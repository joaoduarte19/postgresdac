unit PSQLDumpTest;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit 
  being tested.

}

interface

uses
  TestFramework, Db, PSQLDump, PSQLTypes, Classes, SysUtils, PSQLDbTables,
  Windows, Math, PSQLAboutFrm, TestExtensions;

type
  //Setup decorator
  TDbSetup = class(TTestSetup)
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  end;

  // Test methods for class TPSQLDump
  TestTPSQLDump = class(TTestCase)
  private
    FPSQLDump: TPSQLDump;
  public
    procedure SetUp; override;
    procedure TearDown; override;
    procedure TestDumpToFileLogFile(ALogFileName: string = '');
  published
    procedure TestDumpToStream;
    procedure TestDumpToStreamStrings;
    procedure TestDumpToStreamLogFile;
    procedure TestDumpToFileStrings;
    //specific routines
    procedure TestDumpCompressed;
    procedure TestDumpTar;
    procedure TestDumpDirectory;
    procedure TestDumpPlain;
    procedure TestDumpPlainCompressed;
    procedure TestDumpNonASCIIName;
  end;

  // Test methods for class TPSQLRestore
  TestTPSQLRestore = class(TTestCase)
  private
    FPSQLRestore: TPSQLRestore;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestRestoreFromFile;
    procedure TestRestoreFromFile1;
  end;

var
  QryDb: TPSQLDatabase;
  DumpFileName: string = 'TestOutput\TestDumpToFile.backup';


implementation

uses TestHelper, IOUtils;

procedure TestTPSQLDump.SetUp;
begin
  FPSQLDump := TPSQLDump.Create(nil);
  FPSQLDump.Database := QryDb;
  FPSQLDump.Options := [doVerbose];
end;

procedure TestTPSQLDump.TearDown;
begin
  FPSQLDump.Free;
  FPSQLDump := nil;
end;

procedure TestTPSQLDump.TestDumpToStream;
var
  Stream: TStream;
begin
  Stream := TMemoryStream.Create;
  try
    FPSQLDump.DumpToStream(Stream);
    Check(Stream.Size > 0, 'Dump stream empty');
  finally
    Stream.Free;
  end;
end;

procedure TestTPSQLDump.TestDumpToStreamStrings;
var
  Log: TStrings;
  Stream: TStream;
begin
  Stream := TMemoryStream.Create;
  try
    Log := TStringList.Create;
    try
      FPSQLDump.DumpToStream(Stream, Log);
      Check(Stream.Size > 0, 'Dump stream empty');
      Check(Log.Count > 0, 'Dump log empty');
      Log.SaveToFile('TestOutput\TestDumpToStream1.log');
    finally
      Log.Free;
    end;
  finally
    Stream.Free;
  end;
end;

procedure TestTPSQLDump.TestDumpToStreamLogFile;
var
  LogFileName: string;
  Stream: TStream;
begin
  Stream := TMemoryStream.Create;
  try
    LogFileName := 'TestOutput\TestDumpToStream2.log';
    FPSQLDump.DumpToStream(Stream, LogFileName);
    Check(Stream.Size > 0, 'Dump stream empty');
    Check(FileExists(LogFileName), 'Log file empty');
  finally
    Stream.Free;
  end;
end;

procedure TestTPSQLDump.TestDumpCompressed;
begin
  FPSQLDump.DumpFormat := dfCompressedArchive;
  FPSQLDump.CompressLevel := 9;
  FPSQLDump.RewriteFile := True;
  TestDumpToFileLogFile('TestOutput\CompressedDump.log');
end;

procedure TestTPSQLDump.TestDumpDirectory;
begin
  DumpFileName := 'TestOutput\TestDumpToFile';
  if TDirectory.Exists(DumpFileName) then
    TDirectory.Delete(DumpFileName, True);
  FPSQLDump.DumpFormat := dfDirectory;
  FPSQLDump.RewriteFile := True;
    TestDumpToFileLogFile('TestOutput\DirectoryDump.log');
end;

procedure TestTPSQLDump.TestDumpNonASCIIName;
var OldDb: string;
    DoesDbExist: boolean;
begin
  QryDb.SelectString('SELECT TRUE FROM pg_database WHERE datname = ''�������������������''', DoesDbExist);
  if not DoesDbExist then
    QryDb.Execute('CREATE DATABASE "�������������������"');
  oldDB := QryDb.DatabaseName;
  try
    QryDb.Close;
    QryDb.DatabaseName := '�������������������';
    DumpFileName := 'TestOutput\TestNonASCII.backup';
    TestDumpToFileLogFile('TestOutput\NonASCIINameDump.log');
  finally
    QryDb.Close;
    QryDb.DatabaseName := OldDb;
  end;
end;

procedure TestTPSQLDump.TestDumpPlain;
begin
  DumpFileName := 'TestOutput\TestDumpToFile.sql';
  FPSQLDump.DumpFormat := dfPlain;
  FPSQLDump.CompressLevel := 0;
  FPSQLDump.RewriteFile := True;
  TestDumpToFileLogFile('TestOutput\PlainDump.log');
end;

procedure TestTPSQLDump.TestDumpPlainCompressed;
begin
  DumpFileName := 'TestOutput\TestDumpToFile.gz';
  FPSQLDump.DumpFormat := dfPlain;
  FPSQLDump.CompressLevel := 6;
  FPSQLDump.RewriteFile := True;
  TestDumpToFileLogFile('TestOutput\PlainCompressedDump.log');
end;

procedure TestTPSQLDump.TestDumpTar;
begin
  DumpFileName := 'TestOutput\TestDumpToFile.tar.gz';
  FPSQLDump.DumpFormat := dfTarArchive;
  FPSQLDump.CompressLevel := 6;
  FPSQLDump.RewriteFile := True;
  TestDumpToFileLogFile('TestOutput\TarDump.log');
end;

procedure TestTPSQLDump.TestDumpToFileStrings;
var
  Log: TStrings;
begin
  Log := TStringList.Create;
  try
    FPSQLDump.DumpToFile(DumpFileName, Log);
    Check(FileExists(DumpFileName), 'Dump file empty');
    Check(Log.Count > 0, 'Dump log empty');
  finally
    Log.SaveToFile('TestOutput\TestDumpToFile.log');
    Log.Free;
  end;
end;

procedure TestTPSQLDump.TestDumpToFileLogFile(ALogFileName: string = '');
var
  LogFileName: string;
begin
  if ALogFileName = '' then
    LogFileName := 'TestOutput\TestDumpToFile1.log'
  else
    LogFileName := ALogFileName;
  FPSQLDump.DumpToFile(DumpFileName, LogFileName);
  Check(FileExists(DumpFileName) or DirectoryExists(DumpFileName), 'Dump file empty');
  Check(FileExists(LogFileName), 'Log file empty');
end;

procedure TestTPSQLRestore.SetUp;
begin
  FPSQLRestore := TPSQLRestore.Create(nil);
  FPSQLRestore.Database := QryDb;
  FPSQLRestore.Options := [roVerbose];
  QryDb.Execute('CREATE DATABASE restore_test TEMPLATE template0;')
end;

procedure TestTPSQLRestore.TearDown;
begin
  FPSQLRestore.Free;
  FPSQLRestore := nil;
  QryDb.Execute('DROP DATABASE restore_test;')
end;

procedure TestTPSQLRestore.TestRestoreFromFile;
var
  Log: TStrings;
  FileName: string;
begin
  Log := TStringList.Create;
  try
    FileName := DumpFileName;
    FPSQLRestore.DBName := 'restore_test';
    FPSQLRestore.RestoreFromFile(FileName, Log);
    Log.SaveToFile('TestOutput\TestRestoreFromFile.log');
  finally
    Log.Free;
  end;
end;

procedure TestTPSQLRestore.TestRestoreFromFile1;
var
  LogFileName: string;
  FileName: string;
begin
  LogFileName := 'TestOutput\TestRestoreFromFile1.log';
  FileName := DumpFileName;
  FPSQLRestore.DBName := 'restore_test';
  FPSQLRestore.RestoreFromFile(FileName, LogFileName);
  Check(FileExists(DumpFileName), 'Dump file empty');
  Check(FileExists(LogFileName), 'Log file empty');
end;

{ TDbSetup }

procedure TDbSetup.SetUp;
begin
  inherited;
  SetUpTestDatabase(QryDB, 'PSQLDump.conf');
end;

procedure TDbSetup.TearDown;
begin
  inherited;
  QryDB.Close;
  ComponentToFile(QryDB, 'PSQLDump.conf');
  QryDB.Free;
end;

initialization
  //PaGo: Register any test cases with setup decorator
  RegisterTest(TDbSetup.Create(TestTPSQLDump.Suite, 'Database Setup'));
  RegisterTest(TDbSetup.Create(TestTPSQLRestore.Suite, 'Database Setup'));

end.

