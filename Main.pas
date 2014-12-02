unit Main;

interface
{$I definitions.inc}

uses
  TypInfo, SysUtils,
  mbcommon,
  zglSpriteEngine, zengl_sprite_image, lite_ini,
  zgl_file,
  {$IFNDEF STATIC}
  zglHeader
  {$ELSE}
  zgl_main,
  zgl_screen,
  zgl_window,
  zgl_timers,
  zgl_keyboard,
  zgl_render_2d,
  zgl_fx,
  zgl_textures,
  zgl_textures_png,
  zgl_textures_jpg,
  zgl_sprite_2d,
  zgl_primitives_2d,
  zgl_font,
  zgl_text,
  zgl_math_2d,
  zgl_utils,
  zgl_Mouse,
  zgl_sound_wav,
  zgl_sound
  {$ENDIF}
  ;

{ TSprite }

type
  { TLettre }

  TLettre  = class(TSprite)
   private
     FPetite : Boolean ;
     FLettre : Char ;
   public
    procedure SetLettre(const Lettre : Char ; const ReDraw: Boolean); virtual;
    procedure SetGrosseur(const Petite : Boolean ); virtual;
    constructor Create ( const AParent: TSpriteEngine; const Lettre : Char ; const X, Y : Double ); overload;
  End;

  TLettres = ARRAY [0..15]of TLettre;
  TFenetres=(FPresentation,FMenu,FJeu,FScores);
  TItemDirection = ( idBas,idHaut,idGauche, idDroite);
  TInputType  = (itInactive, itMouse,itKeyboard1,itKeyboard2,itJoystick1,itJoystick2);
  TBalleModif = ( bmNone, bmBalleDessus, bmAccelere, bmRalenti, bmPlomb, bmColle, bmNormal,bmFolleHautBas,bmFolle,bmFolleGaucheDroite,bmPlusGrosse,bmMoinsGrosse);
  TPlayerModif = ( pmErased, pmEnlever, pmAfficher, pmEnvoiBalle, pmBouge );
  TModeBrique = ( mbAucun, mbCassePas, mbMeurt );


const
       CST_MessageErrorInit = 'Error while initializing Multi-Briques. Try to use another display'+
              'mode or use another video adapter.';

       ShowStats = False;
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
       TimerVitesse=1/160;
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
       VitesseTir  = 200 ;
       Ralenti = 150;
       {Constantes liées au réseau }
      DXCHAT_MESSAGE = 1;
       CST_EXT_SOUND_FILE = '.wav' ;

var
  SectionsIni : Array of Record
                  SectionName : String;
                  SectionValues : String;
                end;

  FondImage   : zglPTexture = nil;
  Fenetre : TFenetres;
  ScoreAjouteVie,
  Score                     : Cardinal ;
  NbLevel,
  Compteur,
  NbBalles,
  NbPalettes,
  Vies,
  PointsVie              : Integer ;
  Stop        : Boolean = False;
  GamePause   : Boolean = False;
  LostGame  : Boolean = False;
  NextLevel : Boolean = False;
  MessageEcran  : string = '';
  ToucheHaut : UneTouche ;
  ToucheBas  : UneTouche ;
  ToucheGauche : UneTouche ;
  ToucheDroite  : UneTouche ;
  ToucheBoutonA  : UneTouche ;
  ToucheBoutonB  : UneTouche ;
  SpriteEngine: TSpriteEngine = nil;
  ControleJoueur : ARRAY[1..4] of TInputType;
  NbJoueurs : Integer;
  fntMain : zglPFont ;
  NbBriques : Integer ;
  Sound_Perdu         ,
  Sound_Casse         ,
  Sound_Folle         ,
  Sound_Immobile      ,
  Sound_SpeedUp       ,
  Sound_PaletteGrande ,
  Sound_PaletteMinus  ,
  Sound_ImagePalette  : zglPSound;
  zgl_time      : LongWord;
  Presentes     ,
  BrickItems    ,
  Bricks        ,
  Players       ,
  Balls         ,
  Shots         : TCollisionArray;

procedure Quit;
procedure Draw;
procedure Init;
procedure TimerGame;
procedure SceneFlipping;
procedure StartSceneMain;
procedure EndSceneMain;
procedure Joue;
procedure SceneMain;
procedure AfficheTexte( const Lettres : TLettres ; const Texte : String; const X, Y : Integer);
//procedure CreeIni;
procedure SceneMenu;
procedure EffaceMenu;
procedure ChargeControles;
procedure StartSceneMenu ;
procedure MenuPrincipal;
procedure ScenePresentation;

implementation

procedure loadsounds ;
begin
 snd_Init;
 SubDirSounds:='Sons' ;
 file_OpenArchive(dirRes+dir_Images+SubDirSounds+'.mbs');
 Sound_ImagePalette  := snd_LoadFromFile (ImagePalette +'Tire' + CST_EXT_SOUND_FILE,1);
 Sound_PaletteMinus  := snd_LoadFromFile (PaletteMinus + CST_EXT_SOUND_FILE,1);
 Sound_PaletteGrande := snd_LoadFromFile (PaletteGrande+ CST_EXT_SOUND_FILE,1);
 Sound_SpeedUp       := snd_LoadFromFile ('SpeedUp' + CST_EXT_SOUND_FILE,1);
 Sound_Immobile      := snd_LoadFromFile ('Immobile' + CST_EXT_SOUND_FILE,1);
 Sound_Folle         := snd_LoadFromFile ('Folle' + CST_EXT_SOUND_FILE,1);
 Sound_Casse         := snd_LoadFromFile ('Casse' + CST_EXT_SOUND_FILE,1);
 Sound_Perdu         := snd_LoadFromFile ('Perdu' + CST_EXT_SOUND_FILE,1);

end;

procedure Init ;
  var
    i : Integer;
begin

///  texLogo := tex_LoadFromFile( dirRes + 'zengl.png', $FF000000, TEX_DEFAULT_2D );

//  tex_SetFrameSize( texMiku, 128, 128 );

  // RU:   zglCSEngine2D.
  // EN: Create zglCSEngine2D object.
  SpriteEngine := TSpriteEngine.Create();

  loadsounds ;

  // RU:  1000  Miku-chan :)
  // EN: Create 1000 sprites of Miku-chan :)
//  for i := 0 to 9 do
//    AddMiku();

  fntMain := font_LoadFromFile( dirRes + 'font.zfi' );
  Fenetre:=FPresentation;
  StartSceneMain;
end;

type
  TPlayerSprite = class;
  PPlayerSprite = ^TPlayerSprite;
  TBalle = class;
//  TMBMenu = (MPrincipal,MQuitter,MControl);
  TActions = (AAttente,AJouer,AQuitter,ARetour,ARetourControle,AJoueur,AOptions,ASon,Acontroles,Abas,AHaut,ADroite,AGauche,AChangeGauche,AChangeDroite,AChangeBas,AChangeHaut);

  TChatMessage = record
    dwType: DWORD;  {  dwType is absolutely necessary.  }
    Len: Integer;
    C: array[0..0] of Char;
  end;
  TCurseur = class(TAnimatedSprite)
  Pousse   :boolean;
   private
  procedure DoMove(MoveCount: Double); override;
   public
  constructor Create ( const AParent: TSpriteEngine ; const MonImage :  String ); overload;
  End;

  { TCollisionSprite }

  TCollisionSprite = class(TAnimatedSprite)
  private
  public
    procedure CollisionBalle ( const Balle : TBalle; const AllowPlomb : Boolean ); virtual;
  end;

 { TPresente }

 TPresente = class ( TCollisionSprite  ) // Sprite d'origine
 protected
    constructor Create( const AParent: TSpriteEngine; const PosX,PosY : Integer ); overload;
    destructor Destroy; override;
  end;
 TMainSprite = class ( TAnimatedSprite  ) // Sprite d'origine
  protected
    Mode,
    TamaMax         :Integer; // Maximum de Tama
    Compteur: Integer; // compteur global
    BDGH : Byte; // Variable de position
    Attend             : Integer; // Variable d'attente
  end;
      // UN item de menu

  { TItemMenu }

  TItemMenu = class(TSprite) // Sprite d'origine
  private
  Actif,Inactif                   :String;
  Active                          : boolean;
  procedure ChangeControle(NoControle : TInputType);
  procedure DoMove(MoveCount: Double); override;
   public
  constructor Create(const AParent: TSpriteEngine; const FinImage : String ); overload;
  constructor Create(const AParent: TSpriteEngine; const FinImage : String; const X, Y : Double ; const I : Integer ); overload;
  procedure PlaceItem( const X, Y : Double ; const I : Integer); overload;
  end;

     TItems = record
              LeSprite : TItemMenu;
              LAction : TActions;
              End;

     { TTire }
     TTire = class(TCollideSprite)
     private
       Joueur : PPlayerSprite ;
     procedure DoMove(MoveCount: Double); override;
      // Gestion des collisions
     procedure  DoCollision ( const Sprite: TCollideSprite; var Done: Boolean); override;
     destructor Destroy; override;
     public
       constructor Create ( const AParent: TSpriteEngine ; const UnJoueur : PPlayerSprite ); overload;
     end;

     { TTire }

     { TTirAnim }

     TTirAnim = class(TAnimatedSprite)
     private
      Joueur : PPlayerSprite ;
     protected
      procedure DoMove(MoveCount: Double); override;
     public
      constructor Create ( const AParent: TSpriteEngine ; const UnJoueur : PPlayerSprite ); overload;
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
    procedure AnimOuvreBouche(const Sprites: array of TSprite);
    function InitPos ( const TheCoord : Double ; const NewCoord : Double ):Double;
    procedure Deplace(const InputCoord: Double);
   public
    constructor Create( const AParent: TSpriteEngine; const Apparaitre : Boolean; const Controle : TInputType); overload; virtual;
    destructor Destroy; override;
    // Methodes abstraites
    procedure BallesModifFolle; overload; virtual; abstract;
    procedure SetPalette; overload; virtual; abstract;
    procedure CreeTir ( const Double : Boolean ); virtual; abstract;
    procedure CreateAnimBouche;overload; virtual; abstract;
    procedure CreatePlayer; virtual; abstract;

    // Methodes implémentées
    procedure CreateAnimBouche(var AnimBouche : Array of TSprite ; const AImage: String ); overload; virtual;
    procedure AnimBouche ( const Sprites : Array of TSprite ); dynamic;
    procedure AnimOuvre  ( var   Sprites : Array of TSprite ); dynamic;
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
    procedure AppuieGaucheDroite     ( const ToucheAEnfoncerGauche   , ToucheAEnfoncerDroite   : Byte ); virtual;
    procedure AppuieHautBas     ( const ToucheAEnfoncerBas, ToucheAEnfoncerHaut : Byte ); virtual;
    procedure AppuieButton ( const ToucheAEnfoncer : Byte ); virtual;
    procedure ErasePlayer (); virtual;
  end;


  { TBalle }

  TBalle = class(TAnimatedSprite)
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
    procedure Limites ( var Bouge : Integer );
    procedure ChangeVitesse;
    procedure BalleModif(const Player:PPlayerSprite);
    procedure SetImageGrosseur;
    procedure SetImagePosition;

    procedure ViesPlus;
     // Gestion des collisions
  public
    procedure DoMove(MoveCount: Double); override;
    procedure ChangeUneDirection ( const Decalage : Double ); virtual;
    procedure BeforeCollision ( const Sprite: TCollideSprite ); override;
    procedure DoCollision(const Sprite: TCollideSprite; var Done: Boolean); override;
    procedure ColleBalle(const Player : PPlayerSprite);
    procedure CollisionBalle ( const Balle : TBalle ); virtual;
    procedure Envoi; virtual;
    constructor Create ( const AParent: TSpriteEngine; const Joueur : PPlayerSprite ; Const X, Y : Double ); overload;
    destructor Destroy; override;
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
    procedure BallesModifFolle; override;
    procedure UnMouvement; override;
    procedure SetBalleCollePosition ( const UneBalle : TBalle ); override;
    // Gestion des mouvement
    procedure DoMove(MoveCount: Double); override;
    // Gestion des collisions
    procedure DoCollision ( const Sprite: TCollideSprite; var Done: Boolean); override;
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
    procedure   DoCollision ( const Sprite: TCollideSprite; var Done: Boolean); override;
    procedure SetBalleColle ( const UneBalle : TBalle ); override;
    Procedure BalleFolle ( const Balle : TBalle); override;
    procedure CreeTir ( const Double : Boolean ); override;
    procedure BallesModifFolle; override;
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
  procedure   DoCollision ( const Sprite: TCollideSprite; var Done: Boolean); override;
  public
    procedure CreateAnimBouche; override;
    procedure SetBalleColle ( const UneBalle : TBalle ); override;
    Procedure BalleFolle ( const Balle : TBalle); override;
    procedure CreeTir ( const Double : Boolean ); override;
    procedure BallesModifFolle; override;
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
    procedure BallesModifFolle; override;
    procedure UnMouvement; override;
    procedure SetBalleCollePosition ( const UneBalle : TBalle ); override;

    // Gestion des collisions
    procedure SetPalette; override;
    procedure DoCollision ( const Sprite: TCollideSprite; var Done: Boolean); override;
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
  procedure   DoCollision ( const Sprite: TCollideSprite; var Done: Boolean); override;
//  procedure DoMove(MoveCount: Double); override;
   //Constructeur
//  constructor Create(AParent: TSpriteEngine;Joueur : TPlayerSprite); virtual;
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
    constructor Create ( const AParent: TSpriteEngine; const i,j :integer ; var Cases : TCases ); overload;
    destructor Destroy ; override;
  end;

  TItem = class(TAnimatedSprite)
  private
  Palette : boolean;
  NoItem : integer;
  BDGH : TItemDirection ;
  procedure Destruction;
  procedure DoMove(MoveCount: Double); override;
   protected
  procedure NextAnimation;
  public
    constructor Create( const AParent: TSpriteEngine; const Joueur : PPlayerSprite ; const X, Y : Double ; const NoItem :  Integer ); overload;
    destructor Destroy ; override;
  end;


{ TCollisionSprite }

procedure TCollisionSprite.CollisionBalle(const Balle: TBalle; const AllowPlomb : Boolean );
var MilieuX,MilieuY, VecteurAjouteY, VecteurAjouteX                  :integer;
    ModifX, ModifY                  : boolean;
begin
  ModifX:=False;
  ModifY:=False;
  MilieuX:=trunc(Balle.X+Balle.H/2);
  MilieuY:=trunc(Balle.Y+Balle.H/2);
//   begin
  if not AllowPlomb
  or not (bmPlomb in Balle.Activite) then
    begin
      if ((X>=MilieuX) and (Balle.BougeX>0))
      or ((X+W<=MilieuX) and (Balle.BougeX<0)) then
       //La balle vient de la gauche ou de la droite
        Begin
         ModifX:=True;
         VecteurAjouteY := trunc ( X - MilieuX );
        End ;
      if ((Y>=MilieuY) and (Balle.BougeY>0))
      or ((Y+H<=MilieuY) and (Balle.BougeY<0))
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

constructor TPresente.Create(const AParent: TSpriteEngine; const PosX,PosY: Integer);
begin
  inherited Create(AParent);
  SetImage ( 'Presente' + IntToStr ( PosY )+ IntToStr ( PosX ) );
  W  := Texture.Width ;
  H := Texture.Height ;
  CanDoCollisions:=True;
  If Posx = 0 Then
    Begin
      X := EcranX - LimiteXImages + 1 ;
    End
   Else
    Begin
      X := LimiteXImages - W - 1 ;
    End ;
  If PosY = 0 Then
    Begin
      Y := EcranY - LimiteYImages + 1 ;
    End
   Else
    Begin
      Y := LimiteYImages - H - 1 ;
    End ;
  RegisterCollideArray ( Presentes );
end;

destructor TPresente.Destroy;
begin
  inherited Destroy;
  UnRegisterCollideArray ( Presentes );
end;

type  UneBrique      = RECORD
                       Brique : TBrique;
                       Existe : Boolean;
                       End;
      TBriques        = ARRAY[0..NbBriquesX-1,0..NbBriquesY-1] of UneBrique;

var
    Items : ARRAY[0..MaXItems-1] of TItems;
    BoucheGauche : ARRAY[0..MaxMurGD] of TSprite;
    BoucheDroite : ARRAY[0..MaxMurGD] of TSprite;
    BoucheBas : ARRAY[0..MaxMurBH] of TSprite;
    BoucheHaut : ARRAY[0..MaxMurBH] of TSprite;
    Action_Sprite : TActions;
    joueurs: Array [ 1 .. 4 ] of TPlayerSprite;
//    Controles : ARRAY[1..4] of byte;
//    XCombien :Byte;
    Briques : Tbriques;
    LettresScore : TLettres ;
    LettresPVie  : TLettres ;
    LettresVie   : TLettres ;
    Curseur : TCurseur;


{ TLettre }

procedure TLettre.SetLettre(const Lettre: Char; const ReDraw: Boolean);
begin
  If ( Redraw or ( Lettre <> FLettre ))
  and ( Lettre <> ' ' ) Then
    if FPetite Then
      Begin
        If  (Ord ( Lettre ) >= ChiffreDebut )
        and (Ord ( Lettre ) <= ChiffreFin ) Then
          SetImage ( ChiffrePetit + Lettre )
         Else
          SetImage ( LettreGrosse + Lettre );
        W  := 8;
        H := 16;
      End
     Else
      Begin
        If  (Ord ( Lettre ) >= ChiffreDebut )
        and (Ord ( Lettre ) <= ChiffreFin ) Then
          SetImage ( ChiffreGros + Lettre )
         Else
          SetImage ( LettreGrosse + Lettre );
        W  := 16;
        H := 16;
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

constructor TLettre.Create(const AParent: TSpriteEngine; const Lettre: Char;const X, Y : Double );
begin
  inherited Create(AParent);
  Self.X := X ;
  Self.Y := Y ;
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
 SetImage(Actif);
End;

procedure InitClavier1 ( const NoJoueur : Integer );
Begin
  ToucheHaut [ NoJoueur ] := K_Up ;
  ToucheBas [ NoJoueur ]  := K_Down ;
  ToucheGauche [ NoJoueur ]  := K_Left ;
  ToucheDroite [ NoJoueur ]  := K_right ;
  ToucheBoutonA [ NoJoueur ]  := K_DELETE ;
  ToucheBoutonB [ NoJoueur ]  := K_ENTER ;
End;

procedure TItemMenu.DoMove(MoveCount: Double);
var NewImage : String ;
begin
  NewImage := '' ;
  if (Curseur.X>X) and (Curseur.Y>Y) and (Curseur.X<X+W) and (Curseur.Y<Y+H) then
   begin
   if ( not Active ) then
    Begin
     if Inactif=ImageJoueurs then
      begin
        NewImage := ImageActif+IntToStr(NbJoueurs)+ImageJoueurs;
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
       NewImage := IntToStr(NbJoueurs)+ImageJoueurs;
     end
     else
      NewImage := InActif;
    End;
  if ( NewImage <> '' ) then
   Begin
    SetImage(NewImage);
    W:=Texture.Width;
    H:=Texture.Height;
   End;
end;

procedure TItemMenu.PlaceItem(const X, Y: Double; const I: Integer);
begin
  Self.Y:=Y + H * I;
  Self.X:=X ;

end;

constructor TItemMenu.Create(const AParent: TSpriteEngine; const FinImage : String );
begin
  inherited Create(AParent);
  Active:=False;
  Actif:=ImageActif + FinImage;
  Inactif:=FinImage;
  SetImage(Inactif);
  W:=Texture.Width;
  H:=Texture.Height;
End;

constructor TItemMenu.Create(const AParent: TSpriteEngine;
  const FinImage: String; const X, Y: Double; const I: Integer);
begin
  Create ( AParent, FinImage );
  PlaceItem(X,Y,I);
end;

    { Curseur }
procedure TCurseur.DoMove(MoveCount: Double);
begin
  X:=mouse_X;
  Y:=Mouse_Y;
{  If ( ToucheHaut [ 1 ]    and MainForm.KeyboardState = ToucheHaut [ 1 ]   ) Then  Y:= Y - 12;
  If ( ToucheBas [ 1 ]     and MainForm.KeyboardState = ToucheBas [ 1 ]    ) Then  Y:= Y + 12;
  If ( ToucheDroite [ 1 ]  and MainForm.KeyboardState = ToucheDroite [ 1 ] ) Then  X:= X + 12;
  If ( ToucheGauche [ 1 ]  and MainForm.KeyboardState = ToucheGauche [ 1 ] ) Then  X:= X - 12;
 } if X<0 then X:=0;
  if Y<0 then Y:=0;
  if X>EcranX then X:=EcranX;
  if Y>EcranY then Y:=EcranY;
End;

constructor TCurseur.Create(const AParent: TSpriteEngine ; const MonImage :  String );
begin
  inherited Create(AParent);
  SubImages:=dir_Images + Dir_Menus;
  SetImage(MonImage,15);
  X:=0;
  Y:=0;
  W  := Texture.Width div 15;
  H := Texture.Height;
  //AnimCount:=Texture.FramesX;
  AnimStart := 1 ;
  AnimStop := AnimCount ;
  AnimSpecial := asLoop;
  AnimActive:=True;
  Frame := 1;
  //AnimSpeed := Vitesse/1000;
  Visible:=True;
  SubImages:=dir_Images + Dir_Menus+ Dir_Lang;
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

procedure TPlayerSprite.CreateAnimBouche ( var AnimBouche : Array of TSprite ; const AImage : String );
var i : integer;
begin
  // L'animation de bouchage comprant un certain nombre de sprites
  for I:=0 to high ( AnimBouche ) do
    Begin
      AnimBouche[I]:= TCollideSprite.Create ( SpriteEngine );
      with AnimBouche[I] do
        begin
          Visible := True;
          // On vérifie des variables
          if i = 0 then SetImage(AImage+'1')
            else if i = high (AnimBouche) then SetImage(AImage+'3')
            else SetImage(AImage+'2');
          W:=Texture.Width;
          H:=Texture.Height;
          case NoJoueur of
            Bas    : Begin if i = 0 Then X:= LimiteX-4 Else X:= LimiteX-4+I*AnimBouche[I-1].W ; Y := EcranY-H+Bouche; End;
            Haut   : Begin if i = 0 Then X:= LimiteX-4 Else X:= LimiteX-4+I*AnimBouche[I-1].W ; Y := -Bouche; End;
            Gauche : Begin if i = 0 Then Y:= LimiteY   Else Y:= LimiteY  +I*AnimBouche[I-1].H; X := -Bouche; End;
            Droite : Begin if i = 0 Then Y:= LimiteY   Else Y:= LimiteY  +I*AnimBouche[I-1].H; X := EcranX-W+Bouche;  End;
          end;
         End;
    End;
end;


procedure TPlayerSprite.AnimBouche(const Sprites: array of TSprite );
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

procedure TPlayerSprite.AnimOuvreBouche( const Sprites: array of TSprite );
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
         Sprites[I].Y:=EcranY-Intervalle-Sprites[I].H+Bouche
        else
         Sprites[I].X:=EcranX-Intervalle-Sprites[I].W+Bouche;
   end;

End;
procedure TPlayerSprite.AnimOuvre( var Sprites: array of TSprite );
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
         if assigned ( Sprites[I]) Then
           begin
             Sprites[I].dead;
             Sprites[I].Free;
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
          if (mouse_Click ( 0 )) and self.Visible then
             begin
                PlayerModifs := PlayerModifs + [pmBouge];
                EnvoiBalle;
              end;
{               if (Mouse.Buttons[0]) and not self.Visible then
                CanAppear:=True;}
         End;
      itKeyboard1,itKeyboard2 :
         begin
           if key_Press ( ToucheAEnfoncer) and self.Visible then
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

constructor TPlayerSprite.Create(const AParent: TSpriteEngine; const Apparaitre : Boolean; const Controle : TInputType );
begin
  inherited Create(AParent);
  Cree;
  SetPalette;
  Controleur(Controle);
  RegisterCollideArray ( Players );
end;

destructor TPlayerSprite.Destroy;
begin
  UnRegisterCollideArray ( Players );
  inherited Destroy;
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
  Balle.Limites(Balle.BougeX);
end;


Procedure TPlayerSprite.BalleFolleGaucheDroite ( const Balle : TBalle);
begin
  if ControlY+Y>Y
   then
    inc(Balle.BougeY);
  if ControlY+Y<Y
   then
    dec(Balle.BougeY);
  Randomize;
  if Balle.BougeX=0
   then
    Balle.BougeX:=Random(10)+1;
  Balle.Limites(Balle.BougeY);
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
  if (NbJoueurs>0)
  and (NBBalles=0)
  and ( [pmBouge,pmEnlever] * PlayerModifs = [] )
   Then
    Begin
      Setlength ( Balls, 0 );
      Controleur ( itInactive );
      PlayerModifs := PlayerModifs + [pmEnlever,pmErased];
      Cree;
      SetPalette;
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
 if Y+H+Deplacement1+Deplacement2 / 4+Deplacement3 / 8>EcranY-LimiteY then
  begin
    Y := InitPos ( Y, EcranY-LimiteY-H );
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
 if X+W+Deplacement1+Deplacement2 / 4+Deplacement3 / 8>EcranX-LimiteX then
  begin
    X := InitPos ( X, EcranX-LimiteX-W );
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
                 ControlX:=trunc(Mouse_X-X);
                 End;
        itKeyboard1,itKeyboard2 :
                 begin
                 if key_Press ( ToucheAEnfoncerDroite) then
                 ControlX:=round ( 10+Deplacement2 / 2+ Deplacement3 / 3 )
                  else
                  if key_Press ( ToucheAEnfoncerGauche) then
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
                 ControlY:=trunc(Mouse_Y-Y);
               End;
      itKeyboard1,itKeyboard2 :
               begin
               if key_Press ( ToucheAEnfoncerBas) then
               ControlY:=round ( 10+Deplacement2 / 2+ Deplacement3 / 3 )
                else
                if key_Press ( ToucheAEnfoncerHaut) then
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
  1 : SetImage ( ImagePalette + Palette + PaletteMinus);
  2 : SetImage ( ImagePalette + Palette + PalettePetite);
  3 : SetImage ( ImagePalette + Palette + PaletteMoyenne);
  4 : SetImage ( ImagePalette + Palette + PaletteColle);
  5 : SetImage ( ImagePalette + Palette + PaletteTire + '1');
  6 : SetImage ( ImagePalette + Palette + PaletteTire + '2');
  7 : SetImage ( ImagePalette + Palette + PaletteInvisible);
  8 : SetImage ( ImagePalette + Palette + PaletteGrande);
  End;
 If (( pmAfficher in PlayerModifs ) and Visible and ( PaletteEnCours = NoPalette )) Then
   Begin
     Controle:= ControleJoueur [ NoJoueur ];
     PlayerModifs:=PlayerModifs-[pmAfficher];
     if PaletteEncours=4 then Mode:=Colle;
     if (PaletteEncours>=7)
     or (PaletteEncours< 4) then Mode:=0;
     if (PaletteEncours=1) and visible and ( pmEnlever in PlayerModifs ) then
      Controleur(itInactive);
   End;
 W:=Texture.Width;
 H:=Texture.Height;

end;

procedure TPlayerSprite.Cree;
begin
  PlayerModifs := [pmAfficher];
  inc(NbPalettes);
  BalleModif := bmNone;
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
//  AnimSpeed := Vitesse/1000;
  Visible:=True;
  CanDoCollisions:=True;
  CreatePlayer ;
End;

procedure TPlayerSprite.CreeTirHautBas(const Double: Boolean; const MoinsY : Boolean );
var Decale : Integer;
    SpriteTir : Ttire ;
begin
  if Double then
    Begin
      Decale := 13;
      SpriteTir := Ttire.create(SpriteEngine, Joueur);
      SpriteTir.X:= self.X + self.W / 2 - SpriteTir.W / 2 - Decale;
      SpriteTir.Y:= GetTirY ( MoinsY , SpriteTir );
    End
   Else
    Decale := 0 ;
  SpriteTir := Ttire.create(SpriteEngine, Joueur);
  SpriteTir.X:= self.X + self.W / 2 - SpriteTir.W / 2 + Decale;
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
      SpriteTir.Y:= self.Y + Self.H / 2 - SpriteTir.H / 2 - Decale;
    End
   Else
    Decale := 0 ;
  SpriteTir := Ttire.create(SpriteEngine, Joueur);
  SpriteTir.X:= GetTirX ( MoinsX , SpriteTir );
  SpriteTir.Y:= self.Y + Self.H / 2 - SpriteTir.H / 2 + Decale;
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
begin
  if NbBalles > Maxiballes Then
    Exit;
  CompteEnvoi := 0 ;
  BalleModif := bmNone;
  TBalle.Create(SpriteEngine, Joueur, Self.X + Self.W / 2, Self.Y + Self.H / 2 );
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
     Result:= self.Y - SpriteTir.W / 2
    else
     Result:= self.Y ;

end;

function TPlayerSprite.GetTirX(const MoinsX: Boolean; const SpriteTir: Ttire
  ): Double;
begin
  if MoinsX Then
     Result:= self.X - SpriteTir.H
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
         UneBalle.DecalePalette:= trunc( Uneballe.X + UneBalle.W/2 - Self.X - Self.W / 2 );
         if ( Abs ( UneBalle.DecalePalette ) > Self.W / 3 ) Then
           if ( UneBalle.BougeX <> 0 ) Then
              Begin
                UneBalle.BougeX := UneBalle.BougeX div UneBalle.BougeX * UneBalle.DecalePalette ;
              End
             Else
              Begin
                UneBalle.BougeX := UneBalle.DecalePalette ;
              End;
         UneBalle.DecalePalette:= trunc ( Uneballe.X - Self.X );
         UneBalle.Limites(UneBalle.BougeX);
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
         UneBalle.DecalePalette:= trunc( Uneballe.Y + UneBalle.W/2 - Self.Y - Self.H / 2 );
         if ( Abs ( UneBalle.DecalePalette ) > Self.H / 3 ) Then
           if ( UneBalle.BougeY <> 0 ) Then
              Begin
                UneBalle.BougeY := UneBalle.BougeY div UneBalle.BougeY * UneBalle.DecalePalette ;
              End
             Else
              Begin
                UneBalle.BougeY := UneBalle.DecalePalette ;
              End;
         UneBalle.DecalePalette:= Trunc ( Uneballe.Y - Self.Y );
         UneBalle.Limites(UneBalle.BougeY);
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
                  PlaySoundRandom ( Sound_ImagePalette,False);
                  end;
         BTire2 : begin
                  inc(Score,PTire2*NbPalettes);
                  NoPalette:=6;
                  PlaySoundRandom ( Sound_ImagePalette,False);
                  end;
         BMinus : begin
                  inc(Score,PMinus*NbPalettes);
                  PlaySoundRandom ( Sound_PaletteMinus,False);
                  NoPalette:=1;
                  end;
         BPetit : begin
                  inc(Score,PPetit*NbPalettes);
                  PlaySoundRandom ( Sound_PaletteMinus,False);
                  NoPalette:=2;
                  end;
         BGrand : begin
                  inc(Score,PGrand*NbPalettes);
                  PlaySoundRandom ( Sound_PaletteGrande,False);
                  NoPalette:=8;
                  end;
         BBase : begin
                 inc(Score,PBase*NbPalettes);
                 BallesModif ( bmNormal );
                 end;
         BSpeedUp : begin
                    inc(Score,PSpeedUp*NbPalettes);
                    PlaySoundRandom ( Sound_SpeedUp,False);
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
                    PlaySoundRandom ( Sound_Immobile,False);
                    CompteImmobile:=TempsImmobile;
                    end;
         BTransparent: begin
                       inc(Score,PTransparent*NbPalettes);
                       NOPalette:=7;
                       end;
         BFolle: begin
                 inc(Score,PFolle*NbPalettes);
                 PlaySoundRandom ( Sound_Folle,False);
                 BallesModifFolle;
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
      If ( Frame > 2 ) Then
        Frame := 2
       Else
        Frame := 3 ;
    End
   Else
     Frame := Frame - 1;
  if ( Frame = 0 )
   Then
    Begin
      Dead;
      Frame := 1 ;
    end;
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

constructor TItem.Create( const AParent: TSpriteEngine; const Joueur : PPlayerSprite ; const X, Y : Double ; const NoItem :  Integer );
Begin
  inherited Create(AParent);
       If Joueur = @Joueurs [ Droite ] Then BDGH := idDroite
  Else If Joueur = @Joueurs [ Gauche ] Then BDGH := idGauche
  Else If Joueur = @Joueurs [ Droite ] Then BDGH := idDroite
  Else If Joueur = @Joueurs [ Bas    ] Then BDGH := idBas ;
  Palette:=False;
  AnimActive := False;
//  AnimSpeed:=Vitesse/1000;
  CanDoCollisions:=True;
  CanDoMoving:=True;
  Visible:=True;
  Self.X := X ;
  Self.Y := Y ;
  SetImage  ( ImageBrique +InTTosTr(NoItem), 6);
  Frame:=2;
  Self.X:=X;
  Self.Y:=Y;
  Self.NoItem:=NoItem;
  PlaySoundRandom ( Sound_Casse,False);
  RegisterCollideArray ( BrickItems );
End;

destructor TItem.Destroy;
begin
  inherited Destroy;
  UnRegisterCollideArray ( BrickItems );
end;

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
  UneBalle.Y:=self.Y-UneBalle.W;
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

procedure TPlayerBas.BallesModifFolle;
begin
  BallesModif ( bmFolleHautBas );
end;

procedure TPlayerBas.CreateAnimBouche ;
begin
  inherited CreateAnimBouche ( BoucheBas, 'BoucheBas' );
End;
procedure TPlayerBas.DoCollision ( const Sprite: TCollideSprite; var Done: Boolean);
begin
  UneCollisionX(Sprite,Done);
  inherited DoCollision( Sprite, Done);
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
procedure TPlayerHaut.BallesModifFolle;
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

procedure TPlayerHaut.DoCollision ( const Sprite: TCollideSprite; var Done: Boolean);
begin
  UneCollisionX(Sprite,Done);
  inherited DoCollision( Sprite, Done );
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
  UneBalle.Y:=self.Y+self.H;
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
procedure TPlayerGauche.BallesModifFolle;
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

procedure TPlayerGauche.DoCollision ( const Sprite: TCollideSprite; var Done: Boolean);
begin
  UneCollisionY( Sprite, Done );
  Inherited DoCollision( Sprite, Done );
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
  UneBalle.X:=self.X+Self.W;
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
  UneBalle.X:=self.X-UneBalle.W;
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

procedure TPlayerDroite.BallesModifFolle;
begin
  BallesModif ( bmFolleGaucheDroite );

end;

procedure TPlayerDroite.CreateAnimBouche;
begin
  CreateAnimBouche ( BoucheDroite, 'BoucheDroite');
end;

Procedure TPlayerDroite.CreatePlayer ;
var I       :Integer;
begin
  X := JoueurDroiteX;
  Y:= JoueurDroiteY;
  NoJoueur := Droite ;
End ;

procedure TPlayerDroite.DoCollision ( const Sprite: TCollideSprite; var Done: Boolean);
begin
  UneCollisionY( Sprite, Done );
  Inherited DoCollision( Sprite, Done );
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
  case NoBrique [ 0 ] of
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
       SetImage(  ImageBrique +IntToStr(NoBrique[0]), 6);
       Mode:=mbAucun;
       Frame:=1;
       AnimActive:=False;
       CanDoCollisions:=True;
     End;
   if NbBriques=0 then NextLevel:=True;
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
       Frame := Frame + 1;
       if round ( Frame ) = AnimCount
        then Destruction;
     end ;
    mbCassePas :
     begin
       Frame := Frame + 1;
       if round ( Frame ) = AnimCount then
        begin
          Frame:=1;
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
constructor TBrique.Create ( const AParent: TSpriteEngine; const i,j :integer ; var Cases : TCases );
var Indice : Integer ;
begin
  inherited Create(AParent);
  Indice := Cases [ i, j, 0 ];
  Joueur:=Nil;
//  BDGH:=Bas;
  Mode:=mbAucun;
  SetImage(  ImageBrique +IntToStr(Indice), 6 );
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
  W := Texture.Width div 6;
  H := Texture.Height;
  CanDoCollisions:=True;
//  AnimCount := Texture.FramesX;
  AnimActive := False;
  InitBrique(i,j,Cases);
  RegisterCollideArray ( Bricks );
//  AnimSpeed := Vitesse/1000;
end;

destructor TBrique.Destroy;
begin
  inherited Destroy;
  UnRegisterCollideArray ( Bricks );
end;

procedure Tballe.SetImageGrosseur;
begin
  SetImage (  ImageBalle + IntToStr ( Grosseur ), 2 );
  W  := Texture.Width div 2;
  H := Texture.Height;
  SetImagePosition;
End ;

procedure Tballe.SetImagePosition;
begin
  if (bmPlomb in Activite) Then
    Frame := 2
   Else
    Frame := 1 ;
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
  if not ( bmColle in Activite ) Then
    Begin
      if BougeX > 0 Then BougeX:=trunc(Vitesse*(BougeX/BougeX))
                    Else BougeX:=Vitesse;
      if BougeY > 0 Then BougeY:=trunc(Vitesse*(BougeY/BougeY))
                    Else BougeY:=Vitesse;
      if BougeX > VitesseMax Then BougeX := VitesseMax;
      if BougeY > VitesseMax Then BougeY := VitesseMax;
    End;
End;

procedure Tballe.Limites ( var Bouge : Integer );
Begin
  if (Abs(Bouge)>=VitesseMax) then Bouge:=VitesseMax*Bouge div Bouge;
End;


procedure TBalle.Destruction;
Begin
  dec(NBBalles);
  //MainForm.Donnee:=intToStr(NBBalles);
  if NBBalles<=0 then LostGame:=True;
  Frame:=1;
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
    Limites(BougeX);
    Limites(BougeY);
  end;

end;


// gestion des collisions
procedure TBalle.BeforeCollision ( const Sprite: TCollideSprite);
begin
   if (Sprite is TBalle   ) Then TestCollision := TestCollisionCircleCircle
                            else TestCollision := TestCollisionCircleRectangle;
end;

// gestion des collisions
procedure TBalle.DoCollision ( const Sprite: TCollideSprite; var Done : Boolean);
begin
  if (Sprite is TBrique) then // si la balle rencontre une brique
    (Sprite as TBrique ).CollisionBalle ( Self )
  else if (Sprite is TBalle) then
     CollisionBalle ( Sprite as TBalle )
  else if (Sprite is TPresente) then // si la balle rencontre les murs
     (Sprite as TPresente ).CollisionBalle ( Self, False )
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
  if ( not assigned ( Joueurs[NoJoueur] ) or not Joueurs[NoJoueur].Visible ) then Result:=True
  else
   if Perdu
   and Visible then
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
       CanDoCollisions:=True;
     End ;

  inc(Accelere);
  // Pas de vérfication de collision avec les sprites du décor
  // On vérifie directement les positions dans les limites des bords du décor
{  if ( X < LimiteX ) and ( Y < LimiteY ) Then
   ChangeUneDirection ( X-LimiteX - Y + LimiteY );
  if ( X < LimiteX ) and ( Y + H > EcranY - LimiteY ) then
   ChangeUneDirection ( X-LimiteX + Y - EcranY - H + LimiteY );
  if ( X + W > EcranX - LimiteX ) and ( Y < LimiteY ) then
   ChangeUneDirection ( - X + W + EcranX - LimiteX - Y + LimiteY );
  if ( X + W > EcranX - LimiteX ) and ( Y + H > EcranY - LimiteY ) then
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
  PerdJoueur (X+W <0, Gauche);
  PerdJoueur (Y+H<0, Haut);
  if Change>=TempsChange then // au bout d'un moment la balle change de direction
   if ( bmColle in Activite ) Then
      Envoi
     Else
       begin
         Change:=0;
         Randomize;
         if (Abs(BougeX)>=VitesseMax) then BougeX:=Lente * ( Random ( 2 ) + 2 );
         Randomize;
         if (Abs(BougeY)>=VitesseMax) then BougeY:=Lente * ( Random ( 2 ) + 2 );
       End;
  X:=X+BougeX*MoveCount;    // Déplacement de la itMouse
  Y:=Y+BougeY*MoveCount;
  Inc(Change);  // Compteur qui sert à contrôler la direction de la balle
   // Collisions ensuite
  inherited DoMove(MoveCount);
//  Collision;
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
 CanDoCollisions := True;
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
end;

//Crée une brique
constructor TBalle.Create ( const AParent: TSpriteEngine; const Joueur : PPlayerSprite ; Const X, Y : Double );
begin
  inherited Create(AParent);
  Self.Joueur := Joueur ;
  Mode:=0;
  Activite := [bmColle];
  Grosseur := 1 ;
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
  RegisterCollideArray ( Balls );
end;

destructor TBalle.Destroy;
begin
  inherited Destroy;
  UnRegisterCollideArray ( Balls );
end;

procedure TBalle.Show;
begin
  If not Visible Then
    Begin
      Visible := True ;
      inc ( NbBalles );
    End;

end;

procedure TTire.DoCollision  ( const Sprite: TCollideSprite ; var Done: Boolean );
Begin
  if (Sprite is TBrique) then // si le tir rencontre une brique
  with TTirAnim.create ( SpriteEngine, Joueur ) do
    begin
      X := Self.X - ( W - Self.W) / 2;
      Y := Self.Y - ( W - Self.W) / 2;
      TBrique(Sprite).Touche;
      Dead;
    End ;
End ;

destructor TTire.Destroy;
begin
  inherited Destroy;
  UnRegisterCollideArray(Shots);
end;


constructor TTire.Create  ( const AParent: TSpriteEngine ; const UnJoueur : PPlayerSprite );
Begin
  inherited Create(AParent);
  TestCollision:=TestCollisionCircleRectangle;
  Joueur:=UnJoueur;
  SetImage  ( ImageTir );
  Visible:=True;
  CanDoCollisions:=True;
  CanDoMoving:=True;
  RegisterCollideArray(Shots);
End ;

procedure TTire.DoMove(MoveCount: Double);
begin
  if CanDoCollisions Then
    Begin
     if ( X > EcranX ) or ( Y > EcranY ) or ( X < -W ) or ( Y < -H )
       Then
        Dead ;
    end;

       If Joueur=@Joueurs[Bas   ] Then Y := Y - VitesseTir * MoveCount
  Else If Joueur=@Joueurs[Haut  ] Then Y := Y + VitesseTir * MoveCount
  Else If Joueur=@Joueurs[Gauche] Then X := X + VitesseTir * MoveCount
  Else If Joueur=@Joueurs[Droite] Then X := X - VitesseTir * MoveCount;
end;

{  TTirAnim  }

procedure TTirAnim.DoMove(MoveCount: Double);
begin
  if Round ( Frame ) < AnimCount Then
    Frame := Frame + 1
  Else
    Dead;

       If Joueur=@Joueurs[Bas   ] Then Y := Y - VitesseTir * MoveCount
  Else If Joueur=@Joueurs[Haut  ] Then Y := Y + VitesseTir * MoveCount
  Else If Joueur=@Joueurs[Gauche] Then X := X + VitesseTir * MoveCount
  Else If Joueur=@Joueurs[Droite] Then X := X - VitesseTir * MoveCount;
end;

constructor TTirAnim.Create(const AParent: TSpriteEngine;
  const UnJoueur: PPlayerSprite);
begin
  inherited Create(AParent);
  Joueur:=UnJoueur;
  SetImage  ( ImageTirAnim, 3 );
  Visible:=True;
  CanDoCollisions:=False;
  CanDoMoving:=True;
  AnimActive := False;
end;

{  TTamaSprite  }

//Joue un son et se détruit
procedure TTamaSprite.Destruction;
begin
//PlaySoundRandom ( Sound_'Explosion',False); // Joue le son
  dead;
end;

// Gestion des collisions
procedure TTamaSprite.DoCollision ( const Sprite: TCollideSprite; var Done: Boolean);
begin
  if ( Sprite is TBrique) then
    begin
      Mode:=2;
      Compteur:=0;
    //  SetImage('Explosion2');
      W := Texture.Width;
      H := Texture.Height;
    end;
  Done := False;
end;
{
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
    AdDraw.Display.W := EcranX;
    AdDraw.Display.H := EcranY;
    AdDraw.Display.BitCount := BitCompte;
    AdDraw.Initialize;
  end else
  begin
    //  Window mode
    AdDraw.Finalize;

    if doFullScreen in AdDraw.Options then
      RestoreWindow;

    AdDraw.Options := AdDraw.Options - [doFullScreen];
    AdDraw.Display.W := EcranX;
    AdDraw.Display.H := EcranY;
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

procedure Quit;
begin
  // RU:     .
  // EN: Free allocated memory for sprites.
  SpriteEngine.Clear ;
  SpriteEngine.Free;
  SpriteEngine := nil;
end;

procedure Draw;
begin
  batch2d_Begin();
  // RU:        .
  // EN: Render all sprites contained in current sprite engine.
    //My code here
  SceneFlipping;

  if ShowStats Then
    begin
      pr2d_Rect( 0, 0, 256, 64, $000000, 200, PR2D_FILL );
      text_Draw( fntMain, 0, 0, 'FPS: ' + u_IntToStr( zgl_Get( RENDER_FPS ) ) );
      text_Draw( fntMain, 0, 20, 'Sprites: ' + u_IntToStr( SpriteEngine.Count ) );
      text_Draw( fntMain, 0, 40, 'Up/Down - Add/Delete Miku :)' );
    end;
  batch2d_End();
end;
// Rafraichissement d'écran
procedure TimerGame;
begin
  INC( zgl_time, 2 );

  if key_Press( K_ESCAPE ) Then zgl_Exit();
  key_ClearState();

  if Stop Then
    Exit;

  // RU:        .
  // EN: Process all sprites contained in current sprite engine.
  SpriteEngine.Proc();
  // RU:      .
  // EN: Delete all sprites if space was pressed.
  //  Fenetre:=FMenu;
  Draw;
End ;

// Rafraichissement d'écran
procedure SceneFlipping;

//var Rect : TAdRect ;
var i :integer;
begin
  if NextLevel then
    begin
      Score:=Score;
      Stop := True ;
//      DXTimer.Enabled:=False;
      EndSceneMain;
      StartSceneMain;
      Stop := False ;
//      DXTimer.Enabled:=True;
    end;
  if LostGame then
    begin
      dec(Vies);
      LostGame:=False;
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
           PlaySoundRandom ( Sound_Perdu,False);
           Score:=0;
           Fenetre:=FPresentation;
           EndSceneMain;
           StartSceneMain;
    //       Joue;
         end;
    End;
  SceneMain;
  mouse_ClearState;

end;

procedure FondImageDraw;
begin
  ssprite2d_Draw( FondImage,0,0 ,EcranX,EcranY,0);

end;
// Menu looping
procedure SceneMenu;
Var Compte :integer;

  procedure SauveControles;

  var lit_Compteur     : TInputType;
      li_Compteur     : Integer ;
      ValideControle : Array[TInputType] of Boolean;
  begin
    for lit_Compteur:=low ( TInputType ) to high ( TInputType ) do
     ValideControle[lit_Compteur]:=False;
    for li_Compteur := 1 to high ( ControleJoueur ) do
     if ControleJoueur[li_Compteur]<>itInactive then
       begin
         ValideControle[ControleJoueur[li_Compteur]]:=True;
       End;
    NbJoueurs:=0;
    for lit_Compteur:=low ( TInputType ) to high ( TInputType ) do
     if ValideControle[lit_Compteur] then inc(NbJoueurs);
    if NbJoueurs=0 then
      Begin
         for li_Compteur:=1 to high ( ControleJoueur ) do
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
    for i := 1 to high ( ControleJoueur ) do
      Begin
        Items[i-1].LeSprite.ChangeControle(ControleJoueur[i]);
      End;
  End;

  procedure MenuControle;
  const NbItems = 5;
  var i, ItemHeight, ItemWidth :integer;
      controle : String ;

  begin
    I:=0 ;
    with Items[I] do
      Begin
        Lesprite:=TItemMenu.Create(SpriteEngine, ImageSouris );
        ItemHeight := Round(LeSprite.H);
        ItemWidth  := Round(LeSprite.W);
        LAction:=AChangeBas;
        Lesprite.PlaceItem(EcranX / 2, EcranY / 2- (NbItems / 2) * ItemHeight, I);
      end;
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
   Curseur:=TCurseur.Create(SpriteEngine, File_Cursor );
  End;

  procedure EcritIniPlayers ;
  var li_Compteur : Integer ;
  Begin
    SauveControles;
    WriteIni(IniGame,IniPlayers,IntToStr(NbJoueurs));
  End;

  procedure EcritIniControle ;
  var li_Compteur : Integer ;
  Begin
    EcritIniPlayers ;
    for li_Compteur:= 1 to high ( ControleJoueur ) do
      WriteIni(IntToStr(NbJoueurs) + IniPlayer,IniAPlayer+IntToStr(li_Compteur),
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
    I:=0 ;
    with Items[I] do
     begin
       Lesprite:=TItemMenu.Create(SpriteEngine, ImageControle );
       LAction:=AControles;
       ItemHeight := Round(LeSprite.H);
       ItemWidth  := Round(LeSprite.W);
       Lesprite.PlaceItem( EcranX div 2 - ItemWidth / 2, EcranY div 2- (NbItems div 2) * ItemHeight, I );
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
   Curseur:=TCurseur.Create(SpriteEngine, File_Cursor );
  end;

begin
  If Compteur > 0 Then dec ( Compteur )
    Else Compteur := 0 ;
//  DXinput.UpDate;
  SpriteEngine.Move(TimerVitesse/2);
  FondImageDraw;
//  AdDraw.Scene.Draw
  SpriteEngine.Draw;
//  AdDraw.Surface.Canvas.Release;
  //if (Mainform.DXInput.Mouse.Buttons[0]) then
  if Curseur.Pousse
  and ( Compteur = 0 )
    then Curseur.Pousse:=False;

  if  ( Compteur = 0 )
  and (( not Curseur.Pousse and   (MouseClick [ 0 ]))
       or key_Press ( ToucheBoutonA [ 1 ]))
   then
     begin
     Compteur := 8 ;
     Curseur.pousse:=True;
     For Compte:=0 to MaxItems - 1 do with Items[Compte] do
      begin
      if (LeSprite <>nil) and (Curseur.X>LeSprite.X) and (Curseur.Y>LeSprite.Y)
      and (Curseur.X<LeSprite.W+LeSprite.X) and (Curseur.Y<LeSprite.H+LeSprite.Y) then
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
               Items[1].LeSprite.SetImage(IntToStr(NbJoueurs)+ImageJoueurs,6);
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
   AQuitter : zgl_Exit;
   end;
End;


procedure EffaceMenu;
var I : Integer ;
begin
  for I:= low ( Items ) to high ( Items ) do
    begin
      Items[I].LeSprite:=Nil;
    End;
 SubImages:= dir_Images + File_Background ;
 FondImage := LoadImage ( Presentation1 );
 SubImages:= dir_Images + Dir_Menus + Dir_Lang;
End;


procedure ChargeControles;
var I     :integer;
    lit_j     : TInputType ;
    Entree : string;
begin
  for I:=1 to high ( ControleJoueur ) do
   begin
     ControleJoueur[I]:=itMouse;
     ReadIni(Entree,IntToStr(NbJoueurs)+IniPlayer, IniAPlayer + IntToStr(I));
     if Entree<>'' then
      try
        for lit_j := low ( TInputType ) to high ( TInputType ) do
          if GetEnumName(TypeInfo(TInputType), LongInt( lit_j )) = Entree Then
            ControleJoueur[I]:=lit_j ;
      except
      End;
   End;
End;

procedure StartSceneMenu ;

var NombreJoueurs : String ;
    i             : Integer ;

Begin
 LoadImage(File_Cursor);
 EffaceMenu;
 InitClavier1 ( 1 );

 NombreJoueurs := '1' ;
 for i := 1 to high ( ControleJoueur ) do
   ControleJoueur[i]:=itMouse;
 ReadIni(NombreJoueurs,IniGame,IniPlayers);
 if NombreJoueurs<>'' then
  try
    NbJoueurs:=sTrToIntDef(NombreJoueurs,1);
  except
  End;
 if (NBJoueurs<1) or (NBJoueurs>4) then NBJoueurs:=1;
 ChargeControles;
 Compteur:=0;
 for I:=1 to MaxItems do Items[I].LeSprite:=Nil;
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


procedure MenuPrincipal;
const NbItems = 4;
var i, ItemHeight, ItemWidth :integer;

begin
  I:=0 ;
  with Items[I] do
   begin
     Lesprite:=TItemMenu.Create(SpriteEngine, 'Options');
     ItemHeight := Round(Lesprite.H);
     ItemWidth  := Round(Lesprite.W);
     Lesprite.PlaceItem( EcranX div 2 - ItemWidth / 2, EcranY div 2- (NbItems div 2) * ItemHeight, I );
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
 Curseur:=TCurseur.Create(SpriteEngine, File_Cursor );
End;

procedure ScenePresentation;
Begin
//AdDraw.Surface.Canvas.Release;
   case Compteur of

    1000  : Begin
             EraseTexture ( FondImage );
             FondImage := LoadImage( Presentation2 );
            End;

    end;
 FondImageDraw;
// FondImage.
inc(compteur);
if ( MouseClick [ 0 ] )
or ( key_Press( ToucheBoutonA [ 1 ] )) then
 Begin
   EndSceneMain;
   Fenetre:= FMenu;
   StartSceneMain;
 End;
End;

{
procedure LoadDir ( const Subdir : String );
var Files:TSearchRec;
    ls_FileName, ls_FileExt : String;
    IsFound : Boolean;
Begin
  SubImages:=SubDir;
  IsFound := FindFirst( dirRes + Subdir + '*',faArchive,Files)=0;
  try
    while IsFound do
      Begin
        ls_FileName := file_GetName ( Files.Name );
        ls_FileExt  := file_GetExtension( Files.Name );
        if LowerCase(ls_FileExt) = LittleImageExtension Then
          LoadImage(ls_FileName);
        IsFound:=FindNext(Files)=0;
      end;
  finally
    findclose(Files);
  end;
end;
 }
procedure ChargeStage ( const Niveau : Integer );
var Stage : Integer ;
Begin
  Stage := Niveau div 10 ;
  Stage := Stage mod 10 ;
  If    Stage < 1 Then Stage := 1 ;

  SubImages:=dir_Images+File_shoot;
  LoadImage(ImageTir);
  LoadImage( ImageTirAnim );
  SubImages:= Dir_Images +File_Items + IntToStr(NbLevel);
End;



// Démarrage du niveau      ---------------------------------

procedure StartSceneMain;

var

//  NoSprite
  i, j            :Integer;
  TailleX,TailleY: Integer;
  Cases : TCases;

procedure Charge;
begin
  NbBriques:=0;
  if FileExists(dirRes + dir_Niveaux + 'N'+IntToStr(NbLevel)+'.MUL') then
    ChargeFichier(dirRes + dir_Niveaux + 'N'+IntToStr(NbLevel)+'.MUL', TailleX, TailleY, Cases)
     else zgl_Exit;
end;

begin
  Stop := True ;
  //DXTimer.Enabled:=False;
  //  showmessage ('5');
  //  showmessage ('4');
  if Fenetre=FJeu then
   begin
    for i := 1 to high ( ControleJoueur ) do
      ControleJoueur [ i ] := itMouse;
    {  Main scene beginning  }
    inc(NbLevel);
    if NbLevel>Fin then NbLevel:=1;


    NbBalles:=0;
    NbBriques :=0;
    NbPalettes:=0;
    NextLevel:=False;
  //  ChargeFichier('NIVEAUX' + DirectorySeparator + 'NIVDEF.MUL');
    ChargeLUM(dirres + Dir_Niveaux + 'NIVEAUX.LUM',NbLevel, TailleX,TailleY, Cases);
    ChargeStage ( NbLevel );
    FondImage := LoadImage( ImageListFond );

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
    Joueurs[Bas]:= TPlayerBas.Create(SpriteEngine, True, ControleJoueur [ Bas ]) ;
    with Joueurs[Bas] do
      Begin
        Joueur := @Joueurs[Bas];
        BallePlus;
      End ;
    Joueurs[Haut] := TPlayerHaut.Create(SpriteEngine, True, ControleJoueur [ Haut ]);
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
    if NbBriques=0 then NextLevel:=True;

   End;
  //  showmessage ('3');
  If Fenetre=FPresentation then
   begin
    InitClavier1 ( 1 );
    Compteur:=0;
    SubImages:= Dir_Images+File_Background;
    FondImage := LoadImage( Presentation1 )
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
  //startscene
  Stop:= False;
end;



// Fin de l'animation destruction des sprites
procedure EndSceneMain;
begin
  Stop:=True;
    {  Main scene end  }
    //destruction des sprites
  SpriteEngine.Clear ;
  Finalize ( Presentes );
  Finalize ( Bricks   );
  Finalize ( Items    );
  Finalize ( Players  );
  Finalize ( Balls    );
end;

procedure Joue;
var i :integer;
begin
 Fenetre:=FJeu;
 EndSceneMain;
 NbLevel:=0;
 Score:=0;
 PointsVie:=0;
 ScoreAjouteVie:=ScoreVie;
 NbLevel:=0;
 Vies:=10;
 StartSceneMain;
 SceneMain;
//       DXTimer.Enabled:=True;
end;

// Scène d'animation
procedure SceneMain;
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
  If  ((( ControleJoueur [i] = itMouse    ) and ( MouseClick [ 0 ] ))
//  or  ((( ControleJoueur [i] = itJoystick1 ) or ( ControleJoueur [i] = itJoystick2 )) and (Joystick.Buttons [0] ))
  or  ((( ControleJoueur [i] = itKeyboard1  ) or ( ControleJoueur [i] = itKeyboard2  )) and key_Press( ToucheBoutonA [ i ] )))
  and ( pmErased in Joueurs[i].PlayerModifs     )
    Then
      Joueurs[i].PlayerModifs := Joueurs[i].PlayerModifs + [pmAfficher] ;//AnimOuvreBas ;

  FondImageDraw;
  SpriteEngine.Collide(BrickItems,Players);
  SpriteEngine.Collide(Balls     ,Players);
  SpriteEngine.Collide(Balls     ,Bricks );
  SpriteEngine.Collide(Balls     ,Presentes );
  SpriteEngine.Collide(Players   ,Presentes );
  SpriteEngine.Collide(Shots     ,Bricks );
  SpriteEngine.Move(TimerVitesse);
  SpriteEngine.Draw;
//  MAJ_objets3D ;
  AfficheTexte(LettresScore, IntToStr(Score),20,20);
  AfficheTexte(LettresVie  , IntToStr(Vies),20,40);
  AfficheTexte(LettresPVie , IntToStr(PointsVie),20,60);
//      Font.Size := 10;
  if Compteur<100 then
  text_Draw( fntMain, 10, 30, MessageEcran)
   else MessageEcran:='';
  inc(Compteur);
 end;
if Fenetre=FMenu then SceneMenu;
if Fenetre=FPresentation then ScenePresentation;
end;

// Démarre le 1er niveau
procedure AfficheTexte( const Lettres : TLettres ; const Texte : String; const X, Y : Integer);
var i : Integer ;
Begin
  For i := 1 To length ( Texte ) do
   if i <= high ( Lettres ) Then
    Begin
      Lettres [ i ].SetLettre ( Texte [ I ], False );
      Lettres [ i ].X := X + Lettres [ I ].W * ( i - 1 );
      Lettres [ i ].Y := Y ;
      Lettres [ i ].Visible := True;
    End
   Else
    Lettres [ i ].Visible := False;
End;


initialization
  Zip_extension:='.mbr';
end.

