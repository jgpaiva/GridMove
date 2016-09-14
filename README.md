15.09.2016 - Fix WinMove for Windows 10.
------------------------

GridMove
========

GridMove is a Windows program that aims at making windows management easier. It helps you with this task by defining a visual grid on your desktop, to which you can easily snap windows. It is built with [AutoHotkey](http://www.autohotkey.com "AutoHotKey"), a scripting language for desktop automation for Windows.

More information at [GridMove's homepage](http://jgpaiva.dcmembers.com/gridmove.html).

Source code organization
------------------------

* GridMove.ahk - Main program, most of the functionality
* files.ahk - Configuration and Grid parsing
* command.ahk - Keyboard (command) interface 
* calc.ahk - Evaluates the .grid files
* helper.ahk - Tooltips for first run
* strings.ahk - Language file
* Aero\_lib.ahk - Library for handling Aero look

This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 3.0 United States License.
