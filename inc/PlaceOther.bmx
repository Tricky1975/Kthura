Rem
	Kthura
	Place "Other"
	
	
	
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
Version: 15.10.01
End Rem
Type TOtherMap Extends TMap
	
	Method Get:totherbase(Tag$)
	Local ret:tOtherBase = totherbase(MapValueForKey(Self,tag))
	If Not ret ked_error "'Other' record asked which does not exist ("+tag+")"
	Return ret
	End Method
	
	Method Have(Tag$)
	Return MapContains(Self,tag)
	End Method
	
	End Type


Global OM:Tothermap = New tothermap	
	

Type TOtherBase

	Method Place(x,y) Abstract
	
	Method Show(KO:TKthuraObject) Abstract
	
	End Type

Type TOtherExit Extends totherbase

	Method Place(x,y)
	Local tag$ = GUI_Input("Please enter a tag for this exit/entrance spot:")
	If Not tag Return
	If kthmap.GetObjectByTag(tag) Return Notify("There already is an object with that tag")
	Print "Placing exit: "+tag
	Local o:TKthuraObject = kthmap.createobject()
	o.kind = "Exit"
	o.tag = tag
	o.impassible = ButtonState(otherdata.impassible)
	o.alpha = SliderValue(ObstacleData.Alpha) / Double(1000)
	o.dominance = TextFieldText(ObstacleData.Dominance).toint()
	If gridmode
		o.x = (Floor(x/currentgridw)*currentgridw)+(currentgridw/2) + screenx
		o.y = (Floor(y/currentgridh)*currentgridh)+currentgridh     + screeny
	Else
		o.x = ex + screenx
		o.y = ey + screeny
		EndIf
	Print "Remapping"	
	kthmap.remaptagmap
	Print "Done"
	End Method
	
	Method Show(KO:TKthuraObject)
	'Print "Showing exit"
	drawspot KO,0,255,0
	'Print "Exit shown"
	End Method
	
	End Type
	
Type TCustomExit Extends totherbase
	Field R = Rand(0,255)
	Field G = Rand(0,255)
	Field B = Rand(0,255)
	
	Method Place(x,y)
	Local O:TKthuraObject = kthmap.createobject()
	o.tag = ""
	o.impassible = ButtonState(otherdata.impassible)
	o.alpha = SliderValue(ObstacleData.Alpha) / Double(1000)
	o.dominance = TextFieldText(ObstacleData.Dominance).toint()
	If gridmode
		o.x = (Floor(x/currentgridw)*currentgridw)+(currentgridw/2) + screenx
		o.y = (Floor(y/currentgridh)*currentgridh)+currentgridh     + screeny
	Else
		o.x = ex + screenx
		o.y = ey + screeny
		EndIf
	o.kind = GadgetItemText ( OtherObjects , SelectedGadgetItem ( OtherObjects ) )
	spotMe = O	
	projectscript.run Replace(o.kind,"$","CSpot_")+"_Place",Null
	kthmap.remaptagmap
	spotMe = Null	
	End Method
	
	Method Show(KO:TKthuraObject)
	spotme = KO
	projectscript.run Replace(ko.kind,"$","CSpot_")+"_Show",Null
	spotme = Null
	End Method
	
	
	End Type	

MapInsert om,"Exit",New totherexit
MapInsert om,"Entrance",om.get("Exit")


Function DrawSpot(KO:TKthuraObject,R,G,B,Rad=5)
Local sx,sy,ex,ey
sx = KO.X-rad
sy = KO.Y-rad
ex = KO.X+rad
ey = KO.Y+rad
SetColor Abs(Sin(MilliSecs()/100)*(R)),Abs(Sin(MilliSecs()/100)*(G)),Abs(Sin(MilliSecs()/100)*(B))
'DrawOval sx-screenx,sy-screeny,ex-screenx,ey-screeny
DrawOpenCircle KO.x-screenx,ko.y-screeny,rad
DrawLine sx-screenx,KO.y-screeny,ex-screenx,KO.Y-screeny
DrawLine ko.x-screenx,sy-screeny,ko.x-screenx,ey-screeny
End Function









' All definened, let's put them into the GUI
For Local K$=EachIn MapKeys(OM)	AddGadgetItem OtherObjects,k	Next
