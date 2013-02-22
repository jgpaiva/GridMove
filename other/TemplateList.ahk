#Singleinstance, Force
Gui, add, ListView, Grid gTemplateList MyListView r15 w400, Name|Number Of Groups
Loop, Grids\*.grid, 0, 1
{
   IniRead, Number, Grids\%A_LoopFileName%, Groups, NumberOfGroups
   LV_Add( "", A_LoopFileName, Number)
}
LV_ModifyCol(1) 
Gui, show
return

GuiEscape:
GuiClose:
  Exitapp

TemplateList:
  If A_GuiEvent = DoubleClick
    LV_GetText(Grid,A_EventInfo,1)
  If A_EventInfo = 0
    return
  msgbox,%grid%`,%A_EventInfo%
