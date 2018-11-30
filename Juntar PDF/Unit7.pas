unit Unit7;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TForm7 = class(TForm)
    Button1: TButton;
    OpenDialog1: TOpenDialog;
    procedure Button1Click(Sender: TObject);
  private
  public
  end;

var
  Form7: TForm7;

implementation

uses
  UJuntaPDF;

{$R *.dfm}

procedure TForm7.Button1Click(Sender: TObject);
var
  AJuntaPDf: TJuntaPDF;
begin
  Button1.Enabled := False;
  AJuntaPDf := TJuntaPDF.Create;
  try
    // AJuntaPDf.SalvaArquivo;
    AJuntaPDf.Executa;
  finally
    FreeAndNil(AJuntaPDf);
    Button1.Enabled := true;
  end;
end;

end.
