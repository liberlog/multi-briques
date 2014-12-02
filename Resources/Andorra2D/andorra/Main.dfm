object MainForm: TMainForm
  Left = 1
  Top = 26
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsNone
  Caption = 'Multi-Briques'
  ClientHeight = 420
  ClientWidth = 640
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu
  OldCreateOrder = True
  OnCreate = FormCreate
  OnKeyDown = AKeyDown
  OnKeyPress = AKeyPress
  OnMouseDown = AMouseDown
  OnMouseMove = AMouseMove
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 13
  object MainMenu: TMainMenu
    Left = 16
    Top = 16
    object GameMenu: TMenuItem
      Caption = '&Jeu'
      object GameStart: TMenuItem
        Caption = '&Recommencer'
        ShortCut = 113
        OnClick = GameStartClick
      end
      object GamePause: TMenuItem
        Caption = '&Pause'
        ShortCut = 114
        OnClick = GamePauseClick
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object GameExit: TMenuItem
        Caption = '&Quitter'
        OnClick = GameExitClick
      end
    end
    object OptionMenu: TMenuItem
      Caption = '&Options'
      object OptionFullScreen: TMenuItem
        Caption = 'Plein '#195#169'cran'
        ShortCut = 115
      end
      object N3: TMenuItem
        Caption = '-'
        GroupIndex = 1
      end
      object OptionSound: TMenuItem
        Caption = 'son'
        GroupIndex = 1
      end
      object N1: TMenuItem
        Caption = '-'
        GroupIndex = 1
      end
      object OptionShowFPS: TMenuItem
        Caption = 'Monter FPS'
        GroupIndex = 1
        OnClick = OptionShowFPSClick
      end
    end
  end
end
