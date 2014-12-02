unit zengl_sprite_image;

interface

////////////////////////////////////////////////////////////////////////////////
// Andorra 2D and Delphi X Compatibility
// auteur : Matthieu GIROUX
// LGPL license
// www.liberlog.fr
////////////////////////////////////////////////////////////////////////////////

{$DEFINE STATIC}

{$I ../zengl/src/zgl_config.cfg}


uses
  zglSpriteEngine,
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
  {$IFDEF USE_ZIP}
  zgl_lib_zip,
  {$ENDIF}
  zgl_math_2d,
  zgl_utils,
  zgl_collision_2d,
  zgl_sound
  {$ENDIF}
  ;

var ArrayTextures : Array of Record
                               FileName : String;
                               Texture  : zglPTexture;
                             end;



function FindTexture ( const FileName : String ) : zglPTexture;
procedure EraseTexture ( const ATexture : zglPTexture );
function PlaySoundRandom ( const Sound : zglPSound; const Loop : Boolean = FALSE): Integer;
function LoadImage(const LittleFileName: String ): zglPTexture;
function LoadSoundFromRes ( const FileName : String; const Count : Integer ): zglPSound;
procedure SpriteToCircle (const ASprite: zglCSprite2D; var Circle : zglTCircle );
procedure SpriteToRectangle (const ASprite: zglCSprite2D; var Rectangle : zglTRect );

type
   TPoint = Record
             X, Y : Double;
            end;

  { TSprite }
  TSprite = class ( zglCSprite2D )
     public
       Z         : Integer;
       CanDoMoving ,
       Visible     : Boolean;
       constructor CreateSprite ( const _Manager : zglCSEngine2D; var _ID : Integer ); virtual;
       constructor Create ( const _Manager : zglCSEngine2D ); overload; virtual;
       procedure SetImage ( const FileName : String ; const ImagesCountX : Word = 1; const ImagesCountY : Word = 1 ); virtual;
       procedure InvalidateImage; virtual;
       procedure Dead; virtual;
       procedure OnDraw; override;
       procedure Move(MoveCount: Double); virtual;
       procedure DoMove(MoveCount: Double); virtual;
     End;

  { TCollideSprite }
  ETestCollision = function ( const Sprite1, Sprite2 : TSprite ): Boolean of object;
  TCollideSprite = class;
  TCollisionArray = Array of TCollideSprite;
  TAnimSpecial = ( asNone, asLoop, asDead );

  TCollideSprite = class ( TSprite )
     private
     protected
       CollideID : Integer;
       function TestCollisionCircleCircle(const Circle1, Circle2: TSprite  ): Boolean; virtual;
       function TestCircle1InCircle2(const Circle1, Circle2: TSprite  ): Boolean; virtual;
       function TestCircle2InCircle1(const Circle1, Circle2: TSprite  ): Boolean; virtual;
       function TestCollisionCircleRectangle(const Circle, Rectangle: TSprite ): Boolean; virtual;
       function TestCircleInRectangle(const Circle, Rectangle: TSprite ): Boolean; virtual;
       function TestCollisionRectangleCircle(const Rectangle, Circle: TSprite ): Boolean; virtual;
       function TestRectangleInCircle(const Rectangle, Circle: TSprite ): Boolean; virtual;
       function TestRectangle1InRectangle2(const Rectangle1, Rectangle2: TSprite): Boolean; virtual;
       function TestCollisionRectangleRectangle(const Rectangle1, Rectangle2: TSprite): Boolean; virtual;
       function TestRectangle2InRectangle1(const Rectangle1, Rectangle2: TSprite): Boolean; virtual;
     public
       CanDoCollisions : Boolean;
       TestCollision : ETestCollision;
       procedure RegisterCollideArray ( var CollideArray : TCollisionArray ); virtual;
       procedure UnRegisterCollideArray ( var CollideArray : TCollisionArray ); virtual;
       constructor CreateSprite ( const _Manager : zglCSEngine2D; var _ID : Integer ); override;
       procedure BeforeCollision(const Sprite: TCollideSprite); virtual;
       procedure Collision(const Sprite: TCollideSprite; var Done: Boolean); virtual;
       procedure DoCollision(const Sprite: TCollideSprite; var Done: Boolean); virtual;
     End;

  { TAnimatedSprite }

  TAnimatedSprite = class ( TCollideSprite )
     public
       AnimStart ,
       AnimStop  ,
       AnimCount : Integer;
       AnimActive  : Boolean;
       AnimSpecial : TAnimSpecial;
       constructor CreateSprite ( const _Manager : zglCSEngine2D; var _ID : Integer ); override;
       procedure SetImage ( const FileName : String ; const ImagesCountX : Word = 1; const ImagesCountY : Word = 1 ); override;
       procedure Move(MoveCount: Double); override;
     End;

  { TSpriteEngine }

  TSpriteEngine = class ( zglCSEngine2D )
  private
     protected
     public
       procedure AddSprite ( const Sprite : TSprite ); virtual; overload;
       procedure Collide(const ArraySprites1, ArraySprites2 : TCollisionArray ); virtual;
       procedure Clear; virtual;
       procedure Move(MoveCount: Double); virtual;
     End;
var
  SubImages       : UTF8String='';
  SubDirSounds       : UTF8String='';
  TexturesExtension  : String='.png';
  dirRes    : UTF8String = '.'+DirectorySeparator;
  TransparentColor ,
  Flags            : Integer ;
  CurrentSpriteID : Integer;
  ZipImages : Boolean =
  {$IFDEF USE_ZIP}
  True;
  Zip_extension : String = '.zip';
  ZipFileHandle : zglTFile = 0;
  ZipFileName : UTF8String;
  ZipList : zglTFileList;
  {$ELSE}
  False;
  {$ENDIF}

implementation

uses SysUtils;
{ Fonctions }

procedure SpriteToCircle (const ASprite: zglCSprite2D; var Circle : zglTCircle );
begin
  Circle.cX := ASprite.X + ASprite.w  / 2 ;
  Circle.cY := ASprite.Y + ASprite.H / 2 ;
  Circle.Radius:=ASprite.W/2;
end;

procedure SpriteToRectangle (const ASprite: zglCSprite2D; var Rectangle : zglTRect );
begin
  Rectangle.X := ASprite.X ;
  Rectangle.W := ASprite.w  ;
  Rectangle.Y := ASprite.Y ;
  Rectangle.H := ASprite.H ;
end;

function TCollideSprite.TestCollisionCircleCircle(const Circle1,
  Circle2: TSprite): Boolean;
var SomeCircle1, SomeCircle2 : zglTCircle ;
begin
  SpriteToCircle (Circle1, SomeCircle1 );
  SpriteToCircle (Circle2, SomeCircle2);

  Result := col2d_Circle( SomeCircle1, SomeCircle2 );
end;

function TCollideSprite.TestCircle1InCircle2(const Circle1, Circle2: TSprite
  ): Boolean;
var SomeCircle1, SomeCircle2 : zglTCircle ;
begin
  SomeCircle1.cX := Circle1.X + Circle1.w  / 2 ;
  SomeCircle1.cY := Circle1.Y + Circle1.H / 2 ;
  SomeCircle1.Radius:=Circle1.W/2;
  SomeCircle2.cX := Circle2.X + Circle2.w  / 2 ;
  SomeCircle2.cY := Circle2.Y + Circle2.H / 2 ;
  SomeCircle2.Radius:=Circle2.W/2;

  Result := col2d_CircleInCircle( SomeCircle1, SomeCircle2 );
end;

function TCollideSprite.TestCircle2InCircle1(const Circle1, Circle2: TSprite
  ): Boolean;
begin
  Result := TestCircle1InCircle2(Circle2,Circle1);
end;

function TCollideSprite.TestCollisionCircleRectangle(const Circle,Rectangle: TSprite): Boolean;
Begin
  Result := TestCollisionRectangleCircle(Rectangle,Circle);
end;

function TCollideSprite.TestCircleInRectangle(const Circle, Rectangle: TSprite
  ): Boolean;
begin

end;

function TCollideSprite.TestCollisionRectangleCircle(const Rectangle,Circle: TSprite): Boolean;
var SomeCircle : zglTCircle ;
    SomeRectangle : zglTRect ;
begin
  SpriteToCircle (Circle, SomeCircle );
  SpriteToRectangle(Rectangle, SomeRectangle );
    // Convert circle center to box coordinates.

  Result := col2d_RectVsCircle( SomeRectangle, SomeCircle );
end;

function TCollideSprite.TestRectangleInCircle(const Rectangle, Circle: TSprite
  ): Boolean;
var SomeCircle : zglTCircle ;
    SomeRectangle : zglTRect ;
begin
  SpriteToCircle (Circle, SomeCircle );
  SpriteToRectangle(Rectangle, SomeRectangle );
    // Convert circle center to box coordinates.

  Result := col2d_RectInCircle( SomeRectangle, SomeCircle );
end;

function TCollideSprite.TestRectangle1InRectangle2(const Rectangle1,
  Rectangle2: TSprite): Boolean;
var
    SomeRectangle1,SomeRectangle2 : zglTRect ;
begin
  SpriteToRectangle(Rectangle1, SomeRectangle1 );
  SpriteToRectangle(Rectangle2, SomeRectangle2 );

  // Convert circle center to box coordinates.
  Result := col2d_RectInRect( SomeRectangle1, SomeRectangle2 );

end;

function TCollideSprite.TestRectangle2InRectangle1(const Rectangle1,
  Rectangle2: TSprite): Boolean;
begin
  Result := TestRectangle1InRectangle2(Rectangle2,Rectangle1);
end;
function TCollideSprite.TestCollisionRectangleRectangle(const Rectangle1,
  Rectangle2: TSprite): Boolean;
var SomeRectangle1, SomeRectangle2 : zglTRect ;
begin
  SpriteToRectangle(Rectangle1, SomeRectangle1 );
  SpriteToRectangle(Rectangle2, SomeRectangle2 );

  // Convert circle center to box coordinates.
  Result := col2d_Rect( SomeRectangle1, SomeRectangle2 );
end;


function LoadSoundFromRes ( const FileName : String; const Count : Integer ): zglPSound;
Begin
  Result := snd_LoadFromFile( dirRes + SubDirSounds + FileName, Count );
end;

function AddTexture (const FileName, LittleFileName: String ): zglPTexture;
Begin
  if file_Exists (FileName) Then
    Begin
      Result := tex_LoadFromFile( FileName, TransparentColor, Flags );
//      writeln ( FileName + ' '+ LittleFileName +' ' + IntToStr ( high ( ArrayTextures )) );
      SetLength(ArrayTextures, high ( ArrayTextures ) + 2);
//      writeln ( FileName + ' '+ LittleFileName +' ' + IntToStr ( high ( ArrayTextures )) );
      ArrayTextures [ high ( ArrayTextures ) ].FileName := LittleFileName;
      ArrayTextures [ high ( ArrayTextures ) ].Texture  := Result;
    end
  Else
    Begin
      writeln ( 'Texture ' + FileName + ' does not exist ! Quiting...' );
      zgl_Exit;
      Abort;
    End;
end;

function LoadImage(const LittleFileName: String ): zglPTexture;
var Extension : String ;
  {$IFDEF USE_ZIP}
    AList : zglTFileList;
    i:Integer;
    AFile : String;
  {$ENDIF}
begin
  if LittleFileName = ''
   Then
    Exit;
  Result := FindTexture ( LittleFileName );
  if Result = nil Then
    Begin
      Extension := TexturesExtension;
      {$IFDEF USE_ZIP}
      if FileExists(dirRes+SubImages+Zip_extension) Then
       Begin
        if ( ZipFileHandle = 0 )
        or ( ZipFileName <> dirRes+SubImages+Zip_extension) Then
         Begin
          if ( ZipFileHandle <> 0 ) Then
           Begin
             file_CloseArchive;
           end;
          ZipFileName := dirRes+SubImages+Zip_extension;
          file_OpenArchive(ZipFileName);
          file_Find('.',AList,False);
          with AList do
          for i:=0 to Count-1 do
            Begin
              AFile := Items [ i ];
              if AFile = LittleFileName+Extension Then
               Result:= AddTexture ( AFile, copy ( AFile, 1, Length(AFile)-length( ExtractFileExt( AFile ))+1))
              Else
               AddTexture ( AFile, Items [ i ] );
            end;
         end;
         Result := AddTexture ( LittleFileName+Extension, LittleFileName );
        End
       Else
        Begin
          if ( ZipFileHandle <> 0 ) Then
           Begin
             file_CloseArchive;
             ZipFileHandle := 0;
           end;
      {$ELSE}
        Begin
      {$ENDIF}
         Result := AddTexture ( dirRes+SubImages+DirectorySeparator+LittleFileName+Extension, LittleFileName );
        end;
    end;

end;


function PlaySoundRandom ( const Sound : zglPSound; const Loop : Boolean = FALSE): Integer;
Begin
  Result := snd_Play( Sound, Loop, random ( 9 ), random ( 9 ), random ( 9 ));
end;

{ TSprite }
constructor TSprite.CreateSprite(const _Manager: zglCSEngine2D; var _ID: Integer);
begin
  Manager := _Manager;
  Layer   := 0;
  X       := 0;
  Y       := 0;
  Angle   := 0;
  Frame   := 1;
  Alpha   := 255;
  FxFlags := FX_BLEND;
  ID := _ID;
  CanDoMoving    := False;
  W := 0;
  H := 0 ;
  Visible := True;
  (Manager as TSpriteEngine ).AddSprite ( Self );
end;

constructor TSprite.Create(const _Manager: zglCSEngine2D);
begin
  CreateSprite(_Manager, CurrentSpriteID);
  inc(CurrentSpriteID);
end;

procedure TSprite.SetImage(const FileName: String; const ImagesCountX : Word = 1; const ImagesCountY : Word = 1 );
var Extension : String ;
begin
  Texture := LoadImage( FileName );
  tex_SetFrameSize( Texture, Texture.Width div ImagesCountX, Texture.Height div ImagesCountY );
  W := Texture.Width  div ImagesCountX;
  H := Texture.Height div ImagesCountY;
  Layer   := Z;
  Angle   := 0;
  Frame   := 1;
  Alpha   := 255;
  FxFlags := FX_BLEND;
end;

procedure TSprite.InvalidateImage;
begin
  tex_SetFrameSize( Texture, Round(W), Round(H) );

end;

procedure TSprite.Dead;
begin
  Kill:=true;
end;

procedure TSprite.OnDraw;
begin
  If Visible Then
    inherited OnDraw;
end;

procedure TSprite.Move(MoveCount: Double);
begin
  DoMove(MoveCount);
end;

procedure TSprite.DoMove(MoveCount: Double);
begin

end;


{ TSpriteEngine }

procedure TSpriteEngine.Collide(const ArraySprites1, ArraySprites2 : TCollisionArray );
var I, j : Integer ;
    Done : Boolean;
begin
  for i := 0 to high ( ArraySprites1 ) do
    if  assigned ( ArraySprites1 [ I ]) Then
      for j := 0 to high ( ArraySprites2 ) do
        if assigned ( ArraySprites2 [ j ])
         Then
           Begin
             ArraySprites1 [ I ].Collision(ArraySprites2 [ j ], Done );
           End;
end;

procedure TSpriteEngine.Clear;
var i : Integer;
begin
  inherited ClearAll;
  CurrentSpriteID := 0;
  for i := 0 to High(ArrayTextures) do
   if ArrayTextures [ i ].FileName > '' Then
    tex_Del( ArrayTextures [ i ].Texture );
  Finalize ( ArrayTextures );
end;

procedure TSpriteEngine.Move(MoveCount: Double);
var I : Integer ;
begin
  for i := 0 to FCount - 1 do
   if FList [ I ] is TSprite
    Then
      Begin
        (FList [ I ] as TSprite).Move(MoveCount);
      end;
end;

procedure TSpriteEngine.AddSprite(const Sprite: TSprite);
  var
    id : Integer;
begin
  id := AddSprite;

  FList[ id ] := Sprite;
  FList[ id ].Manager := Self;
  FList[ id ].ID      := id;
end;



{ TCollideSprite }

procedure TCollideSprite.RegisterCollideArray(
  var CollideArray: TCollisionArray);
var li_i : Integer;
begin
  CollideID := -1;
  for li_i := 0 to high ( CollideArray ) do
   if CollideArray [ li_i ] = nil Then
    Begin
      CollideID := li_i ;
      Break;
    end;
  if CollideID = -1 then
    Begin
      Setlength ( CollideArray, high ( CollideArray ) + 2 );
      CollideID := high ( CollideArray );
    end;
  CollideArray [ CollideID ] := Self;

end;

procedure TCollideSprite.UnRegisterCollideArray(
  var CollideArray: TCollisionArray);
begin
  if CollideID >= 0 Then
    CollideArray [ CollideID ] := nil;

end;

constructor TCollideSprite.CreateSprite(const _Manager: zglCSEngine2D;
  var _ID: Integer);
begin
  inherited CreateSprite(_Manager, _ID);
  CanDoCollisions:=True;
  CollideID:=-1;
  TestCollision:=TestCollisionRectangleRectangle;
end;

procedure TCollideSprite.BeforeCollision(const Sprite: TCollideSprite);
begin

end;

procedure TCollideSprite.Collision(const Sprite: TCollideSprite; var Done: Boolean);
begin
  if CanDoCollisions
  and Sprite.CanDoCollisions Then
    Begin
      BeforeCollision(Sprite);
      if TestCollision ( Self, Sprite ) Then
        Begin
          DoCollision ( Sprite, Done);
          Sprite.DoCollision ( Self, Done);
        end;
    end;
end;

procedure TCollideSprite.DoCollision(const Sprite: TCollideSprite;
  var Done: Boolean);
begin

end;

{ TAnimatedSprite }

constructor TAnimatedSprite.CreateSprite(const _Manager: zglCSEngine2D;
  var _ID: Integer);
begin
  inherited CreateSprite(_Manager, _ID);
  AnimActive := False;
  AnimSpecial:=asNone;
end;

procedure TAnimatedSprite.SetImage(const FileName: String;
  const ImagesCountX: Word; const ImagesCountY: Word);

begin
  inherited SetImage(FileName, ImagesCountX, ImagesCountY);
  AnimCount:= ImagesCountX * ImagesCountY;
end;

procedure TAnimatedSprite.Move(MoveCount: Double);
begin
  If AnimActive Then
    if Round ( Frame ) < AnimCount Then
      Frame := Frame + 1
    Else
     case AnimSpecial of
       asDead : Dead;
       asLoop : Frame := 1;
     end;
  Inherited;
end;

function FindTexture ( const FileName : String ) : zglPTexture;
var li_i : Integer;
Begin
  Result := nil;
  if FileName > '' Then
    for li_i := 0 to high ( ArrayTextures ) do
      if ArrayTextures [ li_i ].FileName = FileName Then
        Begin
          Result := ArrayTextures [ li_i ].Texture;
          Break;
        end;
end;

procedure EraseTexture ( const ATexture : zglPTexture );
var li_i : Integer;
Begin
  for li_i := 0 to high ( ArrayTextures ) do
    if ArrayTextures [ li_i ].Texture = ATexture Then
      Begin
        tex_Del(ArrayTextures [ li_i ].Texture);
        ArrayTextures [ li_i ].FileName:='';
        Break;
      end;

end;

initialization
  {$IFDEF DARWIN}
  dirRes := zgl_Get( APP_DIRECTORY ) + DirectorySeparator;
  {$ENDIF}
  CurrentSpriteID := 0 ;
end.

