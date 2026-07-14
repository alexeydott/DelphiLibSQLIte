program Sqlite3StaticTests;

{$APPTYPE CONSOLE}

uses
  TestFramework,
  TextTestRunner,
  Sqlite3StaticTestCase in 'Sqlite3StaticTestCase.pas',
  Sqlite3ExtendedApiTestCase in 'Sqlite3ExtendedApiTestCase.pas';

begin
  TextTestRunner.RunRegisteredTests(rxbHaltOnFailures);
end.
