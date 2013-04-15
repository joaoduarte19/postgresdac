unit PSQLFieldsTest;
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
  PSQLTypes, SysUtils, DbCommon, Graphics, StdVCL, TestExtensions,
  Forms, PSQLConnFrm, PSQLFields;

type

  //Setup decorator
  TDbSetup = class(TTestSetup)
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  end;

  // Test methods for class TPSQLGuidField
  TestTPSQLGuidField = class(TTestCase)
  public
    procedure SetUp; override;
    procedure TearDown; override;
    procedure TestGUIDField;
    procedure TestGUIDInsert;
    procedure TestGUIDUpdate;
    procedure TestGUIDDelete;
  published
    procedure TestSelectUUID;
    procedure TesTGUIDField_ASCII;
    procedure TestGUIDInsert_ASCII;
    procedure TestGUIDUpdate_ASCII;
    procedure TestGUIDDelete_ASCII;
    procedure TestGUIDField_UTF8;
    procedure TestGUIDInsert_UTF8;
    procedure TestGUIDUpdate_UTF8;
    procedure TestGUIDDelete_UTF8;
  end;

var
  FldDB: TPSQLDatabase;
  FldQry: TPSQLQuery;

implementation

uses TestHelper;

{$IFDEF DELPHI_5}
function CoCreateGuid(out guid: TGUID): HResult; stdcall; external 'ole32.dll' name 'CoCreateGuid';

function CreateGUID(out Guid: TGUID): HResult;
begin
  Result := CoCreateGuid(Guid);
end;
{$ENDIF}

procedure TestTPSQLGuidField.SetUp;
begin
end;

procedure TestTPSQLGuidField.TearDown;
begin
 FldQry.Close;
 FldQry.SQL.Clear;
end;

procedure TestTPSQLGuidField.TestSelectUUID;
begin
  FldQry.SQL.Text := 'SELECT ''35c6c84e-4157-466c-0091-31a4714aca34''::uuid';
  FldQry.Open;
  Check(FldQry.Active, 'Cannot select UUID value');
end;

procedure TestTPSQLGuidField.TestGUIDDelete;
begin
  FldQry.RequestLive := True;
  FldQry.SQL.Text := 'SELECT * FROM uuid_test_case_table';
  FldQry.Open;
  FldQry.Delete;
  Check(FldQry.RowsAffected = 1, 'Cannot delete UUID ' + FldQry.Fields[0].ClassName);
end;

procedure TestTPSQLGuidField.TestGUIDDelete_ASCII;
begin
  fldDB.CharSet := 'SQL_ASCII';
  FldQry.Options := FldQry.Options + [dsoUseGUIDField];
  TestGUIDDelete;
  FldQry.Options := FldQry.Options - [dsoUseGUIDField];
  TestGUIDDelete;
end;

procedure TestTPSQLGuidField.TestGUIDDelete_UTF8;
begin
  fldDB.CharSet := 'UNICODE';
  FldQry.Options := FldQry.Options + [dsoUseGUIDField];
  TestGUIDDelete;
  FldQry.Options := FldQry.Options - [dsoUseGUIDField];
  TestGUIDDelete;
end;

procedure TestTPSQLGuidField.TestGUIDField;
var G1, G2: TGUID;
begin
  G1 := StringToGuid('{35c6c84e-4157-466c-0091-31a4714aca34}');
  FldQry.SQL.Text := 'SELECT ''35c6c84e-4157-466c-0091-31a4714aca34''::uuid';
  FldQry.Open;
  Check(FldQry.Active, 'Cannot select UUID value');
  Check(FldQry.Fields[0].AsString = UpperCase('{35c6c84e-4157-466c-0091-31a4714aca34}'), 'UUID value is corrupted in SQL_ASCII charset using TGUIDField');
  if FldQry.Fields[0] is TGUIDField then
   G2 := TGUIDField(FldQry.Fields[0]).AsGuid
  else
   G2 := TPSQLGUIDField(FldQry.Fields[0]).AsGuid;
  Check(IsEqualGUID(G1, G2), 'GUID comparison failed: ' + FldQry.Fields[0].ClassName);
end;

procedure TestTPSQLGuidField.TestGUIDInsert;
var G: TGUID;
begin
  FldQry.RequestLive := True;
  FldQry.SQL.Text := 'SELECT * FROM uuid_test_case_table';
  FldQry.Open;
  FldQry.Insert;
  Check(CreateGUID(G) = 0, 'GUID generation failed');
  if FldQry.Fields[0] is TGUIDField then
   TGUIDField(FldQry.Fields[0]).AsGuid := G
  else
   TPSQLGUIDField(FldQry.Fields[0]).AsGuid := G;
  FldQry.Post;
  Check(FldQry.RowsAffected = 1, 'Cannot insert UUID: ' + FldQry.Fields[0].ClassName);
end;

procedure TestTPSQLGuidField.TestGUIDInsert_ASCII;
begin
  fldDB.CharSet := 'SQL_ASCII';
  FldQry.Options := FldQry.Options + [dsoUseGUIDField];
  TestGUIDInsert;
  FldQry.Options := FldQry.Options - [dsoUseGUIDField];
  TestGUIDInsert;
end;

procedure TestTPSQLGuidField.TestGUIDInsert_UTF8;
begin
  fldDB.CharSet := 'UNICODE';
  FldQry.Options := FldQry.Options + [dsoUseGUIDField];
  TestGUIDInsert;
  FldQry.Options := FldQry.Options - [dsoUseGUIDField];
  TestGUIDInsert;
end;

procedure TestTPSQLGuidField.TestGUIDUpdate;
var G: TGUID;
begin
  FldQry.RequestLive := True;
  FldQry.SQL.Text := 'SELECT * FROM uuid_test_case_table';
  FldQry.Open;
  FldQry.Edit;
  CreateGUID(G);
  if FldQry.Fields[0] is TGUIDField then
   TGUIDField(FldQry.Fields[0]).AsGuid := G
  else
   TPSQLGUIDField(FldQry.Fields[0]).AsGuid := G;
  FldQry.Post;
  Check(FldQry.RowsAffected = 1, 'Cannot update UUID ' + FldQry.Fields[0].ClassName);
end;

procedure TestTPSQLGuidField.TestGUIDUpdate_ASCII;
begin
  fldDB.CharSet := 'SQL_ASCII';
  FldQry.Options := FldQry.Options + [dsoUseGUIDField];
  TestGUIDUpdate;
  FldQry.Options := FldQry.Options - [dsoUseGUIDField];
  TestGUIDUpdate;
end;

procedure TestTPSQLGuidField.TestGUIDUpdate_UTF8;
begin
  fldDB.CharSet := 'UNICODE';
  FldQry.Options := FldQry.Options + [dsoUseGUIDField];
  TestGUIDUpdate;
  FldQry.Options := FldQry.Options - [dsoUseGUIDField];
  TestGUIDUpdate;
end;

procedure TestTPSQLGuidField.TestGUIDField_ASCII;
begin
  fldDB.CharSet := 'SQL_ASCII';
  FldQry.Options := FldQry.Options + [dsoUseGUIDField];
  TestGUIDField;
  FldQry.Options := FldQry.Options - [dsoUseGUIDField];
  TestGUIDField;
end;

procedure TestTPSQLGuidField.TestGUIDField_UTF8;
begin
  fldDB.CharSet := 'UNICODE';
  FldQry.Options := FldQry.Options + [dsoUseGUIDField];
  TestGUIDField;
  FldQry.Options := FldQry.Options - [dsoUseGUIDField];
  TestGUIDField;
end;

{ TDbSetup }

procedure TDbSetup.SetUp;
begin
  inherited;
  SetUpTestDatabase(FldDB, 'PSQLQueryTest.conf');
  FldQry := TPSQLQuery.Create(nil);
  FldQry.Database := FldDB;
  FldQry.ParamCheck := False;
  FldDB.Execute('CREATE TABLE IF NOT EXISTS uuid_test_case_table(uuidf uuid NOT NULL PRIMARY KEY)');
end;

procedure TDbSetup.TearDown;
begin
  inherited;
  FldDB.Execute('DROP TABLE uuid_test_case_table');
  FldDB.Close;
  ComponentToFile(FldDB, 'PSQLQueryTest.conf');
  FldQry.Free;
  FldDB.Free;
end;

initialization
  //PaGo: Register any test cases with setup decorator
  RegisterTest(TDbSetup.Create(TestTPSQLGuidField.Suite, 'Database Setup'));

end.

