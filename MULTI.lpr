program Multi;

{$I definitions.inc}
{$IFNDEF FPC}
{$R MULTI.res}
{$ENDIF}

uses
  Main in 'Main.pas' {MainForm},
  lite_ini,
  SysUtils,
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
  zgl_sound
  {$ENDIF}
  ;


//-----------------------------------------------------------------------------
// Name: Initialisation
// Création de la fenêtre de jeu
//-----------------------------------------------------------------------------

{$IFDEF WINDOWS}{$R MULTI.rc}{$ENDIF}

Begin
  {$IFNDEF STATIC}
  zglLoad( libZenGL );
  {$ENDIF}

  randomize();

  app_Name:='multi-bricks';

  CreeIni;

  timer_Add( @TimerGame, 16 );

  zgl_Reg( SYS_LOAD, @Init );
  zgl_Reg( SYS_DRAW, @Draw );
  zgl_Reg( SYS_EXIT, @Quit );

  // RU: Т.к. модуль сохранен в кодировке UTF-8 и в нем используются строковые переменные
  // следует указать использование этой кодировки.
  // EN: Enable using of UTF-8, because this unit saved in UTF-8 encoding and here used
  // string variables.
//  zgl_Enable( APP_USE_UTF8 );

  wnd_SetCaption( 'Multi-Bricks' );

  wnd_ShowCursor( TRUE );

  scr_SetOptions( EcranX, EcranY, REFRESH_DEFAULT, True, True );

  zgl_Init();
  SetHeapTraceOutput (ExtractFilePath (ParamStr (0)) + 'heaptrclog.trc');
End.
