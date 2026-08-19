program Sqlite3CipheredReferenceTests;

{$APPTYPE CONSOLE}

uses
  TestFramework,
  TextTestRunner,
  Sqlite3StaticTestCase in 'Sqlite3StaticTestCase.pas',
  Sqlite3CipheredReferenceTestCase in 'Sqlite3CipheredReferenceTestCase.pas';

begin
  TextTestRunner.RunRegisteredTests(rxbHaltOnFailures);
end.
