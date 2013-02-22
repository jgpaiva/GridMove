;GridMove
;By jgpaiva
;date: May 2006
;function: Adjusts windows to a predefined or user-defined desktop grid.

;************************************************************************ini i/o
ReadIni:

  IfExist,%A_AppData%/DonationCoder/GridMove/%A_ScriptName%.ini
    ScriptDir=%A_AppData%/DonationCoder/GridMove/%A_ScriptName%.ini
  else
    IfExist,%A_ScriptDir%\%A_ScriptName%.ini
    {
    filecopy,%A_ScriptDir%\%A_ScriptName%.ini,%A_AppData%/DonationCoder/GridMove/%A_ScriptName%.ini
    ScriptDir=%A_AppData%/DonationCoder/GridMove/%A_ScriptName%.ini
    }
    else
    {
      ScriptDir=%A_AppData%/DonationCoder/GridMove/%A_ScriptName%.ini
    }

  IfExist,%ScriptDir%
    IniRead,isFirstRun            ,%ScriptDir%,IniSettings,IniVersion,false
    

  IniVersion=15
  IfExist,%ScriptDir%
  {
    IniRead,IniVersion            ,%ScriptDir%,IniSettings,IniVersion,1

    If IniVersion = 0
      Iniversion = 1
    If IniVersion = 1
    {
      IniWrite,%GridOrder%        ,%ScriptDir%,GridSettings,GridOrder
      IniVersion = 2
      IniWrite,%IniVersion%       ,%ScriptDir%,IniSettings,Iniversion
    }
    If IniVersion = 2
    {
      IniWrite,%UseCommand%       ,%ScriptDir%,ProgramSettings,UseCommand
      IniWrite,%CommandHotkey%    ,%ScriptDir%,ProgramSettings,CommandHotkey
      IniWrite,%UseFastMove%      ,%ScriptDir%,ProgramSettings,UseFastMove
      IniWrite,%FastMoveModifiers%,%ScriptDir%,ProgramSettings,FastMoveModifiers
      IniVersion = 3
      IniWrite, %IniVersion%      ,%ScriptDir%, IniSettings,Iniversion
    }
    if IniVersion = 3
    {
      IniWrite,%TitleLeft%        ,%ScriptDir%,ProgramSettings,TitleLeft
      IniVersion = 4
      IniWrite, %IniVersion%      ,%ScriptDir%, IniSettings,Iniversion
    }
    if IniVersion = 4
    {
      IniWrite,%ShowNumbersFlag%  ,%ScriptDir%,OtherSettings,ShowNumbersFlag
      IniVersion = 5
      IniWrite,%IniVersion%       ,%ScriptDir%, IniSettings,Iniversion
    }
    if IniVersion = 5
    {
      IniWrite,%MButtonTimeout%  ,%ScriptDir%,InterfaceSettings,MButtonTimeout
      IniWrite,%Transparency%    ,%ScriptDir%,InterfaceSettings,Transparency
      IniVersion = 6
      IniWrite,%IniVersion%      ,%ScriptDir%, IniSettings,Iniversion
    }
    if IniVersion = 6
    {
      IniWrite,%FastMoveMeta%    ,%ScriptDir%,ProgramSettings,FastMoveMeta
      IniVersion = 7
      IniWrite,%IniVersion%      ,%ScriptDir%, IniSettings,Iniversion
    }
    if IniVersion = 7
    {
      IniWrite,%Exceptions%      ,%ScriptDir%,ProgramSettings,Exceptions
      IniVersion = 8
      IniWrite,%IniVersion%      ,%ScriptDir%, IniSettings,Iniversion
    }
    if IniVersion = 8
    {
      IniWrite,%SafeMode%        ,%ScriptDir%,ProgramSettings,SafeMode
      IniVersion = 9
      IniWrite,%IniVersion%      ,%ScriptDir%, IniSettings,Iniversion
    }
    if IniVersion = 9
    {
      IniWrite,%SequentialMove%  ,%ScriptDir%,ProgramSettings,SequentialMove
      IniVersion = 10
      IniWrite,%IniVersion%      ,%ScriptDir%, IniSettings,Iniversion
    }
    if IniVersion = 10
    {
      IniWrite,%DebugMode%       ,%ScriptDir%,ProgramSettings,DebugMode
      IniVersion = 11
      IniWrite,%IniVersion%      ,%ScriptDir%, IniSettings,Iniversion
    }
    if IniVersion = 11
    {
      IniWrite,%GridOrder%       ,%ScriptDir%,GridSettings,GridOrder
      IniWrite,%GridName%        ,%ScriptDir%,GridSettings,GridName
      IniVersion = 12
      IniWrite,%IniVersion%      ,%ScriptDir%, IniSettings,Iniversion
    }
    if IniVersion = 12
    {
      IniWrite,%DisableTitleButtonsDetection%,%ScriptDir%,OtherSettings,DisableTitleButtonsDetection
      IniVersion = 13
      IniWrite,%IniVersion%      ,%ScriptDir%, IniSettings,Iniversion
    }
    if Iniversion = 13
    {
      IniWrite,%ColorTheme%      ,%ScriptDir%,OtherSettings,ColorTheme
      IniWrite,%Language%        ,%ScriptDir%,OtherSettings,Language
      IniWrite,%NoTrayIcon%      ,%ScriptDir%,InterfaceSettings,NoTrayIcon
      IniVersion = 14
      IniWrite,%IniVersion%      ,%ScriptDir%, IniSettings,Iniversion
    }
    if IniVersion = 14
    {
      IniWrite,%FirstRun%        ,%ScriptDir%, IniSettings,FirstRun
      IniVersion = 15
      IniWrite,%IniVersion%      ,%ScriptDir%, IniSettings,Iniversion
    }

    IniRead,GridName         ,%ScriptDir%,GridSettings     ,GridName,Error
    IniRead,LButtonDrag      ,%ScriptDir%,InterfaceSettings,LButtonDrag,Error
    IniRead,MButtonDrag      ,%ScriptDir%,InterfaceSettings,MButtonDrag,Error
    IniRead,EdgeDrag         ,%ScriptDir%,InterfaceSettings,EdgeDrag,Error
    IniRead,EdgeTime         ,%ScriptDir%,OtherSettings    ,EdgeTime,Error
    IniRead,ShowGroupsFlag   ,%ScriptDir%,OtherSettings    ,ShowGroupsFlag,Error
    IniRead,ShowNumbersFlag  ,%ScriptDir%,OtherSettings    ,ShowNumbersFlag,Error
    IniRead,TitleSize        ,%ScriptDir%,OtherSettings    ,TitleSize,Error
    IniRead,GridOrder        ,%ScriptDir%,GridSettings     ,GridOrder,Error
    IniRead,UseCommand       ,%ScriptDir%,Programsettings  ,UseCommand,Error
    IniRead,CommandHotkey    ,%ScriptDir%,Programsettings  ,CommandHotkey,Error
    IniRead,UseFastMove      ,%ScriptDir%,Programsettings  ,UseFastMove,Error
    IniRead,FastMoveModifiers,%ScriptDir%,Programsettings  ,FastMoveModifiers,Error
    IniRead,FastMoveMeta     ,%ScriptDir%,Programsettings  ,FastMoveMeta,Error
    IniRead,TitleLeft        ,%ScriptDir%,ProgramSettings  ,TitleLeft,Error
    IniRead,MButtonTimeout   ,%ScriptDir%,InterfaceSettings,MButtonTimeout,Error
    IniRead,Transparency     ,%ScriptDir%,InterfaceSettings,Transparency,Error
    IniRead,Exceptions       ,%ScriptDir%,ProgramSettings  ,Exceptions,Error
    IniRead,SafeMode         ,%ScriptDir%,ProgramSettings  ,SafeMode,Error
    IniRead,SequentialMove   ,%ScriptDir%,ProgramSettings  ,SequentialMove,Error
    IniRead,DebugMode        ,%ScriptDir%,ProgramSettings  ,DebugMode,Error
    IniRead,DisableTitleButtonsDetection,%ScriptDir%,OtherSettings,DisableTitleButtonsDetection,Error
    IniRead,ColorTheme       ,%ScriptDir%,OtherSettings    ,ColorTheme,Error
    IniRead,Language         ,%ScriptDir%,OtherSettings    ,Language,Error
    IniRead,Registered       ,%ScriptDir%,OtherSettings    ,Registered,Error
    IniRead,NoTrayIcon       ,%ScriptDir%,InterfaceSettings,NoTrayIcon,Error
    IniRead,FirstRun         ,%ScriptDir%,IniSettings      ,FirstRun,Error

    If(Registered = "Error")
      Registered =

    If (GridName          = "Error" OR LButtonDrag    = "Error" OR MButtonDrag       = "Error" 
        OR EdgeDrag       = "Error" OR EdgeTime       = "Error" OR ShowGroupsFlag    = "Error" 
        OR TitleSize      = "Error" OR ShowGroupsFlag = "Error" OR ShowNumbersFlag   = "Error" 
        OR TitleSize      = "Error" OR GridOrder      = "Error" OR UseCommand        = "Error" 
        OR CommandHotkey  = "Error" OR UseFastMove    = "Error" OR FastMoveModifiers = "Error" 
        OR FastMoveMeta   = "Error" OR TitleLeft      = "Error" OR MButtonTimeout    = "Error" 
        OR Transparency   = "Error" OR Exceptions     = "Error" OR SafeMode          = "Error"
        OR SequentialMove = "Error" OR DebugMode      = "Error" OR NoTrayIcon        = "Error"
        OR FirstRun       = "ERROR"
        OR DisableTitleButtonsDetection = "Error")
    {
      MsgBox,%error_inifile%
      FileDelete,%ScriptDir%
      Reload
      sleep 20000
    }

    If(FirstRun){
      GoSub,firstRun
    }
  }
  else
  {
    gosub,firstRun
  }
return

firstRun:
    FirstRun:=false
    GoSub,setlanguage
    GoSub,AboutHelp
    GoSub,WriteIni
    msgbox,64,%info_firstrun_title%,%info_firstrun%
    settimer, helper,100
    
WriteIni:
  IfNotExist,%ScriptDir%
  {
    FileCreateDir,%A_AppData%/DonationCoder/
    if(ErrorLevel <> 0)
    {           
      ScriptDir=%A_ScriptDir%\%A_ScriptName%.ini
    }
    else
      FileCreateDir,%A_AppData%/DonationCoder/GridMove/
      if(ErrorLevel <> 0)
      {           
        ScriptDir=%A_ScriptDir%\%A_ScriptName%.ini
      }
    FileAppend, ,%ScriptDir%
  }
  IniWrite,%GridName%         ,%ScriptDir%,GridSettings     ,GridName
  IniWrite,%LButtonDrag%      ,%ScriptDir%,InterfaceSettings,LButtonDrag
  IniWrite,%MButtonDrag%      ,%ScriptDir%,InterfaceSettings,MButtonDrag
  IniWrite,%EdgeDrag%         ,%ScriptDir%,InterfaceSettings,EdgeDrag
  IniWrite,%EdgeTime%         ,%ScriptDir%,OtherSettings    ,EdgeTime
  IniWrite,%ShowGroupsFlag%   ,%ScriptDir%,OtherSettings    ,ShowGroupsFlag
  IniWrite,%ShowNumbersFlag%  ,%ScriptDir%,OtherSettings    ,ShowNumbersFlag
  IniWrite,%TitleSize%        ,%ScriptDir%,OtherSettings    ,TitleSize
  IniWrite,%GridOrder%        ,%ScriptDir%,GridSettings     ,GridOrder
  IniWrite,%UseCommand%       ,%ScriptDir%,ProgramSettings  ,UseCommand
  IniWrite,%CommandHotkey%    ,%ScriptDir%,ProgramSettings  ,CommandHotkey
  IniWrite,%UseFastMove%      ,%ScriptDir%,ProgramSettings  ,UseFastMove
  IniWrite,%FastMoveModifiers%,%ScriptDir%,ProgramSettings  ,FastMoveModifiers
  IniWrite,%FastMoveMeta%     ,%ScriptDir%,ProgramSettings  ,FastMoveMeta
  IniWrite,%SafeMode%         ,%ScriptDir%,ProgramSettings  ,SafeMode
  IniWrite,%TitleLeft%        ,%ScriptDir%,ProgramSettings  ,TitleLeft
  IniWrite,%MButtonTimeout%   ,%ScriptDir%,InterfaceSettings,MButtonTimeout
  IniWrite,%Transparency%     ,%ScriptDir%,InterfaceSettings,Transparency
  IniWrite,%Exceptions%       ,%ScriptDir%,ProgramSettings,Exceptions
  IniWrite,%SequentialMove%   ,%ScriptDir%,ProgramSettings,SequentialMove
  IniWrite,%DebugMode%        ,%ScriptDir%,ProgramSettings,DebugMode
  IniWrite,%DisableTitleButtonsDetection%,%ScriptDir%,OtherSettings,DisableTitleButtonsDetection
  IniWrite,%ColorTheme%       ,%ScriptDir%,OtherSettings    ,ColorTheme
  IniWrite,%IniVersion%       ,%ScriptDir%,IniSettings      ,iniversion
  IniWrite,%Language%         ,%ScriptDir%,OtherSettings    ,Language
  IniWrite,%NoTrayIcon%       ,%ScriptDir%,InterfaceSettings,NoTrayIcon
  IniWrite,%FirstRun%         ,%ScriptDir%,IniSettings      ,FirstRun
Return   
   
;***************************************************************About / help GUI
AboutHelp:
  if mutex
    return
  mutex:=true

  gui, 3: Add, Tab, x6 y5 w440 h420, About|Help

  ;**************About
  gui, 3: Tab, 1
  IfExist %A_ScriptDir%\gridmove.ico
    gui, 3:Add , Picture, x15 y35,%A_ScriptDir%\gridmove.ico
  else
    IfExist %A_ScriptDir%\gridmove.exe
      gui, 3:Add , Picture, x15 y35,%A_ScriptDir%\gridmove.exe
      
  gui, 3:Font,Bold s10
  if(Registered="quebec")
    gui, 3:Add ,Text,x70 y45,GridMove V%ScriptVersion% by João Paiva`n
  else
    gui, 3:Add ,Text,x70 y45,GridMove V%ScriptVersion% by jgpaiva`n

  gui, 3:Font,
  gui, 3:Font, s10
  gui, 3:Add ,Text,x15 y95 w420 ,%About_Main%

  gui, 3:Add ,Text,X15 Y220,%About_Suggest%
  gui, 3:Font,CBlue Underline
  gui, 3:Add ,Text,X15 Y255 GPost,http://www.donationcoder.com/Forums/bb/index.php?topic=3824
  gui, 3:Font

  gui, 3:Font, s10
  gui, 3:Add ,Text, y280 X15,`n%About_visit%
  gui, 3:Font,CBlue Underline s10
  gui, 3:Add ,Text, y313 X15 GMainSite,http://www.donationcoder.com/
  gui, 3:Font

  if(Registered="quebec"){
    IfExist,%A_SCRIPTDIR%/Images/CLP_LOGO.png
      Gui, 3:Add ,Picture, Y290 X235,%A_SCRIPTDIR%/Images/CLP_LOGO.png
  }else{
    ifexist,%a_scriptdir%/images/cody.png 
      gui, 3:add ,picture, y290 x280,%a_scriptdir%/images/cody.png
  }

  if(Registered<>"quebec")
    gui, 3:Add ,Button,y350 x15  gdonateAuthor w116 h30,Donate

  if(Registered="quebec"){
    gui, 3:Font, s10
    gui, 3:add, Text,y380 x15 h10,%about_license_quebec%
  }else{
    gui, 3:Font, s9
    gui, 3:Add ,Text,y400 x15 h10,If you like this program please make a donation to help further development.
  }
  gui, 3:Font, s9

  ;**************HELP
  gui, 3:Tab, 2
  gui, 3:Font,

  Gui, 3:Add, Edit, w413 R29 vMyEdit ReadOnly
  if(Language = "FR"){
    IfExist, %A_ScriptDir%\GridMoveHelp_FR.txt
      FileRead, FileContents,%A_ScriptDir%\GridMoveHelp_FR.txt 
  }else{
    IfExist, %A_ScriptDir%\GridMoveHelp_EN.txt
      FileRead, FileContents,%A_ScriptDir%\GridMoveHelp_EN.txt 
  }
  GuiControl,3:, MyEdit, %FileContents%

  ;gui, 3:default
  ;gui, tab,3
  ;
  ;gui, add, groupbox, ,How to activate GridMove
  ;
  ;Gui, add, checkbox, ,By dragging a window by its title
  ;Gui, add, checkbox, ,By dragging a window while pressing middle mouse button
  ;Gui, add, checkbox, ,By dragging a window to the edge of the screen



  ;**************General + complementary functions
  gui, 3:tab

  if(Registered="quebec")
    Gui, 3:show,,GridMove V%ScriptVersion% by João Paiva
  else
    Gui, 3:show,,GridMove V%ScriptVersion% by jgpaiva
return

Post:
  Run,http://www.donationcoder.com/Forums/bb/index.php?topic=3824
  GoSub,3GuiCLOSE 
return
  
MainSite:
  Run,http://www.donationcoder.com/
  GoSub,3Guiclose 
return
  
DonateSite:
  Run,http://www.donationcoder.com/Donate/index.html
  GoSub,3Guiclose
return
  
DonateAuthor:
  Run,https://www.paypal.com/cgi-bin/webscr?cmd=_xclick&business=jgpaiva`%40gmail`%2ecom&item_name`=donate`%20to`%20jgpaiva&item_number`=donationcoder`%2ecom&no_shipping=1&cn=Please`%20drop`%20me`%20a`%20line`%20`%3aD&tax`=0&currency_code=EUR&bn=PP`%2dDonationsBF&charset=UTF`%2d8
  GoSub,3Guiclose
return  
  
3GuiEscape:
3GuiClose:  
buttonok:
  gui,3:destroy
  mutex:=false
return
  
;*********************************************************************Templates


Template-3part:
  Menu,Templates,DeleteAll
  CreateTemplatesMenu() 

  SysGet, MonitorCount, MonitorCount
  Count := 0
  
  loop, %MonitorCount%
  {
    SysGet, Monitor, MonitorWorkArea,%A_index%
    MonitorWidth := MonitorRight - MonitorLeft
    MonitorHeight := MonitorBottom - MonitorTop
    
    Count+=1
    %Count%TriggerTop    := MonitorTop
    %Count%TriggerRight  := MonitorRight
    %Count%TriggerBottom := MonitorBottom
    %Count%TriggerLeft   := MonitorLeft + Round(MonitorWidth / 3)
    %Count%GridTop       := %Count%TriggerTop
    %Count%GridRight     := %Count%TriggerRight
    %Count%GridBottom    := %Count%TriggerBottom
    %Count%GridLeft      := %Count%TriggerLeft
    
    Count+=1
    %Count%TriggerTop    := MonitorTop
    %Count%TriggerRight  := MonitorLeft + Round(MonitorWidth / 3)
    %Count%TriggerBottom := MonitorTop + Round(MonitorHeight / 2)
    %Count%TriggerLeft   := MonitorLeft
    %Count%GridTop       := %Count%TriggerTop
    %Count%GridRight     := %Count%TriggerRight
    %Count%GridBottom    := %Count%TriggerBottom
    %Count%GridLeft      := %Count%TriggerLeft
    
    Count+=1
    temp := count - 1
    %Count%TriggerTop    := %Temp%TriggerBottom +0.01
    %Count%TriggerRight  := MonitorLeft + Round(MonitorWidth / 3)
    %Count%TriggerBottom := MonitorBottom
    %Count%TriggerLeft   := MonitorLeft
    %Count%GridTop       := %Count%TriggerTop
    %Count%GridRight     := %Count%TriggerRight
    %Count%GridBottom    := %Count%TriggerBottom
    %Count%GridLeft      := %Count%TriggerLeft
  }
  NGroups := MonitorCount * 3
  Gui,Destroy
  GoSub, CreateGroups
  GridName = 3Part
  GoSub, WriteIni
return

