program VistaPaint;

uses
  FMX.Forms,
  VistaPaint.Components.Canvas in 'Source\VistaPaint.Components.Canvas.pas',
  VistaPaint.Forms.Main in 'Source\VistaPaint.Forms.Main.pas' {MainForm};

{$R *.res}

begin
  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
