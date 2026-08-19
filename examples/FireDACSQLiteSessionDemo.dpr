program FireDACSQLiteSessionDemo;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Stan.Async,
  FireDAC.Stan.Def,
  FireDAC.Stan.Param,
  FireDAC.Stan.Pool,
  FireDAC.Phys,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef,
  FireDAC.Phys.SQLiteWrapper,
  FireDAC.Phys.SQLiteWrapper.SQLCipher in '..\FireDAC.Phys.SQLiteWrapper.SQLCipher.pas',
  sqlite.session in '..\sqlite.session.pas';

var
  Connection: TFDConnection;
  DriverLink: TFDPhysSQLiteDriverLink;
  SessionInterface: IFireDACSQLiteSession;
  Adapter: TFireDACSQLiteSession;
  Session: TSQLiteSession;
  Changeset: TSQLiteChangeset;
begin
  DriverLink := TFDPhysSQLiteDriverLink.Create(nil);
  try
    DriverLink.EngineLinkage := slSEEStatic;
    Connection := TFDConnection.Create(nil);
    try
      Connection.DriverName := 'SQLite';
      Connection.Params.Database := ':memory:';
      Connection.Open;

      Adapter := TFireDACSQLiteSession.Create(Connection);
      if not Adapter.GetInterface(IFireDACSQLiteSession, SessionInterface) then
        raise ESQLiteSessionError.Create('Session interface is unavailable');
      if SessionInterface = nil then
        raise ESQLiteSessionError.Create('Session interface is unavailable');

      Connection.ExecSQL('create table demo_items(id integer primary key, value text);');
      Session := SessionInterface.CreateSession;
      try
        Session.Attach;
        Connection.ExecSQL(
          'insert into demo_items(value) values(''captured through FireDAC'');');
        Changeset := Session.CreateChangeset;
        try
          Writeln('Session API changeset bytes: ', Changeset.Size);
        finally
          Changeset.Free;
        end;
      finally
        Session.Free;
      end;
      Connection.Close;
    finally
      Connection.Free;
    end;
  finally
    DriverLink.Free;
  end;
end.
