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
End;

procedure TForm1.Charge;
var  Images :integer;
begin
Sprites.Items.Clear();
Sprites.Items.add;
with Sprites.Items[Compteur] do
 begin
 Picture.LoadFromFile('D:\DOCS\MULTIB\DATA\TIRE.BMP');
 Name:='Tire';
 PatternWidth:=30;
 PatternHeight:=30;
 end;
if SauveItems.execute then
Sprites.Items.SaveToFile(SauveItems.Filename);
end;

procedure TForm1.Charger1Click(Sender: TObject);
begin
 Charge;
end;

end.
