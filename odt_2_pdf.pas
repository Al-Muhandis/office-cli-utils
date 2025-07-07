unit odt_2_pdf;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

function ConvertODT2Pdf(const aSrcODT, aOutDir: String): Boolean;

implementation

uses
  process
  ;

const

  _PathToSOffice={$IFDEF MSWINDOWS}'C:\Program Files\LibreOffice\program\soffice.exe'{$ELSE}'soffice'{$ENDIF};

function ConvertODT2Pdf(const aSrcODT, aOutDir: String): Boolean;
var
  aProcess: TProcess;
begin
  Result:=False;
  aProcess := TProcess.Create(nil);
  with aProcess do
  begin
    try
      Executable := _PathToSOffice;
      Parameters.Add('--headless');
      Parameters.Add('--convert-to');
      Parameters.Add('pdf');
      Parameters.Add(aSrcODT);
      if not aOutDir.IsEmpty then
      begin
        Parameters.Add('--outdir');
        Parameters.Add(aOutDir);
      end;
      Options := Options + [poWaitOnExit];
      Execute;
      Result:=True;
    finally
      Free;
    end;
  end;
end;

end.

