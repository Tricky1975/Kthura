Rem
	Kthura Map Editor
		An object based map editor using the Kthura map engine
	
	
	
	(c) Jeroen P. Broks, 2015, 2016, 2017, All rights reserved
	
		This program is free software: you can redistribute it and/or modify
		it under the terms of the GNU General Public License as published by
		the Free Software Foundation, either version 3 of the License, or
		(at your option) any later version.
		
		This program is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		GNU General Public License for more details.
		You should have received a copy of the GNU General Public License
		along with this program.  If not, see <http://www.gnu.org/licenses/>.
		
	Exceptions to the standard GNU license are available with Jeroen's written permission given prior 
	to the project the exceptions are needed for.
Version: 17.05.05
End Rem
Strict

Rem
This is the main file of the Kthura Map Editor.
Contrary to regular 2d mapeditors Kthura is not tile based as in building up a map tile by tile (in other words the tradition way of working) but by setting up objects.

The first game in which this engine was used was "Moerker" and was named after its protagonist "Kthura" in this honor. (Though this game was suspended due to some issues I could not yet deal with. It might still be created later).
End Rem


' Revisions (version numbers are based on the calendar)
' 15.07.29 - GitHub Script set up
'          - Fixed modify alpha ignore bug
' 15.08.01 - Export features now present
' 15.08.17 - FIXED: Console text unreadble in Windows. That is fixed. If Linux had the same issue then it should be fixed as well, though I don't plan a Linux build.
'          - FIXED: Exit menu item didn't work outside Mac. Just forgot to implement that. It's fixed now.
' 15.08.23 - Area effect support
'          - Relabel
'          - Two bugs did pop up which have low priority, but they are noted in my GitHub repository as issues #12 and #13
' 15.09.08 - Fixed alpha bug in modifier
' 15.09.11 - Added support for rotation
'          - Added support for insertion points
' 15.09.14 - Rotten objects remover now also works on zones.
' 15.09.22 - Added color support
'          - Added animation support
' 15.09.23 - Force passible support
' 15.09.26 - Enchanced the Lua Scripting APIs with more features
' 15.09.27 - Fixed the "modified JCR6 file" bug.
' 15.09.28 - Radius support spots
' 15.10.02 - Fixed a bug in radius support lua
' 15.10.03 - Fixed a bug not properly taking over some data in the "Other" spots.
' 15.10.11 - The undesirable behavior caused by JCR6's new changed check has now been resolved. A future feature that CAN take advantage of it MAY still come though.
' 15.10.12 - Multi-Map support
' 15.10.14 - Insert point link
' 15.10.21 - Fixed "color ignore" bug in the tiled area
' 15.11.09 - Removed the reference to the old deprecated IniFile module and switched to IniFile2
' 16.01.07 - Scaling support added
' 16.01.10 - Zone scaling bug fixed
' 16.01.23 - Debug tag list added
' 16.02.07 - OS driven color selector supported
'          - CallBack also supports XTRA for extra data
'          - FIXED: Keep object selected through layer change bug
'          - FIXED: Tag not checked upon entering bug. I may need to change this all once multi-tagging is supported though
' 16.05.08 - Rebuilt for newly set up blockmap saving routine. This does not alter the source of the editor itself, but I name it here, as the compiled version DOES take effect from this.
' 16.09.20 - Frame edit support
' 17.01.08 - Just recompiled, but now it has "raw import" support in the Lua scripting routine due to a GALE upgrade :P
' 17.01.16 - Alternate Blend Support
' 17.04.09 - Script Export
'          - Stand Alone export


' Drivers JCR6
Framework jcr6.zlibdriver
Import    jcr6.realdir
Import    jcr6.fileasjcr

' Drivers for images
Import    brl.pngloader
Import    brl.bmploader
Import    brl.jpgloader
Import    brl.tgaloader

' General Tricky modules
Import    tricky_units.prefixsuffix


' Windows icon
?Win32
Import    "Icons/Kthura.o" 
?


' GUI drivers
Import    MaxGUI.Drivers

' OpenGL drivers
Import    brl.glmax2d ' Nope I'm not gonna support DirectX, no way!

' GALE GUI Driver
Import    GALE.MGUI

' A few required GALE APIs
Import    GALE.Time


' Routines
Import    tricky_units.FilePicker
Import    tricky_units.MKL_Version
Import    tricky_units.Bye
Import    tricky_units.advdatetime
Import    tricky_units.Initfile2
Import    tricky_units.ListDir
Import    tricky_units.ranger
Import    tricky_units.trickycircle
Import    tricky_units.swapper
Import    tricky_units.Dirry




' And last but not least, the core of the Kthura map engine itself. The file is (as you can see) imported directly and not as a module.
' This was done in order to allow myself to change the editor and the core engine more easily without having to rebuild the modules all the time.
' In future versions of this editor a call to the module may be done.
Import    "Mods/Kthura_Core.bmx"
Import    "Mods/Kthura_Draw.bmx"
Import    "Mods/Kthura_Save.bmx"

GALE_USING = True

' Version information
MKL_Version "Kthura Map System - Kthura Map Editor.bmx","17.05.05"
MKL_Lic     "Kthura Map System - Kthura Map Editor.bmx","GNU General Public License 3"

Kthura_DrawZones = True

' Use OpenGL (nope, I'm not even thinking about supporting DirectX, sorry!)
SetGraphicsDriver (GLMax2DDriver(),GRAPHICS_ALPHABUFFER|GRAPHICS_BACKBUFFER|GRAPHICS_ACCUMBUFFER)

' Don't make JCR6 check stuff all the time. Kthura doesn't handle that well, so we can better make Kthura handle such things by itself.
JCR6CheckChange = False

' Well, with all the imports out of da way, let's now concentrate on all files to be included in order to set up the editor
Include   "inc/Assign.bmx"
Include   "inc/error.bmx"
Include   "inc/Globals.bmx"
Include   "inc/AltArg.bmx"
Include   "inc/TexSettingsLoadSave.bmx"
Include   "inc/CamSaveLoad.bmx"
Include   "inc/GetProject.bmx"
Include   "inc/GUI.bmx"
Include   "inc/PlaceOther.bmx" ' This must always be placed AFTER the inc/GUI.bmx call!
Include   "inc/Export.bmx"
Include   "inc/ExportScript.bmx"
Include   "inc/ExportStandAlone.bmx"
Include   "inc/script.bmx"
Include   "inc/areaeffect.bmx"
Include   "inc/Editor.bmx"
Include   "inc/Layers.bmx"
Include   "inc/go.bmx"

SetGadgetText TabPanels[0] ,"Kthura map editor "+MKL_NewestVersion()+"~n~nCoded by Tricky~n~n(c) Jeroen P Broks 2015-"+Year()+"~n~nThe Kthura modules have been licensed under the Mozilla Public License 2.0~nThis editor has been licensed under the GNU General Public License v3~n~n"+MKL_GetAllversions()



' We have everything? well let's rock and roll then.
GetProject
Run
