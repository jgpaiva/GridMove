;GridMove
;By jgpaiva
;date: May 2006
;function: Adjusts windows to a predefined or user-defined desktop grid.

  ;;options:
  MButtonDrag := True ;to be able to drag a window using the 3rd mouse button
  LButtonDrag:=True ;to be able to drag a window by its title
  EdgeDrag := True ;to be able to bring the grid up when dragging a window to the edge
  EdgeTime := 500
  ShowGroupsFlag := True ;configures the showing or not of the groups
  ShowNumbersFlag := True ;configures the showing or not of the numbers
  TitleSize := 100
  GridName = Grids/3 Part.grid
  GridOrder = 2 Part Vertical,3 Part,EdgeGrid,Dual Screen
  UseCommand := True
  CommandHotkey = #g
  UseFastMove := True
  FastMoveModifiers = #
  Exceptions = QuarkXPress,Winamp v1.x,Winamp PE,Winamp Gen,Winamp EQ,Shell_TrayWnd,32768,Progman,DV2ControlHost
  MButtonExceptions = inkscape.exe 
  MButtonTimeout = 0.3
  Transparency = 200
  SafeMode := True
  FastMoveMeta =
  SequentialMove := False
  DebugMode := False
  StartWithWindows := False
  DisableTitleButtonsDetection := False
  ColorTheme=orange
  Language=EN
  NoTrayIcon:=False
  FirstRun:=True

  ;Registered=quebec

  ;;end of options

  ScriptVersion = 1.19.72-win10fix

  ; Detect Windows 10
  if % substr(a_osversion, 1, 2) = 10
    Windows10:=True

  ; Hack WinMove for Windows 10
  WinSnap(WinTitle, X := "", Y := "", W := "", H := "") {
   If ((X . Y . W . H) = "") ;
      Return False
   WinGet, hWnd, ID, %WinTitle% ; taken from Coco's version
   If !(hWnd)
      Return False
   DL := DT := DR := DB := 0
   VarSetCapacity(RC, 16, 0)
   DllCall("GetWindowRect", "Ptr", hWnd, "Ptr", &RC)
   WL := NumGet(RC, 0, "Int"), WT := NumGet(RC, 4, "Int"), WR := NumGet(RC, 8, "Int"), WB := NumGet(RC, 12, "Int")
   If (DllCall("Dwmapi.dll\DwmGetWindowAttribute", "Ptr", hWnd, "UInt", 9, "Ptr", &RC, "UInt", 16) = 0) { ; S_OK = 0
      FL := NumGet(RC, 0, "Int"), FT := NumGet(RC, 4, "Int"), FR := NumGet(RC, 8, "Int"), FB := NumGet(RC, 12, "Int")
      DL := WL - FL, DT := WT - FT, DR := WR - FR, DB := WB - FB
   }
   X := X <> "" ? X + DL : WL, Y := Y <> "" ? Y + DT : WT
   W := W <> "" ? W - DL + DR : WR - WL, H := H <> "" ? H - DT + DB: WB - WT
   Return DllCall("MoveWindow", "Ptr", hWnd, "Int", X, "Int", Y, "Int", W, "Int", H, "UInt", 1)
  }

  MutexExists("GridMove_XB032")


  Sysget, CaptionSize,4  ;get the size of the caption
  Sysget, BorderSize, 46 ;get the size of the border
  CaptionSize += BorderSize

  TitleLeft := CaptionSize

  if DebugMode
    Traytip,GridMove,Reading INI,10

  ;goSub, showOptions
    
  
  GetScreenSize()       ;get the size of the monitors
  GetMonitorSizes()
  RectangleSize := 1
  ComputeEdgeRectangles()
  OSDcreate()
  GoSub,setlanguage
  GoSub, ReadIni

  AeroEnabled := loadAero()
  GoSub,setlanguage

  SetWinDelay, 0
  SetBatchLines, -1

  If 0 = 1
    GridName = %1%

  createTrayMenus()

  if DebugMode
    Traytip,GridMove,Reading the grid file,10

  GoSub, ApplyGrid

  Mutex := False
  GroupsShowing := False
  EdgeFlag := True
  MousePositionLock := False
  WM_ENTERSIZEMOVE = 0x231 
  WM_EXITSIZEMOVE = 0x232


  WindowY =
  WindowX =
  WindowWidth =
  WindowHeight=
  WindowXBuffer = 
  WindowYBuffer = 

  ;if DebugMode
  ;  Traytip,GridMove,Creating the grid,10

  ;GoSub,createGroups NOT NEEDED, GRID IS CREATED IN "APPLY GRID"

  if DebugMode
    Traytip,GridMove,Registering Hotkeys...,10

  ;hotkey definitions:
  If UseCommand
    Hotkey, %CommandHotkey%, Command

  If MButtonDrag
    Hotkey, MButton, MButtonMove

  If UseFastMove
    GoSub,DefineHotkeys

  if SequentialMove
  {
    Hotkey, %FastMoveModifiers%Right,MoveToNext
    Hotkey, %FastMoveModifiers%Left,MoveToPrevious
  }

  MPFlag := True 
  Settimer, MousePosition, 100
  ;Settimer, ReloadOnResolutionChange, 1000

  HotKey,RButton,NextGrid
  HotKey,RButton,off
  HotKey,Esc,cancel
  HotKey,Esc,off
  HotKey,F12,AddCurrentToIgnore
  HotKey,F11,AddCurrentToIgnoreCancel
  HotKey,F12,off
  HotKey,F11,off

#maxthreadsperhotkey,1
#singleinstance,force
#InstallMouseHook 
#InstallKeybdHook
#noenv

;  GoSub,TitleButtonInitialization

  if DebugMode
    Traytip,GridMove,Start process completed,10


  SetBatchLines, 20ms
return


MutexExists(name) {
    mutex := DllCall("CreateMutex", "UInt", 0, "UInt", 0, "str", name)
    last_error := A_LastError
;    DllCall("CloseHandle", "uint", mutex)
    return last_error == 183 ; ERROR_ALREADY_EXISTS
}


;*******************Init
createTrayMenus()
{
  global

  if DebugMode
    Traytip,GridMove,Creating the templates menu,10

  ;;tray menu:
  Menu,Tray, Add, %tray_help%, AboutHelp
  Menu,Tray, Default, %tray_help%
  Menu,Tray, Tip, GridMove V%ScriptVersion%
  Menu,Tray, Add, %tray_updates%, EnableAutoUpdate
  Menu,Tray, Add, %tray_ignore%, AddToIgnore
  
  if(Registered<>"quebec")
    Menu,Tray, Add, %tray_windows%, StartWithWindowsToggle

  if(Registered<>"quebec")
    if(startWithWindowsQ())
      Menu,Tray,Check, %tray_windows%
    else
      Menu,Tray,UnCheck, %tray_windows%
 
  createTemplatesMenu()
  Menu,Tray, Add, %tray_templates%, :templates_menu
  If(NoTrayIcon){
    msgbox,here
    menu, tray, NoIcon
  }else{
    IfExist %A_ScriptDir%\Images\gridmove.ico  
      Menu,Tray, Icon,%A_ScriptDir%\Images\gridmove.ico
  }
  Menu,Tray, NoStandard

  if DebugMode
    Traytip,GridMove,Creating the options tray menu,10

  createOptionsMenu()
  Menu,Tray, Add,%tray_options%, :options_menu
  createColorsMenu()
  Menu,Tray, Add, %tray_colors%, :colors_menu
  createHotkeysMenu()
  Menu,Tray, Add, %tray_hotkeys%, :hotkeys_menu
  Menu,Tray, Add, %tray_restart%, ReloadProgram
  Menu,Tray, Add, %tray_exit%, ExitProgram
}

createTemplatesMenu()
{
  global GridName
  global tray_refresh
  Loop,%A_ScriptDir%\Grids\*.grid
  {
    StringTrimRight,out_GridName2,A_LoopFileName,5
    Menu,templates_menu, add, %out_GridName2%,Template-Grids
  }
  Menu,templates_menu,add,,
  Menu,templates_menu, add,%tray_refresh%, RefreshTemplates
    
  stringgetpos,out_pos,gridname,\,R1
  if out_pos <= 0
    stringgetpos,out_pos,gridname,/,R1
  if out_pos <= 0
    return
  stringlen, len, gridname
  StringRight,out_GridName,gridname,% len - out_pos -1 
  StringTrimRight,out_GridName2,out_GridName,5
  IfExist %A_ScriptDir%\Grids\%out_GridName2%.grid
    menu,templates_menu,check,%out_GridName2%
}

createOptionsMenu()
{
  global
  Menu,options_menu, add, %tray_safemode%, Options_SafeMode
  Menu,options_menu, add, %tray_showgrid%, Options_ShowGrid
  Menu,options_menu, add, %tray_shownumbers%, Options_ShowNumbers
  Menu,options_menu, add, %tray_lbuttondrag%, Options_LButtonDrag
  Menu,options_menu, add, %tray_mbuttondrag%, Options_MButtonDrag
  Menu,options_menu, add, %tray_edgedrag%, Options_EdgeDrag
  Menu,options_menu, add, %tray_edgetime%, Options_EdgeTime
  Menu,options_menu, add, %tray_titlesize%, Options_TitleSize
  Menu,options_menu, add, %tray_gridorder%, Options_GridOrder
  If LButtonDrag
    Menu,options_menu,check, %tray_lbuttondrag%
  else
    Menu,options_menu,Disable, %tray_titlesize%
  If MButtonDrag
    Menu,options_menu,check, %tray_mbuttondrag%
  If EdgeDrag
    Menu,options_menu,check, %tray_edgedrag%
  else
    Menu,options_menu,Disable, %tray_edgetime%
  If ShowGroupsFlag
    Menu,options_menu, Check, %tray_showgrid%
  If ShowNumbersFlag
    Menu,options_menu, Check, %tray_shownumbers%
  If SafeMode
    Menu,options_menu, Check, %tray_safemode%
}

createColorsMenu()
{
  global tray_color_orange
  global tray_color_blue
  global tray_color_black
  global colortheme

  Menu,colors_menu, add, %tray_color_orange%, setColorTheme
  Menu,colors_menu, add, %tray_color_blue%, setColorTheme
  Menu,colors_menu, add, %tray_color_black%, setColorTheme

  if(colortheme="orange")
    Menu,colors_menu,check, %tray_color_orange%
  if(colortheme="blue")
    Menu,colors_menu,check, %tray_color_blue%
  if(colortheme="black")
    Menu,colors_menu,check, %tray_color_black%
}

setColorTheme:
  if(A_ThisMenuItem=tray_color_orange)
    colorTheme=orange
  if(A_ThisMenuItem=tray_color_blue)
    colorTheme=blue
  if(A_ThisMenuItem=tray_color_black)
    colorTheme=black

  gosub, writeini
  reload
  return

createHotkeysMenu()
{
  global
  Menu,hotkeys_menu, add, %tray_usecommand%, Hotkeys_UseCommand 
  Menu,hotkeys_menu, add, %tray_commandhotkey%, Hotkeys_CommandHotkey
  Menu,hotkeys_menu, add, %tray_fastmove%, Hotkeys_UseFastMove
  Menu,hotkeys_menu, add, %tray_fastmovemodifiers%, Hotkeys_FastMoveModifiers
  If UseCommand
    Menu,hotkeys_menu,check, %tray_usecommand%
  else
    Menu,hotkeys_menu,Disable, %tray_commandhotkey%,
  If UseFastMove
    Menu,hotkeys_menu,check, %tray_fastmove%
  else
    Menu,hotkeys_menu,Disable, %tray_fastmovemodifiers%
}

startWithWindowsQ()
{
  loop,%A_startup%\*.lnk
  {
    if (A_LoopFileName = "GridMove.lnk")
    {
      return true
    }
  }
  return false
}

;*******************Drop Zone Mode 

DropZoneMode:  
  DropZoneModeFlag := true
  gosub,showgroups
  Hotkey,RButton,on
  Hotkey,Esc,on
  Canceled := False
  CoordMode,Mouse,Screen
  hideGui2()
  loop
  {
    If Canceled
      {
      Critical, on
      Gui,2:Hide
      Hotkey,RButton,off
      Hotkey,Esc,off
      DropZoneModeFlag := false
      Critical, off
      return      
      }  
  
    GetKeyState,State,%hotkey%,P
    If State = U
        break
    
    MouseGetPos, MouseX, MouseY, window,
    flagLButton:=true
    Critical, on
    SetBatchLines, 10ms
    loop,%NGroups%
    {
      TriggerTop    := %A_Index%TriggerTop
      TriggerBottom := %A_Index%TriggerBottom
      TriggerRight  := %A_Index%TriggerRight
      TriggerLeft   := %A_Index%TriggerLeft

      If (MouseY >= TriggerTop AND MouseY <= TriggerBottom 
          AND MouseX <= TriggerRight AND MouseX >= TriggerLeft)
      {
        GetGrid(A_Index)

        If (GridTop = "AlwaysOnTop" OR GridTop = "Run")
        {
          GridTop := TriggerTop
          GridLeft := TriggerLeft
          GridWidth := TriggerRight - TriggerLeft
          GridHeight := TriggerBottom - TriggerTop
        }
        If (GridTop = "Maximize")
        {
          GridTop := GetMonitorTop(MouseX,MouseY)
          GridLeft := GetMonitorLeft(MouseX,MouseY)
          GridWidth := GetMonitorRight(MouseX,MouseY) - GetMonitorLeft(MouseX,MouseY)
          GridHeight := GetMonitorBottom(MouseX,MouseY) - GetMonitorTop(MouseX,MouseY)
        }         

        If not canceled
        {
          if(!AeroEnabled)
            WinMove,ahk_id %gui2hwnd%, ,%GridLeft%,%GridTop%,%GridWidth%,%GridHeight%
          else
          {
            left:=GridLeft + 3
            top:=GridTop + 3
            width:=GridWidth - 6
            height:=GridHeight - 6
            WinMove,ahk_id %gui2hwnd%, ,%Left%,%Top%,%Width%,%Height%
          }
        }
        flagLButton:=false
        break
      }
    }
    Critical, off
    if flagLButton
      hideGui2()
  }   
  DropZoneModeFlag := false 
  Gui,2:Hide
  Hotkey,RButton,off
  Hotkey,Esc,off
  GoSub,SnapWindow
  Gosub,hidegroups
return

hideGui2()
{
  global AeroEnabled
  if(!AeroEnabled)
    Gui,2: +ToolWindow +AlwaysOnTop -Disabled -SysMenu -Caption
  else
    Gui,2: +ToolWindow +AlwaysOnTop -Disabled -SysMenu
  Gui,2: Show, x-10000 y-10000 w0 h0 NoActivate,% A_SPACE
}
  
cancel:
  if not canceled
  {
    canceled := True 
    GoSub, HideGroups
    Gui,2:Hide
  }
return
  
;*******************Mbutton method

MButtonMove:
  CoordMode,Mouse,Screen
  MouseGetPos, OldMouseX, OldMouseY, Window,
  WinGetTitle,WinTitle,ahk_id %Window%
  WinGetClass,WinClass,ahk_id %Window%
  WinGetPos,WinLeft,WinTop,WinWidth,WinHeight,ahk_id%Window%
  WinGet,WinStyle,Style,ahk_id %Window%
  WinGet,WindowId,Id,ahk_id %Window%
  WinGet, WindowProcess , ProcessName, ahk_id %Window%

  if SafeMode
  {
    if not (WinStyle & 0x40000) ;0x40000 = WS_SIZEBOX = WS_THICKFRAME
    {
      sendinput,{MButton down}
      Keywait,mbutton
      sendinput,{MButton up}
      Return
    }
  }
  If Winclass in %Exceptions%
  {
    sendinput,{MButton down}
    Keywait,mbutton
    sendinput,{MButton up}
    Return
  }
  If WindowProcess in %MButtonExceptions%
  {
    sendinput,{MButton down}
    Keywait,mbutton
    sendinput,{MButton up}
    Return
  }
  KeyWait,MButton,T%MButtonTimeOut%
  if errorlevel = 0
  {
    sendinput,{MButton}
    return
  }

  Winactivate, ahk_id %window%
  Hotkey = MButton
  GoSub, DropZoneMode
  return

;**********************edge/lbutton method

MousePosition:
  Settimer, MousePosition,off

  if MousePositionLock
    return

  KeyWait, LButton,U
  KeyWait, LButton,D 

  SetBatchLines, -1

  CoordMode,Mouse,Relative
  MouseGetPos,OldMouseX,OldMouseY,MouseWin, MouseControl
  WinGetTitle,Wintitle,ahk_id %mousewin%
  WinGetClass,WinClass,ahk_id %mousewin%
  WinGetPos,WinLeft,WinTop,WinWidth,WinHeight,ahk_id%MouseWin%
  WinGet,WinStyle,Style,ahk_id %mousewin%
  WinGet,WindowId,Id,ahk_id %mousewin%
  
  If Winclass in %Exceptions%
  {
    Settimer, MousePosition,10
    Return
  }

  if SafeMode
    if not (WinStyle & 0x40000) ;0x40000 = WS_SIZEBOX = WS_THICKFRAME
    {
      Settimer, MousePosition,10
      Return
    }

  If (OldMouseY > CaptionSize OR OldMouseY <= BorderSize + 1 OR WinTitle = "" )
  {
    Settimer, MousePosition,10
    return
  }

  if(WinWidth > 3 * TitleSize)
  {
    If (TitleSize < WinWidth - 100 AND LButtonDrag
        AND OldmouseX > TitleLeft AND OldMouseX < TitleSize
  AND (MouseControl = "" OR DisableTitleButtonsDetection))
    {
      Hotkey = LButton
      sendinput {LButton up} 
      GoSub,DropZoneMode
      Settimer, MousePosition,10
      return
    }
  } 
  else 
  {
    If (LButtonDrag AND OldmouseX > TitleLeft 
        AND OldMouseX < TitleLeft + 20 AND WinWidth > 170
        AND (MouseControl = "" OR  DisableTitleButtonsDetection))
    {
      Hotkey = LButton
      sendinput {LButton up} 
      GoSub,DropZoneMode
      Settimer, MousePosition,10
      return
    }
  }

  if not EdgeDrag
  {
    settimer, MousePosition,10
    return
  }

  SetBatchLines, 10ms

  CoordMode,Mouse,Screen
  EdgeFlag := true
  SetTimer, EdgeMove, Off
  loop
  {
    MouseGetPos, MouseX, MouseY

    GetKeyState, State, LButton, P
    If (state = "U" or MousePositionLock)
    {
      SetTimer, EdgeMove, Off
      Settimer, MousePosition,10
      return
    }

    EdgeFlagFound := false
    loop,%RectangleCount%
    {
      if(mouseX >= EdgeRectangleXL%A_Index% && mouseX <= EdgeRectangleXR%A_Index% 
          && mouseY >= EdgeRectangleYT%A_Index% && mouseY <= EdgeRectangleYB%A_Index%)
      {
        EdgeFlagFound := true
        break
      }
    }

    if EdgeFlagFound
    {
      if EdgeFlag
      {
        settimer, EdgeMove, %EdgeTime%
        EdgeFlag := False
      }
    }
    else
    {
      SetTimer, EdgeMove, Off
      EdgeFlag := True
    }

    sleep,100
    ;eternal loop
  }
return

edgemove:
  SetTimer, EdgeMove, Off
  HotKey = LButton
  sendinput, {LButton up}
  MousePositionLock := true
  SetBatchLines, -1
  GoSub,DropZoneMode
  MousePositionLock := false
  EdgeFlag := True
  Settimer, MousePosition,10
return

;**********************Snap Window to Grid

SnapWindow:
  sendinput, {LButton up}
  CoordMode,Mouse,Screen
  Moved := False
  loop %NGroups%
  {
    triggerTop    := %A_Index%TriggerTop
    triggerBottom := %A_Index%TriggerBottom
    triggerRight  := %A_Index%TriggerRight
    triggerLeft   := %A_Index%TriggerLeft

    GridBottom :=0
    GridRight  :=0
    GridTop    :=0
    GridLeft   :=0

    
    If (MouseY >= triggerTop AND MouseY <= triggerBottom
        AND MouseX <= triggerRight AND MouseX >= triggerLeft)
    {
      GetGrid(A_Index)

      If GridTop = AlwaysOnTop
      {
        WinSet, AlwaysOnTop, Toggle,A 
        return
      }
      If GridTop = Maximize
      {
        winget,state,minmax,A
        if state = 1
          WinRestore,A
        else
          PostMessage, 0x112, 0xF030,,, A,
        return 
      }
      If GridTop = Run
      {
        Run,%GridLeft% ,%GridRight%
        return              
      }

      WinRestore,A
      Moved := True

      if ShouldUseSizeMoveMessage(WinClass)
        SendMessage WM_ENTERSIZEMOVE, , , ,ahk_id %windowid%

      if Windows10
        WinSnap("ahk_id" windowid, GridLeft,GridTop, GridWidth, GridHeight)
      else
        WinMove, ahk_id %windowid%, ,%GridLeft%,%GridTop%,%GridWidth%,%GridHeight%,

      if ShouldUseSizeMoveMessage(WinClass)
        SendMessage WM_EXITSIZEMOVE, , , ,ahk_id %windowid%
      break
    }  
  }
  If Moved
    StoreWindowState(WindowID,WinLeft,WinTop,WinWidth,WinHeight)
  gosub, hidegroups
return

GetGrid(number)
{
  global
  
  MouseGetPos, MouseX, MouseY, window,
  
  GridTop := %number%GridTop
  GridBottom := %number%GridBottom
  GridRight := %number%GridRight
  GridLeft := %number%GridLeft

  TriggerTop := %number%TriggerTop
  TriggerBottom := %number%TriggerBottom
  TriggerRight := %number%TriggerRight
  TriggerLeft := %number%TriggerLeft

  if GridTop in run,maximize,AlwaysOnTop
    return
  If GridTop = WindowHeight
  {
    MonitorBottom := GetMonitorBottom(MouseX, MouseY)
    MonitorTop := GetMonitorTop(MouseX, MouseY)
    GridTop := MouseY - 0.5 * WinHeight
    If (GridTop + WinHeight > MonitorBottom)
      GridTop := MonitorBottom - WinHeight
    If (GridTop < MonitorTop)
      GridTop := MonitorTop
    GridBottom := GridTop + WinHeight
  }
    
  If GridLeft = WindowWidth
  {
    MonitorRight := GetMonitorRight(MouseX, MouseY)
    MonitorLeft := GetMonitorLeft(MouseX, MouseY)
    GridLeft := MouseX - 0.5 * WinWidth
    If (GridLeft + WinWidth > MonitorRight)
      GridLeft := MonitorRight - WinWidth
    If (GridLeft < MonitorLeft)
      GridLeft := MonitorLeft
    GridRight := GridLeft + WinWidth       
  } 

  If GridTop = restore
  {
    data := GetWindowState(WindowID)
    If data   
    { 
      GridLeft   := WindowX
      GridRight  := WindowX + WindowWidth
      GridTop    := WindowY
      GridBottom := WindowY + WindowHeight 
    }
    else
    {
      GridLeft   := WinLeft
      GridRight  := WinLeft + WinWidth
      GridTop    := WinTop
      GridBottom := WinTop + WinHeight 
    }
  }

  if (GridTop = "Current")
    GridTop := WinTop
  else
    GridTop := round(GridTop)

  if (GridLeft = "Current")
    GridLeft := WinLeft
  else
    GridLeft := round(GridLeft)

  if (GridRight = "Current")
    GridRight := WinLeft + WinWidth
  else
    GridRight := round(GridRight)

  if(GridBottom = "Current")
    GridBottom := WinTop + WinHeight
  else
    GridBottom := round(GridBottom)

  GridWidth  := GridRight - GridLeft 
  GridHeight := GridBottom - GridTop
}


;*************************************************************************Groups

showgroups:
  if not ShowGroupsFlag
    return
  Gui,+ToolWindow +AlwaysOnTop -Disabled -SysMenu -Caption
  WinSet, AlwaysOnTop, On,ahk_id %GuiId%
  Gui,Show, X%ScreenLeft% Y%ScreenTop% W%ScreenWidth% H%ScreenHeight% noactivate,GridMove Drop Zone
  ;sleep,100
  GroupsShowing := True
  return

Hidegroups:
  Gui,hide
  return

setGuiColors()
{
  global shadowcolor
  global textcolor
  global guicolor
  global colortheme
  global horizontalGrid
  global verticalGrid
  if(colortheme="blue")
  {
    Gui, Font, s15 cBlue, Tahoma
    shadowcolor=555555
    textcolor=0000FF
    guicolor=0000EF
    horizontalGrid=Gridh_blue.bmp
    verticalGrid=Gridv_blue.bmp
  }else if(colortheme="black")
  {
    Gui, Font, s15 cBlack, Tahoma
    shadowcolor=333333
    textcolor=000000
    guicolor=333333
    horizontalGrid=Gridh_black.bmp
    verticalGrid=Gridv_black.bmp
  }else{
    Gui, Font, s15 cRed, Tahoma
    shadowcolor=000000
    textcolor=FFD300
    guicolor=EEAA99
    horizontalGrid=Gridh_orange.bmp
    verticalGrid=Gridv_orange.bmp
  }
}

creategroups:
  gui,destroy
  setGuiColors()
  loop,%NGroups%
  {
    TriggerTop    := %A_Index%TriggerTop - ScreenTop
    TriggerBottom := %A_Index%TriggerBottom - ScreenTop
    TriggerLeft   := %A_Index%TriggerLeft - ScreenLeft
    TriggerRight  := %A_Index%TriggerRight - ScreenLeft
    TriggerHeight := TriggerBottom - TriggerTop 
    TriggerWidth  := TriggerRight - TriggerLeft
    GridTop       := %A_Index%GridTop
    GridLeft      := %A_Index%GridLeft
    
    TextTop := %A_Index%TriggerTop - ScreenTop
    TextTop += Round((%A_Index%TriggerBottom - %A_Index%TriggerTop) / 2 )- 11
    TextLeft := %A_Index%TriggerLeft - ScreenLeft
    TextLeft += Round((%A_Index%TriggerRight - %A_Index%TriggerLeft) / 2) - 5
    RestoreLeft := TextLeft - 50
    tempTop := triggerTop - 1
    tempBottom := triggerBottom - 1
    tempLeft := triggerLeft - 1
    tempRight := triggerRight - 1
    tempHeight := tempBottom - tempTop +2
    tempWidth  := tempRight - tempLeft +2
    Gui, add, Picture, Y%tempTop%    X%tempLeft% W%tempWidth% H3 ,%A_ScriptDir%\Images\%horizontalGrid%
    Gui, add, Picture, Y%tempBottom% X%tempLeft% W%tempWidth% H3 ,%A_ScriptDir%\Images\%horizontalGrid%
    Gui, add, Picture, Y%tempTop% X%tempLeft%  W3 H%tempHeight% ,%A_ScriptDir%\Images\%verticalGrid%
    Gui, add, Picture, Y%tempTop% X%tempRight% W3 H%tempHeight% ,%A_ScriptDir%\Images\%verticalGrid%
    
    shadowleft := textleft + 1
    shadowtop := texttop + 1
    
    If ShowNumbersFlag
      If GridTop is number
        If GridLeft is number
          If A_Index < 10 
          {
            Gui, add, text, BackGroundTrans c%shadowcolor% X%ShadowLeft% Y%ShadowTop% ,%A_Index%
            Gui, add, text, BackGroundTrans c%textcolor% X%TextLeft% Y%TextTop% ,%A_Index%
          }
          else
          {
            Gui, add, text,% "X" ShadowLeft - 6 " Y" ShadowTop "c"shadowcolor  "BackGroundTrans" ,%A_Index%
            Gui, add, text,% "X" TextLeft - 6 " Y" TextTop "c"textcolor "BackGroundTrans" ,%A_Index%
          }


    RestoreLeftShadow := RestoreLeft + 1
    RestoreUndo := RestoreLeft + 20
    RestoreUndoShadow := RestoreUndo + 1

    If ShowNumbersFlag
    {
      If (GridTop = "WindowHeight" OR GridLeft = "WindowWidth")
      {
        Gui, add, text,c%shadowcolor% BackGroundTrans  X%ShadowLeft% Y%ShadowTop% ,%A_Index%
        Gui, add, text,c%textcolor% BackGroundTrans  X%TextLeft% Y%TextTop% ,%A_Index%
      }
      If Gridtop = Restore
      {
        Gui, add, text,c%shadowcolor% BackGroundTrans  X%RestoreUndoShadow% Y%ShadowTop% ,%A_Index%-Undo
        Gui, add, text,c%textcolor% BackGroundTrans  X%RestoreUndo% Y%TextTop% ,%A_Index%-Undo
      }
      If GridTop = Maximize 
      {
        Gui, add, text,c%shadowcolor% BackGroundTrans  X%RestoreLeftShadow% Y%ShadowTop% ,%A_Index%-Maximize
        Gui, add, text,c%textcolor% BackGroundTrans  X%RestoreLeft% Y%TextTop% ,%A_Index%-Maximize
      }
      If GridTop = AlwaysOnTop
      {
        Gui, add, text,c%shadowcolor% BackGroundTrans  X%RestoreLeftShadow% Y%ShadowTop% ,%A_Index%-On Top
        Gui, add, text,c%textcolor% BackGroundTrans  X%RestoreLeft% Y%TextTop% ,%A_Index%-On Top
      }
    }
    else
    {
      If Gridtop = Restore
      {
        Gui, add, text,c%shadowcolor% BackGroundTrans  X%RestoreUndoShadow% Y%ShadowTop% ,Undo
        Gui, add, text,c%textcolor% BackGroundTrans  X%RestoreUndo% Y%TextTop% ,Undo
      }
      If GridTop = Maximize 
      {
        Gui, add, text,c%shadowcolor% BackGroundTrans  X%RestoreLeftShadow% Y%ShadowTop% ,Maximize
        Gui, add, text,c%textcolor% BackGroundTrans  X%RestoreLeft% Y%TextTop% ,Maximize
      }
      If GridTop = AlwaysOnTop
      {
        Gui, add, text,c%shadowcolor% BackGroundTrans  X%RestoreLeftShadow% Y%ShadowTop% ,On Top
        Gui, add, text,c%textcolor% BackGroundTrans  X%RestoreLeft% Y%TextTop% ,On Top
      }
    }

    If Gridtop = Run
    {
      GridBottom := %A_Index%GridBottom
      GridLeft := %A_Index%GridLeft

      If ShowNumbersFlag
      {
        If (%A_Index%GridBottom != "")
        {
          Gui, add, text,c%shadowcolor% BackGroundTrans  X%RestoreLeftShadow% Y%ShadowTop% ,%A_Index%-%GridBottom%
          Gui, add, text,c%textcolor% BackGroundTrans  X%RestoreLeft% Y%TextTop% ,%A_Index%-%GridBottom%
        }
        else
        {
          Gui, add, text,c%shadowcolor% BackGroundTrans  X%RestoreLeftShadow% Y%ShadowTop% ,%A_Index%-%GridLeft%
          Gui, add, text,c%textcolor% BackGroundTrans  X%RestoreLeft% Y%TextTop% ,%A_Index%-%GridLeft%
        }
      }else
      {
        If (%A_Index%GridBottom != "")
        {
          Gui, add, text,c%shadowcolor% BackGroundTrans  X%RestoreLeftShadow% Y%ShadowTop% ,%GridBottom%
          Gui, add, text,c%textcolor% BackGroundTrans  X%RestoreLeft% Y%TextTop% ,%GridBottom%
        }
        else
        {
          Gui, add, text,c%shadowcolor% BackGroundTrans  X%RestoreLeftShadow% Y%ShadowTop% ,%GridLeft%
          Gui, add, text,c%textcolor% BackGroundTrans  X%RestoreLeft% Y%TextTop% ,%GridLeft%
        }
      }
    }
  }
  Gui, +AlwaysOnTop +ToolWindow -Caption +LastFound +E0x20
  Gui, Color, %guicolor%
  Gui, Margin,0,0

  Gui,show,x0 y0 w0 h0 noactivate,GridMove Drop Zone 0xba
  WinGet,GuiId,Id,GridMove Drop Zone 0xba
  WinSet, TransColor, %guicolor%, ahk_id %GuiId%

  Gui,2: +lastfound
  gui2hwnd:=WinExist() ;handle.
  if(!AeroEnabled)
  {
    WinSet, Transparent, %Transparency%,
    Gui,2: +ToolWindow +AlwaysOnTop -Disabled -SysMenu -Caption
    Gui,2: Margin,0,0
  }
  else 
  {
    Gui,2: Color, 0
    Aero_ChangeFrameAreaAll(gui2hwnd) ;call the Function
  }
  Gui,hide
return
 
;***********************************************************Aditional Functions

ExitProgram:
  ExitApp
return

ReloadProgram:
  Reload
return

RefreshTemplates:
  Menu,templates_menu,DeleteAll
  createTemplatesMenu()
return

Hotkeys_UseCommand:
  If UseCommand
      UseCommand := False
  else
      UseCommand := True
  GoSub,WriteIni
  Reload
return


Hotkeys_UseFastMove:
  If UseFastMove
      UseFastMove := False
  else
      UseFastMove := True
  GoSub,WriteIni
  Reload
return

Hotkeys_CommandHotkey:
  inputbox,input, %input_hotkey_title%,%input_hotkey%,,,,,,,,%CommandHotkey%
  if errorlevel <> 0
    return
  CommandHotkey := input
  GoSub, WriteIni
  reload
  return

Hotkeys_FastMoveModifiers:
  inputbox,input, %input_fastmove_title%,%input_fastmove%,,,,,,,,%FastMoveModifiers%
  if errorlevel <> 0
    return
  FastMoveModifiers := input
  GoSub, WriteIni
  Reload
  return


Options_GridOrder:
  inputbox,input, %input_gridorder_title%,%input_gridorder%,,,,,,,,%GridOrder%
  if errorlevel <> 0
    return
  GridOrder := input
  GoSub, WriteIni
return
  
Options_LButtonDrag:
  If LButtonDrag
  {
    Menu,options_menu,Uncheck, %tray_lbuttondrag%
    LButtonDrag := false
    Menu,options_menu,Disable, %tray_titlesize%,
  }
  else
  {
    Menu,options_menu,check, %tray_lbuttondrag%
    LButtonDrag := true
    Menu,options_menu,Enable, %tray_titlesize%,
  }
  GoSub, WriteIni
return

Options_mbuttonDrag:
  If mbuttonDrag
    mbuttonDrag := false
  else
    mbuttonDrag := true
  GoSub, WriteIni
  reload
return
  
Options_EdgeDrag:
  If EdgeDrag
  {
    EdgeDrag := false
    Menu,options_menu,Uncheck, %tray_edgedrag%
    Menu,options_menu,Disable, %tray_edgetime%
  }
  else
  {
    EdgeDrag := true
    Menu,options_menu,check, %tray_edgedrag%
    Menu,options_menu,Enable, %tray_edgetime%
  }
  GoSub, WriteIni
return  

Options_EdgeTime:
  inputbox,input, %input_edgetime_title%,%input_edgetime%,,,,,,,,%EdgeTime%
  if errorlevel <> 0
    return
  EdgeTime := input
  GoSub, WriteIni
return
  
Options_TitleSize:
  inputbox,input, %input_titlesize_title%,%input_titlesize%,,,,,,,,%TitleSize%
  if errorlevel <> 0
    return
  TitleSize := input
  GoSub, WriteIni
return  
  
Options_SafeMode:
  if SafeMode
  {
    SafeMode := False
    Menu,options_menu,Uncheck, %tray_safemode%
  }
  else
  {
    SafeMode := True
    Menu,options_menu,check, %tray_safemode%
  }
  GoSub, WriteIni
return

Options_ShowGrid:
  If ShowGroupsFlag
  {
    ShowGroupsFlag := false
    Menu,options_menu, Uncheck, %tray_showgrid%
    Menu,options_menu,Disable, %tray_shownumbers%
  }  
  else
  {
    ShowGroupsFlag := True
    Menu,options_menu, Check, %tray_show%
    Menu,options_menu,Enable, %tray_shownumbers%
  }
  GoSub, WriteIni
return 

Options_ShowNumbers:
  If ShowNumbersFlag
  {
    ShowNumbersFlag := false
    Menu,options_menu, Uncheck, %tray_shownumbers%
  }  
  else
  {
    ShowNumbersFlag := True
    Menu,options_menu, Check, %tray_shownumbers%
  }
  GoSub, WriteIni
  Reload
return 

Template-Grids:
  GridName = Grids/%A_ThisMenuItem%.grid
  GoSub, ApplyGrid
  Menu,templates_menu,DeleteAll
  createTemplatesMenu()
  Menu,templates_menu, check,%A_ThisMenuItem%
return

NextGrid:
  NextGridFlag := False
  NextGrid =
  Loop
  {
    StringLeft,out,GridOrder,1
    If out = ,
      StringTrimLeft,GridOrder,GridOrder,1
    else
      {
      StringRight,out,GridOrder,1
      If out <> ,
        GridOrder =%GridOrder%,
      break
      }
  }
  Loop, Parse,GridOrder,CSV 
  {
    If A_LoopField is space
      continue
      
    If NextGridFlag
    {
      NextGrid := A_LoopField
      AutoTrim,on
      SetEnv,NextGrid,%NextGrid%
      NextGridFlag:= False
    }
    If ("Grids/" . A_LoopField ".grid" = GridName)
      NextGridFlag := True
  }
  If (NextGridFlag OR NextGrid = "")
    {
    StringGetPos, CommaPosition, GridOrder, `,
    StringLeft, NextGrid, GridOrder, %CommaPosition% 
    }
  GridName = Grids/%NextGrid%.grid
  Critical,on
  GoSub,HideGroups
  Gui,2:Hide
  GoSub, ApplyGrid
  GoSub, ShowGroups
  SafeShow := False
  Critical,off
return

ApplyGrid:
  If (GridName = "4part")
    GridName = Grids/4-Part.grid 
  if (GridName = "edge")
    GridName = Grids/EdgeGrid.grid
  if (Gridname = "DualScreen")
    GridName = Grids/Dual-Screen.grid
  if (GridName = "2PartHorizontal")
    GridName = Grids/2 Part-Horizontal.grid
  if (Gridname = "2PartVertical")
    GridName = Grids/2 Part-Vertical.grid

  If (GridName = "3part")
    GoSub,Template-3part
  else
    GoSub, CreateGridFromFile
return

CreateGridFromFile:
  Menu,templates_menu,DeleteAll
  createTemplatesMenu()
  
  GoSub, HideGroups
  Gui,destroy
  Gui,2:destroy
  IniRead,NGroups,%A_ScriptDir%\%GridName%,Groups,NumberOfGroups,Error
  If (NGroups = "error")
    {
    MsgBox,%error_ngroups% %GridName%
    GoSub, Template-3Part
    return
    } 
  ErrorLevel := False
  loop,%NGroups%
  {
    if a_index = "0"
      continue
    TriggerTop    = %A_Index%TriggerTop
    TriggerBottom = %A_Index%TriggerBottom
    TriggerRight  = %A_Index%TriggerRight
    TriggerLeft   = %A_Index%TriggerLeft
      
    GridTop    = %A_Index%GridTop
    GridBottom = %A_Index%GridBottom
    GridRight  = %A_Index%GridRight
    GridLeft   = %A_Index%GridLeft
      
    IniRead,%TriggerTop%    ,%A_ScriptDir%\%GridName%,%A_Index%,TriggerTop,Error
    IniRead,%TriggerBottom% ,%A_ScriptDir%\%GridName%,%A_Index%,TriggerBottom,Error
    IniRead,%TriggerLeft%   ,%A_ScriptDir%\%GridName%,%A_Index%,TriggerLeft,Error
    IniRead,%TriggerRight%  ,%A_ScriptDir%\%GridName%,%A_Index%,TriggerRight,Error
               
    IniRead,%GridTop%       ,%A_ScriptDir%\%GridName%,%A_Index%,GridTop,Error
    IniRead,%GridBottom%    ,%A_ScriptDir%\%GridName%,%A_Index%,GridBottom,Error
    IniRead,%GridLeft%      ,%A_ScriptDir%\%GridName%,%A_Index%,GridLeft,Error
    IniRead,%GridRight%     ,%A_ScriptDir%\%GridName%,%A_Index%,GridRight,Error

    If (%TriggerTop%="Error" OR %TriggerBottom%="Error" 
        OR %TriggerLeft%="Error" OR %TriggerRight%="Error" )
      {
      ErrorCode := A_Index
      ErrorLevel := True
      break
      }

    if (%GridTop%="Error")
      %GridTop% := %TriggerTop%
    if (%GridBottom%="Error")
      %GridBottom% := %TriggerBottom%
    if (%GridLeft%="Error")
      %GridLeft% := %TriggerLeft%
    if (%GridRight%="Error")
      %GridRight% := %TriggerRight%
  }
  If (ErrorLevel != 0 or ErrorCode)
    {
    MsgBox,%error_grid_p1% (%error_grid_p2% %ErrorCode%)
    GoSub, Template-3Part
    GridName = 3Part
    return
    }
  evaluateGrid()
  GoSub, CreateGroups
  GoSub, WriteIni
return

GetScreenSize()
{
  Global 
  ScreenLeft   :=0
  ScreenTop    :=0
  ScreenRight  :=0
  ScreenBottom :=0
  Sysget,MonitorCount,MonitorCount
  
  Loop,%MonitorCount%
  {
    SysGet,monitor,Monitor,%A_Index%
    If (monitorLeft<ScreenLeft)
      ScreenLeft:=monitorLeft
    If (monitorTop<ScreenTop)
      ScreenTop:=monitorTop
    If (monitorRight>ScreenRight)
      ScreenRight:=monitorRight
    If (monitorBottom>ScreenBottom)
      ScreenBottom:=monitorBottom
  }
  ScreenWidth := ScreenRight - ScreenLeft
  ScreenHeight := ScreenBottom - ScreenTop 
  return
}

GetMonitorRight(MouseX, MouseY)
{
  SysGet,monitorcount,MonitorCount
  Loop,%monitorcount%
  {
    SysGet,monitor,Monitor,%A_Index%
    If (MouseX <= monitorRight AND MouseX >= monitorLeft 
        AND MouseY >= monitorTop AND MouseY <= monitorBottom)
      return %MonitorRight%
  }
  return error
}

GetMonitorBottom(MouseX, MouseY)
{
  SysGet,monitorcount,MonitorCount
  Loop,%monitorcount%
  {
    SysGet,monitor,Monitor,%A_Index%
    If (MouseX <= MonitorRight AND MouseX >= MonitorLeft 
        AND MouseY >= monitorTop AND MouseY <= monitorBottom)
      return, %MonitorBottom%
  }
  return error
}
  
GetMonitorLeft(MouseX, MouseY)
{
  SysGet,monitorcount,MonitorCount
  Loop,%monitorcount%
  {
    SysGet,monitor,Monitor,%A_Index%
    If (MouseX <= MonitorRight AND MouseX >= MonitorLeft 
        AND MouseY >= monitorTop AND MouseY <= monitorBottom)
      return, %MonitorLeft%
  }
  return error
}
  
GetMonitorTop(MouseX, MouseY)
{
  SysGet,monitorcount,MonitorCount
  Loop,%monitorcount%
  {
    SysGet,monitor,Monitor,%A_Index%
    If (MouseX <= MonitorRight AND MouseX >= MonitorLeft 
        AND MouseY >= monitorTop AND MouseY <= monitorBottom)
      return, %MonitorTop%
  }
  return error
}

StoreWindowState(WindowID,WindowX,WindowY,WindowWidth,WindowHeight)
{
  global WindowIdBuffer
  global WindowXBuffer
  global WindowYBuffer
  global WindowWidthBuffer
  global WindowHeightBuffer
  WindowIdBuffer = %WindowId%,%WindowIdBuffer%
  WindowXBuffer = %WindowX%,%WindowXBuffer%
  WindowYBuffer = %WindowY%,%WindowYBuffer%
  WindowWidthBuffer = %WindowWidth%,%WindowWidthBuffer%
  WindowHeightBuffer = %WindowHeight%,%WindowHeightBuffer%
  return
}
  
GetWindowState(WindowId)
{
  global
  StringSplit, WindowX     , WindowXBuffer     , `,,,
  StringSplit, WindowY     , WindowYBuffer     , `,,,
  StringSplit, WindowWidth , WindowWidthBuffer , `,,,
  StringSplit, WindowHeight, WindowHeightBuffer, `,,,
  loop, parse, WindowIdBuffer,CSV
  {
    if a_loopfield is space
      continue
    if (WindowId = A_LoopField) 
    {
      WindowX := WindowX%A_Index%
      WindowY := WindowY%A_Index%
      WindowWidth  := WindowWidth%A_Index%
      WindowHeight := WindowHeight%A_Index%
      return true
    }
  }
  return false  
}

evaluateGrid()
{
  global
  count := 0
  loop,%NGroups%
  {
    value := A_Index - count

    %value%TriggerTop    := eval(%A_Index%TriggerTop)
    %value%TriggerBottom := eval(%A_Index%TriggerBottom)
    %value%TriggerLeft   := eval(%A_Index%TriggerLeft)
    %value%TriggerRight  := eval(%A_Index%TriggerRight)
    
    If (%A_Index%GridTop = "Run")
    {
      %value%GridTop    := %A_Index%GridTop
      %value%GridBottom := %A_Index%GridBottom
      %value%GridLeft   := %A_Index%GridLeft
      %value%GridRight  := %A_Index%GridRight
      continue
    }


    if(%value%GridTop <> "")
      %value%GridTop    := eval(%A_Index%GridTop)
    if(%value%GridBottom <> "")
      %value%GridBottom := eval(%A_Index%GridBottom)
    if(%value%GridLeft <> "")
      %value%GridLeft   := eval(%A_Index%GridLeft)
    if(%value%GridRight <> "")
      %value%GridRight  := eval(%A_Index%GridRight)

    if (%value%TriggerTop = "error" OR %value%TriggerBottom = "Error" 
        OR %value%TriggerLeft = "error" OR %value%TriggerRight = "error" 
        OR %value%GridTop = "error" OR %value%GridBottom = "Error" 
        OR %value%GridLeft = "error" OR %value%GridRight = "error")
    {
      count += 1
      continue
    }
  }
  ngroups -= count
}

Getmonitorsizes()
{
  global 
  sysget,monitorCount,MonitorCount
  
  loop,%monitorCount%
  {
    sysget,monitorReal,Monitor,%A_Index%
    sysget,monitor,MonitorWorkArea,%A_Index%
    monitor%a_Index%Left   :=MonitorLeft
    monitor%a_Index%Bottom :=MonitorBottom
    monitor%a_Index%Right  :=MonitorRight
    monitor%a_Index%Top    :=MonitorTop
    monitor%a_Index%Width  :=MonitorRight - MonitorLeft
    monitor%a_Index%Height :=MonitorBottom - MonitorTop
    
    monitorreal%A_Index%Left   :=MonitorRealLeft
    monitorreal%A_Index%Bottom :=MonitorRealBottom
    monitorreal%A_Index%Right  :=MonitorRealRight
    monitorreal%A_Index%Top    :=MonitorRealTop
    monitorreal%A_Index%Width  :=MonitorRealRight - MonitorRealLeft
    monitorreal%A_Index%Height :=MonitorRealBottom - MonitorRealTop
  } 
  return
}

ComputeEdgeRectangles()
{
  global 

  sysget,MonitorCount,MonitorCount

  RectangleCount := 0

  loop,%MonitorCount%
  {
    sysget,Monitor,Monitor,%A_Index%

    MonitorRight := MonitorRight -1
    MonitorBottom := MonitorBottom -1

    ;Top
    RectangleCount := RectangleCount +1
    EdgeRectangleXL%RectangleCount% := MonitorLeft
    EdgeRectangleYT%RectangleCount% := MonitorTop

    EdgeRectangleXR%RectangleCount% := MonitorRight
    EdgeRectangleYB%RectangleCount% := MonitorTop + RectangleSize

    ;Bottom
    RectangleCount := RectangleCount +1
    EdgeRectangleXL%RectangleCount% := MonitorLeft
    EdgeRectangleYT%RectangleCount% := MonitorBottom - RectangleSize

    EdgeRectangleXR%RectangleCount% := MonitorRight
    EdgeRectangleYB%RectangleCount% := MonitorBottom

    ;Left
    RectangleCount := RectangleCount +1
    EdgeRectangleXL%RectangleCount% := MonitorLeft
    EdgeRectangleYT%RectangleCount% := MonitorTop

    EdgeRectangleXR%RectangleCount% := MonitorLeft + RectangleSize
    EdgeRectangleYB%RectangleCount% := MonitorBottom

    ;Right
    RectangleCount := RectangleCount +1
    EdgeRectangleXL%RectangleCount% := MonitorRight - RectangleSize
    EdgeRectangleYT%RectangleCount% := MonitorTop

    EdgeRectangleXR%RectangleCount% := MonitorRight
    EdgeRectangleYB%RectangleCount% := MonitorBottom
  }
}

;Determine if the window class should be treated like Putty
ShouldUseSizeMoveMessage(class)
{
	return class = "Putty" or class = "Pietty"
}

StartWithWindowsToggle:
  if(startWithWindowsQ())
  {
    FileDelete,%a_startup%\GridMove.lnk
    StartWithWindows := false
  }
  else
  {
    FileCreateShortcut,%A_ScriptDir%/GridMove.exe,%A_startup%\GridMove.lnk
    StartWithWindows := true
  }

  if(Registered<>"quebec")
    if(startwithwindows)
      Menu,Tray,Check,%tray_windows%
    else
      Menu,Tray,UnCheck,%tray_windows%
return

EnableAutoUpdate:
  ; Register with DcUpdater and check for updates. 
  ; When no updates are found nothing is displayed.
  ; make sure the dcuhelper.exe is in a subdirectory called 'dcuhelper' of this script's location.
  cmdParams = -ri    ;r = register app, i = check for updates
  uniqueID = GridMove ;anything allowed
  dcuHelperDir = %A_ScriptDir%
  IfExist, %dcuHelperDir%\dcuhelper.exe
  {
    OutputDebug, %A_Now%: %dcuHelperDir%\dcuhelper.exe %cmdParams% "%uniqueID%" "%A_ScriptDir%" . -shownew -nothingexit
    Run, %dcuHelperDir%\dcuhelper.exe %cmdParams% "%uniqueID%" "%A_ScriptDir%" Updater ,,Hide
  }
return

AddToIgnore:
  ;add selected window to ignore list
  Ignore_added := false
  coordmode,tooltip,screen
  coordmode,mouse,screen
  hotkey,F11,on
  hotkey,F12,on
  loop
  {
    mousegetpos,MouseX,MouseY
    if(Ignore_added)
      break
    tooltip,%tooltip_ignore%
    sleep,50
  }
  tooltip,
  hotkey,F11,off
  hotkey,F12,off
return

AddCurrentToIgnore:
  Ignore_added := true
  wingetclass,WinIgnoreClass,A
  if Exceptions contains %WinIgnoreClass%
  {
    IgnorePattern = ,?\s*%WinIgnoreClass%\s*
    Exceptions := RegExReplace(Exceptions,IgnorePattern)
    msgbox,%info_removed% %WinIgnoreClass% (%Errorlevel%)
  }
  else
  {
    Exceptions := Exceptions . "," . WinIgnoreClass
    msgbox,%info_added% %WinIgnoreClass%
  }
  Gosub,WriteIni
return

AddCurrentToIgnoreCancel:
  Ignore_added := true
return

loadAero()
{
  If(A_OSVersion!="WIN_VISTA" && A_OSVersion!="WIN_7")
    return false

  If(!Aero_StartUp()) ;start the Lib
    return false

  If(!Aero_IsEnabled()) ;Make sure that
    return false

  If(Aero_GetDWMTrans())
    return false

  return true
}
  
#include files.ahk
#include command.ahk
#include calc.ahk
#include helper.ahk
#Include Aero_lib.ahk
#include strings.ahk
