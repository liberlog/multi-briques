unit Image;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DXDraws, DIB, StdCtrls, Menus, ExtCtrls, PNGImage;

type
  TForm1 = class(TForm)
    Items:TImage;
    Sprites: TDXImageList;
    OuvreBMP: TOpenDialog;
    MainMenu1: TMainMenu;
    Fichier1: TMenuItem;
    Charger1: TMenuItem;
    Sauver1: TMenuItem;
    SauveItems: TSaveDialog;
    UneBrique: TImage;
    procedure Charger1Click(Sender: TObject);
    procedure Sauver1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
  Compteur    :Integer;
  PNG : TPngObject;
  procedure SauveCliped(X,Y,Largeur,Hauteur:Integer;Fichier:String;Transparent:Boolean);
  procedure Sauve;
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.SauveCliped(X,Y,Largeur,Hauteur:Integer;Fichier:String;Transparent:Boolean);
var I, J :integer;
begin
UneBrique.Width:=Largeur;
UneBrique.Height:=Hauteur;
UneBrique.Picture.Bitmap.PixelFormat := pf24bit ;
UneBrique.Picture.Bitmap.SetSize(Largeur,Hauteur);
for J:=0 to Hauteur-1 do for I:=0 to Largeur-1 do
 UneBrique.Picture.Bitmap.Canvas.Pixels[I,J]:=Items.Picture.Bitmap.Canvas.Pixels[X+I,Y+J];
UneBrique.Picture.Bitmap.Transparent := Transparent;
UneBrique.Picture.Bitmap.TransparentColor := clBlack;
UneBrique.Picture.Bitmap.SaveToFile(ExtractFilePath ( SauveItems.FileName ) +Fichier + '.BMP' );

PNG.Assign( UneBrique.Picture.Bitmap );
//for J:=0 to Hauteur-1 do for I:=0 to Largeur-1 do
// PNG.Pixels[I,J]:=Items.Picture.Bitmap.Canvas.Pixels[X+I,Y+J];
PNG.Transparent := Transparent;
PNG.TransparentColor := clBlack;
PNG.SaveToFile(ExtractFilePath ( SauveItems.FileName ) +Fichier + '.PNG' );
end;

procedure TForm1.Sauver1Click(Sender: TObject);
begin
  SauveItems.InitialDir:= ExtractFilePath ( OuvreBMP.FileName );
  If ( SauveItems.Execute ) Then
    Sauve;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
PNG := TPngObject.Create ;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  PNG.Free;
end;

procedure TForm1.Sauve;
var  Images :integer;
     ImagesX : Integer;
     ImagesY : Integer;
     Nom : String ;
begin
Sprites.Items.Clear();
Compteur:=0;
for Images:=1 to 25 do
 begin
 SauveCliped(0,(Images-1)*16,192,16,'Brique'+IntToStr(Images),True);
 end;
SauveCliped(192,0,192,16,'Brique26',True);
for Images:=0 to 9 do
 begin
 SauveCliped(192*2+(Images)*8,0,8,16,'Chiffre'+IntToStr(Images),True);
 end;
SauveCliped(448,16,32,16,'Balle',True);
for ImagesX := 0 to 1 do
  for ImagesY := 0 to 1 do
    Begin
      SauveCliped(192+ImagesX*(352 div 2),256+ImagesY*(144 div 2),352 div 2,144 div 2,'Presente' + IntToStr ( ImagesY ) + IntToStr ( ImagesX ),True);
    End;
ImagesX:= 0;
ImagesY:= 0;
for Images:=0 to 51 do
 begin
   If Images mod 6 = 0 Then
     Begin
       if ( Images > 0 ) Then inc ( ImagesY );
       ImagesX:= 0;
     End;
   case Images of
     0..9  : Nom := 'Caractere'+ IntToStr ( Images );
     10..19 : Nom := 'ChiffreG'+ IntToStr ( Images - 10 );
     20     : Nom := 'Score2Points';
     21     : Nom := 'ScoreQui';
     22..48 : Nom := 'Char'+chr ( ord ( 'A' ) + Images -22 );
     49     : Nom := 'ASlash';
   end;

   SauveCliped(544+(ImagesX)*16,256+(ImagesY)*16,16,16,Nom,True);
   inc ( ImagesX );
 end;
{Oui non }
SauveCliped(195,224,44,16,'ActifOui',True);
SauveCliped(195,224+16,44,16,'Oui',True);
SauveCliped(530,0,46,16,'ActifNon',True);
SauveCliped(530,16,46,16,'Non',True);

{ Palette de gauche }
for Images:=1 to 2 do
  SauveCliped(194,32+(Images-1)*48,24,48,'PaletteGTire'+IntToStr(Images),True);
for Images:=1 to 2 do
  SauveCliped(226,32+(Images-1)*48,24,48,'PaletteGNeTire'+IntToStr(Images),True);
SauveCliped(194,128,24,48,'PaletteGInvisible',True);
SauveCliped(194,176,24,48,'PaletteGColle',True);
SauveCliped(290,64,24,80,'PaletteGGrand',True);
SauveCliped(258,32,24,63,'PaletteGMoyen',True);
SauveCliped(258,96,24,48,'PaletteGPetit',True);
SauveCliped(290,32,24,31,'PaletteGMinus',True);
SauveCliped(224,144,38,39,'BoucheGauche1',True);
SauveCliped(224,153,38,30,'BoucheGauche2',True);
SauveCliped(224,153,38,39,'BoucheGauche3',True);

{ Palette de droite }
SauveCliped(598,0,24,48,'PaletteDTire2',True);
SauveCliped(598,48,24,48,'PaletteDTire1',True);
SauveCliped(566,32,24,48,'PaletteDNeTire2',True);
SauveCliped(566,32+48,24,48,'PaletteDNeTire1',True);
SauveCliped(598,96,24,48,'PaletteDInvisible',True);
SauveCliped(598,144,24,48,'PaletteDColle',True);
SauveCliped(502,64,24,80,'PaletteDGrand',True);
SauveCliped(534,32,24,63,'PaletteDMoyen',True);
SauveCliped(534,96,24,48,'PaletteDPetit',True);
SauveCliped(502,32,24,31,'PaletteDMinus',True);
SauveCliped(282,144,38,39,'BoucheDroite1',True);
SauveCliped(282,153,38,30,'BoucheDroite2',True);
SauveCliped(282,153,38,39,'BoucheDroite3',True);

{ Palette du haut }
SauveCliped(320,37,112,20,'PaletteHGrand',True);
SauveCliped(320,69,96,20,'PaletteHMoyen',True);
SauveCliped(320,101,80,20,'PaletteHPetit',True);
SauveCliped(320,133,62,20,'PaletteHMinus',True);
SauveCliped(240,197,80,20,'PaletteHTire2',True);
SauveCliped(320,197,80,20,'PaletteHTire1',True);
SauveCliped(240,229,80,20,'PaletteHNeTire2',True);
SauveCliped(320,229,80,20,'PaletteHNeTire1',True);
SauveCliped(320,165,80,20,'PaletteHInvisible',True);
SauveCliped(560,229,80,20,'PaletteHColle',True);
SauveCliped(496,144,40,38,'BoucheHaut1',True);
SauveCliped(504,144,30,38,'BoucheHaut2',True);
SauveCliped(504,144,40,38,'BoucheHaut3',True);

{ Palette du bas }
SauveCliped(432,39,62,20,'PaletteBMinus',True);
SauveCliped(417,71,80,20,'PaletteBPetit',True);
SauveCliped(400,103,96,20,'PaletteBMoyen',True);
SauveCliped(384,135,112,20,'PaletteBGrand',True);
SauveCliped(400,199,80,20,'PaletteBTire1',True);
SauveCliped(480,199,80,20,'PaletteBTire2',True);
SauveCliped(400,231,80,20,'PaletteBNeTire1',True);
SauveCliped(480,231,80,20,'PaletteBNeTire2',True);
SauveCliped(416,167,80,20,'PaletteBInvisible',True);
SauveCliped(560,199,80,20,'PaletteBColle',True);
SauveCliped(544,154,39,38,'BoucheBas1',True);
SauveCliped(553,154,30,38,'BoucheBas2',True);
SauveCliped(553,154,39,38,'BoucheBas3',True);
end;

procedure TForm1.Charger1Click(Sender: TObject);
begin
OuvreBMP.InitialDir := ExtractFilePath ( Application.exeName ) +'..\';
if OuvreBMP.execute then
 begin
 Items.Picture.Bitmap.LoadFromFile(OuvreBMP.FileName);
 try
 Items.Picture.Bitmap.SetSize(640,400);
 except
 End;
 end;
end;

end.
