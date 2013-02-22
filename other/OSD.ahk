OSDCreate()
  {
  global OSD
  Gui,4: +ToolWindow +AlwaysOnTop -Disabled -SysMenu -Caption
  Gui,4: Font,S13
  Gui,4: Add, Button, vOSD x0 y0 w100 h30 ,
  Gui,4: Color, EEAAEE
  Gui,4: Show, x0 y0 w0 h0 noactivate, OSD 
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
  Gui,4:Show, x%Xpos% y%Ypos% w100 h30 noactivate
  return
  }
  
OSDHide()
  {
  Gui,4:hide,
  }
