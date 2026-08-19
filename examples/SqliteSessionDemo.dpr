program SqliteSessionDemo;

{$APPTYPE CONSOLE}

{$I ..\sqlite3.config.inc}

uses
  System.SysUtils,
  sqlite3.common,
  sqlite3.static,
  sqlite.session;

var
  Database: Pointer;
  Session: TSQLiteSession;
  Changeset: TSQLiteChangeset;
  SQLUtf8: UTF8String;

procedure CheckSqlite(const Code: Integer; const Operation: string);
begin
  if Code <> SQLITE_OK then
    raise ESQLiteSessionError.CreateFmt('%s failed with SQLite code %d', [Operation, Code]);
end;

begin
  Database := nil;
  try
    CheckSqlite(sqlite3_initialize, 'sqlite3_initialize');
    CheckSqlite(sqlite3_open_v2(MarshaledAString(PAnsiChar(UTF8String(':memory:'))), Database,
      SQLITE_OPEN_READWRITE or SQLITE_OPEN_CREATE or SQLITE_OPEN_MEMORY, nil), 'sqlite3_open_v2');
    CheckSqlite(sqlite3_exec_simple(Database,
      'create table notes(id integer primary key, text_value text);'), 'create table');

    Session := TSQLiteSession.Create(Database);
    try
      Session.Attach;
      SQLUtf8 := UTF8String('insert into notes(text_value) values(''captured by session'');');
      CheckSqlite(sqlite3_exec_simple(Database, string(SQLUtf8)), 'insert row');
      Changeset := Session.CreateChangeset;
      try
        Writeln('Captured changeset bytes: ', Changeset.Size);
      finally
        Changeset.Free;
      end;
    finally
      Session.Free;
    end;
  finally
    if Database <> nil then
      CheckSqlite(sqlite3_close_v2(Database), 'sqlite3_close_v2');
    CheckSqlite(sqlite3_shutdown, 'sqlite3_shutdown');
  end;
end.
