unit Sqlite3CipheredReferenceTestCase;

interface

uses
  Winapi.Windows,
  System.Classes,
  System.IOUtils,
  System.SysUtils,
  TestFramework,
  sqlite3.common,
  sqlite3.static,
  Sqlite3StaticTestCase;

type
  TSqlite3CipheredReferenceTests = class(TTestCase)
  private
    procedure ApplyKey(const DB: Pointer; const Key: UTF8String);
    procedure ChangePassword(const FileName: string; const OldKey, NewKey: UTF8String);
    procedure CheckEncryptedRead(const FileName: string; const Key: UTF8String;
      const ExpectedGeometryColumns, ExpectedPoints: Integer);
    procedure CheckSqliteOk(const Code: Integer; const Context: string; const DB: Pointer = nil);
    procedure CloseDatabase(var DB: Pointer);
    procedure DeleteDatabaseFiles(const FileName: string);
    procedure DecryptDatabase(const FileName: string; const Key: UTF8String);
    procedure CreateEncryptedCopy(const SourceFileName, DestinationFileName: string;
      const Key: UTF8String);
    function LastError(const DB: Pointer): string;
    function OpenDatabase(const FileName: string; const Flags: Integer): Pointer;
    function QueryScalarInt(const DB: Pointer; const SQL: string): Integer;
    function SourceFileName: string;
    function TempDatabaseFileName: string;
    procedure CheckDatabaseDataEqual(const DatabaseFileName, ReferenceFileName: string);
    procedure CheckOldPasswordRejected(const FileName: string; const OldKey: UTF8String);
  published
    procedure EncryptDecryptAndChangePasswordPreservesReferenceData;
  end;

implementation

const
  PASSWORD_ONE: UTF8String = 'mappl';
  PASSWORD_TWO: UTF8String = 'mapas';

procedure TSqlite3CipheredReferenceTests.CheckSqliteOk(const Code: Integer;
  const Context: string; const DB: Pointer);
begin
  if Code <> SQLITE_OK then
    Fail(Format('%s failed with code %d: %s', [Context, Code, LastError(DB)]));
end;

function TSqlite3CipheredReferenceTests.LastError(const DB: Pointer): string;
begin
  if DB = nil then
    Exit('<no database handle>');
  Result := UTF8ToString(PAnsiChar(sqlite3_errmsg(DB)));
end;

function TSqlite3CipheredReferenceTests.OpenDatabase(const FileName: string;
  const Flags: Integer): Pointer;
var
  FileNameUtf8: UTF8String;
begin
  Result := nil;
  FileNameUtf8 := UTF8String(FileName);
  CheckSqliteOk(sqlite3_open_v2(MarshaledAString(PAnsiChar(FileNameUtf8)), Result,
    Flags, nil), 'sqlite3_open_v2(' + FileName + ')', Result);
end;

procedure TSqlite3CipheredReferenceTests.CloseDatabase(var DB: Pointer);
begin
  if DB = nil then
    Exit;
  CheckSqliteOk(sqlite3_close_v2(DB), 'sqlite3_close_v2', DB);
  DB := nil;
end;

procedure TSqlite3CipheredReferenceTests.ApplyKey(const DB: Pointer;
  const Key: UTF8String);
begin
  CheckSqliteOk(sqlite3_key(DB, MarshaledAString(PAnsiChar(Key)), Length(Key)),
    'sqlite3_key', DB);
end;

procedure TSqlite3CipheredReferenceTests.CreateEncryptedCopy(const SourceFileName,
  DestinationFileName: string; const Key: UTF8String);
var
  SourceDB: Pointer;
  DestinationDB: Pointer;
  DestinationPath: string;
  AttachSql: string;
begin
  DestinationDB := OpenDatabase(DestinationFileName,
    SQLITE_OPEN_READWRITE or SQLITE_OPEN_CREATE or SQLITE_OPEN_URI);
  try
    ApplyKey(DestinationDB, Key);
    CheckSqliteOk(sqlite3_exec_simple(DestinationDB,
      'create table __cipher_export_bootstrap(value integer);'),
      'initialize encrypted destination', DestinationDB);
    CheckSqliteOk(sqlite3_exec_simple(DestinationDB,
      'drop table __cipher_export_bootstrap;'),
      'clean encrypted destination', DestinationDB);
  finally
    CloseDatabase(DestinationDB);
  end;

  SourceDB := OpenDatabase(SourceFileName, SQLITE_OPEN_READWRITE or SQLITE_OPEN_URI);
  try
    DestinationPath := StringReplace(DestinationFileName, '''', '''''', [rfReplaceAll]);
    AttachSql := Format('ATTACH DATABASE ''%s'' AS encrypted KEY ''%s'';',
      [DestinationPath, StringReplace(string(Key), '''', '''''', [rfReplaceAll])]);
    CheckSqliteOk(sqlite3_exec_simple(SourceDB, AttachSql), 'attach encrypted database', SourceDB);
    try
      CheckSqliteOk(sqlite3_exec_simple(SourceDB, 'SELECT sqlcipher_export(''encrypted'');'),
        'sqlcipher_export', SourceDB);
    finally
      CheckSqliteOk(sqlite3_exec_simple(SourceDB, 'DETACH DATABASE encrypted;'),
        'detach encrypted database', SourceDB);
    end;
  finally
    CloseDatabase(SourceDB);
  end;
end;

procedure TSqlite3CipheredReferenceTests.DecryptDatabase(const FileName: string;
  const Key: UTF8String);
var
  DB: Pointer;
  PlainDB: Pointer;
  PlainFileName: string;
  PlainPath: string;
  AttachSql: string;
begin
  PlainFileName := FileName + '.decrypted';
  DeleteDatabaseFiles(PlainFileName);
  PlainDB := OpenDatabase(PlainFileName,
    SQLITE_OPEN_READWRITE or SQLITE_OPEN_CREATE or SQLITE_OPEN_URI);
  CloseDatabase(PlainDB);
  DB := OpenDatabase(FileName, SQLITE_OPEN_READWRITE or SQLITE_OPEN_URI);
  try
    ApplyKey(DB, Key);
    PlainPath := StringReplace(PlainFileName, '''', '''''', [rfReplaceAll]);
    AttachSql := Format('ATTACH DATABASE ''%s'' AS plain KEY '''';', [PlainPath]);
    CheckSqliteOk(sqlite3_exec_simple(DB, AttachSql), 'attach plaintext database', DB);
    try
      CheckSqliteOk(sqlite3_exec_simple(DB, 'SELECT sqlcipher_export(''plain'');'),
        'sqlcipher_export plaintext', DB);
    finally
      CheckSqliteOk(sqlite3_exec_simple(DB, 'DETACH DATABASE plain;'),
        'detach plaintext database', DB);
    end;
  finally
    CloseDatabase(DB);
  end;
  DeleteDatabaseFiles(FileName);
  TFile.Move(PlainFileName, FileName);
end;

procedure TSqlite3CipheredReferenceTests.ChangePassword(const FileName: string;
  const OldKey, NewKey: UTF8String);
var
  DB: Pointer;
begin
  DB := OpenDatabase(FileName, SQLITE_OPEN_READWRITE or SQLITE_OPEN_URI);
  try
    ApplyKey(DB, OldKey);
    CheckSqliteOk(sqlite3_rekey(DB, MarshaledAString(PAnsiChar(NewKey)), Length(NewKey)),
      'sqlite3_rekey change password', DB);
  finally
    CloseDatabase(DB);
  end;
end;

function TSqlite3CipheredReferenceTests.QueryScalarInt(const DB: Pointer;
  const SQL: string): Integer;
var
  Statement: Pointer;
  SQLUtf8: UTF8String;
begin
  Statement := nil;
  SQLUtf8 := UTF8String(SQL);
  CheckSqliteOk(sqlite3_prepare_v2(DB, MarshaledAString(PAnsiChar(SQLUtf8)), -1,
    Statement, nil), 'sqlite3_prepare_v2: ' + SQL, DB);
  try
    CheckEquals(SQLITE_ROW, sqlite3_step(Statement), 'sqlite3_step: ' + SQL);
    Result := sqlite3_column_int(Statement, 0);
  finally
    CheckSqliteOk(sqlite3_finalize(Statement), 'sqlite3_finalize', DB);
  end;
end;

procedure TSqlite3CipheredReferenceTests.CheckEncryptedRead(const FileName: string;
  const Key: UTF8String; const ExpectedGeometryColumns, ExpectedPoints: Integer);
var
  DB: Pointer;
begin
  DB := OpenDatabase(FileName, SQLITE_OPEN_READWRITE or SQLITE_OPEN_URI);
  try
    ApplyKey(DB, Key);
    CheckEquals(ExpectedGeometryColumns, QueryScalarInt(DB, 'select count(*) from geometry_columns;'),
      'geometry_columns mismatch while encrypted');
    CheckEquals(ExpectedPoints, QueryScalarInt(DB, 'select count(*) from points;'),
      'points mismatch while encrypted');
    CheckTrue(QueryScalarInt(DB, 'select count(*) from spatial_ref_sys;') > 0,
      'spatial_ref_sys is empty while encrypted');
  finally
    CloseDatabase(DB);
  end;
end;

procedure TSqlite3CipheredReferenceTests.CheckOldPasswordRejected(const FileName: string;
  const OldKey: UTF8String);
var
  DB: Pointer;
  Statement: Pointer;
  SQLUtf8: UTF8String;
  Code: Integer;
  Rejected: Boolean;
begin
  DB := OpenDatabase(FileName, SQLITE_OPEN_READWRITE or SQLITE_OPEN_URI);
  try
    ApplyKey(DB, OldKey);
    Statement := nil;
    SQLUtf8 := UTF8String('select count(*) from geometry_columns;');
    Code := sqlite3_prepare_v2(DB, MarshaledAString(PAnsiChar(SQLUtf8)), -1, Statement, nil);
    Rejected := Code <> SQLITE_OK;
    if not Rejected then
    begin
      try
        Rejected := sqlite3_step(Statement) <> SQLITE_ROW;
      finally
        sqlite3_finalize(Statement);
      end;
    end;
    CheckTrue(Rejected, 'the old password still opened the rekeyed database');
  finally
    CloseDatabase(DB);
  end;
end;

procedure TSqlite3CipheredReferenceTests.DeleteDatabaseFiles(const FileName: string);
const
  Suffixes: array[0..3] of string = ('', '-journal', '-wal', '-shm');
var
  Suffix: string;
begin
  for Suffix in Suffixes do
    if TFile.Exists(FileName + Suffix) then
      TFile.Delete(FileName + Suffix);
end;

procedure TSqlite3CipheredReferenceTests.CheckDatabaseDataEqual(const DatabaseFileName,
  ReferenceFileName: string);
var
  DB: Pointer;
  ReferenceDB: Pointer;
  Statement: Pointer;
  Tail: MarshaledAString;
  TableName: string;
  TableNameUtf8: UTF8String;
  SQLUtf8: UTF8String;
  CountSql: string;
begin
  DB := OpenDatabase(DatabaseFileName, SQLITE_OPEN_READWRITE or SQLITE_OPEN_URI);
  try
    ReferenceDB := OpenDatabase(ReferenceFileName, SQLITE_OPEN_READONLY or SQLITE_OPEN_URI);
    try
      CheckEquals(QueryScalarInt(ReferenceDB, 'select count(*) from sqlite_master;'),
        QueryScalarInt(DB, 'select count(*) from sqlite_master;'),
        'schema object count differs from reference');
      SQLUtf8 := UTF8String('select name from sqlite_master where type = ''table'' order by name;');
      Statement := nil;
      Tail := nil;
      CheckSqliteOk(sqlite3_prepare_v2(ReferenceDB, MarshaledAString(PAnsiChar(SQLUtf8)), -1,
        Statement, @Tail), 'prepare reference table list', DB);
      try
        while sqlite3_step(Statement) = SQLITE_ROW do
        begin
          TableName := UTF8ToString(sqlite3_column_text(Statement, 0));
          TableNameUtf8 := UTF8String(StringReplace(TableName, '"', '""', [rfReplaceAll]));
          CountSql := Format('select count(*) from main."%s";', [TableNameUtf8]);
          CheckEquals(QueryScalarInt(ReferenceDB, CountSql), QueryScalarInt(DB, CountSql),
            'row count mismatch for table ' + TableName);
        end;
      finally
        sqlite3_finalize(Statement);
      end;
    finally
      CloseDatabase(ReferenceDB);
    end;
  finally
    CloseDatabase(DB);
  end;
end;

function TSqlite3CipheredReferenceTests.SourceFileName: string;
begin
  Result := TPath.GetFullPath(TPath.Combine(ExtractFileDir(ParamStr(0)),
    '..\..\..\data\perm_krai.sqlite'));
end;

function TSqlite3CipheredReferenceTests.TempDatabaseFileName: string;
begin
  Result := TPath.Combine(TPath.GetTempPath,
    Format('DelphiLibSQLite_Reference_%d_%d_%d.db',
      [GetCurrentProcessId, GetCurrentThreadId, GetTickCount]));
  DeleteDatabaseFiles(Result);
end;

procedure TSqlite3CipheredReferenceTests.EncryptDecryptAndChangePasswordPreservesReferenceData;
var
  SourceFile: string;
  WorkFile: string;
  ReencryptedFile: string;
  ExpectedGeometryColumns: Integer;
  ExpectedPoints: Integer;
  SourceDB: Pointer;
begin
  SourceFile := SourceFileName;
  if not TFile.Exists(SourceFile) then
  begin
    Status('Skipped: test data is not available: ' + SourceFile);
    Exit;
  end;
  CheckSqliteOk(sqlite3_initialize, 'sqlite3_initialize');
  SourceDB := OpenDatabase(SourceFile, SQLITE_OPEN_READONLY or SQLITE_OPEN_URI);
  try
    ExpectedGeometryColumns := QueryScalarInt(SourceDB, 'select count(*) from geometry_columns;');
    ExpectedPoints := QueryScalarInt(SourceDB, 'select count(*) from points;');
  finally
    CloseDatabase(SourceDB);
  end;

  WorkFile := TempDatabaseFileName;
  try
    CreateEncryptedCopy(SourceFile, WorkFile, PASSWORD_ONE);
    CheckEncryptedRead(WorkFile, PASSWORD_ONE, ExpectedGeometryColumns, ExpectedPoints);

    DecryptDatabase(WorkFile, PASSWORD_ONE);
    CheckDatabaseDataEqual(WorkFile, SourceFile);

    ReencryptedFile := WorkFile + '.reencrypted';
    DeleteDatabaseFiles(ReencryptedFile);
    CreateEncryptedCopy(WorkFile, ReencryptedFile, PASSWORD_ONE);
    DeleteDatabaseFiles(WorkFile);
    TFile.Move(ReencryptedFile, WorkFile);
    ChangePassword(WorkFile, PASSWORD_ONE, PASSWORD_TWO);
    CheckOldPasswordRejected(WorkFile, PASSWORD_ONE);
    CheckEncryptedRead(WorkFile, PASSWORD_TWO, ExpectedGeometryColumns, ExpectedPoints);

    DecryptDatabase(WorkFile, PASSWORD_TWO);
    CheckDatabaseDataEqual(WorkFile, SourceFile);
  finally
    if GetEnvironmentVariable('SQLITE_CIPHER_KEEP_TEMP') = '' then
      DeleteDatabaseFiles(WorkFile)
    else
      Writeln('Preserved reference database: ', WorkFile);
  end;
end;

initialization
  RegisterTest(TSqlite3CipheredReferenceTests.Suite);

end.
