#notrayicon
If 0 != 1
  return
if 1 = store
{
  WinGetClass,WindowClass,A
  WinGetPos,WindowLeft,WindowTop,WindowWidth,WindowHeight,A
  IfNotExist,%a_scriptname%.ini
    FileAppend,,%a_scriptname%.ini
  IniWrite,%WindowLeft%,%A_ScriptName%.ini,%WindowClass%,WindowLeft
  IniWrite,%WindowTop%,%A_ScriptName%.ini,%WindowClass%,WindowTop
  IniWrite,%WindowWidth%,%A_ScriptName%.ini,%WindowClass%,WindowWidth
  IniWrite,%WindowHeight%,%A_ScriptName%.ini,%WindowClass%,WindowHeight
}
else if 1 = load
{
  WinGetClass,WindowClass,A
  WinGetPos,WindowLeft,WindowTop,WindowWidth,WindowHeight,A
  IniRead,WindowLeft  ,%A_ScriptName%.ini,%WindowClass%,WindowLeft,Error
  IniRead,WindowTop   ,%A_ScriptName%.ini,%WindowClass%,WindowTop,Error
  IniRead,WindowWidth ,%A_ScriptName%.ini,%WindowClass%,WindowWidth,Error
  IniRead,WindowHeight,%A_ScriptName%.ini,%WindowClass%,WindowHeight,Error
  if (WindowLeft = "error" OR WindowTop = "error" 
    OR WindowWidth = "error" OR WindowHeight = "error")
    {
      msgbox,window not yet stored: %WindowClass% 
      return
    }
  WinMove,ahk_class %WindowClass%,,WindowLeft,WindowTop,WindowWidth,WindowHeight
}
return
