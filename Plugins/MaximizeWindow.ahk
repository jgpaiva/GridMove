;MaximizeWindow
;By jgpaiva
;January 2006
;Function: Maximizes windows on the screen where the mouse is
SetWinDelay,-1

#notrayicon
CoordMode,Mouse,Screen
MouseGetPos,MouseX,MouseY
WinGetPos,WinX,WinY,WinW,WinH,A
MouseMonitor := GetMonitorNumber(MouseX,MouseY)
If (MouseMonitor = "Error")
{
  msgbox,error retreiving monitor number
  exitapp
}
SysGet,Monitor,Monitor,%MouseMonitor%
;MsgBox,Mouse Position: %MouseX% %MouseY%`nMouse Monitor: %mousemonitor%`nMoving to %Winx% %winy%
WinRestore,A
WinMove,A,,%MonitorLeft%,%MonitorTop%,%WinW%,%WinH%
WinMaximize,A
exitapp


GetMonitorNumber(X, Y)
  {
  SysGet,monitorcount,MonitorCount
  Loop,%monitorcount%
    {
      SysGet,monitor,Monitor,%A_Index%
      If (X <= MonitorRight AND X >= MonitorLeft 
          AND Y >= monitorTop AND Y <= monitorBottom)
        return, %a_index%
    }
  return error
  }
