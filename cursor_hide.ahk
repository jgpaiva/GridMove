loop, 13 
   ToggleSystemCursor( A_Index, true ) 
    
MsgBox, Just in time for Halloween ... 

loop, 13 
   ToggleSystemCursor( A_Index ) 
return 

ToggleSystemCursor( p_id, p_hide=false ) 
{ 
   /* 
   OCR_NORMAL      IDC_ARROW      32512   1 
   OCR_IBEAM      IDC_IBEAM      32513   2 
   OCR_WAIT      IDC_WAIT      32514   3 
   OCR_CROSS      IDC_CROSS      32515   4 
   OCR_UP         IDC_UPARROW      32516   5 
   OCR_SIZENWSE   IDC_SIZENWSE   32642   6 
   OCR_SIZENESW   IDC_SIZENESW   32643   7 
   OCR_SIZEWE      IDC_SIZEWE      32644   8 
   OCR_SIZENS      IDC_SIZENS      32645   9 
   OCR_SIZEALL      IDC_SIZEALL      32646   10 
   OCR_NO         IDC_NO         32648   11 
   OCR_HAND      IDC_HAND      32649   12 
   OCR_APPSTARTING   IDC_APPSTARTING   32650   13 
   */ 
    
   static   system_cursor_list 
    
   if system_cursor_list= 
      system_cursor_list = |1:32512|2:32513|3:32514|4:32515|5:32516|6:32642|7:32643|8:32644|9:32645|10:32646|11:32648|12:32649|13:32650| 
    
   ix := InStr( system_cursor_list, "|" p_id ) 
   ix := InStr( system_cursor_list, ":", false, ix )+1 
    
   StringMid, id, system_cursor_list, ix, 5 
    
   ix_b := ix+6 
   ix_e := InStr( system_cursor_list, "|", false, ix )-1 
    
   SysGet, cursor_w, 13 
   SysGet, cursor_h, 14 
    
   if ( cursor_w != 32 or cursor_h != 32 ) 
   { 
      MsgBox, System parameters not supported! 
      return 
   } 
    
   if ( p_hide ) 
   { 
      if ( ix_b < ix_e ) 
         return 

      h_cursor := DllCall( "LoadCursor", "uint", 0, "uint", id ) 
       
      h_cursor := DllCall( "CopyImage", "uint", h_cursor, "uint", 2, "int", 0, "int", 0, "uint", 0 ) 
       
      StringReplace, system_cursor_list, system_cursor_list, |%p_id%:%id%, |%p_id%:%id%`,%h_cursor% 
       
      VarSetCapacity( AndMask, 32*4, 0xFF ) 
      VarSetCapacity( XorMask, 32*4, 0 ) 
       
      h_cursor := DllCall( "CreateCursor" 
                        , "uint", 0 
                        , "int", 0 
                        , "int", 0 
                        , "int", cursor_w 
                        , "int", cursor_h 
                        , "uint", &AndMask 
                        , "uint", &XorMask ) 
   } 
   else 
   { 
      if ( ix_b > ix_e ) 
         return 

      StringMid, h_cursor, system_cursor_list, ix_b, ix_e-ix_b+1 
       
      StringReplace, system_cursor_list, system_cursor_list, |%p_id%:%id%`,%h_cursor%, |%p_id%:%id% 
   } 
    
   result := DllCall( "SetSystemCursor", "uint", h_cursor, "uint", id ) 
}

