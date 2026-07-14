unit FireDACSQLiteWrapperSQLCipherTestCase;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.IOUtils,
  TestFramework,
  FireDAC.Stan.Consts,
  FireDAC.Stan.Error,
  FireDAC.Phys.SQLiteCli,
  FireDAC.Phys.SQLiteWrapper,
  FireDAC.Phys.SQLiteWrapper.SQLCipher,
  sqlite3.common,
  sqlite3.static;

type
  TFireDACSQLiteWrapperSQLCipherTests = class(TTestCase)
  private
    procedure CheckSqliteOk(const Code: Integer; const Context: string; const DB: psqlite3 = nil);
    procedure CloseRawDatabase(var DB: psqlite3);
    procedure DeleteDatabaseFiles(const FileName: string);
    procedure ExecSql(const DB: psqlite3; const SQL: string);
    procedure FinalizeStatement(var Statement: psqlite3_stmt; const DB: psqlite3);
    function OpenRawDatabase(const FileName: string): psqlite3;
    function PrepareV2(const DB: psqlite3; const SQL: string): psqlite3_stmt;
    function QueryScalarText(const DB: psqlite3; const SQL: string): string;
    function TempDatabaseFileName: string;
    function Utf8PtrToString(const Value: Pointer): string;
  published
    procedure RegistersAndLoadsStaticLibrary;
    procedure FireDACDatabaseUsesSQLCipherStaticApi;
    procedure RawWrapperApiCoversModernEntrypoints;
    procedure EncryptedFileRoundTripThroughFireDACWrapper;
  end;

implementation

const
  MAIN_SCHEMA_UTF8: UTF8String = 'main';

procedure TFireDACSQLiteWrapperSQLCipherTests.CheckSqliteOk(const Code: Integer;
  const Context: string; const DB: psqlite3);
var
  Msg: string;
begin
  if Code = SQLITE_OK then
    Exit;

  if DB <> nil then
    Msg := Utf8PtrToString(sqlite3_errmsg(DB))
  else
    Msg := Utf8PtrToString(sqlite3_errstr(Code));
  Fail(Format('%s failed with code %d: %s', [Context, Code, Msg]));
end;

procedure TFireDACSQLiteWrapperSQLCipherTests.CloseRawDatabase(var DB: psqlite3);
var
  Code: Integer;
begin
  if DB = nil then
    Exit;
  Code := sqlite3_close_v2(DB);
  DB := nil;
  CheckSqliteOk(Code, 'sqlite3_close_v2');
end;

procedure TFireDACSQLiteWrapperSQLCipherTests.DeleteDatabaseFiles(const FileName: string);
begin
  if FileName = '' then
    Exit;
  if TFile.Exists(FileName) then
    TFile.Delete(FileName);
  if TFile.Exists(FileName + '-journal') then
    TFile.Delete(FileName + '-journal');
  if TFile.Exists(FileName + '-wal') then
    TFile.Delete(FileName + '-wal');
  if TFile.Exists(FileName + '-shm') then
    TFile.Delete(FileName + '-shm');
end;

procedure TFireDACSQLiteWrapperSQLCipherTests.ExecSql(const DB: psqlite3; const SQL: string);
var
  SQLUtf8: UTF8String;
  ErrMsg: MarshaledAString;
begin
  SQLUtf8 := UTF8String(SQL);
  ErrMsg := nil;
  try
    CheckSqliteOk(sqlite3_exec(DB, MarshaledAString(PAnsiChar(SQLUtf8)), nil, nil, @ErrMsg),
      'sqlite3_exec: ' + SQL, DB);
  finally
    if ErrMsg <> nil then
      sqlite3_free(ErrMsg);
  end;
end;

procedure TFireDACSQLiteWrapperSQLCipherTests.FinalizeStatement(var Statement: psqlite3_stmt;
  const DB: psqlite3);
begin
  if Statement = nil then
    Exit;
  CheckSqliteOk(sqlite3_finalize(Statement), 'sqlite3_finalize', DB);
  Statement := nil;
end;

function TFireDACSQLiteWrapperSQLCipherTests.OpenRawDatabase(const FileName: string): psqlite3;
var
  FileNameUtf8: UTF8String;
begin
  Result := nil;
  FileNameUtf8 := UTF8String(FileName);
  CheckSqliteOk(sqlite3_open_v2(MarshaledAString(PAnsiChar(FileNameUtf8)), Result,
    SQLITE_OPEN_READWRITE or SQLITE_OPEN_CREATE, nil), 'sqlite3_open_v2');
end;

function TFireDACSQLiteWrapperSQLCipherTests.PrepareV2(const DB: psqlite3;
  const SQL: string): psqlite3_stmt;
var
  SQLUtf8: UTF8String;
  Tail: MarshaledAString;
begin
  Result := nil;
  Tail := nil;
  SQLUtf8 := UTF8String(SQL);
  CheckSqliteOk(sqlite3_prepare_v2(DB, MarshaledAString(PAnsiChar(SQLUtf8)), -1, Result, @Tail),
    'sqlite3_prepare_v2: ' + SQL, DB);
end;

function TFireDACSQLiteWrapperSQLCipherTests.QueryScalarText(const DB: psqlite3;
  const SQL: string): string;
var
  Statement: psqlite3_stmt;
begin
  Statement := PrepareV2(DB, SQL);
  try
    CheckEquals(SQLITE_ROW, sqlite3_step(Statement), 'sqlite3_step: ' + SQL);
    Result := Utf8PtrToString(sqlite3_column_text(Statement, 0));
  finally
    FinalizeStatement(Statement, DB);
  end;
end;

function TFireDACSQLiteWrapperSQLCipherTests.TempDatabaseFileName: string;
begin
  Result := TPath.Combine(TPath.GetTempPath,
    Format('DelphiLibSQLite_FireDAC_%d_%d_%d.db',
      [GetCurrentProcessId, GetCurrentThreadId, GetTickCount]));
  DeleteDatabaseFiles(Result);
end;

function TFireDACSQLiteWrapperSQLCipherTests.Utf8PtrToString(const Value: Pointer): string;
begin
  if Value = nil then
    Result := ''
  else
    Result := UTF8ToString(PAnsiChar(Value));
end;

procedure TFireDACSQLiteWrapperSQLCipherTests.RegistersAndLoadsStaticLibrary;
var
  Lib: TSQLiteLibSQLCipherStat;
begin
  CheckTrue(TSQLiteLib.GLibClasses[slSEEStatic] = TSQLiteLibSQLCipherStat,
    'slSEEStatic is not registered to TSQLiteLibSQLCipherStat');

  Lib := TSQLiteLibSQLCipherStat.Create;
  try
    Lib.Load('', '');
    CheckTrue(Lib.Version > 0, 'SQLite version was not detected');
    CheckTrue(Lib.VersionStr <> '', 'SQLite version string was not detected');
    CheckTrue(Assigned(Lib.Fsqlite3_open_v2), 'sqlite3_open_v2 was not assigned');
    CheckTrue(Assigned(Lib.Fsqlite3_key), 'sqlite3_key was not assigned');
    CheckTrue(Assigned(Lib.Fsqlite3_activate_see), 'sqlite3_activate_see was not assigned');
    CheckTrue(Assigned(Lib.Fad_sqlite3GetCacheSize), 'ad_sqlite3GetCacheSize was not assigned');
    CheckTrue(Assigned(Lib.Fad_sqlite3GetEncoding), 'ad_sqlite3GetEncoding was not assigned');
    CheckTrue(Assigned(Lib.Fad_sqlite3GetEncryptionMode), 'ad_sqlite3GetEncryptionMode was not assigned');
    CheckTrue(Assigned(Lib.Fad_sqlite3GetEncryptionError), 'ad_sqlite3GetEncryptionError was not assigned');
    CheckTrue(Assigned(Lib.Fad_sqlite3Error), 'ad_sqlite3Error was not assigned');
    Lib.ActivateSEE('');
  finally
    Lib.Unload;
    Lib.Free;
  end;
end;

procedure TFireDACSQLiteWrapperSQLCipherTests.FireDACDatabaseUsesSQLCipherStaticApi;
var
  Lib: TSQLiteLibSQLCipherStat;
  DB: TSQLiteDatabase;
begin
  Lib := TSQLiteLibSQLCipherStat.Create;
  try
    Lib.Load('', '');
    DB := TSQLiteDatabase.Create(Lib);
    try
      DB.Open(':memory:', smCreate, scDefault);
      CheckEquals('<unencrypted>', DB.Encryption,
        'encryption mode should be empty before SQLCipher key attaches a codec');
      DB.Key('fire-dac-wrapper-key');
      CheckEquals('UTF8', DB.CharacterSet, 'FireDAC did not read SQLite text encoding');
      CheckTrue(DB.CacheSize <> 0, 'FireDAC did not read SQLite cache_size');
      CheckTrue(Pos('SQLCipher/', DB.Encryption) = 1,
        'FireDAC did not read SQLCipher encryption mode');
      ExecSql(DB.Handle, 'create table items(id integer primary key, value text not null);');
      ExecSql(DB.Handle, 'insert into items(value) values(''wrapped'');');
      CheckEquals('wrapped', QueryScalarText(DB.Handle, 'select value from items where id = 1;'),
        'FireDAC wrapper failed to read inserted data');
      CheckTrue(QueryScalarText(DB.Handle, 'pragma cipher_version;') <> '',
        'SQLCipher pragma returned an empty version');
    finally
      DB.Free;
    end;
  finally
    Lib.Unload;
    Lib.Free;
  end;
end;

procedure TFireDACSQLiteWrapperSQLCipherTests.RawWrapperApiCoversModernEntrypoints;
var
  DB: psqlite3;
  Statement: psqlite3_stmt;
  InsertSQL: UTF8String;
  SelectSQL: UTF8String;
  Tail: MarshaledAString;
  Expanded: MarshaledAString;
  KeywordName: MarshaledAString;
  KeywordLength: Integer;
begin
  CheckTrue(sqlite3_threadsafe() <> 0, 'sqlite3_threadsafe returned false');
  CheckTrue(Utf8PtrToString(sqlite3_sourceid()) <> '', 'sqlite3_sourceid returned empty text');

  DB := nil;
  CheckSqliteOk(sqlite3_initialize, 'sqlite3_initialize');
  try
    DB := OpenRawDatabase(':memory:');
    try
      CheckSqliteOk(sqlite3_key(DB, MarshaledAString(PAnsiChar(UTF8String('raw-wrapper-key'))), Length('raw-wrapper-key')),
        'sqlite3_key', DB);
      ExecSql(DB, 'create table items(id integer primary key, value text not null, payload blob);');

      Statement := nil;
      Tail := nil;
      InsertSQL := UTF8String('insert into items(value, payload) values(?1, ?2);');
      CheckSqliteOk(sqlite3_prepare_v3(DB, MarshaledAString(PAnsiChar(InsertSQL)), -1, 0, Statement, @Tail),
        'sqlite3_prepare_v3 insert', DB);
      try
        CheckTrue(sqlite3_db_handle(Statement) = DB, 'sqlite3_db_handle returned unexpected handle');
        CheckSqliteOk(sqlite3_bind_text(Statement, 1, MarshaledAString(PAnsiChar(UTF8String('modern'))), -1, TxDestroy(SQLITE_TRANSIENT)),
          'sqlite3_bind_text', DB);
        CheckSqliteOk(sqlite3_bind_zeroblob64(Statement, 2, 8), 'sqlite3_bind_zeroblob64', DB);
        Expanded := sqlite3_expanded_sql(Statement);
        try
          CheckTrue(Expanded <> nil, 'sqlite3_expanded_sql returned nil');
        finally
          if Expanded <> nil then
            sqlite3_free(Expanded);
        end;
        CheckEquals(SQLITE_DONE, sqlite3_step(Statement), 'sqlite3_step insert');
      finally
        FinalizeStatement(Statement, DB);
      end;

      CheckEquals(1, sqlite3_changes(DB), 'sqlite3_changes mismatch');
      CheckEquals(1, sqlite3_changes64(DB), 'sqlite3_changes64 mismatch');
      CheckTrue(sqlite3_total_changes64(DB) >= 1, 'sqlite3_total_changes64 did not increase');

      Statement := nil;
      Tail := nil;
      SelectSQL := UTF8String('select value, payload from items where id = ?1;');
      CheckSqliteOk(sqlite3_prepare_v3(DB, MarshaledAString(PAnsiChar(SelectSQL)), -1, 0, Statement, @Tail),
        'sqlite3_prepare_v3 select', DB);
      try
        CheckTrue(sqlite3_sql(Statement) <> nil, 'sqlite3_sql returned nil');
        {$IFDEF SQLITE_ENABLE_NORMALIZE}
        CheckTrue(sqlite3_normalized_sql(Statement) <> nil, 'sqlite3_normalized_sql returned nil');
        {$ENDIF}
        CheckEquals(0, sqlite3_stmt_isexplain(Statement), 'sqlite3_stmt_isexplain mismatch');
        CheckSqliteOk(sqlite3_bind_int(Statement, 1, 1), 'sqlite3_bind_int', DB);
        CheckTrue(sqlite3_next_stmt(DB, nil) <> nil, 'sqlite3_next_stmt returned nil while statement was active');
        CheckEquals(SQLITE_ROW, sqlite3_step(Statement), 'sqlite3_step select');
        CheckEquals(2, sqlite3_data_count(Statement), 'sqlite3_data_count mismatch');
        CheckEquals('modern', Utf8PtrToString(sqlite3_column_text(Statement, 0)),
          'sqlite3_column_text mismatch');
        CheckEquals(8, sqlite3_column_bytes(Statement, 1), 'sqlite3_bind_zeroblob64 payload size mismatch');
      finally
        FinalizeStatement(Statement, DB);
      end;

      CheckTrue(sqlite3_db_name(DB, 0) <> nil, 'sqlite3_db_name returned nil');
      CheckTrue(sqlite3_keyword_count() > 0, 'sqlite3_keyword_count returned zero');
      CheckEquals(1, sqlite3_keyword_check(MarshaledAString(PAnsiChar(UTF8String('select'))), Length('select')),
        'sqlite3_keyword_check did not recognize SELECT');
      CheckSqliteOk(sqlite3_keyword_name(0, KeywordName, KeywordLength), 'sqlite3_keyword_name', DB);
      CheckTrue((KeywordName <> nil) and (KeywordLength > 0), 'sqlite3_keyword_name returned empty data');
    finally
      CloseRawDatabase(DB);
    end;
  finally
    CheckSqliteOk(sqlite3_shutdown, 'sqlite3_shutdown');
  end;
end;

procedure TFireDACSQLiteWrapperSQLCipherTests.EncryptedFileRoundTripThroughFireDACWrapper;
var
  Lib: TSQLiteLibSQLCipherStat;
  DB: TSQLiteDatabase;
  FileName: string;
  OldKey: string;
  NewKey: string;
  Statement: TSQLiteStatement;
  WrongPasswordRaised: Boolean;
begin
  FileName := TempDatabaseFileName;
  OldKey := 'old-fire-dac-key';
  NewKey := 'new-fire-dac-key';

  Lib := TSQLiteLibSQLCipherStat.Create;
  try
    Lib.Load('', '');
    DB := TSQLiteDatabase.Create(Lib);
    try
      DB.Open(FileName, smCreate, scDefault);
      DB.Key(OldKey);
      ExecSql(DB.Handle, 'create table secrets(id integer primary key, value text not null);');
      ExecSql(DB.Handle, 'insert into secrets(value) values(''encrypted-wrapper-value'');');
      CheckEquals('encrypted-wrapper-value',
        QueryScalarText(DB.Handle, 'select value from secrets where id = 1;'),
        'encrypted value was not readable before rekey');
      DB.ReKey(NewKey);
    finally
      DB.Free;
    end;

    DB := TSQLiteDatabase.Create(Lib);
    try
      DB.Open(FileName, smReadWrite, scDefault);
      DB.Key(OldKey);
      WrongPasswordRaised := False;
      Statement := TSQLiteStatement.Create(DB);
      try
        try
          Statement.Prepare('select value from secrets where id = 1;');
          Statement.Fetch;
        except
          on E: ESQLiteNativeException do
          begin
            WrongPasswordRaised := True;
            CheckEquals(Ord(ekUserPwdInvalid), Ord(E.Kind),
              'wrong SQLCipher key was not classified as ekUserPwdInvalid');
            CheckEquals(er_FD_SQLitePwdInvalid, E.FDCode,
              'wrong SQLCipher key returned an unexpected FireDAC FDCode');
            CheckTrue(E.ErrorCode in [SQLITE_ERROR, SQLITE_NOTADB],
              'wrong SQLCipher key returned an unexpected native SQLite error code');
            CheckTrue(Pos('Cipher:', E.Message) <> 0,
              'wrong SQLCipher key did not return a cipher error message');
          end;
        end;
        finally
          Statement.Free;
        end;
      CheckTrue(WrongPasswordRaised, 'database was readable with the old key after rekey');
    finally
      DB.Free;
    end;

    DB := TSQLiteDatabase.Create(Lib);
    try
      DB.Open(FileName, smReadWrite, scDefault);
      DB.Key(NewKey);
      CheckEquals('encrypted-wrapper-value',
        QueryScalarText(DB.Handle, 'select value from secrets where id = 1;'),
        'encrypted value was not readable after rekey');
    finally
      DB.Free;
    end;
  finally
    Lib.Unload;
    Lib.Free;
    DeleteDatabaseFiles(FileName);
  end;
end;

initialization
  RegisterTest(TFireDACSQLiteWrapperSQLCipherTests.Suite);

end.
