program SqliteSessionTests;

{$APPTYPE CONSOLE}

uses
  TestFramework,
  TextTestRunner,
  SqliteSessionTestCase in 'SqliteSessionTestCase.pas';

begin
  TextTestRunner.RunRegisteredTests(rxbHaltOnFailures);
end.
