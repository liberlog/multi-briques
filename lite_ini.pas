unit lite_ini;

{$mode Delphi}

{ IniFile for ZEN GL }
{ Author : Matthieu GIROUX }
{ www.liberlog.fr }

{$DEFINE ZENGL}
{$DEFINE STATIC}

interface

uses
  Classes,
{$IFDEF ZENGL}
  {$IFNDEF STATIC}
  zglHeader,
  {$ELSE}
  zgl_application,
  zgl_main,
  {$ENDIF}
{$ENDIF}
  SysUtils;

type
   TIniCoord = Record
                    Pos   ,
                    Count : LongInt;
                   end;

procedure ReadIni(var Installed:string; const Rep,Nom : String);
procedure WriteIni(const Rep,Nom,Install:string);
procedure UpdateIni;
procedure CreeIni;

var app_Name : String;
    FIniFileValues : String;
{$IFNDEF ZENGL}
    app_HomeDir : String = './' ;
{$ENDIF}

implementation


procedure CreeIni;
var myFile : TextFile ;
    Line,
    IniFileName : String ;
begin
  if (FIniFileValues = '') then
   begin
{$IFDEF ZENGL}
     zgl_GetSysDir;
{$ENDIF}
     IniFileName:=appHomeDir + app_Name + DirectorySeparator ;
     if not DirectoryExists(IniFileName) then
       CreateDir(IniFileName);
     IniFileName:= IniFileName + app_Name +'.ini';
     AssignFile(myFile,IniFileName);
     try
       if not FileExists(IniFileName) then
         Rewrite(myFile)
        Else
         Begin
          Reset(myFile);
          while not eof ( myfile ) do
            Begin
              Readln(myFile,Line);
              AppendStr(FIniFileValues,Line);
            end;
         End;

     finally
       CloseFile(myFile);
     end;
   End ;
End ;

procedure UpdateIni;
var myFile : TextFile ;
    IniFileName : String ;
begin
  if (FIniFileValues <> '') then
   begin
     IniFileName:= appHomeDir + app_Name + DirectorySeparator +app_Name +'.ini';
     if not FileExists(IniFileName) then
       Exit;
     AssignFile(myFile,IniFileName);
     try
       Rewrite(myFile);
       write(myFile,FIniFileValues);
     finally
       CloseFile(myFile);
     end;
   End ;
End ;

function GetSectionCoord ( Rep : String ):TIniCoord;
var li_i ,
    li_j : Integer;
    lpc_i :PChar ;
Begin
  Rep := '[' + trim ( Rep ) + ']' ;
  li_i := Pos(Rep,FIniFileValues);
  if li_i <= 0 then
   Begin
     if FIniFileValues <> '' Then
       AppendStr ( FIniFileValues, #13#10 );
     AppendStr ( FIniFileValues, Rep );
     li_i := length ( FIniFileValues );
     Result.Pos := length(FIniFileValues) + 1;
     Result.Count := 0;
   end
  Else
    Begin
      inc ( li_i, length ( Rep ));
      lpc_i := @FIniFileValues [ li_i ];
      while (( lpc_i^ = #13 ) or ( lpc_i^ = #10 ))
      and ( li_i < length ( FIniFileValues )) do
        Begin
          inc ( lpc_i );
          inc ( li_i );
        end;
      li_j := li_i;
      while li_j <= length ( FIniFileValues ) do
        Begin
          if lpc_i^ = '[' Then
             Break;
          inc ( lpc_i );
          inc ( li_j );
        end;
      Result.Pos := li_i;
      Result.Count := li_j-li_i+1;
   end;
end;

function GetSectionValues ( Rep : String ):String;
var SectionCoord : TIniCoord;
Begin
  SectionCoord := GetSectionCoord(Rep);
  if SectionCoord.Count > 0 Then
    Result := Copy ( FIniFileValues, SectionCoord.Pos, SectionCoord.Count )
   Else
    Result := '';
end;
function GetSectionCoordValues ( Rep : String ; var SectionCoord : TIniCoord):String;
Begin
  SectionCoord := GetSectionCoord(Rep);
  if SectionCoord.Count > 0 Then
    Result := Copy ( FIniFileValues, SectionCoord.Pos, SectionCoord.Count )
   Else
    Result := '';
end;
Function GetSectionValue ( var SectionValues : String ; Nom , Install : String ):TIniCoord;
var li_i ,
    li_j : Integer;
    lpc_i :PChar ;
Begin
  Install := Trim ( Install );
  Nom := Trim ( Nom ) + '=' ;
  li_i := AnsiPos(nom,FIniFileValues);
  if li_i > 0 Then
    Begin
      inc ( li_i, length ( nom )-1);
      lpc_i:=@SectionValues [ li_i ];
      li_j := li_i;
      while li_j <= length ( SectionValues ) do
        Begin
          if ( lpc_i^ = #13 )
          or ( lpc_i^ = #10 ) Then
             Break;
          inc ( lpc_i );
          inc ( li_j );
        end;
      Result.Pos   := li_i;
      Result.Count := li_j - li_i;
    end
   Else
    Begin
      AppendStr ( SectionValues, #13#10+ Nom + Install );
      Result.Pos   := 0;
      Result.Count := 0;
    end;
end;


procedure WriteStringToSection ( var SectionValues : String ; Nom , Install : String );
var InstallCoord : TIniCoord;
Begin
  InstallCoord := GetSectionValue ( SectionValues, nom, install );
  if InstallCoord.Pos > 0 Then
   if InstallCoord.count > 0 Then
      SectionValues:= LeftStr(SectionValues,InstallCoord.Pos)+Install+RightStr(SectionValues,InstallCoord.Pos+InstallCoord.Count)
    Else
      SectionValues:= LeftStr(SectionValues,InstallCoord.Pos)+Install
  Else
    AppendStr ( SectionValues, Nom + '=' +Install );
end;

procedure SetIniValues ( const SectionValues : String ; const OldSectionCoord : TIniCoord );
Begin
  if OldSectionCoord.Pos+OldSectionCoord.Count+1 < length ( FIniFileValues ) Then
    FIniFileValues:=Copy(FIniFileValues,1,OldSectionCoord.Pos-1)+SectionValues+Copy (FIniFileValues,OldSectionCoord.Pos+OldSectionCoord.Count+1, length ( FIniFileValues ) + OldSectionCoord.Pos+OldSectionCoord.Count)
   else
    if OldSectionCoord.Pos <= length ( FIniFileValues ) Then
     FIniFileValues:=Copy(FIniFileValues,1,OldSectionCoord.Pos-1)+SectionValues
   Else
     AppendStr ( FIniFileValues,SectionValues );

end;

procedure WriteIni(const Rep,Nom,Install:string);
var Section : String ;
    OldSectionCoord : TIniCoord;
begin
  Section := GetSectionCoordValues(Rep,OldSectionCoord);
  WriteStringToSection (Section, Nom,Install);
  SetIniValues ( Section, OldSectionCoord );
End;

procedure ReadIni(var Installed:string; const Rep,Nom : String);
var Section : String ;
    OldSectionCoord ,
    ValueCoord   : TIniCoord;
begin
  Section := GetSectionCoordValues(Rep,OldSectionCoord);
  ValueCoord := GetSectionValue (Section, Nom,Installed);
  If ValueCoord.Pos <= 0 Then
    Begin
      SetIniValues ( Section, OldSectionCoord );
    end;
end;


finalization
  updateIni;
end.

