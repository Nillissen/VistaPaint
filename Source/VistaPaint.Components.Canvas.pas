unit VistaPaint.Components.Canvas;

{$SCOPEDENUMS ON}

interface

uses
  System.Classes, System.SysUtils, System.Types, System.UITypes,
  FMX.Colors, FMX.Controls, FMX.Graphics, FMX.Objects, FMX.Surfaces, FMX.Types;


type
  TVistaPaintTool = (
    None, DottedDraw, ContinuousDraw, StraightLine, CurvedLine, Fill, Spray,
    Rectangle, Ellipse);


type
  TVistaPaintCanvas = class(FMX.Objects.TPaintBox)
  private
    {$IFDEF POSIX}
    FFillBrush : TStrokeBrush;
    {$ENDIF}
    FIsDrawing : Boolean;
    /// <summary>
    ///   The canvas that is drawn too.
    /// </summary>
    FCanvas : TBitmap;
    /// <summary>
    ///   The size of the canvas.
    /// </summary>
    FCanvasRect : TRectF;
    FTool : TVistaPaintTool;
    FThickness : Single;
    FForgroundColor : TAlphaColor;
    FBackgroundColor : TAlphaColor;
    FToolFill : Boolean;
    /// <summary>
    ///   Current drawing Brush.
    /// </summary>
    FBrush : TBrush;
    /// <summary>
    ///   Current drawing Stroke.
    /// </summary>
    FStrokeBrush : TStrokeBrush;
    FTrackFrom : TPointF;
    FTrackTo : TPointF;
    FMouseMoved : Boolean;
    FMouseDowned : Boolean;
    procedure SetForegroundColor(AValue: TAlphaColor);
    procedure SetBackgroundColor(AValue: TAlphaColor);
    procedure SetThickness(AValue: Single);
    procedure SetToolFill(AValue: Boolean);
  private
    procedure StartDrawing(APoint: TPointF);
    procedure EndDrawing(APoint: TPointF);
    procedure DoDraw(ACanvas: TCanvas; const ADrawAll: Boolean = True);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
  public { methods }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure MouseLeave;
    procedure FillColor(AColor: TAlphaColor);
    procedure SaveToFile(const AFileName: string; AQuality: Integer);
    procedure SaveToBitmap(ABitmap: TBitmap); overload;
    procedure LoadFromBitmap(ABitmap: TBitmap);
    function GetCanvasWidth: Integer;
    function GetCanvasHeight: Integer;
    procedure SaveToBitmap(ABitmap: TBitmap; AWidth, AHeight: Integer); overload;
    {$IFDEF POSIX}
    procedure FillerMod;
    {$ENDIF}
  public { properties }
    property ForegroundColor : TAlphaColor read FForgroundColor write SetForegroundColor;
    property BackgroundColor : TAlphaColor read FBackgroundColor write SetBackgroundColor;
    property Thickness : Single read FThickness write SetThickness;
    property Tool : TVistaPaintTool read FTool write FTool;
    property ToolFill : Boolean read FToolFill write SetToolFill;
  end;


procedure Register;


implementation


procedure Register;
begin
    RegisterComponents('VistaPaintCanvas', [TVistaPaintCanvas]);
end;


{ TVistaPaintCanvas }

constructor TVistaPaintCanvas.Create(AOwner: TComponent);
begin
    inherited;

    Self.Parent := TFmxObject(AOwner);
    Self.Align := TAlignLayout.Client;

    FTool := TVistaPaintTool.ContinuousDraw;

    FToolFill := False;
    FIsDrawing := False;
    FThickness := 1;
    FTrackFrom := PointF(-1, -1);
    FTrackTo := PointF(-1, -1);

    FCanvasRect := RectF(0, 0, Self.Width, Self.Height);
    FCanvas := TBitmap.Create(Round(FCanvasRect.Width), Round(FCanvasRect.Height));

    Self.SetBackgroundColor(TAlphaColorRec.White);
    Self.SetForegroundColor(TAlphaColorRec.Black);
    Self.FillColor(FBackgroundColor);

    {$IFDEF POSIX}
    Self.FillerMod;
    {$ENDIF}
end;

destructor TVistaPaintCanvas.Destroy;
begin
    if Assigned(FBrush) then
        FBrush.Free;

    if Assigned(FStrokeBrush) then
        FStrokeBrush.Free;

    {$IFDEF POSIX}
    if FFillBrush <> nil then
        FFillBrush.Free;
    {$ENDIF}
  
    FCanvas.Free;
    inherited;
end;

procedure TVistaPaintCanvas.DoDraw(ACanvas: TCanvas; const ADrawAll: Boolean);
var
  LDrawRect : TRectF;
begin
    if ADrawAll then
        Self.Canvas.DrawBitmap(FCanvas, FCanvasRect, FCanvasRect, 1);
        
    if (FTool = TVistaPaintTool.None) or (not FIsDrawing) then
        Exit;

    LDrawRect := TRectF.Create(FTrackFrom, FTrackTo);

    ACanvas.BeginScene;
    try
        case FTool of
          {$IFDEF MSWINDOWS}
//          TPaintTool.DottedDraw:
              // TODO: Add functionality.

          TVistaPaintTool.ContinuousDraw:
              ACanvas.DrawLine(FTrackFrom, FTrackTo, 1, FStrokeBrush);
          {$ENDIF}

          TVistaPaintTool.StraightLine:
              ACanvas.DrawLine(FTrackFrom, FTrackTo, 1, FStrokeBrush);

//          TPaintTool.CurvedLine:
              // TODO: Add functionality.

//          TPaintTool.Fill:
              // TODO: Add functionality.

//          TPaintTool.Spray:
              // TODO: Add functionality.

          TVistaPaintTool.Rectangle:
            begin
                if FToolFill then
                    ACanvas.FillRect(LDrawRect, 0, 0, [TCorner.TopLeft], 1, FBrush);
                ACanvas.DrawRect(LDrawRect, 0, 0, [TCorner.TopLeft], 1, FStrokeBrush);
            end;

          TVistaPaintTool.Ellipse:
            begin
                if FToolFill then
                    ACanvas.FillEllipse(LDrawRect, 1, FBrush);
                ACanvas.DrawEllipse(LDrawRect, 1, FStrokeBrush);
            end;

//          TPaintTool.Fill:
              // TODO: Add functionality.
//              ACanvas.Clear(FBackgroundColor);

        end;
    finally
        ACanvas.EndScene;
    end;
end;

procedure TVistaPaintCanvas.EndDrawing(APoint: TPointF);
begin
    if not FIsDrawing then
        Exit;

    FTrackTo := PointF(APoint.X, APoint.Y);
    Self.DoDraw(FCanvas.Canvas, False);

    FIsDrawing := False;

    FTrackFrom := PointF(-1, -1);
    FTrackTo := PointF(-1, -1);
end;

procedure TVistaPaintCanvas.FillColor(AColor: TAlphaColor);
begin
    FCanvas.Canvas.BeginScene;
    try
        FCanvas.Canvas.Clear(AColor);
    finally
        FCanvas.Canvas.EndScene;
    end;
end;

procedure TVistaPaintCanvas.MouseLeave;
begin
//    if not MouseDowned and not fdrawing then
//        StartDrawing(PointF(X, Y));

    if not FMouseMoved then
    begin
        {$IFDEF MSWINDOWS}
        InvalidateRect(FCanvasRect);

        case FTool of
          TVistaPaintTool.ContinuousDraw:
            begin
                Self.DoDraw(FCanvas.Canvas, False);
                FTrackFrom := FTrackTo;
            end;
        end;
        {$ENDIF}
    end;

    FMouseMoved := False;
    FMouseDowned := False;

    FIsDrawing := False;

    {$IFDEF POSIX}
    InvalidateRect(fdrawrect);
    {$ENDIF}
end;

procedure TVistaPaintCanvas.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
    inherited;

    if not FIsDrawing then
      StartDrawing(PointF(X, Y));

    FMouseDowned := True;
end;

procedure TVistaPaintCanvas.MouseMove(Shift: TShiftState; X, Y: Single);
{$IFDEF POSIX}
var
  Radius : Single;
  xDir, yDir : Single;
  Dx, Dy : Single;
  Ratio : Single;
  MoveX, MoveY : Single;
{$ENDIF}
begin
    inherited;

    if not FIsDrawing then
        Exit;

  {$IFDEF POSIX}
    Radius := fThickness / 2;
  {$ENDIF}

    FTrackTo := PointF(X, Y);

    InvalidateRect(FCanvasRect);

    case FTool of
      TVistaPaintTool.ContinuousDraw:
        begin
            {$IFDEF POSIX}
            if pFrom.Round <> pTo.Round then
            begin
                { Direction detection from pFrom to pTo }
                { to adjust start center                }
                if pTo.Y >= pFrom.Y then yDir := -1 else yDir := 1;
                if pTo.X >= pFrom.X then xDir := -1 else xDir := 1;

                { Quantify movement }
                Dx := Abs(pTo.X - pFrom.X);
                Dy := Abs(pTo.Y - pFrom.Y);

                if Abs(Dy) > Abs(Dx) then
                begin
                    Ratio := Abs(Radius / Dy * Dx);
                    MoveY := Radius * yDir;
                    pFrom.Y := pFrom.Y + MoveY;
                    MoveX := Ratio * xDir;
                    pFrom.X := pFrom.X + MoveX;
                end else
                begin
                    Ratio := Abs(Radius / Dx * Dy);
                    MoveX := Radius * xDir;
                    pFrom.X := pFrom.X + MoveX;
                    MoveY := Ratio * yDir;
                    pFrom.Y := pFrom.Y + MoveY;
                end;

                fdrawbmp.Canvas.BeginScene;
                try
                   fdrawbmp.Canvas.DrawLine(pFrom, pTo, 1, FFillBrush);
                finally
                   fdrawbmp.Canvas.EndScene;
                end;

                { Direction detection end of line }
                { to adjust end of line center    }
                if pTo.Y >= pFrom.Y then yDir := -1 else yDir := 1;
                if pTo.X >= pFrom.X then xDir := -1 else xDir := 1;

                { Quantify movement }

                Dx := Abs(pTo.X - pFrom.X);
                Dy := Abs(pTo.Y - pFrom.Y);

                if Abs(Dy) > Abs(Dx) then
                begin
                    Ratio := Abs(Radius / Dy * Dx);
                    MoveY := Radius * yDir;
                    pFrom.Y := pTo.Y + MoveY;
                    MoveX := Ratio * xDir;
                    pFrom.X := pTo.X + MoveX;
                end else
                begin
                    Ratio := Abs(Radius / Dx * Dy);
                    MoveX := Radius * xDir;
                    pFrom.X := pTo.X + MoveX;
                    MoveY := Ratio * yDir;
                    pFrom.Y := pTo.Y + MoveY;
                end;
            end;
            {$ENDIF}
            {$IFDEF MSWINDOWS}
            Self.DoDraw(FCanvas.Canvas,false);
            FTrackFrom := FTrackTo;
            {$ENDIF}
        end;
    end;

    FMouseMoved := True;
end;

procedure TVistaPaintCanvas.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
    inherited;

    if not FMouseDowned and not FIsDrawing then
        StartDrawing(PointF(X, Y));

    if not FMouseMoved then
    begin
        {$IFDEF MSWINDOWS}
        FTrackTo := PointF(X, Y);

        InvalidateRect(FCanvasRect);

        case FTool of
          TVistaPaintTool.ContinuousDraw:
          begin
              Self.DoDraw(FCanvas.Canvas, False);
              FTrackFrom := FTrackTo;
          end;
        end;
        {$ENDIF}
    end;

    FMouseMoved := False;
    FMouseDowned := False;

    EndDrawing(PointF(X, Y));
    {$IFDEF POSIX}
    InvalidateRect(fdrawrect);
    {$ENDIF}
end;

procedure TVistaPaintCanvas.Paint;
begin
    inherited;

    if csDesigning in ComponentState then
        Exit;

    Self.DoDraw(Self.Canvas);
end;

procedure TVistaPaintCanvas.SaveToFile(const AFileName: string; AQuality: Integer);
begin
    var SaveParams : TBitmapCodecSaveParams;
    SaveParams.Quality := AQuality;

    FCanvas.SaveToFile(AFileName, @SaveParams);
end;

procedure TVistaPaintCanvas.SaveToBitmap(ABitmap: TBitmap);
begin
    ABitmap.Assign(FCanvas);
end;

procedure TVistaPaintCanvas.SaveToBitmap(ABitmap: TBitmap; AWidth, AHeight: Integer);
begin
    if ABitmap.Width = 0 then
        Exit;

    if FCanvas <> nil then
        ABitmap.Assign(
            FCanvas.CreateThumbnail(AWidth, AHeight));
end;

procedure TVistaPaintCanvas.LoadFromBitmap(ABitmap: TBitmap);
var
  r, rd: TRectF;
begin
    if Assigned(FCanvas) then
    begin
        r := TRectF.Create(PointF(0,0), ABitmap.Width, ABitmap.Height);
        rd := TRectF.Create(PointF(0,0), ABitmap.Width, ABitmap.Height);

        FCanvas.Canvas.BeginScene;
        try
            FCanvas.Canvas.DrawBitmap(ABitmap, r, rd, 1);
        finally
            FCanvas.Canvas.EndScene;
        end;

        InvalidateRect(FCanvasRect);
    end;
end;


function TVistaPaintCanvas.GetCanvasWidth: Integer;
begin
    Result := FCanvas.Width;
end;

function TVistaPaintCanvas.GetCanvasHeight: Integer;
begin
    Result := FCanvas.Height;
end;

procedure TVistaPaintCanvas.SetBackgroundColor(AValue: TAlphaColor);
begin
    if AValue = FBackgroundColor then
        Exit;

    if Assigned(FBrush) then
      FBrush.Free;

    FBackgroundColor := AValue;
    FBrush := TBrush.Create(TBrushKind.Solid, FBackgroundColor);
end;

procedure TVistaPaintCanvas.SetForegroundColor(AValue: TAlphaColor);
begin
    if AValue = FForgroundColor then
        Exit;

    if Assigned(FStrokeBrush) then
        FStrokeBrush.Free;

    FForgroundColor:=AValue;

    FStrokeBrush:=TStrokeBrush.Create(TBrushKind.Solid, FForgroundColor);
    FStrokeBrush.DefaultColor := FForgroundColor;
    FStrokeBrush.Thickness := FThickness;

    {$IFDEF POSIX}
    Self.FillerMod;
    {$ENDIF}
end;

procedure TVistaPaintCanvas.SetToolFill(AValue: Boolean);
begin
    if FToolFill <> AValue then
        FToolFill := AValue;
end;

procedure TVistaPaintCanvas.SetThickness(AValue: Single);
begin
    if AValue = FThickness then
        Exit;

    if Assigned(FStrokeBrush) then
        FStrokeBrush.Free;

    FThickness := AValue;

    FStrokeBrush := TStrokeBrush.Create(TBrushKind.Solid, FForgroundColor);
    FStrokeBrush.DefaultColor := FForgroundColor;
    FStrokeBrush.Thickness := FThickness;
    FStrokeBrush.Cap := TStrokeCap.Round;

    {$IFDEF POSIX}
    Self.FillerMod;
    {$ENDIF}
end;

procedure TVistaPaintCanvas.StartDrawing(APoint: TPointF);
begin
    if csDesigning in ComponentState then
        Exit;

    if (FIsDrawing) or (FTool = TVistaPaintTool.None) then
        Exit;

    FTrackFrom := PointF(APoint.X, APoint.Y);
    FTrackTo := PointF(APoint.X, APoint.Y);

    FIsDrawing := True;
end;

{$IFDEF POSIX}
procedure TVistaPaintCanvas.FillerMod;
begin
    if FFillBrush = nil then
        FFillBrush := TStrokeBrush.Create(TBrushKind.bkSolid, ffgcolor);

    FFillBrush.Thickness := fThickness;
    FFillBrush.Cap := TStrokeCap.scRound;
    FFillBrush.Join := TStrokeJoin.sjRound;
    FFillBrush.Color := ffgcolor;
end;
{$ENDIF}


end.
