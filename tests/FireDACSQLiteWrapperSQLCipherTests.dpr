program FireDACSQLiteWrapperSQLCipherTests;

{$APPTYPE CONSOLE}

uses
  TestFramework,
  TextTestRunner,
  FireDAC.Phys.SQLiteWrapper.SQLCipher in '..\FireDAC.Phys.SQLiteWrapper.SQLCipher.pas',
  FireDACSQLiteWrapperSQLCipherTestCase in 'FireDACSQLiteWrapperSQLCipherTestCase.pas';

begin
  TextTestRunner.RunRegisteredTests(rxbHaltOnFailures);
end.
