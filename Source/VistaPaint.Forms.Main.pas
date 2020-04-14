unit VistaPaint.Forms.Main;

interface

uses
  System.IOUtils, System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.StdCtrls, FMX.Colors, FMX.ExtCtrls, FMX.ListBox, FMX.ListView.Types,
  FMX.ListView, FMX.Layouts, FMX.Objects, FMX.Edit, System.Actions,
  FMX.ActnList, FMX.StdActns, FMX.MediaLibrary.Actions, FMX.EditBox,
  FMX.SpinBox, FMX.Controls.Presentation, FMX.MultiView,
  VistaPaint.Components.Canvas;


type
  TMainForm = class(TForm)
    ButtonSave: TSpeedButton;
    ToolPalette: TPanel;
    ToolDottedDraw: TSpeedButton;
    ImageToolDottedDraw: TImage;
    ToolContinuousDraw: TSpeedButton;
    ImageToolContinuousDraw: TImage;
    ToolStraightLine: TSpeedButton;
    ImageToolStraightLine: TImage;
    ToolCurvedLine: TSpeedButton;
    ImageToolCurvedLine: TImage;
    ToolFill: TSpeedButton;
    Image5: TImage;
    ToolSpray: TSpeedButton;
    ImageToolSpray: TImage;
    ToolSquare: TSpeedButton;
    ImageToolSquare: TImage;
    ToolCircle: TSpeedButton;
    ImageToolCircle: TImage;
    ToolClear: TSpeedButton;
    ImageToolClear: TImage;
    CheckboxFill: TCheckBox;
    SpinBoxThickness: TSpinBox;
    ComboColorBoxForground: TComboColorBox;
    ComboColorBoxBackground: TComboColorBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ComboColorBoxBackgroundChange(Sender: TObject);
    procedure ComboColorBoxForgroundChange(Sender: TObject);
    procedure ButtonSaveClick(Sender: TObject);
    procedure SpinBoxThicknessChange(Sender: TObject);
    procedure CheckboxFillChange(Sender: TObject);
    procedure ToolButtonClick(Sender: TObject);
  private
    FCanvas : TVistaPaintCanvas;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}


{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
begin
    { Create and initialize the main canvas. }
    FCanvas := TVistaPaintCanvas.Create(Self);
    FCanvas.ForegroundColor := ComboColorBoxForground.Color;
    FCanvas.BackgroundColor := ComboColorBoxBackground.Color;
    FCanvas.Align := TAlignLayout.Center;

    { Ensure that the tool palette is above all other controls. }
    ToolPalette.BringToFront;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
    FCanvas.Free;
end;

procedure TMainForm.ComboColorBoxBackgroundChange(Sender: TObject);
begin
    FCanvas.BackgroundColor := ComboColorBoxBackground.Color;
end;

procedure TMainForm.ComboColorBoxForgroundChange(Sender: TObject);
begin
    FCanvas.ForegroundColor := ComboColorBoxForground.Color;
end;

procedure TMainForm.CheckboxFillChange(Sender: TObject);
begin
    FCanvas.ToolFill := CheckboxFill.IsChecked;
end;

procedure TMainForm.SpinBoxThicknessChange(Sender: TObject);
begin
    FCanvas.Thickness := SpinBoxThickness.Value;
end;

procedure TMainForm.ButtonSaveClick(Sender: TObject);
begin
    var FileName : string := InputBox('Save File', 'Enter a File Name', 'drawing.jpg');
    if not FileName.IsEmpty then
    begin
        FileName := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, FileName);
        FCanvas.SaveToFile(FileName, 93);
    end;
end;

procedure TMainForm.ToolButtonClick(Sender: TObject);
begin
    { Assign the selected painting tool to the canvas. }
    FCanvas.Tool := TVistaPaintTool(
        TControl(Sender).Tag);
end;


end.
