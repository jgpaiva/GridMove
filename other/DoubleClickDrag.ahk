;SCRIPTNAME!
;By jgpaiva
;date: 
;Function:

#SingleInstance, Force
#InstallMouseHook

CoordMode,Mouse,Screen
settimer, FirstStep, 100
return

FirstStep:
  GetKeyState, State, LButton, P
    If State = U
    {
      return
    }      
  
SecondStep:  
  KeyWait, LButton, T0.2
  If errorlevel = 1
    return
  
  KeyWait, LButton, D T0.2
  If errorlevel = 1
    return
  
  Send,{LButton up}
  
  MouseGetPos, OldMouseX, OldMouseY
  Loop
    {
    GetKeyState, State, LButton, P
    If State = U
      break
    MouseGetPos, MouseX, MouseY
    WinGetPos,WindowX, WindowY,,,A
    ;tooltip,% "MouseX: " . MouseX . " MouseY: " . MouseY . "`nWindowX: " . WindowX . " WindowY: " . WindowY . "`nmouseX - oldmouseX: " . mouseX - oldmouseX
    WinMove, A,, % WindowX + MouseX - OldMouseX, % WindowY + MouseY - OldMouseY
    OldMouseX := MouseX
    OldMouseY := MouseY
    }
  Tooltip,
  Goto, FirstStep
