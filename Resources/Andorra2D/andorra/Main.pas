unit Main;

{$IFDEF FPC}
{$MODE Delphi}
{$ELSE}
{$R *.DFM}
{$ENDIF}

interface

uses
{$IFDEF FPC}
  LCLType, LResources, KeyBoard,
{$ELSE}
  Windows,
{$ENDIF}
  SysUtils, Classes, mbcommon,
  Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Menus, AdClasses, AdSprites, AdDraws,
  AdSpriteEngineEx, AdPerformanceCounter,
  AdEvents, IniFiles, AdCanvas;

function TestUneCoordonneeCercleRectangle ( const CentreX , CentreY, Rayon, CoordX, CoordY : Double ): Boolean;
function TestCollisionCercleRectangle ( const Cercle, Rectangle : TSprite ): Boolean;
function TestCollisionCercleCercle ( const Cercle1, Cercle2 : TSprite ): Boolean;


type
  TItemDirection = ( idBas,idHaut,idGauche, idDroite);
  TInputType  = (itInactive, itMouse,itKeyboard1,itKeyboard2,itJoystick1,itJoystick2);
  TBalleModif = ( bmBalleDessus, bmAccelere, bmRalenti, bmPlomb, bmColle, bmNormal,bmFolleHautBas,bmFolle,bmFolleGaucheDroite,bmPlusGrosse,bmMoinsGrosse);
  TPlayerModif = ( pmErased, pmEnlever, pmAfficher, pmEnvoiBalle, pmBouge );
  TModeBrique = ( mbAucun, mbCassePas, mbMeurt );

  { TLettre }

  TLettre  = class(TImageSprite)
   private
     FPetite : Boolean ;
     FLettre : Char ;
   public
  procedure DoMove(MoveCount: Double); override;
  procedure SetLettre(const Lettre : Char ; const ReDraw: Boolean); virtual;
  procedure SetGrosseur(const Petite : Boolean ); virtual;
  constructor Create ( const AParent: TSprite; const Lettre : Char ; const X, Y : Double ); overload;
  End;

  TLettres = ARRAY [0..15]of TLettre;

  { TMainForm }

  TMainForm = class(TForm)
//    DXWaveList: TDXWaveList;
//    DXSound: TDXSound;
    MainMenu: TMainMenu;
    GameMenu: TMenuItem;
    GameStart: TMenuItem;
    GamePause: TMenuItem;
    GameExit: TMenuItem;
    OptionMenu: TMenuItem;
    OptionFullScreen: TMenuItem;
    OptionSound: TMenuItem;
    OptionShowFPS: TMenuItem;
    N4: TMenuItem;
    N3: TMenuItem;
    N1: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure GamePauseClick(Sender: TObject);
    procedure GameExitClick(Sender: TObject);
    procedure OptionShowFPSClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure DXSoundInitialize(Sender: TObject);
    procedure GameStartClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; Key: Word;
      Shift: TAdShiftState);

      // Evènements du clavier et de la souris
    procedure FormKeyPress(Sender: TObject; Key: Char);
    procedure FormMouseDown(Sender : TObject; Button : TAdMouseButton; Shift : TAdShiftState; X,Y : Integer);
    procedure FormMouseMove(Sender:TObject; Shift:TAdShiftState; X, Y:integer);
    procedure AMouseDown(Sender : TObject; Button : TMouseButton; Shift : TShiftState; X,Y : Integer);
    procedure AMouseMove(Sender:TObject; Shift:TShiftState; X, Y:integer);
    procedure PanelEnter(Sender: TObject);
    procedure PanelExit(Sender: TObject);
    procedure AKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure AKeyPress(Sender: TObject; var Key: Char);
  private
    AdDraw:TAdDraw;
    AdPerCounter : TAdPerformanceCounter;
    FEraseButtonLeft: Boolean;
    FEraseButtonRight: Boolean;
    FMouseButtonLeft: Boolean;
    FMouseButtonRight: Boolean;
    MouseX,MouseY : Integer ;
    KeyboardState : Byte ;
    FIniFile : TMemIniFile ;
    AdPause : Boolean ;
    Stop : Boolean ;
    NoNiveau : Integer;
    Ecran   : boolean;
    Compteur,
    NbJoueurs : Integer;
    Messages,
    Son,
    MessageEcran  : string;
    ControleJoueur : ARRAY[1..4] of TInputType;
//    Disparait : ARRAY[1..4] of Boolean;
    Suivant,Perdu,
    Envoi     : boolean;
//    Fond: TAdTexture;
//    WaveFormat: TWaveFormatEx;
    //fixed arrays
//    populated : array[0..6, 0..6] of boolean;


    function GetMouseButtonLeft : Boolean;
    function GetMouseButtonRight : Boolean;
    procedure p_KeyDown( const Sender: TObject; const Key: Word  ; const Alt : Boolean );
    procedure SceneFlipping;
    procedure OnIdle(Sender: TObject; var Done: Boolean);
    procedure PlaySound(const Name: string; Wait: Boolean);

    procedure ChargeTir ();
    procedure ChargeStage( const Niveau : Integer );

    procedure MenuPrincipal;
    procedure ChargeControles;
    procedure StartSceneMain;
    procedure EndSceneMain;
    procedure EffaceMenu;
    procedure SceneMain;
    procedure StartSceneMenu;
    procedure EndSceneMenu;
    procedure SceneMenu;
    procedure EnvoiMessage;
    procedure ScenePresentation;
    procedure AfficheTexte( const Lettres : TLettres ; const Texte : String);
    procedure EcritIni(Rep,Nom,Install:string);
    procedure LitIni(var Installed:string;Rep,Nom : String);
    procedure Joue;
    procedure CreeIni ;
//    procedure AssignKey(var KeyAssignList: TKeyAssignList; State: TDXInputState; const Keys: array of Integer);

    public
    property MouseButtonRight : Boolean read GetMouseButtonRight write FMouseButtonRight ;
    property MouseButtonLeft  : Boolean read GetMouseButtonLeft  write FMouseButtonLeft ;
    destructor  Destroy; override;
   end;


const
       CST_MessageErrorInit = 'Error while initializing Multi-Briques. Try to use another display'+
              'mode or use another video adapter.';
       {Constantes menu }
       MaxItems = 9;
       {Constantes globales }
       ScoreVie    =1000;
       AjouteVie   = 16;
       Bas         =1;
       Haut        =2;
       Gauche      =3;
       Droite      =4;

       {Constantes liées aux niveaux }
       Fin = 50;
       {Constantes liées à l'écran }
       BitCompte = 16;
       EcranX=640;
       EcranY=400;
       LimiteXImages = 100 ; {94;}
       LimiteYImages = 50 ;{47;   }
       LimiteX = 94 ; {94;}
       LimiteY= 47 ;{47;   }

       {Constantes liées aux balles }
       Lente       =100; //Vitesse lente
       VitesseMax = 600;
       ZBalles     =3;
       MaxiBalles   = 60;
       DecalX      = 2;
       DecalY      = 2;
       {Constantes liées aux briques }
       ZBRiques   = 1;
       ZItems     = 0;
       NbBriquesX = 20; {12;}
       NbBriquesY = 24; {14;}
       BriquesX   = (EcranX-12*32)div 2;
       BriquesY   = (EcranY-14*16) div 2;
       NeCasse    = 1;
       Meurt      = 2;

       TempsChange = 30000;
       TempsAccelere = 20000;
       TempsInversion=5000;
       TempsImmobile=3000;

       PColle     = 100;
       PTire1     = 100;
       PTire2     = 100;
       PMinus     = 400;
       PPetit     = 300;
       PGrand     = 200;
       PBase      = 100;
       PSpeedUp   = 400;
       PSpeedDown = 100;
       PInversion = 300;
       PImmobile  = 300;
       PTransparent =200;
       PFolle     = 200;
       PPlusGrosse= 250;
       PMoinsGrosse= 100;
       PPlomb     = 200;
       PBalle     = 200;
       PPointsX3  = 100;
       PPointsX2  = 100;
       PPointsX1  = 100;
       PCasse     = 100;

       {Constantes liées aux tires }
       ZTires     = 20 ;

       {Constantes liées aux joueurs }
       Bouche      = 34;
       MaxMurBH    = 14;
       MaxMurGD    = 9 ;
       ZJoueurs    = 2;
        // Modes des Joueurs
       Colle         = 1;
       Tire1         = 2;
       Tire2         = 3;
       Minus         = 4;
       Moyen         = 5;
       Grand         = 6;
       TRansparent   = 7;
       Immobilise    = 8;
       // Joueur 1
       JoueurBasX    = EcranX/2-40;
       JoueurBasY    = EcranY-30;
       // Joueur 2
       JoueurHautX    = EcranX/2-40;
       JoueurHautY    = 10;
       // Joueur 3
       JoueurGaucheX    = 10;
       JoueurGaucheY    = EcranY/2-30;
       // Joueur 4
       JoueurDroiteX    = EcranX-34;
       JoueurDroiteY    = EcranY/2-30;

       BougePaletteX= 30;
       BougePaletteY= 30;

       {Constantes liées aux sprites }
       Vitesse = 1000;
       VitesseItem = 170 ;
       VitesseTir  = 10 ;
       Ralenti = 150;
       {Constantes liées au réseau }
      DXCHAT_MESSAGE = 1;

var
  MainForm: TMainForm;
  ScoreAjouteVie,
  Score                     : Cardinal ;
  NbBalles,
  NbPalettes,
  Vies,
  PointsVie              : Integer ;
  ToucheHaut : UneTouche ;
  ToucheBas  : UneTouche ;
  ToucheGauche : UneTouche ;
  ToucheDroite  : UneTouche ;
  ToucheBoutonA  : UneTouche ;
  ToucheBoutonB  : UneTouche ;
  FondImage: TAdImageList;
  SpriteEngine: TSpriteEngine;
  ImageList: TAdImageList;
  ImageListTirs: TAdImageList;
  NbBriques : Integer ;

implementation

uses TypInfo;

type
  TPlayerSprite = class;
  PPlayerSprite = ^TPlayerSprite;
  TBalle = class;
//  TMBMenu = (MPrincipal,MQuitter,MControl);
  TActions = (AAttente,AJouer,AQuitter,ARetour,ARetourControle,AJoueur,AOptions,ASon,Acontroles,Abas,AHaut,ADroite,AGauche,AChangeGauche,AChangeDroite,AChangeBas,AChangeHaut);

  TDXChatMessage = record
    dwType: DWORD;  {  dwType is absolutely necessary.  }
    Len: Integer;
    C: array[0..0] of Char;
  end;
  TFenetres=(FPresentation,FMenu,FJeu,FScores);
  TCurseur = class(TimageSprite)
  Pousse   :boolean;
   private
  procedure DoMove(MoveCount: Double); override;
   public
  constructor Create ( const AParent: TSprite ; const MonImage :  String ); overload;
  End;

  { TCollisionSprite }

  TCollisionSprite = class(TimageSprite)
  private
  public
    procedure CollisionBalle ( const Balle : TBalle; const AllowPlomb : Boolean ); virtual;
  end;

 { TPresente }

 TPresente = class ( TCollisionSprite  ) // Sprite d'origine
 protected
    constructor Create( const AParent: TSprite; const PosX,PosY : Integer ); overload; 
  end;
 TMainSprite = class ( TimageSprite  ) // Sprite d'origine
  protected
    Mode,
    TamaMax         :Integer; // Maximum de Tama
    Compteur: Integer; // compteur global
    BDGH : Byte; // Variable de position
    Attend             : Integer; // Variable d'attente
  end;
      // UN item de menu
  TItemMenu = class(TimageSprite) // Sprite d'origine
  private
  Actif,Inactif                   :String;
  Active                          : boolean;
  procedure ChangeControle(NoControle : TInputType);
  procedure DoMove(MoveCount: Double); override;
   public
  constructor Create(const AParent: TSprite ; const FinImage : String; const X, Y : Double ; const I : Integer); overload;
  end;

     TItems = record
              LeSprite : TItemMenu;
              LAction : TActions;
              End;

  { TTire }
  TTire = class(TimageSprite)
  private
    Touche : Boolean ;
  Joueur : PPlayerSprite ;
  procedure DoMove(MoveCount: Double); override;
   // Gestion des collisions
  procedure   DoCollision(Sprite: TSprite; var Done: Boolean); override;
  public
    constructor Create ( const AParent: TSprite ; const UnJoueur : PPlayerSprite ); overload;
  end;

      // Sprite du ou des joueurs
  { TPlayerSprite }

  TPlayerSprite = class(TMainSprite)
   private
    Joueur : PPlayerSprite;
    Deplacement1,Deplacement2,Deplacement3 :Extended;
    BalleModif : TBalleModif;
    ControlX,ControlY,
    Mode,NoPalette : Integer;   // Mode (mort vivant touché)
    Controle : TInputType ;
    PlayerModifs : set of TPlayerModif;
    Intervalle, // Intervalle de rebondissment des balles
    CompteEnvoi,
    CompteurInversion,
    CompteurTire,
    CompteImmobile,
    PaletteEnCours,
    Inversion,
    VitesseBalles : integer;
    NoJoueur : Integer ;
    procedure Erase;
    procedure EnvoiBalle;
    procedure UneCollisionX ( const Sprite : TSprite ; var Done: Boolean);
    procedure UneCollisionY ( const Sprite : TSprite ; var Done: Boolean);
    procedure UneCollision(const Sprite: TSprite);
    procedure ChangeVitesses( const Vitesse : integer);
    function GetTirY ( const MoinsY : Boolean ; const SpriteTir : Ttire ): Double;
    function GetTirX ( const MoinsX : Boolean ; const SpriteTir : Ttire ): Double;
    procedure AnimOuvreBouche(const Sprites: array of TImageSprite);
    function InitPos ( const TheCoord : Double ; const NewCoord : Double ):Double;
    procedure Deplace(const InputCoord: Double);
   public
    constructor Create( const AParent: TSprite; const Apparaitre : Boolean; const Controle : TInputType); overload; virtual;
    // Methodes abstraites
    procedure BallesModif; overload; virtual; abstract;
    procedure SetPalette; overload; virtual; abstract;
    procedure CreeTir ( const Double : Boolean ); virtual; abstract;
    procedure CreateAnimBouche; overload; virtual; abstract;
    procedure CreatePlayer; virtual; abstract;

    // Methodes implémentées
    procedure CreateAnimBouche(var AnimBouche : Array of TImageSprite ; const AImage: String ); overload; virtual;
    procedure AnimBouche ( const Sprites : Array of TImageSprite ); dynamic;
    procedure AnimOuvre  ( var   Sprites : Array of TImageSprite ); dynamic;
    procedure SetPalette( const Palette : String ); overload; virtual;
    procedure DoMove(MoveCount: Double); override;
    procedure DetruitJoueur; virtual;
    procedure Cree; virtual;
    Procedure BalleFolleHautBas ( const Balle : TBalle); virtual;
    Procedure BalleFolleGaucheDroite ( const Balle : TBalle); virtual;
    Procedure BalleFolle ( const Balle : TBalle); virtual;
    procedure CreeTirHautBas ( const Double : Boolean ; const MoinsY : Boolean ); virtual;
    procedure CreeTirGaucheDroite ( const Double : Boolean ; const MoinsX : Boolean ); virtual;
    procedure BallesModif ( const Modif : TBalleModif ); overload; dynamic;
    procedure UnMouvement; dynamic;
    procedure UnMouvementY; dynamic;
    procedure UnMouvementX; dynamic;
    procedure BallePlus; dynamic;
    procedure SetBalleColle ( const UneBalle : TBalle ); virtual;
    procedure SetBalleCollePosition ( const UneBalle : TBalle ); virtual;
    procedure Controleur(Control : TInputType); virtual;
    procedure CreeBalle ( var UneBalle : TBalle ); virtual;
    procedure AppuieGaucheDroite     ( const ToucheAEnfoncerGauche   , ToucheAEnfoncerDroite   : Byte ); virtual;
    procedure AppuieHautBas     ( const ToucheAEnfoncerBas, ToucheAEnfoncerHaut : Byte ); virtual;
    procedure AppuieButton ( const ToucheAEnfoncer : Byte ); virtual;
    procedure ErasePlayer (); virtual;
  end;


  { TBalle }

  TBalle = class(TImageSprite)
  private
    Joueur : PPlayerSprite;
    DecalePalette,
    Vitesse,
    Accelere,
    NoBalle,
    BougeX,BougeY,
    Change   :integer;
    Mode :integer;
    Activite : set of TBalleModif;// Toute l'activité de la balle
    Grosseur : Integer ;
    function PerdJoueur   ( const Perdu : Boolean; const NoJoueur : Integer ):boolean;
    procedure LimitesX;
    procedure LimitesY;
    procedure ChangeVitesse;
    procedure BalleModif(const Player:PPlayerSprite);
    procedure SetImageGrosseur;
    procedure SetImagePosition;

    procedure ViesPlus;
     // Gestion des collisions
  public
    procedure DoMove(MoveCount: Double); override;
    procedure ChangeUneDirection ( const Decalage : Double ); virtual;
    procedure DoCollision ( Sprite : TSprite ; var Done: Boolean ); override;
    procedure ColleBalle(const Player : PPlayerSprite);
    procedure CollisionBalle ( const Balle : TBalle ); virtual;
    procedure Envoi; virtual;
    constructor Create ( const AParent: TSprite; const Joueur : PPlayerSprite ; Const X, Y : Double ); overload;
    procedure Show ; virtual;
  // Détruit la balle
    procedure Destruction;
  end;

  ABalle = ^TBalle;

  { TPlayerBas }

  TPlayerBas = class(TPlayerSprite)
  private
  public
    procedure CreateAnimBouche; override;
    procedure CreeTir ( const Double : Boolean ); override;
    Procedure BalleFolle ( const Balle : TBalle); override;
    procedure SetBalleColle ( const UneBalle : TBalle ); override;
    procedure BallesModif; override;
    procedure UnMouvement; override;
    procedure SetBalleCollePosition ( const UneBalle : TBalle ); override;
    // Gestion des mouvement
    procedure DoMove(MoveCount: Double); override;
    // Gestion des collisions
    procedure DoCollision(Sprite: TSprite; var Done: Boolean); override;
    procedure SetPalette; override;
    procedure CreatePlayer; override;
    destructor Destroy; override;
  end;

  { TPlayerHaut }

  TPlayerHaut = class(TPlayerSprite)
  private
//  SourisX : integer;
    // Gestion des mouvement
  public
    procedure CreateAnimBouche; override;
    procedure DoMove(MoveCount: Double); override;
   // Gestion des collisions
    procedure   DoCollision(Sprite: TSprite; var Done: Boolean); override;
    procedure SetBalleColle ( const UneBalle : TBalle ); override;
    Procedure BalleFolle ( const Balle : TBalle); override;
    procedure CreeTir ( const Double : Boolean ); override;
    procedure BallesModif; override;
    procedure UnMouvement; override;
    procedure SetBalleCollePosition ( const UneBalle : TBalle ); override;
    procedure SetPalette; override;
    procedure CreatePlayer; override;
    destructor Destroy; override;
  end;

  { TPlayerGauche }

  TPlayerGauche = class(TPlayerSprite)
  private
//  SourisY : integer;
    // Gestion des mouvement
  procedure DoMove(MoveCount: Double); override;
   // Gestion des collisions
  procedure   DoCollision(Sprite: TSprite; var Done: Boolean); override;
  public
    procedure CreateAnimBouche; override;
    procedure SetBalleColle ( const UneBalle : TBalle ); override;
    Procedure BalleFolle ( const Balle : TBalle); override;
    procedure CreeTir ( const Double : Boolean ); override;
    procedure BallesModif; override;
    procedure UnMouvement; override;
    procedure SetBalleCollePosition ( const UneBalle : TBalle ); override;
    procedure SetPalette; override;
    procedure CreatePlayer; override;
    destructor Destroy; override;
  end;

  { TPlayerDroite }

  TPlayerDroite = class(TPlayerSprite)
  private
//  SourisY : integer;
    // Gestion des mouvement
  public
    procedure CreateAnimBouche; override;
    procedure SetBalleColle ( const UneBalle : TBalle ); override;
    procedure DoMove(MoveCount: Double); override;
    Procedure BalleFolle ( const Balle : TBalle); override;
    procedure CreeTir ( const Double : Boolean ); override;
    procedure BallesModif; override;
    procedure UnMouvement; override;
    procedure SetBalleCollePosition ( const UneBalle : TBalle ); override;

    // Gestion des collisions
    procedure SetPalette; override;
    procedure DoCollision(Sprite: TSprite; var Done: Boolean); override;
    procedure CreatePlayer; override;
    destructor Destroy; override;
  end;

                // Un type de projectile

  { TTamaSprite }

  TTamaSprite = class(TMainSprite)
  private
  protected
   // Gestion des collisions
   // Gestion des mouvements
//  procedure DoMove(MoveCount: Double); override;
    // Joue un son avant de mourir
    procedure Destruction;
  public
  procedure   DoCollision(Sprite: TSprite; var Done: Boolean); override;
  procedure DoMove(MoveCount: Double); override;
   //Constructeur
//  constructor Create(AParent: TimageSprite;Joueur : TPlayerSprite); virtual;
    //Destructeur
//  destructor Destroy; override;
  end;

      // Un type de tile
  { TBrique }

  TBrique = class(TCollisionSprite)
  private
//  BDGH   : integer;
  Joueur : PPlayerSprite;
  NoBrique : Array [ 0 .. 5 ] of Byte;
  Mode : TModeBrique;
  procedure Touche;
  procedure Destruction;
  procedure DoMove(MoveCount: Double); override;
  public
    procedure CollisionBalle ( const Balle : TBalle ); overload;
    procedure InitBrique ( const i, j : Integer ; var Cases : TCases );
    constructor Create ( const AParent: TSprite; const i,j :integer ; var Cases : TCases ); overload;
  end;

  TItem = class(TimageSprite)
  private
  Palette : boolean;
  NoItem : integer;
  BDGH : TItemDirection ;
  procedure Destruction;
  procedure DoMove(MoveCount: Double); override;
   protected
  procedure NextAnimation;
  public
    constructor Create( const AParent: TSprite; const Joueur : PPlayerSprite ; const X, Y : Double ; const NoItem :  Integer ); overload; 
  end;

{ Fonctions }

function TestUneCoordonneeCercleRectangle( const CentreX , CentreY, Rayon, CoordX, CoordY : Double ): Boolean;
begin
  if  ( CentreX - CoordX <= Abs ( Rayon ))
  and ( CentreY - CoordY <= Abs ( Rayon ))
    Then
      Result := True
     else
      Result := False ;
end;

function TestCollisionCercleRectangle(const Cercle,Rectangle: TSprite): Boolean;
var CentreX ,
    CentreY ,
    Rayon   : Double ;
begin
  CentreX := Cercle.X + Cercle.width  / 2 ;
  CentreY := Cercle.Y + Cercle.height / 2 ;
  Rayon := Cercle.Width / 2 - 1 ;
  Result := TestUneCoordonneeCercleRectangle(CentreX,CentreY,Rayon,Rectangle.X,Rectangle.Y)
         or TestUneCoordonneeCercleRectangle(CentreX,CentreY,Rayon,Rectangle.X+Rectangle.Width,Rectangle.Y)
         or TestUneCoordonneeCercleRectangle(CentreX,CentreY,Rayon,Rectangle.X,Rectangle.Y+Rectangle.Height)
         or TestUneCoordonneeCercleRectangle(CentreX,CentreY,Rayon,Rectangle.X+Rectangle.Width,Rectangle.Y+Rectangle.Height) ;
end;

function TestCollisionCercleCercle(const Cercle1,Cercle2: TSprite): Boolean;
var EcartX,EcartY   : Double ;
begin
  EcartX := Abs (( Cercle1.X + Cercle1.width  / 2  ) - ( Cercle2.X + Cercle2.width  / 2 ));
  Result := EcartX < Cercle1.Width / 2 - 1 + Cercle2.Width / 2 - 1 ;
  if ( Result ) Then
     Begin
       EcartY := Abs (( Cercle1.Y + Cercle1.Height / 2 ) - ( Cercle2.Y + Cercle2.Height  / 2 ));
       Result := EcartY < Cercle1.Height / 2 + Cercle2.Height / 2;
     End;
end;


{ TCollisionSprite }

procedure TCollisionSprite.CollisionBalle(const Balle: TBalle; const AllowPlomb : Boolean );
var MilieuX,MilieuY, VecteurAjouteY, VecteurAjouteX                  :integer;
    ModifX, ModifY                  : boolean;
begin
  ModifX:=False;
  ModifY:=False;
  MilieuX:=trunc(Balle.X+Balle.Height/2);
  MilieuY:=trunc(Balle.Y+Balle.Height/2);
//   begin
  if not AllowPlomb
  or not (bmPlomb in Balle.Activite) then
    begin
      if ((X>=MilieuX) and (Balle.BougeX>0))
      or ((X+Width<=MilieuX) and (Balle.BougeX<0)) then
       //La balle vient de la gauche ou de la droite
        Begin
         ModifX:=True;
         VecteurAjouteY := trunc ( X - MilieuX );
        End ;
      if ((Y>=MilieuY) and (Balle.BougeY>0))
      or ((Y+Height<=MilieuY) and (Balle.BougeY<0))
       //La balle vient du haut et du bas
       then
        Begin
          ModifY:=True;
          VecteurAjouteX := trunc (  Y - MilieuY );
        End;
    End;

 if ModifX then Balle.BougeX:=-Balle.BougeX;
 if ModifY then Balle.BougeY:=-Balle.BougeY;
 if ModifX and ModifY then
   Begin
    inc( Balle.BougeY, VecteurAjouteY );
    inc( Balle.BougeX, VecteurAjouteX );
   End;
end;

{ TPresente }

constructor TPresente.Create(const AParent: TSprite; const PosX,PosY: Integer);
begin
  inherited Create ( AParent );
  SetImage ( ImageList.Find ( 'Presente' + IntToStr ( PosY )+ IntToStr ( PosX ) ));
  Width  := Image.Width ;
  Height := Image.Height ;
  CanDoCollisions:=True;
  If Posx = 0 Then
    Begin
      X := EcranX - LimiteXImages + 1 ;
    End
   Else
    Begin
      X := LimiteXImages - Width - 1 ;
    End ;
  If PosY = 0 Then
    Begin
      Y := EcranY - LimiteYImages + 1 ;
    End
   Else
    Begin
      Y := LimiteYImages - Height - 1 ;
    End ;
end;

type  UneBrique      = RECORD
                       Brique : TBrique;
                       Existe : Boolean;
                       End;
      TBriques        = ARRAY[0..NbBriquesX-1,0..NbBriquesY-1] of UneBrique;

var
    Items : ARRAY[0..MaXItems-1] of TItems;
    BoucheGauche : ARRAY[0..MaxMurGD] of TimageSprite;
    BoucheDroite : ARRAY[0..MaxMurGD] of TimageSprite;
    BoucheBas : ARRAY[0..MaxMurBH] of TimageSprite;
    BoucheHaut : ARRAY[0..MaxMurBH] of TimageSprite;
    Action_Sprite : TActions;
    joueurs: Array [ 1 .. 4 ] of TPlayerSprite;
//    Controles : ARRAY[1..4] of byte;
    Fenetre : TFenetres;
//    XCombien :Byte;
    Briques : Tbriques;
    LettresScore : TLettres ;
    LettresPVie  : TLettres ;
    LettresVie   : TLettres ;
    Curseur : TCurseur;


{ TLettre }

procedure TLettre.DoMove(MoveCount: Double);
begin
  inherited DoMove(MoveCount);
end;

procedure TLettre.SetLettre(const Lettre: Char; const ReDraw: Boolean);
begin
  If Redraw
  or ( Lettre <> FLettre ) Then
    if FPetite Then
      Begin
        If  (Ord ( Lettre ) >= ChiffreDebut )
        and (Ord ( Lettre ) <= ChiffreFin ) Then
          SetImage ( ImageList.Find(ChiffrePetit + Lettre ))
         Else
          SetImage ( ImageList.Find(LettreGrosse + Lettre ));
        Width  := 8;
        Height := 16;
      End
     Else
      Begin
        If  (Ord ( Lettre ) >= ChiffreDebut )
        and (Ord ( Lettre ) <= ChiffreFin ) Then
          SetImage ( ImageList.Find(ChiffreGros + Lettre ))
         Else
          SetImage ( ImageList.Find(LettreGrosse + Lettre ));
        Width  := 16;
        Height := 16;
      End;
end;

procedure TLettre.SetGrosseur(const Petite: Boolean);
begin
  if ( FPetite <> Petite ) Then
    Begin
      FPetite := Petite ;
      SetLettre ( FLettre, True );
    End ;
end;

constructor TLettre.Create(const AParent: TSprite; const Lettre: Char;const X, Y : Double );
begin
  inherited Create(AParent);
  Self.X := X ;
  Self.Y := Y ;
  CanDoCollisions:=False;
  SetLettre( Lettre, False);
end;


procedure TItemMenu.ChangeControle(NoControle : TInputType);
Begin
Case NoControle of
 itInactive     : begin
                  Actif:=ImageActif + 'Inactif';
                  Inactif:='Inactif';
                  end;
 itKeyboard1       : begin
                  Actif:=ImageActif + 'Clavier1';
                  Inactif:='Clavier1';
                  end;
 itKeyboard2       : begin
                  Actif:=ImageActif + 'Clavier2';
                  Inactif:='Clavier2';
                  end;
 itJoystick1      : begin
                  Actif:=ImageActif + 'Joystick1';
                  Inactif:='Joystick1';
                  end;
 itJoystick2      : begin
                  Actif:=ImageActif + 'Joystick2';
                  Inactif:='Joystick2';
                  end;
 itMouse         : begin
                  Actif:=ImageActif + ImageSouris;
                  Inactif:=ImageSouris;
                  end;
 end;
 Active:=True;
 Image:=ImageList.Find(Actif);
End;

procedure InitClavier1 ( const NoJoueur : Integer );
Begin
  ToucheHaut [ NoJoueur ] := VK_Up ;
  ToucheBas [ NoJoueur ]  := VK_Down ;
  ToucheGauche [ NoJoueur ]  := VK_Left ;
  ToucheDroite [ NoJoueur ]  := VK_right ;
  ToucheBoutonA [ NoJoueur ]  := VK_DELETE ;
  ToucheBoutonB [ NoJoueur ]  := VK_RETURN ;
End;


destructor  TMainForm.Destroy;
Begin
  if assigned ( FIniFile ) Then
    FIniFile.UpdateFile ;
  Addraw.Free;
  ImageList.Free;
  ImageListTirs.Free;
//  Fond.free;
  FondImage.free;
  FIniFile.free ;
  AdPerCounter.free;
End ;

procedure TItemMenu.DoMove(MoveCount: Double);
var NewImage : String ;
begin
  NewImage := '' ;
  if (Curseur.X>X) and (Curseur.Y>Y) and (Curseur.X<X+Width) and (Curseur.Y<Y+Height) then
   begin
   if ( not Active ) then
    Begin
     if Inactif=ImageJoueurs then
      begin
        NewImage := ImageActif+IntToStr(MainForm.NbJoueurs)+ImageJoueurs;
      end
      else
       NewImage := Actif;
     Active:=True;
    End;
   End
   else if Active then
    begin
    Active:=False;
    if Inactif=ImageJoueurs then
     begin
       NewImage := IntToStr(MainForm.NbJoueurs)+ImageJoueurs;
     end
     else
      NewImage := InActif;
    End;
  if ( NewImage <> '' ) then
   Begin
    ImageList.Find(NewImage);
    Width:=Image.Width;
    Height:=Image.Height;
   End;
end;

constructor TItemMenu.Create(const AParent: TSprite; const FinImage : String; const X, Y : Double ; const I : Integer );
begin
  inherited Create(AParent);
  Active:=False;
  Actif:=ImageActif + FinImage;
  Inactif:=FinImage;
  Image:=ImageList.Find(Inactif);
  Width:=Image.Width;
  Height:=Image.Height;
  Self.Y:=Y + Height * I;
  Self.X:=X ;
End;
    { Curseur }
procedure TCurseur.DoMove(MoveCount: Double);
begin
  X:=MainForm.MouseX;
  Y:=MainForm.MouseY;
{  If ( ToucheHaut [ 1 ]    and MainForm.KeyboardState = ToucheHaut [ 1 ]   ) Then  Y:= Y - 12;
  If ( ToucheBas [ 1 ]     and MainForm.KeyboardState = ToucheBas [ 1 ]    ) Then  Y:= Y + 12;
  If ( ToucheDroite [ 1 ]  and MainForm.KeyboardState = ToucheDroite [ 1 ] ) Then  X:= X + 12;
  If ( ToucheGauche [ 1 ]  and MainForm.KeyboardState = ToucheGauche [ 1 ] ) Then  X:= X - 12;
 } if X<0 then X:=0;
  if Y<0 then Y:=0;
  if X>EcranX then X:=EcranX;
  if Y>EcranY then Y:=EcranY;
End;

constructor TCurseur.Create(const AParent: TSprite ; const MonImage :  String );
begin
  inherited Create(AParent);
  Image:=ImageList.Find(MonImage);
  X:=0;
  Y:=0;
  Z:=10;
  Width  := Image.Width;
  Height := Image.Height;
  //AnimCount:=Image.PatternCount;
  AnimStart := 0 ;
  AnimStop := Image.PatternCount - 1 ;
  AnimActive := True ;
  AnimLoop := True;
  AnimPos := 0;
  //AnimSpeed := Vitesse/1000;
  Visible:=True;
End;
{  TMainSprite  }

procedure TBalle.ViesPlus;
Begin
if PointsVie>=AjouteVie then
 begin
  inc(Vies);
  dec(PointsVie,AjouteVie);
 end;
if Score>=ScoreAjouteVie then
 begin
 inc(Vies);
 ScoreAjouteVie:=ScoreAjouteVie*2;
 end;
End;

procedure TplayerSprite.Erase ();
  Begin
    if not Visible then
      Begin
        CanDoCollisions := False ;
        Visible := False;
        dec(NbPalettes);
      End;
  End ;

procedure TPlayerSprite.CreateAnimBouche ( var AnimBouche : Array of TImageSprite ; const AImage : String );
var i : integer;
begin
// L'animation de bouchage comprant un certain nombre de sprites
for I:=0 to high ( AnimBouche ) do
  Begin
    AnimBouche[I]:= TImageSprite.Create ( SpriteEngine );
    with AnimBouche[I] do
      begin
        Visible := True;
        // On vérifie des variables
        if i = 0 then Image:=ImageList.Find(AImage+'1')
          else if i = high (AnimBouche) then Image:=ImageList.Find(AImage+'3')
          else Image:=ImageList.Find(AImage+'2');
        Width:=Image.Width;
        Height:=Image.Height;
        case NoJoueur of
          Bas    : Begin if i = 0 Then X:= LimiteX-4 Else X:= LimiteX-4+I*AnimBouche[I-1].Width ; Y := EcranY-Height+Bouche; End;
          Haut   : Begin if i = 0 Then X:= LimiteX-4 Else X:= LimiteX-4+I*AnimBouche[I-1].Width ; Y := -Bouche; End;
          Gauche : Begin if i = 0 Then Y:= LimiteY   Else Y:= LimiteY  +I*AnimBouche[I-1].Height; X := -Bouche; End;
          Droite : Begin if i = 0 Then Y:= LimiteY   Else Y:= LimiteY  +I*AnimBouche[I-1].Height; X := EcranX-Width+Bouche;  End;
        end;
       End;
  End;
end;


procedure TPlayerSprite.AnimBouche(const Sprites: array of TImageSprite );
var I :integer;
Begin
  if Intervalle<Bouche then
   begin
     inc(Intervalle);
     AnimOuvreBouche(Sprites);
   End
   else
    begin
      PlayerModifs:=PlayerModifs-[pmEnlever];
    End;
end;

procedure TPlayerSprite.AnimOuvreBouche( const Sprites: array of TImageSprite );
Var I:integer;
Begin
   case NoJoueur of
    Gauche,Haut :
     for I:=0 to high ( Sprites ) do
       If NoJoueur = Haut then
         Sprites[I].Y:=Intervalle-Bouche
        else
         Sprites[I].X:=Intervalle-Bouche;
    else
     for I:=0 to high ( Sprites ) do
       if NoJoueur = Bas then
         Sprites[I].Y:=EcranY-Intervalle-Sprites[I].Height+Bouche
        else
         Sprites[I].X:=EcranX-Intervalle-Sprites[I].Width+Bouche;
   end;

End;
procedure TPlayerSprite.AnimOuvre( var Sprites: array of TImageSprite );
Var I:integer;
Begin
  if Intervalle>0 then
   begin
     PlayerModifs := PlayerModifs + [ pmAfficher ] ;
     dec(Intervalle);
     AnimOuvreBouche(Sprites);
   End
    else
     if not Visible Then
      begin
//        MainForm.Disparait[NoJoueur]:=False;
        PlayerModifs := PlayerModifs - [ pmAfficher ] ;
        for I:=0 to high ( Sprites ) do
           begin
             Sprites[I].dead;
             Sprites[I]:=nil;
           End;
        Cree;
      End;
end;

procedure TplayerSprite.AppuieButton ( const ToucheAEnfoncer : Byte );
  Begin
    if ([ pmEnlever, pmAfficher ] * PlayerModifs <> [] )
      Then
        Exit ;
    case Controle of
      itMouse :
        begin
          if (MainForm.MouseButtonLeft) and self.Visible then
             begin
                PlayerModifs := PlayerModifs + [pmBouge];
                EnvoiBalle;
              end;
{               if (Mouse.Buttons[0]) and not self.Visible then
                CanAppear:=True;}
         End;
      itKeyboard1,itKeyboard2 :
         begin
           if (ToucheAEnfoncer and MainForm.KeyBoardState= ToucheAEnfoncer) and self.Visible then
             begin
                PlayerModifs := PlayerModifs + [pmBouge];
                EnvoiBalle;
              end;
{               if (isButton1 in States) and not self.Visible then
                CanAppear:=True;}
          End;
{      itJoystick1,itJoystick2 :begin
               if (isButton1 in Joystick.States) and self.Visible
                 then
                   EnvoiBalle;
               End;}
      End;
  end;

constructor TPlayerSprite.Create(const AParent: TSprite; const Apparaitre : Boolean; const Controle : TInputType );
begin
  inherited Create(AParent);
  Cree;
  SetPalette;
  Controleur(Controle);
end;

procedure TPlayerSprite.ErasePlayer ();
begin
  PlayerModifs := PlayerModifs + [pmEnlever];
  Controleur ( itInactive );
end;

Procedure TPlayerSprite.BalleFolle ( const Balle : TBalle);
begin
  Balle.Activite:=Balle.Activite - [bmColle];
End;

Procedure TPlayerSprite.BalleFolleHautBas ( const Balle : TBalle);
begin
  if ControlX+X>X then
    begin
      inc(Balle.BougeX);
    End;
  if ControlX+X<X then
    Begin
      dec(Balle.BougeX);
    End;
  Randomize;
  if Balle.BougeY=0 then Balle.BougeY:=Random(10)+1;
  Balle.LimitesX;
end;


Procedure TPlayerSprite.BalleFolleGaucheDroite ( const Balle : TBalle);
begin
  if ControlY+Y>Y then inc(Balle.BougeY);
  if ControlY+Y<Y then dec(Balle.BougeY);
  Randomize;
  if Balle.BougeX=0 then Balle.BougeX:=Random(10)+1;
  Balle.LimitesY;
End;

procedure TPlayerSprite.DoMove(MoveCount: Double);
begin
  AppuieButton ( ToucheBoutonA [ NoJoueur ] );
  if ( pmAfficher in PlayerModifs ) then
   begin
     Case NoJoueur of
       Bas    :  AnimOuvre ( BoucheBas    );
       Haut   :  AnimOuvre ( BoucheHaut   );
       Gauche :  AnimOuvre ( BoucheGauche );
       Droite :  AnimOuvre ( BoucheDroite );
     End;
   End;

  if (pmEnlever in PlayerModifs) then
   begin
     NoPalette:=1;
     ErasePlayer;
     if (NoPalette=PaletteEnCours) then
       Begin
         Erase ;
         Case NoJoueur of
           Bas    :  AnimBouche ( BoucheBas );
           Haut   :  AnimBouche ( BoucheHaut );
           Gauche :  AnimBouche ( BoucheGauche );
           Droite :  AnimBouche ( BoucheDroite );
         End;

       End;
   End;
  if CompteImmobile=0 then
   begin
     UnMouvement;
   end
    else dec(CompteImmobile);
  inherited Domove ( MoveCount );
  If ( Deplacement1 > 0 ) then
    Begin
     PlayerModifs := PlayerModifs + [pmBouge];
    End;
//  Collision;
end;


procedure TPlayerSprite.Deplace(const InputCoord: Double);
begin
 Deplacement3:=Deplacement2;
 Deplacement2:=Deplacement1;
 Deplacement1:=InputCoord*Inversion;
end;

procedure TPlayerSprite.DetruitJoueur;
begin
  if (MainForm.NbJoueurs>0)
  and (NBBalles=0)
  and ( [pmBouge,pmEnlever] * PlayerModifs = [] )
   Then
    Begin
      Controleur ( itInactive );
      PlayerModifs := PlayerModifs + [pmEnlever,pmErased];
    End;
end;
function TPlayerSprite.InitPos ( const TheCoord : Double ; const NewCoord : Double ): Double;
begin
  Deplacement3:=0;
  Deplacement2:=0;
  Deplacement1:=NewCoord-trunc(TheCoord);
  Result:=NewCoord;
End;
procedure TPlayerSprite.UnMouvementY;
begin
 Deplace(ControlY);
 if Y+Height+Deplacement1+Deplacement2 / 4+Deplacement3 / 8>EcranY-LimiteY then
  begin
    Y := InitPos ( Y, EcranY-LimiteY-Height );
  end
  else
 if Y+Deplacement1+Deplacement2 / 4+Deplacement3 / 8<LimiteY then
  begin
    Y := InitPos ( Y, LimiteY );
  End
   else
    Y:=Y+Deplacement1+Deplacement2 / 4+Deplacement3 / 8;
end;

procedure TPlayerSprite.UnMouvementX;
begin
 Deplace(ControlX);
 if X+Width+Deplacement1+Deplacement2 / 4+Deplacement3 / 8>EcranX-LimiteX then
  begin
    X := InitPos ( X, EcranX-LimiteX-Width );
  end
  else
 if X+Deplacement1+Deplacement2 / 4+Deplacement3 / 8<LimiteX then
  begin
    X := InitPos ( X, LimiteX );
  End
   else
   X:=X+Deplacement1+Deplacement2 / 4+Deplacement3 / 8;
End;
procedure TplayerSprite.AppuieGaucheDroite     (  const ToucheAEnfoncerGauche   , ToucheAEnfoncerDroite : Byte  );
  begin
    if (( [pmEnlever,pmAfficher] * PlayerModifs ) = [] ) then
      case Controle of
        itMouse : begin
                 ControlX:=trunc(MainForm.MouseX-X);
                 End;
        itKeyboard1,itKeyboard2 :
                 begin
                 if (ToucheAEnfoncerDroite and MainForm.KeyBoardState= ToucheAEnfoncerDroite) then
                 ControlX:=round ( 10+Deplacement2 / 2+ Deplacement3 / 3 )
                  else
                  if (ToucheAEnfoncerGauche and MainForm.KeyBoardState = ToucheAEnfoncerGauche) then
                   ControlX:=round ( -10+Deplacement2 / 2 + Deplacement3 / 3 )
                    else ControlX:=0;
                 End;
{
        itJoystick1,itJoystick2 :begin
                 ControlX:=Joystick.X;
                 End;
                 }
        end;
  end;

procedure TplayerSprite.AppuieHautBas ( const ToucheAEnfoncerBas, ToucheAEnfoncerHaut : Byte );
  begin
    if (( [pmEnlever,pmAfficher] * PlayerModifs ) = [] ) then
    case Controle of
      itMouse : begin
                 ControlY:=trunc(MainForm.MouseY-Y);
               End;
      itKeyboard1,itKeyboard2 :
               begin
               if (ToucheAEnfoncerBas and MainForm.KeyBoardState= ToucheAEnfoncerBas) then
               ControlY:=round ( 10+Deplacement2 / 2+ Deplacement3 / 3 )
                else
                if (ToucheAEnfoncerHaut and MainForm.KeyBoardState= ToucheAEnfoncerHaut) then
                 ControlY:=round ( -10+Deplacement2 / 2 + Deplacement3 / 3 )
                  else ControlY:=0;
               End;
{
      itJoystick1,itJoystick2 :begin
               ControlY:=Joystick.Y;
               End;}
      end;
    end;

procedure TPlayerSprite.SetPalette(const Palette: String);
begin
 case NoPalette of
  1 : SetImage ( ImageList.Find(ImagePalette + Palette + PaletteMinus));
  2 : SetImage ( ImageList.Find(ImagePalette + Palette + PalettePetite));
  3 : SetImage ( ImageList.Find(ImagePalette + Palette + PaletteMoyenne));
  4 : SetImage ( ImageList.Find(ImagePalette + Palette + PaletteColle));
  5 : SetImage ( ImageList.Find(ImagePalette + Palette + PaletteTire + '1'));
  6 : SetImage ( ImageList.Find(ImagePalette + Palette + PaletteTire + '2'));
  7 : SetImage ( ImageList.Find(ImagePalette + Palette + PaletteInvisible));
  8 : SetImage ( ImageList.Find(ImagePalette + Palette + PaletteGrande));
  End;
 If (( pmAfficher in PlayerModifs ) and Visible and ( PaletteEnCours = NoPalette )) Then
   Begin
     Controle:= MainForm.ControleJoueur [ NoJoueur ];
     PlayerModifs:=PlayerModifs-[pmAfficher];
     if PaletteEncours=4 then Mode:=Colle;
     if (PaletteEncours>=7)
     or (PaletteEncours< 4) then Mode:=0;
     if (PaletteEncours=1) and visible and ( pmEnlever in PlayerModifs ) then
      Controleur(itInactive);
   End;
 Width:=Image.Width;
 Height:=Image.Height;

end;

procedure TPlayerSprite.Cree;
begin
  PlayerModifs := [pmAfficher];
  inc(NbPalettes);
  CompteurTire := 0 ;
  CompteurInversion:=0;
  CompteEnvoi:=0;
  Inversion:=1;
  NoPalette:=3;
  PaletteEnCours:=1;
  CompteImmobile:=0;
  VitesseBalles :=Lente;
  Mode:=0;
  Deplacement1:=0;
  Deplacement2:=0;
  Deplacement3:=0;
  BDGH:=0;
  TamaMax:=1;
  Mode:=0;
  Attend:=0;
  Z := ZJoueurs;
  AnimActive := False;
  AnimSpeed := Vitesse/1000;
  Visible:=True;
  CanDoCollisions:=True;
  CreatePlayer ;
End;

procedure TPlayerSprite.CreeBalle(var UneBalle: TBalle);
begin
  if NbBalles > Maxiballes Then
    Exit;
  if not assigned ( UneBalle ) Then
    Begin
      UneBalle := TBalle.Create(SpriteEngine, Joueur, Self.X + Self.Width / 2, Self.Y + Self.Height / 2 );
    End;
end;

procedure TPlayerSprite.CreeTirHautBas(const Double: Boolean; const MoinsY : Boolean );
var Decale : Integer;
    SpriteTir : Ttire ;
begin
  if Double then
    Begin
      Decale := 13;
      SpriteTir := Ttire.create(SpriteEngine, Joueur);
      SpriteTir.X:= self.X + self.Width / 2 - SpriteTir.Width / 2 - Decale;
      SpriteTir.Y:= GetTirY ( MoinsY , SpriteTir );
    End
   Else
    Decale := 0 ;
  SpriteTir := Ttire.create(SpriteEngine, Joueur);
  SpriteTir.X:= self.X + self.Width / 2 - SpriteTir.Width / 2 + Decale;
  SpriteTir.Y:= GetTirY ( MoinsY , SpriteTir );
end;

procedure TPlayerSprite.CreeTirGaucheDroite(const Double : Boolean; const MoinsX : Boolean );
var Decale : Integer;
    SpriteTir : Ttire ;
begin
  if Double then
    Begin
      Decale := 10 ;
      SpriteTir := Ttire.create(SpriteEngine, Joueur);
      SpriteTir.X:= GetTirX ( MoinsX , SpriteTir );
      SpriteTir.Y:= self.Y + Self.Height / 2 - SpriteTir.Height / 2 - Decale;
    End
   Else
    Decale := 0 ;
  SpriteTir := Ttire.create(SpriteEngine, Joueur);
  SpriteTir.X:= GetTirX ( MoinsX , SpriteTir );
  SpriteTir.Y:= self.Y + Self.Height / 2 - SpriteTir.Height / 2 + Decale;
end;

procedure TPlayerSprite.Controleur(Control : TInputType);
begin
  if ( Control <> Controle ) Then
    Begin
      Controle:=Control;
      if Controle=itInactive then
        begin
         Intervalle:=0;
         PlayerModifs:=PlayerModifs+[pmEnlever];
         Dec(NbPalettes);
         Visible:=False;
    //       CanDoMoving:=False;
         CanDoCollisions:=False;
         CreateAnimBouche;
    //       EnvoiBalle;
        End
       Else
        CanDoCollisions:=True;
  //CanDoCollisions:=False;
      case Controle of
       itKeyboard1 : Begin
                    InitClavier1 ( NoJoueur );
                  End ;
       itKeyboard2 : Begin
                    ToucheHaut [ NoJoueur ] := Ord ( 'E' );
                    ToucheBas [ NoJoueur ]  := Ord ( 'D' );
                    ToucheGauche [ NoJoueur ]  := Ord ( 'S' );
                    ToucheDroite [ NoJoueur ]  :=  Ord ( 'F' );
                    ToucheBoutonA [ NoJoueur ]  :=  Ord ( ' ' );
                    ToucheBoutonB [ NoJoueur ]  :=   Ord ( 'R' );
                  End ;
       itInactive,itMouse,itJoystick1,itJoystick2 :
                 Begin
                    ToucheHaut [ NoJoueur ]     := 255;
                    ToucheBas [ NoJoueur ]      := 255;
                    ToucheGauche [ NoJoueur ]   := 255;
                    ToucheDroite [ NoJoueur ]   := 255;
                    ToucheBoutonA [ NoJoueur ]  := 255;
                    ToucheBoutonB [ NoJoueur ]  := 255;
                  End ;
                      {
     itJoystick1,itJoystick2 :
              begin
              Joystick.Enabled:=True;
              Case Controle of
               itJoystick1:JoyStick.ID:=0;
               itJoystick2:JoyStick.ID:=1;
               end;
              End;}
     End;
    End;
//          KeyBoard.Enabled:=True;
end;

procedure TPlayerSprite.BallePlus;   // balle supplémentaire
var UneBalle     : TBalle ;
begin
  UneBalle := nil ;
  CreeBalle ( UneBalle );


End;

procedure TPlayerSprite.SetBalleColle(const UneBalle: TBalle);
begin
  UneBalle.ColleBalle(Joueur);
end;

procedure TPlayerSprite.ChangeVitesses(const Vitesse : integer);
begin
  Randomize;
  VitesseBalles:=Vitesse*Random(50);
  if VitesseBalles > VitesseMax Then
    VitesseBalles := VitesseMax ;
End;

function TPlayerSprite.GetTirY(const MoinsY: Boolean; const SpriteTir: Ttire
  ): Double;
begin
  if MoinsY Then
     Result:= self.Y - SpriteTir.width
    else
     Result:= self.Y ;

end;

function TPlayerSprite.GetTirX(const MoinsX: Boolean; const SpriteTir: Ttire
  ): Double;
begin
  if MoinsX Then
     Result:= self.X - SpriteTir.height
    else
     Result:= self.X ;
end;

procedure TPlayerSprite.BallesModif ( const Modif : TBalleModif );
begin
  BalleModif:=Modif;
End;

procedure TPlayerSprite.SetBalleCollePosition(const UneBalle: TBalle);
begin
end;

procedure TPlayerSprite.UnMouvement;
begin
  inc (CompteurTire);
  If CompteEnvoi=TempsEnvoi then EnvoiBalle;
  if CompteurInversion>0 then dec(CompteurInversion)
   else Inversion:=1;
  inc(CompteEnvoi);
  inc(Compteur);
  if (NoPalette<>PaletteEnCours) and (Compteur mod 5=0) then
   begin
     if PaletteEncours<NoPalette then inc(PaletteEnCours);
     if PaletteEncours>NoPalette then dec(PaletteEnCours);
     SetPalette;
    //  end;
   End;
end;

procedure TPlayerSprite.UneCollisionX(const Sprite: TSprite; var Done: Boolean);
var UneBalle : TBalle ;
begin
  UneCollision( Sprite );
  if (Sprite is TBalle) then // and (Y+Milieu>=JoueurBasY) then
   begin
     UneBalle := Tballe(Sprite);
     UneBalle.Joueur:=Joueur;
     if not ( bmColle in UneBalle.Activite ) Then
       Begin
         UneBalle.BougeY:=-UneBalle.BougeY ;
         CompteEnvoi:=0;
         UneBalle.Change:=0;
         UneBalle.DecalePalette:= trunc( Uneballe.X + UneBalle.Width/2 - Self.X - Self.Width / 2 );
         if ( Abs ( UneBalle.DecalePalette ) > Self.Width / 3 ) Then
           if ( UneBalle.BougeX <> 0 ) Then
              Begin
                UneBalle.BougeX := UneBalle.BougeX div UneBalle.BougeX * UneBalle.DecalePalette ;
              End
             Else
              Begin
                UneBalle.BougeX := UneBalle.DecalePalette ;
              End;
         UneBalle.DecalePalette:= trunc ( Uneballe.X - Self.X );
         UneBalle.LimitesX;
        End;
     UneBalle.ColleBalle(Joueur);
   end;
end;

procedure TPlayerSprite.UneCollisionY(const Sprite: TSprite; var Done: Boolean);
var UneBalle : TBalle ;
begin
  UneCollision( Sprite );
  if ( Sprite is TBalle) then // and (Y+Milieu>=JoueurBasY) then
   begin
     UneBalle := TBalle ( Sprite );
     UneBalle.Joueur:=Joueur;
     if not ( bmColle in UneBalle.Activite ) Then
       Begin
         UneBalle.BougeX:=-UneBalle.BougeX ;
         CompteEnvoi:=0;
         UneBalle.DecalePalette:= trunc( Uneballe.Y + UneBalle.Width/2 - Self.Y - Self.Height / 2 );
         if ( Abs ( UneBalle.DecalePalette ) > Self.Height / 3 ) Then
           if ( UneBalle.BougeY <> 0 ) Then
              Begin
                UneBalle.BougeY := UneBalle.BougeY div UneBalle.BougeY * UneBalle.DecalePalette ;
              End
             Else
              Begin
                UneBalle.BougeY := UneBalle.DecalePalette ;
              End;
         UneBalle.DecalePalette:= Trunc ( Uneballe.Y - Self.Y );
         UneBalle.LimitesY;
         UneBalle.Change:=0;
       End;
     UneBalle.ColleBalle(Joueur);
   end;

end;

procedure TPlayerSprite.UneCollision(const Sprite: TSprite);
var UnItem : TItem ;
Begin
  if Sprite is TItem then
    begin
      UnItem := TItem ( Sprite );
      UnItem.CanDoCollisions:=False;
      case UnItem.NoItem of
         BColle : begin
                 inc(Score,PColle*NbPalettes);
             NoPalette:=4;
             end;
         BTire1 : begin
                  inc(Score,PTire1*NbPalettes);
                  NoPalette:=5;
                  MainForm.Playsound(ImagePalette + 'Tire',False);
                  end;
         BTire2 : begin
                  inc(Score,PTire2*NbPalettes);
                  NoPalette:=6;
                  MainForm.Playsound(ImagePalette + 'Tire',False);
                  end;
         BMinus : begin
                  inc(Score,PMinus*NbPalettes);
                  MainForm.Playsound('' + PaletteMinus,False);
                  NoPalette:=1;
                  end;
         BPetit : begin
                  inc(Score,PPetit*NbPalettes);
                  MainForm.Playsound('' + PaletteMinus,False);
                  NoPalette:=2;
                  end;
         BGrand : begin
                  inc(Score,PGrand*NbPalettes);
                  MainForm.Playsound('' + PaletteGrande,False);
                  NoPalette:=8;
                  end;
         BBase : begin
                 inc(Score,PBase*NbPalettes);
                 BallesModif ( bmNormal );
                 end;
         BSpeedUp : begin
                    inc(Score,PSpeedUp*NbPalettes);
                    MainForm.Playsound('SpeedUp',False);
                     begin
                     ChangeVitesses(VitesseBalles+1);
                     End;
                    end;
         BSpeedDown : begin
                    inc(Score,PSpeedDown*NbPalettes);
                     begin
                     ChangeVitesses(VitesseBalles-1);
                     End;
                      end;
         BInversion: begin
                     inc(Score,PInversion*NbPalettes);
                     Inversion:=-1;
                     CompteurInversion:=TempsInversion;
                     end;
         BImmobile: begin
                    inc(Score,PImmobile*NbPalettes);
                    MainForm.Playsound('Immobile',False);
                    CompteImmobile:=TempsImmobile;
                    end;
         BTransparent: begin
                       inc(Score,PTransparent*NbPalettes);
                       NOPalette:=7;
                       end;
         BFolle: begin
                 inc(Score,PFolle*NbPalettes);
                 MainForm.Playsound('Folle',False);
                 BallesModif;
                 end;
         BPlomb : begin
                  inc(Score,PPlomb*NbPalettes);
                  BallesModif ( bmPlomb );
                  end;
         BPlusGros : begin
                  inc(Score,PPlusGRosse*NbPalettes*NBBalles);
                  BallesModif ( bmPlusGrosse );
                  end;
         BMoinsGros : begin
                  inc(Score,PMoinsGRosse*NbPalettes);
                  BallesModif ( bmMoinsGrosse );
                  end;
         BBalle: begin
                 inc(Score,PBalle*NbPalettes);
                 BallePlus;
                 end;
         BpointsX3: begin
                    inc(Score,PPointsX3*NbPalettes);
                    inc(PointsVie,3);
                    end;
         BpointsX2: begin
                    inc(Score,PPointsX2*NbPalettes);
                    inc(PointsVie,2);
                    end;
         BpointsX1: begin
                    inc(Score,PPointsX1*NbPalettes);
                    inc(PointsVie);
                    end;
       End;
      UnItem.Palette:=True;
    end;
end;

procedure TPlayerSprite.EnvoiBalle;

begin
  CompteEnvoi:=0;
  PlayerModifs := PlayerModifs + [pmEnvoiBalle];
  If ( NoPalette = 5 ) and ( CompteurTire > 20 )
    Then
      Begin
        CompteurTire := 0;
        CreeTir ( False );
     End ;
  If ( NoPalette = 6 ) and ( CompteurTire > 20 )
    Then
      Begin
        CompteurTire := 0;
        CreeTir ( True );
     End ;
End;

procedure TItem.Destruction;
begin
Dead;
End;

procedure TItem.NextAnimation;
Begin
  if CanDoCollisions then
    Begin
      If ( AnimPos > 2 ) Then
        AnimPos := 2
       Else
        AnimPos := 3 ;
    End
   Else
     AnimPos := AnimPos - 1;
  if ( AnimPos = -1 )
   Then
    Dead;
End;

procedure TItem.DoMove(MoveCount: Double);
Begin
  Case BDGH of
   idBas    : begin
              Y:=Y+VitesseItem*MoveCount;
              if Y>EcranY then Destruction;
            End;
   idHaut   : begin
              Y:=Y-VitesseItem*MoveCount;
              if Y<-14 then Destruction;
            End;
   idDroite : begin
              X:=X+VitesseItem*MoveCount;
              if X>EcranX then Destruction;
            End;
   idGauche : begin
              X:=X-VitesseItem*MoveCount;
              if X<-30 then Destruction;
            End;
   End;
  NextAnimation ;
  inherited;
End;

constructor TItem.Create( const AParent: TSprite; const Joueur : PPlayerSprite ; const X, Y : Double ; const NoItem :  Integer );
Begin
  inherited Create(AParent);
  If Joueur = @Joueurs [ Droite ] Then BDGH := idDroite
  Else If Joueur = @Joueurs [ Gauche ] Then BDGH := idGauche
  Else If Joueur = @Joueurs [ Droite ] Then BDGH := idDroite
  Else If Joueur = @Joueurs [ Bas    ] Then BDGH := idBas ;
  Palette:=False;
  Z := ZItems;
  AnimActive := False;
  AnimSpeed:=Vitesse/1000;
  CanDoCollisions:=True;
  CanDoMoving:=True;
  AnimPos := 2;
  Visible:=True;
  Self.X := X ;
  Self.Y := Y ;
  SetImage  ( ImageList.Find ( ImageBrique +InTTosTr(NoItem)));
  AnimPos:=2;
  Self.X:=X;
  Self.Y:=Y;
  Self.NoItem:=NoItem;
  MainForm.Playsound('Casse',False);
End;
{
procedure TPlayerSprite.Coller;
begin
NoPalette:=4;
Mode:=Colle;
end;
 }
procedure TPlayerBas.SetBalleCollePosition(const UneBalle: TBalle);
begin
  UneBalle.X:=self.X+UneBalle.DecalePalette;
  UneBalle.Y:=self.Y-UneBalle.Width;
end;

procedure TPlayerBas.SetPalette;
begin
  SetPalette ( 'B' );

end;

procedure TPlayerBas.UnMouvement;
begin
  UnMouvementX;
  inherited;
end;

procedure TPlayerBas.BallesModif;
begin
  BallesModif ( bmFolleHautBas );
end;

procedure TPlayerBas.CreateAnimBouche ;
begin
  inherited CreateAnimBouche ( BoucheBas, 'BoucheBas' );
End;
procedure TPlayerBas.DoCollision(Sprite: TSprite; var Done: Boolean);
begin
  UneCollisionX(Sprite,Done);
  inherited DoCollision(Sprite, Done);
end;

procedure TPlayerBas.CreatePlayer;
var I       :Integer;
begin
  X := JoueurBasX;
  Y:= JoueurBasY;
  NoJoueur := Bas ;
End ;

destructor TPlayerBas.Destroy;
begin
  joueurs[Bas]:=nil;
  inherited Destroy;
end;


procedure TPlayerBas.CreeTir ( const Double : Boolean );
begin
  CreeTirHautBas ( Double , True );
end;

procedure TPlayerBas.BalleFolle(const Balle: TBalle);
begin
  BalleFolleHautBas(Balle);
  inherited;
end;

procedure TPlayerBas.SetBalleColle(const UneBalle: TBalle);
begin
  inherited SetBalleColle(UneBalle);
  UneBalle.DecalePalette:= trunc ( UneBalle.X - Self.x );
end;

procedure TPlayerBas.DoMove(MoveCount: Double);
begin
  AppuieGaucheDroite ( ToucheGauche [ NoJoueur ], ToucheDroite [ NoJoueur ] );
  inherited Domove ( MoveCount );
end;

procedure TPlayerHaut.DoMove(MoveCount: Double);
begin
  AppuieGaucheDroite  ( ToucheGauche [ NoJoueur ], ToucheDroite [ NoJoueur ] );
  inherited Domove ( MoveCount );
end;

//Crée le joueur
procedure TPlayerHaut.BallesModif;
begin
  BallesModif ( bmFolleHautBas );
end;

procedure TPlayerHaut.CreateAnimBouche;
begin
  inherited CreateAnimBouche (BoucheHaut, 'BoucheHaut' );
end;

procedure TPlayerHaut.CreatePlayer;
var I       :Integer;
begin
  X := JoueurHautX;
  Y:= JoueurHautY;
  NoJoueur := Haut ;
End ;

destructor TPlayerHaut.Destroy;
begin
  joueurs[Haut]:=nil;
  inherited Destroy;
end;

procedure TPlayerHaut.DoCollision(Sprite: TSprite; var Done: Boolean);
begin
  UneCollisionX(Sprite,Done);
  inherited DoCollision(Sprite, Done );
end;

procedure TPlayerHaut.SetBalleColle(const UneBalle: TBalle);
begin
  inherited SetBalleColle(UneBalle);
  UneBalle.DecalePalette:= trunc ( UneBalle.X - Self.x );
end;

procedure TPlayerHaut.BalleFolle(const Balle: TBalle);
begin
  BalleFolleHautBas(Balle);
  inherited;
end;

procedure TPlayerHaut.SetBalleCollePosition(const UneBalle: TBalle);
begin
  UneBalle.X:=self.X+UneBalle.DecalePalette;
  UneBalle.Y:=self.Y+self.Height;
end;

procedure TPlayerHaut.SetPalette;
begin
 SetPalette ( 'H' );
end;

procedure TPlayerHaut.UnMouvement;
begin
  UnMouvementX;
  inherited;
end;

procedure TPlayerHaut.CreeTir ( const Double : Boolean );
begin
  CreeTirHautBas ( Double, False );
end;

procedure TPlayerGauche.DoMove(MoveCount: Double);
begin
  AppuieHautBas     ( ToucheHaut [ Gauche ], ToucheBas [ Gauche ] );
  inherited Domove ( MoveCount );
end;

//Crée le joueur
procedure TPlayerGauche.BallesModif;
begin
  BallesModif ( bmFolleGaucheDroite );
end;

procedure TPlayerGauche.CreateAnimBouche;
begin
  inherited CreateAnimBouche(BoucheGauche, 'BoucheGauche');
end;

procedure TPlayerGauche.CreatePlayer;
var I       :Integer;
begin
  X := JoueurGaucheX;
  Y:= JoueurGaucheY;
  NoJoueur := Gauche ;
End ;

destructor TPlayerGauche.Destroy;
begin
  joueurs[Gauche]:=nil;
  inherited Destroy;
end;

procedure TPlayerGauche.DoCollision(Sprite: TSprite; var Done: Boolean);
begin
  UneCollisionY( Sprite, Done );
  Inherited DoCollision(Sprite, Done );
end;

procedure TPlayerGauche.SetBalleColle(const UneBalle: TBalle);
begin
  inherited SetBalleColle(UneBalle);
  UneBalle.DecalePalette:= trunc ( UneBalle.Y - Self.Y );
end;

procedure TPlayerGauche.BalleFolle(const Balle: TBalle);
begin
  BalleFolleGaucheDroite(Balle);
  inherited;
end;

procedure TPlayerGauche.SetBalleCollePosition(const UneBalle: TBalle);
begin
  UneBalle.X:=self.X+Self.Width;
  UneBalle.Y:=self.Y+UneBalle.DecalePalette;
end;

procedure TPlayerGauche.SetPalette;
begin
  SetPalette ( 'G' );
end;

procedure TPlayerGauche.UnMouvement;
begin
  UnMouvementY;
  inherited;
end;

procedure TPlayerGauche.CreeTir ( const Double : Boolean );
begin
  CreeTirGaucheDroite ( Double, False );
end;


procedure TPlayerDroite.SetBalleCollePosition(const UneBalle: TBalle);
begin
  UneBalle.X:=self.X-UneBalle.width;
  UneBalle.Y:=self.Y+UneBalle.DecalePalette;
end;

procedure TPlayerDroite.SetPalette;
begin
  SetPalette ( 'D' );
end;

procedure TPlayerDroite.UnMouvement;
begin
  UnMouvementY;
  inherited;
end;

procedure TPlayerDroite.BalleFolle(const Balle: TBalle);
begin
  BalleFolleGaucheDroite(Balle);
  inherited;
end;

//Crée le tir
procedure TPlayerDroite.CreeTir ( const Double : Boolean );
begin
  CreeTirGaucheDroite ( Double, True );
end;

procedure TPlayerDroite.BallesModif;
begin
  BallesModif ( bmFolleGaucheDroite );

end;

procedure TPlayerDroite.CreateAnimBouche;
begin
  inherited CreateAnimBouche ( BoucheDroite, 'BoucheDroite');
end;

Procedure TPlayerDroite.CreatePlayer ;
var I       :Integer;
begin
  X := JoueurDroiteX;
  Y:= JoueurDroiteY;
  NoJoueur := Droite ;
End ;

procedure TPlayerDroite.DoCollision(Sprite: TSprite; var Done: Boolean);
begin
  UneCollisionY( Sprite, Done );
  Inherited DoCollision(Sprite, Done );
end;

destructor TPlayerDroite.Destroy;
begin
  joueurs[Droite]:=nil;
  inherited Destroy;
end;

procedure TPlayerDroite.SetBalleColle(const UneBalle: TBalle);
begin
  inherited SetBalleColle(UneBalle);
  UneBalle.DecalePalette:= trunc ( UneBalle.Y - Self.Y );
end;

procedure TPlayerDroite.DoMove(MoveCount: Double);
begin
  AppuieHautBas     ( ToucheHaut [ Droite ], ToucheBas [ Droite ] );
  inherited DoMove(MoveCount);
end;

procedure TBrique.Destruction;
var i : Integer;
begin
  case NoBrique [ 0] of
   1..18, 27..28 :
     begin

       TItem.Create(SpriteEngine, Joueur, X, Y, NoBrique[0] )
     end;
   end;
  dec(NbBriques);
  for i := 0 to high ( NoBrique ) - 1 Do
    Begin
      NoBrique[i]:=NoBrique [ I + 1 ];
    End ;
  NoBrique[high ( NoBrique )]:= 0 ;
  if NoBrique[0]=0 then
   begin
     inc(Score,PCasse*NbPalettes);
     Dead;
   end
    else
     Begin
       SetImage( ImageList.Find (  ImageBrique +IntToStr(NoBrique[0])));
       Mode:=mbAucun;
       AnimPos:=0;
       AnimActive:=False;
       CanDoCollisions:=True;
     End;
   if NbBriques=0 then MainForm.Suivant:=True;
end;

procedure TBrique.Touche;
begin
  if NoBrique [ 0 ] = BIndestructible Then
    Mode:=mbCassePas
   Else
    Begin
      Mode:=mbMeurt;
      CanDoCollisions:=False;
     End;
end;

procedure TBrique.DoMove(MoveCount: Double);
begin
  case Mode of
    mbMeurt :
     begin
       AnimPos := AnimPos + 1;
       if AnimPos=AnimCount then Destruction;
     end ;
    mbCassePas :
     begin
       AnimPos := AnimPos + 1;
       if AnimPos=AnimCount then
        begin
          AnimPos:=0;
          Mode:=mbAucun;
        End;
     end;
    End;
    inherited;
end;

procedure TBrique.CollisionBalle(const Balle: TBalle);
begin
  CollisionBalle ( Balle, NoBrique[0]<>BIndestructible );
  Joueur :=Balle.Joueur;
  Touche ;
  if ( Mode = mbMeurt ) then Balle.Accelere:=0;
end;

procedure TBrique.InitBrique(const i, j: Integer ; var Cases : TCases );
var k : Integer ;
begin
  X:=BriquesX+I*32;
  Y:=BriquesY+J*16;
  For K:=0 to FinCouche do
   if (Cases[I,J,K]>0) and (Cases[I,J,K]<=FinBriques) then
    begin
      NoBrique[K]:=0;
      if ( Cases[I,J,k]<=FinBriques ) then
        NoBrique[K]:=Cases[I,J,K];
      if (Cases[I,J,K]=BIndestructible) then break ;
      inc(NbBriques);
    End
     Else
       Break;
end;

//Crée une brique
constructor TBrique.Create ( const AParent: TSprite; const i,j :integer ; var Cases : TCases );
var Indice : Integer ;
begin
  inherited Create(AParent);
  Indice := Cases [ i, j, 0 ];
  Joueur:=Nil;
//  BDGH:=Bas;
  Mode:=mbAucun;
  SetImage( ImageList.Find (  ImageBrique +IntToStr(Indice)));
  NoBrique[0]:=Indice;
  case Indice of
   0  : begin
        Visible:=True;
        end;
   1  : begin
        Visible:=True;
        end;
   11 : begin
        Visible:=True;
        end;
   end;
  Width := Image.Width;
  Height := Image.Height;
  Z := ZBriques;
  CanDoCollisions:=True;
//  AnimCount := Image.PatternCount;
  AnimActive := False;
  AnimLoop := False;
  InitBrique(i,j,Cases);
  AnimSpeed := Vitesse/1000;
end;

procedure Tballe.SetImageGrosseur;
begin
  SetImage (  ImageList.Find ( ImageBalle + IntToStr ( Grosseur )));
  Width  := Image.Width;
  Height := Image.Height;
  SetImagePosition;
End ;

procedure Tballe.SetImagePosition;
begin
  if (bmPlomb in Activite) Then
    AnimPos := 1
   Else
    AnimPos := 0 ;
End ;

procedure Tballe.BalleModif(const Player:PPlayerSprite);
begin

case Player^.BalleModif of
 bmNormal :
   begin
     Activite := [];
     SetImagePosition;
   end;
 bmPlomb :
   Begin
     Activite := Activite + [bmPlomb];
     SetImagePosition;
   end;
 bmFolle :
   Begin
     Activite := Activite + [bmFolle];
   end;
 bmColle :
   Begin
     Activite := Activite + [bmColle];
   end;
 bmFolleHautBas :
   Begin
     Activite := Activite + [bmFolleHautBas];
   end;
 bmFolleGaucheDroite :
   Begin
     Activite := Activite + [bmFolleGaucheDroite];
   end;
 bmPlusGrosse :
   Begin
    inc ( Grosseur );
    If Grosseur > 3 Then
      Grosseur := 3
     Else
      SetImageGrosseur;
   end;
 bmMoinsGrosse :
   Begin
    dec ( Grosseur );
    If Grosseur < 1 Then
      Grosseur := 1
     Else
      SetImageGrosseur;
   end;
 End;

End;

procedure Tballe.ChangeVitesse;
Begin
  if not ( bmColle in Activite ) Then BougeX:=trunc(Vitesse*(BougeX/BougeX));
  if not ( bmColle in Activite ) Then BougeY:=trunc(Vitesse*(BougeY/BougeY));
End;

procedure Tballe.LimitesX;
Begin
  if (BougeX>=VitesseMax) then BougeX:=VitesseMax;
  if (BougeX<=-VitesseMax) then BougeX:=-VitesseMax;
End;

procedure Tballe.LimitesY;
Begin
  if (BougeY>=VitesseMax) then BougeY:=VitesseMax;
  if (BougeY<=-VitesseMax) then BougeY:=-VitesseMax;
End;

procedure TBalle.Destruction;
Begin
  dec(NBBalles);
  //MainForm.Donnee:=intToStr(NBBalles);
  if NBBalles<=0 then MainForm.Perdu:=True;
  AnimPos:=0;
  Activite:=[];
  Visible:=False;
  CanDoMoving:=False;
  CanDoCollisions:=False;
End;

procedure TBalle.CollisionBalle(const Balle: TBalle);
var Dirige : Integer ;
begin
 if  not ( bmColle in Activite )
 and not ( bmBalleDessus in Activite ) then
  begin
    Activite := Activite + [bmBalleDessus];
    Randomize;
    Dirige:=Random(2);
    if Dirige<>0 then BougeX:=-Balle.BougeX*Dirige;
    if Dirige<>0 then BougeY:=-Balle.BougeY*Dirige;
  // if BougeX<0 then BougeX:=BougeX-Dirige;
  // if BougeY<0 then BougeY:=BougeY-Dirige;
    LimitesX;
    LimitesY;
  end;

end;


// gestion des collisions
procedure TBalle.DoCollision(Sprite: TSprite; var Done: Boolean);
begin
  if (Sprite is TBrique)
  and TestCollisionCercleRectangle ( Self, Sprite ) then // si la balle rencontre une brique
    begin
       (Sprite as TBrique ).CollisionBalle ( Self );
   end
  else if (Sprite is TBalle)
  and TestCollisionCercleCercle ( Self, Sprite ) then
   begin
     CollisionBalle ( Sprite as TBalle );
   end
  else if (Sprite is TPresente)
  and TestCollisionCercleRectangle ( Self, Sprite ) then // si la balle rencontre les murs
   begin
     (Sprite as TPresente ).CollisionBalle ( Self, False );
   end
    else
     Activite := Activite - [bmBalleDessus];
end;

procedure TBalle.ColleBalle(const Player: PPlayerSprite);
begin
  if ( Player^.BalleModif = bmColle ) Then
    Begin
      CanDoCollisions:=False;
      Activite := Activite + [bmColle];
      BougeX := 0;
      BougeY := 0;
      Joueur := Player;
    End;
end;

Function TBalle.PerdJoueur ( const Perdu : Boolean; const NoJoueur : Integer ):boolean;
Begin
  Result:=False;
  if ( not assigned ( Joueurs[Gauche] ) or not Joueurs[Gauche].Visible ) then Result:=True
  else
   if Perdu then
    begin
     Destruction;
     Result:=True;
     Joueurs[NoJoueur].DetruitJoueur;
    End;
End;

procedure TBalle.DoMove(MoveCount: Double);
begin
  ViesPlus;
  if  ( BougeX = 0 )
  and ( BougeY = 0 )
  and not ( bmColle in Activite )
    Then
     Begin
       if X > EcranX / 2 Then
          BougeX := - Lente
         Else
          BougeX := Lente ;
       if Y > EcranY / 2 Then
          BougeY := - Lente
         Else
          BougeY := Lente ;
     End ;

  inc(Accelere);
  // Pas de vérfication de collision avec les sprites du décor
  // On vérifie directement les positions dans les limites des bords du décor
{  if ( X < LimiteX ) and ( Y < LimiteY ) Then
   ChangeUneDirection ( X-LimiteX - Y + LimiteY );
  if ( X < LimiteX ) and ( Y + Height > EcranY - LimiteY ) then
   ChangeUneDirection ( X-LimiteX + Y - EcranY - Height + LimiteY );
  if ( X + Width > EcranX - LimiteX ) and ( Y < LimiteY ) then
   ChangeUneDirection ( - X + Width + EcranX - LimiteX - Y + LimiteY );
  if ( X + Width > EcranX - LimiteX ) and ( Y + Height > EcranY - LimiteY ) then
   ChangeUneDirection ( - X + EcranX - LimiteX + Y - EcranY - LimiteY );}
  if Accelere>TempsAccelere then
   begin
     if ( bmRalenti in Activite )
       Then Activite := Activite + [bmAccelere] - [bmRalenti]
       Else Activite := Activite - [bmAccelere] + [bmRalenti];
     Accelere:=0;
     if ( bmRalenti in Activite ) and (Vitesse>1) then dec(Vitesse)
      Else if (Vitesse<VitesseMax) then inc(Vitesse);
     ChangeVitesse;
   End;
  if (assigned ( Joueur )) Then
    Begin
      BalleModif ( Joueur );
      Vitesse := Joueur^.VitesseBalles;
      if ( bmFolle in Activite ) then // La balle folle peut être maitrisée par le joueur
         begin
           Joueur^.BalleFolle(Self);
         End
        else if bmColle in Activite Then
          Begin
            if ( pmEnvoiBalle in Joueur^.PlayerModifs )
               Then Envoi
               Else Joueur^.SetBalleCollePosition ( Self );
          End ;
      End ;
  PerdJoueur (X>EcranX, Bas);
  PerdJoueur (Y>EcranY, Droite);
  PerdJoueur (X+Width <0, Gauche);
  PerdJoueur (Y+Height<0, Haut);
  if Change>=TempsChange then // au bout d'un moment la balle change de direction
   if ( bmColle in Activite ) Then
      Envoi
     Else
       begin
         Change:=0;
         Randomize;
         Activite:=Activite-[bmColle];
         if (Abs(BougeX)>=VitesseMax) then BougeX:=Lente * ( Random ( 2 ) + 2 );
         Randomize;
         if (Abs(BougeY)>=VitesseMax) then BougeY:=Lente * ( Random ( 2 ) + 2 );
       End;
  X:=X+BougeX*MoveCount;    // Déplacement de la itMouse
  Y:=Y+BougeY*MoveCount;
  Inc(Change);  // Compteur qui sert à contrôler la direction de la balle
   // Collisions ensuite
  inherited DoMove(MoveCount);
  Collision;
end;

// Change la direction de la balle
// En entrée la soustractions des Y aux X
procedure TBalle.ChangeUneDirection(const Decalage: Double);
begin
  If ( Decalage < 0 ) Then
    BougeY:=-BougeY
   Else
    BougeX:=-BougeX ;
end;

procedure TBalle.Envoi;
begin
 if (Joueur=@Joueurs[Gauche])
 or (Joueur=@Joueurs[Bas   ]) then
   BougeY:=-lente;
 if (Joueur=@Joueurs[Haut  ])
 or (Joueur=@Joueurs[Droite]) then
    BougeY:=lente;
 if (Joueur=@Joueurs[Haut  ])
 or (Joueur=@Joueurs[Gauche]) then
   BougeX:=lente;
 if (Joueur=@Joueurs[Bas   ])
 or (Joueur=@Joueurs[Droite]) then
   BougeX:=-lente;
 Activite:=Activite-[bmColle];
 //CanDoCollisions:=True;
end;

//Crée une brique
constructor TBalle.Create ( const AParent: TSprite; const Joueur : PPlayerSprite ; Const X, Y : Double );
begin
  inherited Create(AParent);
  Self.Joueur := Joueur ;
  Mode:=0;
  Activite := [bmColle] ;
  Grosseur := 1 ;
  Z := ZBalles;
  Vitesse:=Lente;
  DecalePalette := 0 ;
  BougeX := 0 ;
  BougeY := 0 ;
  Accelere:=0;
  SetImageGrosseur;
  SetImagePosition;
  AnimActive := False;
  Visible:=False;
  Self.NoBalle:=NbBalles;
  Show;
  CanDoCollisions:=False;
  Self.X := X ;
  Self.Y := Y ;
  Joueur^.SetBalleColle ( Self );
end;

procedure TBalle.Show;
begin
  If not Visible Then
    Begin
      Visible := True ;
      inc ( NbBalles );
    End;

end;

procedure TTire.DoCollision  ( Sprite: TSprite ; var Done: Boolean );
Begin
  if (Sprite is TBrique) and Not AnimActive
  and TestCollisionCercleRectangle(Self,Sprite) then // si le tire rencontre une brique
    begin
     AnimSpeed := Vitesse/1000;
     Touche := True ;
     if Assigned(joueur) then
      begin
      TBrique(Sprite).Joueur := Joueur;
      End;
     TBrique(Sprite).Touche;
     CanDoCollisions:=False;
    End ;
End ;

constructor TTire.Create  ( const AParent: TSprite ; const UnJoueur : PPlayerSprite );
Begin
  inherited Create(AParent);
  Joueur:=Joueur;
  SetImage  ( ImageListTirs.Find ( ImageTir ));
  Width := Image.Width;
  Height := Image.Height;
  Touche := False ;
  AnimPos := 0;
  Visible:=True;
  Z:=ZTires;
  CanDoCollisions:=True;
  CanDoMoving:=True;
  AnimActive := False;
End ;

procedure TTire.DoMove(MoveCount: Double);
begin
  if Touche Then
     AnimPos := AnimPos + 1;
  If AnimPos = AnimCount
   Then
    Dead ;
  if ( X > EcranX ) or ( Y > EcranY ) or ( X < -Width ) or ( Y < -Height )
    Then
     Dead ;
  If Joueur=@Joueurs[Bas   ] Then Y := Y - VitesseTir * MoveCount;
  If Joueur=@Joueurs[Haut  ] Then Y := Y + VitesseTir * MoveCount;
  If Joueur=@Joueurs[Gauche] Then X := X + VitesseTir * MoveCount;
  If Joueur=@Joueurs[Droite] Then X := X - VitesseTir * MoveCount;
  inherited; // heritage obligatoire
  Collision;
end;

{  TTamaSprite  }

//Joue un son et se détruit
procedure TTamaSprite.Destruction;
begin
//MainForm.PlaySound('Explosion',False); // Joue le son
dead;
end;

// Gestion des collisions
procedure TTamaSprite.DoCollision(Sprite: TSprite; var Done: Boolean);
begin
  if ( Sprite is TBrique) then
    begin
      Mode:=2;
      Compteur:=0;
    //  SetImage('Explosion2');
      Width := Image.Width;
      Height := Image.Height;
      AnimActive := True;
    end;
  Done := False;
end;

procedure TTamaSprite.DoMove(MoveCount: Double);
begin
  inherited DoMove(MoveCount);
  Collision;
end;

{
procedure TMainForm.EnvoiMessage;
var
  Msg: ^TDXChatMessage;
  MsgSize: Integer;
begin
  MsgSize := SizeOf(TDXChatMessage)+Length(Messages);
  GetMem(Msg, MsgSize);
  try
    Msg.dwType := DXCHAT_MESSAGE;
    Msg.Len := Length(Messages);
    StrLCopy(Msg.c, PChar(Messages), Length(Messages));

    //  The message is sent all.
    DXPlay1.SendMessage(DPID_ALLPLAYERS, Msg, MsgSize);

    //  The message is sent also to me.
    DXPlay1.SendMessage(DXPlay1.LocalPlayer.ID, Msg, MsgSize);

    Messages := '';
  finally
    FreeMem(Msg);
  end;
end;
 }
procedure TMainForm.FormMouseDown(Sender : TObject; Button : TAdMouseButton; Shift : TAdShiftState; X,Y : Integer);
Begin
  MouseButtonRight := FMouseButtonRight or ( abRight = Button );
  MouseButtonLeft  := FMouseButtonLeft  or ( abLeft  = Button );
End;

procedure TMainForm.FormMouseMove(Sender:TObject; Shift:TAdShiftState; X, Y:integer);
Begin
  MouseX := X ;
  MouseY := Y ;
End;

procedure TMainForm.AMouseDown(Sender : TObject; Button : TMouseButton; Shift : TShiftState; X,Y : Integer);
Begin
  MouseButtonRight := FMouseButtonRight or ( mbRight = Button );
  MouseButtonLeft  := FMouseButtonLeft  or ( mbLeft  = Button );
End;

procedure TMainForm.AMouseMove(Sender:TObject; Shift:TShiftState; X, Y:integer);
Begin
  MouseX := X ;
  MouseY := Y ;
End;


// Appuie sur une touche
procedure TMainForm.FormKeyDown(Sender: TObject; Key: Word;
  Shift: TAdShiftState);
begin
  p_KeyDown( Sender, Key, asAlt in Shift );
End ;

procedure TMainForm.PanelEnter(Sender: TObject);
begin
  //SetCursor ( crNone );
end;

procedure TMainForm.PanelExit(Sender: TObject);
begin
  SetCursor ( crDefault );
end;

function TMainForm.GetMouseButtonLeft: Boolean;
begin
  Result := FMouseButtonLeft ;
  FeraseButtonLeft := True ;
end;

function TMainForm.GetMouseButtonRight: Boolean;
begin
  Result := FMouseButtonRight ;
  FEraseButtonRight := True ;
end;

procedure TMainForm.p_KeyDown( const Sender: TObject; const Key: Word ; const Alt : Boolean );
Begin
  inc ( KeyboardState, Key );
  if (Alt) and (Key=VK_RETURN) then
  begin
    //OptionFullScreenClick(OptionFullScreen)
  end;
  if ((Key=VK_ESCAPE) and ((Fenetre=FJeu) or (Fenetre=FPresentation)))
  or ((Key=20) and (Fenetre=FPresentation)) then
  begin
  EndSceneMain;
  Fenetre:=FMenu;
  StartSceneMain;
  end
  else
  if (Key=VK_ESCAPE) then
  begin
  Mainform.close;
  end;
if (Key=VK_RETURN) then
 begin
 if Envoi then EnvoiMessage;
 Envoi:=not Envoi;
 end;
end;

// Pause
procedure TMainForm.GamePauseClick(Sender: TObject);
begin
  {  Pause  }
  GamePause.Checked := not GamePause.Checked;
  AdPause   := not GamePause.Checked;
end;

// Création de la fenêtre
procedure TMainForm.FormShow(Sender: TObject);
begin
  //  RegisteredWindowFrameworks.Add ( TAdWindowFramework.Create );
  FondImage := nil ;
  FIniFile  := nil;
  Addraw := TAdDraw.Create ( Self );
  {$IFDEF FPC}
    {$IFDEF WIN32}
     AdDraw.DllName := 'AndorraDX93D.dll';
    {$ELSE}
     AdDraw.DllName := 'libAndorraOGLLaz.so';
    {$ENDIF}
  Application.OnIdle := OnIdle;

  if not AdDraw.Initialize Then
    Begin
  {$ELSE}
    AdDraw.DllName := 'AndorraDX93D.dll';
  if AdDraw.Initialize then
    begin
      Application.OnIdle := OnIdle;
    end
   else
     begin

  {$ENDIF}
      ShowMessage(CST_MessageErrorInit);

       halt; //<-- Completely shuts down the application
     end;


end;

// Quitte
procedure TMainForm.GameExitClick(Sender: TObject);
begin
  Close;
end;


{
// Mode plein écran activé désactivé
procedure TMainForm.OptionFullScreenClick(Sender: TObject);
begin
  //  Screen mode change
  OptionFullScreen.Checked := not OptionFullScreen.Checked;

  if OptionFullScreen.Checked then
  begin
    //  FullScreen mode
    AdDraw.Finalize;

    if not (doFullScreen in AdDraw.Options) then
      StoreWindow;

    AdDraw.Options := AdDraw.Options + [doFullScreen];
    AdDraw.Display.Width := EcranX;
    AdDraw.Display.Height := EcranY;
    AdDraw.Display.BitCount := BitCompte;
    AdDraw.Initialize;
  end else
  begin
    //  Window mode
    AdDraw.Finalize;

    if doFullScreen in AdDraw.Options then
      RestoreWindow;

    AdDraw.Options := AdDraw.Options - [doFullScreen];
    AdDraw.Display.Width := EcranX;
    AdDraw.Display.Height := EcranY;
    AdDraw.Display.BitCount :=  BitCompte;
    AdDraw.Initialize;
  end;
end;
}
// Dés/activation du son
 {
procedure TMainForm.OptionSoundClick(Sender: TObject);
begin
  //  Sound
  OptionSound.Checked := not OptionSound.Checked;

  if OptionSound.Checked then
  begin
    if not DXSound.Initialized then
    begin
      try
        DXSound.Initialize;
      except
        OptionSound.Checked := False;
      end;
    end;
  end else
    DXSound.Finalize;
end;
}
// Option Images par secondes
procedure TMainForm.OptionShowFPSClick(Sender: TObject);
begin
  OptionShowFPS.Checked := not OptionShowFPS.Checked;
end;

// Rafraichissement d'écran
procedure TMainForm.OnIdle(Sender: TObject; var Done: Boolean);
Begin
  if not assigned (FondImage) Then
    Begin
      Application.ProcessMessages;
      //Create the performance counter. This class is used for measuring the time
      //that passes between two frames.
      AdPerCounter := TAdPerformanceCounter.Create;

      FondImage := TAdImageList.Create(AdDraw);
//      Fond := TAdTexture.Create(AdDraw);
//      FondImage.Texture := Fond ;


      SpriteEngine := TSpriteEngine.Create ( AdDraw );
      ImageList := TAdImageList.Create ( AdDraw );
      ImageListTirs := TAdImageList.Create ( AdDraw );
      AdDraw.Window.Events.OnKeyPress  := FormKeyPress ;
      AdDraw.Window.Events.OnMouseDown := FormMouseDown ;
      AdDraw.Window.Events.OnMouseMove := FormMouseMove ;
      AdDraw.Window.Events.OnKeyDown   := FormKeyDown ;
      Son:='';

      {  Window mode  }
      OptionFullScreen.Checked := True;
      //OptionFullScreenClick(OptionFullScreen);

      {  Sound on  }
      OptionSound.Checked := False;
      //OptionSoundClick(OptionSound);

      Fenetre:=FPresentation;
    //  Fenetre:=FMenu;
      StartSceneMain;
{
    if (Uppercase(ParamStr (1)) = 'DIRECTPLAY')  then
      try
        Reseau := True ;
        DXPlay1.Open;
      except
        on E: Exception do
        begin
          Application.ShowMainForm := False;
          Application.HandleException(E);
          Application.Terminate;
        end;
      end;}
      // We will continue here, soon..
    End;
  if AdDraw.CanDraw and not Stop then
  begin
    //Calculate the time difference.
    AdPerCounter.Calculate;

    KeyBoardState := 0 ;
    Application.ProcessMessages;
    AdDraw.BeginScene;

    AdDraw.ClearSurface(clBlack);

    //My code here
    SceneFlipping;

    AdDraw.EndScene;

    AdDraw.Flip;
    if FEraseButtonLeft Then
      FMouseButtonLeft := False;
    if FEraseButtonright Then
      FMouseButtonRight := False;
  end;
  Done := false;
End ;

procedure TMainForm.PlaySound(const Name: string; Wait: Boolean);
begin

end;

// Rafraichissement d'écran
procedure TMainForm.SceneFlipping;

//var Rect : TAdRect ;
var i :integer;
begin
  if Suivant then
    begin
      Score:=Score;
      Stop := True ;
//      DXTimer.Enabled:=False;
      EndSceneMain;
      StartSceneMain;
      Stop := False ;
//      DXTimer.Enabled:=True;
    end;
  if Perdu then
    begin
      dec(Vies);
      Perdu:=False;
      if Vies>0 then
       begin
         NbBalles:=0;
         for i := low ( Joueurs ) to high ( Joueurs ) do
           if not ( [pmErased,pmEnlever,pmAfficher] * Joueurs[i].PlayerModifs <> [] ) then
            begin
              Joueurs[i].Erase;
              Joueurs[i].Cree;
              Joueurs[i].BallePlus;
            End;
       End;
      if Vies<=0 then
         begin
           MainForm.Playsound('Perdu',False);
           Score:=0;
           Fenetre:=FPresentation;
           EndSceneMain;
           StartSceneMain;
    //       Joue;
         end;
    End;
  if not AdDraw.CanDraw then exit;
  SceneMain;
//  SpriteEngine.Draw;

  if OptionShowFPS.Checked then
  begin
    //  Frame rate display
    with AdDraw.Canvas do
    begin
      Brush.Style := abClear;
  //    Font.Color.r := 0;
  //    Font.Color.g := 0;
   //   Font.Color.b := 0;
   //   Font.Color.a := 0;
      Textout(0, 0, 'FPS: '+IntToStr ( AdPerCounter.FPS ));
      Release;
    end;
  end;

{  If Fenetre = FJeu
    Then
     Application.Terminate ;}
end;

// Directsound joue un son
 {
procedure TMainForm.PlaySound(const Name: string; Wait: Boolean);
begin
  if OptionSound.Checked then
  begin
    DXWaveList.Items.Find(Name).play(Wait);
  end;
end;
      }

// Démarrage du jeu      ---------------------------------
procedure TMainForm.CreeIni;
begin
  if (FIniFile = NIL) then
   begin
     FIniFile := TMemIniFile.create ( ExtractFilePath ( Application.exeName ) +  ExtractFileName ( Application.exeName ) + '.INI' );
   End ;
End ;

procedure TMainForm.EcritIni(Rep,Nom,Install:string);
begin
  CreeIni;
  if (FIniFile <> NIL) then
   begin
        FIniFile.WriteString(Rep, Nom,Install);
   end;
End;

procedure TMainForm.LitIni(var Installed:string;Rep,Nom : String);

begin
  CreeIni;
  if (FIniFile <> NIL) then
   begin
     Installed := FIniFile.ReadString(Rep, Nom, '');
   end;
end;

procedure TMainForm.SceneMenu;
Var Compte :integer;

  procedure SauveControles;

  var lit_Compteur     : TInputType;
      li_Compteur     : Integer ;
      ValideControle : Array[TInputType] of Boolean;
  begin
    for lit_Compteur:=low ( TInputType ) to high ( TInputType ) do
     ValideControle[lit_Compteur]:=False;
    for li_Compteur := low ( ControleJoueur ) to high ( ControleJoueur ) do
     if ControleJoueur[li_Compteur]<>itInactive then
       begin
         ValideControle[ControleJoueur[li_Compteur]]:=True;
       End;
    NbJoueurs:=0;
    for lit_Compteur:=low ( TInputType ) to high ( TInputType ) do
     if ValideControle[lit_Compteur] then inc(NbJoueurs);
    if NbJoueurs=0 then
      Begin
         for li_Compteur:=low ( ControleJoueur ) to high ( ControleJoueur ) do
           begin
             ControleJoueur[li_Compteur]:=itMouse;
           End;
         NbJoueurs:=1;
       End;
  End;
  procedure SetControle;
  var i :integer;
      controle : String ;
  Begin
    ChargeControles;
    for i := low ( ControleJoueur ) to high ( ControleJoueur ) do
      Begin
        Items[i-1].LeSprite.ChangeControle(ControleJoueur[i]);
      End;
  End;

  procedure MenuControle;
  const NbItems = 5;
  var i, ItemHeight, ItemWidth :integer;
      controle : String ;

  begin
    ItemHeight := ImageList.Find ( ImageControle ).Height;
    ItemWidth  := ImageList.Find ( ImageControle ).Width;
    I:=0 ;
    Items[I].Lesprite:=TItemMenu.Create(SpriteEngine, ImageSouris, EcranX / 2, EcranY / 2- (NbItems / 2) * ItemHeight, I );
    Items[I].LAction:=AChangeBas;
    inc(I);
    Items[I].Lesprite:=TItemMenu.Create(SpriteEngine, ImageSouris, EcranX / 2, EcranY / 2- (NbItems / 2) * ItemHeight, I );
    Items[I].LAction:=AChangeHaut;
    inc(I);
    Items[I].Lesprite:=TItemMenu.Create(SpriteEngine, ImageSouris, EcranX / 2, EcranY / 2- (NbItems / 2) * ItemHeight, I );
    Items[I].LAction:=AChangeGauche;
    inc(I);
    Items[I].Lesprite:=TItemMenu.Create(SpriteEngine, ImageSouris, EcranX / 2, EcranY / 2- (NbItems / 2) * ItemHeight, I);
    Items[I].LAction:=AChangeDroite;
    inc(I);
    Items[I].Lesprite:=TItemMenu.Create(SpriteEngine, ImageBas, EcranX / 2 - ItemWidth, EcranY / 2- (NbItems / 2) * ItemHeight, I - 4);
    Items[I].LAction:=ABas;
    inc(I);
    Items[I].Lesprite:=TItemMenu.Create(SpriteEngine, ImageHaut, EcranX / 2 - ItemWidth, EcranY / 2- (NbItems / 2) * ItemHeight, I - 4);
    Items[I].LAction:=AHaut;
    inc(I);
    Items[I].Lesprite:=TItemMenu.Create(SpriteEngine, ImageGauche, EcranX / 2 - ItemWidth, EcranY / 2- (NbItems / 2) * ItemHeight, I - 4);
    Items[I].LAction:=AGauche;
    inc(I);
    Items[I].Lesprite:=TItemMenu.Create(SpriteEngine, ImageDroite, EcranX / 2 - ItemWidth, EcranY / 2- (NbItems / 2) * ItemHeight, I - 4);
    Items[I].LAction:=ADroite;
    inc(I);
    Items[I].Lesprite:=TItemMenu.Create(SpriteEngine, ImageJouer, EcranX div 2 - ItemWidth / 2, EcranY div 2- (NbItems div 2) * ItemHeight,I-4);
    Items[I].LAction:=ARetourControle;
    SetControle;
   Curseur:=TCurseur.Create(SpriteEngine, 'curseur' );
  End;

  procedure EcritIniPlayers ;
  var li_Compteur : Integer ;
  Begin
    SauveControles;
    EcritIni(IniGame,IniPlayers,IntToStr(NbJoueurs));
  End;

  procedure EcritIniControle ;
  var li_Compteur : Integer ;
  Begin
    EcritIniPlayers ;
    for li_Compteur:= low ( ControleJoueur ) to high ( ControleJoueur ) do
      EcritIni(IntToStr(NbJoueurs) + IniPlayer,IniAPlayer+IntToStr(li_Compteur),
               GetEnumName(TypeInfo(TInputType), integer ( ControleJoueur[li_Compteur])));
  End;

  procedure ChangeControle ( Controle : TInputType; const Item : TItemMenu ; var Action_Sprite : TActions; const i : Integer );
  Begin
    Action_Sprite:=AAttente;
    inc(Controle);
    if Controle>high(TinputType) then Controle:=itInactive;
    Item.ChangeControle(Controle);
    ControleJoueur [ i ] := Controle ;
  End;

  procedure MenuOptions;
  const NbItems = 3;
  var i, ItemHeight, ItemWidth :integer;

  begin
    ItemHeight := ImageList.Find ( ImageControle ).Height;
    ItemWidth  := ImageList.Find ( ImageControle ).Width;
    I:=0 ;
    ItemHeight := ImageList.Find ( ImageControle ).Height;
    with Items[I] do
     begin
       Lesprite:=TItemMenu.Create(SpriteEngine, ImageControle, EcranX div 2 - ItemWidth / 2, EcranY div 2- (NbItems div 2) * ItemHeight, I );
       LAction:=AControles;
     End;
    inc(I);
    with Items[I] do
     begin
       Lesprite:=TItemMenu.Create(SpriteEngine, ImageSon, EcranX div 2 - ItemWidth / 2, EcranY div 2- (NbItems div 2) * ItemHeight, I );
       LAction:=ASon;
     End;
    inc(I);
    with Items[I] do
     begin
       Lesprite:=TItemMenu.Create(SpriteEngine, ImageJouer, EcranX div 2 - ItemWidth / 2, EcranY div 2- (NbItems div 2) * ItemHeight, I );
       LAction:=ARetour;
     End;
   Curseur:=TCurseur.Create(SpriteEngine, 'curseur' );
  end;

begin
  If Compteur > 0 Then dec ( Compteur )
    Else Compteur := 0 ;
//  DXinput.UpDate;
  SpriteEngine.Move(AdPerCounter.TimeGap / 1000);
  FondImage.Items [ 0 ].Draw (AdDraw,0,0 ,0);
//  AdDraw.Scene.Draw
  SpriteEngine.Draw;
//  AdDraw.Surface.Canvas.Release;
  //if (Mainform.DXInput.Mouse.Buttons[0]) then
  if Curseur.Pousse
  and ( Compteur = 0 )
    then Curseur.Pousse:=False;

  if  ( Compteur = 0 )
  and (( not Curseur.Pousse and   (MouseButtonLeft))
       or (ToucheBoutonA [ 1 ] and KeyboardState = ToucheBoutonA [ 1 ]))
   then
     begin
     Compteur := 8 ;
     Curseur.pousse:=True;
     For Compte:=0 to MaxItems - 1 do with Items[Compte] do
      begin
      if (LeSprite <>nil) and (Curseur.X>LeSprite.X) and (Curseur.Y>LeSprite.Y)
      and (Curseur.X<LeSprite.width+LeSprite.X) and (Curseur.Y<LeSprite.Height+LeSprite.Y) then
        Begin
          Action_Sprite:=LAction;
          Break;
        End ;
      end;
     End;
  case Action_Sprite of
   ARetourControle : begin
                       Action_Sprite:=ARetour;
                       EcritIniControle ;
                     End;
   AChangeBas:begin
                ChangeControle ( ControleJoueur [Bas], Items [Bas-1].LeSprite, Action_Sprite, Bas );
              end;
   AChangeHaut:begin
                ChangeControle ( ControleJoueur [Haut], Items [Haut-1].LeSprite, Action_Sprite, Haut );
              end;
   AChangeGauche:begin
                ChangeControle ( ControleJoueur [Gauche], Items [Gauche-1].LeSprite, Action_Sprite, Gauche );

              end;
   AChangeDroite:begin
                ChangeControle ( ControleJoueur [Droite], Items [Droite-1].LeSprite, Action_Sprite, Droite );

              end;
   AControles:begin
              Action_Sprite:=AAttente;
              EffaceMenu;
              MenuControle;
              SetControle;
              End;
   AOptions : begin
              Action_Sprite:=AAttente;
              EffaceMenu;
              MenuOptions;
              End;
   AJoueur : begin
             Action_Sprite:=AAttente;
             inc(NbJoueurs);
             if NbJoueurs> high ( ControleJoueur ) then NbJoueurs:=1;
             Items[1].LeSprite.Image:=ImageList.Find(IntToStr(NbJoueurs)+ImageJoueurs);
             EcritIniPlayers ;
             ChargeControles;
             end;
   ARetour : begin
             Action_Sprite:=AAttente;
             EffaceMenu;
             {
             with DXInput do
               begin
               Mouse.Enabled:=True;
               Joystick.Enabled:=False;
               Keyboard.Enabled:=False;
               End;
               }
             MenuPrincipal;
             end;
   AJouer : begin
           Action_Sprite:=AAttente;
           Joue;
           end;
   AQuitter : Mainform.close;
   end;
End;

procedure TMainForm.EnvoiMessage;
begin

end;

procedure TMainForm.EffaceMenu;
var I : Integer ;
begin
  SpriteEngine.Clear;

  for I:= low ( Items ) to high ( Items ) do
    begin
      Items[I].LeSprite:=Nil;
    End;
End;

procedure TMainForm.ChargeControles;
var I     :integer;
    lit_j     : TInputType ;
    Entree : string;
begin
  for I:=low ( ControleJoueur ) to high ( ControleJoueur ) do
   begin
     ControleJoueur[I]:=itMouse;
     LitIni(Entree,IntToStr(NbJoueurs)+IniPlayer, IniAPlayer + IntToStr(I));
     if Entree<>'' then
      try
        for lit_j := low ( TInputType ) to high ( TInputType ) do
          if GetEnumName(TypeInfo(TInputType), LongInt( lit_j )) = Entree Then
            ControleJoueur[I]:=lit_j ;
      except
      End;
   End;
End;

procedure TMainForm.StartSceneMenu ;

var NombreJoueurs : String ;
    i             : Integer ;

Begin
 InitClavier1 ( 1 );

 NombreJoueurs := '1' ;
 for i := low ( ControleJoueur ) to high ( ControleJoueur ) do
   ControleJoueur[i]:=itMouse;
 LitIni(NombreJoueurs,IniGame,IniPlayers);
 if NombreJoueurs<>'' then
  try
    NbJoueurs:=sTrToIntDef(NombreJoueurs,1);
  except
  End;
 if (NBJoueurs<1) or (NBJoueurs>4) then NBJoueurs:=1;
 ChargeControles;
 Compteur:=0;
 for I:=1 to MaxItems do Items[I].LeSprite:=Nil;
 If FileExists(ExtractFilePath(Application.Exename) +DirectoryData + DirectorySeparator + 'MENUS' + ImagesLibExtension) then
  Begin
//  Showmessage ( 'ok');
  FondImage.Items [ 0 ].Draw(AdDraw,0,0,0);
//  Showmessage ( 'ok');
//  ImageList.BeginUpdate ;
  If  FileExists (ExtractFilePath(Application.Exename) + DirectoryData + DirectorySeparator + ImageListMenus + ImagesLibExtension )
    then
      Begin
        ImageList.Clear;
        ImageList.LoadFromFile ( ExtractFilePath(Application.Exename) + DirectoryData + DirectorySeparator + ImageListMenus + ImagesLibExtension);
      End;
//  ImageList.EndUpdate ;
  End
   else Application.terminate;
 ImageList.Restore ;
 FondImage.Restore ;
 EffaceMenu;
//     EndSceneMain;
{     with DXInput do
      begin
      Mouse.Enabled:=True;
      Joystick.Enabled:=False;
      Keyboard.Enabled:=True;
      End;}
 MenuPrincipal;
 Stop := False ;

//     DXTimer.Enabled:=True;
//     End;
End ;

procedure TMainForm.MenuPrincipal;
const NbItems = 4;
var i, ItemHeight, ItemWidth :integer;

begin
  ItemHeight := ImageList.Find ( ImageControle ).Height;
  ItemWidth  := ImageList.Find ( ImageControle ).Width;
  I:=0 ;
  with Items[I] do
   begin
     Lesprite:=TItemMenu.Create(SpriteEngine, 'Options', EcranX div 2 - ItemWidth / 2, EcranY div 2- (NbItems div 2) * ItemHeight, I );
     LAction:=AOptions;
   End;
  inc(I);
  with Items[I] do
   begin
     Lesprite:=TItemMenu.Create(SpriteEngine, IntToStr(NbJoueurs)+ ImageJoueurs, EcranX div 2 - ItemWidth / 2, EcranY div 2- (NbItems div 2) * ItemHeight, I );
     LAction:=AJoueur;
   End;
  inc(I);
  with Items[I] do
   begin
     Lesprite:=TItemMenu.Create(SpriteEngine, ImageJouer, EcranX div 2 - ItemWidth / 2, EcranY div 2- (NbItems div 2) * ItemHeight, I );
     LAction:=AJouer;
   End;
  inc(I);
  with Items[I] do
   begin
     Lesprite:=TItemMenu.Create(SpriteEngine, 'Quitter', EcranX div 2 - ItemWidth / 2, EcranY div 2- (NbItems div 2) * ItemHeight, I );
     LAction:=AQuitter;
   End;
 Curseur:=TCurseur.Create(SpriteEngine, 'curseur' );
End;

procedure TMainForm.EndSceneMenu;
Begin
 SpriteEngine.Clear;
End;

procedure TMainForm.ScenePresentation;
Begin
//AdDraw.Surface.Canvas.Release;
 case Compteur of
  0 : begin
      FondImage.LoadFromFile(ExtractFilePath(Application.Exename) +DirectoryData + DirectorySeparator + 'MULTI1' + ImageExtension);
      End;
  1000  : begin
         FondImage.LoadFromFile(ExtractFilePath(Application.Exename) +DirectoryData + DirectorySeparator + 'MULTI2' + ImageExtension);
         End;
  end;
FondImage.Items [ 0 ].Draw(AdDraw,0,0,0);
// FondImage.
//DXInput.Update;
inc(compteur);
if ( MousebuttonLeft )
or ( ToucheBoutonA [ 1 ] and KeyBoardState = ToucheBoutonA [ 1 ] ) then
 Begin
 EndSceneMain;
 Fenetre:=FMenu;
 StartSceneMain;
 End;
End;

// Démarrage du niveau      ---------------------------------

procedure TMainForm.StartSceneMain;

var

//  NoSprite
  i, j            :Integer;
  TailleX,TailleY: Integer;
  Cases : TCases;

procedure Charge;
begin
  NbBriques:=0;
  if FileExists(ExtractFilePath(Application.Exename) +'NIVEAUX' + DirectorySeparator + 'N'+IntToStr(NoNiveau)+'.MUL') then
    ChargeFichier(ExtractFilePath(Application.Exename) +'NIVEAUX' + DirectorySeparator + 'N'+IntToStr(NoNiveau)+'.MUL', TailleX, TailleY, Cases)
     else MainForm.Close;
end;

begin
  FMouseButtonLeft:=False;
  KeyBoardState := 0;
  FMouseButtonRight:=False;
  Stop := True ;
  //DXTimer.Enabled:=False;
  //  showmessage ('5');
  //  showmessage ('4');
  if Fenetre=FJeu then
   begin
    {  Main scene beginning  }
    inc(NoNiveau);
    if NoNiveau>Fin then NoNiveau:=1;
    ChargeStage ( NoNiveau );
    NbBalles:=0;
    NbBriques :=0;
    NbPalettes:=0;
    Suivant:=False;
  //  ChargeFichier('NIVEAUX' + DirectorySeparator + 'NIVDEF.MUL');
    ChargeLUM(DirectoryNiveaux + DirectorySeparator + 'NIVEAUX.LUM',NoNiveau, TailleX,TailleY, Cases);
    TPresente.Create ( SpriteEngine, 0, 0 );
    TPresente.Create ( SpriteEngine, 0, 1 );
    TPresente.Create ( SpriteEngine, 1, 1 );
    TPresente.Create ( SpriteEngine, 1, 0 );
   //  Player object
    for I:=0 to MaxMurGD-1 do
     begin
     BoucheGauche[I]:=nil;
     BoucheDroite[I]:=nil;
     End;
    for I:=0 to MaxMurBH-1 do
     begin
     BoucheBas[I]:=nil;
     BoucheHaut[I]:=nil;
     End;
    For i:=0 to high ( LettresScore ) do
      Begin
        LettresScore [ i ] := TLettre.Create ( SpriteEngine, ' ', 2 + i * 9, 10 );
      End;
    For i:=0 to high ( LettresPVie ) do
      Begin
        LettresPVie [ i ] := TLettre.Create ( SpriteEngine, ' ', EcranX-LimiteX+60 + i * 9, EcranY - 30 );
      End;
    For i:=0 to high ( LettresVie ) do
      Begin
        LettresVie [ i ] := TLettre.Create ( SpriteEngine, ' ', EcranX-LimiteX+60 + i * 9, EcranY - 60 );
      End;
  //         Application.MessageBox ( 'EZRRZE', 'rtez', MB_OK );
    for I:=0 to TailleX-1 do for J:=0 to TailleY-1 do
     begin
       if (Cases[I,J,0]>0) and (Cases[I,J,0]<=FinBriques) then
        begin
          Briques[I,J].Brique:=TBrique.Create(SpriteEngine,I, J, Cases );
        End
         else
         Briques[I,J].Brique:=nil;
     end;
     //  Charge;
    {  Background  }
  {  with DXInput do
     begin
     Keyboard.Enabled:=False;
     Joystick.Enabled:=False;
     Mouse.Enabled:=False;
     End;
    with DXInput2 do
     begin
     Keyboard.Enabled:=False;
     Joystick.Enabled:=False;
     Mouse.Enabled:=False;
     End;
    with DXInput3 do
     begin
     Keyboard.Enabled:=False;
     Joystick.Enabled:=False;
     Mouse.Enabled:=False;
     End;
    with DXInput4 do
     begin
     Keyboard.Enabled:=False;
     Joystick.Enabled:=False;
     Mouse.Enabled:=False;
     End;}
    Joueurs[Bas]:= TPlayerBas   .Create(SpriteEngine, True, ControleJoueur [ Bas ]) ;
    with Joueurs[Bas] do
      Begin
        Joueur := @Joueurs[Bas];
        BallePlus;
      End ;
    Joueurs[Haut] := TPlayerHaut  .Create(SpriteEngine, True, ControleJoueur [ Haut ]);
    with Joueurs[Haut] do
      Begin
        Joueur := @Joueurs[Haut];
        BallePlus;
      End ;
    Joueurs[Gauche] := TPlayerGauche.Create(SpriteEngine, True, ControleJoueur [ Gauche ]);
    with Joueurs[Gauche] do
      Begin
        Joueur := @Joueurs[Gauche];
        BallePlus;
      End ;
    Joueurs[Droite] := TPlayerDroite.Create(SpriteEngine, True, ControleJoueur [ Droite ] );
    with Joueurs[Droite] do
      Begin
        Joueur := @Joueurs[Droite];
        BallePlus;
      End ;
    if NbBriques=0 then MainForm.Suivant:=True;

   End;
  //  showmessage ('3');
  If Fenetre=FPresentation then
   begin
    InitClavier1 ( 1 );
    Compteur:=0;
  // DXInput.Mouse.Enabled:=True;
  // DXInput.Keyboard.Enabled:=True;
  // DXInput.Joystick.Enabled:=True;
   end;
  //  showmessage ('2');
  If Fenetre=FMenu
   then
    StartSceneMenu ;
  //  showmessage ('2');
  //AdDraw.Initialize
  FMouseButtonRight := False ;
  FMouseButtonLeft  := False ;
  //startscene
  Stop:= False;
end;

procedure TMainForm.ChargeStage ( const Niveau : Integer );
  var Stage : Integer ;
  Begin
    Stage := Niveau div 10 ;
    Stage := Stage mod 10 ;
    If    Stage < 1 Then Stage := 1 ;

    If  FileExists (ExtractFilePath(Application.Exename) + DirectoryData + DirectorySeparator + ImageListStage + IntToStr ( Stage  ) + ImagesLibExtension )
    and FileExists (ExtractFilePath(Application.Exename) + DirectoryData + DirectorySeparator + ImageListFond  + IntToStr ( Niveau ) + ImageExtension )
      then
        Begin
          FondImage.Clear;
          FondImage.LoadFromFile(ExtractFilePath(Application.Exename) +DirectoryData + DirectorySeparator + ImageListFond + IntToStr ( Niveau ) + ImageExtension);
          ImageList.Clear;
          ImageList.LoadFromFile(ExtractFilePath(Application.Exename) +DirectoryData + DirectorySeparator + ImageListStage + IntToStr ( Stage ) + ImagesLibExtension);
        End
      else
        Application.Terminate;
 ImageList.Restore ;
 FondImage.Restore ;
End;

procedure TMainForm.ChargeTir ();
  Begin
    If  FileExists (ExtractFilePath(Application.Exename) + DirectoryData + DirectorySeparator + ImageListTir   + ImagesLibExtension                             )
      then
        Begin
          if not assigned ( ImageListTirs.Find ( ImageTir )) Then
            Begin
              ImageListTirs.LoadFromFile(ExtractFilePath(Application.Exename) +DirectoryData + DirectorySeparator + ImageListTir   + ImagesLibExtension);
              ImageListTirs.Restore;
            End;
        End
      else
        Application.Terminate;

End;

// Fin de l'animation destruction des sprites
procedure TMainForm.EndSceneMain;
begin
  Stop:=True;
    {  Main scene end  }
    //destruction des sprites
  SpriteEngine.Clear;

  if Fenetre=FMenu then EndSceneMenu;
end;

procedure TMainForm.Joue;
var i :integer;
begin
 Fenetre:=FJeu;
 EndSceneMain;
 NoNiveau:=0;
 Score:=0;
 PointsVie:=0;
 ScoreAjouteVie:=ScoreVie;
 NoNiveau:=0;
 Vies:=10;
 ChargeTir ();
 StartSceneMain;
 SceneMain;
//       DXTimer.Enabled:=True;
end;

// Scène d'animation
procedure TMainForm.SceneMain;
var I : Integer ;
begin

if Fenetre=FJeu then
 begin
  //  Main scene
{  DXInput .Update;
  DXInput2.Update;
  DXInput3.Update;
  DXInput4.Update;}


  For i:= low ( Joueurs ) to high ( Joueurs ) do
  If  ((( ControleJoueur [i] = itMouse    ) and ( MouseButtonLeft ))
//  or  ((( ControleJoueur [i] = itJoystick1 ) or ( ControleJoueur [i] = itJoystick2 )) and (Joystick.Buttons [0] ))
  or  ((( ControleJoueur [i] = itKeyboard1  ) or ( ControleJoueur [i] = itKeyboard2  )) and ( ToucheBoutonA [ i ] and KeybOardState = ToucheBoutonA [ i ] )))
  and ( pmErased in Joueurs[i].PlayerModifs     )
    Then
        Joueurs[i].PlayerModifs := Joueurs[i].PlayerModifs + [pmAfficher] ;//AnimOuvreBas ;

  SpriteEngine.Move(AdPerCounter.TimeGap / 1000);

  FondImage.Items [ 0 ].Draw(AdDraw,0,0,0);
  SpriteEngine.Draw;
  SpriteEngine.Dead;
//  MAJ_objets3D ;
  with AdDraw.Canvas do
    begin
      Brush.Style := abClear;
//      Font.Color.r := 255;
//      Font.Color.g := 255;
//      Font.Color.b := 0;
//      Font.Color.a := 100;
//      Font.Size := 30;
      AfficheTexte(LettresScore, IntToStr(Score));
      AfficheTexte(LettresVie  , IntToStr(Vies));
      AfficheTexte(LettresPVie , IntToStr(PointsVie));
//      Font.Size := 10;
      if Compteur<100 then
      Textout(10, 30, MessageEcran)
       else MessageEcran:='';
      inc(Compteur);
      Release;
    end;
 end;
if Fenetre=FMenu then SceneMenu;
if Fenetre=FPresentation then ScenePresentation;
end;

// Démarre le 1er niveau
procedure TMainForm.AfficheTexte( const Lettres : TLettres ; const Texte : String);
var i : Integer ;
Begin
  For i := 1 To length ( Texte ) do
   if i <= high ( Lettres ) Then
    Begin
      Lettres [ i ].SetLettre ( Texte [ I ], False );
    End ;
End;

// Démarre le 1er niveau
// Met en full screen au démarrage
procedure TMainForm.FormPaint(Sender: TObject);
begin
if (not OptionFullscreen.checked) and not Ecran then
  begin
  //OptionFullScreenClick(OptionFullScreen);
  Ecran:=True;
  End;
end;


procedure TMainForm.FormKeyPress(Sender: TObject;  Key: Char);
begin
if Envoi then Messages:=Messages+Key;
end;

procedure TMainForm.AKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  p_KeyDown( Sender, Key, ssAlt in Shift );
end;

procedure TMainForm.AKeyPress(Sender: TObject; var Key: Char);
begin
if Envoi then Messages:=Messages+Key;
end;

procedure TMainForm.DXSoundInitialize(Sender: TObject);
begin
  {  44100Hz, 16bit, Stereo  }
//  MakePCMWaveFormatEx(WaveFormat, 22050, 16, 2);
//  DXSound.Primary.SetFormat(WaveFormat);
end;

procedure TMainForm.GameStartClick(Sender: TObject);
begin
 Score:=0;
 Vies:=5;
 PointsVie:=0;
 SCoreAjouteVie:=ScoreVie;
 NoNiveau:=0;
 EndSceneMain;
 NbBalles:=0;
 FEnetre:=FJeu;
 StartSceneMain;
//       DXTimer.Enabled:=True;

end;

initialization

{$IFDEF FPC}
  {$i Main.lrs}
{$ENDIF}

end.

