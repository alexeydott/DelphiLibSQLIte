unit sqlite.session;

{$I sqlite3.config.inc}

interface

{$IFNDEF SQLITE_ENABLE_SESSION}
{$MESSAGE ERROR 'sqlite.session requires SQLITE_ENABLE_SESSION'}
{$ENDIF}

uses
  System.SysUtils,
  sqlite3.common,
  sqlite3.static;

type
  /// <summary>Exception raised when a SQLite Session API operation fails.</summary>
  ESQLiteSessionError = class(ESQLite3Exception);

  /// <summary>Action returned by a changeset conflict callback.</summary>
  TSQLiteSessionConflictAction = (
    /// <summary>Abort changeset application.</summary>
    scaAbort,
    /// <summary>Replace the conflicting row with the changeset row.</summary>
    scaReplace,
    /// <summary>Omit the conflicting changeset operation.</summary>
    scaOmit
  );

  /// <summary>Decides whether a session should capture changes for a table.</summary>
  TSQLiteSessionTableFilter = function(const TableName: string): Boolean of object;

  /// <summary>Owned Delphi copy of a SQLite changeset or patchset.</summary>
  TSQLiteChangeset = class
  private
    FData: TBytes;
  public
    /// <summary>Copies a SQLite-allocated changeset buffer into a Delphi object.</summary>
    /// <param name="Buffer">Pointer to the SQLite changeset data.</param>
    /// <param name="Size">Size of the data in bytes.</param>
    class function FromSQLiteBuffer(const Buffer: Pointer; const Size: Integer): TSQLiteChangeset; static;
    /// <summary>Creates an empty changeset.</summary>
    class function Empty: TSQLiteChangeset; static;
    /// <summary>Indicates whether the changeset contains no operations.</summary>
    function IsEmpty: Boolean;
    /// <summary>Returns the changeset size in bytes.</summary>
    function Size: Integer;
    /// <summary>Returns a pointer to the owned changeset bytes, or nil when empty.</summary>
    function Data: Pointer;
    /// <summary>Creates the inverse of a changeset.</summary>
    /// <param name="Changeset">Changeset to invert.</param>
    class function Invert(const Changeset: TSQLiteChangeset): TSQLiteChangeset; static;
    /// <summary>Concatenates two changesets and coalesces compatible operations.</summary>
    /// <param name="First">First changeset in the sequence.</param>
    /// <param name="Second">Second changeset in the sequence.</param>
    class function Concat(const First, Second: TSQLiteChangeset): TSQLiteChangeset; static;
    /// <summary>Runs the streaming changeset inversion API with caller callbacks.</summary>
    class function InvertStream(const Input: TxSessionInput; InputContext: Pointer;
      const Output: TxSessionOutput; OutputContext: Pointer): Integer; static;
    /// <summary>Runs the streaming changeset concatenation API with caller callbacks.</summary>
    class function ConcatStream(const InputA: TxSessionInput; InputAContext: Pointer;
      const InputB: TxSessionInput; InputBContext: Pointer;
      const Output: TxSessionOutput; OutputContext: Pointer): Integer; static;
    /// <summary>Provides access to a copy of the changeset bytes.</summary>
    property Bytes: TBytes read FData;
  end;

  /// <summary>Captures database changes and produces changesets or patchsets.</summary>
  TSQLiteSession = class
  private
    FHandle: PSQLiteSession;
    FDatabase: Pointer;
    FTableFilter: TSQLiteSessionTableFilter;
    class function ConflictCallback(Context: Pointer; Conflict: Integer;
      Iter: PSQLiteChangesetIter): Integer; cdecl; static;
    class function TableFilterCallback(Context: Pointer; TableName: MarshaledAString): Integer; cdecl; static;
    procedure CheckCode(const Code: Integer; const Operation: string);
  public
    /// <summary>Creates a session attached to an open SQLite database.</summary>
    /// <param name="Database">Open SQLite database handle.</param>
    /// <param name="Schema">Database schema to observe, normally "main".</param>
    constructor Create(const Database: Pointer; const Schema: string = 'main');
    /// <summary>Releases the SQLite session handle.</summary>
    destructor Destroy; override;
    /// <summary>Attaches a table to the session; an empty name attaches all tables.</summary>
    /// <param name="TableName">Table name, or an empty string for all tables.</param>
    procedure Attach(const TableName: string = '');
    /// <summary>Enables or disables change capture.</summary>
    procedure Enable(const Value: Boolean);
    /// <summary>Sets whether subsequent changes are marked as indirect.</summary>
    procedure SetIndirect(const Value: Boolean);
    /// <summary>Configures a session object option.</summary>
    function ObjectConfig(const Operation, Value: Integer): Integer;
    /// <summary>Sets a callback that selects tables on first write.</summary>
    procedure SetTableFilter(const Filter: TSQLiteSessionTableFilter);
    /// <summary>Returns whether change capture is enabled.</summary>
    function IsEnabled: Boolean;
    /// <summary>Returns whether the session currently marks changes as indirect.</summary>
    function IsIndirect: Boolean;
    /// <summary>Returns whether no changes have been captured.</summary>
    function IsEmpty: Boolean;
    /// <summary>Returns the estimated encoded changeset size.</summary>
    function ChangesetSize: Int64;
    /// <summary>Returns memory currently used by the session object.</summary>
    function MemoryUsed: Int64;
    /// <summary>Captures changes by comparing a source database schema.</summary>
    function Diff(const FromSchema, TableName: string): string;
    /// <summary>Creates an owned changeset from the captured changes.</summary>
    function CreateChangeset: TSQLiteChangeset;
    /// <summary>Creates an owned patchset from the captured changes.</summary>
    function CreatePatchset: TSQLiteChangeset;
    /// <summary>Writes the changeset through a streaming output callback.</summary>
    function CreateChangesetStream(const Output: TxSessionOutput; OutputContext: Pointer): Integer;
    /// <summary>Writes the patchset through a streaming output callback.</summary>
    function CreatePatchsetStream(const Output: TxSessionOutput; OutputContext: Pointer): Integer;
    /// <summary>Applies a changeset to an open SQLite database.</summary>
    /// <param name="Database">Target SQLite database handle.</param>
    /// <param name="Changeset">Changeset to apply.</param>
    /// <param name="ConflictAction">Action to use when a row conflict occurs.</param>
    /// <returns>SQLite result code returned by the apply operation.</returns>
    class function Apply(const Database: Pointer; const Changeset: TSQLiteChangeset;
      const ConflictAction: TSQLiteSessionConflictAction = scaAbort): Integer; static;
    /// <summary>Applies a changeset with a table filter and returns v2 rebase data.</summary>
    class function ApplyV2(const Database: Pointer; const Changeset: TSQLiteChangeset;
      const TableFilter: TxSessionTableFilter; const Conflict: TxSessionConflict;
      Context: Pointer; Flags: Integer; out RebaseData: TBytes): Integer; static;
    /// <summary>Applies a changeset with the v3 filter ABI and returns rebase data.</summary>
    class function ApplyV3(const Database: Pointer; const Changeset: TSQLiteChangeset;
      const TableFilter: TxSessionChangesetFilterV3; const Conflict: TxSessionConflict;
      Context: Pointer; Flags: Integer; out RebaseData: TBytes): Integer; static;
    /// <summary>Runs the streaming changeset apply API with caller callbacks.</summary>
    class function ApplyStream(const Database: Pointer; const Input: TxSessionInput;
      InputContext: Pointer; const TableFilter: TxSessionTableFilter;
      const Conflict: TxSessionConflict; Context: Pointer): Integer; static;
    /// <summary>Applies a streamed changeset and returns v2 rebase data.</summary>
    class function ApplyV2Stream(const Database: Pointer; const Input: TxSessionInput;
      InputContext: Pointer; const TableFilter: TxSessionTableFilter;
      const Conflict: TxSessionConflict; Context: Pointer; Flags: Integer;
      out RebaseData: TBytes): Integer; static;
    /// <summary>Applies a streamed changeset with the v3 filter ABI.</summary>
    class function ApplyV3Stream(const Database: Pointer; const Input: TxSessionInput;
      InputContext: Pointer; const TableFilter: TxSessionChangesetFilterV3;
      const Conflict: TxSessionConflict; Context: Pointer; Flags: Integer;
      out RebaseData: TBytes): Integer; static;
    /// <summary>Sets the global SQLite Session streaming buffer size.</summary>
    class function ConfigureStreamSize(const Value: Integer): Integer; static;
    /// <summary>Returns the underlying SQLite session handle for advanced API calls.</summary>
    property Handle: PSQLiteSession read FHandle;
  end;

  /// <summary>Iterates over operations contained in a changeset.</summary>
  TSQLiteChangesetIterator = class
  private
    FHandle: PSQLiteChangesetIter;
    FChangeset: TSQLiteChangeset;
    FTableName: string;
    FColumnCount: Integer;
    FOperation: Integer;
    FIndirect: Boolean;
  public
    /// <summary>Creates an iterator that retains the supplied changeset reference.</summary>
    /// <param name="Changeset">Changeset to iterate.</param>
    constructor Create(const Changeset: TSQLiteChangeset);
    /// <summary>Creates an iterator over a changeset using v2 flags.</summary>
    constructor CreateV2(const Changeset: TSQLiteChangeset; const Flags: Integer);
    /// <summary>Creates an iterator over streamed changeset data.</summary>
    constructor CreateStream(const Input: TxSessionInput; InputContext: Pointer);
    /// <summary>Creates an iterator over streamed changeset data using v2 flags.</summary>
    constructor CreateStreamV2(const Input: TxSessionInput; InputContext: Pointer;
      const Flags: Integer);
    /// <summary>Releases the SQLite changeset iterator.</summary>
    destructor Destroy; override;
    /// <summary>Advances to the next operation.</summary>
    /// <returns>True when an operation is available.</returns>
    function Next: Boolean;
    /// <summary>Copies the primary-key bitmap for the current operation.</summary>
    function PrimaryKeys: TBytes;
    /// <summary>Returns a borrowed old-value pointer for the current operation.</summary>
    function OldValue(const Index: Integer): PSQLiteValue;
    /// <summary>Returns a borrowed new-value pointer for the current operation.</summary>
    function NewValue(const Index: Integer): PSQLiteValue;
    /// <summary>Returns a borrowed conflict-value pointer for the current operation.</summary>
    function ConflictValue(const Index: Integer): PSQLiteValue;
    /// <summary>Returns the foreign-key conflict count for the current operation.</summary>
    function ForeignKeyConflicts: Integer;
    /// <summary>Returns the raw iterator handle for value-level inspection.</summary>
    property Handle: PSQLiteChangesetIter read FHandle;
    /// <summary>Returns the table name of the current operation.</summary>
    property TableName: string read FTableName;
    /// <summary>Returns the number of columns in the current operation.</summary>
    property ColumnCount: Integer read FColumnCount;
    /// <summary>Returns the SQLite changeset operation code of the current operation.</summary>
    property Operation: Integer read FOperation;
    /// <summary>Returns whether the current operation is indirect.</summary>
    property Indirect: Boolean read FIndirect;
  end;

  /// <summary>Combines multiple changesets or patchsets into one output.</summary>
  TSQLiteChangegroup = class
  private
    FHandle: PSQLiteChangegroup;
    procedure CheckCode(const Code: Integer; const Operation: string);
  public
    /// <summary>Creates an empty changegroup.</summary>
    constructor Create;
    /// <summary>Releases the SQLite changegroup handle.</summary>
    destructor Destroy; override;
    /// <summary>Configures the group to produce or consume patchsets.</summary>
    procedure ConfigurePatchset(const Value: Boolean);
    /// <summary>Supplies the database schema used to complete a partial group.</summary>
    function Schema(const Database: Pointer; const SchemaName: string = 'main'): Integer;
    /// <summary>Adds a changeset or patchset to the group.</summary>
    /// <param name="Changeset">Changeset or patchset to add.</param>
    procedure Add(const Changeset: TSQLiteChangeset);
    /// <summary>Adds changeset data through the streaming input callback.</summary>
    function AddStream(const Input: TxSessionInput; InputContext: Pointer): Integer;
    /// <summary>Adds one encoded changeset operation to the group.</summary>
    function AddChange(const Change: TBytes): Integer;
    /// <summary>Begins constructing one operation in the group.</summary>
    function BeginChange(const Operation: Integer; const TableName: string;
      const Indirect: Boolean; out ErrorMessage: string): Integer;
    /// <summary>Adds an integer value while constructing an operation.</summary>
    function ChangeInt64(const IsNew, Column: Integer; const Value: Int64): Integer;
    /// <summary>Adds a NULL value while constructing an operation.</summary>
    function ChangeNull(const IsNew, Column: Integer): Integer;
    /// <summary>Adds a floating-point value while constructing an operation.</summary>
    function ChangeDouble(const IsNew, Column: Integer; const Value: Double): Integer;
    /// <summary>Adds UTF-8 text while constructing an operation.</summary>
    function ChangeText(const IsNew, Column: Integer; const Value: string): Integer;
    /// <summary>Adds a blob while constructing an operation.</summary>
    function ChangeBlob(const IsNew, Column: Integer; const Value: TBytes): Integer;
    /// <summary>Finishes or discards the operation under construction.</summary>
    function FinishChange(const Discard: Boolean; out ErrorMessage: string): Integer;
    /// <summary>Returns the combined changeset or patchset owned by the caller.</summary>
    function Output: TSQLiteChangeset;
    /// <summary>Writes grouped changeset data through the streaming output callback.</summary>
    function OutputStream(const Output: TxSessionOutput; OutputContext: Pointer): Integer;
    /// <summary>Returns the underlying SQLite changegroup handle.</summary>
    property Handle: PSQLiteChangegroup read FHandle;
  end;

  /// <summary>Applies SQLite rebase information to a changeset.</summary>
  TSQLiteRebaser = class
  private
    FHandle: PSQLiteRebaser;
    procedure CheckCode(const Code: Integer; const Operation: string);
  public
    /// <summary>Creates a rebaser from rebase data returned by sqlite3changeset_apply_v2/v3.</summary>
    /// <param name="RebaseData">SQLite rebase blob, copied by the SQLite API during configuration.</param>
    constructor Create(const RebaseData: TBytes);
    /// <summary>Releases the SQLite rebaser handle.</summary>
    destructor Destroy; override;
    /// <summary>Rebases a changeset using the configured rebase data.</summary>
    /// <param name="Changeset">Changeset to rebase.</param>
    /// <returns>A new owned changeset containing the rebased operations.</returns>
    function Rebase(const Changeset: TSQLiteChangeset): TSQLiteChangeset;
    /// <summary>Rebases streamed changeset data through caller callbacks.</summary>
    function RebaseStream(const Input: TxSessionInput; InputContext: Pointer;
      const Output: TxSessionOutput; OutputContext: Pointer): Integer;
  end;

implementation

function CopySQLiteBuffer(const Buffer: Pointer; const Size: Integer): TBytes;
begin
  SetLength(Result, 0);
  if (Buffer <> nil) and (Size > 0) then
  begin
    SetLength(Result, Size);
    Move(Buffer^, Result[0], Size);
  end;
end;

function SQLiteErrorText(var ErrorPtr: MarshaledAString): string;
begin
  if ErrorPtr = nil then
    Exit('');
  Result := UTF8ToString(PAnsiChar(ErrorPtr));
  sqlite3_free(ErrorPtr);
  ErrorPtr := nil;
end;

class function TSQLiteChangeset.FromSQLiteBuffer(const Buffer: Pointer;
  const Size: Integer): TSQLiteChangeset;
begin
  Result := TSQLiteChangeset.Create;
  try
    if (Buffer <> nil) and (Size > 0) then
    begin
      SetLength(Result.FData, Size);
      Move(Buffer^, Result.FData[0], Size);
    end;
  except
    Result.Free;
    raise;
  end;
end;

class function TSQLiteChangeset.Empty: TSQLiteChangeset;
begin
  Result := TSQLiteChangeset.Create;
end;

function TSQLiteChangeset.IsEmpty: Boolean;
begin
  Result := Length(FData) = 0;
end;

function TSQLiteChangeset.Size: Integer;
begin
  Result := Length(FData);
end;

function TSQLiteChangeset.Data: Pointer;
begin
  if Length(FData) = 0 then
    Result := nil
  else
    Result := @FData[0];
end;

class function TSQLiteChangeset.Invert(const Changeset: TSQLiteChangeset): TSQLiteChangeset;
var
  Size: Integer;
  Buffer: Pointer;
begin
  if Changeset = nil then
    raise EArgumentNilException.Create('Changeset');
  Size := 0;
  Buffer := nil;
  if sqlite3changeset_invert(Changeset.Size, Changeset.Data, Size, Buffer) <> SQLITE_OK then
    raise ESQLiteSessionError.Create('sqlite3changeset_invert failed');
  try
    Result := FromSQLiteBuffer(Buffer, Size);
  finally
    if Buffer <> nil then
      sqlite3_free(Buffer);
  end;
end;

class function TSQLiteChangeset.Concat(const First, Second: TSQLiteChangeset): TSQLiteChangeset;
var
  Size: Integer;
  Buffer: Pointer;
begin
  if First = nil then
    raise EArgumentNilException.Create('First');
  if Second = nil then
    raise EArgumentNilException.Create('Second');
  Size := 0;
  Buffer := nil;
  if sqlite3changeset_concat(First.Size, First.Data, Second.Size, Second.Data,
    Size, Buffer) <> SQLITE_OK then
    raise ESQLiteSessionError.Create('sqlite3changeset_concat failed');
  try
    Result := FromSQLiteBuffer(Buffer, Size);
  finally
    if Buffer <> nil then
      sqlite3_free(Buffer);
  end;
end;

class function TSQLiteChangeset.InvertStream(const Input: TxSessionInput;
  InputContext: Pointer; const Output: TxSessionOutput; OutputContext: Pointer): Integer;
begin
  Result := sqlite3changeset_invert_strm(Input, InputContext, Output, OutputContext);
end;

class function TSQLiteChangeset.ConcatStream(const InputA: TxSessionInput;
  InputAContext: Pointer; const InputB: TxSessionInput; InputBContext: Pointer;
  const Output: TxSessionOutput; OutputContext: Pointer): Integer;
begin
  Result := sqlite3changeset_concat_strm(InputA, InputAContext, InputB, InputBContext,
    Output, OutputContext);
end;

procedure TSQLiteSession.CheckCode(const Code: Integer; const Operation: string);
begin
  if Code <> SQLITE_OK then
    raise ESQLiteSessionError.CreateFmt('%s failed with SQLite code %d', [Operation, Code]);
end;

constructor TSQLiteSession.Create(const Database: Pointer; const Schema: string);
var
  SchemaUtf8: UTF8String;
begin
  inherited Create;
  if Database = nil then
    raise EArgumentNilException.Create('Database');
  FDatabase := Database;
  FHandle := nil;
  SchemaUtf8 := UTF8String(Schema);
  CheckCode(sqlite3session_create(FDatabase,
    MarshaledAString(PAnsiChar(SchemaUtf8)), FHandle), 'sqlite3session_create');
end;

destructor TSQLiteSession.Destroy;
begin
  if FHandle <> nil then
    sqlite3session_delete(FHandle);
  inherited Destroy;
end;

procedure TSQLiteSession.Attach(const TableName: string);
var
  TableUtf8: UTF8String;
  TablePtr: MarshaledAString;
begin
  if TableName = '' then
    TablePtr := nil
  else
  begin
    TableUtf8 := UTF8String(TableName);
    TablePtr := MarshaledAString(PAnsiChar(TableUtf8));
  end;
  CheckCode(sqlite3session_attach(FHandle, TablePtr), 'sqlite3session_attach');
end;

procedure TSQLiteSession.Enable(const Value: Boolean);
begin
  CheckCode(sqlite3session_enable(FHandle, Ord(Value)), 'sqlite3session_enable');
end;

procedure TSQLiteSession.SetIndirect(const Value: Boolean);
begin
  CheckCode(sqlite3session_indirect(FHandle, Ord(Value)), 'sqlite3session_indirect');
end;

function TSQLiteSession.ObjectConfig(const Operation, Value: Integer): Integer;
var
  Arg: Integer;
begin
  Arg := Value;
  Result := sqlite3session_object_config(FHandle, Operation, @Arg);
end;

class function TSQLiteSession.TableFilterCallback(Context: Pointer;
  TableName: MarshaledAString): Integer;
begin
  Result := 1;
  try
    if (Context <> nil) and Assigned(TSQLiteSession(Context).FTableFilter) then
      if not TSQLiteSession(Context).FTableFilter(UTF8ToString(PAnsiChar(TableName))) then
        Result := 0;
  except
    Result := 0;
  end;
end;

procedure TSQLiteSession.SetTableFilter(const Filter: TSQLiteSessionTableFilter);
begin
  FTableFilter := Filter;
  if Assigned(FTableFilter) then
    sqlite3session_table_filter(FHandle, @TableFilterCallback, Self)
  else
    sqlite3session_table_filter(FHandle, nil, nil);
end;

function TSQLiteSession.IsEnabled: Boolean;
begin
  Result := sqlite3session_enable(FHandle, -1) <> 0;
end;

function TSQLiteSession.IsIndirect: Boolean;
begin
  Result := sqlite3session_indirect(FHandle, -1) <> 0;
end;

function TSQLiteSession.IsEmpty: Boolean;
begin
  Result := sqlite3session_isempty(FHandle) <> 0;
end;

function TSQLiteSession.ChangesetSize: Int64;
begin
  Result := sqlite3session_changeset_size(FHandle);
end;

function TSQLiteSession.MemoryUsed: Int64;
begin
  Result := sqlite3session_memory_used(FHandle);
end;

function TSQLiteSession.Diff(const FromSchema, TableName: string): string;
var
  SchemaUtf8: UTF8String;
  TableUtf8: UTF8String;
  ErrorPtr: MarshaledAString;
  Code: Integer;
begin
  SchemaUtf8 := UTF8String(FromSchema);
  TableUtf8 := UTF8String(TableName);
  ErrorPtr := nil;
  Code := sqlite3session_diff(FHandle, MarshaledAString(PAnsiChar(SchemaUtf8)),
    MarshaledAString(PAnsiChar(TableUtf8)), ErrorPtr);
  Result := SQLiteErrorText(ErrorPtr);
  if Code <> SQLITE_OK then
    raise ESQLiteSessionError.CreateFmt('sqlite3session_diff failed with SQLite code %d: %s',
      [Code, Result]);
end;

function TSQLiteSession.CreateChangeset: TSQLiteChangeset;
var
  Size: Integer;
  Buffer: Pointer;
begin
  Size := 0;
  Buffer := nil;
  CheckCode(sqlite3session_changeset(FHandle, Size, Buffer), 'sqlite3session_changeset');
  try
    Result := TSQLiteChangeset.FromSQLiteBuffer(Buffer, Size);
  finally
    if Buffer <> nil then
      sqlite3_free(Buffer);
  end;
end;

function TSQLiteSession.CreatePatchset: TSQLiteChangeset;
var
  Size: Integer;
  Buffer: Pointer;
begin
  Size := 0;
  Buffer := nil;
  CheckCode(sqlite3session_patchset(FHandle, Size, Buffer), 'sqlite3session_patchset');
  try
    Result := TSQLiteChangeset.FromSQLiteBuffer(Buffer, Size);
  finally
    if Buffer <> nil then
      sqlite3_free(Buffer);
  end;
end;

function TSQLiteSession.CreateChangesetStream(const Output: TxSessionOutput;
  OutputContext: Pointer): Integer;
begin
  Result := sqlite3session_changeset_strm(FHandle, Output, OutputContext);
end;

function TSQLiteSession.CreatePatchsetStream(const Output: TxSessionOutput;
  OutputContext: Pointer): Integer;
begin
  Result := sqlite3session_patchset_strm(FHandle, Output, OutputContext);
end;

class function TSQLiteSession.ConflictCallback(Context: Pointer; Conflict: Integer;
  Iter: PSQLiteChangesetIter): Integer;
begin
  Result := NativeInt(Context);
end;

class function TSQLiteSession.Apply(const Database: Pointer;
  const Changeset: TSQLiteChangeset;
  const ConflictAction: TSQLiteSessionConflictAction): Integer;
var
  Action: Integer;
begin
  if Database = nil then
    raise EArgumentNilException.Create('Database');
  if Changeset = nil then
    raise EArgumentNilException.Create('Changeset');
  case ConflictAction of
    scaAbort: Action := SQLITE_CHANGESET_ABORT;
    scaReplace: Action := SQLITE_CHANGESET_REPLACE;
    scaOmit: Action := SQLITE_CHANGESET_OMIT;
  else
    Action := SQLITE_CHANGESET_ABORT;
  end;
  Result := sqlite3changeset_apply(Database, Changeset.Size, Changeset.Data,
    nil, @ConflictCallback, Pointer(NativeInt(Action)));
end;

class function TSQLiteSession.ApplyV2(const Database: Pointer;
  const Changeset: TSQLiteChangeset; const TableFilter: TxSessionTableFilter;
  const Conflict: TxSessionConflict; Context: Pointer; Flags: Integer;
  out RebaseData: TBytes): Integer;
var
  RebasePtr: Pointer;
  RebaseSize: Integer;
begin
  if Database = nil then
    raise EArgumentNilException.Create('Database');
  if Changeset = nil then
    raise EArgumentNilException.Create('Changeset');
  RebasePtr := nil;
  RebaseSize := 0;
  Result := sqlite3changeset_apply_v2(Database, Changeset.Size, Changeset.Data, TableFilter,
    Conflict, Context, RebasePtr, RebaseSize, Flags);
  try
    RebaseData := CopySQLiteBuffer(RebasePtr, RebaseSize);
  finally
    if RebasePtr <> nil then
      sqlite3_free(RebasePtr);
  end;
end;

class function TSQLiteSession.ApplyV3(const Database: Pointer;
  const Changeset: TSQLiteChangeset; const TableFilter: TxSessionChangesetFilterV3;
  const Conflict: TxSessionConflict; Context: Pointer; Flags: Integer;
  out RebaseData: TBytes): Integer;
var
  RebasePtr: Pointer;
  RebaseSize: Integer;
begin
  if Database = nil then
    raise EArgumentNilException.Create('Database');
  if Changeset = nil then
    raise EArgumentNilException.Create('Changeset');
  RebasePtr := nil;
  RebaseSize := 0;
  Result := sqlite3changeset_apply_v3(Database, Changeset.Size, Changeset.Data,
    TableFilter, Conflict, Context, RebasePtr, RebaseSize, Flags);
  try
    RebaseData := CopySQLiteBuffer(RebasePtr, RebaseSize);
  finally
    if RebasePtr <> nil then
      sqlite3_free(RebasePtr);
  end;
end;

class function TSQLiteSession.ApplyStream(const Database: Pointer; const Input: TxSessionInput;
  InputContext: Pointer; const TableFilter: TxSessionTableFilter;
  const Conflict: TxSessionConflict; Context: Pointer): Integer;
begin
  if Database = nil then
    raise EArgumentNilException.Create('Database');
  Result := sqlite3changeset_apply_strm(Database, Input, InputContext, TableFilter,
    Conflict, Context);
end;

class function TSQLiteSession.ApplyV2Stream(const Database: Pointer; const Input: TxSessionInput;
  InputContext: Pointer; const TableFilter: TxSessionTableFilter;
  const Conflict: TxSessionConflict; Context: Pointer; Flags: Integer;
  out RebaseData: TBytes): Integer;
var
  RebasePtr: Pointer;
  RebaseSize: Integer;
begin
  if Database = nil then
    raise EArgumentNilException.Create('Database');
  RebasePtr := nil;
  RebaseSize := 0;
  Result := sqlite3changeset_apply_v2_strm(Database, Input, InputContext, TableFilter,
    Conflict, Context, RebasePtr, RebaseSize, Flags);
  try
    RebaseData := CopySQLiteBuffer(RebasePtr, RebaseSize);
  finally
    if RebasePtr <> nil then
      sqlite3_free(RebasePtr);
  end;
end;

class function TSQLiteSession.ApplyV3Stream(const Database: Pointer; const Input: TxSessionInput;
  InputContext: Pointer; const TableFilter: TxSessionChangesetFilterV3;
  const Conflict: TxSessionConflict; Context: Pointer; Flags: Integer;
  out RebaseData: TBytes): Integer;
var
  RebasePtr: Pointer;
  RebaseSize: Integer;
begin
  if Database = nil then
    raise EArgumentNilException.Create('Database');
  RebasePtr := nil;
  RebaseSize := 0;
  Result := sqlite3changeset_apply_v3_strm(Database, Input, InputContext, TableFilter,
    Conflict, Context, RebasePtr, RebaseSize, Flags);
  try
    RebaseData := CopySQLiteBuffer(RebasePtr, RebaseSize);
  finally
    if RebasePtr <> nil then
      sqlite3_free(RebasePtr);
  end;
end;

class function TSQLiteSession.ConfigureStreamSize(const Value: Integer): Integer;
var
  Arg: Integer;
begin
  Arg := Value;
  Result := sqlite3session_config(SQLITE_SESSION_CONFIG_STRMSIZE, @Arg);
end;

constructor TSQLiteChangesetIterator.Create(const Changeset: TSQLiteChangeset);
begin
  inherited Create;
  if Changeset = nil then
    raise EArgumentNilException.Create('Changeset');
  FChangeset := Changeset;
  FHandle := nil;
  if sqlite3changeset_start(FHandle, Changeset.Size, Changeset.Data) <> SQLITE_OK then
    raise ESQLiteSessionError.Create('sqlite3changeset_start failed');
end;

constructor TSQLiteChangesetIterator.CreateStream(const Input: TxSessionInput;
  InputContext: Pointer);
begin
  inherited Create;
  FChangeset := nil;
  FHandle := nil;
  if sqlite3changeset_start_strm(FHandle, Input, InputContext) <> SQLITE_OK then
    raise ESQLiteSessionError.Create('sqlite3changeset_start_strm failed');
end;

constructor TSQLiteChangesetIterator.CreateV2(const Changeset: TSQLiteChangeset;
  const Flags: Integer);
begin
  inherited Create;
  if Changeset = nil then
    raise EArgumentNilException.Create('Changeset');
  FChangeset := Changeset;
  FHandle := nil;
  if sqlite3changeset_start_v2(FHandle, Changeset.Size, Changeset.Data, Flags) <> SQLITE_OK then
    raise ESQLiteSessionError.Create('sqlite3changeset_start_v2 failed');
end;

constructor TSQLiteChangesetIterator.CreateStreamV2(const Input: TxSessionInput;
  InputContext: Pointer; const Flags: Integer);
begin
  inherited Create;
  FChangeset := nil;
  FHandle := nil;
  if sqlite3changeset_start_v2_strm(FHandle, Input, InputContext, Flags) <> SQLITE_OK then
    raise ESQLiteSessionError.Create('sqlite3changeset_start_v2_strm failed');
end;

destructor TSQLiteChangesetIterator.Destroy;
begin
  if FHandle <> nil then
    sqlite3changeset_finalize(FHandle);
  inherited Destroy;
end;

function TSQLiteChangesetIterator.Next: Boolean;
var
  TableNamePtr: MarshaledAString;
  Indirect: Integer;
begin
  Result := sqlite3changeset_next(FHandle) = SQLITE_ROW;
  if not Result then
    Exit;
  TableNamePtr := nil;
  FColumnCount := 0;
  FOperation := 0;
  Indirect := 0;
  if sqlite3changeset_op(FHandle, TableNamePtr, FColumnCount, FOperation,
    Indirect) <> SQLITE_OK then
    raise ESQLiteSessionError.Create('sqlite3changeset_op failed');
  FIndirect := Indirect <> 0;
  FTableName := UTF8ToString(PAnsiChar(TableNamePtr));
end;

function TSQLiteChangesetIterator.PrimaryKeys: TBytes;
var
  Bitmap: PByte;
  Count: Integer;
begin
  Bitmap := nil;
  Count := 0;
  if sqlite3changeset_pk(FHandle, Bitmap, Count) <> SQLITE_OK then
    raise ESQLiteSessionError.Create('sqlite3changeset_pk failed');
  Result := CopySQLiteBuffer(Bitmap, Count);
end;

function TSQLiteChangesetIterator.OldValue(const Index: Integer): PSQLiteValue;
begin
  Result := nil;
  if sqlite3changeset_old(FHandle, Index, Result) <> SQLITE_OK then
    raise ESQLiteSessionError.Create('sqlite3changeset_old failed');
end;

function TSQLiteChangesetIterator.NewValue(const Index: Integer): PSQLiteValue;
begin
  Result := nil;
  if sqlite3changeset_new(FHandle, Index, Result) <> SQLITE_OK then
    raise ESQLiteSessionError.Create('sqlite3changeset_new failed');
end;

function TSQLiteChangesetIterator.ConflictValue(const Index: Integer): PSQLiteValue;
begin
  Result := nil;
  if sqlite3changeset_conflict(FHandle, Index, Result) <> SQLITE_OK then
    raise ESQLiteSessionError.Create('sqlite3changeset_conflict failed');
end;

function TSQLiteChangesetIterator.ForeignKeyConflicts: Integer;
begin
  Result := 0;
  if sqlite3changeset_fk_conflicts(FHandle, Result) <> SQLITE_OK then
    raise ESQLiteSessionError.Create('sqlite3changeset_fk_conflicts failed');
end;

procedure TSQLiteChangegroup.CheckCode(const Code: Integer; const Operation: string);
begin
  if Code <> SQLITE_OK then
    raise ESQLiteSessionError.CreateFmt('%s failed with SQLite code %d', [Operation, Code]);
end;

constructor TSQLiteChangegroup.Create;
begin
  inherited Create;
  FHandle := nil;
  CheckCode(sqlite3changegroup_new(FHandle), 'sqlite3changegroup_new');
end;

destructor TSQLiteChangegroup.Destroy;
begin
  if FHandle <> nil then
    sqlite3changegroup_delete(FHandle);
  inherited Destroy;
end;

procedure TSQLiteChangegroup.ConfigurePatchset(const Value: Boolean);
var
  Patchset: Integer;
begin
  Patchset := Ord(Value);
  CheckCode(sqlite3changegroup_config(FHandle, SQLITE_CHANGEGROUP_CONFIG_PATCHSET,
    @Patchset), 'sqlite3changegroup_config');
end;

function TSQLiteChangegroup.Schema(const Database: Pointer; const SchemaName: string): Integer;
var
  SchemaUtf8: UTF8String;
begin
  SchemaUtf8 := UTF8String(SchemaName);
  Result := sqlite3changegroup_schema(FHandle, Database,
    MarshaledAString(PAnsiChar(SchemaUtf8)));
end;

procedure TSQLiteChangegroup.Add(const Changeset: TSQLiteChangeset);
begin
  if Changeset = nil then
    raise EArgumentNilException.Create('Changeset');
  CheckCode(sqlite3changegroup_add(FHandle, Changeset.Size, Changeset.Data),
    'sqlite3changegroup_add');
end;

function TSQLiteChangegroup.Output: TSQLiteChangeset;
var
  Size: Integer;
  Buffer: Pointer;
begin
  Size := 0;
  Buffer := nil;
  CheckCode(sqlite3changegroup_output(FHandle, Size, Buffer), 'sqlite3changegroup_output');
  try
    Result := TSQLiteChangeset.FromSQLiteBuffer(Buffer, Size);
  finally
    if Buffer <> nil then
      sqlite3_free(Buffer);
  end;
end;

function TSQLiteChangegroup.AddStream(const Input: TxSessionInput;
  InputContext: Pointer): Integer;
begin
  Result := sqlite3changegroup_add_strm(FHandle, Input, InputContext);
end;

function TSQLiteChangegroup.OutputStream(const Output: TxSessionOutput;
  OutputContext: Pointer): Integer;
begin
  Result := sqlite3changegroup_output_strm(FHandle, Output, OutputContext);
end;

function TSQLiteChangegroup.AddChange(const Change: TBytes): Integer;
var
  DataPtr: Pointer;
begin
  if Length(Change) = 0 then
    DataPtr := nil
  else
    DataPtr := @Change[0];
  Result := sqlite3changegroup_add_change(FHandle, Length(Change), DataPtr);
end;

function TSQLiteChangegroup.BeginChange(const Operation: Integer; const TableName: string;
  const Indirect: Boolean; out ErrorMessage: string): Integer;
var
  TableUtf8: UTF8String;
  ErrorPtr: MarshaledAString;
begin
  TableUtf8 := UTF8String(TableName);
  ErrorPtr := nil;
  Result := sqlite3changegroup_change_begin(FHandle, Operation,
    MarshaledAString(PAnsiChar(TableUtf8)), Ord(Indirect), ErrorPtr);
  ErrorMessage := SQLiteErrorText(ErrorPtr);
end;

function TSQLiteChangegroup.ChangeInt64(const IsNew, Column: Integer;
  const Value: Int64): Integer;
begin
  Result := sqlite3changegroup_change_int64(FHandle, IsNew, Column, Value);
end;

function TSQLiteChangegroup.ChangeNull(const IsNew, Column: Integer): Integer;
begin
  Result := sqlite3changegroup_change_null(FHandle, IsNew, Column);
end;

function TSQLiteChangegroup.ChangeDouble(const IsNew, Column: Integer;
  const Value: Double): Integer;
begin
  Result := sqlite3changegroup_change_double(FHandle, IsNew, Column, Value);
end;

function TSQLiteChangegroup.ChangeText(const IsNew, Column: Integer;
  const Value: string): Integer;
var
  ValueUtf8: UTF8String;
begin
  ValueUtf8 := UTF8String(Value);
  Result := sqlite3changegroup_change_text(FHandle, IsNew, Column,
    MarshaledAString(PAnsiChar(ValueUtf8)), Length(ValueUtf8));
end;

function TSQLiteChangegroup.ChangeBlob(const IsNew, Column: Integer;
  const Value: TBytes): Integer;
var
  DataPtr: Pointer;
begin
  if Length(Value) = 0 then
    DataPtr := nil
  else
    DataPtr := @Value[0];
  Result := sqlite3changegroup_change_blob(FHandle, IsNew, Column, DataPtr, Length(Value));
end;

function TSQLiteChangegroup.FinishChange(const Discard: Boolean;
  out ErrorMessage: string): Integer;
var
  ErrorPtr: MarshaledAString;
begin
  ErrorPtr := nil;
  Result := sqlite3changegroup_change_finish(FHandle, Ord(Discard), ErrorPtr);
  ErrorMessage := SQLiteErrorText(ErrorPtr);
end;

procedure TSQLiteRebaser.CheckCode(const Code: Integer; const Operation: string);
begin
  if Code <> SQLITE_OK then
    raise ESQLiteSessionError.CreateFmt('%s failed with SQLite code %d', [Operation, Code]);
end;

constructor TSQLiteRebaser.Create(const RebaseData: TBytes);
var
  RebasePtr: Pointer;
begin
  inherited Create;
  FHandle := nil;
  CheckCode(sqlite3rebaser_create(FHandle), 'sqlite3rebaser_create');
  if Length(RebaseData) = 0 then
    RebasePtr := nil
  else
    RebasePtr := @RebaseData[0];
  CheckCode(sqlite3rebaser_configure(FHandle, Length(RebaseData), RebasePtr),
    'sqlite3rebaser_configure');
end;

destructor TSQLiteRebaser.Destroy;
begin
  if FHandle <> nil then
    sqlite3rebaser_delete(FHandle);
  inherited Destroy;
end;

function TSQLiteRebaser.Rebase(const Changeset: TSQLiteChangeset): TSQLiteChangeset;
var
  Size: Integer;
  Buffer: Pointer;
begin
  if Changeset = nil then
    raise EArgumentNilException.Create('Changeset');
  Size := 0;
  Buffer := nil;
  CheckCode(sqlite3rebaser_rebase(FHandle, Changeset.Size, Changeset.Data, Size, Buffer),
    'sqlite3rebaser_rebase');
  try
    Result := TSQLiteChangeset.FromSQLiteBuffer(Buffer, Size);
  finally
    if Buffer <> nil then
      sqlite3_free(Buffer);
  end;
end;

function TSQLiteRebaser.RebaseStream(const Input: TxSessionInput; InputContext: Pointer;
  const Output: TxSessionOutput; OutputContext: Pointer): Integer;
begin
  Result := sqlite3rebaser_rebase_strm(FHandle, Input, InputContext, Output, OutputContext);
end;

end.
