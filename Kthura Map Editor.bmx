Rem
/*
	Kthura Map Editor
	An object based map editor using the Kthura map engine
	
	
	
	(c) Jeroen P. Broks, 2015, All rights reserved
	
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
*/


Version: 15.08.23

End Rem
Strict

Rem
This is the main file of the Kthura Map Editor.
Contrary to regular 2d mapeditors Kthura is not tile based as in building up a map tile by tile (in other words the tradition way of working) but by setting up objects.

The first game in which this engine was used was "Moerker" and was named after its protagonist "Kthura" in this honor. (Though this game was suspended due to some issues I could not yet deal with. It might still be created later).
End Rem

' Revisions
' 15.07.29 - GitHub Script set up
'          - Fixed modify alpha ignore bug
' 15.08.01 - Export features now present
' 15.08.17 - FIXED: Console text unreadble in Windows. That is fixed. If Linux had the same issue then it should be fixed as well, though I don't plan a Linux build.
'          - FIXED: Exit menu item didn't work outside Mac. Just forgot to implement that. It's fixed now.
' 15.08.23 - Area effect support
'          - Relabel
'          - Two bugs did pop up which have low priority, but they are noted in my GitHub repository as issues #12 and #13

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
Import    tricky_units.Initfile
Import    tricky_units.ListDir
Import    tricky_units.ranger
Import    tricky_units.trickycircle
Import    tricky_units.swapper




' And last but not least, the core of the Kthura map engine itself. The file is (as you can see) imported directly and not as a module.
' This was done in order to allow myself to change the editor and the core engine more easily without having to rebuild the modules all the time.
' In future versions of this editor a call to the module may be done.
Import    "Mods/Kthura_Core.bmx"
Import    "Mods/Kthura_Draw.bmx"
Import    "Mods/Kthura_Save.bmx"

' Version information
MKL_Version "Kthura Map Editor - Kthura Map Editor.bmx","15.08.23"
MKL_Lic     "Kthura Map Editor - Kthura Map Editor.bmx","GNU - General Public License ver3"


' Use OpenGL (nope, I'm not even thinking about supporting DirectX, sorry!)
SetGraphicsDriver (GLMax2DDriver(),GRAPHICS_ALPHABUFFER|GRAPHICS_BACKBUFFER|GRAPHICS_ACCUMBUFFER)


' Well, with all the imports out of da way, let's now concentrate on all files to be included in order to set up the editor
Include   "inc/Assign.bmx"
Include   "inc/error.bmx"
Include   "inc/Globals.bmx"
Include   "inc/CamSaveLoad.bmx"
Include   "inc/GetProject.bmx"
Include   "inc/GUI.bmx"
Include   "inc/placeother.bmx" ' This must always be placed AFTER the inc/GUI.bmx call!
Include   "inc/Export.bmx"
Include   "inc/script.bmx"
Include   "inc/areaeffect.bmx"
Include   "inc/Editor.bmx"
Include   "inc/go.bmx"




' We have everything? well let's rock and roll then.
GetProject
Run
