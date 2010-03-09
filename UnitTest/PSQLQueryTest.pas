unit PSQLQueryTest;
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
  PSQLTypes, SysUtils, DbCommon, Variants, Graphics, StdVCL, TestExtensions,
  Forms, PSQLConnFrm;

type
  //Setup decorator
  TDbSetup = class(TTestSetup)
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  end;

  // Test methods for class TPSQLQuery
  TestTPSQLQuery = class(TTestCase)
  strict private
    FPSQLQuery: TPSQLQuery;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestEmptyCharAsNullOption;
    procedure TestCreateBlobStream;
    procedure TestIsSequenced;
    procedure TestExecSQL;
    procedure TestGetDetailLinkFields;
    procedure TestParamByName;
    procedure TestPrepare;
    procedure TestUnPrepare;
  end;

var
  QryDB: TPSQLDatabase;

implementation

uses TestHelper;

procedure TestTPSQLQuery.SetUp;
begin
  FPSQLQuery := TPSQLQuery.Create(nil);
  FPSQLQuery.Database := QryDB;
end;

procedure TestTPSQLQuery.TearDown;
begin
  FPSQLQuery.Free;
  FPSQLQuery := nil;
end;

procedure TestTPSQLQuery.TestEmptyCharAsNullOption;
var
  ReturnValue: TPSQLEngine;
begin
  FPSQLQuery.Options := [];
  FPSQLQuery.SQL.Text := 'SELECT Cast('''' AS varchar(30)), Cast(''text'' AS varchar(30)) as col1';
  FPSQLQuery.Open;
  Check(not FPSQLQuery.Fields[0].IsNull, 'Field must be NOT NULL due to normal options');
  FPSQLQuery.Close;

  FPSQLQuery.Options := [dsoEmptyCharAsNull];
  FPSQLQuery.SQL.Text := 'SELECT Cast('''' AS varchar(30)), Cast(''text'' AS varchar(30)) as col1';
  FPSQLQuery.Open;
  Check(FPSQLQuery.Fields[0].IsNull, 'IsNULL must be true due to dsoEmptyCharAsNull used');
  Check(FPSQLQuery.Fields.FieldByName('col1').AsWideString = 'text', 'Field must be not empty if dsoEmptyCharAsNull enabled');
  FPSQLQuery.Close;
end;

procedure TestTPSQLQuery.TestCreateBlobStream;
var
  ReturnValue: TStream;
  Mode: TBlobStreamMode;
  Field: TField;
begin
  Check(False);
  // TODO: Setup method call parameters
  ReturnValue := FPSQLQuery.CreateBlobStream(Field, Mode);
  // TODO: Validate method results
end;

procedure TestTPSQLQuery.TestIsSequenced;
var
  ReturnValue: Boolean;
begin
  Check(False);
  // TODO: Validate method results
end;

procedure TestTPSQLQuery.TestExecSQL;
begin
  Check(False);
  FPSQLQuery.ExecSQL;
  // TODO: Validate method results
end;

procedure TestTPSQLQuery.TestGetDetailLinkFields;
var
  DetailFields: TList;
  MasterFields: TList;
begin
  Check(False);
  // TODO: Setup method call parameters
  FPSQLQuery.GetDetailLinkFields(MasterFields, DetailFields);
  // TODO: Validate method results
end;

procedure TestTPSQLQuery.TestParamByName;
var
  ReturnValue: TPSQLParam;
  Value: string;
begin
  Check(False);
  // TODO: Setup method call parameters
  ReturnValue := FPSQLQuery.ParamByName(Value);
  // TODO: Validate method results
end;

procedure TestTPSQLQuery.TestPrepare;
begin
  Check(False);
  FPSQLQuery.Prepare;
  // TODO: Validate method results
end;

procedure TestTPSQLQuery.TestUnPrepare;
begin
  Check(False);
  FPSQLQuery.UnPrepare;
  // TODO: Validate method results
end;

{ TDbSetup }

procedure TDbSetup.SetUp;
begin
  inherited;
  SetUpTestDatabase(QryDB, 'PSQLQueryTest.conf');
end;

procedure TDbSetup.TearDown;
begin
  inherited;
  ComponentToFile(QryDB, 'PSQLQueryTest.conf');
  QryDB.Free;
end;

initialization
  //PaGo: Register any test cases with setup decorator
  RegisterTest(TDbSetup.Create(TestTPSQLQuery.Suite, 'Database Setup'));

end.
