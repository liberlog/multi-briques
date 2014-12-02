unit Image;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DXDraws, DIB, StdCtrls, Menus;

const EcranX    = 720;
      EcranY    = 400;
      BitCompte = 24;

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
    Quitter1: TMenuItem;
    procedure Charger1Click(Sender: TObject);
    procedure Quitter1Click(Sender: TObject);
  private
  Compteur    :Integer;
  procedure SauveCliped(X,Y,Largeur,Hauteur:Integer;Fichier:String;Sauve:Boolean);
  procedure SauveItem(Largeur,Hauteur:Integer;Fichier:String);
  procedure SauveItem2(Largeur,Hauteur:Integer;Fichier:String);
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
UneBrique.DIB.SetSize(Largeur,Hauteur,BitCompte);
UneBrique.Paint;
for J:=0 to Hauteur-1 do for I:=0 to Largeur-1 do
 UneBrique.DIB.Pixels[I,J]:=Items.DIB.Pixels[X+I,Y+J];
UneBrique.Paint;
UneBrique.DIB.SaveToFile('F:\DOCS\MULTIB\DATA\IMENU\'+Fichier);
if Sauve then SauveItem(Largeur,Hauteur,copy(Fichier,1,Length(Fichier)-4));
end;

procedure TForm1.SauveItem2(Largeur,Hauteur:Integer;Fichier:String);
Begin
UneBrique.Width:=Largeur;
UneBrique.Height:=Hauteur;
UneBrique.DIB.SetSize(Largeur,Hauteur,BitCompte);
UneBrique.DIB.LoadFromFile('F:\DOCS\MULTIB\DATA\MENU\'+Fichier+'.BMP');
UneBrique.Paint;
UneBrique.DIB.SaveToFile('F:\DOCS\MULTIB\DATA\IMENU\'+Fichier+'.BMP');
Sprites.Items.add;
with Sprites.Items[Compteur] do
 begin
 Picture.LoadFromFile('F:\DOCS\MULTIB\DATA\IMENU\'+Fichier+'.BMP');
 Name:=Fichier;
 TransparentColor:=clWhite;
 PatternWidth:=Largeur;
 PatternHeight:=Hauteur;
 end;
inc(Compteur);
End;

procedure TForm1.SauveItem(Largeur,Hauteur:Integer;Fichier:String);
Begin
Sprites.Items.add;
with Sprites.Items[Compteur] do
 begin
 Picture.LoadFromFile('F:\DOCS\MULTIB\DATA\IMENU\'+Fichier+'.BMP');
 Name:=Fichier;
 TransparentColor:=clWhite;
 PatternWidth:=Largeur;
 PatternHeight:=Hauteur;
 end;
inc(Compteur);
Sprites.Items.add;
with Sprites.Items[Compteur] do
 begin
 Picture.LoadFromFile('F:\DOCS\MULTIB\DATA\IMENU\Actif'+Fichier+'.BMP');
 Name:='Actif'+Fichier;
 TransparentColor:=clWhite;
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
Images:=0;
SauveCliped(0,Images*48,240,48,'Inactif.BMP',True);
inc(Images);
SauveCliped(0,Images*48,240,48,'Bas.BMP',True);
inc(Images);
SauveCliped(0,Images*48,240,48,'Haut.BMP',True);
inc(Images);
SauveCliped(0,Images*48,240,48,'Droite.BMP',True);
inc(Images);
SauveCliped(0,Images*48,240,48,'Gauche.BMP',True);
inc(Images);
SauveCliped(0,Images*48,240,48,'Joystick1.BMP',True);
inc(Images);
SauveCliped(0,Images*48,240,48,'Joystick2.BMP',True);
inc(Images);
SauveCliped(0,Images*48,240,48,'Souris.BMP',True);
Images:=0;
SauveCliped(240,Images*48,240,48,'Jouer.BMP',True);
inc(Images);
SauveCliped(240,Images*48,240,48,'Quitter.BMP',True);
inc(Images);
SauveCliped(240,Images*48,240,48,'Options.BMP',True);
inc(Images);
SauveCliped(240,Images*48,240,48,'Son.BMP',True);
inc(Images);
SauveCliped(240,Images*48,240,48,'Controle.BMP',True);
inc(Images);
SauveCliped(240,Images*48,240,48,'Scores.BMP',True);
inc(Images);
SauveCliped(240,Images*48,240,48,'Scenario.BMP',True);
inc(Images);
SauveCliped(240,Images*48,240,48,'Clavier1.BMP',True);
Images:=0;
SauveCliped(480,Images*48,240,48,'1Joueurs.BMP',True);
inc(Images);
SauveCliped(480,Images*48,240,48,'2Joueurs.BMP',True);
inc(Images);
SauveCliped(480,Images*48,240,48,'3Joueurs.BMP',True);
inc(Images);
SauveCliped(480,Images*48,240,48,'4Joueurs.BMP',True);
inc(Images);
SauveCliped(480,Images*48,240,48,'Clavier2.BMP',True);
inc(Images);
SauveCliped(480,Images*48,240,48,'Charger.BMP',True);
inc(Images);
SauveItem2(61,68,'Curseur');
if SauveItems.execute then
Sprites.Items.SaveToFile(SauveItems.Filename);
end;

procedure TForm1.Charger1Click(Sender: TObject);
begin
if OuvreBMP.execute then
 begin
 Items.DIB.LoadFromFile(OuvreBMP.FileName);
 try
 Items.DIB.SetSize(EcranX,EcranY,BitCompte);
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

procedure TForm1.Quitter1Click(Sender: TObject);
begin
Close;
end;

end.
