unit Image;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  AdBitmap, DIB, StdCtrls, Menus, AdDraws, ExtCtrls, DXDraws;

type
  TForm1 = class(TForm)
    OuvreBMP: TOpenDialog;
    MainMenu1: TMainMenu;
    Fichier1: TMenuItem;
    Charger1: TMenuItem;
    Sauver1: TMenuItem;
    SauveItems: TSaveDialog;
    AllItems: TImage;
    UneBrique: TImage;
    procedure Charger1Click(Sender: TObject);
    procedure Sauver1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OnIdle(Sender: TObject; var Done: Boolean);
  private
  Compteur    :Integer;
  procedure SauveCliped(X,Y,Largeur,Hauteur,AnimWidth,AnimHeight:Integer;Fichier:String;Sauve:Boolean);
  procedure Sauve;
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;
  Sprites: TAdImageList;
  AdDraw : TAdDraw;
  Bitmap : TadImage ;
  LitteBitmap : TadBitmap ;

implementation

{$R *.DFM}

procedure TForm1.SauveCliped(X,Y,Largeur,Hauteur,AnimWidth,AnimHeight:Integer;Fichier:String;Sauve:Boolean);
var I, J :integer;
begin
  UneBrique.Width := Largeur ;
  UneBrique.height := Largeur ;
  AllItems.Canvas.Draw ( X, Y, UneBrique.Picture.Bitmap );
  with UneBrique.Picture.Bitmap do
    Begin
      TransparentColor := clBlack;
      UneBrique.Picture.Bitmap.SaveToFile(ExtractFilePath ( SauveItems.FileName ) +Fichier);
    End;
  LitteBitmap.LoadFromFile(ExtractFilePath ( SauveItems.FileName ) +Fichier);
  LitteBitmap.AssignTo(Sprites.add ( ExtractFileName ( Fichier )));
  with Sprites.Find ( ExtractFileName ( Fichier )) do
    Begin
      PatternWidth:=AnimWidth;
      patternHeight:=AnimHeight;
      Paint;

    End;
end;

procedure TForm1.Sauver1Click(Sender: TObject);
begin
  SauveItems.InitialDir:= ExtractFilePath ( Application.exeName ) +'..\IMAGES';
  If ( SauveItems.Execute ) Then
    Sauve;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Sprites := nil ;
  Addraw := TAdDraw.Create ( Self);
  AdDraw.DllName :=
  {$IFDEF FPC}
    'AndorraOGLLaz.dll';
  Application.OnIdle := OnIdle;
  if not AdDraw.Initialize Then
    Begin
  {$ELSE}
    'AndorraDX93D.dll';
  if AdDraw.Initialize then
    begin
      Application.OnIdle := OnIdle;
    end
   else
     begin

  {$ENDIF}
      ShowMessage('Cannot init addraw');

       halt; //<-- Completely shuts down the application
     end;

end;

procedure TForm1.OnIdle(Sender: TObject; var Done: Boolean);
begin
  if not assigned (Sprites) Then
    Begin
      Sprites := TAdImageList.Create ( AdDraw );
      Bitmap := TadImage.Create ( AdDraw ) ;
      LitteBitmap := TadBitmap.Create ;
    End;
  if AdDraw.CanDraw then
  begin
    //Calculate the time difference.
    Application.ProcessMessages;
    AdDraw.BeginScene;

    AdDraw.ClearSurface(clBlack);

    Bitmap.Draw ( AdDraw, 0, 0, 0 );

    AdDraw.EndScene;

    AdDraw.Flip;
  end;
  Done := false;

end;

procedure TForm1.Sauve;
var  Images :integer;
begin
Sprites.Clear();
Compteur:=0;
for Images:=1 to 25 do
 begin
 SauveCliped(0,(Images-1)*16,192,16,32,16,'Brique'+IntToStr(Images)+'.BMP',False);
 end;
SauveCliped(192,0,192,16,32,16,'Brique26.BMP',False);
SauveCliped(448,16,32,16,16,16,'Balle.BMP',False);
SauveCliped(192,256,352,144,0,0,'Presente.BMP',True);

{Oui non }
SauveCliped(195,224,44,16,0,0,'Oui.BMP',False);
SauveCliped(530,0,46,16,0,0,'Non.BMP',False);

{ Palette de gauche }
for Images:=1 to 2 do
  SauveCliped(194,32+(Images-1)*48,24,48,0,0,'PaletteGTire'+IntToStr(Images)+'.BMP',True);
for Images:=1 to 2 do
  SauveCliped(226,32+(Images-1)*48,24,48,0,0,'PaletteGNeTire'+IntToStr(Images)+'.BMP',True);
SauveCliped(194,128,24,48,0,0,'PaletteGInvisible.BMP',True);
SauveCliped(194,176,24,48,0,0,'PaletteGColle.BMP',True);
SauveCliped(290,64,24,80,0,0,'PaletteGGrand.BMP',True);
SauveCliped(258,32,24,63,0,0,'PaletteGMoyen.BMP',True);
SauveCliped(258,96,24,48,0,0,'PaletteGPetit.BMP',True);
SauveCliped(290,32,24,31,0,0,'PaletteGMinus.BMP',True);
SauveCliped(224,144,38,39,0,0,'BoucheGauche1.BMP',True);
SauveCliped(224,153,38,30,0,0,'BoucheGauche2.BMP',True);
SauveCliped(224,153,38,39,0,0,'BoucheGauche3.BMP',True);

{ Palette de droite }
SauveCliped(598,0,24,48,0,0,'PaletteDTire2.BMP',True);
SauveCliped(598,48,24,48,0,0,'PaletteDTire1.BMP',True);
SauveCliped(566,32,24,48,0,0,'PaletteDNeTire2.BMP',True);
SauveCliped(566,32+48,24,48,0,0,'PaletteDNeTire1.BMP',True);
SauveCliped(598,96,24,48,0,0,'PaletteDInvisible.BMP',True);
SauveCliped(598,144,24,48,0,0,'PaletteDColle.BMP',True);
SauveCliped(502,64,24,80,0,0,'PaletteDGrand.BMP',True);
SauveCliped(534,32,24,63,0,0,'PaletteDMoyen.BMP',True);
SauveCliped(534,96,24,48,0,0,'PaletteDPetit.BMP',True);
SauveCliped(502,32,24,31,0,0,'PaletteDMinus.BMP',True);
SauveCliped(282,144,38,39,0,0,'BoucheDroite1.BMP',True);
SauveCliped(282,153,38,30,0,0,'BoucheDroite2.BMP',True);
SauveCliped(282,153,38,39,0,0,'BoucheDroite3.BMP',True);

{ Palette du haut }
SauveCliped(320,37,112,20,0,0,'PaletteHGrand.BMP',True);
SauveCliped(320,69,96,20,0,0,'PaletteHMoyen.BMP',True);
SauveCliped(320,101,80,20,0,0,'PaletteHPetit.BMP',True);
SauveCliped(320,133,62,20,0,0,'PaletteHMinus.BMP',True);
SauveCliped(240,197,80,20,0,0,'PaletteHTire2.BMP',True);
SauveCliped(320,197,80,20,0,0,'PaletteHTire1.BMP',True);
SauveCliped(240,229,80,20,0,0,'PaletteHNeTire2.BMP',True);
SauveCliped(320,229,80,20,0,0,'PaletteHNeTire1.BMP',True);
SauveCliped(320,165,80,20,0,0,'PaletteHInvisible.BMP',True);
SauveCliped(560,229,80,20,0,0,'PaletteHColle.BMP',True);
SauveCliped(496,144,40,38,0,0,'BoucheHaut1.BMP',True);
SauveCliped(504,144,30,38,0,0,'BoucheHaut2.BMP',True);
SauveCliped(504,144,40,38,0,0,'BoucheHaut3.BMP',True);

{ Palette du bas }
SauveCliped(432,39,62,20,0,0,'PaletteBMinus.BMP',True);
SauveCliped(417,71,80,20,0,0,'PaletteBPetit.BMP',True);
SauveCliped(400,103,96,20,0,0,'PaletteBMoyen.BMP',True);
SauveCliped(384,135,112,20,0,0,'PaletteBGrand.BMP',True);
SauveCliped(400,199,80,20,0,0,'PaletteBTire1.BMP',True);
SauveCliped(480,199,80,20,0,0,'PaletteBTire2.BMP',True);
SauveCliped(400,231,80,20,0,0,'PaletteBNeTire1.BMP',True);
SauveCliped(480,231,80,20,0,0,'PaletteBNeTire2.BMP',True);
SauveCliped(416,167,80,20,0,0,'PaletteBInvisible.BMP',True);
SauveCliped(560,199,80,20,0,0,'PaletteBColle.BMP',True);
SauveCliped(544,154,39,38,0,0,'BoucheBas1.BMP',True);
SauveCliped(553,154,30,38,0,0,'BoucheBas2.BMP',True);
SauveCliped(553,154,39,38,0,0,'BoucheBas3.BMP',True);
//if SauveItems.execute then
Sprites.SaveToFile(ExtractFilePath ( SauveItems.FileName )  + 'Stage.ail');
end;

procedure TForm1.Charger1Click(Sender: TObject);
begin
OuvreBMP.InitialDir := ExtractFilePath ( Application.exeName ) +'..\IMAGES';
if OuvreBMP.execute then
 begin
 AllItems.Picture.LoadFromFile(OuvreBMP.FileName);
 try
 AllItems.SetBounds(0,0,40,400);
 except
 End;
 UneBrique.Picture.Bitmap.Palette:=AllItems.Picture.Bitmap.Palette;
 end;
end;

end.
