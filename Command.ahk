;GridMove
;By jgpaiva
;date: May 2006
;function: Adjusts windows to a predefined or user-defined desktop grid.

Command:
  
  GoSub, ShowGroups

Drop_Command:
  Settimer,Drop_Command,off
  OSDwrite("- -")
  Input,FirstNumber,I L1 T10,{esc},1,2,3,4,5,6,7,8,9,0,m,r,n,M,v,a,e
  If ErrorLevel = Max
    {
    OSDwrite("| |")
    sleep,200
    GoSub,Command
    }
  If (ErrorLevel = "Timeout" OR ErrorLevel = "EndKey")
    {
    GoSub, Command_Hide
    return
    }
  
  If FirstNumber is not number
    {
    If (FirstNumber = "M")
      {
      winget,state,minmax,A
      if state = 1
        WinRestore,A
      else
        PostMessage, 0x112, 0xF030,,, A,
      }
    Else If (FirstNumber = "e")
    {
      GoSub, Command_Hide
      exitapp
      return
    }
    Else If (FirstNumber = "A")
    {
      GoSub, Command_Hide
      gosub,AboutHelp
      return
    }
    Else If (FirstNumber = "V")
      {
      GoSub, Command_Hide
      msgbox,NOT DONE!!
;      WinMove, A, ,%WinLeft%,%GridTop%, %WinWidth%,% GridBottom - GridTop,    
;      StoreWindowState(WindowId,WinLeft,WinTop,WinWidth,WinHeight)
      return
      }
    Else If (FirstNumber = "R")
      {
      GoSub, Command_Hide
      Reload
      }
    Else If FirstNumber = n
      {
      gosub, NextGrid
      gosub, command
      return
      }
    GoSub, Command_Hide
    return
    }
      
  If (NGroups < FirstNumber * 10)
    {
    If (FirstNumber = "0")
      {
      GoSub, Command_Hide
      WinMinimize,A
      return
      }
    GoSub, Command_Hide
    MoveToGrid(FirstNumber)
    return
    }

  Command2:
  output := FirstNumber . " -"
  OSDwrite(Output)
  Input,SecondNumber,I L1 T2,{esc}{enter},1,2,3,4,5,6,7,8,9,0
  If ErrorLevel = Max
    {
    OSDwrite("")
    sleep,500
    GoSub,Command2
    }

  If(ErrorLevel = "Timeout")
    {
    If (FirstNumber = "0")
      {
      GoSub, Command_Hide
      WinMinimize,A
      return
      }
    GoSub, Command_Hide
    MoveToGrid(FirstNumber)
    return
    }
  If(ErrorLevel = "EndKey:enter")
    {
    If (FirstNumber = "0")
      {
      GoSub, Command_Hide
      WinMinimize,A
      return
      }
    GoSub, Command_Hide
    MoveToGrid(FirstNumber)
    return
    }
  If(ErrorLevel = "EndKey:esc")
    {
    GoSub, Command_Hide
    return
    }
  
  If firstnumber = 0
    GridNumber := SecondNumber
  else
    GridNumber := FirstNumber . SecondNumber
  GoSub, Command_Hide
  MoveToGrid(GridNumber)
  return    

OSDCreate()
  {
  global OSD
  Gui,4: +ToolWindow +AlwaysOnTop -Disabled -SysMenu -Caption
  Gui,4: Font,S13
  Gui,4: Add, Button, vOSD x0 y0 w100 h30 ,
  Gui,4: Color, EEAAEE
  Gui,4: Show, x0 y0 w0 h0 noactivate, OSD 
  Gui,4: hide
  WinSet, TransColor, EEAAEE,OSD
  return
  }

OSDWrite(Value)
  {
  Global OSD
  Global Monitor1Width
  Global Monitor1Height
  Global Monitor1Top
  Global Monitor1Left
  XPos := Monitor1Left + Monitor1Width / 2 - 50
  YPos := Monitor1Top + Monitor1Height / 2 - 15
  GuiControl, 4:Text, OSD, %value%
  Gui,4: +ToolWindow +AlwaysOnTop -Disabled -SysMenu -Caption
  Gui,4:Show, x%Xpos% y%Ypos% w100 h30 noactivate
  return
  }
  
OSDHide()
  {
  Gui,4:hide,
  return
  }

MoveToGrid(GridToMove)
  {
  global
  triggerTop := %GridToMove%TriggerTop
  triggerBottom := %GridToMove%TriggerBottom
  triggerRight := %GridToMove%TriggerRight
  triggerLeft := %GridToMove%TriggerLeft
  GridBottom :=0
  GridRight  :=0
  GridTop    :=0
  GridLeft   :=0

  GridTop := %GridToMove%GridTop
  GridBottom := %GridToMove%GridBottom
  GridRight := %GridToMove%GridRight
  GridLeft := %GridToMove%GridLeft


  WinGetPos, WinLeft, WinTop, WinWidth, WinHeight,A
  WinGetClass,WinClass,A
  WinGet,WindowId,id,A
  WinGet,WinStyle,Style,A

  if SafeMode
    if not (WinStyle & 0x40000) ;0x40000 = WS_SIZEBOX = WS_THICKFRAME
      {
      Return
      }

  if (WinClass = "DV2ControlHost" OR Winclass = "Progman"
      OR Winclass = "Shell_TrayWnd")
    Return

  If Winclass in %Exceptions%
    Return

  If (GridTop = )
    return

  If (GridLeft = "WindowWidth" AND GridRight = "WindowWidth")
  {
    WinGetClass,WinClass,A

    if ShouldUseSizeMoveMessage(WinClass)
      SendMessage WM_ENTERSIZEMOVE, , , ,ahk_id %windowid%

    WinMove, A, ,%WinLeft%,%GridTop%, %WinWidth%,% GridBottom - GridTop,    

    if ShouldUseSizeMoveMessage(WinClass)
      SendMessage WM_EXITSIZEMOVE, , , ,ahk_id %windowid%
    StoreWindowState(WindowId,WinLeft,WinTop,WinWidth,WinHeight)
    return
  }
  If (GridTop = "WindowHeight" AND GridBottom = "WindowHeight")
  {
    WinGetClass,WinClass,A

    if ShouldUseSizeMoveMessage(WinClass)
      SendMessage WM_ENTERSIZEMOVE, , , ,ahk_id %windowid%

    WinMove, A, ,%GridLeft%,%WinTop%, % GridRight - GridLeft,%WinHeight%,    

    if ShouldUseSizeMoveMessage(WinClass)
      SendMessage WM_EXITSIZEMOVE, , , ,ahk_id %windowid%
    StoreWindowState(WindowId,WinLeft,WinTop,WinWidth,WinHeight)
    return
  }
  If (GridTop = "AlwaysOnTop")
  {
    WinSet, AlwaysOnTop, Toggle,A 
    return
  }
  If (GridTop =  "Maximize")
  {
    winget,state,minmax,A
    if state = 1
      WinRestore,A
    else
      PostMessage, 0x112, 0xF030,,, A,
    return 
  }
  If (GridTop = "Run")
  {
    Run,%GridLeft% ,%GridRight%
    return              
  }
  if (GridTop = "Restore")
  {
    data := GetWindowState(WindowId)
    If data   
      {
      GridLeft  := WindowX
      GridRight := WindowX + WindowWidth
      GridTop   := WindowY
      GridBottom:= WindowY + WindowHeight 
      WinRestore,A

      WinGetClass,WinClass,A

      if ShouldUseSizeMoveMessage(WinClass)
        SendMessage WM_ENTERSIZEMOVE, , , ,ahk_id %windowid%

      WinMove, A, ,%GridLeft%,%GridTop%,% GridRight - GridLeft,% GridBottom - GridTop

      if ShouldUseSizeMoveMessage(WinClass)
        SendMessage WM_EXITSIZEMOVE, , , ,ahk_id %windowid%

      StoreWindowState(WindowId,WinLeft,WinTop,WinWidth,WinHeight)
      }
    return
  }
  GridTop := round(GridTop)
  GridLeft := round(GridLeft)
  GridRight := round(GridRight)
  GridBottom := round(GridBottom)

  GridWidth  := GridRight - GridLeft 
  GridHeight := GridBottom - GridTop

  WinRestore,A

  WinGetClass,WinClass,A

  if ShouldUseSizeMoveMessage(WinClass)
    SendMessage WM_ENTERSIZEMOVE, , , ,ahk_id %windowid%

  if Windows10
    WinSnap("ahk_id" windowid, GridLeft,GridTop, GridWidth, GridHeight)
  else
    WinMove, A, ,%GridLeft%,%GridTop%,%GridWidth%,%GridHeight%

  if ShouldUseSizeMoveMessage(WinClass)
    SendMessage WM_EXITSIZEMOVE, , , ,ahk_id %windowid%

  StoreWindowState(WindowId,WinLeft,WinTop,WinWidth,WinHeight)
  return
  }

Command_Hide:
  critical,on
  Gosub, Cancel
  critical,off
  GoSub, HideGroups
  OSDHide()
  return

DefineHotkeys:
  loop,9
  {
     Hotkey, %FastMoveModifiers%%A_Index%, WinHotkeys
     Hotkey, %FastMoveModifiers%Numpad%A_Index%, WinHotkeys
  }
  Hotkey, %FastMoveModifiers%0, WinHotKey
  Hotkey, %FastMoveModifiers%Numpad0, WinHotkeys
  if FastMoveMeta <>
    Hotkey, %FastMoveModifiers%%FastMoveMeta%, WinHotkeysMeta
  return 

WinHotkeys:
  StringRight,Number,A_ThisHotkey,1
  MoveToGrid(Number)
  return
  
WinHotkeysMeta:
  GoSub, ShowGroups

  Settimer,Drop_Command,off
  OSDwrite("- -")
  Input,FirstNumber,I L1 T10,{esc},1,2,3,4,5,6,7,8,9,0,m,r,n,M,v,a,e
  If ErrorLevel = Max
    {
    OSDwrite("| |")
    sleep,200
    GoSub,WinHotkeysMeta
    }
  If (ErrorLevel = "Timeout" OR ErrorLevel = "EndKey")
    {
    GoSub, Command_Hide
    return
    }
  
  If FirstNumber is not number
    {
    If (FirstNumber = "M")
      {
      winget,state,minmax,A
      if state = 1
        WinRestore,A
      else
        PostMessage, 0x112, 0xF030,,, A,
      }
    Else If (FirstNumber = "e")
    {
      GoSub, Command_Hide
      exitapp
      return
    }
    Else If (FirstNumber = "A")
    {
      GoSub, Command_Hide
      gosub,AboutHelp
      return
    }
    Else If (FirstNumber = "V")
      {
      GoSub, Command_Hide
      msgbox,NOT DONE!!
;      WinMove, A, ,%WinLeft%,%GridTop%, %WinWidth%,% GridBottom - GridTop,    
;      StoreWindowState(WindowId,WinLeft,WinTop,WinWidth,WinHeight)
      return
      }
    Else If (FirstNumber = "R")
      {
      GoSub, Command_Hide
      Reload
      }
    Else If FirstNumber = n
      {
      gosub, NextGrid
      gosub, command
      return
      }
    GoSub, Command_Hide
    return
    }
      
  GoSub, Command_Hide
  FirstNumber := FirstNumber + 10
  MoveToGrid(FirstNumber)
  return

WinHotkey:
  MoveToGrid("10")
  return

MoveToPrevious:
  direction = back

MoveToNext:
  if direction <> back
    direction = forward

  WinGetPos,WinLeft,WinTop,WinWidth,WinHeight,A
  current = 0
  loop %NGroups%
  {
    triggerTop := %A_Index%TriggerTop
    triggerBottom := %A_Index%TriggerBottom
    triggerRight := %A_Index%TriggerRight
    triggerLeft := %A_Index%TriggerLeft

    GridToMove := A_index
    GridTop := %GridToMove%GridTop
    GridBottom := %GridToMove%GridBottom
    GridRight := %GridToMove%GridRight
    GridLeft := %GridToMove%GridLeft

    If GridTop = WindowHeight
      continue
    If GridLeft = WindowWidth
      continue
    If GridTop = AlwaysOnTop
      continue
    If GridTop = Maximize
      continue
    If GridTop = Run
      continue
    If GridTop = Restore
      continue

    GridTop := round(GridTop)
    GridBottom := round(GridBottom)
    GridRight := round(GridRight)
    GridLeft := round(GridLeft)

    GridHeight := GridBottom - GridTop
    GridWidth := GridRight - GridLeft

    if (WinTop = GridTop && WinLeft = GridLeft 
      && WinHeight = GridHeight && WinWidth = GridWidth)
    {
      current := a_index
      break
    }
    ;msgbox,% GridTop GridBottom Grid
  }
  if (current = 0 AND direction = "back")
    current := ngroups + 1

  if direction = forward
  {
    loop %NGroups%
    {
      if (a_index <= current)
        continue

      GridToMove := A_index
      GridTop := %GridToMove%GridTop
      GridBottom := %GridToMove%GridBottom
      GridRight := %GridToMove%GridRight
      GridLeft := %GridToMove%GridLeft

      If GridTop = WindowHeight
        continue
      If GridLeft = WindowWidth
        continue
      If GridTop = AlwaysOnTop
        continue
      If GridTop = Maximize
        continue
      If GridTop = Run
        continue
      If GridTop = Restore
        continue

      MoveToGrid(A_Index)
      direction =
      return
    }
    loop %NGroups%
    {
      GridToMove := A_index
      GridTop := %GridToMove%GridTop
      GridBottom := %GridToMove%GridBottom
      GridRight := %GridToMove%GridRight
      GridLeft := %GridToMove%GridLeft

      If GridTop = WindowHeight
        continue
      If GridLeft = WindowWidth
        continue
      If GridTop = AlwaysOnTop
        continue
      If GridTop = Maximize
        continue
      If GridTop = Run
        continue
      If GridTop = Restore
        continue

      MoveToGrid(A_Index)
      direction =
      return
    }
  }

  if direction = back
  {
    loop %NGroups%
    {
      if (Ngroups - a_index + 1 >= current)
        continue

      GridToMove := NGroups - A_index + 1
      GridTop := %GridToMove%GridTop
      GridBottom := %GridToMove%GridBottom
      GridRight := %GridToMove%GridRight
      GridLeft := %GridToMove%GridLeft

      If GridTop = WindowHeight
        continue
      If GridLeft = WindowWidth
        continue
      If GridTop = AlwaysOnTop
        continue
      If GridTop = Maximize
        continue
      If GridTop = Run
        continue
      If GridTop = Restore
        continue

      MoveToGrid(Ngroups - A_Index + 1)
      direction =
      return
    }
    loop %NGroups%
    {
      GridToMove := NGroups - A_index + 1
      GridTop := %GridToMove%GridTop
      GridBottom := %GridToMove%GridBottom
      GridRight := %GridToMove%GridRight
      GridLeft := %GridToMove%GridLeft

      If GridTop = WindowHeight
        continue
      If GridLeft = WindowWidth
        continue
      If GridTop = AlwaysOnTop
        continue
      If GridTop = Maximize
        continue
      If GridTop = Run
        continue
      If GridTop = Restore
        continue

      MoveToGrid(Ngroups - A_Index + 1)
      direction =
      return
    }
  }
  direction =
  return
