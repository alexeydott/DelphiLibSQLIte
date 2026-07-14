unit Sqlite3StaticTestCase;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.IOUtils,
  System.Variants,
  TestFramework,
  sqlite3.common,
  sqlite3.static;

type
  TSqlite3StaticApiTests = class(TTestCase)
  private
    function LastError(const DB: Pointer): string;
    function OpenDatabase(const FileName: string): Pointer;
    function Prepare(const DB: Pointer; const SQL: string): Pointer;
    function QueryScalarText(const DB: Pointer; const SQL: string): string;
    function QueryScalarInt(const DB: Pointer; const SQL: string): Integer;
    function QueryScalarInt64(const DB: Pointer; const SQL: string): Int64;
    function TempDatabaseFileName: string;
    procedure ApplyKey(const DB: Pointer; const Key: UTF8String);
    procedure ApplyKeyV2(const DB: Pointer; const Key: UTF8String);
    procedure CheckSqliteOk(const Code: Integer; const Context: string; const DB: Pointer = nil);
    procedure CloseDatabase(var DB: Pointer);
    procedure DeleteDatabaseFiles(const FileName: string);
    procedure ExecSql(const DB: Pointer; const SQL: string);
    procedure FinalizeStatement(var Statement: Pointer; const DB: Pointer);
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure VersionAndCompileOptions;
    procedure OpenCloseAndDatabaseMetadata;
    procedure MetadataLoadExtensionAndErrorApis;
    procedure ExecGetTableAndCrud;
    procedure PreparedStatementsBindAndColumns;
    procedure PreparedSqlTextAndNormalize;
    procedure UserFunctionsCollationsAndValues;
    procedure CollationNeededCallbacks;
    procedure HooksProgressAuthorizerAndTrace;
    procedure BlobBackupSerializeAndStatus;
    procedure WalCheckpointAndFilenameApis;
    procedure StringMemoryUriVfsAndMutexApis;
    procedure ExtensionRegistrationAndCArray;
    procedure CipherPragmasAndEncryptedRoundTrip;
  end;

implementation

type
  PExecCallbackState = ^TExecCallbackState;
  TExecCallbackState = record
    RowCount: Integer;
    ColumnCount: Integer;
  end;

  PFunctionState = ^TFunctionState;
  TFunctionState = record
    CallCount: Integer;
    DestroyCount: Integer;
    AuxDestroyCount: Integer;
    FromBindCount: Integer;
    PointerSeen: Integer;
    LastType: Integer;
    ContextDb: Pointer;
  end;

  PCollationState = ^TCollationState;
  TCollationState = record
    CompareCount: Integer;
    DestroyCount: Integer;
    NeededCalls: Integer;
    Needed16Calls: Integer;
  end;

  PHookState = ^THookState;
  THookState = record
    AuthorizerCalls: Integer;
    TraceCalls: Integer;
    ProgressCalls: Integer;
    CommitCalls: Integer;
    RollbackCalls: Integer;
    UpdateCalls: Integer;
    WalCalls: Integer;
    AutoVacuumCalls: Integer;
  end;

  PBusyState = ^TBusyState;
  TBusyState = record
    Calls: Integer;
  end;

  PDumpState = ^TDumpState;
  TDumpState = record
    Lines: Integer;
  end;

const
  DUNIT_POINTER_TYPE: UTF8String = 'dunit.pointer';
  MAIN_SCHEMA: UTF8String = 'main';
  STATIC_BLOB: array[0..2] of Byte = (1, 2, 3);
  STATIC_BLOB64: array[0..3] of Byte = (4, 5, 6, 7);

function Utf8PtrToString(const Value: MarshaledAString): string;
begin
  if Value = nil then
    Exit('');
  Result := string(UTF8String(AnsiString(Value)));
end;

function Utf16PtrToString(const Value: MarshaledString): string;
begin
  if Value = nil then
    Exit('');
  Result := string(Value);
end;

function BlobToAnsiString(const Value: Pointer; const Size: Integer): AnsiString;
begin
  Result := '';
  if (Value <> nil) and (Size > 0) then
    SetString(Result, PAnsiChar(Value), Size);
end;

function ExecCountingCallback(Param: Pointer; NumCols: Integer; var ColTextStrs: PMarshaledAString; var ColNameStrs: PMarshaledAString): Integer; cdecl;
begin
  Inc(PExecCallbackState(Param)^.RowCount);
  PExecCallbackState(Param)^.ColumnCount := NumCols;
  Result := SQLITE_OK;
end;

function BusyCallback(Ptr: Pointer; NumberOfInvocations: Integer): Integer; cdecl;
begin
  Inc(PBusyState(Ptr)^.Calls);
  Result := 0;
end;

procedure FunctionDestroy(Ptr: Pointer); cdecl;
begin
  if Ptr <> nil then
    Inc(PFunctionState(Ptr)^.DestroyCount);
end;

procedure AuxDataDestroy(Ptr: Pointer); cdecl;
begin
  if Ptr <> nil then
    Inc(PFunctionState(Ptr)^.AuxDestroyCount);
end;

procedure TwiceFunction(pCtx: PSQLite3FuncContext; ArgNum: Integer; ArgValues: PSQLiteValues); cdecl;
var
  State: PFunctionState;
  Aux: Pointer;
begin
  State := PFunctionState(sqlite3_user_data(pCtx));
  if State <> nil then
  begin
    Inc(State^.CallCount);
    State^.ContextDb := sqlite3_context_db_handle(pCtx);
  end;

  if ArgNum <> 1 then
  begin
    sqlite3_result_error_code(pCtx, SQLITE_MISUSE);
    Exit;
  end;

  if State <> nil then
  begin
    State^.LastType := sqlite3_value_type(ArgValues[0]);
    if sqlite3_value_frombind(ArgValues[0]) <> 0 then
      Inc(State^.FromBindCount);
  end;

  Aux := sqlite3_get_auxdata(pCtx, 0);
  if Aux = nil then
    sqlite3_set_auxdata(pCtx, 0, State, AuxDataDestroy);

  sqlite3_result_int(pCtx, sqlite3_value_int(ArgValues[0]) * 2);
end;

procedure PointerFunction(pCtx: PSQLite3FuncContext; ArgNum: Integer; ArgValues: PSQLiteValues); cdecl;
var
  PointerValue: Pointer;
  State: PFunctionState;
begin
  State := PFunctionState(sqlite3_user_data(pCtx));
  PointerValue := nil;
  if ArgNum = 1 then
    PointerValue := sqlite3_value_pointer(ArgValues[0], MarshaledAString(PAnsiChar(DUNIT_POINTER_TYPE)));
  if (PointerValue <> nil) and (State <> nil) then
    Inc(State^.PointerSeen);
  sqlite3_result_int(pCtx, Ord(PointerValue <> nil));
end;

procedure StaticBlobFunction(pCtx: PSQLite3FuncContext; ArgNum: Integer; ArgValues: PSQLiteValues); cdecl;
begin
  sqlite3_result_blob(pCtx, @STATIC_BLOB[0], SizeOf(STATIC_BLOB), nil);
end;

procedure StaticBlob64Function(pCtx: PSQLite3FuncContext; ArgNum: Integer; ArgValues: PSQLiteValues); cdecl;
begin
  sqlite3_result_blob64(pCtx, @STATIC_BLOB64[0], SizeOf(STATIC_BLOB64), nil);
end;

procedure StaticZeroBlobFunction(pCtx: PSQLite3FuncContext; ArgNum: Integer; ArgValues: PSQLiteValues); cdecl;
begin
  sqlite3_result_zeroblob64(pCtx, 5);
end;

procedure StaticNullFunction(pCtx: PSQLite3FuncContext; ArgNum: Integer; ArgValues: PSQLiteValues); cdecl;
begin
  sqlite3_result_null(pCtx);
end;

procedure StaticDoubleFunction(pCtx: PSQLite3FuncContext; ArgNum: Integer; ArgValues: PSQLiteValues); cdecl;
begin
  sqlite3_result_double(pCtx, 12.5);
end;

procedure EchoValueFunction(pCtx: PSQLite3FuncContext; ArgNum: Integer; ArgValues: PSQLiteValues); cdecl;
begin
  if ArgNum = 1 then
    sqlite3_result_value(pCtx, ArgValues[0])
  else
    sqlite3_result_null(pCtx);
end;

procedure AggregateStep(pCtx: PSQLite3FuncContext; ArgNum: Integer; ArgValues: PSQLiteValues); cdecl;
var
  Sum: PInt64;
begin
  Sum := PInt64(sqlite3_aggregate_context(pCtx, SizeOf(Int64)));
  if (Sum <> nil) and (ArgNum = 1) then
    Sum^ := Sum^ + sqlite3_value_int64(ArgValues[0]);
end;

procedure AggregateFinal(pCtx: PSQLite3FuncContext); cdecl;
var
  Sum: PInt64;
begin
  Sum := PInt64(sqlite3_aggregate_context(pCtx, 0));
  if Sum = nil then
    sqlite3_result_null(pCtx)
  else
    sqlite3_result_int64(pCtx, Sum^);
end;

function LengthCompare(pArg: Pointer; Size1: Integer; Str1: Pointer; Size2: Integer; Str2: Pointer): Integer; cdecl;
var
  LeftValue: AnsiString;
  RightValue: AnsiString;
begin
  if pArg <> nil then
    Inc(PCollationState(pArg)^.CompareCount);

  LeftValue := BlobToAnsiString(Str1, Size1);
  RightValue := BlobToAnsiString(Str2, Size2);
  Result := Length(LeftValue) - Length(RightValue);
  if Result = 0 then
    Result := CompareStr(string(LeftValue), string(RightValue));
end;

procedure CollationDestroy(Ptr: Pointer); cdecl;
begin
  if Ptr <> nil then
    Inc(PCollationState(Ptr)^.DestroyCount);
end;

procedure CollationNeededCallback(pUserData: Pointer; pDB: Pointer; eTextRep: Integer; SequenceName: MarshaledAString); cdecl;
begin
  if pUserData <> nil then
    Inc(PCollationState(pUserData)^.NeededCalls);
  sqlite3_create_collation(pDB, SequenceName, SQLITE_UTF8, pUserData, LengthCompare);
end;

procedure CollationNeeded16Callback(pUserData: Pointer; pDB: Pointer; eTextRep: Integer; SequenceName: Pointer); cdecl;
begin
  if pUserData <> nil then
    Inc(PCollationState(pUserData)^.Needed16Calls);
  sqlite3_create_collation16(pDB, PChar(SequenceName), SQLITE_UTF16, pUserData, LengthCompare);
end;

function AuthorizerCallback(UserData: Pointer; ActionCode: Integer; Str1, Str2, Str3, Str4: MarshaledAString): Integer; cdecl;
begin
  if UserData <> nil then
    Inc(PHookState(UserData)^.AuthorizerCalls);
  Result := SQLITE_OK;
end;

procedure TraceCallback(reason: Cardinal; pCtx: Pointer; P: Pointer; X: Pointer); cdecl;
begin
  if ((reason and SQLITE_TRACE_STMT) <> 0) and (pCtx <> nil) then
    Inc(PHookState(pCtx)^.TraceCalls);
end;

function ProgressCallback(pUserData: Pointer): Integer; cdecl;
begin
  if pUserData <> nil then
    Inc(PHookState(pUserData)^.ProgressCalls);
  Result := 0;
end;

function CommitCallback(Ptr: Pointer): Integer; cdecl;
begin
  if Ptr <> nil then
    Inc(PHookState(Ptr)^.CommitCalls);
  Result := 0;
end;

procedure RollbackCallback(Ptr: Pointer); cdecl;
begin
  if Ptr <> nil then
    Inc(PHookState(Ptr)^.RollbackCalls);
end;

procedure UpdateCallback(Ptr: Pointer; Operation: Integer; DbName, TableName: MarshaledAString; RowId: Int64); cdecl;
begin
  if Ptr <> nil then
    Inc(PHookState(Ptr)^.UpdateCalls);
end;

function WalCallback(Ptr: Pointer; pDB: Pointer; DbName: MarshaledAString; NumPages: Integer): Integer; cdecl;
begin
  if Ptr <> nil then
    Inc(PHookState(Ptr)^.WalCalls);
  Result := SQLITE_OK;
end;

function AutoVacuumCallback(pClientData: Pointer; zSchema: MarshaledAString; nDbPage, nFreePage, nBytePerPage: Cardinal): Cardinal; cdecl;
begin
  if pClientData <> nil then
    Inc(PHookState(pClientData)^.AutoVacuumCalls);
  Result := 0;
end;

procedure DumpCallback(const z: MarshaledAString; pContext: Pointer); cdecl;
begin
  if pContext <> nil then
    Inc(PDumpState(pContext)^.Lines);
end;

function CompileOptionUsed(const Name: string): Boolean;
var
  NameUtf8: UTF8String;
begin
  NameUtf8 := UTF8String(Name);
  Result := sqlite3_compileoption_used(MarshaledAString(PAnsiChar(NameUtf8))) <> 0;
end;

procedure TSqlite3StaticApiTests.SetUp;
begin
  inherited;
  CheckSqliteOk(sqlite3_initialize, 'sqlite3_initialize');
end;

procedure TSqlite3StaticApiTests.TearDown;
begin
  CheckSqliteOk(sqlite3_shutdown, 'sqlite3_shutdown');
  inherited;
end;

function TSqlite3StaticApiTests.LastError(const DB: Pointer): string;
begin
  if DB = nil then
    Exit('<no database handle>');
  Result := Utf8PtrToString(sqlite3_errmsg(DB));
end;

procedure TSqlite3StaticApiTests.CheckSqliteOk(const Code: Integer; const Context: string; const DB: Pointer);
begin
  if Code <> SQLITE_OK then
    Fail(Format('%s failed with code %d: %s', [Context, Code, LastError(DB)]));
end;

function TSqlite3StaticApiTests.OpenDatabase(const FileName: string): Pointer;
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

procedure TSqlite3StaticApiTests.CloseDatabase(var DB: Pointer);
var
  Code: Integer;
begin
  if DB = nil then
    Exit;

  Code := sqlite3_close(DB);
  DB := nil;
  CheckSqliteOk(Code, 'sqlite3_close');
end;

procedure TSqlite3StaticApiTests.DeleteDatabaseFiles(const FileName: string);
const
  Suffixes: array[0..3] of string = ('', '-journal', '-wal', '-shm');
var
  Suffix: string;
  Candidate: string;
begin
  for Suffix in Suffixes do
  begin
    Candidate := FileName + Suffix;
    if TFile.Exists(Candidate) then
      TFile.Delete(Candidate);
  end;
end;

function TSqlite3StaticApiTests.TempDatabaseFileName: string;
begin
  Result := TPath.Combine(
    TPath.GetTempPath,
    Format('DelphiLibSQLite_DUnit_%d_%d_%d.db', [GetCurrentProcessId, GetCurrentThreadId, GetTickCount]));
  DeleteDatabaseFiles(Result);
end;

procedure TSqlite3StaticApiTests.ExecSql(const DB: Pointer; const SQL: string);
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
      Details := Utf8PtrToString(ErrorMessage);
      sqlite3_free(ErrorMessage);
    end
    else
      Details := LastError(DB);
    Fail(Format('SQL failed with code %d: %s; SQL=%s', [Code, Details, SQL]));
  end;
end;

function TSqlite3StaticApiTests.Prepare(const DB: Pointer; const SQL: string): Pointer;
var
  SQLUtf8: UTF8String;
  Code: Integer;
begin
  Result := nil;
  SQLUtf8 := UTF8String(SQL);
  Code := sqlite3_prepare_v2(DB, MarshaledAString(PAnsiChar(SQLUtf8)), -1, Result, nil);
  CheckSqliteOk(Code, 'sqlite3_prepare_v2(' + SQL + ')', DB);
end;

procedure TSqlite3StaticApiTests.FinalizeStatement(var Statement: Pointer; const DB: Pointer);
var
  Code: Integer;
begin
  if Statement = nil then
    Exit;
  Code := sqlite3_finalize(Statement);
  Statement := nil;
  CheckSqliteOk(Code, 'sqlite3_finalize', DB);
end;

function TSqlite3StaticApiTests.QueryScalarText(const DB: Pointer; const SQL: string): string;
var
  Statement: Pointer;
  Code: Integer;
begin
  Result := '';
  Statement := Prepare(DB, SQL);
  try
    Code := sqlite3_step(Statement);
    if Code <> SQLITE_ROW then
      Fail(Format('sqlite3_step expected SQLITE_ROW, got %d: %s', [Code, LastError(DB)]));
    Result := Utf8PtrToString(sqlite3_column_text(Statement, 0));
  finally
    FinalizeStatement(Statement, DB);
  end;
end;

function TSqlite3StaticApiTests.QueryScalarInt(const DB: Pointer; const SQL: string): Integer;
var
  Statement: Pointer;
  Code: Integer;
begin
  Statement := Prepare(DB, SQL);
  try
    Code := sqlite3_step(Statement);
    if Code <> SQLITE_ROW then
      Fail(Format('sqlite3_step expected SQLITE_ROW, got %d: %s', [Code, LastError(DB)]));
    Result := sqlite3_column_int(Statement, 0);
  finally
    FinalizeStatement(Statement, DB);
  end;
end;

function TSqlite3StaticApiTests.QueryScalarInt64(const DB: Pointer; const SQL: string): Int64;
var
  Statement: Pointer;
  Code: Integer;
begin
  Statement := Prepare(DB, SQL);
  try
    Code := sqlite3_step(Statement);
    if Code <> SQLITE_ROW then
      Fail(Format('sqlite3_step expected SQLITE_ROW, got %d: %s', [Code, LastError(DB)]));
    Result := sqlite3_column_int64(Statement, 0);
  finally
    FinalizeStatement(Statement, DB);
  end;
end;

procedure TSqlite3StaticApiTests.ApplyKey(const DB: Pointer; const Key: UTF8String);
begin
  CheckSqliteOk(sqlite3_key(DB, MarshaledAString(PAnsiChar(Key)), Length(Key)), 'sqlite3_key', DB);
end;

procedure TSqlite3StaticApiTests.ApplyKeyV2(const DB: Pointer; const Key: UTF8String);
begin
  CheckSqliteOk(sqlite3_key_v2(DB, MarshaledAString(PAnsiChar(MAIN_SCHEMA)), MarshaledAString(PAnsiChar(Key)), Length(Key)), 'sqlite3_key_v2', DB);
end;

procedure TSqlite3StaticApiTests.VersionAndCompileOptions;
var
  SQLUtf8: UTF8String;
  SQLWide: string;
  KeywordName: MarshaledAString;
  KeywordLength: Integer;
  KeywordText: AnsiString;
begin
  CheckEquals(SQLITE_VERSION_NUMBER, sqlite3_libversion_number, 'sqlite3_libversion_number differs from sqlite3.common.pas');
  CheckTrue(Utf8PtrToString(sqlite3_libversion) <> '', 'sqlite3_libversion returned an empty value');
  CheckTrue(Utf8PtrToString(sqlite3_sourceid) <> '', 'sqlite3_sourceid returned an empty value');
  CheckTrue(sqlite3_threadsafe >= 0, 'sqlite3_threadsafe returned an invalid value');

  CheckTrue(CompileOptionUsed('SQLITE_HAS_CODEC'), 'SQLITE_HAS_CODEC compile option is missing');
  CheckTrue(CompileOptionUsed('SQLITE_ENABLE_NORMALIZE'), 'SQLITE_ENABLE_NORMALIZE compile option is missing');
  CheckTrue(sqlite3_compileoption_get(0) <> nil, 'sqlite3_compileoption_get(0) returned nil');

  SQLUtf8 := UTF8String('select 1;');
  CheckEquals(1, sqlite3_complete(MarshaledAString(PAnsiChar(SQLUtf8))), 'sqlite3_complete did not accept a complete statement');
  SQLUtf8 := UTF8String('select 1');
  CheckEquals(0, sqlite3_complete(MarshaledAString(PAnsiChar(SQLUtf8))), 'sqlite3_complete accepted an incomplete statement');
  SQLWide := 'select 1;';
  CheckEquals(1, sqlite3_complete16(PChar(SQLWide)), 'sqlite3_complete16 did not accept a complete statement');

  CheckTrue(sqlite3_keyword_count > 0, 'sqlite3_keyword_count returned zero');
  KeywordName := nil;
  KeywordLength := 0;
  CheckSqliteOk(sqlite3_keyword_name(0, KeywordName, KeywordLength), 'sqlite3_keyword_name');
  SetString(KeywordText, PAnsiChar(KeywordName), KeywordLength);
  CheckTrue(KeywordText <> '', 'sqlite3_keyword_name returned an empty keyword');
  SQLUtf8 := UTF8String('select');
  CheckTrue(sqlite3_keyword_check(MarshaledAString(PAnsiChar(SQLUtf8)), Length(SQLUtf8)) <> 0, 'sqlite3_keyword_check did not recognize SELECT');
end;

procedure TSqlite3StaticApiTests.OpenCloseAndDatabaseMetadata;
var
  DB: Pointer;
  SecondDB: Pointer;
  FileName: string;
  FileNameUtf8: UTF8String;
  MemoryUtf8: UTF8String;
  MainUtf8: UTF8String;
  ClientKey: UTF8String;
  ErrorSql: UTF8String;
  Statement: Pointer;
  Code: Integer;
  ClientValue: Integer;
begin
  FileName := TempDatabaseFileName;
  DB := nil;
  try
    DB := OpenDatabase(FileName);
    CheckSqliteOk(sqlite3_extended_result_codes(DB, 1), 'sqlite3_extended_result_codes', DB);
    CheckSqliteOk(sqlite3_busy_timeout(DB, 5), 'sqlite3_busy_timeout', DB);

    ExecSql(DB, 'create table metadata_items(id integer primary key, name text not null);');
    ExecSql(DB, 'insert into metadata_items(name) values(''alpha'');');
    CheckEquals(Int64(1), sqlite3_last_insert_rowid(DB), 'sqlite3_last_insert_rowid mismatch');
    sqlite3_set_last_insert_rowid(DB, 777);
    CheckEquals(Int64(777), sqlite3_last_insert_rowid(DB), 'sqlite3_set_last_insert_rowid did not update the value');

    MainUtf8 := UTF8String('main');
    CheckEquals('main', Utf8PtrToString(sqlite3_db_name(DB, 0)), 'sqlite3_db_name mismatch');
    CheckTrue(Utf8PtrToString(sqlite3_db_filename(DB, PAnsiChar(MainUtf8))) <> '', 'sqlite3_db_filename returned an empty value');
    CheckTrue(sqlite3_limit(DB, SQLITE_LIMIT_VARIABLE_NUMBER, -1) > 0, 'sqlite3_limit returned an invalid variable limit');

    ClientValue := 42;
    ClientKey := UTF8String('dunit.client');
    CheckSqliteOk(sqlite3_set_clientdata(DB, MarshaledAString(PAnsiChar(ClientKey)), @ClientValue, nil), 'sqlite3_set_clientdata', DB);
    CheckTrue(sqlite3_get_clientdata(DB, MarshaledAString(PAnsiChar(ClientKey))) = @ClientValue, 'sqlite3_get_clientdata returned a wrong pointer');

    ErrorSql := UTF8String('select * from missing_table');
    Statement := nil;
    Code := sqlite3_prepare_v2(DB, MarshaledAString(PAnsiChar(ErrorSql)), -1, Statement, nil);
    CheckTrue(Code <> SQLITE_OK, 'invalid SQL unexpectedly prepared');
    CheckTrue(sqlite3_errcode(DB) <> SQLITE_OK, 'sqlite3_errcode did not report an error');
    CheckTrue(sqlite3_extended_errcode(DB) <> SQLITE_OK, 'sqlite3_extended_errcode did not report an error');
    CheckTrue(Utf8PtrToString(sqlite3_errmsg(DB)) <> '', 'sqlite3_errmsg returned an empty value');
    CheckTrue(Utf16PtrToString(sqlite3_errmsg16(DB)) <> '', 'sqlite3_errmsg16 returned an empty value');
    CheckTrue(Utf8PtrToString(sqlite3_errstr(Code)) <> '', 'sqlite3_errstr returned an empty value');
    CheckTrue(sqlite3_error_offset(DB) >= -1, 'sqlite3_error_offset returned an invalid value');
    CheckTrue(sqlite3_system_errno(DB) >= 0, 'sqlite3_system_errno returned an invalid value');
    if Statement <> nil then
      FinalizeStatement(Statement, DB);

    sqlite3_interrupt(DB);
    CheckTrue(sqlite3_is_interrupted(DB) <> 0, 'sqlite3_is_interrupted did not report the pending interrupt');
  finally
    CloseDatabase(DB);
    DeleteDatabaseFiles(FileName);
  end;

  MemoryUtf8 := UTF8String(':memory:');
  SecondDB := nil;
  CheckSqliteOk(sqlite3_open(MarshaledAString(PAnsiChar(MemoryUtf8)), SecondDB), 'sqlite3_open', SecondDB);
  CloseDatabase(SecondDB);

  SecondDB := nil;
  CheckSqliteOk(sqlite3_open16(PChar(':memory:'), SecondDB), 'sqlite3_open16', SecondDB);
  CloseDatabase(SecondDB);

  FileName := TempDatabaseFileName;
  FileNameUtf8 := UTF8String(FileName);
  SecondDB := nil;
  try
    CheckSqliteOk(sqlite3_open_v2(MarshaledAString(PAnsiChar(FileNameUtf8)), SecondDB, SQLITE_OPEN_READWRITE or SQLITE_OPEN_CREATE, nil), 'sqlite3_open_v2', SecondDB);
    CheckSqliteOk(sqlite3_close_v2(SecondDB), 'sqlite3_close_v2');
    SecondDB := nil;
  finally
    if SecondDB <> nil then
      CloseDatabase(SecondDB);
    DeleteDatabaseFiles(FileName);
  end;
end;

procedure TSqlite3StaticApiTests.MetadataLoadExtensionAndErrorApis;
var
  DB: Pointer;
  ReadOnlyDB: Pointer;
  FileName: string;
  FileNameUtf8: UTF8String;
  MainUtf8: UTF8String;
  TableUtf8: UTF8String;
  ColumnUtf8: UTF8String;
  MessageUtf8: UTF8String;
  MissingExtensionUtf8: UTF8String;
  DataType: MarshaledAString;
  CollSeq: MarshaledAString;
  ErrorMessage: MarshaledAString;
  NotNull: Integer;
  PrimaryKey: Integer;
  AutoInc: Integer;
  Code: Integer;
begin
  DB := OpenDatabase(':memory:');
  try
    ExecSql(DB, 'create table metadata_items(id integer primary key autoincrement, name text not null collate nocase);');
    MainUtf8 := UTF8String('main');
    TableUtf8 := UTF8String('metadata_items');
    ColumnUtf8 := UTF8String('name');
    DataType := nil;
    CollSeq := nil;
    NotNull := 0;
    PrimaryKey := 0;
    AutoInc := 0;
    CheckEquals(0, sqlite3_db_readonly(DB, MarshaledAString(PAnsiChar(MainUtf8))), 'sqlite3_db_readonly should report writable main db');
    CheckSqliteOk(sqlite3_setlk_timeout(DB, 0, 0), 'sqlite3_setlk_timeout', DB);
    CheckSqliteOk(
      sqlite3_table_column_metadata(
        DB,
        MarshaledAString(PAnsiChar(MainUtf8)),
        MarshaledAString(PAnsiChar(TableUtf8)),
        MarshaledAString(PAnsiChar(ColumnUtf8)),
        @DataType,
        @CollSeq,
        @NotNull,
        @PrimaryKey,
        @AutoInc),
      'sqlite3_table_column_metadata name',
      DB);
    CheckEquals('TEXT', UpperCase(Utf8PtrToString(DataType)), 'column data type mismatch');
    CheckEquals('NOCASE', UpperCase(Utf8PtrToString(CollSeq)), 'column collation mismatch');
    CheckEquals(1, NotNull, 'column not-null metadata mismatch');
    CheckEquals(0, PrimaryKey, 'column primary-key metadata mismatch');
    CheckEquals(0, AutoInc, 'column autoincrement metadata mismatch');

    ColumnUtf8 := UTF8String('id');
    DataType := nil;
    CollSeq := nil;
    NotNull := 0;
    PrimaryKey := 0;
    AutoInc := 0;
    CheckSqliteOk(
      sqlite3_table_column_metadata(
        DB,
        MarshaledAString(PAnsiChar(MainUtf8)),
        MarshaledAString(PAnsiChar(TableUtf8)),
        MarshaledAString(PAnsiChar(ColumnUtf8)),
        @DataType,
        @CollSeq,
        @NotNull,
        @PrimaryKey,
        @AutoInc),
      'sqlite3_table_column_metadata id',
      DB);
    CheckEquals('INTEGER', UpperCase(Utf8PtrToString(DataType)), 'id data type mismatch');
    CheckEquals(1, PrimaryKey, 'id primary-key metadata mismatch');
    CheckEquals(1, AutoInc, 'id autoincrement metadata mismatch');

    MessageUtf8 := UTF8String('forced dunit error');
    CheckSqliteOk(sqlite3_set_errmsg(DB, SQLITE_NOTICE, MarshaledAString(PAnsiChar(MessageUtf8))), 'sqlite3_set_errmsg notice', DB);
    CheckEquals(SQLITE_NOTICE, sqlite3_errcode(DB), 'sqlite3_set_errmsg errcode mismatch');
    CheckEquals('forced dunit error', Utf8PtrToString(sqlite3_errmsg(DB)), 'sqlite3_set_errmsg message mismatch');
    CheckSqliteOk(sqlite3_set_errmsg(DB, SQLITE_OK, nil), 'sqlite3_set_errmsg clear', DB);

    CheckSqliteOk(sqlite3_enable_load_extension(DB, 1), 'sqlite3_enable_load_extension on', DB);
    ErrorMessage := nil;
    MissingExtensionUtf8 := UTF8String('DelphiLibSQLiteDUnitMissingExtension');
    Code := sqlite3_load_extension(DB, MarshaledAString(PAnsiChar(MissingExtensionUtf8)), nil, @ErrorMessage);
    CheckTrue(Code <> SQLITE_OK, 'sqlite3_load_extension unexpectedly loaded a missing extension');
    if ErrorMessage <> nil then
      sqlite3_free(ErrorMessage);
    CheckSqliteOk(sqlite3_enable_load_extension(DB, 0), 'sqlite3_enable_load_extension off', DB);
  finally
    CloseDatabase(DB);
  end;

  FileName := TempDatabaseFileName;
  DB := OpenDatabase(FileName);
  try
    ExecSql(DB, 'create table readonly_items(id integer primary key);');
  finally
    CloseDatabase(DB);
  end;

  ReadOnlyDB := nil;
  FileNameUtf8 := UTF8String(FileName);
  try
    CheckSqliteOk(sqlite3_open_v2(MarshaledAString(PAnsiChar(FileNameUtf8)), ReadOnlyDB, SQLITE_OPEN_READONLY, nil), 'sqlite3_open_v2 readonly', ReadOnlyDB);
    CheckEquals(1, sqlite3_db_readonly(ReadOnlyDB, MarshaledAString(PAnsiChar(MainUtf8))), 'sqlite3_db_readonly should report read-only main db');
  finally
    CloseDatabase(ReadOnlyDB);
    DeleteDatabaseFiles(FileName);
  end;
end;

procedure TSqlite3StaticApiTests.ExecGetTableAndCrud;
var
  DB: Pointer;
  CallbackState: TExecCallbackState;
  Table: PMarshaledAString;
  Values: PMarshaledAStrings;
  ErrorMessage: MarshaledAString;
  Rows: Integer;
  Columns: Integer;
  SQLUtf8: UTF8String;
begin
  DB := OpenDatabase(':memory:');
  try
    CheckSqliteOk(sqlite3_exec_simple(DB, 'create table items(id integer primary key, name text not null);'), 'sqlite3_exec_simple create table', DB);
    ExecSql(DB, 'insert into items(name) values(''alpha''),(''beta''),(''gamma'');');

    FillChar(CallbackState, SizeOf(CallbackState), 0);
    SQLUtf8 := UTF8String('select id, name from items order by id;');
    CheckSqliteOk(sqlite3_exec(DB, MarshaledAString(PAnsiChar(SQLUtf8)), ExecCountingCallback, @CallbackState, nil), 'sqlite3_exec callback', DB);
    CheckEquals(3, CallbackState.RowCount, 'sqlite3_exec callback row count mismatch');
    CheckEquals(2, CallbackState.ColumnCount, 'sqlite3_exec callback column count mismatch');

    CheckEquals(3, QueryScalarInt(DB, 'select count(*) from items;'), 'unexpected row count');
    CheckEquals('beta', QueryScalarText(DB, 'select name from items where id = 2;'), 'unexpected row value');
    CheckEquals(3, sqlite3_changes(DB), 'sqlite3_changes mismatch');
    CheckEquals(Int64(3), sqlite3_changes64(DB), 'sqlite3_changes64 mismatch');
    CheckTrue(sqlite3_total_changes(DB) >= 3, 'sqlite3_total_changes mismatch');
    CheckTrue(sqlite3_total_changes64(DB) >= 3, 'sqlite3_total_changes64 mismatch');

    Table := nil;
    ErrorMessage := nil;
    Rows := 0;
    Columns := 0;
    SQLUtf8 := UTF8String('select id, name from items order by id;');
    CheckSqliteOk(sqlite3_get_table(DB, MarshaledAString(PAnsiChar(SQLUtf8)), Table, Rows, Columns, ErrorMessage), 'sqlite3_get_table', DB);
    try
      CheckEquals(3, Rows, 'sqlite3_get_table row count mismatch');
      CheckEquals(2, Columns, 'sqlite3_get_table column count mismatch');
      Values := PMarshaledAStrings(Table);
      CheckEquals('id', Utf8PtrToString(Values^[0]), 'sqlite3_get_table first column name mismatch');
      CheckEquals('alpha', Utf8PtrToString(Values^[3]), 'sqlite3_get_table first row value mismatch');
    finally
      sqlite3_free_table(Table);
      if ErrorMessage <> nil then
        sqlite3_free(ErrorMessage);
    end;

    CheckEquals(SQLITE_TXN_NONE, sqlite3_txn_state(DB, MarshaledAString(PAnsiChar(MAIN_SCHEMA))), 'initial transaction state mismatch');
    ExecSql(DB, 'begin immediate;');
    CheckEquals(SQLITE_TXN_WRITE, sqlite3_txn_state(DB, MarshaledAString(PAnsiChar(MAIN_SCHEMA))), 'write transaction state mismatch');
    ExecSql(DB, 'rollback;');
    CheckEquals(SQLITE_TXN_NONE, sqlite3_txn_state(DB, MarshaledAString(PAnsiChar(MAIN_SCHEMA))), 'final transaction state mismatch');
  finally
    CloseDatabase(DB);
  end;
end;

procedure TSqlite3StaticApiTests.PreparedStatementsBindAndColumns;
var
  DB: Pointer;
  Statement: Pointer;
  SQLUtf8: UTF8String;
  NameUtf8: UTF8String;
  BlobValue: AnsiString;
  Blob64Value: AnsiString;
  Text64Value: UTF8String;
  Integer64Value: Int64;
  ColumnBlob: Pointer;
  ColumnValue: PSQLiteValue;
  DuplicatedValue: PSQLiteValue;
  SourceStatement: Pointer;
  TargetStatement: Pointer;
begin
  DB := OpenDatabase(':memory:');
  try
    ExecSql(DB, 'create table bind_test(i integer, i64 integer, r real, t text, t64 text, w text, b blob, b64 blob, z blob, z64 blob, n, v text);');
    Statement := Prepare(DB, 'insert into bind_test values(:i,:i64,:r,:t,:t64,:w,:b,:b64,:z,:z64,:n,:v);');
    try
      CheckEquals(12, sqlite3_bind_parameter_count(Statement), 'sqlite3_bind_parameter_count mismatch');
      CheckEquals(':i', Utf8PtrToString(sqlite3_bind_parameter_name(Statement, 1)), 'sqlite3_bind_parameter_name mismatch');
      NameUtf8 := UTF8String(':v');
      CheckEquals(12, sqlite3_bind_parameter_index(Statement, MarshaledAString(PAnsiChar(NameUtf8))), 'sqlite3_bind_parameter_index mismatch');
      CheckSqliteOk(sqlite3_clear_bindings(Statement), 'sqlite3_clear_bindings', DB);

      Integer64Value := 1234567890123;
      Text64Value := UTF8String('text64-value');
      BlobValue := AnsiString('blob');
      Blob64Value := AnsiString('blob2');

      CheckSqliteOk(sqlite3_bind_int(Statement, 1, 7), 'sqlite3_bind_int', DB);
      CheckSqliteOk(sqlite3_bind_int64(Statement, 2, Integer64Value), 'sqlite3_bind_int64', DB);
      CheckSqliteOk(sqlite3_bind_double(Statement, 3, 3.25), 'sqlite3_bind_double', DB);
      CheckSqliteOk(sqlite3_bind_text(Statement, 4, UTF8String('alpha')), 'sqlite3_bind_text helper', DB);
      CheckSqliteOk(sqlite3_bind_text64(Statement, 5, MarshaledAString(PAnsiChar(Text64Value)), Length(Text64Value), nil, SQLITE_UTF8), 'sqlite3_bind_text64', DB);
      CheckSqliteOk(sqlite3_bind_text16(Statement, 6, 'wide-text'), 'sqlite3_bind_text16 helper', DB);
      CheckSqliteOk(sqlite3_bind_blob(Statement, 7, PAnsiChar(BlobValue), Length(BlobValue), nil), 'sqlite3_bind_blob', DB);
      CheckSqliteOk(sqlite3_bind_blob64(Statement, 8, PAnsiChar(Blob64Value), Length(Blob64Value), nil), 'sqlite3_bind_blob64', DB);
      CheckSqliteOk(sqlite3_bind_zeroblob(Statement, 9, 3), 'sqlite3_bind_zeroblob', DB);
      CheckSqliteOk(sqlite3_bind_zeroblob64(Statement, 10, 4), 'sqlite3_bind_zeroblob64', DB);
      CheckSqliteOk(sqlite3_bind_null(Statement, 11), 'sqlite3_bind_null', DB);
      CheckSqliteOk(sqlite3_bind_variant(Statement, 12, Variant('variant-text')), 'sqlite3_bind_variant', DB);

      CheckEquals(SQLITE_DONE, sqlite3_step(Statement), 'sqlite3_step insert mismatch');
      CheckSqliteOk(sqlite3_reset(Statement), 'sqlite3_reset insert', DB);
    finally
      FinalizeStatement(Statement, DB);
    end;

    Statement := Prepare(DB, 'select i,i64,r,t,t64,w,b,b64,z,z64,n,v from bind_test;');
    try
      CheckEquals(12, sqlite3_column_count(Statement), 'sqlite3_column_count mismatch');
      CheckEquals('i', Utf8PtrToString(sqlite3_column_name(Statement, 0)), 'sqlite3_column_name mismatch');
      CheckEquals('i', Utf16PtrToString(sqlite3_column_name16(Statement, 0)), 'sqlite3_column_name16 mismatch');
      CheckTrue(Utf8PtrToString(sqlite3_column_decltype(Statement, 0)) <> '', 'sqlite3_column_decltype returned an empty value');
      if sqlite3_column_database_name(Statement, 0) <> nil then
        CheckEquals('main', Utf8PtrToString(sqlite3_column_database_name(Statement, 0)), 'sqlite3_column_database_name mismatch');
      if sqlite3_column_table_name(Statement, 0) <> nil then
        CheckEquals('bind_test', Utf8PtrToString(sqlite3_column_table_name(Statement, 0)), 'sqlite3_column_table_name mismatch');
      if sqlite3_column_origin_name(Statement, 0) <> nil then
        CheckEquals('i', Utf8PtrToString(sqlite3_column_origin_name(Statement, 0)), 'sqlite3_column_origin_name mismatch');

      CheckEquals(SQLITE_ROW, sqlite3_step(Statement), 'sqlite3_step select mismatch');
      CheckEquals(12, sqlite3_data_count(Statement), 'sqlite3_data_count mismatch');
      CheckEquals(7, sqlite3_column_int(Statement, 0), 'sqlite3_column_int mismatch');
      CheckEquals(Integer64Value, sqlite3_column_int64(Statement, 1), 'sqlite3_column_int64 mismatch');
      CheckEquals(3.25, sqlite3_column_double(Statement, 2), 0.0001, 'sqlite3_column_double mismatch');
      CheckEquals('alpha', Utf8PtrToString(sqlite3_column_text(Statement, 3)), 'sqlite3_column_text mismatch');
      CheckEquals('text64-value', Utf8PtrToString(sqlite3_column_text(Statement, 4)), 'sqlite3_column_text64 value mismatch');
      CheckEquals('wide-text', Utf16PtrToString(sqlite3_column_text16(Statement, 5)), 'sqlite3_column_text16 mismatch');
      CheckTrue(sqlite3_column_bytes16(Statement, 5) >= Length('wide-text') * SizeOf(WideChar), 'sqlite3_column_bytes16 mismatch');

      ColumnBlob := sqlite3_column_blob(Statement, 6);
      CheckEquals(BlobValue, BlobToAnsiString(ColumnBlob, sqlite3_column_bytes(Statement, 6)), 'sqlite3_column_blob mismatch');
      ColumnBlob := sqlite3_column_blob(Statement, 7);
      CheckEquals(Blob64Value, BlobToAnsiString(ColumnBlob, sqlite3_column_bytes(Statement, 7)), 'sqlite3_column_blob64 mismatch');
      CheckEquals(3, sqlite3_column_bytes(Statement, 8), 'sqlite3_column zeroblob bytes mismatch');
      CheckEquals(4, sqlite3_column_bytes(Statement, 9), 'sqlite3_column zeroblob64 bytes mismatch');
      CheckEquals(SQLITE_NULL, sqlite3_column_type(Statement, 10), 'sqlite3_column_type null mismatch');
      CheckEquals('variant-text', Utf8PtrToString(sqlite3_column_text(Statement, 11)), 'sqlite3_bind_variant value mismatch');

      ColumnValue := sqlite3_column_value(Statement, 0);
      CheckTrue(ColumnValue <> nil, 'sqlite3_column_value returned nil');
      CheckEquals(SQLITE_INTEGER, sqlite3_value_type(ColumnValue), 'sqlite3_value_type mismatch');
      CheckEquals(7, sqlite3_value_int(ColumnValue), 'sqlite3_value_int mismatch');
      CheckEquals(Int64(7), sqlite3_value_int64(ColumnValue), 'sqlite3_value_int64 mismatch');
      CheckEquals(SQLITE_INTEGER, sqlite3_value_numeric_type(ColumnValue), 'sqlite3_value_numeric_type mismatch');
      CheckEquals(0, sqlite3_value_frombind(ColumnValue), 'sqlite3_value_frombind should be false for table values');
      DuplicatedValue := sqlite3_value_dup(ColumnValue);
      CheckTrue(DuplicatedValue <> nil, 'sqlite3_value_dup returned nil');
      try
        CheckEquals(7, sqlite3_value_int(DuplicatedValue), 'sqlite3_value_dup value mismatch');
      finally
        sqlite3_value_free(DuplicatedValue);
      end;

      CheckEquals(SQLITE_DONE, sqlite3_step(Statement), 'sqlite3_step should finish after one row');
    finally
      FinalizeStatement(Statement, DB);
    end;

    SQLUtf8 := UTF8String('select ?1;');
    SourceStatement := nil;
    TargetStatement := nil;
    CheckSqliteOk(sqlite3_prepare_v2(DB, MarshaledAString(PAnsiChar(SQLUtf8)), -1, SourceStatement, nil), 'sqlite3_prepare_v2 bind_value source', DB);
    try
      CheckSqliteOk(sqlite3_bind_int(SourceStatement, 1, 91), 'sqlite3_bind_int source', DB);
      CheckEquals(SQLITE_ROW, sqlite3_step(SourceStatement), 'sqlite3_step bind_value source');
      ColumnValue := sqlite3_column_value(SourceStatement, 0);
      TargetStatement := Prepare(DB, 'select ?1;');
      try
        CheckSqliteOk(sqlite3_bind_value(TargetStatement, 1, ColumnValue), 'sqlite3_bind_value', DB);
        CheckEquals(SQLITE_ROW, sqlite3_step(TargetStatement), 'sqlite3_step bind_value target');
        CheckEquals(91, sqlite3_column_int(TargetStatement, 0), 'sqlite3_bind_value mismatch');
      finally
        FinalizeStatement(TargetStatement, DB);
      end;
    finally
      FinalizeStatement(SourceStatement, DB);
    end;
  finally
    CloseDatabase(DB);
  end;
end;

procedure TSqlite3StaticApiTests.PreparedSqlTextAndNormalize;
var
  DB: Pointer;
  Statement: Pointer;
  ExplainStatement: Pointer;
  LegacyStatement: Pointer;
  SQLUtf8: UTF8String;
  SQLWide: string;
  Tail: MarshaledAString;
  Tail16: MarshaledString;
  Expanded: MarshaledAString;
  Normalized: MarshaledAString;
begin
  DB := OpenDatabase(':memory:');
  try
    Statement := nil;
    SQLUtf8 := UTF8String('select :x + 1 as result where :x = 41;');
    CheckSqliteOk(sqlite3_prepare_v3(DB, MarshaledAString(PAnsiChar(SQLUtf8)), -1, SQLITE_PREPARE_PERSISTENT or SQLITE_PREPARE_NORMALIZE, Statement, nil), 'sqlite3_prepare_v3', DB);
    try
      CheckTrue(sqlite3_db_handle(Statement) = DB, 'sqlite3_db_handle mismatch');
      CheckTrue(sqlite3_next_stmt(DB, nil) = Statement, 'sqlite3_next_stmt did not find the active statement');
      CheckTrue(Utf8PtrToString(sqlite3_sql(Statement)) <> '', 'sqlite3_sql returned an empty value');
      CheckTrue(Utf8PtrToString(sqlite3_normalized_sql(Statement)) <> '', 'sqlite3_normalized_sql returned an empty value');
      CheckTrue(sqlite3_stmt_readonly(Statement) <> 0, 'sqlite3_stmt_readonly did not report a read-only statement');
      CheckEquals(0, sqlite3_stmt_busy(Statement), 'new statement should not be busy');
      CheckEquals(1, sqlite3_bind_parameter_index(Statement, MarshaledAString(PAnsiChar(UTF8String(':x')))), 'parameter index mismatch');
      CheckSqliteOk(sqlite3_bind_int(Statement, 1, 41), 'sqlite3_bind_int normalize test', DB);

      Expanded := sqlite3_expanded_sql(Statement);
      CheckTrue(Expanded <> nil, 'sqlite3_expanded_sql returned nil');
      sqlite3_free(Expanded);
      CheckTrue(sqlite3_expanded_sql_text(Statement) <> '', 'sqlite3_expanded_sql_text returned an empty value');

      CheckEquals(SQLITE_ROW, sqlite3_step(Statement), 'sqlite3_step normalized statement');
      CheckEquals(42, sqlite3_column_int(Statement, 0), 'normalized statement result mismatch');
      CheckTrue(sqlite3_stmt_busy(Statement) <> 0, 'row-producing statement should be busy before reset');
      CheckTrue(sqlite3_stmt_status(Statement, SQLITE_STMTSTATUS_VM_STEP, 0) > 0, 'sqlite3_stmt_status VM step counter mismatch');
      CheckSqliteOk(sqlite3_reset(Statement), 'sqlite3_reset normalized statement', DB);
      CheckEquals(SQLITE_ROW, sqlite3_try_step(Statement, 2, 1), 'sqlite3_try_step mismatch');
    finally
      FinalizeStatement(Statement, DB);
    end;

    SQLUtf8 := UTF8String('select 1; select 2;');
    LegacyStatement := nil;
    Tail := nil;
    CheckSqliteOk(sqlite3_prepare(DB, MarshaledAString(PAnsiChar(SQLUtf8)), -1, LegacyStatement, @Tail), 'sqlite3_prepare legacy', DB);
    try
      CheckEquals(SQLITE_ROW, sqlite3_step(LegacyStatement), 'legacy sqlite3_prepare statement did not step');
    finally
      FinalizeStatement(LegacyStatement, DB);
    end;
    CheckTrue(Tail <> nil, 'sqlite3_prepare did not expose a SQL tail');

    SQLWide := 'select 2;';
    Statement := nil;
    Tail16 := nil;
    CheckSqliteOk(sqlite3_prepare16_v2(DB, PChar(SQLWide), -1, Statement, @Tail16), 'sqlite3_prepare16_v2', DB);
    try
      CheckEquals(SQLITE_ROW, sqlite3_step(Statement), 'sqlite3_prepare16_v2 statement did not step');
      CheckEquals(2, sqlite3_column_int(Statement, 0), 'sqlite3_prepare16_v2 result mismatch');
    finally
      FinalizeStatement(Statement, DB);
    end;

    SQLWide := 'select 3;';
    Statement := nil;
    CheckSqliteOk(sqlite3_prepare16_v3(DB, PChar(SQLWide), -1, SQLITE_PREPARE_PERSISTENT, Statement, nil), 'sqlite3_prepare16_v3', DB);
    try
      CheckEquals(SQLITE_ROW, sqlite3_step(Statement), 'sqlite3_prepare16_v3 statement did not step');
      CheckEquals(3, sqlite3_column_int(Statement, 0), 'sqlite3_prepare16_v3 result mismatch');
    finally
      FinalizeStatement(Statement, DB);
    end;

    SQLUtf8 := UTF8String('select 1, ''literal'' where value = 42;');
    Normalized := sqlite3_normalize(MarshaledAString(PAnsiChar(SQLUtf8)));
    CheckTrue(Normalized <> nil, 'sqlite3_normalize returned nil');
    try
      CheckTrue(Utf8PtrToString(Normalized) <> '', 'sqlite3_normalize returned an empty value');
    finally
      sqlite3_free(Normalized);
    end;

    ExplainStatement := Prepare(DB, 'select 1;');
    try
      CheckEquals(0, sqlite3_stmt_isexplain(ExplainStatement), 'plain statement should not be EXPLAIN');
      CheckSqliteOk(sqlite3_stmt_explain(ExplainStatement, 1), 'sqlite3_stmt_explain enable', DB);
      CheckEquals(1, sqlite3_stmt_isexplain(ExplainStatement), 'sqlite3_stmt_explain did not switch mode');
      CheckEquals(SQLITE_ROW, sqlite3_step(ExplainStatement), 'EXPLAIN statement did not produce rows');
    finally
      FinalizeStatement(ExplainStatement, DB);
    end;
  finally
    CloseDatabase(DB);
  end;
end;

procedure TSqlite3StaticApiTests.UserFunctionsCollationsAndValues;
var
  DB: Pointer;
  Statement: Pointer;
  FunctionState: TFunctionState;
  CollationState: TCollationState;
  NameUtf8: UTF8String;
  PointerValue: Integer;
begin
  FillChar(FunctionState, SizeOf(FunctionState), 0);
  FillChar(CollationState, SizeOf(CollationState), 0);
  DB := OpenDatabase(':memory:');
  try
    NameUtf8 := UTF8String('twice');
    CheckSqliteOk(sqlite3_create_function_v2(DB, MarshaledAString(PAnsiChar(NameUtf8)), 1, SQLITE_UTF8 or SQLITE_DETERMINISTIC, @FunctionState, TwiceFunction, nil, nil, FunctionDestroy), 'sqlite3_create_function_v2 twice', DB);
    NameUtf8 := UTF8String('dunit_sum');
    CheckSqliteOk(sqlite3_create_function(DB, MarshaledAString(PAnsiChar(NameUtf8)), 1, SQLITE_UTF8, nil, nil, AggregateStep, AggregateFinal), 'sqlite3_create_function aggregate', DB);
    NameUtf8 := UTF8String('ptr_is_set');
    CheckSqliteOk(sqlite3_create_function_v2(DB, MarshaledAString(PAnsiChar(NameUtf8)), 1, SQLITE_UTF8, @FunctionState, PointerFunction, nil, nil, nil), 'sqlite3_create_function_v2 pointer', DB);
    NameUtf8 := UTF8String('static_blob');
    CheckSqliteOk(sqlite3_create_function_v2(DB, MarshaledAString(PAnsiChar(NameUtf8)), 0, SQLITE_UTF8, nil, StaticBlobFunction, nil, nil, nil), 'sqlite3_create_function_v2 static_blob', DB);
    NameUtf8 := UTF8String('static_blob64');
    CheckSqliteOk(sqlite3_create_function_v2(DB, MarshaledAString(PAnsiChar(NameUtf8)), 0, SQLITE_UTF8, nil, StaticBlob64Function, nil, nil, nil), 'sqlite3_create_function_v2 static_blob64', DB);
    NameUtf8 := UTF8String('static_zeroblob');
    CheckSqliteOk(sqlite3_create_function_v2(DB, MarshaledAString(PAnsiChar(NameUtf8)), 0, SQLITE_UTF8, nil, StaticZeroBlobFunction, nil, nil, nil), 'sqlite3_create_function_v2 static_zeroblob', DB);
    NameUtf8 := UTF8String('static_null');
    CheckSqliteOk(sqlite3_create_function_v2(DB, MarshaledAString(PAnsiChar(NameUtf8)), 0, SQLITE_UTF8, nil, StaticNullFunction, nil, nil, nil), 'sqlite3_create_function_v2 static_null', DB);
    NameUtf8 := UTF8String('static_double');
    CheckSqliteOk(sqlite3_create_function_v2(DB, MarshaledAString(PAnsiChar(NameUtf8)), 0, SQLITE_UTF8, nil, StaticDoubleFunction, nil, nil, nil), 'sqlite3_create_function_v2 static_double', DB);
    NameUtf8 := UTF8String('echo_value');
    CheckSqliteOk(sqlite3_create_function_v2(DB, MarshaledAString(PAnsiChar(NameUtf8)), 1, SQLITE_UTF8, nil, EchoValueFunction, nil, nil, nil), 'sqlite3_create_function_v2 echo_value', DB);

    CheckEquals(42, QueryScalarInt(DB, 'select twice(21);'), 'twice literal result mismatch');

    Statement := Prepare(DB, 'select twice(?1), ptr_is_set(?2);');
    try
      PointerValue := 1234;
      CheckSqliteOk(sqlite3_bind_int(Statement, 1, 21), 'sqlite3_bind_int UDF', DB);
      CheckSqliteOk(sqlite3_bind_pointer(Statement, 2, PointerValue, MarshaledAString(PAnsiChar(DUNIT_POINTER_TYPE)), nil), 'sqlite3_bind_pointer', DB);
      CheckEquals(SQLITE_ROW, sqlite3_step(Statement), 'sqlite3_step UDF');
      CheckEquals(42, sqlite3_column_int(Statement, 0), 'twice result mismatch');
      CheckEquals(1, sqlite3_column_int(Statement, 1), 'ptr_is_set result mismatch');
    finally
      FinalizeStatement(Statement, DB);
    end;

    CheckTrue(FunctionState.CallCount > 0, 'scalar function was not called');
    CheckTrue(FunctionState.FromBindCount > 0, 'sqlite3_value_frombind was not observed');
    CheckEquals(SQLITE_INTEGER, FunctionState.LastType, 'sqlite3_value_type in scalar function mismatch');
    CheckTrue(FunctionState.ContextDb = DB, 'sqlite3_context_db_handle mismatch');
    CheckTrue(FunctionState.PointerSeen > 0, 'sqlite3_value_pointer did not recover the bound pointer');
    CheckTrue(FunctionState.AuxDestroyCount > 0, 'sqlite3_set_auxdata destructor was not called');

    ExecSql(DB, 'with nums(x) as (values(1),(2),(3)) select dunit_sum(x) from nums;');
    CheckEquals(Int64(6), QueryScalarInt64(DB, 'with nums(x) as (values(1),(2),(3)) select dunit_sum(x) from nums;'), 'aggregate function result mismatch');
    CheckEquals(3, QueryScalarInt(DB, 'select length(static_blob());'), 'sqlite3_result_blob result mismatch');
    CheckEquals(4, QueryScalarInt(DB, 'select length(static_blob64());'), 'sqlite3_result_blob64 result mismatch');
    CheckEquals(5, QueryScalarInt(DB, 'select length(static_zeroblob());'), 'sqlite3_result_zeroblob64 result mismatch');
    CheckEquals(1, QueryScalarInt(DB, 'select typeof(static_null()) = ''null'';'), 'sqlite3_result_null result mismatch');
    CheckEquals(12, QueryScalarInt(DB, 'select cast(static_double() as integer);'), 'sqlite3_result_double result mismatch');
    CheckEquals('echoed', QueryScalarText(DB, 'select echo_value(''echoed'');'), 'sqlite3_result_value result mismatch');

    ExecSql(DB, 'create table words(word text);');
    ExecSql(DB, 'insert into words(word) values(''bbbb''),(''a''),(''cc'');');
    NameUtf8 := UTF8String('DUNIT_LEN');
    CheckSqliteOk(sqlite3_create_collation_v2(DB, MarshaledAString(PAnsiChar(NameUtf8)), SQLITE_UTF8, @CollationState, LengthCompare, CollationDestroy), 'sqlite3_create_collation_v2', DB);
    CheckEquals('a,cc,bbbb', QueryScalarText(DB, 'select group_concat(word, '','') from (select word from words order by word collate DUNIT_LEN);'), 'custom collation order mismatch');
    CheckTrue(CollationState.CompareCount > 0, 'custom collation was not called');
  finally
    CloseDatabase(DB);
  end;
  CheckEquals(1, FunctionState.DestroyCount, 'function destructor was not called on close');
  CheckEquals(1, CollationState.DestroyCount, 'collation destructor was not called on close');
end;

procedure TSqlite3StaticApiTests.CollationNeededCallbacks;
var
  DB: Pointer;
  State: TCollationState;
begin
  FillChar(State, SizeOf(State), 0);
  DB := OpenDatabase(':memory:');
  try
    CheckSqliteOk(sqlite3_collation_needed(DB, @State, CollationNeededCallback), 'sqlite3_collation_needed', DB);
    ExecSql(DB, 'create table lazy_words(word text);');
    ExecSql(DB, 'insert into lazy_words(word) values(''bbbb''),(''a''),(''cc'');');
    CheckEquals('a,cc,bbbb', QueryScalarText(DB, 'select group_concat(word, '','') from (select word from lazy_words order by word collate DUNIT_LAZY);'), 'lazy UTF-8 collation order mismatch');
    CheckTrue(State.NeededCalls > 0, 'sqlite3_collation_needed callback was not called');
    CheckTrue(State.CompareCount > 0, 'lazy UTF-8 collation compare was not called');
    CheckSqliteOk(sqlite3_collation_needed(DB, nil, nil), 'sqlite3_collation_needed clear', DB);
  finally
    CloseDatabase(DB);
  end;

  FillChar(State, SizeOf(State), 0);
  DB := OpenDatabase(':memory:');
  try
    CheckSqliteOk(sqlite3_collation_needed16(DB, @State, CollationNeeded16Callback), 'sqlite3_collation_needed16', DB);
    ExecSql(DB, 'create table lazy_words16(word text);');
    ExecSql(DB, 'insert into lazy_words16(word) values(''bbbb''),(''a''),(''cc'');');
    CheckEquals('a,cc,bbbb', QueryScalarText(DB, 'select group_concat(word, '','') from (select word from lazy_words16 order by word collate DUNIT_LAZY16);'), 'lazy UTF-16 collation order mismatch');
    CheckTrue(State.Needed16Calls > 0, 'sqlite3_collation_needed16 callback was not called');
    CheckTrue(State.CompareCount > 0, 'lazy UTF-16 collation compare was not called');
    CheckSqliteOk(sqlite3_collation_needed16(DB, nil, nil), 'sqlite3_collation_needed16 clear', DB);
  finally
    CloseDatabase(DB);
  end;
end;

procedure TSqlite3StaticApiTests.HooksProgressAuthorizerAndTrace;
var
  DB: Pointer;
  State: THookState;
  BusyState: TBusyState;
begin
  FillChar(State, SizeOf(State), 0);
  FillChar(BusyState, SizeOf(BusyState), 0);
  DB := OpenDatabase(':memory:');
  try
    CheckSqliteOk(sqlite3_set_authorizer(DB, AuthorizerCallback, @State), 'sqlite3_set_authorizer', DB);
    CheckSqliteOk(sqlite3_trace_v2(DB, SQLITE_TRACE_STMT, TraceCallback, @State), 'sqlite3_trace_v2', DB);
    sqlite3_progress_handler(DB, 1, ProgressCallback, @State);
    sqlite3_commit_hook(DB, CommitCallback, @State);
    sqlite3_rollback_hook(DB, RollbackCallback, @State);
    sqlite3_update_hook(DB, UpdateCallback, @State);
    sqlite3_wal_hook(DB, WalCallback, @State);
    CheckSqliteOk(sqlite3_busy_handler(DB, BusyCallback, @BusyState), 'sqlite3_busy_handler', DB);
    CheckSqliteOk(sqlite3_autovacuum_pages(DB, AutoVacuumCallback, @State, nil), 'sqlite3_autovacuum_pages', DB);

    ExecSql(DB, 'create table hook_items(id integer primary key, name text);');
    ExecSql(DB, 'insert into hook_items(name) values(''alpha''),(''beta'');');
    ExecSql(DB, 'update hook_items set name = name || ''-updated'' where id = 1;');
    CheckEquals(2, QueryScalarInt(DB, 'select count(*) from hook_items where name like ''%updated'';') + 1, 'query result mismatch');

    CheckEquals(1, sqlite3_get_autocommit(DB), 'sqlite3_get_autocommit initial mismatch');
    ExecSql(DB, 'begin;');
    CheckEquals(0, sqlite3_get_autocommit(DB), 'sqlite3_get_autocommit inside transaction mismatch');
    ExecSql(DB, 'insert into hook_items(name) values(''rolled-back'');');
    ExecSql(DB, 'rollback;');
    CheckEquals(1, sqlite3_get_autocommit(DB), 'sqlite3_get_autocommit final mismatch');

    CheckTrue(State.AuthorizerCalls > 0, 'authorizer callback was not called');
    CheckTrue(State.TraceCalls > 0, 'trace callback was not called');
    CheckTrue(State.ProgressCalls > 0, 'progress callback was not called');
    CheckTrue(State.CommitCalls > 0, 'commit hook was not called');
    CheckTrue(State.RollbackCalls > 0, 'rollback hook was not called');
    CheckTrue(State.UpdateCalls >= 3, 'update hook call count mismatch');

    CheckSqliteOk(sqlite3_set_authorizer(DB, nil, nil), 'sqlite3_set_authorizer clear', DB);
    CheckSqliteOk(sqlite3_trace_v2(DB, 0, nil, nil), 'sqlite3_trace_v2 clear', DB);
    sqlite3_progress_handler(DB, 0, nil, nil);
    sqlite3_commit_hook(DB, nil, nil);
    sqlite3_rollback_hook(DB, nil, nil);
    sqlite3_update_hook(DB, nil, nil);
    sqlite3_wal_hook(DB, nil, nil);
    CheckSqliteOk(sqlite3_busy_handler(DB, nil, nil), 'sqlite3_busy_handler clear', DB);
  finally
    CloseDatabase(DB);
  end;
end;

procedure TSqlite3StaticApiTests.BlobBackupSerializeAndStatus;
var
  DB: Pointer;
  DestDB: Pointer;
  CopyDB: Pointer;
  Blob: Pointer;
  Backup: PSQLite3Backup;
  Buffer: array[0..4] of AnsiChar;
  WriteValue: AnsiString;
  Serialized: Pointer;
  SerializedCopy: Pointer;
  SerializedSize: Int64;
  Current: Integer;
  Highwater: Integer;
  Current64: Int64;
  Highwater64: Int64;
  BackupStepCode: Integer;
begin
  DB := OpenDatabase(':memory:');
  DestDB := nil;
  CopyDB := nil;
  Blob := nil;
  Serialized := nil;
  SerializedCopy := nil;
  try
    ExecSql(DB, 'create table files(id integer primary key, data blob);');
    ExecSql(DB, 'insert into files(data) values(zeroblob(5));');

    CheckSqliteOk(sqlite3_blob_open(DB, MarshaledAString(PAnsiChar(MAIN_SCHEMA)), MarshaledAString(PAnsiChar(UTF8String('files'))), MarshaledAString(PAnsiChar(UTF8String('data'))), 1, 1, @Blob), 'sqlite3_blob_open write', DB);
    try
      CheckEquals(5, sqlite3_blob_bytes(Blob), 'sqlite3_blob_bytes mismatch');
      WriteValue := AnsiString('abcde');
      CheckSqliteOk(sqlite3_blob_write(Blob, PAnsiChar(WriteValue), Length(WriteValue), 0), 'sqlite3_blob_write', DB);
    finally
      CheckSqliteOk(sqlite3_blob_close(Blob), 'sqlite3_blob_close write', DB);
      Blob := nil;
    end;

    CheckSqliteOk(sqlite3_blob_open(DB, MarshaledAString(PAnsiChar(MAIN_SCHEMA)), MarshaledAString(PAnsiChar(UTF8String('files'))), MarshaledAString(PAnsiChar(UTF8String('data'))), 1, 0, @Blob), 'sqlite3_blob_open read', DB);
    try
      CheckSqliteOk(sqlite3_blob_reopen(Blob, 1), 'sqlite3_blob_reopen', DB);
      FillChar(Buffer, SizeOf(Buffer), 0);
      CheckSqliteOk(sqlite3_blob_read(Blob, @Buffer[0], SizeOf(Buffer), 0), 'sqlite3_blob_read', DB);
      CheckEquals(WriteValue, BlobToAnsiString(@Buffer[0], SizeOf(Buffer)), 'blob round-trip mismatch');
    finally
      CheckSqliteOk(sqlite3_blob_close(Blob), 'sqlite3_blob_close read', DB);
      Blob := nil;
    end;

    DestDB := OpenDatabase(':memory:');
    Backup := sqlite3_backup_init(DestDB, MarshaledAString(PAnsiChar(MAIN_SCHEMA)), DB, MarshaledAString(PAnsiChar(MAIN_SCHEMA)));
    CheckTrue(Backup <> nil, 'sqlite3_backup_init returned nil');
    BackupStepCode := sqlite3_backup_step(Backup, -1);
    CheckTrue((BackupStepCode = SQLITE_DONE) or (BackupStepCode = SQLITE_OK), 'sqlite3_backup_step returned an unexpected code');
    CheckTrue(sqlite3_backup_pagecount(Backup) >= 0, 'sqlite3_backup_pagecount returned an invalid value');
    CheckTrue(sqlite3_backup_remaining(Backup) >= 0, 'sqlite3_backup_remaining returned an invalid value');
    CheckSqliteOk(sqlite3_backup_finish(Backup), 'sqlite3_backup_finish', DestDB);
    CheckEquals('abcde', QueryScalarText(DestDB, 'select cast(data as text) from files where id = 1;'), 'backup result mismatch');

    SerializedSize := 0;
    Serialized := sqlite3_serialize(DB, MarshaledAString(PAnsiChar(MAIN_SCHEMA)), @SerializedSize, 0);
    CheckTrue(Serialized <> nil, 'sqlite3_serialize returned nil');
    CheckTrue(SerializedSize > 0, 'sqlite3_serialize returned an empty buffer');

    SerializedCopy := sqlite3_malloc64(SerializedSize);
    CheckTrue(SerializedCopy <> nil, 'sqlite3_malloc64 failed for deserialize buffer');
    Move(Serialized^, SerializedCopy^, SerializedSize);
    CopyDB := OpenDatabase(':memory:');
    CheckSqliteOk(sqlite3_deserialize(CopyDB, MarshaledAString(PAnsiChar(MAIN_SCHEMA)), SerializedCopy, SerializedSize, SerializedSize, SQLITE_DESERIALIZE_FREEONCLOSE), 'sqlite3_deserialize', CopyDB);
    SerializedCopy := nil;
    CheckEquals('abcde', QueryScalarText(CopyDB, 'select cast(data as text) from files where id = 1;'), 'deserialize result mismatch');

    CheckSqliteOk(sqlite3_status(SQLITE_STATUS_MEMORY_USED, Current, Highwater, 0), 'sqlite3_status memory used');
    CheckTrue(Current >= 0, 'sqlite3_status current memory is invalid');
    CheckSqliteOk(sqlite3_status64(SQLITE_STATUS_MEMORY_USED, Current64, Highwater64, 0), 'sqlite3_status64 memory used');
    CheckTrue(Current64 >= 0, 'sqlite3_status64 current memory is invalid');
    CheckSqliteOk(sqlite3_db_status(DB, SQLITE_DBSTATUS_CACHE_USED, Current, Highwater, 0), 'sqlite3_db_status cache used', DB);
    CheckTrue(Current >= 0, 'sqlite3_db_status current cache is invalid');
    CheckSqliteOk(sqlite3_db_status64(DB, SQLITE_DBSTATUS_CACHE_USED, Current64, Highwater64, 0), 'sqlite3_db_status64 cache used', DB);
    CheckTrue(Current64 >= 0, 'sqlite3_db_status64 current cache is invalid');
    CheckTrue(sqlite3_db_release_memory(DB) >= 0, 'sqlite3_db_release_memory returned an invalid value');
    CheckSqliteOk(sqlite3_db_cacheflush(DB), 'sqlite3_db_cacheflush', DB);
  finally
    if Blob <> nil then
      sqlite3_blob_close(Blob);
    if Serialized <> nil then
      sqlite3_free(Serialized);
    if SerializedCopy <> nil then
      sqlite3_free(SerializedCopy);
    CloseDatabase(CopyDB);
    CloseDatabase(DestDB);
    CloseDatabase(DB);
  end;
end;

procedure TSqlite3StaticApiTests.WalCheckpointAndFilenameApis;
var
  DB: Pointer;
  FileName: string;
  MainUtf8: UTF8String;
  JournalMode: string;
  CreatedFileName: MarshaledAString;
  CreatedDbUtf8: UTF8String;
  CreatedJournalUtf8: UTF8String;
  CreatedWalUtf8: UTF8String;
  LogFrames: Integer;
  CheckpointedFrames: Integer;
  State: THookState;
begin
  CreatedDbUtf8 := UTF8String('DelphiLibSQLiteFilename.db');
  CreatedJournalUtf8 := UTF8String('DelphiLibSQLiteFilename.db-journal');
  CreatedWalUtf8 := UTF8String('DelphiLibSQLiteFilename.db-wal');
  CreatedFileName := sqlite3_create_filename(
    MarshaledAString(PAnsiChar(CreatedDbUtf8)),
    MarshaledAString(PAnsiChar(CreatedJournalUtf8)),
    MarshaledAString(PAnsiChar(CreatedWalUtf8)),
    0,
    nil);
  CheckTrue(CreatedFileName <> nil, 'sqlite3_create_filename returned nil for filename helpers');
  try
    CheckEquals('DelphiLibSQLiteFilename.db', Utf8PtrToString(sqlite3_filename_database(CreatedFileName)), 'sqlite3_filename_database mismatch');
    CheckEquals('DelphiLibSQLiteFilename.db-journal', Utf8PtrToString(sqlite3_filename_journal(CreatedFileName)), 'sqlite3_filename_journal mismatch');
    CheckEquals('DelphiLibSQLiteFilename.db-wal', Utf8PtrToString(sqlite3_filename_wal(CreatedFileName)), 'sqlite3_filename_wal mismatch');
  finally
    sqlite3_free_filename(CreatedFileName);
  end;

  FillChar(State, SizeOf(State), 0);
  FileName := TempDatabaseFileName;
  DB := OpenDatabase(FileName);
  try
    MainUtf8 := UTF8String('main');
    JournalMode := LowerCase(QueryScalarText(DB, 'pragma journal_mode=wal;'));
    CheckTrue(JournalMode <> '', 'pragma journal_mode returned an empty value');
    CheckSqliteOk(sqlite3_wal_autocheckpoint(DB, 1), 'sqlite3_wal_autocheckpoint', DB);
    sqlite3_wal_hook(DB, WalCallback, @State);
    ExecSql(DB, 'create table wal_items(id integer primary key, name text);');
    ExecSql(DB, 'insert into wal_items(name) values(''alpha''),(''beta'');');
    if JournalMode = 'wal' then
      CheckTrue(State.WalCalls > 0, 'sqlite3_wal_hook was not called in WAL mode');

    CheckSqliteOk(sqlite3_wal_checkpoint(DB, MarshaledAString(PAnsiChar(MainUtf8))), 'sqlite3_wal_checkpoint', DB);
    LogFrames := 0;
    CheckpointedFrames := 0;
    CheckSqliteOk(sqlite3_wal_checkpoint_v2(DB, MarshaledAString(PAnsiChar(MainUtf8)), SQLITE_CHECKPOINT_PASSIVE, @LogFrames, @CheckpointedFrames), 'sqlite3_wal_checkpoint_v2', DB);
    CheckTrue(LogFrames >= -1, 'sqlite3_wal_checkpoint_v2 log frame count is invalid');
    CheckTrue(CheckpointedFrames >= -1, 'sqlite3_wal_checkpoint_v2 checkpointed frame count is invalid');
    sqlite3_wal_hook(DB, nil, nil);
  finally
    CloseDatabase(DB);
    DeleteDatabaseFiles(FileName);
  end;
end;

procedure TSqlite3StaticApiTests.StringMemoryUriVfsAndMutexApis;
var
  FileDB: Pointer;
  FileName: string;
  MainUtf8: UTF8String;
  ParamUtf8: UTF8String;
  FileNamePtr: MarshaledAString;
  CreatedFileName: MarshaledAString;
  CreatedNameUtf8: UTF8String;
  CreatedJournalUtf8: UTF8String;
  CreatedWalUtf8: UTF8String;
  ParamName0: UTF8String;
  ParamValue0: UTF8String;
  ParamName1: UTF8String;
  ParamValue1: UTF8String;
  FileNameParams: array[0..3] of MarshaledAString;
  Memory: Pointer;
  Builder: PSQLite3Str;
  Finished: MarshaledAString;
  CurrentBytes: Int64;
  PreviousSoftLimit: Int64;
  PreviousHardLimit: Int64;
  RandomBytes: array[0..7] of Byte;
  Mutex: Pointer;
  DataVersion: Integer;
  Utf8Text: MarshaledAString;
  Utf8Source: UTF8String;
  WideText: MarshaledString;
  WideSource: string;
begin
  Memory := sqlite3_malloc(16);
  CheckTrue(Memory <> nil, 'sqlite3_malloc returned nil');
  Memory := sqlite3_realloc(Memory, 32);
  CheckTrue(Memory <> nil, 'sqlite3_realloc returned nil');
  CheckTrue(sqlite3_msize(Memory) >= 32, 'sqlite3_msize returned a smaller value than requested');
  sqlite3_free(Memory);

  Memory := sqlite3_malloc64(16);
  CheckTrue(Memory <> nil, 'sqlite3_malloc64 returned nil');
  Memory := sqlite3_realloc64(Memory, 24);
  CheckTrue(Memory <> nil, 'sqlite3_realloc64 returned nil');
  sqlite3_free(Memory);

  CurrentBytes := sqlite3_memory_used;
  CheckTrue(CurrentBytes >= 0, 'sqlite3_memory_used returned an invalid value');
  CheckTrue(sqlite3_memory_highwater(0) >= CurrentBytes, 'sqlite3_memory_highwater returned an invalid value');
  CheckTrue(sqlite3_release_memory(0) >= 0, 'sqlite3_release_memory returned an invalid value');
  PreviousSoftLimit := sqlite3_soft_heap_limit64(-1);
  CheckTrue(PreviousSoftLimit >= 0, 'sqlite3_soft_heap_limit64 query returned an invalid value');
  CheckTrue(sqlite3_soft_heap_limit64(PreviousSoftLimit) >= 0, 'sqlite3_soft_heap_limit64 restore returned an invalid value');
  sqlite3_soft_heap_limit(-1);
  PreviousHardLimit := sqlite3_hard_heap_limit64(-1);
  CheckTrue(PreviousHardLimit >= 0, 'sqlite3_hard_heap_limit64 query returned an invalid value');
  sqlite3_randomness(SizeOf(RandomBytes), @RandomBytes[0]);

  Builder := sqlite3_str_new(nil);
  CheckTrue(Builder <> nil, 'sqlite3_str_new returned nil');
  sqlite3_str_appendall(Builder, MarshaledAString(PAnsiChar(UTF8String('abc'))));
  sqlite3_str_appendchar(Builder, 2, AnsiChar('x'));
  CheckEquals(5, sqlite3_str_length(Builder), 'sqlite3_str_length mismatch');
  sqlite3_str_truncate(Builder, 4);
  CheckEquals('abcx', Utf8PtrToString(sqlite3_str_value(Builder)), 'sqlite3_str_value mismatch');
  CheckSqliteOk(sqlite3_str_errcode(Builder), 'sqlite3_str_errcode');
  Finished := sqlite3_str_finish(Builder);
  CheckTrue(Finished <> nil, 'sqlite3_str_finish returned nil');
  try
    CheckEquals('abcx', Utf8PtrToString(Finished), 'sqlite3_str_finish value mismatch');
  finally
    sqlite3_free(Finished);
  end;

  Builder := sqlite3_str_new(nil);
  CheckTrue(Builder <> nil, 'sqlite3_str_new reset/free returned nil');
  sqlite3_str_append(Builder, MarshaledAString(PAnsiChar(UTF8String('abcdef'))), 6);
  sqlite3_str_reset(Builder);
  CheckEquals(0, sqlite3_str_length(Builder), 'sqlite3_str_reset did not clear the builder');
  sqlite3_str_free(Builder);

  CheckEquals(0, sqlite3_strglob(MarshaledAString(PAnsiChar(UTF8String('a*'))), MarshaledAString(PAnsiChar(UTF8String('abc')))), 'sqlite3_strglob mismatch');
  CheckEquals(0, sqlite3_strlike(MarshaledAString(PAnsiChar(UTF8String('a%'))), MarshaledAString(PAnsiChar(UTF8String('abc'))), 0), 'sqlite3_strlike mismatch');
  CheckEquals(0, sqlite3_stricmp(MarshaledAString(PAnsiChar(UTF8String('abc'))), MarshaledAString(PAnsiChar(UTF8String('ABC')))), 'sqlite3_stricmp mismatch');
  CheckEquals(0, sqlite3_strnicmp(MarshaledAString(PAnsiChar(UTF8String('abcdef'))), MarshaledAString(PAnsiChar(UTF8String('ABCxyz'))), 3), 'sqlite3_strnicmp mismatch');
  CheckTrue(sqlite3_sleep(0) >= 0, 'sqlite3_sleep returned an invalid value');

  CreatedNameUtf8 := UTF8String('DelphiLibSQLiteDUnitUri');
  CreatedJournalUtf8 := UTF8String('DelphiLibSQLiteDUnitUri-journal');
  CreatedWalUtf8 := UTF8String('DelphiLibSQLiteDUnitUri-wal');
  ParamName0 := UTF8String('answer');
  ParamValue0 := UTF8String('42');
  ParamName1 := UTF8String('enabled');
  ParamValue1 := UTF8String('1');
  FileNameParams[0] := MarshaledAString(PAnsiChar(ParamName0));
  FileNameParams[1] := MarshaledAString(PAnsiChar(ParamValue0));
  FileNameParams[2] := MarshaledAString(PAnsiChar(ParamName1));
  FileNameParams[3] := MarshaledAString(PAnsiChar(ParamValue1));
  CreatedFileName := sqlite3_create_filename(MarshaledAString(PAnsiChar(CreatedNameUtf8)), MarshaledAString(PAnsiChar(CreatedJournalUtf8)), MarshaledAString(PAnsiChar(CreatedWalUtf8)), 2, @FileNameParams[0]);
  CheckTrue(CreatedFileName <> nil, 'sqlite3_create_filename returned nil');
  try
    ParamUtf8 := UTF8String('answer');
    CheckEquals('42', Utf8PtrToString(sqlite3_uri_parameter(CreatedFileName, MarshaledAString(PAnsiChar(ParamUtf8)))), 'sqlite3_uri_parameter mismatch');
    CheckEquals(Int64(42), sqlite3_uri_int64(CreatedFileName, MarshaledAString(PAnsiChar(ParamUtf8)), 0), 'sqlite3_uri_int64 mismatch');
    ParamUtf8 := UTF8String('enabled');
    CheckEquals(1, sqlite3_uri_boolean(CreatedFileName, MarshaledAString(PAnsiChar(ParamUtf8)), 0), 'sqlite3_uri_boolean mismatch');
    CheckTrue(sqlite3_uri_key(CreatedFileName, 0) <> nil, 'sqlite3_uri_key returned nil');
  finally
    sqlite3_free_filename(CreatedFileName);
  end;

  FileName := TempDatabaseFileName;
  FileDB := OpenDatabase(FileName);
  try
    ExecSql(FileDB, 'create table file_control_items(id integer);');
    MainUtf8 := UTF8String('main');
    DataVersion := 0;
    CheckSqliteOk(sqlite3_file_control(FileDB, MarshaledAString(PAnsiChar(MainUtf8)), SQLITE_FCNTL_DATA_VERSION, @DataVersion), 'sqlite3_file_control DATA_VERSION', FileDB);
    CheckTrue(sqlite3_vfs_find(nil) <> nil, 'sqlite3_vfs_find returned nil');
    CheckTrue(sqlite3_db_mutex(FileDB) <> nil, 'sqlite3_db_mutex returned nil');
    FileNamePtr := sqlite3_db_filename(FileDB, PAnsiChar(MainUtf8));
    CheckTrue(sqlite3_database_file_object(FileNamePtr) <> nil, 'sqlite3_database_file_object returned nil');
  finally
    CloseDatabase(FileDB);
    DeleteDatabaseFiles(FileName);
  end;

  if sqlite3_threadsafe <> 0 then
  begin
    Mutex := sqlite3_mutex_alloc(SQLITE_MUTEX_RECURSIVE);
    CheckTrue(Mutex <> nil, 'sqlite3_mutex_alloc returned nil');
    sqlite3_mutex_enter(Mutex);
    CheckEquals(SQLITE_OK, sqlite3_mutex_try(Mutex), 'sqlite3_mutex_try on recursive mutex mismatch');
    sqlite3_mutex_leave(Mutex);
    sqlite3_mutex_leave(Mutex);
    sqlite3_mutex_free(Mutex);
  end;

  CheckTrue(sqlite3_win32_is_nt <> 0, 'sqlite3_win32_is_nt returned false');
  sqlite3_win32_sleep(0);
  WideSource := 'wide';
  Utf8Text := sqlite3_win32_unicode_to_utf8(PWideChar(WideSource));
  CheckTrue(Utf8Text <> nil, 'sqlite3_win32_unicode_to_utf8 returned nil');
  try
    CheckEquals('wide', Utf8PtrToString(Utf8Text), 'sqlite3_win32_unicode_to_utf8 mismatch');
  finally
    sqlite3_free(Utf8Text);
  end;

  Utf8Source := UTF8String('utf8');
  Utf8Text := MarshaledAString(PAnsiChar(Utf8Source));
  WideText := sqlite3_win32_utf8_to_unicode(PUtf8Char(Utf8Text));
  CheckTrue(WideText <> nil, 'sqlite3_win32_utf8_to_unicode returned nil');
  try
    CheckEquals('utf8', Utf16PtrToString(WideText), 'sqlite3_win32_utf8_to_unicode mismatch');
  finally
    sqlite3_free(WideText);
  end;
end;

procedure TSqlite3StaticApiTests.ExtensionRegistrationAndCArray;
var
  DB: Pointer;
  Statement: Pointer;
  Values: array[0..2] of Integer;
  DumpState: TDumpState;
begin
  FillChar(DumpState, SizeOf(DumpState), 0);
  DB := OpenDatabase(':memory:');
  try
    CheckSqliteOk(sqlite3_carray_register(DB), 'sqlite3_carray_register', DB);
    CheckSqliteOk(sqlite3_unicode_register(DB), 'sqlite3_unicode_register', DB);
    CheckSqliteOk(sqlite3_eval_register(DB), 'sqlite3_eval_register', DB);
    CheckSqliteOk(sqlite3_base64_register(DB), 'sqlite3_base64_register', DB);
    CheckSqliteOk(sqlite3_base85_register(DB), 'sqlite3_base85_register', DB);

    Values[0] := 3;
    Values[1] := 1;
    Values[2] := 2;
    Statement := Prepare(DB, 'select sum(value) from carray(?1);');
    try
      CheckSqliteOk(sqlite3_carray_bind(Statement, 1, @Values[0], Length(Values), SQLITE_CARRAY_INT32, nil), 'sqlite3_carray_bind', DB);
      CheckEquals(SQLITE_ROW, sqlite3_step(Statement), 'sqlite3_step carray');
      CheckEquals(6, sqlite3_column_int(Statement, 0), 'carray sum mismatch');
    finally
      FinalizeStatement(Statement, DB);
    end;

    Values[0] := 10;
    Values[1] := 20;
    Values[2] := 30;
    Statement := Prepare(DB, 'select count(*) from carray(?1) where value >= 20;');
    try
      CheckSqliteOk(sqlite3_carray_bind_v2(Statement, 1, @Values[0], Length(Values), SQLITE_CARRAY_INT32, nil, nil), 'sqlite3_carray_bind_v2', DB);
      CheckEquals(SQLITE_ROW, sqlite3_step(Statement), 'sqlite3_step carray_v2');
      CheckEquals(2, sqlite3_column_int(Statement, 0), 'carray_v2 count mismatch');
    finally
      FinalizeStatement(Statement, DB);
    end;

    ExecSql(DB, 'create table dump_items(id integer primary key, name text);');
    ExecSql(DB, 'insert into dump_items(name) values(''dumped'');');
    CheckSqliteOk(sqlite3_db_dump(DB, MarshaledAString(PAnsiChar(MAIN_SCHEMA)), MarshaledAString(PAnsiChar(UTF8String('dump_items'))), DumpCallback, @DumpState), 'sqlite3_db_dump', DB);
    CheckTrue(DumpState.Lines > 0, 'sqlite3_db_dump callback was not called');
  finally
    CloseDatabase(DB);
  end;
end;

procedure TSqlite3StaticApiTests.CipherPragmasAndEncryptedRoundTrip;
var
  DB: Pointer;
  FileName: string;
  OldKey: UTF8String;
  NewKey: UTF8String;
  Statement: Pointer;
  SQLUtf8: UTF8String;
  Code: Integer;
begin
  OldKey := UTF8String('correct horse battery staple');
  NewKey := UTF8String('changed horse battery staple');

  DB := OpenDatabase(':memory:');
  try
    ApplyKey(DB, UTF8String('pragma-provider-check'));
    CheckTrue(QueryScalarText(DB, 'pragma cipher_version;') <> '', 'pragma cipher_version returned an empty value');
    CheckTrue(QueryScalarText(DB, 'pragma cipher_provider;') <> '', 'pragma cipher_provider returned an empty value');
  finally
    CloseDatabase(DB);
  end;

  FileName := TempDatabaseFileName;
  DB := OpenDatabase(FileName);
  try
    ApplyKeyV2(DB, OldKey);
    ExecSql(DB, 'create table secret_items(id integer primary key, value text not null);');
    ExecSql(DB, 'insert into secret_items(value) values(''encrypted-value'');');
    CheckEquals('encrypted-value', QueryScalarText(DB, 'select value from secret_items where id = 1;'), 'encrypted write/read failed before close');
    CheckSqliteOk(sqlite3_rekey(DB, MarshaledAString(PAnsiChar(NewKey)), Length(NewKey)), 'sqlite3_rekey', DB);
  finally
    CloseDatabase(DB);
  end;

  DB := OpenDatabase(FileName);
  try
    ApplyKeyV2(DB, OldKey);
    Statement := nil;
    SQLUtf8 := UTF8String('select value from secret_items where id = 1;');
    Code := sqlite3_prepare_v2(DB, MarshaledAString(PAnsiChar(SQLUtf8)), -1, Statement, nil);
    if Code = SQLITE_OK then
    begin
      try
        Code := sqlite3_step(Statement);
        CheckTrue(Code <> SQLITE_ROW, 'encrypted database was readable with the old key after rekey');
      finally
        sqlite3_finalize(Statement);
        Statement := nil;
      end;
    end;
  finally
    CloseDatabase(DB);
  end;

  DB := OpenDatabase(FileName);
  try
    ApplyKeyV2(DB, NewKey);
    CheckEquals('encrypted-value', QueryScalarText(DB, 'select value from secret_items where id = 1;'), 'encrypted write/read failed after rekey');
    CheckSqliteOk(sqlite3_rekey_v2(DB, MarshaledAString(PAnsiChar(MAIN_SCHEMA)), MarshaledAString(PAnsiChar(OldKey)), Length(OldKey)), 'sqlite3_rekey_v2', DB);
  finally
    CloseDatabase(DB);
  end;

  DB := OpenDatabase(FileName);
  try
    ApplyKey(DB, OldKey);
    CheckEquals('encrypted-value', QueryScalarText(DB, 'select value from secret_items where id = 1;'), 'encrypted write/read failed after sqlite3_rekey_v2');
  finally
    CloseDatabase(DB);
    DeleteDatabaseFiles(FileName);
  end;
end;

initialization
  RegisterTest(TSqlite3StaticApiTests.Suite);

end.
