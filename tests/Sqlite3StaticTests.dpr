program Sqlite3StaticTests;

{$APPTYPE CONSOLE}

uses
  Winapi.Windows,
  System.SysUtils,
  System.IOUtils,
  sqlite3.common,
  sqlite3.static;

type
  ETestFailure = class(Exception);

var
  TestsRun: Integer = 0;
  TestsFailed: Integer = 0;

procedure Fail(const Message: string);
begin
  raise ETestFailure.Create(Message);
end;

procedure Check(const Condition: Boolean; const Message: string);
begin
  if not Condition then
    Fail(Message);
end;

function LastError(const DB: Pointer): string;
begin
  if DB = nil then
    Exit('<no database handle>');
  Result := string(UTF8String(AnsiString(sqlite3_errmsg(DB))));
end;

procedure CheckSqliteOk(const Code: Integer; const Context: string; const DB: Pointer = nil);
begin
  if Code <> SQLITE_OK then
    Fail(Format('%s failed with code %d: %s', [Context, Code, LastError(DB)]));
end;

function OpenDatabase(const FileName: string): Pointer;
var
  FileNameUtf8: UTF8String;
  Code: Integer;
begin
  Result := nil;
  FileNameUtf8 := UTF8String(FileName);
  Code := sqlite3_open_v2(
    MarshaledAString(PAnsiChar(FileNameUtf8)),
    Result,
    SQLITE_OPEN_READWRITE or SQLITE_OPEN_CREATE or SQLITE_OPEN_URI,
    nil);
  CheckSqliteOk(Code, 'sqlite3_open_v2(' + FileName + ')', Result);
end;

procedure CloseDatabase(var DB: Pointer);
var
  Code: Integer;
begin
  if DB = nil then
    Exit;

  Code := sqlite3_close(DB);
  DB := nil;
  CheckSqliteOk(Code, 'sqlite3_close');
end;

procedure ExecSql(const DB: Pointer; const SQL: string);
var
  SQLUtf8: UTF8String;
  ErrorMessage: MarshaledAString;
  Code: Integer;
  Details: string;
begin
  ErrorMessage := nil;
  SQLUtf8 := UTF8String(SQL);
  Code := sqlite3_exec(DB, MarshaledAString(PAnsiChar(SQLUtf8)), nil, nil, @ErrorMessage);
  if Code <> SQLITE_OK then
  begin
    if ErrorMessage <> nil then
    begin
      Details := string(UTF8String(AnsiString(ErrorMessage)));
      sqlite3_free(ErrorMessage);
    end
    else
      Details := LastError(DB);
    Fail(Format('SQL failed with code %d: %s; SQL=%s', [Code, Details, SQL]));
  end;
end;

function QueryScalarText(const DB: Pointer; const SQL: string): string;
var
  SQLUtf8: UTF8String;
  Statement: Pointer;
  Code: Integer;
  TextValue: MarshaledAString;
begin
  Result := '';
  Statement := nil;
  SQLUtf8 := UTF8String(SQL);
  Code := sqlite3_prepare_v2(DB, MarshaledAString(PAnsiChar(SQLUtf8)), -1, Statement, nil);
  CheckSqliteOk(Code, 'sqlite3_prepare_v2(' + SQL + ')', DB);
  try
    Code := sqlite3_step(Statement);
    if Code = SQLITE_ROW then
    begin
      TextValue := sqlite3_column_text(Statement, 0);
      if TextValue <> nil then
        Result := string(UTF8String(AnsiString(TextValue)));
    end
    else if Code <> SQLITE_DONE then
      Fail(Format('sqlite3_step failed with code %d: %s', [Code, LastError(DB)]));
  finally
    Code := sqlite3_finalize(Statement);
    CheckSqliteOk(Code, 'sqlite3_finalize', DB);
  end;
end;

function QueryScalarInt(const DB: Pointer; const SQL: string): Integer;
var
  SQLUtf8: UTF8String;
  Statement: Pointer;
  Code: Integer;
begin
  Result := 0;
  Statement := nil;
  SQLUtf8 := UTF8String(SQL);
  Code := sqlite3_prepare_v2(DB, MarshaledAString(PAnsiChar(SQLUtf8)), -1, Statement, nil);
  CheckSqliteOk(Code, 'sqlite3_prepare_v2(' + SQL + ')', DB);
  try
    Code := sqlite3_step(Statement);
    if Code <> SQLITE_ROW then
      Fail(Format('sqlite3_step expected SQLITE_ROW, got %d: %s', [Code, LastError(DB)]));
    Result := sqlite3_column_int(Statement, 0);
  finally
    Code := sqlite3_finalize(Statement);
    CheckSqliteOk(Code, 'sqlite3_finalize', DB);
  end;
end;

procedure ApplyKey(const DB: Pointer; const Key: UTF8String);
begin
  CheckSqliteOk(sqlite3_key(DB, MarshaledAString(PAnsiChar(Key)), Length(Key)), 'sqlite3_key', DB);
end;

function CompileOptionUsed(const Name: string): Boolean;
var
  NameUtf8: UTF8String;
begin
  NameUtf8 := UTF8String(Name);
  Result := sqlite3_compileoption_used(MarshaledAString(PAnsiChar(NameUtf8))) <> 0;
end;

procedure TestCompileOptions;
begin
  Check(sqlite3_libversion_number > 0, 'sqlite3_libversion_number returned zero');
  Check(CompileOptionUsed('SQLITE_HAS_CODEC'), 'SQLITE_HAS_CODEC compile option is missing');
end;

procedure TestInMemoryCrud;
var
  DB: Pointer;
begin
  DB := OpenDatabase(':memory:');
  try
    ExecSql(DB, 'create table items(id integer primary key, name text not null);');
    ExecSql(DB, 'insert into items(name) values(''alpha''),(''beta'');');
    Check(QueryScalarInt(DB, 'select count(*) from items;') = 2, 'unexpected row count from in-memory table');
    Check(QueryScalarText(DB, 'select name from items where id = 2;') = 'beta', 'unexpected row value from in-memory table');
  finally
    CloseDatabase(DB);
  end;
end;

procedure TestCipherPragma;
var
  DB: Pointer;
  CipherVersion: string;
  CipherProvider: string;
  Key: UTF8String;
begin
  Key := UTF8String('pragma-provider-check');
  DB := OpenDatabase(':memory:');
  try
    ApplyKey(DB, Key);
    CipherVersion := QueryScalarText(DB, 'pragma cipher_version;');
    Check(CipherVersion <> '', 'pragma cipher_version returned an empty value');
    CipherProvider := QueryScalarText(DB, 'pragma cipher_provider;');
    Check(CipherProvider <> '', 'pragma cipher_provider returned an empty value');
  finally
    CloseDatabase(DB);
  end;
end;

procedure TestNormalizeFunction;
var
  SQLUtf8: UTF8String;
  Normalized: MarshaledAString;
  NormalizedText: string;
begin
  SQLUtf8 := UTF8String('select 1, ''literal'' where value = 42;');
  Normalized := sqlite3_normalize(MarshaledAString(PAnsiChar(SQLUtf8)));
  Check(Normalized <> nil, 'sqlite3_normalize returned nil');
  try
    NormalizedText := string(UTF8String(AnsiString(Normalized)));
    Check(NormalizedText <> '', 'sqlite3_normalize returned an empty string');
  finally
    sqlite3_free(Normalized);
  end;
end;

procedure TestEncryptedDatabaseRoundTrip;
var
  DB: Pointer;
  FileName: string;
  Key: UTF8String;
begin
  FileName := TPath.Combine(TPath.GetTempPath, Format('DelphiLibSQLite_%d_%d.db', [GetCurrentProcessId, GetTickCount]));
  Key := UTF8String('correct horse battery staple');

  if TFile.Exists(FileName) then
    TFile.Delete(FileName);

  DB := OpenDatabase(FileName);
  try
    ApplyKey(DB, Key);
    ExecSql(DB, 'create table secret_items(id integer primary key, value text not null);');
    ExecSql(DB, 'insert into secret_items(value) values(''encrypted-value'');');
    Check(QueryScalarText(DB, 'select value from secret_items where id = 1;') = 'encrypted-value', 'encrypted write/read failed before close');
  finally
    CloseDatabase(DB);
  end;

  DB := OpenDatabase(FileName);
  try
    ApplyKey(DB, Key);
    Check(QueryScalarText(DB, 'select value from secret_items where id = 1;') = 'encrypted-value', 'encrypted write/read failed after reopen');
  finally
    CloseDatabase(DB);
  end;

  DB := OpenDatabase(FileName);
  try
    try
      QueryScalarText(DB, 'select value from secret_items where id = 1;');
      Fail('encrypted database was readable without sqlite3_key');
    except
      on E: ETestFailure do
      begin
        if Pos('expected SQLITE_ROW', E.Message) > 0 then
          raise;
      end;
    end;
  finally
    CloseDatabase(DB);
    if TFile.Exists(FileName) then
      TFile.Delete(FileName);
  end;
end;

procedure RunTest(const Name: string; const Proc: TProc);
begin
  Inc(TestsRun);
  Write(Name, ' ... ');
  try
    Proc();
    Writeln('OK');
  except
    on E: Exception do
    begin
      Inc(TestsFailed);
      Writeln('FAILED');
      Writeln('  ', E.ClassName, ': ', E.Message);
    end;
  end;
end;

begin
  try
    CheckSqliteOk(sqlite3_initialize, 'sqlite3_initialize');
    RunTest('compile options', TestCompileOptions);
    RunTest('in-memory CRUD', TestInMemoryCrud);
    RunTest('cipher pragma', TestCipherPragma);
    RunTest('normalize function', TestNormalizeFunction);
    RunTest('encrypted database round trip', TestEncryptedDatabaseRoundTrip);

    Writeln;
    Writeln(Format('Tests run: %d, failures: %d', [TestsRun, TestsFailed]));
    CheckSqliteOk(sqlite3_shutdown, 'sqlite3_shutdown');
    if TestsFailed <> 0 then
      Halt(1);
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
      Halt(1);
    end;
  end;
end.
