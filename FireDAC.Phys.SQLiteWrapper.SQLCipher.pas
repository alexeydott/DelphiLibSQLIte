// SQLCipher static API wrapping for Delphi FireDAC Framework

{$I FireDAC.inc} // $(BDS)\source\data
{$I sqlite3.config.inc}
{$IFDEF SQLCIPHER_CRYPTO_OPENSSL}
  {$UNDEF SQLITE3_CNG_CIPHER}
  {$DEFINE SQLITE3_OpenSSL3_CIPHER}
{$ENDIF}
{$IFDEF SQLCIPHER_CRYPTO_CNG}
  {$UNDEF SQLITE3_OpenSSL3_CIPHER}
  {$DEFINE SQLITE3_CNG_CIPHER}
{$ENDIF}
{$IF DEFINED(IOS) OR DEFINED(ANDROID)}
  {$HPPEMIT LINKUNIT}
{$ELSE}
  {$HPPEMIT LINKUNIT}
{$ENDIF}


unit FireDAC.Phys.SQLiteWrapper.SQLCipher;

interface

{$IFDEF FireDAC_SQLITE_STATIC}
uses
  System.SysUtils,
  FireDAC.Stan.Intf, FireDAC.Comp.Client, FireDAC.Phys.SQLiteCli, FireDAC.Phys.SQLiteWrapper,
  sqlite3.common, sqlite.session;

const
{$IFDEF FireDAC_SQLITE_EXTERNAL}
  {$IFDEF UNDERSCOREIMPORTNAME}
    _SLU = '_';
  {$ELSE}
    _SLU = '';
  {$ENDIF}
  {$IF DEFINED(MACOS) and not DEFINED(IOS)}
    C_FD_SQLiteLib = 'libcgsqlite3.dylib';
  {$ELSE}
    C_FD_SQLiteLib = 'libsqlite.a';
  {$ENDIF}
{$ELSE}
  {$IFDEF FireDAC_32}
    {$IFDEF SQLITE3_OpenSSL3_CIPHER}
      C_FD_SQLiteLib = 'sqlite3_win32_ossl.obj';
    {$ELSE}
      C_FD_SQLiteLib = 'sqlite3_win32_cng.obj';
    {$ENDIF}
  {$ENDIF}
  {$IFDEF FireDAC_64}
    {$IFDEF SQLITE3_OpenSSL3_CIPHER}
      C_FD_SQLiteLib = 'sqlite3_win64_ossl.obj';
    {$ELSE}
      C_FD_SQLiteLib = 'sqlite3_win64_cng.obj';
    {$ENDIF}
  {$ENDIF}
{$ENDIF}

type
  TSQLiteLibSQLCipherStat = class;

  /// <summary>Session API facade bound to an open FireDAC physical connection.</summary>
  IFireDACSQLiteSession = interface(IUnknown)
    ['{B5D6F3E0-5E8E-4EF6-9F3B-8C5B1C5A0C41}']
    /// <summary>Returns the SQLite database handle owned by the FireDAC connection.</summary>
    function GetDatabaseHandle: Pointer;
    /// <summary>Creates a Session API capture object for this connection.</summary>
    function CreateSession(const ASchema: string = 'main'): TSQLiteSession;
    /// <summary>Applies a changeset to this connection.</summary>
    function ApplyChangeset(const AChangeset: TSQLiteChangeset;
      const AConflictAction: TSQLiteSessionConflictAction = scaAbort): Integer;
    /// <summary>Applies a changeset with table filtering and v2 rebase output.</summary>
    function ApplyChangesetV2(const AChangeset: TSQLiteChangeset;
      const ATableFilter: TxSessionTableFilter; const AConflict: TxSessionConflict;
      AContext: Pointer; AFlags: Integer; out ARebaseData: TBytes): Integer;
    /// <summary>Applies a changeset with the v3 filter ABI and rebase output.</summary>
    function ApplyChangesetV3(const AChangeset: TSQLiteChangeset;
      const ATableFilter: TxSessionChangesetFilterV3; const AConflict: TxSessionConflict;
      AContext: Pointer; AFlags: Integer; out ARebaseData: TBytes): Integer;
    /// <summary>Applies streamed changeset data to this connection.</summary>
    function ApplyChangesetStream(const AInput: TxSessionInput; AInputContext: Pointer;
      const ATableFilter: TxSessionTableFilter; const AConflict: TxSessionConflict;
      AContext: Pointer): Integer;
    /// <summary>Applies streamed changeset data with v2 rebase output.</summary>
    function ApplyChangesetV2Stream(const AInput: TxSessionInput; AInputContext: Pointer;
      const ATableFilter: TxSessionTableFilter; const AConflict: TxSessionConflict;
      AContext: Pointer; AFlags: Integer; out ARebaseData: TBytes): Integer;
    /// <summary>Applies streamed changeset data with the v3 filter ABI.</summary>
    function ApplyChangesetV3Stream(const AInput: TxSessionInput; AInputContext: Pointer;
      const ATableFilter: TxSessionChangesetFilterV3; const AConflict: TxSessionConflict;
      AContext: Pointer; AFlags: Integer; out ARebaseData: TBytes): Integer;
    /// <summary>Creates a changegroup associated with this SQLite build.</summary>
    function CreateChangegroup: TSQLiteChangegroup;
    /// <summary>Creates a rebaser from apply-v2/v3 rebase data.</summary>
    function CreateRebaser(const ARebaseData: TBytes): TSQLiteRebaser;
    /// <summary>Configures the process-wide Session streaming buffer size.</summary>
    function ConfigureSessionStreamSize(const AValue: Integer): Integer;
    /// <summary>Returns the borrowed SQLite database handle.</summary>
    property DatabaseHandle: Pointer read GetDatabaseHandle;
  end;

  /// <summary>QueryInterface-compatible adapter for the Session API of a FireDAC connection.</summary>
  /// <remarks>The FireDAC connection must remain alive while this interface is in use.</remarks>
  TFireDACSQLiteSession = class(TInterfacedObject, IFireDACSQLiteSession)
  private
    FConnection: TFDCustomConnection;
    FDatabase: TSQLiteDatabase;
  public
    /// <summary>Binds the adapter to an open FireDAC connection.</summary>
    constructor Create(const AConnection: TFDCustomConnection);
    /// <summary>Releases the borrowed FireDAC database reference.</summary>
    destructor Destroy; override;
    /// <summary>Returns the borrowed SQLite database handle.</summary>
    function GetDatabaseHandle: Pointer;
    /// <summary>Creates a Session API capture object for the FireDAC connection.</summary>
    function CreateSession(const ASchema: string = 'main'): TSQLiteSession;
    /// <summary>Applies a changeset to the FireDAC connection.</summary>
    function ApplyChangeset(const AChangeset: TSQLiteChangeset;
      const AConflictAction: TSQLiteSessionConflictAction = scaAbort): Integer;
    function ApplyChangesetV2(const AChangeset: TSQLiteChangeset;
      const ATableFilter: TxSessionTableFilter; const AConflict: TxSessionConflict;
      AContext: Pointer; AFlags: Integer; out ARebaseData: TBytes): Integer;
    function ApplyChangesetV3(const AChangeset: TSQLiteChangeset;
      const ATableFilter: TxSessionChangesetFilterV3; const AConflict: TxSessionConflict;
      AContext: Pointer; AFlags: Integer; out ARebaseData: TBytes): Integer;
    function ApplyChangesetStream(const AInput: TxSessionInput; AInputContext: Pointer;
      const ATableFilter: TxSessionTableFilter; const AConflict: TxSessionConflict;
      AContext: Pointer): Integer;
    function ApplyChangesetV2Stream(const AInput: TxSessionInput; AInputContext: Pointer;
      const ATableFilter: TxSessionTableFilter; const AConflict: TxSessionConflict;
      AContext: Pointer; AFlags: Integer; out ARebaseData: TBytes): Integer;
    function ApplyChangesetV3Stream(const AInput: TxSessionInput; AInputContext: Pointer;
      const ATableFilter: TxSessionChangesetFilterV3; const AConflict: TxSessionConflict;
      AContext: Pointer; AFlags: Integer; out ARebaseData: TBytes): Integer;
    function CreateChangegroup: TSQLiteChangegroup;
    function CreateRebaser(const ARebaseData: TBytes): TSQLiteRebaser;
    function ConfigureSessionStreamSize(const AValue: Integer): Integer;
  end;

  TSQLiteLibSQLCipherStat = class(TSQLiteLib)
  protected
    function GetDefaultSharedCacheMode: Integer; override;
    procedure LoadEntries; override;
  public
    procedure Load(const AVendorHome, AVendorLib: String); override;
    procedure Unload; override;
    /// <summary>Indicates whether this statically linked SQLite build includes Session API.</summary>
    function SupportsSessionApi: Boolean;
    /// <summary>Creates a Session API wrapper for an open SQLite database.</summary>
    /// <param name="ADatabase">Open SQLite database handle.</param>
    /// <param name="ASchema">Database schema to observe, normally "main".</param>
    function CreateSession(const ADatabase: Pointer; const ASchema: string = 'main'): TSQLiteSession;
    /// <summary>Applies a changeset through the statically linked SQLCipher library.</summary>
    /// <param name="ADatabase">Target SQLite database handle.</param>
    /// <param name="AChangeset">Changeset to apply.</param>
    /// <param name="AConflictAction">Action to use for changeset conflicts.</param>
    /// <returns>SQLite result code returned by the apply operation.</returns>
    function ApplyChangeset(const ADatabase: Pointer; const AChangeset: TSQLiteChangeset;
      const AConflictAction: TSQLiteSessionConflictAction = scaAbort): Integer;
  end;

  // SQLite C API entry points are provided by sqlite3.static.pas.
  // This unit only adapts them to FireDAC's TSQLiteLib static linkage.

var
  __ieee_32_p_inf: Double = 0;

{$ENDIF}

implementation

{$IFDEF FireDAC_SQLITE_STATIC}
uses
  System.Classes, System.SyncObjs,
{$IFDEF MSWINDOWS}
  Winapi.Windows, System.Win.Crtl, System.Math,
{$ENDIF}
  FireDAC.Stan.Util, FireDAC.Stan.Consts, FireDAC.Stan.Cipher,
  sqlite3.static;

procedure sqlite3_activate_see_compat(see: PFDAnsiString); cdecl;
begin
  sqlite3_activate_see(see);
end;

var
  GSQLCipherEncryptionMode: UTF8String;
  GSQLCipherEncryptionError: UTF8String;

function SQLCipherPFDAnsiString(const Value: UTF8String): PFDAnsiString;
begin
  Result := PFDAnsiString(PAnsiChar(Value));
end;

{ TFireDACSQLiteSession                                                        }
{-------------------------------------------------------------------------------}
constructor TFireDACSQLiteSession.Create(const AConnection: TFDCustomConnection);
begin
  inherited Create;
  if AConnection = nil then
    raise EArgumentNilException.Create('AConnection');
  FConnection := AConnection;
  FDatabase := TSQLiteDatabase(FConnection.CliObj);
  if (FDatabase = nil) or (FDatabase.Handle = nil) then
    raise ESQLiteSessionError.Create('FireDAC connection is not open');
  if (FDatabase.Lib = nil) or not (FDatabase.Lib is TSQLiteLibSQLCipherStat) or
     not Assigned(FDatabase.Lib.Fsqlite3_compileoption_used) or
     (FDatabase.Lib.Fsqlite3_compileoption_used('ENABLE_SESSION') = 0) then
    raise ESQLiteSessionError.Create('SQLite was built without ENABLE_SESSION');
end;

destructor TFireDACSQLiteSession.Destroy;
begin
  FDatabase := nil;
  FConnection := nil;
  inherited Destroy;
end;

function TFireDACSQLiteSession.GetDatabaseHandle: Pointer;
begin
  Result := FDatabase.Handle;
end;

function TFireDACSQLiteSession.CreateSession(const ASchema: string): TSQLiteSession;
begin
  Result := TSQLiteLibSQLCipherStat(FDatabase.Lib).CreateSession(GetDatabaseHandle, ASchema);
end;

function TFireDACSQLiteSession.ApplyChangeset(const AChangeset: TSQLiteChangeset;
  const AConflictAction: TSQLiteSessionConflictAction): Integer;
begin
  Result := TSQLiteLibSQLCipherStat(FDatabase.Lib).ApplyChangeset(GetDatabaseHandle,
    AChangeset, AConflictAction);
end;

function TFireDACSQLiteSession.ApplyChangesetV2(const AChangeset: TSQLiteChangeset;
  const ATableFilter: TxSessionTableFilter; const AConflict: TxSessionConflict;
  AContext: Pointer; AFlags: Integer; out ARebaseData: TBytes): Integer;
begin
  Result := TSQLiteSession.ApplyV2(GetDatabaseHandle, AChangeset, ATableFilter,
    AConflict, AContext, AFlags, ARebaseData);
end;

function TFireDACSQLiteSession.ApplyChangesetV3(const AChangeset: TSQLiteChangeset;
  const ATableFilter: TxSessionChangesetFilterV3; const AConflict: TxSessionConflict;
  AContext: Pointer; AFlags: Integer; out ARebaseData: TBytes): Integer;
begin
  Result := TSQLiteSession.ApplyV3(GetDatabaseHandle, AChangeset, ATableFilter,
    AConflict, AContext, AFlags, ARebaseData);
end;

function TFireDACSQLiteSession.ApplyChangesetStream(const AInput: TxSessionInput;
  AInputContext: Pointer; const ATableFilter: TxSessionTableFilter;
  const AConflict: TxSessionConflict; AContext: Pointer): Integer;
begin
  Result := TSQLiteSession.ApplyStream(GetDatabaseHandle, AInput, AInputContext,
    ATableFilter, AConflict, AContext);
end;

function TFireDACSQLiteSession.ApplyChangesetV2Stream(const AInput: TxSessionInput;
  AInputContext: Pointer; const ATableFilter: TxSessionTableFilter;
  const AConflict: TxSessionConflict; AContext: Pointer; AFlags: Integer;
  out ARebaseData: TBytes): Integer;
begin
  Result := TSQLiteSession.ApplyV2Stream(GetDatabaseHandle, AInput, AInputContext,
    ATableFilter, AConflict, AContext, AFlags, ARebaseData);
end;

function TFireDACSQLiteSession.ApplyChangesetV3Stream(const AInput: TxSessionInput;
  AInputContext: Pointer; const ATableFilter: TxSessionChangesetFilterV3;
  const AConflict: TxSessionConflict; AContext: Pointer; AFlags: Integer;
  out ARebaseData: TBytes): Integer;
begin
  Result := TSQLiteSession.ApplyV3Stream(GetDatabaseHandle, AInput, AInputContext,
    ATableFilter, AConflict, AContext, AFlags, ARebaseData);
end;

function TFireDACSQLiteSession.CreateChangegroup: TSQLiteChangegroup;
begin
  Result := TSQLiteChangegroup.Create;
end;

function TFireDACSQLiteSession.CreateRebaser(const ARebaseData: TBytes): TSQLiteRebaser;
begin
  Result := TSQLiteRebaser.Create(ARebaseData);
end;

function TFireDACSQLiteSession.ConfigureSessionStreamSize(const AValue: Integer): Integer;
begin
  Result := TSQLiteSession.ConfigureStreamSize(AValue);
end;

function SQLCipherPragmaText(db: psqlite3; const SQL: UTF8String): string;
var
  Statement: psqlite3_stmt;
  Tail: MarshaledAString;
  Text: MarshaledAString;
begin
  Result := '';
  if db = nil then
    Exit;

  Statement := nil;
  Tail := nil;
  if sqlite3_prepare_v2(db, MarshaledAString(PAnsiChar(SQL)), -1, Statement, @Tail) <> SQLITE_OK then
    Exit;
  try
    if sqlite3_step(Statement) = SQLITE_ROW then
    begin
      Text := sqlite3_column_text(Statement, 0);
      if Text <> nil then
        Result := UTF8ToString(PAnsiChar(Text));
    end;
  finally
    sqlite3_finalize(Statement);
  end;
end;

function SQLCipherPragmaInt(db: psqlite3; const SQL: UTF8String; const DefaultValue: Integer): Integer;
var
  Statement: psqlite3_stmt;
  Tail: MarshaledAString;
begin
  Result := DefaultValue;
  if db = nil then
    Exit;

  Statement := nil;
  Tail := nil;
  if sqlite3_prepare_v2(db, MarshaledAString(PAnsiChar(SQL)), -1, Statement, @Tail) <> SQLITE_OK then
    Exit;
  try
    if sqlite3_step(Statement) = SQLITE_ROW then
      Result := sqlite3_column_int(Statement, 0);
  finally
    sqlite3_finalize(Statement);
  end;
end;

function SQLCipherLooksLikeEncryptionError(const Code: Integer; const Message: string): Boolean;
var
  LowerMessage: string;
begin
  LowerMessage := LowerCase(Message);
  Result :=
    (Code in [SQLITE_ERROR, SQLITE_NOTADB, SQLITE_AUTH]) and
    ((Pos('file is not a database', LowerMessage) <> 0) or
     (Pos('not a database', LowerMessage) <> 0) or
     (Pos('hmac', LowerMessage) <> 0) or
     (Pos('cipher', LowerMessage) <> 0) or
     (Pos('decrypt', LowerMessage) <> 0) or
     (Pos('malformed', LowerMessage) <> 0));
end;

function FD_sqlite3GetCacheSize(db: psqlite3): Integer; cdecl;
begin
  Result := SQLCipherPragmaInt(db, 'pragma cache_size;', 0);
end;

function FD_sqlite3GetEncoding(db: psqlite3): Integer; cdecl;
var
  Encoding: string;
begin
  Encoding := LowerCase(SQLCipherPragmaText(db, 'pragma encoding;'));
  if Encoding = 'utf-16le' then
    Result := SQLITE_UTF16LE
  else if Encoding = 'utf-16be' then
    Result := SQLITE_UTF16BE
  else if Copy(Encoding, 1, 6) = 'utf-16' then
    Result := SQLITE_UTF16
  else
    Result := SQLITE_UTF8;
end;

function FD_sqlite3GetEncryptionMode(db: psqlite3; var name: PFDAnsiString;
  var len: Integer): Integer;
var
  Provider: string;
  Version: string;
begin
  name := nil;
  len := 0;
  if db = nil then
  begin
    Result := SQLITE_ERROR;
    Exit;
  end;

  Provider := SQLCipherPragmaText(db, 'pragma cipher_provider;');
  Version := SQLCipherPragmaText(db, 'pragma cipher_version;');
  if Provider = '' then
  begin
    Result := SQLITE_ERROR;
    Exit;
  end;

  GSQLCipherEncryptionMode := UTF8String('SQLCipher/' + Provider);
  if Version <> '' then
    GSQLCipherEncryptionMode := GSQLCipherEncryptionMode + UTF8String(' ' + Version);

  name := SQLCipherPFDAnsiString(GSQLCipherEncryptionMode);
  len := Length(GSQLCipherEncryptionMode);
  Result := SQLITE_OK;
end;

function FD_sqlite3GetEncryptionError(db: psqlite3; var error: PFDAnsiString;
  var len: Integer; var error_code: Integer): Integer;
var
  Code: Integer;
  Message: string;
begin
  error := nil;
  len := 0;
  error_code := er_FD_SQLiteGeneral;
  Result := SQLITE_OK;
  if db = nil then
    Exit;

  Code := sqlite3_errcode(db);
  Message := UTF8ToString(PAnsiChar(sqlite3_errmsg(db)));
  if not SQLCipherLooksLikeEncryptionError(Code, Message) then
    Exit;

  GSQLCipherEncryptionError := 'Cipher: invalid password is specified or database is corrupted';
  error := SQLCipherPFDAnsiString(GSQLCipherEncryptionError);
  len := Length(GSQLCipherEncryptionError);
  error_code := er_FD_SQLitePwdInvalid;
  Result := SQLITE_ERROR;
end;

procedure FD_sqlite3Error(db: psqlite3; err_code: Integer; zMessage: PByte); cdecl;
begin
  if db <> nil then
    sqlite3_set_errmsg(db, err_code, MarshaledAString(zMessage));
end;

{-------------------------------------------------------------------------------}
{ TSQLiteLibSQLCipherStat                                                             }
{-------------------------------------------------------------------------------}
function TSQLiteLibSQLCipherStat.GetDefaultSharedCacheMode: Integer;
begin
  Result := 0;
end;

{-------------------------------------------------------------------------------}
procedure TSQLiteLibSQLCipherStat.Load(const AVendorHome, AVendorLib: String);
begin
  FDLLName := '<' + C_FD_SQLiteLib + ' SEE statically linked>';
  LoadEntries;
  InternalAfterLoad(True);
end;

{-------------------------------------------------------------------------------}
procedure TSQLiteLibSQLCipherStat.Unload;
begin
  InternalBeforeUnload;
end;

function TSQLiteLibSQLCipherStat.SupportsSessionApi: Boolean;
begin
  Result := sqlite3_compileoption_used(MarshaledAString(PAnsiChar(UTF8String('ENABLE_SESSION')))) <> 0;
end;

function TSQLiteLibSQLCipherStat.CreateSession(const ADatabase: Pointer;
  const ASchema: string): TSQLiteSession;
begin
  if not SupportsSessionApi then
    raise ESQLiteSessionError.Create('SQLite was built without ENABLE_SESSION');
  Result := TSQLiteSession.Create(ADatabase, ASchema);
end;

function TSQLiteLibSQLCipherStat.ApplyChangeset(const ADatabase: Pointer;
  const AChangeset: TSQLiteChangeset;
  const AConflictAction: TSQLiteSessionConflictAction): Integer;
begin
  if not SupportsSessionApi then
    raise ESQLiteSessionError.Create('SQLite was built without ENABLE_SESSION');
  Result := TSQLiteSession.Apply(ADatabase, AChangeset, AConflictAction);
end;

{-------------------------------------------------------------------------------}
procedure TSQLiteLibSQLCipherStat.LoadEntries;
begin
  @Fsqlite3_libversion := @sqlite3_libversion;
  FVersionStr := TFDEncoder.Deco(Fsqlite3_libversion(), -1, ecANSI);
  @Fsqlite3_libversion_number := @sqlite3_libversion_number;
  FVersion := Fsqlite3_libversion_number();
  FVersion :=
    (FVersion div 1000000) * 100000000 +
    ((FVersion mod 1000000) div 1000) * 1000000 +
    (FVersion mod 1000) * 10000;
  @Fsqlite3_compileoption_used := @sqlite3_compileoption_used;
  @Fsqlite3_compileoption_get := @sqlite3_compileoption_get;

  @Fsqlite3_initialize := @sqlite3_initialize;
  @Fsqlite3_shutdown := @sqlite3_shutdown;
  @Fsqlite3_config := @sqlite3_config;
  @Fsqlite3_close := @sqlite3_close;
  @Fsqlite3_errcode := @sqlite3_errcode;
  @Fsqlite3_errmsg := @sqlite3_errmsg16;
  @Fsqlite3_errstr := @sqlite3_errstr;
  @Fsqlite3_extended_result_codes := @sqlite3_extended_result_codes;
  @Fsqlite3_open := @sqlite3_open16;
  @Fsqlite3_open_v2 := @sqlite3_open_v2;
  @Fsqlite3_activate_see := @sqlite3_activate_see_compat;
  @Fsqlite3_key := @sqlite3_key;
  @Fsqlite3_rekey := @sqlite3_rekey;
  @Fsqlite3_trace := nil;
  @Fsqlite3_profile := nil;
  @Fsqlite3_busy_timeout := @sqlite3_busy_timeout;
  @Fsqlite3_get_autocommit := @sqlite3_get_autocommit;
  @Fsqlite3_set_authorizer := @sqlite3_set_authorizer;
  @Fsqlite3_update_hook := @sqlite3_update_hook;
  @Fsqlite3_limit := @sqlite3_limit;
  @Fsqlite3_changes := @sqlite3_changes;
  @Fsqlite3_total_changes := @sqlite3_total_changes;
  @Fsqlite3_interrupt := @sqlite3_interrupt;
  @Fsqlite3_last_insert_rowid := @sqlite3_last_insert_rowid;
  @Fsqlite3_db_status := @sqlite3_db_status;
  @Fsqlite3_exec := @sqlite3_exec;
  @Fsqlite3_enable_shared_cache := @sqlite3_enable_shared_cache;
  @Fsqlite3_release_memory := @sqlite3_release_memory;
  @Fsqlite3_soft_heap_limit := @sqlite3_soft_heap_limit;
  @Fsqlite3_malloc := @sqlite3_malloc;
  @Fsqlite3_memory_used := @sqlite3_memory_used;
  @Fsqlite3_memory_highwater := @sqlite3_memory_highwater;
  @Fsqlite3_status := @sqlite3_status;
  @Fsqlite3_prepare := @sqlite3_prepare16_v2;
  @Fsqlite3_finalize := @sqlite3_finalize;
  @Fsqlite3_step := @sqlite3_step;
  @Fsqlite3_reset := @sqlite3_reset;
  @Fsqlite3_stmt_status := @sqlite3_stmt_status;
  @Fsqlite3_column_count := @sqlite3_column_count;
  @Fsqlite3_column_type := @sqlite3_column_type;
  @Fsqlite3_column_name := @sqlite3_column_name16;
  @Fsqlite3_column_database_name := @sqlite3_column_database_name16;
  @Fsqlite3_column_table_name := @sqlite3_column_table_name16;
  @Fsqlite3_column_origin_name := @sqlite3_column_origin_name16;
  @Fsqlite3_table_column_metadata := @sqlite3_table_column_metadata;
  @Fsqlite3_column_decltype := @sqlite3_column_decltype16;
  @Fsqlite3_column_blob := @sqlite3_column_blob;
  @Fsqlite3_column_double := @sqlite3_column_double;
  @Fsqlite3_column_int64 := @sqlite3_column_int64;
  @Fsqlite3_column_text := @sqlite3_column_text16;
  @Fsqlite3_column_bytes_row := @sqlite3_column_bytes;
  @Fsqlite3_column_bytes := @sqlite3_column_bytes16;
  @Fsqlite3_clear_bindings := @sqlite3_clear_bindings;
  @Fsqlite3_bind_parameter_count := @sqlite3_bind_parameter_count;
  @Fsqlite3_bind_parameter_index := @sqlite3_bind_parameter_index;
  @Fsqlite3_bind_parameter_name := @sqlite3_bind_parameter_name;
  @Fsqlite3_bind_blob := @sqlite3_bind_blob;
  @Fsqlite3_bind_blob64 := @sqlite3_bind_blob64;
  @Fsqlite3_bind_double := @sqlite3_bind_double;
  @Fsqlite3_bind_int64 := @sqlite3_bind_int64;
  @Fsqlite3_bind_null := @sqlite3_bind_null;
  @Fsqlite3_bind_text := @sqlite3_bind_text16;
  @Fsqlite3_bind_text64 := @sqlite3_bind_text64;
  @Fsqlite3_bind_value := @sqlite3_bind_value;
  @Fsqlite3_bind_zeroblob := @sqlite3_bind_zeroblob;
  @Fsqlite3_value_type := @sqlite3_value_type;
  @Fsqlite3_value_blob := @sqlite3_value_blob;
  @Fsqlite3_value_bytes := @sqlite3_value_bytes16;
  @Fsqlite3_value_double := @sqlite3_value_double;
  @Fsqlite3_value_int64 := @sqlite3_value_int64;
  @Fsqlite3_value_text := @sqlite3_value_text16;
  @Fsqlite3_result_blob := @sqlite3_result_blob;
  @Fsqlite3_result_blob64 := @sqlite3_result_blob64;
  @Fsqlite3_result_double := @sqlite3_result_double;
  @Fsqlite3_result_error := @sqlite3_result_error16;
  @Fsqlite3_result_error_code := @sqlite3_result_error_code;
  @Fsqlite3_result_zeroblob := @sqlite3_result_zeroblob;
  @Fsqlite3_result_int64 := @sqlite3_result_int64;
  @Fsqlite3_result_null := @sqlite3_result_null;
  @Fsqlite3_result_text := @sqlite3_result_text16;
  @Fsqlite3_result_text64 := @sqlite3_result_text64;
  @Fsqlite3_create_collation := @sqlite3_create_collation16;
  @Fsqlite3_create_function := @sqlite3_create_function16;
  @Fsqlite3_user_data := @sqlite3_user_data;
  @Gsqlite3_user_data := @Fsqlite3_user_data;
  @Fsqlite3_enable_load_extension := @sqlite3_enable_load_extension;
  @Fsqlite3_load_extension := @sqlite3_load_extension;
  @Fsqlite3_free := @sqlite3_free;
  @Fsqlite3_progress_handler := @sqlite3_progress_handler;
  @Fsqlite3_declare_vtab := @sqlite3_declare_vtab;
  @Fsqlite3_create_module := @sqlite3_create_module;
  @Fsqlite3_create_module_v2 := @sqlite3_create_module_v2;
  @Fsqlite3_vfs_find := @sqlite3_vfs_find;
  @Fsqlite3_vfs_register := @sqlite3_vfs_register;
  @Fsqlite3_vfs_unregister := @sqlite3_vfs_unregister;
  @Fsqlite3_backup_init := @sqlite3_backup_init;
  @Fsqlite3_backup_step := @sqlite3_backup_step;
  @Fsqlite3_backup_finish := @sqlite3_backup_finish;
  @Fsqlite3_backup_remaining := @sqlite3_backup_remaining;
  @Fsqlite3_backup_pagecount := @sqlite3_backup_pagecount;
  @Fsqlite3_wal_hook := @sqlite3_wal_hook;
  @Fsqlite3_wal_autocheckpoint := @sqlite3_wal_autocheckpoint;
  @Fsqlite3_wal_checkpoint := @sqlite3_wal_checkpoint;
  @Fsqlite3_rtree_geometry_callback := @sqlite3_rtree_geometry_callback;
  @Fsqlite3_rtree_query_callback := @sqlite3_rtree_query_callback;
  @Fsqlite3_blob_open := @sqlite3_blob_open;
  @Fsqlite3_blob_close := @sqlite3_blob_close;
  @Fsqlite3_blob_bytes := @sqlite3_blob_bytes;
  @Fsqlite3_blob_read := @sqlite3_blob_read;
  @Fsqlite3_blob_write := @sqlite3_blob_write;
  @Fsqlite3_vtab_config := @sqlite3_vtab_config;
  @Fsqlite3_vtab_on_conflict := @sqlite3_vtab_on_conflict;
  @Fad_sqlite3GetCacheSize := @FD_sqlite3GetCacheSize;
  @Fad_sqlite3GetEncoding := @FD_sqlite3GetEncoding;
  @Fad_sqlite3GetEncryptionMode := @FD_sqlite3GetEncryptionMode;
  @Fad_sqlite3GetEncryptionError := @FD_sqlite3GetEncryptionError;
  @Fad_sqlite3Error := @FD_sqlite3Error;
end;

{-------------------------------------------------------------------------------}
initialization
  TSQLiteLib.GLibClasses[slDefault] := TSQLiteLibSQLCipherStat;
  TSQLiteLib.GLibClasses[slSEEStatic] := TSQLiteLibSQLCipherStat;

finalization
{$ENDIF}

end.
