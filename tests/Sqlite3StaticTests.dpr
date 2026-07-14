program Sqlite3StaticTests;

{$APPTYPE CONSOLE}

uses
  TestFramework,
  TextTestRunner,
  Sqlite3StaticTestCase in 'Sqlite3StaticTestCase.pas';

begin
  TextTestRunner.RunRegisteredTests(rxbHaltOnFailures);
end.
