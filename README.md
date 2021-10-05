GridMove (unstable, customized)
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

## Differences from original:
Block system. The screen(s) are divided up into a given blocksize. E.g. in your `.grid` file:
```
[Groups]

  NumberOfGroups = 36
  Blocksize = 7
```

Blocks are used M`X`B`Y`, where `X` is the monitor number and `Y` is the block number. Se example below

Customizable numberings (doesn't have to be the group number):
```
[25]
  ShortCutNum   = 4
  GridTop       = [Monitor2Top]
  GridBottom    = [Monitor2Bottom]
  GridLeft      = [M2B1]
  GridRight     = [M2B2]

  ShowGrid      = 0
```
The above has shortcut number `4` and not `25`.