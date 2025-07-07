unit zip_odt;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

procedure FillODTDoc(const aSrcFile, aDestFile: String; aKeyValuePairs: TStringList; const aODTSubFile: String = '');

implementation

uses
  Zipper, FileUtil
  ;

procedure UnzipODT(const aUnzipDir, aZipFile: String);
var
  aUnZipper: TUnZipper;
begin
  aUnZipper:=TUnZipper.Create;
  try
    ForceDirectories(aUnzipDir);
    aUnZipper.OutputPath:=aUnzipDir;
    aUnZipper.UnZipAllFiles(aZipFile);
  finally
    aUnZipper.Free;
  end;
end;

procedure ZipODT(const aSrcDir, aZipFile: String);
var
  aZipper: TZipper;
  aList: tStringList;
  s: String;
begin
  aZipper := TZipper.create;
  aList := TStringList.create;
  try
    FindAllFiles(aList, aSrcDir);
    aZipper.FileName := aZipFile;
    for s in aList do
      aZipper.Entries.AddFileEntry(s, ExtractRelativePath(aSrcDir, s));
    aZipper.ZipAllFiles;
  finally
    aZipper.Free;
    aList.free;
  end;
end;

procedure FillContent(const aPath: String; const aKey, aValue: String; const aODTSubFile: String = '');
var
  S, aFile: String;
  aContent: TStringList;
begin
  if aODTSubFile.IsEmpty then
    aFile:=IncludeTrailingPathDelimiter(aPath)+'content.xml'
  else
    aFile:=IncludeTrailingPathDelimiter(aPath)+aODTSubFile;
  S:=ReadFileToString(aFile);
  S:=StringReplace(S, aKey, aValue, [rfReplaceAll]);
  aContent:=TStringList.Create;
  try
    aContent.Text:=S;
    aContent.SaveToFile(aFile);
  finally
    aContent.Free;
  end;
end;

procedure FillContent(const aPath: String; aKeyValuePairs: TStringList; const aODTSubFile: String = '');
var
  S, aFile: String;
  aContent: TStringList;
  i: Integer;
begin
  if aODTSubFile.IsEmpty then
    aFile:=IncludeTrailingPathDelimiter(aPath)+'content.xml'
  else
    aFile:=IncludeTrailingPathDelimiter(aPath)+aODTSubFile;
  S:=ReadFileToString(aFile);
  for i:=0 to aKeyValuePairs.Count-1 do
    S:=StringReplace(S, aKeyValuePairs.Names[i], aKeyValuePairs.ValueFromIndex[i], [rfReplaceAll]);
  aContent:=TStringList.Create;
  try
    aContent.Text:=S;
    aContent.SaveToFile(aFile);
  finally
    aContent.Free;
  end;
end;

  { aODTSubFile - a file to be processed in addition to the main content.xml }
procedure FillODTDoc(const aSrcFile, aDestFile: String; aKeyValuePairs: TStringList; const aODTSubFile: String = '');
var
  aTempPath: String;
begin
  aTempPath:=IncludeTrailingPathDelimiter(GetTempDir(False))+'zipodt'+PathDelim;
  ForceDirectories(aTempPath);
  UnzipODT(aTempPath, aSrcFile);
  FillContent(aTempPath, aKeyValuePairs);
  if not aODTSubFile.IsEmpty then
    FillContent(aTempPath, aKeyValuePairs, aODTSubFile);
  ZipODT(aTempPath, aDestFile);
  DeleteDirectory(aTempPath, True);
end;

end.

