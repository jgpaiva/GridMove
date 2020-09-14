;got from http://www.autohotkey.com/forum/viewtopic.php?p=107547#107547
;*********************************************************************Calculator

CalcEval(X)
  {
  Global Monitor1Left
  Global Monitor1Right
  Global Monitor1Top
  Global Monitor1Bottom
  Global Monitor1Width
  Global Monitor1Height
  Global Monitor2Left
  Global Monitor2Right
  Global Monitor2Top
  Global Monitor2Bottom
  Global Monitor2Width
  Global Monitor2Height
  Global Monitor3Left
  Global Monitor3Right
  Global Monitor3Top
  Global Monitor3Bottom
  Global Monitor3Width
  Global Monitor3Height
  Global MonitorReal1Left
  Global MonitorReal1Right
  Global MonitorReal1Top
  Global MonitorReal1Bottom
  Global MonitorReal1Width
  Global MonitorReal1Height
  Global MonitorReal2Left
  Global MonitorReal2Right
  Global MonitorReal2Top
  Global MonitorReal2Bottom
  Global MonitorReal2Width
  Global MonitorReal2Height
  Global MonitorReal3Left
  Global MonitorReal3Right
  Global MonitorReal3Top
  Global MonitorReal3Bottom
  Global MonitorReal3Width
  Global MonitorReal3Height
 ; Global WindowLeft
 ; Global WindowRight
 ; Global WindowBottom
 ; Global WindowTop
 ; Global WindowWidth
 ; Global WindowHeight
  StringReplace,x, x, %A_Space%,, All ; remove white space
  StringReplace,x, x, %A_Tab%,, All
  StringReplace,x, x, -, #, All       ; # = subtraction
  StringReplace,x, x, (#, (0#, All    ; (-x -> (0-x
  If (Asc(x) = Asc("#"))
    x = 0%x%                         ; leading -x -> 0-x
  StringReplace x, x, (+, (, All      ; (+x -> (x
  If (Asc(x) = Asc("+"))
    StringTrimLeft x, x, 1           ; leading +x -> x
  Loop
  {                                   ; replace constants
    StringGetPos,i, x, [             ; find [
    IfLess i,0, Break
    StringGetPos,j, x, ], L, i+1     ; closest ]
    StringMid,y, x, i+2, j-i-1      ; variable in []
    StringLeft,L, x, i
    StringTrimLeft,R, x, j+1
    if (%Y% = "")
      {
      ;msgbox,error: %y%
      return "Error"
      }
    x := L . %y% . R                 ; replace [var] with value of var
  }
  Loop
  {                                ;finding an innermost (..)
  StringGetPos,i, x, (, R          ;Rightmost '('
  IfLess i,0, Break                ;If there are no more '(', break
  StringGetPos,j, x, ), L, i+1     ;Find the corresponding ')'
  StringMid,y, x, i+2, j-i-1      ;Expression in '()'
  StringLeft,L, x, i               ;Left Part of the expresion
  StringTrimLeft,R, x, j+1         ;Right Part of the expression
  x := L . Eval@(y) . R            ;replace (x) with value of x
  }
  Return Eval@(X)
  }

Eval@(x)
  {
  StringGetPos,i, x, +, R             ; i = -1 if no + is found
  StringGetPos,j, x, #, R
  If (i > j)
    Return Left(x,i)+Right(x,i)
  If (j > i)                          ; i = j only if no + or - found
    Return Left(x,j)-Right(x,j)
  StringGetPos,i, x, *, R
  StringGetPos,j, x, /, R
  If (i > j)
    Return Left(x,i)*Right(x,i)
  If (j > i)
    Return Left(x,j)/Right(x,j)
  StringGetPos,i1, x, abs, R          ; no more operators
  StringGetPos,i2, x, ceil, R         ; look for functions
  StringGetPos,i3, x, floor, R        ; insert further functions below
  m := Max1(i1,i2,i3)
  If (m = i1)                         ; apply the rightmost function
    Return abs(Right(x,i1+2))        ; only one function is applied
  Else If (m = i2)                    ; in one recursion
    Return ceil(Right(x,i2+3))
  Else If (m = i3)
    Return floor(Right(x,i3+4))      ; offset j + StrLen(func) - 2
  Return x
}

Left(x,i)
{
   StringLeft,x, x, i
   Return Eval@(x)
}
Right(x,i)
{
   StringTrimLeft,x, x, i+1
   Return Eval@(x)
}
Max1(x0,x1="",x2="",x3="",x4="",x5="",x6="",x7="",x8="",x9="",x10="",x11="",x12="",x13="",x14="",x15="",x16="",x17="",x18="",x19="",x20="")
{
   x := x0
   Loop 20
   {
      IfEqual   x%A_Index%,, Break
      IfGreater x%A_Index%, %x%
           x := x%A_Index%
   }
   IfLess x,0, Return -2               ; prevent match with -1
   Return %x%
}
