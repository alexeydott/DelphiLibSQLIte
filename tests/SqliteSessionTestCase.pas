unit SqliteSessionTestCase;

interface

uses
  System.SysUtils,
  System.IOUtils,
  TestFramework,
  sqlite3.common,
  sqlite3.static,
  sqlite.session;

type
  TSessionStreamContext = record
    Data: TBytes;
    Offset: Integer;
  end;

  TSqliteSessionTests = class(TTestCase)
  private
    procedure ExecSql(const Database: Pointer; const SQL: string);
    function OpenMemory: Pointer;
    function OpenFile(const FileName: string; const Flags: Integer): Pointer;
    procedure CloseDatabase(var Database: Pointer);
    function FilterItems(const TableName: string): Boolean;
    function FilterPoints(const TableName: string): Boolean;
    function QueryScalarInt64(const Database: Pointer; const SQL: string): Int64;
    function QueryScalarText(const Database: Pointer; const SQL: string): string;
    procedure CopyTestDatabase(const SourceFile, TargetFile: string);
    class function StreamInput(Context, Data: Pointer; DataSize: PInteger): Integer; cdecl; static;
    class function StreamOutput(Context, Data: Pointer; DataSize: Integer): Integer; cdecl; static;
    class function StreamFilterV3(Context: Pointer; Iter: PSQLiteChangesetIter): Integer; cdecl; static;
  published
    procedure SessionAbiExportsAreLinked;
    procedure CaptureIterateAndApplyChangeset;
    procedure SessionFacadeSupportsFiltersValuesAndRebase;
    procedure RealDatabaseSessionApplyFilterMergeAndRollback;
    procedure StreamingSessionFacade;
  end;

implementation

procedure TSqliteSessionTests.SessionAbiExportsAreLinked;
begin
  CheckTrue(@sqlite3session_create <> nil, 'sqlite3session_create is not linked');
  CheckTrue(@sqlite3session_delete <> nil, 'sqlite3session_delete is not linked');
  CheckTrue(@sqlite3session_object_config <> nil, 'sqlite3session_object_config is not linked');
  CheckTrue(@sqlite3session_enable <> nil, 'sqlite3session_enable is not linked');
  CheckTrue(@sqlite3session_indirect <> nil, 'sqlite3session_indirect is not linked');
  CheckTrue(@sqlite3session_attach <> nil, 'sqlite3session_attach is not linked');
  CheckTrue(@sqlite3session_table_filter <> nil, 'sqlite3session_table_filter is not linked');
  CheckTrue(@sqlite3session_changeset <> nil, 'sqlite3session_changeset is not linked');
  CheckTrue(@sqlite3session_changeset_size <> nil, 'sqlite3session_changeset_size is not linked');
  CheckTrue(@sqlite3session_diff <> nil, 'sqlite3session_diff is not linked');
  CheckTrue(@sqlite3session_patchset <> nil, 'sqlite3session_patchset is not linked');
  CheckTrue(@sqlite3session_isempty <> nil, 'sqlite3session_isempty is not linked');
  CheckTrue(@sqlite3session_memory_used <> nil, 'sqlite3session_memory_used is not linked');
  CheckTrue(@sqlite3changeset_start <> nil, 'sqlite3changeset_start is not linked');
  CheckTrue(@sqlite3changeset_start_v2 <> nil, 'sqlite3changeset_start_v2 is not linked');
  CheckTrue(@sqlite3changeset_next <> nil, 'sqlite3changeset_next is not linked');
  CheckTrue(@sqlite3changeset_op <> nil, 'sqlite3changeset_op is not linked');
  CheckTrue(@sqlite3changeset_pk <> nil, 'sqlite3changeset_pk is not linked');
  CheckTrue(@sqlite3changeset_old <> nil, 'sqlite3changeset_old is not linked');
  CheckTrue(@sqlite3changeset_new <> nil, 'sqlite3changeset_new is not linked');
  CheckTrue(@sqlite3changeset_conflict <> nil, 'sqlite3changeset_conflict is not linked');
  CheckTrue(@sqlite3changeset_fk_conflicts <> nil, 'sqlite3changeset_fk_conflicts is not linked');
  CheckTrue(@sqlite3changeset_finalize <> nil, 'sqlite3changeset_finalize is not linked');
  CheckTrue(@sqlite3changeset_invert <> nil, 'sqlite3changeset_invert is not linked');
  CheckTrue(@sqlite3changeset_concat <> nil, 'sqlite3changeset_concat is not linked');
  CheckTrue(@sqlite3changeset_apply <> nil, 'sqlite3changeset_apply is not linked');
  CheckTrue(@sqlite3changeset_apply_v2 <> nil, 'sqlite3changeset_apply_v2 is not linked');
  CheckTrue(@sqlite3changeset_apply_v3 <> nil, 'sqlite3changeset_apply_v3 is not linked');
  CheckTrue(@sqlite3changegroup_new <> nil, 'sqlite3changegroup_new is not linked');
  CheckTrue(@sqlite3changegroup_schema <> nil, 'sqlite3changegroup_schema is not linked');
  CheckTrue(@sqlite3changegroup_add <> nil, 'sqlite3changegroup_add is not linked');
  CheckTrue(@sqlite3changegroup_add_change <> nil, 'sqlite3changegroup_add_change is not linked');
  CheckTrue(@sqlite3changegroup_output <> nil, 'sqlite3changegroup_output is not linked');
  CheckTrue(@sqlite3changegroup_delete <> nil, 'sqlite3changegroup_delete is not linked');
  CheckTrue(@sqlite3changegroup_config <> nil, 'sqlite3changegroup_config is not linked');
  CheckTrue(@sqlite3changegroup_change_begin <> nil, 'sqlite3changegroup_change_begin is not linked');
  CheckTrue(@sqlite3changegroup_change_int64 <> nil, 'sqlite3changegroup_change_int64 is not linked');
  CheckTrue(@sqlite3changegroup_change_null <> nil, 'sqlite3changegroup_change_null is not linked');
  CheckTrue(@sqlite3changegroup_change_double <> nil, 'sqlite3changegroup_change_double is not linked');
  CheckTrue(@sqlite3changegroup_change_text <> nil, 'sqlite3changegroup_change_text is not linked');
  CheckTrue(@sqlite3changegroup_change_blob <> nil, 'sqlite3changegroup_change_blob is not linked');
  CheckTrue(@sqlite3changegroup_change_finish <> nil, 'sqlite3changegroup_change_finish is not linked');
  CheckTrue(@sqlite3rebaser_create <> nil, 'sqlite3rebaser_create is not linked');
  CheckTrue(@sqlite3rebaser_configure <> nil, 'sqlite3rebaser_configure is not linked');
  CheckTrue(@sqlite3rebaser_rebase <> nil, 'sqlite3rebaser_rebase is not linked');
  CheckTrue(@sqlite3rebaser_delete <> nil, 'sqlite3rebaser_delete is not linked');
  CheckTrue(@sqlite3session_config <> nil, 'sqlite3session_config is not linked');
  CheckTrue(@sqlite3session_changeset_strm <> nil, 'sqlite3session_changeset_strm is not linked');
  CheckTrue(@sqlite3session_patchset_strm <> nil, 'sqlite3session_patchset_strm is not linked');
  CheckTrue(@sqlite3changeset_start_strm <> nil, 'sqlite3changeset_start_strm is not linked');
  CheckTrue(@sqlite3changeset_start_v2_strm <> nil, 'sqlite3changeset_start_v2_strm is not linked');
  CheckTrue(@sqlite3changeset_apply_strm <> nil, 'sqlite3changeset_apply_strm is not linked');
  CheckTrue(@sqlite3changeset_apply_v2_strm <> nil, 'sqlite3changeset_apply_v2_strm is not linked');
  CheckTrue(@sqlite3changeset_apply_v3_strm <> nil, 'sqlite3changeset_apply_v3_strm is not linked');
  CheckTrue(@sqlite3changeset_concat_strm <> nil, 'sqlite3changeset_concat_strm is not linked');
  CheckTrue(@sqlite3changeset_invert_strm <> nil, 'sqlite3changeset_invert_strm is not linked');
  CheckTrue(@sqlite3changegroup_add_strm <> nil, 'sqlite3changegroup_add_strm is not linked');
  CheckTrue(@sqlite3changegroup_output_strm <> nil, 'sqlite3changegroup_output_strm is not linked');
  CheckTrue(@sqlite3rebaser_rebase_strm <> nil, 'sqlite3rebaser_rebase_strm is not linked');
end;

procedure TSqliteSessionTests.ExecSql(const Database: Pointer; const SQL: string);
var
  SQLUtf8: UTF8String;
begin
  SQLUtf8 := UTF8String(SQL);
  CheckEquals(SQLITE_OK, sqlite3_exec_simple(Database, SQL), 'SQL failed: ' + SQL);
end;

function TSqliteSessionTests.OpenMemory: Pointer;
begin
  Result := nil;
  CheckEquals(SQLITE_OK, sqlite3_open_v2(MarshaledAString(PAnsiChar(UTF8String(':memory:'))),
    Result, SQLITE_OPEN_READWRITE or SQLITE_OPEN_CREATE or SQLITE_OPEN_MEMORY, nil),
    'sqlite3_open_v2');
end;

function TSqliteSessionTests.OpenFile(const FileName: string; const Flags: Integer): Pointer;
var
  FileNameUtf8: UTF8String;
begin
  Result := nil;
  FileNameUtf8 := UTF8String(FileName);
  CheckEquals(SQLITE_OK, sqlite3_open_v2(MarshaledAString(PAnsiChar(FileNameUtf8)),
    Result, Flags, nil), 'sqlite3_open_v2 file');
end;

procedure TSqliteSessionTests.CloseDatabase(var Database: Pointer);
begin
  if Database <> nil then
  begin
    CheckEquals(SQLITE_OK, sqlite3_close_v2(Database), 'sqlite3_close_v2');
    Database := nil;
  end;
end;

function TSqliteSessionTests.FilterItems(const TableName: string): Boolean;
begin
  Result := SameText(TableName, 'items');
end;

function TSqliteSessionTests.FilterPoints(const TableName: string): Boolean;
begin
  Result := SameText(TableName, 'points');
end;

function TSqliteSessionTests.QueryScalarInt64(const Database: Pointer;
  const SQL: string): Int64;
var
  Statement: Pointer;
begin
  Statement := nil;
  CheckEquals(SQLITE_OK, sqlite3_prepare_v2(Database,
    MarshaledAString(PAnsiChar(UTF8String(SQL))), -1, Statement, nil),
    'prepare scalar integer query');
  try
    CheckEquals(SQLITE_ROW, sqlite3_step(Statement), 'scalar integer query returned no row');
    Result := sqlite3_column_int64(Statement, 0);
  finally
    sqlite3_finalize(Statement);
  end;
end;

function TSqliteSessionTests.QueryScalarText(const Database: Pointer;
  const SQL: string): string;
var
  Statement: Pointer;
begin
  Statement := nil;
  CheckEquals(SQLITE_OK, sqlite3_prepare_v2(Database,
    MarshaledAString(PAnsiChar(UTF8String(SQL))), -1, Statement, nil),
    'prepare scalar text query');
  try
    CheckEquals(SQLITE_ROW, sqlite3_step(Statement), 'scalar text query returned no row');
    Result := UTF8ToString(sqlite3_column_text(Statement, 0));
  finally
    sqlite3_finalize(Statement);
  end;
end;

procedure TSqliteSessionTests.CopyTestDatabase(const SourceFile, TargetFile: string);
begin
  CheckTrue(TFile.Exists(SourceFile), 'source test database is missing: ' + SourceFile);
  if TFile.Exists(TargetFile) then
    TFile.Delete(TargetFile);
  TFile.Copy(SourceFile, TargetFile, True);
  CheckTrue(TFile.Exists(TargetFile), 'test database copy was not created');
  CheckEquals(TFile.GetSize(SourceFile), TFile.GetSize(TargetFile),
    'test database copy size mismatch');
end;

class function TSqliteSessionTests.StreamInput(Context, Data: Pointer;
  DataSize: PInteger): Integer;
var
  State: ^TSessionStreamContext;
  Available: Integer;
begin
  State := Context;
  if (State = nil) or (DataSize = nil) then
    Exit(SQLITE_ERROR);
  Available := Length(State^.Data) - State^.Offset;
  if Available < 0 then
    Available := 0;
  if Available > 1024 then
    Available := 1024;
  DataSize^ := Available;
  if (Available > 0) and (Data <> nil) then
    Move(State^.Data[State^.Offset], Data^, Available);
  Inc(State^.Offset, Available);
  Result := SQLITE_OK;
end;

class function TSqliteSessionTests.StreamOutput(Context, Data: Pointer;
  DataSize: Integer): Integer;
var
  State: ^TSessionStreamContext;
  OldLength: Integer;
begin
  State := Context;
  if (State = nil) or (DataSize < 0) then
    Exit(SQLITE_ERROR);
  OldLength := Length(State^.Data);
  SetLength(State^.Data, OldLength + DataSize);
  if (DataSize > 0) and (Data <> nil) then
    Move(Data^, State^.Data[OldLength], DataSize);
  Result := SQLITE_OK;
end;

class function TSqliteSessionTests.StreamFilterV3(Context: Pointer;
  Iter: PSQLiteChangesetIter): Integer;
begin
  Result := 1;
end;

procedure TSqliteSessionTests.CaptureIterateAndApplyChangeset;
var
  Source: Pointer;
  Target: Pointer;
  Session: TSQLiteSession;
  Changeset: TSQLiteChangeset;
  Inverted: TSQLiteChangeset;
  Combined: TSQLiteChangeset;
  Grouped: TSQLiteChangeset;
  Group: TSQLiteChangegroup;
  Iterator: TSQLiteChangesetIterator;
  ChangeCount: Integer;
  Statement: Pointer;
begin
  CheckEquals(SQLITE_OK, sqlite3_initialize, 'sqlite3_initialize');
  Source := OpenMemory;
  Target := OpenMemory;
  try
    ExecSql(Source, 'create table items(id integer primary key, value text);');
    ExecSql(Target, 'create table items(id integer primary key, value text);');
    ExecSql(Source, 'insert into items(id, value) values(1, ''before'');');
    ExecSql(Target, 'insert into items(id, value) values(1, ''before'');');

    Session := TSQLiteSession.Create(Source);
    try
      Session.Attach;
      CheckTrue(Session.IsEnabled, 'session must be enabled after construction');
      ExecSql(Source, 'insert into items(id, value) values(2, ''inserted'');');
      ExecSql(Source, 'update items set value = ''updated'' where id = 1;');
      Changeset := Session.CreateChangeset;
      try
        CheckTrue(not Changeset.IsEmpty, 'changeset must contain captured changes');
        Inverted := TSQLiteChangeset.Invert(Changeset);
        try
          CheckTrue(not Inverted.IsEmpty, 'inverted changeset must not be empty');
          Combined := TSQLiteChangeset.Concat(Changeset, Inverted);
          try
            CheckTrue(Combined.IsEmpty,
              'a changeset concatenated with its inverse must be empty');
          finally
            Combined.Free;
          end;
        finally
          Inverted.Free;
        end;
        Group := TSQLiteChangegroup.Create;
        try
          Group.Add(Changeset);
          Grouped := Group.Output;
          try
            CheckTrue(not Grouped.IsEmpty, 'changegroup output must not be empty');
          finally
            Grouped.Free;
          end;
        finally
          Group.Free;
        end;
        Iterator := TSQLiteChangesetIterator.Create(Changeset);
        try
          ChangeCount := 0;
          while Iterator.Next do
            Inc(ChangeCount);
          CheckEquals(2, ChangeCount, 'unexpected changeset operation count');
        finally
          Iterator.Free;
        end;
        CheckEquals(SQLITE_OK, TSQLiteSession.Apply(Target, Changeset),
          'changeset apply failed');
      finally
        Changeset.Free;
      end;
    finally
      Session.Free;
    end;

    Statement := nil;
    CheckEquals(SQLITE_OK, sqlite3_prepare_v2(Target,
      MarshaledAString(PAnsiChar(UTF8String('select value from items where id = 1;'))),
      -1, Statement, nil), 'prepare verification query');
    try
      CheckEquals(SQLITE_ROW, sqlite3_step(Statement), 'verification query returned no row');
      CheckEquals('updated', UTF8ToString(sqlite3_column_text(Statement, 0)),
        'updated value mismatch');
    finally
      sqlite3_finalize(Statement);
    end;
  finally
    CloseDatabase(Target);
    CloseDatabase(Source);
    CheckEquals(SQLITE_OK, sqlite3_shutdown, 'sqlite3_shutdown');
  end;
end;

procedure TSqliteSessionTests.SessionFacadeSupportsFiltersValuesAndRebase;
var
  Source: Pointer;
  Target: Pointer;
  Session: TSQLiteSession;
  Changeset: TSQLiteChangeset;
  Iterator: TSQLiteChangesetIterator;
  RebaseData: TBytes;
  Group: TSQLiteChangegroup;
  Grouped: TSQLiteChangeset;
  Patchset: TSQLiteChangeset;
  PatchGroup: TSQLiteChangegroup;
  PatchGrouped: TSQLiteChangeset;
  BlobData: TBytes;
  ErrorMessage: string;
  Seen: Integer;
begin
  CheckEquals(SQLITE_OK, sqlite3_initialize, 'sqlite3_initialize');
  Source := OpenMemory;
  Target := OpenMemory;
  Patchset := nil;
  PatchGrouped := nil;
  BlobData := TBytes.Create(1, 2, 3, 4);
  try
    ExecSql(Source, 'create table items(id integer primary key, value text);');
    ExecSql(Source, 'create table ignored(id integer primary key, value text);');
    ExecSql(Source, 'create table builder(id integer primary key, txt text, real_value real, nullable text, payload blob);');
    ExecSql(Target, 'create table items(id integer primary key, value text);');
    ExecSql(Target, 'create table ignored(id integer primary key, value text);');
    ExecSql(Target, 'create table builder(id integer primary key, txt text, real_value real, nullable text, payload blob);');

    Session := TSQLiteSession.Create(Source);
    try
      CheckEquals(SQLITE_OK, Session.ObjectConfig(SQLITE_SESSION_OBJCONFIG_SIZE, 1),
        'object size config');
      CheckTrue(Session.MemoryUsed >= 0, 'session memory must be queryable');
      Session.SetTableFilter(FilterItems);
      Session.Attach;
      ExecSql(Source, 'insert into items(id, value) values(1, ''captured'');');
      ExecSql(Source, 'insert into ignored(id, value) values(1, ''filtered'');');
      CheckTrue(Session.ChangesetSize > 0, 'changeset size must grow after a write');
      Changeset := Session.CreateChangeset;
      try
        Iterator := TSQLiteChangesetIterator.Create(Changeset);
        try
          Seen := 0;
          while Iterator.Next do
          begin
            Inc(Seen);
            CheckEquals('items', Iterator.TableName, 'table filter leaked another table');
            CheckEquals(2, Iterator.ColumnCount, 'unexpected column count');
            CheckEquals(SQLITE_INSERT, Iterator.Operation, 'unexpected operation');
            CheckTrue(Length(Iterator.PrimaryKeys) >= 1, 'primary key bitmap missing');
            CheckTrue(Iterator.NewValue(0) <> nil, 'new primary-key value missing');
            CheckTrue(Iterator.NewValue(1) <> nil, 'new text value missing');
          end;
          CheckEquals(1, Seen, 'filtered changeset operation count');
        finally
          Iterator.Free;
        end;

        CheckEquals(SQLITE_OK, TSQLiteSession.ApplyV2(Target, Changeset, nil, nil, nil,
          0, RebaseData), 'v2 changeset apply failed');
        CheckEquals(0, Length(RebaseData), 'unexpected rebase data without conflict');

        Patchset := Session.CreatePatchset;
        PatchGroup := TSQLiteChangegroup.Create;
        try
          PatchGroup.ConfigurePatchset(True);
          PatchGroup.Add(Patchset);
          PatchGrouped := PatchGroup.Output;
          CheckTrue(not PatchGrouped.IsEmpty, 'patchset changegroup output is empty');
        finally
          PatchGroup.Free;
        end;
      finally
        Changeset.Free;
        Patchset.Free;
        PatchGrouped.Free;
      end;
    finally
      Session.Free;
    end;

    Group := TSQLiteChangegroup.Create;
    try
      CheckEquals(SQLITE_OK, Group.Schema(Target), 'changegroup schema failed');
      CheckEquals(SQLITE_OK, Group.BeginChange(SQLITE_INSERT, 'items', False, ErrorMessage),
        'changegroup begin failed: ' + ErrorMessage);
      CheckEquals(SQLITE_OK, Group.ChangeInt64(1, 0, 2), 'changegroup integer failed');
      CheckEquals(SQLITE_OK, Group.ChangeText(1, 1, 'built'), 'changegroup text failed');
      CheckEquals(SQLITE_OK, Group.FinishChange(False, ErrorMessage),
        'changegroup finish failed: ' + ErrorMessage);
      Grouped := Group.Output;
      try
        CheckTrue(not Grouped.IsEmpty, 'manual changegroup output must not be empty');
      finally
        Grouped.Free;
      end;

      CheckEquals(SQLITE_OK, Group.BeginChange(SQLITE_INSERT, 'builder', False, ErrorMessage),
        'builder changegroup begin failed: ' + ErrorMessage);
      CheckEquals(SQLITE_OK, Group.ChangeInt64(1, 0, 3), 'builder integer failed');
      CheckEquals(SQLITE_OK, Group.ChangeText(1, 1, 'text'), 'builder text failed');
      CheckEquals(SQLITE_OK, Group.ChangeDouble(1, 2, 1.25), 'builder double failed');
      CheckEquals(SQLITE_OK, Group.ChangeNull(1, 3), 'builder null failed');
      CheckEquals(SQLITE_OK, Group.ChangeBlob(1, 4, BlobData), 'builder blob failed');
      CheckEquals(SQLITE_OK, Group.FinishChange(False, ErrorMessage),
        'builder changegroup finish failed: ' + ErrorMessage);
      Grouped := Group.Output;
      try
        CheckTrue(not Grouped.IsEmpty, 'builder changegroup output must not be empty');
      finally
        Grouped.Free;
      end;
    finally
      Group.Free;
    end;
  finally
    CloseDatabase(Target);
    CloseDatabase(Source);
    CheckEquals(SQLITE_OK, sqlite3_shutdown, 'sqlite3_shutdown');
  end;
end;

procedure TSqliteSessionTests.RealDatabaseSessionApplyFilterMergeAndRollback;
const
  PointId1 = 1;
  PointId2 = 2;
var
  SourceFile: string;
  FirstFile: string;
  SecondFile: string;
  Source: Pointer;
  Target: Pointer;
  Session: TSQLiteSession;
  Changeset1: TSQLiteChangeset;
  Changeset2: TSQLiteChangeset;
  Combined: TSQLiteChangeset;
  Grouped: TSQLiteChangeset;
  Inverted: TSQLiteChangeset;
  Group: TSQLiteChangegroup;
  OriginalPoint1: string;
  OriginalPoint2: string;
  OriginalLine1: string;
  BaselinePointCount: Int64;
  BaselineLineCount: Int64;
begin
  SourceFile := TPath.GetFullPath(TPath.Combine(ExtractFileDir(ParamStr(0)),
    '..\..\..\data\perm_krai.sqlite'));
  if not TFile.Exists(SourceFile) then
  begin
    Status('Skipped: test data is not available: ' + SourceFile);
    Exit;
  end;
  FirstFile := TPath.GetTempFileName;
  SecondFile := TPath.GetTempFileName;
  TFile.Delete(FirstFile);
  TFile.Delete(SecondFile);
  Source := nil;
  Target := nil;
  Changeset1 := nil;
  Changeset2 := nil;
  Grouped := nil;
  try
    CopyTestDatabase(SourceFile, FirstFile);
    CopyTestDatabase(SourceFile, SecondFile);
    CheckEquals(TFile.GetSize(FirstFile), TFile.GetSize(SecondFile),
      'source and target database sizes differ');

    CheckEquals(SQLITE_OK, sqlite3_initialize, 'sqlite3_initialize');
    Source := OpenFile(FirstFile, SQLITE_OPEN_READWRITE or SQLITE_OPEN_FULLMUTEX);
    Target := OpenFile(SecondFile, SQLITE_OPEN_READWRITE or SQLITE_OPEN_FULLMUTEX);
    OriginalPoint1 := QueryScalarText(Source,
      Format('select coalesce(name, '''') from points where OKEY = %d;', [PointId1]));
    OriginalPoint2 := QueryScalarText(Source,
      Format('select coalesce(name, '''') from points where OKEY = %d;', [PointId2]));
    OriginalLine1 := QueryScalarText(Source,
      'select coalesce(name, '''') from lines where OKEY = 1;');
    BaselinePointCount := QueryScalarInt64(Source, 'select count(*) from points;');
    BaselineLineCount := QueryScalarInt64(Source, 'select count(*) from lines;');
    CheckEquals(BaselinePointCount, QueryScalarInt64(Target, 'select count(*) from points;'),
      'target points baseline mismatch');
    CheckEquals(BaselineLineCount, QueryScalarInt64(Target, 'select count(*) from lines;'),
      'target lines baseline mismatch');

    Session := TSQLiteSession.Create(Source);
    try
      Session.SetTableFilter(FilterPoints);
      Session.Attach;
      ExecSql(Source, Format('update points set name = ''session update one'' where OKEY = %d;',
        [PointId1]));
      ExecSql(Source, 'update lines set name = ''must be filtered'' where OKEY = 1;');
      ExecSql(Source,
        'insert into points(geometry, osm_id, name) values(null, 922337203685477000, ''session insert'');');
      Changeset1 := Session.CreateChangeset;
      CheckTrue(not Changeset1.IsEmpty, 'first real changeset is empty');
    finally
      Session.Free;
    end;

    CheckEquals(SQLITE_OK, TSQLiteSession.Apply(Target, Changeset1),
      'first real changeset apply failed');
    CheckEquals('session update one', QueryScalarText(Target,
      Format('select name from points where OKEY = %d;', [PointId1])),
      'updated point was not applied');
    CheckEquals(BaselinePointCount + 1, QueryScalarInt64(Target, 'select count(*) from points;'),
      'inserted point was not applied');
    CheckEquals(OriginalLine1, QueryScalarText(Target,
      'select coalesce(name, '''') from lines where OKEY = 1;'),
      'excluded lines table was modified');

    Inverted := TSQLiteChangeset.Invert(Changeset1);
    try
      CheckEquals(SQLITE_OK, TSQLiteSession.Apply(Target, Inverted),
        'first changeset rollback failed');
    finally
      Inverted.Free;
    end;
    CheckEquals(OriginalPoint1, QueryScalarText(Target,
      Format('select coalesce(name, '''') from points where OKEY = %d;', [PointId1])),
      'point one rollback mismatch');
    CheckEquals(BaselinePointCount, QueryScalarInt64(Target, 'select count(*) from points;'),
      'insert rollback count mismatch');

    Session := TSQLiteSession.Create(Source);
    try
      Session.SetTableFilter(FilterPoints);
      Session.Attach;
      ExecSql(Source, Format('update points set name = ''session update two'' where OKEY = %d;',
        [PointId2]));
      Changeset2 := Session.CreateChangeset;
      CheckTrue(not Changeset2.IsEmpty, 'second real changeset is empty');
    finally
      Session.Free;
    end;

    Combined := TSQLiteChangeset.Concat(Changeset1, Changeset2);
    try
      CheckEquals(SQLITE_OK, TSQLiteSession.Apply(Target, Combined),
        'concatenated changeset apply failed');
      CheckEquals('session update one', QueryScalarText(Target,
        Format('select name from points where OKEY = %d;', [PointId1])),
        'concatenated update one mismatch');
      CheckEquals('session update two', QueryScalarText(Target,
        Format('select name from points where OKEY = %d;', [PointId2])),
        'concatenated update two mismatch');
      CheckEquals(BaselinePointCount + 1, QueryScalarInt64(Target, 'select count(*) from points;'),
        'concatenated insert count mismatch');

      Inverted := TSQLiteChangeset.Invert(Combined);
      try
        CheckEquals(SQLITE_OK, TSQLiteSession.Apply(Target, Inverted),
          'concatenated changeset rollback failed');
      finally
        Inverted.Free;
      end;
      CheckEquals(OriginalPoint1, QueryScalarText(Target,
        Format('select coalesce(name, '''') from points where OKEY = %d;', [PointId1])),
        'concatenated rollback point one mismatch');
      CheckEquals(OriginalPoint2, QueryScalarText(Target,
        Format('select coalesce(name, '''') from points where OKEY = %d;', [PointId2])),
        'concatenated rollback point two mismatch');

      Group := TSQLiteChangegroup.Create;
      try
        Group.Add(Changeset1);
        Group.Add(Changeset2);
        Grouped := Group.Output;
        CheckEquals(SQLITE_OK, TSQLiteSession.Apply(Target, Grouped),
          'changegroup output apply failed');
        CheckEquals('session update two', QueryScalarText(Target,
          Format('select name from points where OKEY = %d;', [PointId2])),
          'changegroup update mismatch');
      finally
        Group.Free;
      end;

      Inverted := TSQLiteChangeset.Invert(Grouped);
      try
        CheckEquals(SQLITE_OK, TSQLiteSession.Apply(Target, Inverted),
          'changegroup rollback failed');
      finally
        Inverted.Free;
      end;
      CheckEquals(OriginalPoint1, QueryScalarText(Target,
        Format('select coalesce(name, '''') from points where OKEY = %d;', [PointId1])),
        'changegroup rollback point one mismatch');
      CheckEquals(OriginalPoint2, QueryScalarText(Target,
        Format('select coalesce(name, '''') from points where OKEY = %d;', [PointId2])),
        'changegroup rollback point two mismatch');
    finally
      Combined.Free;
    end;
  finally
    if Grouped <> nil then
      Grouped.Free;
    if Changeset2 <> nil then
      Changeset2.Free;
    if Changeset1 <> nil then
      Changeset1.Free;
    CloseDatabase(Target);
    CloseDatabase(Source);
    sqlite3_shutdown;
    if TFile.Exists(FirstFile) then
      TFile.Delete(FirstFile);
    if TFile.Exists(SecondFile) then
      TFile.Delete(SecondFile);
  end;
end;

procedure TSqliteSessionTests.StreamingSessionFacade;
var
  Source: Pointer;
  Target: Pointer;
  TargetV2: Pointer;
  TargetV3: Pointer;
  Session: TSQLiteSession;
  Changeset: TSQLiteChangeset;
  Inverted: TSQLiteChangeset;
  Iterator: TSQLiteChangesetIterator;
  Rebaser: TSQLiteRebaser;
  InputContext: TSessionStreamContext;
  InputContext2: TSessionStreamContext;
  OutputContext: TSessionStreamContext;
  OutputContext2: TSessionStreamContext;
  RebaseData: TBytes;
  Count: Integer;
begin
  CheckEquals(SQLITE_OK, sqlite3_initialize, 'sqlite3_initialize');
  Source := OpenMemory;
  Target := OpenMemory;
  TargetV2 := OpenMemory;
  TargetV3 := OpenMemory;
  try
    ExecSql(Source, 'create table items(id integer primary key, value text);');
    ExecSql(Target, 'create table items(id integer primary key, value text);');
    ExecSql(TargetV2, 'create table items(id integer primary key, value text);');
    ExecSql(TargetV3, 'create table items(id integer primary key, value text);');
    ExecSql(Source, 'insert into items(id, value) values(1, ''before'');');
    ExecSql(Target, 'insert into items(id, value) values(1, ''before'');');
    ExecSql(TargetV2, 'insert into items(id, value) values(1, ''before'');');
    ExecSql(TargetV3, 'insert into items(id, value) values(1, ''before'');');

    Session := TSQLiteSession.Create(Source);
    try
      Session.Attach;
      ExecSql(Source, 'insert into items(id, value) values(2, ''streamed'');');
      Changeset := Session.CreateChangeset;
      try
        CheckEquals(SQLITE_OK, TSQLiteSession.ConfigureStreamSize(512),
          'session stream size configuration failed');

        InputContext.Data := Changeset.Bytes;
        InputContext.Offset := 0;
        Iterator := TSQLiteChangesetIterator.CreateStream(@StreamInput, @InputContext);
        try
          Count := 0;
          while Iterator.Next do
            Inc(Count);
          CheckEquals(1, Count, 'stream iterator operation count mismatch');
        finally
          Iterator.Free;
        end;

        OutputContext.Data := nil;
        OutputContext.Offset := 0;
        InputContext.Offset := 0;
        CheckEquals(SQLITE_OK, TSQLiteChangeset.InvertStream(@StreamInput, @InputContext,
          @StreamOutput, @OutputContext), 'stream invert failed');
        CheckTrue(Length(OutputContext.Data) > 0, 'stream invert returned no data');

        Inverted := TSQLiteChangeset.Invert(Changeset);
        try
          InputContext.Data := Changeset.Bytes;
          InputContext.Offset := 0;
          InputContext2.Data := Inverted.Bytes;
          InputContext2.Offset := 0;
          OutputContext2.Data := nil;
          OutputContext2.Offset := 0;
          CheckEquals(SQLITE_OK, TSQLiteChangeset.ConcatStream(@StreamInput, @InputContext,
            @StreamInput, @InputContext2, @StreamOutput, @OutputContext2),
            'stream concat failed');
          CheckEquals(0, Length(OutputContext2.Data), 'stream concat did not cancel changes');
        finally
          Inverted.Free;
        end;

        InputContext.Data := Changeset.Bytes;
        InputContext.Offset := 0;
        OutputContext.Data := nil;
        OutputContext.Offset := 0;
        CheckEquals(SQLITE_OK, TSQLiteSession.ApplyStream(Target, @StreamInput, @InputContext,
          nil, nil, nil), 'stream apply failed');
        CheckEquals(2, QueryScalarInt64(Target, 'select count(*) from items;'),
          'stream apply row count mismatch');

        InputContext.Data := Changeset.Bytes;
        InputContext.Offset := 0;
        CheckEquals(SQLITE_OK, TSQLiteSession.ApplyV2Stream(TargetV2, @StreamInput,
          @InputContext, nil, nil, nil, 0, RebaseData), 'stream v2 apply failed');
        CheckEquals(0, Length(RebaseData), 'stream v2 unexpected rebase data');

        InputContext.Data := Changeset.Bytes;
        InputContext.Offset := 0;
        CheckEquals(SQLITE_OK, TSQLiteSession.ApplyV3Stream(TargetV3, @StreamInput,
          @InputContext, @StreamFilterV3, nil, nil, 0, RebaseData),
          'stream v3 apply failed');
        CheckEquals(2, QueryScalarInt64(TargetV3, 'select count(*) from items;'),
          'stream v3 apply row count mismatch');

        OutputContext.Data := nil;
        OutputContext.Offset := 0;
        CheckEquals(SQLITE_OK, Session.CreateChangesetStream(@StreamOutput, @OutputContext),
          'session changeset stream failed');
        CheckTrue(Length(OutputContext.Data) > 0, 'session changeset stream returned no data');
        OutputContext.Data := nil;
        CheckEquals(SQLITE_OK, Session.CreatePatchsetStream(@StreamOutput, @OutputContext),
          'session patchset stream failed');
        CheckTrue(Length(OutputContext.Data) > 0, 'session patchset stream returned no data');

        Rebaser := TSQLiteRebaser.Create(nil);
        try
          InputContext.Data := Changeset.Bytes;
          InputContext.Offset := 0;
          OutputContext.Data := nil;
          OutputContext.Offset := 0;
          CheckEquals(SQLITE_OK, Rebaser.RebaseStream(@StreamInput, @InputContext,
            @StreamOutput, @OutputContext), 'stream rebase failed');
          CheckTrue(Length(OutputContext.Data) > 0, 'stream rebase returned no data');
        finally
          Rebaser.Free;
        end;
      finally
        Changeset.Free;
      end;
    finally
      Session.Free;
    end;
  finally
    CloseDatabase(TargetV3);
    CloseDatabase(TargetV2);
    CloseDatabase(Target);
    CloseDatabase(Source);
    CheckEquals(SQLITE_OK, sqlite3_shutdown, 'sqlite3_shutdown');
  end;
end;

initialization
  RegisterTest(TSqliteSessionTests.Suite);

end.
