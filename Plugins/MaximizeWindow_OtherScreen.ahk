;MaximizeWindow
;By jgpaiva
;January 2006
;Function: Maximizes windows on the screen where the mouse is
SetWinDelay,-1

#notrayicon

monitor = %1%

SysGet,Monitor,Monitor,%Monitor%

WinRestore,A

WinMove,A,,%MonitorLeft%,%MonitorTop%,%WinW%,%WinH%
WinMaximize,A
exitapp
