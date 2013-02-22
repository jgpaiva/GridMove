Helper:
  If DropZoneModeFlag
    {
    Tooltip,%helper_1%
    return
    }
  CoordMode,Mouse,relative
  CoordMode,Tooltip,relative
  MouseGetPos, OldMouseX, OldMouseY, MouseWin,
  WinGetPos,,,winwidth,,ahk_id %mousewin%
  WinGetTitle,Wintitle,ahk_id %mousewin%
  WinGetClass,WinClass,ahk_id %mousewin%
  
  if winTitle contains GridMove V%ScriptVersion% by jgpaiva
    return

  If (OldMouseY <= CaptionSize AND OldMouseY > BorderSize + 1 
      AND oldmouseX > CaptionSize AND OldMouseX < TitleSize 
      AND WinTitle != "" AND WinClass != "Shell_TrayWnd" 
      AND TitleSize < WinWidth - 20 AND LButtonDrag)
    {
    Tooltip,%helper_2%
    return
    }
  If (OldMouseY <= CaptionSize AND OldMouseY > BorderSize + 1 
      AND WinTitle != "" AND WinClass != "Shell_TrayWnd" AND EdgeDrag)
    {
    KeyWait,LButton,D T0.01
    If errorlevel = 0
      {
      CoordMode, Mouse, Screen
      If (MouseY <= 2 OR MouseX <= 2 OR MouseY >= Monitor1Height -2 OR MouseX >= Monitor1Width -2)
        Tooltip,%helper_3%
      }
    else
      Tooltip,%helper_4%
    return
    }
    tooltip,
return


Helper2:
  CoordMode,Mouse,Relative
  hCurs := DllCall("LoadCursor","UInt",NULL,"Int",32649,"UInt")
  MouseGetPos, OldMouseX, OldMouseY, MouseWin,
  CoordMode,Mouse,screen
  MouseGetPos, MouseX, MouseY, ,
  If (OldMouseY <= CaptionSize AND OldMouseY > BorderSize + 1 
      AND oldmouseX > CaptionSize AND OldMouseX < TitleSize 
      AND WinTitle != "" AND WinClass != "Shell_TrayWnd" 
      AND TitleSize < WinWidth - 20 AND LButtonDrag)
    If not image
    {
    SplashImage , GridMove.bmp, B X%MouseX% y%MouseY%, , , ,
    Image := true
    }
    else
      return
  else
    {
    SplashImage, Off
    Image := false
    }
return
