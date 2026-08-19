unit Sqlite3ExtendedApiTestCase;

interface

uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  System.IOUtils,
  System.Math,
  System.Types,
  TestFramework,
  sqlite3.common,
  sqlite3.static,
  sqlite3ext;

type
  TSqlite3ExtendedApiTests = class(TTestCase)
  private
    function ExecuteScalarStepCode(const DB: Pointer; const SQL: string; out ErrorText: string): Integer;
    function ExecCode(const DB: Pointer; const SQL: string): Integer;
    function ExtensionFileName: string;
    function LastError(const DB: Pointer): string;
    function OpenDatabase(const FileName: string; const Flags: Integer): Pointer;
    function Prepare(const DB: Pointer; const SQL: string): Pointer;
    function QueryScalarInt(const DB: Pointer; const SQL: string): Integer;
    function QueryScalarText(const DB: Pointer; const SQL: string): string;
    function TestDataFileName: string;
    procedure CheckSqliteOk(const Code: Integer; const Context: string; const DB: Pointer = nil);
    procedure CloseDatabase(var DB: Pointer);
    procedure ExecSql(const DB: Pointer; const SQL: string);
    procedure FinalizeStatement(var Statement: Pointer; const DB: Pointer);
    procedure LoadSpatialite(const DB: Pointer);
    procedure RegisterScalar(const DB: Pointer; const Name: UTF8String; const ArgumentCount: Integer;
      const Flags: Integer; const Callback: TxSFunc);
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure LifecycleFormattingVfsAndWin32Apis;
    procedure Utf16MetadataAndCommonHelpers;
    procedure ResultAndValueApis;
    procedure VirtualTableApis;
    procedure ExtensionApiLayoutAndSpatialite;
    procedure SpatialiteTestDataReadOnly;
    {$IFDEF link_deprecated_api}
    procedure DeprecatedTraceProfileApis;
    {$ENDIF}
  end;

implementation

type
  PLogState = ^TLogState;
  TLogState = record
    Calls: Integer;
    LastCode: Integer;
  end;

  PVTabState = ^TVTabState;
  TVTabState = record
    DB: Pointer;
    BestIndexCalls: Integer;
    CollationCalls: Integer;
    DistinctCalls: Integer;
    InCalls: Integer;
    InValues: Integer;
    RhsCalls: Integer;
    NoChangeCalls: Integer;
    ConflictMode: Integer;
    CreateCalls: Integer;
    DestroyCalls: Integer;
    ModuleDestroyCalls: Integer;
  end;

  PDUnitVTab = ^TDUnitVTab;
  TDUnitVTab = record
    Base: TSQLiteVtab;
    State: PVTabState;
  end;

  PDUnitVTabCursor = ^TDUnitVTabCursor;
  TDUnitVTabCursor = record
    Base: TSQLiteVtabCursor;
    Row: Integer;
    AllowedMask: Integer;
  end;

  TIndexConstraintArray = array[0..1023] of TSQLiteIndexConstraint;
  PIndexConstraintArray = ^TIndexConstraintArray;
  TIndexConstraintUsageArray = array[0..1023] of TSQLiteIndexConstraintUsage;
  PIndexConstraintUsageArray = ^TIndexConstraintUsageArray;

const
  POINTER_TYPE: UTF8String = 'dunit.extended.pointer';
  TEXT64_VALUE: array[0..6] of AnsiChar = ('t', 'e', 'x', 't', '6', '4', #0);
  TEXT16_BE_VALUE: array[0..4] of Byte = (0, Ord('b'), 0, Ord('e'), 0);

var
  PointerPayload: Integer = 123;

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

procedure SQLiteLogCallback(UserData: Pointer; ErrorCode: Integer; MessageText: MarshaledAString); cdecl;
begin
  if UserData <> nil then
  begin
    Inc(PLogState(UserData)^.Calls);
    PLogState(UserData)^.LastCode := ErrorCode;
  end;
end;

procedure ValueProbeFunction(Context: PSQLite3FuncContext; ArgumentCount: Integer;
  ArgumentValues: PSQLiteValues); cdecl;
var
  TextValue: RawByteString;
  NumberValue: Double;
begin
  if ArgumentCount <> 1 then
  begin
    sqlite3_result_int(Context, 0);
    Exit;
  end;

  TextValue := sqlite3_value_str(ArgumentValues[0]);
  NumberValue := sqlite3_value_double(ArgumentValues[0]);
  sqlite3_result_int(Context, Ord((TextValue = '12.5') and
    (NumberValue > 12.49) and (NumberValue < 12.51)));
end;

procedure PointerProducerFunction(Context: PSQLite3FuncContext; ArgumentCount: Integer;
  ArgumentValues: PSQLiteValues); cdecl;
begin
  sqlite3_result_pointer(Context, @PointerPayload,
    MarshaledAString(PAnsiChar(POINTER_TYPE)), nil);
end;

procedure PointerConsumerFunction(Context: PSQLite3FuncContext; ArgumentCount: Integer;
  ArgumentValues: PSQLiteValues); cdecl;
var
  Value: Pointer;
begin
  Value := nil;
  if ArgumentCount = 1 then
    Value := sqlite3_value_pointer(ArgumentValues[0], MarshaledAString(PAnsiChar(POINTER_TYPE)));
  sqlite3_result_int(Context, Ord(Value = @PointerPayload));
end;

procedure SubtypeProducerFunction(Context: PSQLite3FuncContext; ArgumentCount: Integer;
  ArgumentValues: PSQLiteValues); cdecl;
begin
  sqlite3_result_text(Context, UTF8String('subtyped'));
  sqlite3_result_subtype(Context, 73);
end;

procedure SubtypeConsumerFunction(Context: PSQLite3FuncContext; ArgumentCount: Integer;
  ArgumentValues: PSQLiteValues); cdecl;
begin
  if ArgumentCount = 1 then
    sqlite3_result_int(Context, sqlite3_value_subtype(ArgumentValues[0]))
  else
    sqlite3_result_int(Context, -1);
end;

procedure Text64Function(Context: PSQLite3FuncContext; ArgumentCount: Integer;
  ArgumentValues: PSQLiteValues); cdecl;
begin
  sqlite3_result_text64(Context, MarshaledAString(@TEXT64_VALUE[0]), 6, SQLITE_TRANSIENT, SQLITE_UTF8);
end;

procedure Text16LeFunction(Context: PSQLite3FuncContext; ArgumentCount: Integer;
  ArgumentValues: PSQLiteValues); cdecl;
const
  Value: array[0..2] of WideChar = ('l', 'e', #0);
begin
  sqlite3_result_text16le(Context, PChar(@Value[0]), 4, SQLITE_TRANSIENT);
end;

procedure Text16BeFunction(Context: PSQLite3FuncContext; ArgumentCount: Integer;
  ArgumentValues: PSQLiteValues); cdecl;
begin
  sqlite3_result_text16be(Context, PChar(@TEXT16_BE_VALUE[0]), 4, SQLITE_TRANSIENT);
end;

procedure ZeroBlobFunction(Context: PSQLite3FuncContext; ArgumentCount: Integer;
  ArgumentValues: PSQLiteValues); cdecl;
begin
  sqlite3_result_zeroblob(Context, 7);
end;

procedure ErrorFunction(Context: PSQLite3FuncContext; ArgumentCount: Integer;
  ArgumentValues: PSQLiteValues); cdecl;
var
  MessageText: UTF8String;
begin
  MessageText := UTF8String('dunit result error');
  sqlite3_result_error(Context, MarshaledAString(PAnsiChar(MessageText)), Length(MessageText));
end;

procedure Error16Function(Context: PSQLite3FuncContext; ArgumentCount: Integer;
  ArgumentValues: PSQLiteValues); cdecl;
var
  MessageText: string;
begin
  MessageText := 'dunit wide error';
  sqlite3_result_error16(Context, PChar(MessageText), Length(MessageText) * SizeOf(WideChar));
end;

procedure ErrorTooBigFunction(Context: PSQLite3FuncContext; ArgumentCount: Integer;
  ArgumentValues: PSQLiteValues); cdecl;
begin
  sqlite3_result_error_toobig(Context);
end;

procedure ErrorNoMemoryFunction(Context: PSQLite3FuncContext; ArgumentCount: Integer;
  ArgumentValues: PSQLiteValues); cdecl;
begin
  sqlite3_result_error_nomem(Context);
end;

procedure ErrorStringUtf8Function(Context: PSQLite3FuncContext; ArgumentCount: Integer;
  ArgumentValues: PSQLiteValues); cdecl;
begin
  sqlite3_result_error_str(Context, UTF8String('dunit utf8 helper error'));
end;

procedure ErrorStringWideFunction(Context: PSQLite3FuncContext; ArgumentCount: Integer;
  ArgumentValues: PSQLiteValues); cdecl;
begin
  sqlite3_result_error_str(Context, string('dunit wide helper error'));
end;

function ConnectVTab(DB: Pointer; State: PVTabState; VTab: PPSQLiteVtab): Integer;
var
  Created: PDUnitVTab;
  DeclarationSql: UTF8String;
begin
  DeclarationSql := UTF8String('create table x(value integer, label text)');
  Result := sqlite3_declare_vtab(DB, MarshaledAString(PAnsiChar(DeclarationSql)));
  if Result <> SQLITE_OK then
    Exit;

  Result := sqlite3_vtab_config(DB, SQLITE_VTAB_CONSTRAINT_SUPPORT, 1);
  if Result <> SQLITE_OK then
    Exit;
  Result := sqlite3_vtab_config(DB, SQLITE_VTAB_INNOCUOUS);
  if Result <> SQLITE_OK then
    Exit;

  Created := sqlite3_malloc(SizeOf(TDUnitVTab));
  if Created = nil then
    Exit(SQLITE_NOMEM);
  FillChar(Created^, SizeOf(Created^), 0);
  Created^.State := State;
  State^.DB := DB;
  Inc(State^.CreateCalls);
  VTab^ := @Created^.Base;
  Result := SQLITE_OK;
end;

function DUnitVTabCreate(DB: Pointer; Aux: Pointer; ArgumentCount: Integer;
  Arguments: PMarshaledAStrings; VTab: PPSQLiteVtab; ErrorText: PMarshaledAString): Integer; cdecl;
begin
  Result := ConnectVTab(DB, PVTabState(Aux), VTab);
end;

function DUnitVTabConnect(DB: Pointer; Aux: Pointer; ArgumentCount: Integer;
  Arguments: Pointer; VTab: PPSQLiteVtab; ErrorText: PMarshaledAString): Integer; cdecl;
begin
  Result := ConnectVTab(DB, PVTabState(Aux), VTab);
end;

function DUnitVTabBestIndex(VTab: PSQLiteVtab; IndexInfo: PSQLiteIndexInfo): Integer; cdecl;
var
  Constraint: PSQLiteIndexConstraint;
  I: Integer;
  IsInConstraint: Boolean;
  RightValue: PSQLiteValue;
  State: PVTabState;
  Usage: PSQLiteIndexConstraintUsage;
begin
  State := PDUnitVTab(VTab)^.State;
  Inc(State^.BestIndexCalls);
  if sqlite3_vtab_distinct(IndexInfo) <> 0 then
    Inc(State^.DistinctCalls);

  IndexInfo^.estimatedCost := 3.0;
  IndexInfo^.estimatedRows := 3;
  IndexInfo^.idxFlags := 0;

  for I := 0 to IndexInfo^.nConstraint - 1 do
  begin
    Constraint := @PIndexConstraintArray(IndexInfo^.pConstraint)^[I];
    Usage := @PIndexConstraintUsageArray(IndexInfo^.pConstraintUsage)^[I];
    if sqlite3_vtab_collation(IndexInfo, I) <> nil then
      Inc(State^.CollationCalls);

    RightValue := nil;
    if sqlite3_vtab_rhs_value(IndexInfo, I, RightValue) = SQLITE_OK then
      Inc(State^.RhsCalls);

    if (Constraint^.usable = 0) or (Constraint^.iColumn <> 0) or
       (Constraint^.op <> SQLITE_INDEX_CONSTRAINT_EQ) or (IndexInfo^.idxNum <> 0) then
      Continue;

    IsInConstraint := sqlite3_vtab_in(IndexInfo, I, -1) <> 0;
    Usage^.argvIndex := 1;
    Usage^.omit := 1;
    if IsInConstraint then
    begin
      sqlite3_vtab_in(IndexInfo, I, 1);
      IndexInfo^.idxNum := 2;
      Inc(State^.InCalls);
    end
    else
    begin
      IndexInfo^.idxNum := 1;
      IndexInfo^.idxFlags := SQLITE_INDEX_SCAN_UNIQUE;
      IndexInfo^.estimatedRows := 1;
    end;
  end;
  Result := SQLITE_OK;
end;

function DUnitVTabDisconnect(VTab: PSQLiteVtab): Integer; cdecl;
begin
  if VTab <> nil then
  begin
    Inc(PDUnitVTab(VTab)^.State^.DestroyCalls);
    sqlite3_free(VTab);
  end;
  Result := SQLITE_OK;
end;

function DUnitVTabDestroy(VTab: PSQLiteVtab): Integer; cdecl;
begin
  Result := DUnitVTabDisconnect(VTab);
end;

function DUnitVTabOpen(VTab: PSQLiteVtab; Cursor: PPSQLiteVtabCursor): Integer; cdecl;
var
  Created: PDUnitVTabCursor;
begin
  Created := sqlite3_malloc(SizeOf(TDUnitVTabCursor));
  if Created = nil then
    Exit(SQLITE_NOMEM);
  FillChar(Created^, SizeOf(Created^), 0);
  Created^.Base.pVtab := VTab;
  Cursor^ := @Created^.Base;
  Result := SQLITE_OK;
end;

function DUnitVTabClose(Cursor: PSQLiteVtabCursor): Integer; cdecl;
begin
  sqlite3_free(Cursor);
  Result := SQLITE_OK;
end;

procedure AdvanceCursor(Cursor: PDUnitVTabCursor);
begin
  while (Cursor^.Row <= 3) and ((Cursor^.AllowedMask and (1 shl Cursor^.Row)) = 0) do
    Inc(Cursor^.Row);
end;

function DUnitVTabFilter(Cursor: PSQLiteVtabCursor; IndexNumber: Integer;
  IndexString: MarshaledAString; ArgumentCount: Integer; ArgumentValues: PSQLiteValues): Integer; cdecl;
var
  Code: Integer;
  CurrentValue: PSQLiteValue;
  State: PVTabState;
  TypedCursor: PDUnitVTabCursor;
  Value: Integer;
begin
  TypedCursor := PDUnitVTabCursor(Cursor);
  State := PDUnitVTab(Cursor^.pVtab)^.State;
  TypedCursor^.AllowedMask := 0;

  case IndexNumber of
    0:
      TypedCursor^.AllowedMask := (1 shl 1) or (1 shl 2) or (1 shl 3);
    1:
      if ArgumentCount = 1 then
      begin
        Value := sqlite3_value_int(ArgumentValues[0]);
        if (Value >= 1) and (Value <= 3) then
          TypedCursor^.AllowedMask := 1 shl Value;
      end;
    2:
      if ArgumentCount = 1 then
      begin
        CurrentValue := nil;
        Code := sqlite3_vtab_in_first(ArgumentValues[0], CurrentValue);
        while Code = SQLITE_OK do
        begin
          Value := sqlite3_value_int(CurrentValue);
          if (Value >= 1) and (Value <= 3) then
            TypedCursor^.AllowedMask := TypedCursor^.AllowedMask or (1 shl Value);
          Inc(State^.InValues);
          Code := sqlite3_vtab_in_next(ArgumentValues[0], CurrentValue);
        end;
        if Code <> SQLITE_DONE then
          Exit(Code);
      end;
  end;

  TypedCursor^.Row := 1;
  AdvanceCursor(TypedCursor);
  Result := SQLITE_OK;
end;

function DUnitVTabNext(Cursor: PSQLiteVtabCursor): Integer; cdecl;
begin
  Inc(PDUnitVTabCursor(Cursor)^.Row);
  AdvanceCursor(PDUnitVTabCursor(Cursor));
  Result := SQLITE_OK;
end;

function DUnitVTabEof(Cursor: PSQLiteVtabCursor): Integer; cdecl;
begin
  Result := Ord(PDUnitVTabCursor(Cursor)^.Row > 3);
end;

function DUnitVTabColumn(Cursor: PSQLiteVtabCursor; Context: PSQLite3FuncContext;
  Column: Integer): Integer; cdecl;
var
  State: PVTabState;
  TextValue: UTF8String;
begin
  State := PDUnitVTab(Cursor^.pVtab)^.State;
  sqlite3_vtab_nochange(Context);
  Inc(State^.NoChangeCalls);

  if Column = 0 then
    sqlite3_result_int(Context, PDUnitVTabCursor(Cursor)^.Row)
  else
  begin
    case PDUnitVTabCursor(Cursor)^.Row of
      1: TextValue := UTF8String('one');
      2: TextValue := UTF8String('two');
    else
      TextValue := UTF8String('three');
    end;
    sqlite3_result_text(Context, TextValue);
  end;
  Result := SQLITE_OK;
end;

function DUnitVTabRowId(Cursor: PSQLiteVtabCursor; var RowId: Int64): Integer; cdecl;
begin
  RowId := PDUnitVTabCursor(Cursor)^.Row;
  Result := SQLITE_OK;
end;

function DUnitVTabUpdate(VTab: PSQLiteVtab; ArgumentCount: Integer;
  ArgumentValues: PSQLiteValues; var RowId: Int64): Integer; cdecl;
begin
  PDUnitVTab(VTab)^.State^.ConflictMode :=
    sqlite3_vtab_on_conflict(PDUnitVTab(VTab)^.State^.DB);
  Result := SQLITE_READONLY;
end;

procedure ModuleAuxDestroy(Aux: Pointer); cdecl;
begin
  if Aux <> nil then
    Inc(PVTabState(Aux)^.ModuleDestroyCalls);
end;

{$IFDEF link_deprecated_api}
procedure LegacyTraceCallback(Context: Pointer; Text: MarshaledAString); cdecl;
begin
end;

procedure LegacyProfileCallback(Context: Pointer; Text: MarshaledAString; Time: UInt64); cdecl;
begin
end;
{$ENDIF}

procedure TSqlite3ExtendedApiTests.SetUp;
begin
  inherited;
  CheckSqliteOk(sqlite3_initialize, 'sqlite3_initialize');
end;

procedure TSqlite3ExtendedApiTests.TearDown;
begin
  CheckSqliteOk(sqlite3_shutdown, 'sqlite3_shutdown');
  inherited;
end;

function TSqlite3ExtendedApiTests.LastError(const DB: Pointer): string;
begin
  if DB = nil then
    Exit('<no database handle>');
  Result := Utf8PtrToString(sqlite3_errmsg(DB));
end;

procedure TSqlite3ExtendedApiTests.CheckSqliteOk(const Code: Integer;
  const Context: string; const DB: Pointer);
begin
  if Code <> SQLITE_OK then
    Fail(Format('%s failed with code %d: %s', [Context, Code, LastError(DB)]));
end;

function TSqlite3ExtendedApiTests.OpenDatabase(const FileName: string;
  const Flags: Integer): Pointer;
var
  FileNameUtf8: UTF8String;
begin
  Result := nil;
  FileNameUtf8 := UTF8String(FileName);
  CheckSqliteOk(sqlite3_open_v2(MarshaledAString(PAnsiChar(FileNameUtf8)), Result,
    Flags, nil), 'sqlite3_open_v2(' + FileName + ')', Result);
end;

procedure TSqlite3ExtendedApiTests.CloseDatabase(var DB: Pointer);
var
  Code: Integer;
begin
  if DB = nil then
    Exit;
  Code := sqlite3_close(DB);
  DB := nil;
  CheckSqliteOk(Code, 'sqlite3_close');
end;

function TSqlite3ExtendedApiTests.Prepare(const DB: Pointer; const SQL: string): Pointer;
var
  SqlUtf8: UTF8String;
begin
  Result := nil;
  SqlUtf8 := UTF8String(SQL);
  CheckSqliteOk(sqlite3_prepare_v2(DB, MarshaledAString(PAnsiChar(SqlUtf8)), -1,
    Result, nil), 'sqlite3_prepare_v2(' + SQL + ')', DB);
end;

procedure TSqlite3ExtendedApiTests.FinalizeStatement(var Statement: Pointer;
  const DB: Pointer);
var
  Code: Integer;
begin
  if Statement = nil then
    Exit;
  Code := sqlite3_finalize(Statement);
  Statement := nil;
  CheckSqliteOk(Code, 'sqlite3_finalize', DB);
end;

function TSqlite3ExtendedApiTests.ExecCode(const DB: Pointer; const SQL: string): Integer;
var
  ErrorMessage: MarshaledAString;
  SqlUtf8: UTF8String;
begin
  ErrorMessage := nil;
  SqlUtf8 := UTF8String(SQL);
  Result := sqlite3_exec(DB, MarshaledAString(PAnsiChar(SqlUtf8)), nil, nil, @ErrorMessage);
  if ErrorMessage <> nil then
    sqlite3_free(ErrorMessage);
end;

procedure TSqlite3ExtendedApiTests.ExecSql(const DB: Pointer; const SQL: string);
begin
  CheckSqliteOk(ExecCode(DB, SQL), 'sqlite3_exec(' + SQL + ')', DB);
end;

function TSqlite3ExtendedApiTests.QueryScalarInt(const DB: Pointer;
  const SQL: string): Integer;
var
  Statement: Pointer;
begin
  Statement := Prepare(DB, SQL);
  try
    CheckEquals(SQLITE_ROW, sqlite3_step(Statement), 'sqlite3_step expected SQLITE_ROW');
    Result := sqlite3_column_int(Statement, 0);
  finally
    FinalizeStatement(Statement, DB);
  end;
end;

function TSqlite3ExtendedApiTests.QueryScalarText(const DB: Pointer;
  const SQL: string): string;
var
  Statement: Pointer;
begin
  Statement := Prepare(DB, SQL);
  try
    CheckEquals(SQLITE_ROW, sqlite3_step(Statement), 'sqlite3_step expected SQLITE_ROW');
    Result := Utf8PtrToString(sqlite3_column_text(Statement, 0));
  finally
    FinalizeStatement(Statement, DB);
  end;
end;

function TSqlite3ExtendedApiTests.ExecuteScalarStepCode(const DB: Pointer;
  const SQL: string; out ErrorText: string): Integer;
var
  Statement: Pointer;
begin
  Statement := Prepare(DB, SQL);
  Result := sqlite3_step(Statement);
  ErrorText := LastError(DB);
  sqlite3_finalize(Statement);
end;

function TSqlite3ExtendedApiTests.ExtensionFileName: string;
begin
  Result := TPath.GetFullPath(TPath.Combine(ExtractFileDir(ParamStr(0)),
    '..\mod_spatialite.dll'));
end;

function TSqlite3ExtendedApiTests.TestDataFileName: string;
begin
  Result := TPath.GetFullPath(TPath.Combine(ExtractFileDir(ParamStr(0)),
    '..\..\..\data\perm_krai.sqlite'));
end;

procedure TSqlite3ExtendedApiTests.LoadSpatialite(const DB: Pointer);
var
  Code: Integer;
  Enabled: Integer;
  EntryPointUtf8: UTF8String;
  ErrorMessage: MarshaledAString;
  ErrorText: string;
  FileNameUtf8: UTF8String;
begin
  CheckTrue(TFile.Exists(ExtensionFileName), 'mod_spatialite.dll is missing: ' + ExtensionFileName);
  CheckTrue(TFile.GetSize(ExtensionFileName) > 0, 'mod_spatialite.dll is empty: ' + ExtensionFileName);

  Enabled := 0;
  CheckSqliteOk(sqlite3_db_config(DB, SQLITE_DBCONFIG_ENABLE_LOAD_EXTENSION, 1, @Enabled),
    'sqlite3_db_config ENABLE_LOAD_EXTENSION', DB);
  CheckSqliteOk(sqlite3_enable_load_extension(DB, 1), 'sqlite3_enable_load_extension', DB);

  FileNameUtf8 := UTF8String(ExtensionFileName);
  EntryPointUtf8 := UTF8String('sqlite3_modspatialite_init');
  ErrorMessage := nil;
  Code := sqlite3_load_extension(DB, MarshaledAString(PAnsiChar(FileNameUtf8)),
    MarshaledAString(PAnsiChar(EntryPointUtf8)), @ErrorMessage);
  if Code <> SQLITE_OK then
  begin
    ErrorText := Utf8PtrToString(ErrorMessage);
    if ErrorMessage <> nil then
      sqlite3_free(ErrorMessage);
    Fail(Format('sqlite3_load_extension failed with code %d: %s', [Code, ErrorText]));
  end;
  if ErrorMessage <> nil then
    sqlite3_free(ErrorMessage);
  CheckSqliteOk(sqlite3_enable_load_extension(DB, 0), 'sqlite3_enable_load_extension off', DB);
end;

procedure TSqlite3ExtendedApiTests.RegisterScalar(const DB: Pointer;
  const Name: UTF8String; const ArgumentCount, Flags: Integer; const Callback: TxSFunc);
begin
  CheckSqliteOk(sqlite3_create_function_v2(DB, MarshaledAString(PAnsiChar(Name)),
    ArgumentCount, Flags, nil, Callback, nil, nil, nil),
    'sqlite3_create_function_v2(' + string(Name) + ')', DB);
end;

procedure TSqlite3ExtendedApiTests.LifecycleFormattingVfsAndWin32Apis;
var
  Buffer: array[0..63] of AnsiChar;
  Builder: PSQLite3Str;
  DefaultVfs: PSQLiteVfs;
  FormatText: UTF8String;
  Formatted: MarshaledAString;
  LogState: TLogState;
  MBCSText: MarshaledAString;
begin
  if not TFile.Exists(TestDataFileName) then
  begin
    Status('Skipped: test data is not available: ' + TestDataFileName);
    Exit;
  end;
  CheckSqliteOk(sqlite3_shutdown, 'sqlite3_shutdown before config');
  FillChar(LogState, SizeOf(LogState), 0);
  try
    CheckTrue(@sqlite3_os_init <> nil, 'sqlite3_os_init is not linked');
    CheckTrue(@sqlite3_os_end <> nil, 'sqlite3_os_end is not linked');
    CheckSqliteOk(sqlite3_config(SQLITE_CONFIG_LOG, @SQLiteLogCallback, @LogState),
      'sqlite3_config LOG');
    CheckSqliteOk(sqlite3_config(SQLITE_CONFIG_URI, 1), 'sqlite3_config URI');
    CheckSqliteOk(sqlite3_initialize, 'sqlite3_initialize after config');
    sqlite3_log(SQLITE_NOTICE, MarshaledAString(PAnsiChar(UTF8String('dunit sqlite3_log'))));
    CheckEquals(1, LogState.Calls, 'sqlite3_log callback count mismatch');
    CheckEquals(SQLITE_NOTICE, LogState.LastCode, 'sqlite3_log callback code mismatch');
  finally
    sqlite3_shutdown;
    sqlite3_config(SQLITE_CONFIG_LOG, nil, nil);
    CheckSqliteOk(sqlite3_initialize, 'sqlite3_initialize restore');
  end;

  sqlite3_activate_see(nil);
  CheckTrue(sqlite3_test_control(SQLITE_TESTCTRL_BYTEORDER) <> 0,
    'sqlite3_test_control BYTEORDER returned zero');

  FormatText := UTF8String('formatted text');
  Formatted := sqlite3_mprintf(MarshaledAString(PAnsiChar(FormatText)));
  CheckTrue(Formatted <> nil, 'sqlite3_mprintf returned nil');
  try
    CheckEquals('formatted text', Utf8PtrToString(Formatted), 'sqlite3_mprintf mismatch');
  finally
    sqlite3_free(Formatted);
  end;

  Formatted := sqlite3_vmprintf(MarshaledAString(PAnsiChar(FormatText)), nil);
  CheckTrue(Formatted <> nil, 'sqlite3_vmprintf returned nil');
  try
    CheckEquals('formatted text', Utf8PtrToString(Formatted), 'sqlite3_vmprintf mismatch');
  finally
    sqlite3_free(Formatted);
  end;

  FillChar(Buffer, SizeOf(Buffer), 0);
  sqlite3_snprintf(SizeOf(Buffer), @Buffer[0], MarshaledAString(PAnsiChar(FormatText)));
  CheckEquals('formatted text', string(AnsiString(PAnsiChar(@Buffer[0]))), 'sqlite3_snprintf mismatch');
  FillChar(Buffer, SizeOf(Buffer), 0);
  sqlite3_vsnprintf(SizeOf(Buffer), @Buffer[0], MarshaledAString(PAnsiChar(FormatText)), nil);
  CheckEquals('formatted text', string(AnsiString(PAnsiChar(@Buffer[0]))), 'sqlite3_vsnprintf mismatch');

  Builder := sqlite3_str_new(nil);
  CheckTrue(Builder <> nil, 'sqlite3_str_new returned nil');
  sqlite3_str_appendf(Builder, MarshaledAString(PAnsiChar(UTF8String('appendf'))));
  sqlite3_str_vappendf(Builder, MarshaledAString(PAnsiChar(UTF8String('-vappendf'))), nil);
  CheckEquals('appendf-vappendf', Utf8PtrToString(sqlite3_str_value(Builder)),
    'formatted string builder mismatch');
  sqlite3_str_free(Builder);

  DefaultVfs := sqlite3_vfs_find(nil);
  CheckTrue(DefaultVfs <> nil, 'sqlite3_vfs_find returned nil');
  CheckSqliteOk(sqlite3_vfs_unregister(DefaultVfs), 'sqlite3_vfs_unregister');
  try
    CheckSqliteOk(sqlite3_vfs_register(DefaultVfs, 1), 'sqlite3_vfs_register');
    DefaultVfs := nil;
  finally
    if DefaultVfs <> nil then
      sqlite3_vfs_register(DefaultVfs, 1);
  end;

  MBCSText := sqlite3_win32_mbcs_to_utf8(MarshaledAString(PAnsiChar(AnsiString('ascii'))));
  CheckTrue(MBCSText <> nil, 'sqlite3_win32_mbcs_to_utf8 returned nil');
  try
    CheckEquals('ascii', Utf8PtrToString(MBCSText), 'sqlite3_win32_mbcs_to_utf8 mismatch');
  finally
    sqlite3_free(MBCSText);
  end;
  MBCSText := sqlite3_win32_mbcs_to_utf8_v2(MarshaledAString(PAnsiChar(AnsiString('ansi'))), 1);
  CheckTrue(MBCSText <> nil, 'sqlite3_win32_mbcs_to_utf8_v2 returned nil');
  sqlite3_free(MBCSText);
  MBCSText := sqlite3_win32_utf8_to_mbcs(PUtf8Char(PAnsiChar(UTF8String('utf8'))));
  CheckTrue(MBCSText <> nil, 'sqlite3_win32_utf8_to_mbcs returned nil');
  sqlite3_free(MBCSText);
  MBCSText := sqlite3_win32_utf8_to_mbcs_v2(PUtf8Char(PAnsiChar(UTF8String('utf8'))), 0);
  CheckTrue(MBCSText <> nil, 'sqlite3_win32_utf8_to_mbcs_v2 returned nil');
  sqlite3_free(MBCSText);

  CheckSqliteOk(sqlite3_win32_set_directory(SQLITE_WIN32_DATA_DIRECTORY_TYPE, nil),
    'sqlite3_win32_set_directory');
  CheckSqliteOk(sqlite3_win32_set_directory8(SQLITE_WIN32_DATA_DIRECTORY_TYPE, nil),
    'sqlite3_win32_set_directory8');
  CheckSqliteOk(sqlite3_win32_set_directory16(SQLITE_WIN32_DATA_DIRECTORY_TYPE, nil),
    'sqlite3_win32_set_directory16');
  CheckTrue(sqlite3_get_data_directory = nil, 'sqlite3_data_directory was not reset');
  sqlite3_win32_write_debug(nil, 0);
end;

procedure TSqlite3ExtendedApiTests.Utf16MetadataAndCommonHelpers;
var
  BinaryValue: AnsiString;
  Buffer: array[0..15] of AnsiChar;
  DB: Pointer;
  Decoded: string;
  Expected: string;
  PageSize: Integer;
  Statement: Pointer;
  Utf8Value: UTF8String;
  WideBuffer: array[0..7] of WideChar;
  WidePointer: PWideChar;
  WideSql: string;
begin
  if not TFile.Exists(TestDataFileName) then
  begin
    Status('Skipped: test data is not available: ' + TestDataFileName);
    Exit;
  end;
  DB := OpenDatabase(':memory:', SQLITE_OPEN_READWRITE or SQLITE_OPEN_CREATE);
  try
    ExecSql(DB, 'create table meta_items(id integer primary key, name text);');
    WideSql := 'select id, name from meta_items;';
    Statement := nil;
    CheckSqliteOk(sqlite3_prepare16(DB, PWideChar(WideSql), Length(WideSql) * SizeOf(WideChar),
      Statement, nil), 'sqlite3_prepare16', DB);
    try
      CheckEquals('main', Utf16PtrToString(sqlite3_column_database_name16(Statement, 0)),
        'sqlite3_column_database_name16 mismatch');
      CheckEquals('meta_items', Utf16PtrToString(sqlite3_column_table_name16(Statement, 0)),
        'sqlite3_column_table_name16 mismatch');
      CheckEquals('id', Utf16PtrToString(sqlite3_column_origin_name16(Statement, 0)),
        'sqlite3_column_origin_name16 mismatch');
      CheckEquals('INTEGER', UpperCase(Utf16PtrToString(sqlite3_column_decltype16(Statement, 0))),
        'sqlite3_column_decltype16 mismatch');
    finally
      FinalizeStatement(Statement, DB);
    end;
  finally
    CloseDatabase(DB);
  end;

  CheckTrue(sqlite3_error_message(SQLITE_BUSY) <> '', 'sqlite3_error_message returned empty text');
  CheckEquals('main', sqlite3_maindb_alias, 'sqlite3_maindb_alias mismatch');
  BinaryValue := AnsiString(#0#1#39'ABC');
  CheckEquals(BinaryValue, sqlite3_unescape_binary_string(sqlite3_escape_binary_string(BinaryValue)),
    'binary escape round-trip mismatch');
  CheckEquals(5, Integer(sqlite3_strlen(PAnsiChar(AnsiString('alpha')))), 'sqlite3_strlen mismatch');
  CheckEquals(0, sqlite3_strcomp(PAnsiChar(AnsiString('same')), PAnsiChar(AnsiString('same'))),
    'sqlite3_strcomp mismatch');
  FillChar(Buffer, SizeOf(Buffer), 0);
  sqlite3_strlcopy(@Buffer[0], PAnsiChar(AnsiString('abcdef')), 3);
  CheckEquals('abc', string(AnsiString(PAnsiChar(@Buffer[0]))), 'sqlite3_strlcopy mismatch');
  FillChar(Buffer, SizeOf(Buffer), 0);
  sqlite3_strpcopy(@Buffer[0], AnsiString('copied'));
  CheckEquals('copied', string(AnsiString(PAnsiChar(@Buffer[0]))), 'sqlite3_strpcopy mismatch');
  CheckEquals('alpha', string(sqlite3_lowercase(AnsiString('ALPHA'))), 'sqlite3_lowercase mismatch');

  SetLength(Utf8Value, 4);
  Utf8Value[1] := AnsiChar($D0);
  Utf8Value[2] := AnsiChar($90);
  Utf8Value[3] := AnsiChar($D0);
  Utf8Value[4] := AnsiChar($91);
  SetLength(Expected, 2);
  Expected[1] := WideChar($0410);
  Expected[2] := WideChar($0411);
  Decoded := sqlite3_decode_utf8(Utf8Value);
  CheckEquals(Expected, Decoded, 'sqlite3_decode_utf8 string overload mismatch');
  CheckEquals(Expected, sqlite3_decode_utf8(PUtf8Char(Utf8Value), Length(Utf8Value)),
    'sqlite3_decode_utf8 pointer overload mismatch');
  CheckEquals(2, Integer(sqlite3_utf8_bytes(PUtf8Char(Utf8Value), Length(Utf8Value))),
    'sqlite3_utf8_bytes mismatch');
  FillChar(WideBuffer, SizeOf(WideBuffer), 0);
  CheckEquals(2, Integer(sqlite3_utf8_to_utf16(@WideBuffer[0], PUtf8Char(Utf8Value),
    Length(Utf8Value))), 'sqlite3_utf8_to_utf16 buffer length mismatch');
  CheckEquals(Expected, string(PWideChar(@WideBuffer[0])), 'sqlite3_utf8_to_utf16 buffer mismatch');
  WidePointer := nil;
  try
    CheckEquals(2, sqlite3_utf8_to_utf16(PUtf8Char(Utf8Value), WidePointer),
      'sqlite3_utf8_to_utf16 allocation length mismatch');
    CheckEquals(Expected, string(WidePointer), 'sqlite3_utf8_to_utf16 allocation mismatch');
  finally
    FreeMem(WidePointer);
  end;
  CheckTrue(sqlite3_compare_string_ordinal('a', 'b') < 0,
    'sqlite3_compare_string_ordinal mismatch');

  PageSize := 0;
  CheckTrue(sqlite3_is_valid_file(TestDataFileName, @PageSize),
    'sqlite3_is_valid_file rejected perm_krai.sqlite');
  CheckEquals(4096, PageSize, 'perm_krai.sqlite page size mismatch');
end;

procedure TSqlite3ExtendedApiTests.ResultAndValueApis;
type
  TExpectedError = record
    Sql: string;
    Code: Integer;
    MessagePart: string;
  end;
const
  ExpectedErrors: array[0..5] of TExpectedError = (
    (Sql: 'select dunit_error();'; Code: SQLITE_ERROR; MessagePart: 'dunit result error'),
    (Sql: 'select dunit_error16();'; Code: SQLITE_ERROR; MessagePart: 'dunit wide error'),
    (Sql: 'select dunit_toobig();'; Code: SQLITE_TOOBIG; MessagePart: 'too big'),
    (Sql: 'select dunit_nomem();'; Code: SQLITE_NOMEM; MessagePart: 'memory'),
    (Sql: 'select dunit_error_utf8();'; Code: SQLITE_ERROR; MessagePart: 'dunit utf8 helper error'),
    (Sql: 'select dunit_error_wide();'; Code: SQLITE_ERROR; MessagePart: 'dunit wide helper error'));
var
  DB: Pointer;
  ErrorText: string;
  ExpectedError: TExpectedError;
  StepCode: Integer;
begin
  DB := OpenDatabase(':memory:', SQLITE_OPEN_READWRITE or SQLITE_OPEN_CREATE);
  try
    RegisterScalar(DB, UTF8String('dunit_value_probe'), 1, SQLITE_UTF8, ValueProbeFunction);
    RegisterScalar(DB, UTF8String('dunit_pointer'), 0, SQLITE_UTF8, PointerProducerFunction);
    RegisterScalar(DB, UTF8String('dunit_pointer_consumer'), 1, SQLITE_UTF8, PointerConsumerFunction);
    RegisterScalar(DB, UTF8String('dunit_subtype'), 0, SQLITE_UTF8 or SQLITE_RESULT_SUBTYPE,
      SubtypeProducerFunction);
    RegisterScalar(DB, UTF8String('dunit_subtype_consumer'), 1, SQLITE_UTF8 or SQLITE_SUBTYPE,
      SubtypeConsumerFunction);
    RegisterScalar(DB, UTF8String('dunit_text64'), 0, SQLITE_UTF8, Text64Function);
    RegisterScalar(DB, UTF8String('dunit_text16le'), 0, SQLITE_UTF8, Text16LeFunction);
    RegisterScalar(DB, UTF8String('dunit_text16be'), 0, SQLITE_UTF8, Text16BeFunction);
    RegisterScalar(DB, UTF8String('dunit_zeroblob'), 0, SQLITE_UTF8, ZeroBlobFunction);
    RegisterScalar(DB, UTF8String('dunit_error'), 0, SQLITE_UTF8, ErrorFunction);
    RegisterScalar(DB, UTF8String('dunit_error16'), 0, SQLITE_UTF8, Error16Function);
    RegisterScalar(DB, UTF8String('dunit_toobig'), 0, SQLITE_UTF8, ErrorTooBigFunction);
    RegisterScalar(DB, UTF8String('dunit_nomem'), 0, SQLITE_UTF8, ErrorNoMemoryFunction);
    RegisterScalar(DB, UTF8String('dunit_error_utf8'), 0, SQLITE_UTF8, ErrorStringUtf8Function);
    RegisterScalar(DB, UTF8String('dunit_error_wide'), 0, SQLITE_UTF8, ErrorStringWideFunction);

    CheckEquals(1, QueryScalarInt(DB, 'select dunit_value_probe(12.5);'),
      'sqlite3_value_double/sqlite3_value_str mismatch');
    CheckEquals(1, QueryScalarInt(DB, 'select dunit_pointer_consumer(dunit_pointer());'),
      'sqlite3_result_pointer mismatch');
    CheckEquals(73, QueryScalarInt(DB, 'select dunit_subtype_consumer(dunit_subtype());'),
      'sqlite3_result_subtype mismatch');
    CheckEquals('text64', QueryScalarText(DB, 'select dunit_text64();'),
      'sqlite3_result_text64 mismatch');
    CheckEquals('le', QueryScalarText(DB, 'select dunit_text16le();'),
      'sqlite3_result_text16le mismatch');
    CheckEquals('be', QueryScalarText(DB, 'select dunit_text16be();'),
      'sqlite3_result_text16be mismatch');
    CheckEquals(7, QueryScalarInt(DB, 'select length(dunit_zeroblob());'),
      'sqlite3_result_zeroblob mismatch');

    for ExpectedError in ExpectedErrors do
    begin
      StepCode := ExecuteScalarStepCode(DB, ExpectedError.Sql, ErrorText);
      CheckEquals(ExpectedError.Code, StepCode and $FF,
        'unexpected result code for ' + ExpectedError.Sql);
      CheckTrue(Pos(LowerCase(ExpectedError.MessagePart), LowerCase(ErrorText)) > 0,
        'unexpected error text for ' + ExpectedError.Sql + ': ' + ErrorText);
    end;
  finally
    CloseDatabase(DB);
  end;
end;

procedure TSqlite3ExtendedApiTests.VirtualTableApis;
var
  Code: Integer;
  DB: Pointer;
  Module: TSQLiteModule;
  ModuleName: UTF8String;
  State: TVTabState;
begin
  FillChar(State, SizeOf(State), 0);
  FillChar(Module, SizeOf(Module), 0);
  Module.iVersion := 3;
  Module.xCreate := DUnitVTabCreate;
  Module.xConnect := DUnitVTabConnect;
  Module.xBestIndex := DUnitVTabBestIndex;
  Module.xDisconnect := DUnitVTabDisconnect;
  Module.xDestroy := DUnitVTabDestroy;
  Module.xOpen := DUnitVTabOpen;
  Module.xClose := DUnitVTabClose;
  Module.xFilter := DUnitVTabFilter;
  Module.xNext := DUnitVTabNext;
  Module.xEof := DUnitVTabEof;
  Module.xColumn := DUnitVTabColumn;
  Module.xRowID := DUnitVTabRowId;
  Module.xUpdate := DUnitVTabUpdate;

  DB := OpenDatabase(':memory:', SQLITE_OPEN_READWRITE or SQLITE_OPEN_CREATE);
  try
    ModuleName := UTF8String('dunit_vtab');
    CheckSqliteOk(sqlite3_create_module(DB, MarshaledAString(PAnsiChar(ModuleName)),
      @Module, @State), 'sqlite3_create_module', DB);
    ExecSql(DB, 'create virtual table dunit_items using dunit_vtab;');
    CheckEquals('1,3', QueryScalarText(DB,
      'select group_concat(value, '','') from (select value from dunit_items where value in (1,3) order by value);'),
      'sqlite3_vtab_in result mismatch');
    CheckEquals(2, QueryScalarInt(DB, 'select value from dunit_items where value = 2;'),
      'virtual table equality result mismatch');
    CheckEquals(1, QueryScalarInt(DB,
      'select count(*) from dunit_items where label collate nocase = ''TWO'';'),
      'sqlite3_vtab_collation query mismatch');
    CheckEquals(3, QueryScalarInt(DB, 'select count(*) from (select distinct value from dunit_items);'),
      'sqlite3_vtab_distinct query mismatch');
    CheckTrue(State.BestIndexCalls > 0, 'xBestIndex was not called');
    CheckTrue(State.CollationCalls > 0, 'sqlite3_vtab_collation was not exercised');
    CheckTrue(State.RhsCalls > 0, 'sqlite3_vtab_rhs_value was not exercised');
    CheckTrue(State.InCalls > 0, 'sqlite3_vtab_in was not exercised');
    CheckEquals(2, State.InValues, 'sqlite3_vtab_in_first/next value count mismatch');
    CheckTrue(State.NoChangeCalls > 0, 'sqlite3_vtab_nochange was not exercised');

    Code := ExecCode(DB, 'insert or replace into dunit_items(value, label) values(4, ''four'');');
    CheckEquals(SQLITE_READONLY, Code and $FF, 'virtual table xUpdate result mismatch');
    CheckEquals(SQLITE_REPLACE, State.ConflictMode, 'sqlite3_vtab_on_conflict mismatch');
    ExecSql(DB, 'drop table dunit_items;');
    CheckTrue(State.DestroyCalls > 0, 'virtual table xDestroy was not called');

    ModuleName := UTF8String('dunit_vtab_v2');
    CheckSqliteOk(sqlite3_create_module_v2(DB, MarshaledAString(PAnsiChar(ModuleName)),
      @Module, @State, ModuleAuxDestroy), 'sqlite3_create_module_v2', DB);
    CheckSqliteOk(sqlite3_drop_modules(DB, nil), 'sqlite3_drop_modules', DB);
    CheckEquals(1, State.ModuleDestroyCalls, 'module auxiliary destructor count mismatch');
  finally
    CloseDatabase(DB);
  end;
end;

procedure TSqlite3ExtendedApiTests.ExtensionApiLayoutAndSpatialite;
var
  DB: Pointer;
begin
  CheckEquals(277 * SizeOf(Pointer), SizeOf(sqlite3ext.sqlite3_api_routines),
    'sqlite3_api_routines layout size differs from sqlite3ext.h');
  CheckEquals(SizeOf(Pointer), SizeOf(sqlite3ext.sqlite3_loadext_entry),
    'sqlite3_loadext_entry size mismatch');

  DB := OpenDatabase(':memory:', SQLITE_OPEN_READWRITE or SQLITE_OPEN_CREATE);
  try
    LoadSpatialite(DB);
    CheckTrue(QueryScalarText(DB, 'select spatialite_version();') <> '',
      'spatialite_version returned empty text');
    CheckTrue(QueryScalarText(DB, 'select geos_version();') <> '',
      'geos_version returned empty text');
    CheckTrue(QueryScalarText(DB, 'select proj4_version();') <> '',
      'proj4_version returned empty text');
    CheckEquals('POINT(12.5 45.25)', QueryScalarText(DB,
      'select AsText(GeomFromText(''POINT(12.5 45.25)'', 4326));'),
      'SpatiaLite geometry round-trip mismatch');
  finally
    CloseDatabase(DB);
  end;
end;

procedure TSqlite3ExtendedApiTests.SpatialiteTestDataReadOnly;
var
  DB: Pointer;
begin
  if not TFile.Exists(TestDataFileName) then
  begin
    Status('Skipped: test data is not available: ' + TestDataFileName);
    Exit;
  end;
  DB := OpenDatabase(TestDataFileName, SQLITE_OPEN_READONLY);
  try
    LoadSpatialite(DB);
    CheckEquals(12, QueryScalarInt(DB, 'select count(*) from geometry_columns;'),
      'geometry_columns row count mismatch');
    CheckEquals(4326, QueryScalarInt(DB,
      'select srid from geometry_columns where f_table_name = ''points'' and f_geometry_column = ''geometry'';'),
      'points SRID mismatch');
    CheckEquals('POINT', UpperCase(QueryScalarText(DB,
      'select GeometryType(GeomFromText(geometry, 4326)) from points where geometry is not null limit 1;')),
      'points geometry type mismatch');
    CheckEquals(1, QueryScalarInt(DB,
      'select length(AsText(GeomFromText(geometry, 4326))) > 0 from points where geometry is not null limit 1;'),
      'SpatiaLite failed to decode a geometry from test data');
    CheckEquals(1, sqlite3_db_readonly(DB, MarshaledAString(PAnsiChar(UTF8String('main')))),
      'test database was not opened read-only');
  finally
    CloseDatabase(DB);
  end;
end;

{$IFDEF link_deprecated_api}
procedure TSqlite3ExtendedApiTests.DeprecatedTraceProfileApis;
var
  DB: Pointer;
  Statement: Pointer;
begin
  DB := OpenDatabase(':memory:', SQLITE_OPEN_READWRITE or SQLITE_OPEN_CREATE);
  try
    sqlite3_trace(DB, LegacyTraceCallback, nil);
    sqlite3_profile(DB, LegacyProfileCallback, nil);
    Statement := Prepare(DB, 'select 1;');
    try
      CheckTrue(sqlite3_expired(Statement) >= 0, 'sqlite3_expired returned an invalid value');
      CheckEquals(SQLITE_ROW, sqlite3_step(Statement), 'deprecated statement step mismatch');
    finally
      FinalizeStatement(Statement, DB);
    end;
    sqlite3_trace(DB, nil, nil);
    sqlite3_profile(DB, nil, nil);
  finally
    CloseDatabase(DB);
  end;
end;
{$ENDIF}

initialization
  RegisterTest(TSqlite3ExtendedApiTests.Suite);

end.
