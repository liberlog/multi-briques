unit mbcommon;

{$IFDEF FPC}
{$mode objfpc}{$H+}
{$ENDIF}

interface

uses
  Classes, SysUtils;

const
{$IFNDEF FPC}
       DirectorySeparator = '\';
{$ENDIF}
       EcranX=640;
       EcranY=400;
       MinJoueur = 1 ;
       MaxJoueur = 4 ;

       NbBriquesX = 20; {12;}
       NbBriquesY = 24; {14;}
       FinCouche = 5;

       BriqueMinX = 32;
       BriqueMinY = 20 ;
       BBase      = 1;
       BColle     = 7;
       TempsEnvoi = 600;
       BTire1     = 2;
       BTire2     = 3;
       BMinus     = 4;
       BPetit     = 5;
       BGrand     = 6;
       BSpeedUp   = 8;
       BSpeedDown = 9;
       BInversion = 10;
       BImmobile  = 11;
       BTransparent=12;
       BFolle     = 13;
       BPlomb     = 14;
       BBalle     = 15;
       BPointsX3  = 16;
       BPointsX2  = 17;
       BPointsX1  = 18;
       BPlusGros  = 27;
       BMoinsGros = 28;
       BIndestructible = 25;

       FinBriques = 28;


       ChiffreDebut = ord ( '1' );
       ChiffreFin   = ord ( '0' );
       LettreDebut = ord ( 'A' );
       LettreFin   = ord ( 'Z' );

       DirectoryData = 'DATA' ;
       DirectoryNiveaux = 'Niveaux' ;

       ImageActif = 'Actif';
       ImageSouris = 'Souris';
       ImageJoueurs = 'Joueurs' ;
       ImageJouer   = 'Jouer' ;
       ImageBalle = 'balle' ;
       ImageBrique= 'Brique' ;
       PaletteColle= 'Colle' ;
       PaletteInvisible= 'Invisible' ;
       PaletteTire= 'Tire' ;
       ImageTir = 'Tir' ;
       PalettePetite= 'Petit' ;
       PaletteMinus= 'Minus' ;
       PaletteMoyenne= 'Moyen' ;
       ImagePalette= 'Palette' ;
       ImageLettre= 'Lettre' ;
       PaletteGrande = 'Grand' ;
       ImagesLibExtension = '.ail' ;
       ImageExtension = '.ail' ;

       LettresSpeciales = '!%()*+,-./\';
       ChiffreGros  = 'ChiffreG' ;
       LettreGrosse  = 'Char' ;
       ChiffrePetit = 'Chiffre' ;

       ImageListMenus='MENUS';
       ImageListStage= 'Stage' ;
       ImageListFond = 'Fond' ;
       ImageListTir  = 'Tir' ;
       ImageControle = 'Controle' ;
       ImageBas      = 'Bas' ;
       ImageHaut     = 'Haut' ;
       ImageGauche   = 'Gauche' ;
       ImageDroite   = 'Droite' ;
       ImageSon      = 'Son' ;

       IniGame = 'Game';
       IniPlayers = 'Players' ;
       IniPlayer  = 'Player' ;
       IniAPlayer = 'APlayer' ;
       MaxBriques = 28 ;

       BriquesX = ( EcranX - 360 ) div 2;
       BriquesY = ( EcranY - 240 ) div 2;


type  TCases          =ARRAY[0..NbBriquesX-1,0..NbBriquesY-1,0..5] of Byte;
      TAncienCases          =ARRAY[0..11,0..13,0..5] of Byte;
      EnTete      = Record
                   TailleX,
                   TailleY : Integer;
                   end;
      UneTouche = array [ MinJoueur.. MaxJoueur ] of Byte;




procedure ChargeEntete(var Fichier : FILE;var TailleX, TailleY : Integer);
procedure ChargeNiveau(var Fichier : FILE;const TailleX, TailleY : Integer; var Briques : TCases );
procedure ChargeFichier(const Chemin : String; var TailleX, TailleY : Integer; var Briques : TCases );
procedure SauveFichier(const Chemin : String; const TailleX, TailleY : Integer; const Briques : TCases );
procedure ChargeLUM(const Chemin : String;NoNiveau:integer; var TailleX, TailleY : Integer; var Briques : TCases );
procedure SauveLUM(const Chemin : String;NoNiveau:integer; var TailleX, TailleY : Integer; const Briques : TCases );
procedure ChargeMSC(const Chemin : String;NoNiveau:integer; var TailleX, TailleY : Integer; var Briques : TCases );
procedure SauveMSC(const Chemin : String );

var
  TailleX : Integer = 12;
  TailleY : Integer = 14;

implementation

uses Dialogs, Forms;

procedure ChargeNiveau(var Fichier : FILE;const TailleX, TailleY : Integer; var Briques : TCases );
var I,J,k     : Integer;
begin
 for I:=0 to TailleX-1 do for J:=0 to TailleY-1 do
  for K:=0 to FinCouche do
    if not eof(Fichier) then
      BlockRead(Fichier,Briques[I,J,K],Sizeof(byte));
end;

procedure SauveNiveau(var Fichier : FILE;const TailleX, TailleY : Integer; const Briques : TCases );
var I,J,k     : Integer;
begin
  for I:=0 to TailleX-1 do
    for J:=0 to TailleY-1 do
      for K:=0 to FinCouche do
        BlockWrite(Fichier,Briques[I,J,K],Sizeof(byte));
end;

procedure SauveEntete(var Fichier : FILE;const TailleX, TailleY : Integer);
var
  EnteteFichier : Entete;
Begin
  EnTeteFichier.TailleX:=TailleX;
  EnTeteFichier.TailleY:=TailleY;
  if IOResult=0 then
    begin
      BlockWrite(Fichier,EnteteFichier,Sizeof(Entete));
    End
   Else
    Abort;
End;

procedure ChargeEntete(var Fichier : FILE;var TailleX, TailleY : Integer);
var
  EnteteFichier : Entete;

begin
  EnteteFichier.TailleX := 0;
  EnteteFichier.TailleY := 0;
  if (IOResult=0) and not eof(Fichier) then
    begin
     BlockRead(Fichier,EnteteFichier,Sizeof(Entete));
     TailleX := EnteteFichier.TailleX ;
     TailleY := EnteteFichier.TailleY ;
    End
   Else
    Abort;
end;

procedure ChargeFichier(const Chemin : String; var TailleX, TailleY : Integer; var Briques : TCases );
var Fichier : FILE;
begin
  {$I-}
  AssignFile(Fichier,Chemin);
  Reset(Fichier,1);
  {$I+}
  ChargeEntete ( Fichier, TailleX, TailleY );
  ChargeNiveau ( Fichier, TailleX, TailleY, Briques );
  {$I-}
  CloseFile(Fichier);
  {$I+}
  //TailleX:=EnTeteFichier.TailleX;
  //TailleY:=EnTeteFichier.TailleY;
end;



procedure SauveFichier(const Chemin : String; const TailleX, TailleY : Integer; const Briques : TCases );
type EnTete      = Record
                   TailleX,
                   TailleY : Integer;
                   end;

var Fichier : FILE;
begin
  {$I-}
  AssignFile(Fichier,Chemin);
  ReWrite(Fichier,1);
  {$I+}
  SauveEntete ( Fichier, TailleX, TailleY );
  if IOResult=0 then
   begin
     SauveNiveau ( Fichier, TailleX, TailleY, Briques );
   end;
  {$I-}
  CloseFile(Fichier);
  {$I+}
end;

procedure ChargeLUM(const Chemin : String;NoNiveau:integer; var TailleX, TailleY : Integer; var Briques : TCases );
type EnTete      = Record
                   TailleX,
                   TailleY : Integer;
                   end;

var Fichier : FILE;
    i       : Integer ;
    Inutile1       : TCases;
    Inutile2       : TAncienCases;
begin
{$I-}
AssignFile(Fichier,Chemin);
Reset(Fichier,1);
{$I+}
I:=1;
if IOResult=0 then
 begin
  ChargeEntete ( Fichier, TailleX, TailleY );
  while (I<NoNiveau) and not eof(Fichier) DO
   begin
     if ( TailleX = 12 ) then
       BlockRead(Fichier,Inutile2,Sizeof(Inutile2))
     else
       BlockRead(Fichier,Inutile1,Sizeof(Inutile1));
   inc(I);
   End;
   ChargeNiveau ( Fichier, TailleX, TailleY, Briques );
 end;
If (IOResult=0) and (i<>NoNiveau)
  Then
    ShowMessage('Ce niveau n''existe pas ! ' + #13#10 + 'Dernier niveau :' + IntToStr(I));
{$I-}
CloseFile(Fichier);
{$I+}
//TailleX:=EnTeteFichier.TailleX;
//TailleY:=EnTeteFichier.TailleY;
end;

procedure SauveLUM(const Chemin : String;NoNiveau:integer; var TailleX, TailleY : Integer; const Briques : TCases );
type EnTete      = Record
                   TailleX,
                   TailleY : Integer;
                   end;

var Fichier : FILE;
    I       : Integer;
    Inutile1       : TCases;
    Inutile2       : TAncienCases;
begin
  {$I-}
  AssignFile(Fichier,Chemin);
  Reset(Fichier,1);
  {$I+}
  if ( not eof ( Fichier )) then
   ChargeEntete ( Fichier, TailleX, TailleY )
  else
   SauveEntete ( Fichier, TailleX, TailleY );
  I:=1;
  while (I<NoNiveau) and not eof(Fichier) DO
   begin
     if ( TailleX = 12 ) then
       BlockRead(Fichier,Inutile2,Sizeof(Inutile2))
     else
       BlockRead(Fichier,Inutile1,Sizeof(Inutile1));
   inc(I);
   End;
  if ((I=NoNiveau) or eof(Fichier)) and (IOResult=0) then
     begin
       SauveNiveau ( Fichier, TailleX, TailleY, Briques );
     end
      else Application.MessageBox('Le niveau n''a pas pu être sauvé. Le numéro du niveau est trop élevé', 'Erreur !', 1 );
  {$I-}
  CloseFile(Fichier);
  {$I+}
end;


procedure ChargeMSC(const Chemin : String;NoNiveau:integer; var TailleX, TailleY : Integer; var Briques : TCases );
type EnTete      = Record
                   TailleX,
                   TailleY : Integer;
                   end;

var Fichier : FILE;
    I       : Integer;
    EnteteFichier : Entete;
begin
{$I-}
AssignFile(Fichier,Chemin);
Reset(Fichier,1);
{$I+}
if IOResult=0 then
 begin
 for I:=1 to NoNiveau do
 if not eof(Fichier) then
  begin
  BlockRead(Fichier,EnteteFichier,Sizeof(Entete));
  BlockRead(Fichier,Briques,Sizeof(Briques));
  End;
 end;
{$I-}
CloseFile(Fichier);
{$I+}
//TailleX:=EnTeteFichier.TailleX;
//TailleY:=EnTeteFichier.TailleY;
end;

procedure SauveMSC(const Chemin : String);
type TFiche       = Record
                   Num_Niveau : integer;
                   Niveau : string;
                   end;

var Fichier : FILE;
    Fiche   : Tfiche;
    I     : Integer;
begin
//if OuvreFichier.execute then
 begin
 {$I-}
 AssignFile(Fichier,Chemin);
 ReWrite(Fichier,1);
 {$I+}
 I:=0;
// if (I<OuvreFichier.files.Count) and (IOResult=0) then
   begin
   Fiche.Num_Niveau :=I+1;
//   Fiche.Niveau:='Niveaux' + DirectorySeparator+extractFileName(OuvreFichier.Files[I]);
   BlockWrite(Fichier,Fiche,sizeof(Fiche));
   inc(I);
   end;
//    else Application.MessageBox('Le niveau n''a pas pu être sauvé','Erreur !',MB_OK);
 Fiche.Num_Niveau :=I+1;
 Fiche.Niveau:='FIN';
 BlockWrite(Fichier,Fiche,sizeof(Fiche));
 {$I-}
 CloseFile(Fichier);
 {$I+}
 End;
//OuvreFichier.Options:=OuvreFichier.Options-[ofAllowMultiSelect];
end;


end.

