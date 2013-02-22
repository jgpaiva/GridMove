showOptions:

optionsGui:=5

gui, %optionsGui%:default

gui, add, tab2,, Activation|Grid Settings

gui, add, text,,You can use GridMove in two ways: using the mouse and using the keyboard.`nYou may change the setting for both methods in this tab.

gui, add, groupbox, r3,Using the mouse
Gui, add, checkbox, xp+10 yp+20,By dragging a window by its title
Gui, add, checkbox, ,By middle mouse button (anywhere) and dragging window
Gui, add, checkbox, ,By dragging a window to the edge of the screen

gui, add, groupbox, xp-10 yp+30 r3,Using the Keyboard
Gui, add, checkbox, xp+10 yp+20,Use shortcut to show the grid and select
Gui, add, checkbox, ,By middle mouse button (anywhere) and dragging window
Gui, add, checkbox, ,By dragging a window to the edge of the screen

gui,show

gui, 1:default
return
