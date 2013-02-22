Gui, Add, Tab, x6 y7 w430 h530 , Tab1|Tab2
Gui, Add, CheckBox, x26 y57 w210 h30 , By dragging a window by its title (left section of title bar)
Gui, Add, GroupBox, x16 y37 w400 h120 , GroupBox
Gui, Add, CheckBox, x26 y87 w210 h30 , By dragging a window while pressing middle button
Gui, Add, CheckBox, x26 y117 w210 h30 , By dragging a window to the edge of the screen
Gui, Add, Text, x246 y47 w160 h30 , Delay before grid comes up when dragging to edge (in millisecons)
Gui, Tab, Tab1
Gui, Add, Text, x246 y97 w160 h30 , Size of the portion of title bar considered "title" (in pixels)
Gui, Add, Edit, x246 y127 w160 h20 , Edit
Gui, Add, Edit, x246 y77 w160 h20 , Edit
; Generated using SmartGUI Creator 4.0
Gui, Show, x185 y91 h545 w451, New GUI Window
Return

GuiClose:
ExitApp