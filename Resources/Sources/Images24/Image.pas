unit Image;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DXDraws, DIB, StdCtrls, Menus;

type
  TForm1 = class(TForm)
    Items: TDXPaintBox;
    UneBrique: TDXPaintBox;
    Sprites: TDXImageList;
    OuvreBMP: TOpenDialog;
    MainMenu1: TMainMenu;
    Fichier1: TMenuItem;
    Charger1: TMenuItem;
    Sauver1: TMenuItem;
    SauveItems: TSaveDialog;
    procedure Charger1Click(Sender: TObject);
  private
  Compteur    :Integer;
  procedure SauveCliped(X,Y,Largeur,Hauteur:Integer;Fichier:String;Sauve:Boolean);
  procedure SauveOuiNon(X,Y,Largeur,Hauteur:Integer;Fichier:String);
  procedure SauveItem(Largeur,Hauteur:Integer;Fichier:String);
  procedure Charge;
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.SauveCliped(X,Y,Largeur,Hauteur:Integer;Fichier:String;Sauve:Boolean);
var I, J :integer;
begin
UneBrique.Width:=Largeur;
UneBrique.Height:=Hauteur;
UneBrique.DIB.SetSize(Largeur,Hauteur,24);
UneBrique.Paint;
for J:=0 to Hauteur-1 do for I:=0 to Largeur-1 do
 UneBrique.DIB.Pixels[I,J]:=Items.DIB.Pixels[X+I,Y+J];
UneBrique.Paint;
UneBrique.DIB.SaveToFile('C:\Mes documents\MULTIB\DATA\NIVDEF\'+Fichier);
if Sauve then SauveItem(Largeur,Hauteur,copy(Fichier,1,Length(Fichier)-4));
end;

procedure TForm1.SauveOuiNon(X,Y,Largeur,Hauteur:Integer;Fichier:String);
var I, J :integer;
begin
UneBrique.Width:=Largeur*2;
UneBrique.Height:=Hauteur;
UneBrique.DIB.SetSize(Largeur*2,Hauteur,24);
UneBrique.Paint;
for J:=0 to Hauteur-1 do for I:=0 to Largeur-1 do
 UneBrique.DIB.Pixels[I,J]:=Items.DIB.Pixels[X+I,Y+J];
for J:=0 to Hauteur-1 do for I:=0 to Largeur-1 do
 UneBrique.DIB.Pixels[I+Largeur,J]:=Items.DIB.Pixels[X+I,Hauteur+Y+J];
UneBrique.Paint;
UneBrique.DIB.SaveToFile('C:\Mes documents\MULTIB\DATA\NIVDEF\'+Fichier);
end;

procedure TForm1.SauveItem(Largeur,Hauteur:Integer;Fichier:String);
Begin
Sprites.Items.add;
with Sprites.Items[Compteur] do
 begin
 Picture.LoadFromFile('C:\Mes documents\MULTIB\DATA\NIVDEF\'+Fichier+'.BMP');
 Name:=Fichier;
 PatternWidth:=Largeur;
 PatternHeight:=Hauteur;
 end;
inc(Compteur);
End;

procedure TForm1.Charge;
var  Images :integer;
begin
Sprites.Items.Clear();
Compteur:=0;
for Images:=1 to 25 do
 begin
 SauveCliped(0,(Images-1)*16,192,16,'Brique'+IntToStr(Images)+'.BMP',False);
 SauveItem(32,16,'Brique'+IntToStr(Images));
 end;
SauveCliped(192,0,192,16,'Brique26.BMP',False);
SauveItem(32,16,'Brique26');
SauveCliped(448,16,32,16,'Balle.BMP',False);
SauveItem(16,16,'Balle');
SauveCliped(192,256,352,144,'Presente.BMP',True);

{Oui non }
SauveOuiNon(195,224,44,16,'Oui.BMP');
SauveOuiNon(530,0,46,16,'Non.BMP');

{ Palette de gauche }
for Images:=1 to 2 do
  SauveCliped(194,32+(Images-1)*48,24,48,'PaletteGTire'+IntToStr(Images)+'.BMP',True);
for Images:=1 to 2 do
  SauveCliped(226,32+(Images-1)*48,24,48,'PaletteGNeTire'+IntToStr(Images)+'.BMP',True);
SauveCliped(194,128,24,48,'PaletteGInvisible.BMP',True);
SauveCliped(194,176,24,48,'PaletteGColle.BMP',True);
SauveCliped(290,64,24,80,'PaletteGGrand.BMP',True);
SauveCliped(258,32,24,63,'PaletteGMoyen.BMP',True);
SauveCliped(258,96,24,48,'PaletteGPetit.BMP',True);
SauveCliped(290,32,24,31,'PaletteGMinus.BMP',True);
SauveCliped(224,148,38,40,'BoucheGauche.BMP',True);

{ Palette de droite }
SauveCliped(598,0,24,48,'PaletteDTire2.BMP',True);
SauveCliped(598,48,24,48,'PaletteDTire1.BMP',True);
SauveCliped(566,32,24,48,'PaletteDNeTire2.BMP',True);
SauveCliped(566,32+48,24,48,'PaletteDNeTire1.BMP',True);
SauveCliped(598,96,24,48,'PaletteDInvisible.BMP',True);
SauveCliped(598,144,24,48,'PaletteDColle.BMP',True);
SauveCliped(502,64,24,80,'PaletteDGrand.BMP',True);
SauveCliped(534,32,24,63,'PaletteDMoyen.BMP',True);
SauveCliped(534,96,24,48,'PaletteDPetit.BMP',True);
SauveCliped(502,32,24,31,'PaletteDMinus.BMP',True);
SauveCliped(282,148,38,40,'BoucheDroite.BMP',True);

{ Palette du haut }
SauveCliped(320,37,112,20,'PaletteHGrand.BMP',True);
SauveCliped(320,69,96,20,'PaletteHMoyen.BMP',True);
SauveCliped(320,101,80,20,'PaletteHPetit.BMP',True);
SauveCliped(320,133,62,20,'PaletteHMinus.BMP',True);
SauveCliped(240,197,80,20,'PaletteHTire2.BMP',True);
SauveCliped(320,197,80,20,'PaletteHTire1.BMP',True);
SauveCliped(240,229,80,20,'PaletteHNeTire2.BMP',True);
SauveCliped(320,229,80,20,'PaletteHNeTire1.BMP',True);
SauveCliped(320,165,80,20,'PaletteHInvisible.BMP',True);
SauveCliped(560,229,80,20,'PaletteHColle.BMP',True);

{ Palette du bas }
SauveCliped(432,39,62,20,'PaletteBMinus.BMP',True);
SauveCliped(417,71,80,20,'PaletteBPetit.BMP',True);
SauveCliped(400,103,96,20,'PaletteBMoyen.BMP',True);
SauveCliped(384,135,112,20,'PaletteBGrand.BMP',True);
SauveCliped(400,199,80,20,'PaletteBTire1.BMP',True);
SauveCliped(480,199,80,20,'PaletteBTire2.BMP',True);
SauveCliped(400,231,80,20,'PaletteBNeTire1.BMP',True);
SauveCliped(480,231,80,20,'PaletteBNeTire2.BMP',True);
SauveCliped(416,167,80,20,'PaletteBInvisible.BMP',True);
SauveCliped(560,199,80,20,'PaletteBColle.BMP',True);
if SauveItems.execute then
Sprites.Items.SaveToFile(SauveItems.Filename);
end;

procedure TForm1.Charger1Click(Sender: TObject);
begin
if OuvreBMP.execute then
 begin
 Items.DIB.LoadFromFile(OuvreBMP.FileName);
 try
 Items.DIB.SetSize(640,400,24);
 except
 End;
 Items.Paint;
 Items.DIB.UpDatePalette;
 UneBrique.DIB.ColorTable:=Items.DIB.ColorTable;
 UneBrique.Paint;
 UneBrique.DIB.UpdatePalette;
 Sprites.ITems.ColorTable:=Items.DIB.ColorTable;
 Charge;
 end;
end;

end.
