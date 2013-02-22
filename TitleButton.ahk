; By majkinetor
; v0.31

TitleButtonInitialization:
  DetectHiddenWindows, On
	Gui, 5:+LastFound -Caption +ToolWindow +AlwaysOnTop
	Dock_ClientId := WinExist()
	Gui, 5:Font,s8 , Webdings   
	Gui, 5:Add, Picture, w16 h16 x0 y0 +0x8000 gOnClick, GridMove.ico
	WinSet ExStyle, 0x08000008, ahk_id %Dock_ClientId%

	Gui, 5:Color, 0xFF
	WinSet, TransColor, 0xFF


;	Dock("L","T", 25, 5)		;left
	Dock("R","T",-100, 5)		;right 

	Gui, 5:Show, x-1500 
	Gui, 5:Hide
return

OnClick:
    Hotkey = LButton
    send {LButton up} 
    GoSub,DropZoneMode
return


5GuiContextMenu:
	hwnd := WinExist("A")
	WinGetClass class, ahk_id %hwnd%
	msgbox 36, FM3, Exclude class:`n`n%class%
	ifMsgBox, No
		return

return

;===============================================================================

Dock(H="R",V="T", dx=0, dy=0 ) {
   local hwnd, msg


   hwnd := WinExist("ahk_pid " . DllCall("GetCurrentProcessId","Uint"))
   Dock_msg := 0x550

   HookDll = %A_ScriptDir%/wineventhookq.dll
   
   Dock_pH := H
   Dock_pV := V
   Dock_dx := dx
   Dock_dy := dy
   Dock_sizeX := sizeX
   Dock_sizeY := sizeY

   Dock_hHookDll := API_LoadLibrary(HookDll)

   Dock_hHook2 := Hook(hwnd, Dock_msg, 2)									;alert
   Dock_hHook0 := Hook(hwnd, Dock_msg, 3)									;EVENT_SYSTEM_FOREGROUND
;   Dock_hHook1 := Hook(hwnd, Dock_msg, 22, 23)								;EVENT_SYSTEM_MINIMIZEEND
   Dock_hHook3 := Hook(hwnd, Dock_msg, 0x800B, 0x800B, "Dock_HookHandler")  ;EVENT_OBJECT_STATECHANGE ,EVENT_OBJECT_LOCATIONCHANGE


   return Dock_hHook & Dock_hHookDll
}

Dock_Update:

   WinGetPos, Dock_hX, Dock_hY, Dock_hW, Dock_hH,  ahk_id %Dock_HookHwnd%
   WinGetPos, Dock_cX, Dock_cY, Dock_cW, Dock_cH,  ahk_id %Dock_ClientId%


   Dock_x := Dock_hX
   if (Dock_pH = "R")
         Dock_x := Dock_hX + Dock_hW
   else if (Dock_pH = "M")
      Dock_x := Dock_hX + (Dock_hW//2) - (Dock_cW//2)

   Dock_y := Dock_hY
   if (Dock_pV = "B")
      Dock_y := Dock_hY + Dock_hH
   else if (Dock_pV = "M")
      Dock_y := Dock_hY + (Dock_hH//2) - (Dock_cH//2)

   Dock_x += Dock_dx, Dock_y += Dock_dy
;  OutputDebug %Dock_Event%, %Dock_ClientId%, %Dock_X%, %Dock_Y%
	WinMove, ahk_id %Dock_ClientId%, ,%Dock_X%, %Dock_Y%, %Dock_W%, %Dock_H%
	;WinSet, Top,, ahk_id %Dock_ClientId%
	WinShow, ahk_id %Dock_ClientId%
return


Undock(){
   goSub Dock_Update
   Unhook(Dock_hHook, Dock_msg)
   API_FreeLibrary(HookDll)
}
   
Dock_HookHandler(wParam, lParam, msg, hwnd) {
	local e, cls, title
	static alert
	GetHookParams(lparam, Dock_event, Dock_HookHwnd)
	WinGetClass, Dock_cls, ahk_id %Dock_HookHwnd%
	WinGetTitle, title, ahk_id %Dock_HookHwnd%
	WinGet, style, Style, ahk_id %Dock_HookHwnd%
;	OutputDebug AHK-Dock: ENTER %dock_event% %title% %dock_cls%    

	if Dock_cls in %Dock_Exclude%				;skip excluded 
	{
;		OutputDebug AHK-Dock: exclusion %dock_event% %title% %dock_cls%
		if (Dock_event != 0x800B)				
			WinHide, ahk_id %Dock_ClientId%
		return
	}
	
	if (title = "") or !(style & 0xC00000) or !(style & 0x10000000)	or (style & 0x40000000) {	; WS_CAPTION = C00000 , WS_VISIBLE = 0x10000000, WS_CHILD = 0x40000000
		return
	}

	if (Dock_event = 2) {		
;		OutputDebug AHK-Dock: %dock_event% %title% %dock_cls%
		alert := Dock_HookHwnd					; remember alert win
		return
	}
	if (alert = Dock_HookHwnd)					; skip alert windows
		return

	if (Dock_event = 3)   {						; Foreground
;		OutputDebug AHK-Dock: %dock_event% %title% %dock_cls%
		gosub Dock_Update
		return
	}

	if (Dock_event=0x800B) ;or (Dock_event=0x800A) or (Dock_event = 23)  
	{
 ;		OutputDebug AHK-Dock: %dock_event% %title% %dock_cls%
		gosub Dock_Update
		return
	}
}


GetHookParams(lparam, ByRef event, ByRef hwnd="", ByRef idObject="", ByRef idChild="", ByRef dwEventThread="", ByRef dwmsEventTime="") {
   event			:=GetDeRefInteger(lParam+4)
   hwnd				:=GetDeRefInteger(lParam+8)
   idObject			:=GetDeRefInteger(lParam+12)
   idChild			:=GetDeRefInteger(lParam+16)
   dwEventThread	:=GetDeRefInteger(lParam+20)
   dwmsEventTime	:=GetDeRefInteger(lParam+24)
}

Hook(comm_hwnd, comm_msg, s_event, e_event="", function="", wparam=0) {
   global HookDll
   
   r := DllCall(HookDll "\reghook", "UInt", comm_hwnd, "UInt", COMM_MSG, "UInt", s_event, "UInt", e_event ? e_event : s_event, "UInt", wparam)
   if !r
      return 0

   if (function)
      OnMessage(COMM_MSG, function)

   return r
}

Unhook(handle, com_msg) {
   OnMessage(com_msg, "")
   return DllCall("UnhookWinEvent", "UInt", handle)
}

API_LoadLibrary( dll ) {
   return DllCall("LoadLibrary", "str", dll)
}

API_FreeLibrary( h ) {
    return DllCall("FreeLibrary", "uint", h)
}

API_ShowWindow(hwnd, flag){
   return DllCall("ShowWindow", "UInt", hwnd, "int", flag)
}


GetDeRefInteger(pSource, pIsSigned = false, pSize = 4)
; pSource is an integer pointer to a raw/binary integer
; The caller should pass true for pSigned to interpret the result as signed vs. unsigned.
; pSize is the size of PSource's integer in bytes (e.g. 4 bytes for a DWORD or Int).
{
   Loop %pSize%  ; Build the integer by adding up its bytes.
      result += *(pSource + A_Index-1) << 8*(A_Index-1)
   if (!pIsSigned OR pSize > 4 OR result < 0x80000000)
      return result  ; Signed vs. unsigned doesn't matter in these cases.
   ; Otherwise, convert the value (now known to be 32-bit) to its signed counterpart:
   return -(0xFFFFFFFF - result + 1)
}
