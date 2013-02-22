;SCRIPTNAME!
;By jgpaiva
;date: 
;Function:
setbatchlines,-1
#singleinstance,force
;Gui,add,groupbox,xm ym w200 h200 -background,a
;Gui,add,listbox,x0 y0 w200 h200 readonly 
;gui,add,progress,w300 h200 background00ff00
gui,add,button,x0 y0 w100 h20
Gui, +ToolWindow +AlwaysOnTop -Disabled -SysMenu -Caption
Gui,color,ffffff
Gui,Show,x0 y0 w0 h0 testbutton noactivate
;WinSet, TransColor, ffffff,Testbutton
loop
{
WinGetPos,WinX,WinY,winwidth,,A
gui,show,X%WinX% Y%WinY% w100 h20 noactivate,
}
return

guiclose:
exitapp
