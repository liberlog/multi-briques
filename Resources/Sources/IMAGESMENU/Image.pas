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
    Quitter1: TMenuItem;
    procedure Charger1Click(Sender: TObject);
    procedure Quitter1Click(Sender: TObject);
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
UneBrique.DIB.SetSize(Largeur,Hauteur,8);
UneBrique.Paint;
for J:=0 to Hauteur-1 do for I:=0 to Largeur-1 do
 UneBrique.DIB.Pixels[I,J]:=Items.DIB.Pixels[X+I,Y+J];
UneBrique.Paint;
UneBrique.DIB.SaveToFile('C:\Mes documents\MULTIB\DATA\MENU\'+Fichier);
if Sauve then SauveItem(Largeur,Hauteur,copy(Fichier,1,Length(Fichier)-4));
end;

procedure TForm1.SauveOuiNon(X,Y,Largeur,Hauteur:Integer;Fichier:String);
var I, J :integer;
begin
UneBrique.Width:=Largeur*2;
UneBrique.Height:=Hauteur;
UneBrique.DIB.SetSize(Largeur*2,Hauteur,8);
UneBrique.Paint;
for J:=0 to Hauteur-1 do for I:=0 to Largeur-1 do
 UneBrique.DIB.Pixels[I,J]:=Items.DIB.Pixels[X+I,Y+J];
for J:=0 to Hauteur-1 do for I:=0 to Largeur-1 do
 UneBrique.DIB.Pixels[I+Largeur,J]:=Items.DIB.Pixels[X+I,Hauteur+Y+J];
UneBrique.Paint;
UneBrique.DIB.SaveToFile('C:\Mes documents\MULTIB\DATA\MENU\'+Fichier);
end;

procedure TForm1.SauveItem(Largeur,Hauteur:Integer;Fichier:String);
Begin
Sprites.Items.add;
with Sprites.Items[Compteur] do
 begin
 Picture.LoadFromFile('C:\Mes documents\MULTIB\DATA\MENU\'+Fichier+'.BMP');
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
for Images:=1 to 4 do
 begin
 SauveCliped(0,(Images-1)*48,224,48,'Joueur'+IntToStr(Images)+'.BMP',True);
 end;
Images:=4;
SauveCliped(0,Images*48,224,48,'Jouer.BMP',True);
inc(Images);
SauveCliped(0,Images*48,224,48,'Quitter.BMP',True);
inc(Images);
SauveCliped(0,Images*48,224,48,'Joystick1.BMP',True);
inc(Images);
SauveCliped(0,Images*48,224,48,'JoyPad1.BMP',True);
inc(Images);
SauveCliped(0,Images*48,224,48,'Inactif.BMP',True);
inc(Images);
SauveCliped(0,Images*48,224,48,'Clavier1.BMP',True);
inc(Images);
SauveCliped(0,Images*48,224,48,'Clavier2.BMP',True);
inc(Images);
SauveCliped(0,Images*48,224,48,'Rien.BMP',True);
Images:=1;
for Images:=1 to 4 do
 begin
 SauveCliped(224,(Images-1)*48,224,48,'NbJoueur'+IntToStr(Images)+'.BMP',True);
 end;
SauveCliped(224,Images*48,224,48,'RienJouer.BMP',True);
inc(Images);
SauveCliped(224,Images*48,224,48,'RienQuitter.BMP',True);
inc(Images);
SauveCliped(224,Images*48,224,48,'Joystick2.BMP',True);
inc(Images);
SauveCliped(224,Images*48,224,48,'Joypad2.BMP',True);
Images:=0;
SauveCliped(448,Images*48,160,48,'Oui.BMP',True);
inc(Images);
SauveCliped(448,Images*48,160,48,'Non.BMP',True);
inc(Images);
SauveCliped(448,Images*48,160,48,'RienOui.BMP',True);
inc(Images);
SauveCliped(448,Images*48,160,48,'RienNon.BMP',True);
inc(Images);
if SauveItems.execute then
Sprites.Items.SaveToFile(SauveItems.Filename);
end;

procedure TForm1.Charger1Click(Sender: TObject);
begin
if OuvreBMP.execute then
 begin
 Items.DIB.LoadFromFile(OuvreBMP.FileName);
 try
 Items.DIB.SetSize(800,600,8);
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
