Rem
	Kthura
	APIs for Lua
	
	
	
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
Version: 15.10.02
End Rem
Global spotme:TKthuraObject
Type TLuaSPOT ' BLD: Object SPOT\nObject used for spot placement and showing

	Method ME:TKthuraObject() ' BLD: This object is assigned by the editor prior to calling the spot functions. This way the script can act upon the spot accordingly. Notable fields<ul><li>X</li><li>Y</li><li>Tag (this value in this tag must be unique or Kthura will crash out completely!)</li></ul>
	If Not spotme GALE_Error "Me cannot be called when it's not in use!"
	Return spotme
	End Method
	
	Method DrawMe(rad=5) ' BLD: Draws a marker on screen where the spot is located
	Local trad=rad
	If Not trad trad=5
	If Not spotME Return CSay("? ERROR! A DrawMe request was done, while SPOTS.ME is currently not in use")
	DrawSpot spotME,spotME.R,spotME.G,spotME.B,trad
	End Method
	
	Method Kill() ' BLD: Destroy the spot "ME". This feature is most of all for cancelling stuff
	ListRemove kthmap.fullobjectlist,spotme
	kthmap.totalremap
	End Method
	
	End Type
	
Global LuaSPOT:TLuaSpot = New tluaspot
GALE_Register luaspot,"SPOT"

Type TLuaTags ' BLD: Object TAGS\nObject used for tagging issues

	Method Exists(Tag$) ' BLD: Returns 1 if the tag exists and 0 if the tag does not exist. Please note Lua deems both values true, so you need to make an explicit check
	Return MapContains(Kthmap.tagmap,tag)
	End Method
	
	End Type
	
GALE_Register New tluatags,"TAGS"

Type TLuaClicked ' BLD: Object CLICKED\nThis object should only be used in the "Clicked" functions of your script. Using it elsewhere is pretty much pointless.
	Field TrueX,TrueY
	Field X    ' BLD: X-coordinate of the mouse on the moment the function is called
	Field Y    ' BLD: Y-coordinate of the mouse on the moment the function is called
	Field RET  ' BLD: Assign 1 if you want a true statement and 0 if you want a false statement. After Lua carries the process back over to Kthura, this value shall be processed as the "returned value".
	End Type
Global LuaClicked:TLuaClicked	= New tluaclicked
GALE_Register LuaClicked,"CLICKED"

Type TLuaGenObject ' BLD: Object OBJ\nGeneral object features

	Method CreateNew:TKthuraObject(kind$) ' BLD: Creates a new object of a kind. Returns the object itself, and you can best assign it to a variable for further configuration.
	Local ret:TKthuraObject = kthmap.createobject()
	ret.kind = kind
	Return ret
	End Method
	
	Method Remap() ' BLD: Remap all objects
	kthmap.totalremap
	End Method
	
	Method Obj:TKthuraObject(Tag$) ' BLD: Returns a Kthura object tied to the desired tag.<br>If no object exists with the desired tag
	Return TKthuraObject(MapValueForKey(kthmap.tagmap,tag))
	End Method
		
	End Type

GALE_Register New tluagenobject,"OBJ"
	
Type TLuaInput ' BLD: Object INPUT\nGeneral input

	Method Ask$(Caption$) ' BLD: Ask a question and return the answer as a string
	Return MaxGUI_Input(Caption)
	End Method
	
	End Type
	
GALE_Register New tluainput,"INPUT"
	

