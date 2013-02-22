;GridCreator
;By jgpaiva
;date: September 2006
;function: Visually Create Grids for GridMove 

#singleInstance,force
#notrayicon

ScriptName = GridCreator
ScriptVersion = 1.0

Trigger:=true
Current := 1
LastAdded := 1

FileSelectFile,FileName,s 16,%a_workingdir%\new_grid.grid,Select file to write,Grid Files(*.grid)
if errorlevel <> 0 
  exitapp

FileAppend,,%filename%
Gui,add,Button,Section vLeft gLeft,<
Gui,add,text,xp+35 yp+4 vElement,Element 1
Gui,add,Button,xp+60 ys vRight gRight, >
Gui,add,Button,xs Section gInstructions,Instructions
Gui,add,Button,ys gSave,Save
Gui,add,Text,vText_top   xs,Top: 10244 , 100`%
Gui,add,Text,vText_left  xs,Left: 10244 , 100`%
Gui,add,Text,vText_Right xs,Right: 10244 , 100`%
Gui,add,Text,vText_Bottom xs,Bottom: 10244 , 100`%

Gui,show,% "x" A_ScreenWidth / 2 + 30,Creator

Gui,2:+owner1

Gui,2:Default
Gui,+Resize +toolwindow
Gui, Add, Button,Default vbutton gAddPercentage w90 h20,&Add Trigger %Current% 
Gui,show,% "x" A_ScreenWidth / 2 - 90 " autosize toolwindow", %ScriptName% v%scriptVersion%

Gui,1:Default
GuiControl,Disable,Left
GuiControl,Disable,Right

Changed := false
GuiControl,Disable,Save

loop
{
  wingetpos,WinX,WinY,WinWidth,WinHeight, %ScriptName% v%scriptVersion%
  GetMonitorNumber()
  MonitorWidth := MonitorRight - MonitorLeft
  MonitorHeight:= MonitorBottom - MonitorTop
  GuiControl,,Text_Top,% "Top: "WinY ", " Round((WinY - MonitorTop) /MonitorHeight * 100) "%"
  GuiControl,,Text_Left,% "Left: "WinX ", " Round((WinX - MonitorLeft) /MonitorWidth * 100) "%"
  GuiControl,,Text_Right,% "Right: " WinX + WinWidth ", " Round((WinX + WinWidth - MonitorLeft) /MonitorWidth * 100) "%" 
  GuiControl,,Text_Bottom,% "Bottom: " WinY + WinHeight ", " Round((WinY + WinHeight - MonitorTop) /MonitorHeight * 100) "%"
  sleep,200
}
return

2GuiSize:
  GuiControl,Move,button,% "x" . A_GuiWidth/2 - 45. " Y" . A_GuiHeight /2 - 10
  return
  
2GuiClose:
2GuiEscape:
GuiClose:
GuiEscape:
  If changed
  {
    msgbox,3,save?,would you like to save?
    ifmsgbox yes
    {
      gosub,save
      exitapp
    }
    ifmsgbox no
      exitapp
    return
  }
  exitapp

Instructions:
  return
    
Save:
  IfExist %FileName%
    FileDelete,%FileName%
  lastadded --
  IniWrite,%LastAdded%,%FileName%,Groups,NumberOfGroups
  Loop,%LastAdded%
  {
    TriggerTop     :=(%A_Index%TriggerTop   )
    TriggerLeft    :=(%A_Index%TriggerLeft  )
    TriggerRight   :=(%A_Index%TriggerRight )
    TriggerBottom  :=(%A_Index%TriggerBottom)
    GridTop        :=(%A_Index%GridTop      )
    GridLeft       :=(%A_Index%GridLeft     )
    GridRight      :=(%A_Index%GridRight    )
    GridBottom     :=(%A_Index%GridBottom   )
    IniWrite,%TriggerTop%    ,%FileName%,%A_Index%,TriggerTop
    IniWrite,%TriggerLeft%   ,%FileName%,%A_Index%,TriggerLeft
    IniWrite,%TriggerRight%  ,%FileName%,%A_Index%,TriggerRight
    IniWrite,%TriggerBottom% ,%FileName%,%A_Index%,TriggerBottom
    IniWrite,%GridTop%       ,%FileName%,%A_Index%,GridTop
    IniWrite,%GridLeft%      ,%FileName%,%A_Index%,GridLeft
    IniWrite,%GridRight%     ,%FileName%,%A_Index%,GridRight
    IniWrite,%GridBottom%    ,%FileName%,%A_Index%,GridBottom
  }
  Gui,1:Default
  Changed := false
  GuiControl,Disable,Save
  return

Left:
  Current -= 1
  Gui,2:Default
  GuiControl, Text, Button, &Add Grid %Current% 
  Trigger := True
  Update()
  return

Right:
  Current += 1
  Gui,2:Default
  GuiControl, Text, Button, &Add Grid %Current% 
  Trigger := True
  Update()
  return

AddPercentage:
  wingetpos,WinX,WinY,WinWidth,WinHeight, %ScriptName% v%scriptVersion%
  MonitorNumber := GetMonitorNumber()
  MonitorWidth := MonitorRight - MonitorLeft
  MonitorHeight:= MonitorBottom - MonitorTop
  X :=  (WinX - MonitorLeft)/MonitorWidth
  Y :=  (WinY - MonitorTop)/MonitorHeight
  Right := (WinX + WinWidth - MonitorLeft)/MonitorWidth
  Bottom:= (WinY + WinHeight - MonitorTop)/MonitorHeight
  WindowTop = [Monitor%MonitorNumber%Top] + %Y% * [Monitor%MonitorNumber%Height]
  WindowLeft = [Monitor%MonitorNumber%Left] + %X% * [Monitor%MonitorNumber%Width]
  WindowRight = [Monitor%MonitorNumber%Left] + %Right% * [Monitor%MonitorNumber%Width]
  WindowBottom = [Monitor%MonitorNumber%Top] + %Bottom% * [Monitor%MonitorNumber%Height]
  If trigger
    {
      %Current%TriggerTop   := WindowTop
      %Current%TriggerLeft  := WindowLeft  
      %Current%TriggerRight := WindowRight
      %Current%TriggerBottom:= WindowBottom
      Trigger := false
      Gui,2:Default
      GuiControl, Text, Button, &Add Grid %Current% 
      Gui,1:Default
      Changed := True
      GuiControl,Enable,Save
    }
  else
  {
      %Current%GridTop   := WindowTop   
      %Current%GridLeft  := WindowLeft  
      %Current%GridRight := WindowRight 
      %Current%GridBottom:= WindowBottom
      Trigger := True
      Current += 1
      If Current > %LastAdded%
        LastAdded += 1
      Update()
      Gui,2:Default
      GuiControl, Text, Button, &Add Trigger %Current% 
      Gui,1:Default
      Changed := True
      GuiControl,Enable,Save
  }
  return

GetMonitorNumber(){
  global Monitor
  global WinX
  global WinY
  SysGet,MonitorCount,MonitorCount
  Loop,%MonitorCount%
    {
      SysGet,MonitorR,Monitor,%A_Index%
      If (WinX < MonitorRRight AND WinX >= MonitorRLeft AND WinY >= MonitorRTop AND WinY < MonitorRBottom)
        {
          Number := a_index
          break
        }
    }
  Sysget,Monitor,MonitorWorkArea,%Number%
  return %Number%
}

Update()
{
  global
  Gui,1:Default
  if Current > 1
    GuiControl,enable,Left
  else
    GuiControl,Disable,Left
  If Current < %LastAdded%
    GuiControl,enable,Right
  else
    GuiControl,disable,Right
  GuiControl,text,Element,Element%Current%
}
