unit PSQLDatabaseTest;
{$I PSQLDAC.inc}
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit
  being tested.

}

interface

uses
  TestFramework, Db, Windows, PSQLAccess, ExtCtrls, Controls, Classes, PSQLDbTables,
  PSQLTypes, SysUtils, DbCommon, {$IFNDEF DELPHI_5}Variants,{$ENDIF} Graphics, StdVCL, TestExtensions,
  Forms, PSQLConnFrm;

type
  //Setup decorator
  TDbSetup = class(TTestSetup)
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  end;

  // Test methods for class TPSQLDatabase

  TestTPSQLDatabase = class(TTestCase)
  published
    procedure HookUp;
    procedure TestPlainConnInfoConnect;
    procedure TestExecute;
    procedure TestGetBackendPID;
    procedure TestSelectString;
    procedure TestSelectString1;
    procedure TestSelectStringDef;
    procedure TestSelectStringDef1;
    procedure TestSelectStrings;
    procedure TestSelectStrings1;
    procedure TestCommit;
    procedure TestGetCharsets;
    procedure TestGetDatabases;
    procedure TestGetSchemaNames;
    procedure TestGetStoredProcNames;
    procedure TestGetTableNames;
    procedure TestGetTablespaces;
    procedure TestGetUserNames;
    procedure TestReset;
    procedure TestRollback;
    procedure TestPing;
    procedure TestPingEx;
    procedure TestIsThreadSafe;
  end;

var
  FPSQLDatabase: TPSQLDatabase;

implementation

uses TestHelper;

procedure TestTPSQLDatabase.HookUp;
begin
 Check(True);
end;

procedure TestTPSQLDatabase.TestExecute;
var
  ReturnValue: Integer;
  SQL: string;
begin
  SQL := 'SELECT version()';
  ReturnValue := FPSQLDatabase.Execute(SQL);
  Check(ReturnValue = 1);
end;

procedure TestTPSQLDatabase.TestGetBackendPID;
var
  ReturnValue: Cardinal;
begin
  ReturnValue := FPSQLDatabase.GetBackendPID;
  Check(ReturnValue > InvalidOID);
end;

procedure TestTPSQLDatabase.TestSelectString;
var
  ReturnValue: string;
  aFieldName: string;
  IsOk: Boolean;
  aSQL: string;
begin
  aSQL := 'SELECT 12345 as column1';
  aFieldName := 'column1';
  ReturnValue := FPSQLDatabase.SelectString(aSQL, IsOk, aFieldName);
  Check(IsOk);
  CheckEquals('12345', ReturnValue);
end;

procedure TestTPSQLDatabase.TestSelectString1;
var
  ReturnValue: string;
  aFieldNumber: Integer;
  IsOk: Boolean;
  aSQL: string;
begin
  aSQL := 'SELECT 12345 as column1';
  aFieldNumber := 0;
  ReturnValue := FPSQLDatabase.SelectString(aSQL, IsOk, aFieldNumber);
  Check(IsOk);
  CheckEquals('12345', ReturnValue);
end;

procedure TestTPSQLDatabase.TestSelectStringDef;
var
  ReturnValue: string;
  aFieldName: string;
  aDefaultValue: string;
  aSQL: string;
begin
  aSQL := 'SELECT 12345 as column1';
  aFieldName := 'column1';
  ReturnValue := FPSQLDatabase.SelectStringDef(aSQL, aDefaultValue, aFieldName);
  CheckEquals('12345', ReturnValue);
  aSQL := 'SELECT 12345 as column1';
  aFieldName := 'WRONG_COL_NAME';
  aDefaultValue := 'MyDefaultValue';
  ReturnValue := FPSQLDatabase.SelectStringDef(aSQL, aDefaultValue, aFieldName);
  CheckEquals(aDefaultValue, ReturnValue);
end;

procedure TestTPSQLDatabase.TestSelectStringDef1;
var
  ReturnValue: string;
  aFieldNumber: Integer;
  aDefaultValue: string;
  aSQL: string;
begin
  aSQL := 'SELECT 12345 as column1';
  aFieldNumber := 0;
  ReturnValue := FPSQLDatabase.SelectStringDef(aSQL, aDefaultValue, aFieldNumber);
  CheckEquals('12345', ReturnValue);
  aSQL := 'SELECT 12345 as column1';
  aFieldNumber := -1234214;
  aDefaultValue := 'MyDefaultValue';
  ReturnValue := FPSQLDatabase.SelectStringDef(aSQL, aDefaultValue, aFieldNumber);
  CheckEquals(aDefaultValue, ReturnValue);
end;

procedure TestTPSQLDatabase.TestSelectStrings;
var
  aFieldName: string;
  aList: TStrings;
  aSQL: string;
begin
  aList := TStringList.Create;
  try
    aSQL := 'SELECT 1, g.s FROM generate_series(1,10) as g(s)';
    aFieldName := 's';
    FPSQLDatabase.SelectStrings(aSQL, aList, aFieldName);
    Check(aList.Count = 10, 'SelectStrings by FieldName failed');
  finally
    aList.Free;
  end;
end;

procedure TestTPSQLDatabase.TestSelectStrings1;
var
  aFieldNumber: Integer;
  aList: TStrings;
  aSQL: string;
begin
  aList := TStringList.Create;
  try
    aSQL := 'SELECT 1, g.s FROM generate_series(1,10) as g(s)';
    aFieldNumber := 1;
    FPSQLDatabase.SelectStrings(aSQL, aList, aFieldNumber);
    Check(aList.Count = 10, 'SelectStrings by FieldNumber failed');
  finally
    aList.Free;
  end;
end;

procedure TestTPSQLDatabase.TestCommit;
begin
  FPSQLDatabase.StartTransaction;
  Check(FPSQLDatabase.TransactionStatus in [trstINTRANS, trstACTIVE], 'Failed to BEGIN transaction');
  FPSQLDatabase.Execute('CREATE TEMP TABLE foo()');
  FPSQLDatabase.Commit;
  Check(FPSQLDatabase.TransactionStatus = trstIDLE, 'Failed to COMMIT transaction');
end;

procedure TestTPSQLDatabase.TestGetCharsets;
var
  aList: TStrings;
begin
  aList := TStringList.Create;
  try
    FPSQLDatabase.GetCharsets(aList);
    Check(aList.Count > 0, 'GetCharsets failed');
  finally
    aList.Free;
  end;
end;

procedure TestTPSQLDatabase.TestGetDatabases;
var
  aList: TStrings;
  Pattern: string;
begin
  aList := TStringList.Create;
  try
    Pattern := '%';
    FPSQLDatabase.GetDatabases(Pattern, aList);
    Check(aList.Count > 0, 'GetDatabases failed');
  finally
    aList.Free;
  end;
end;

procedure TestTPSQLDatabase.TestGetSchemaNames;
var
  List: TStrings;
  SystemSchemas: Boolean;
  Pattern: string;
  Count: integer;
begin
  List := TStringList.Create;
  try
    Pattern := '%';
    SystemSchemas := True;
    FPSQLDatabase.GetSchemaNames(Pattern, SystemSchemas, List);
    Count := List.Count;
    List.Clear;
    FPSQLDatabase.GetSchemaNames(Pattern, not SystemSchemas, List);
    Check(List.Count <= Count, 'GetSchemaNames failed');
  finally
    List.Free;
  end;
end;

procedure TestTPSQLDatabase.TestGetStoredProcNames;
var
  aList: TStrings;
  Pattern: string;
begin
  aList := TStringList.Create;
  try
    Pattern := '%';
    FPSQLDatabase.GetStoredProcNames(Pattern, aList);
    Check(aList.Count > 0, 'GetStoredProcNames failed');
  finally
    aList.Free;
  end;
end;

procedure TestTPSQLDatabase.TestGetTableNames;
var
  List: TStrings;
  SystemTables: Boolean;
  Pattern: string;
  Count: integer;
begin
  List := TStringList.Create;
  try
    Pattern := '%';
    SystemTables := True;
    FPSQLDatabase.GetTableNames(Pattern, SystemTables, List);
    Count := List.Count;
    List.Clear;
    FPSQLDatabase.GetTableNames(Pattern, not SystemTables, List);
    Check(List.Count <= Count, 'GetTableNames failed');
  finally
    List.Free;
  end;
end;

procedure TestTPSQLDatabase.TestGetTablespaces;
var
  aList: TStrings;
  Pattern: string;
begin
  aList := TStringList.Create;
  try
    Pattern := '%';
    FPSQLDatabase.GetTablespaces(Pattern, aList);
    Check(aList.Count > 0, 'GetTablespaces failed');
  finally
    aList.Free;
  end;
end;

procedure TestTPSQLDatabase.TestGetUserNames;
var
  aList: TStrings;
  Pattern: string;
begin
  aList := TStringList.Create;
  try
    Pattern := '%';
    FPSQLDatabase.GetUserNames(Pattern, aList);
    Check(aList.Count > 0, 'GetUserNames failed');
  finally
    aList.Free;
  end;
end;

procedure TestTPSQLDatabase.TestIsThreadSafe;
begin
  Check(PSQLTypes.PQIsThreadSafe() = 1, 'Library loaded is thread unsafe');
end;

procedure TestTPSQLDatabase.TestPing;
begin
  Check(FPSQLDatabase.Ping = pstOK, 'Ping failed');
end;

procedure TestTPSQLDatabase.TestPingEx;
var ConnParams: TStringList;
begin
  ConnParams := TStringList.Create;
  try
    ConnParams.Assign(FPSQLDatabase.Params);
    Check(FPSQLDatabase.Ping() = pstOK, 'PingEx failed');
  finally
    ConnParams.Free;
  end;
end;

procedure TestTPSQLDatabase.TestPlainConnInfoConnect;
begin
  FPSQLDatabase.Close;
  FPSQLDatabase.UseSingleLineConnInfo := True;
  FPSQLDatabase.Open;
  Check(FPSQLDatabase.Connected, 'Failed to connect using PQconnectdb');
end;

procedure TestTPSQLDatabase.TestReset;
begin
  FPSQLDatabase.Reset;
end;

procedure TestTPSQLDatabase.TestRollback;
begin
  FPSQLDatabase.StartTransaction;
  Check(FPSQLDatabase.TransactionStatus in [trstINTRANS, trstACTIVE], 'Failed to BEGIN transaction');
  FPSQLDatabase.Execute('CREATE TEMP TABLE foo()');
  FPSQLDatabase.Rollback;
  Check(FPSQLDatabase.TransactionStatus = trstIDLE, 'Failed to ROLLBACK transaction');
end;

{ MainFormSetup }

procedure TDbSetup.SetUp;
begin
  inherited;
  SetUpTestDatabase(FPSQLDatabase, 'PSQLDatabaseTest.conf');
end;

procedure TDbSetup.TearDown;
begin
  inherited;
  FPSQLDatabase.Close;
  ComponentToFile(FPSQLDatabase, 'PSQLDatabaseTest.conf');
  FPSQLDatabase.Free;
end;

initialization
  //PaGo: Register any test cases with setup decorator
  RegisterTest(TDbSetup.Create(TestTPSQLDatabase.Suite, 'Database Setup'));

  // Register any test cases with the test runner
  //RegisterTest(TestTPSQLDatabase.Suite);
end.

