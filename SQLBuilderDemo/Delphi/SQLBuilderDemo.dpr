program SQLBuilderDemo;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {FormMain},
  SQLBuilder in 'SQLBuilder.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
