unit PSQLCopyTest;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit 
  being tested.

}

interface

uses
  TestFramework, PSQLAccess, Classes, PSQLCopy, PSQLDbTables, PSQLTypes, SysUtils, TestExtensions;

type
  //Setup decorator
  TDbSetup = class(TTestSetup)
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  end;
  // Test methods for class TCustomPSQLCopy

  TestTCustomPSQLCopy = class(TTestCase)
  published
    procedure TestLoadFromStream;
    procedure TestSaveToStream;
    procedure TestLoadFromStrings;
    procedure TestSaveToStrings;
    procedure TestLoadFromClientSideFile;
    procedure TestSaveToClientSideFile;
    procedure TestLoadFromServerSideFile;
    procedure TestSaveToServerSideFile;
    procedure TestLoadFromProgram;
    procedure TestSaveToProgram;
  end;

implementation

uses TestHelper;

var
  FldDB: TPSQLDatabase;
  FPSQLCopy: TPSQLCopy;

procedure TestTCustomPSQLCopy.TestLoadFromStream;
var
  Stream: TStream;
begin
  Stream := TFileStream.Create('TestData\tasks.csv', fmOpenRead);
  try
    Stream.Position := 0;
    FPSQLCopy.Tablename := 'server_tasks';
    FPSQLCopy.DataFormat := cfCSV;
    FPSQLCopy.LoadFromStream(Stream);
    Check(FPSQLCopy.RowsAffected > 0);
  finally
    Stream.Free;
  end;
end;

procedure TestTCustomPSQLCopy.TestSaveToStream;
var
  Stream: TStream;
begin
  Stream := TMemoryStream.Create;
  try
    FPSQLCopy.SQL.Text := 'SELECT * FROM generate_series(1, 10)';
    FPSQLCopy.SaveToStream(Stream);
    Check(Stream.Size > 0);
  finally
    Stream.Free;
  end;
end;

procedure TestTCustomPSQLCopy.TestLoadFromStrings;
var
  Strings: TStrings;
begin
  Strings := TStringList.Create;
  try
    Strings.LoadFromFile('TestData\tasks.csv');
    FPSQLCopy.Tablename := 'server_tasks';
    FPSQLCopy.DataFormat := cfCSV;
    FPSQLCopy.LoadFromStrings(Strings);
    Check(FPSQLCopy.RowsAffected = Strings.Count);
  finally
    Strings.Free;
  end;
end;

procedure TestTCustomPSQLCopy.TestSaveToStrings;
var
  Strings: TStrings;
begin
  Strings := TStringList.Create();
  try
    FPSQLCopy.SQL.Text := 'SELECT * FROM generate_series(1, 10)';
    FPSQLCopy.SaveToStrings(Strings);
    Check(Strings.Count = 10, 'SaveToStrings failed');
  finally
    Strings.Free;
  end;
end;

procedure TestTCustomPSQLCopy.TestLoadFromClientSideFile;
var
  FileName: string;
begin
  FileName := 'TestData\tasks.csv';
  FPSQLCopy.Tablename := 'server_tasks';
  FPSQLCopy.DataFormat := cfCSV;
  FPSQLCopy.LoadFromClientSideFile(FileName);
end;

procedure TestTCustomPSQLCopy.TestSaveToClientSideFile;
var
  FileName: string;
begin
  FileName := 'TestOutput\TasksCopyOutput.bin';
  DeleteFile(FileName);
  FPSQLCopy.Tablename := 'server_tasks';
  FPSQLCopy.DataFormat := cfBinary;
  FPSQLCopy.SaveToClientSideFile(FileName);
  Check(FileExists(FileName), 'Output file doesn''t exist');
end;

procedure TestTCustomPSQLCopy.TestLoadFromServerSideFile;
var
  FileName: string;
begin
  // TODO: Setup method call parameters
  FPSQLCopy.LoadFromServerSideFile(FileName);
  // TODO: Validate method results
end;

procedure TestTCustomPSQLCopy.TestSaveToServerSideFile;
var
  FileName: string;
  QueryRes: string;
begin
  FPSQlCopy.SQL.Text := 'SELECT * FROM generate_series(1, 11)';
  FileName := 'loglist.txt';
  FPSQLCopy.SaveToServerSideFile(FileName);
  QueryRes := FldDB.SelectStringDef('SELECT now()-s.modification<''10 minutes'' FROM pg_stat_file(' + QuotedStr(FileName) + ') s', 'f');
  Check(QueryRes = 't');
end;

procedure TestTCustomPSQLCopy.TestLoadFromProgram;
var
  CommandLine: string;
begin
  FPSQLCopy.Tablename := 'server_tasks';
  CommandLine := 'tasklist /fo csv /nh';
  FPSQLCopy.Options := [coHeader];
  FPSQLCopy.DataFormat := cfCSV;
  FPSQLCopy.Encoding := 'WIN866';
  FPSQLCopy.LoadFromProgram(CommandLine);
  Check(FPSQLCopy.RowsAffected > 0);
end;

procedure TestTCustomPSQLCopy.TestSaveToProgram;
var
  CommandLine: string;
  QueryRes: string;
begin
  FPSQlCopy.SQL.Text := 'SELECT * FROM generate_series(1, 11)';
  CommandLine := 'find "1" > loglist.txt';
  FPSQLCopy.SaveToProgram(CommandLine);
  QueryRes := FldDB.SelectStringDef('SELECT now()-s.modification<''10 minutes'' FROM pg_stat_file(''loglist.txt'') s', 'f');
  Check(QueryRes = 't');
end;

{ TDbSetup }

procedure TDbSetup.SetUp;
begin
  inherited;
  SetUpTestDatabase(FldDB, 'PSQLCopyTest.conf');
  FPSQLCopy := TPSQLCopy.Create(nil);
  FPSQLCopy.Database := FldDB;
  FldDB.Execute('CREATE TEMP TABLE server_tasks(process text, PID int4, session varchar, session_num int4, memory varchar)');
end;

procedure TDbSetup.TearDown;
begin
  inherited;
  FldDB.Close;
  ComponentToFile(FldDB, 'PSQLCopyTest.conf');
  FPSQLCopy.Free;
  FldDB.Free;
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TDbSetup.Create(TestTCustomPSQLCopy.Suite, 'Database Setup'));
end.

