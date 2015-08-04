Rem
/*
	Kthura
	Editor Part
	
	
	
	(c) JEROEN P. BROKS, 2015, All rights reserved
	
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


Version: 15.07.29

End Rem
MKL_Version "Kthura Map Editor - inc/Editor.bmx","15.07.29"
MKL_Lic     "Kthura Map Editor - inc/Editor.bmx","GNU - General Public License ver3"


' Draw the canvas
Function DrawCanvas()
If SelectedGadgetItem(Tabber)<>1 Return
'If Not  CanvasGraphics(Canvas) Print "No canvas?"
SetGraphics CanvasGraphics(Canvas)
SetBlend alphablend
Cls
' Draw the map
DrawKthura kthmap,screenx,screeny
' Extra draw canvas
Local t = SelectedGadgetItem(ToolTabber)
Local ca:Tcanvasactionbase = canvasaction[t]
ca.xdrawcanvas
' Draw "Other" spots
For Local KO:TKthuraObject = EachIn Kthmap.fullobjectlist
	If OM.Have(KO.Kind) OM.Get(KO.Kind).Show(KO)
	Next
' Show Grid
If GridShow drawgrid
' Draw Work Lines
If linesshow
	SetAlpha 1
	SetColor 255,255,255
	For Local L:TLine = EachIn Worklines
		DrawLine L.SX,L.SY,L.EX,L.EY
		Next
	EndIf	
' flip it 
Flip
End Function



Function DrawGrid()
Local ak
SetAlpha 1
SetColor 25,25,25
'For ak=0 Until ClientWidth(Canvas) Step currentgridw	DrawLine ak,0,ak,ClientHeight(canvas)	Next
'For ak=0 Until ClientHeight(canvas) Step currentgridh	DrawLine 0,ak,ClientWidth(canvas),ak	Next
For ak=EachIn ToRange(0,ClientWidth(Canvas),currentgridw)	DrawLine ak,0,ak,ClientHeight(canvas)	Next
For ak=EachIn ToRange(0,ClientHeight(canvas),currentgridh)	DrawLine 0,ak,ClientWidth(canvas),ak	Next
End Function

' Lines
Function ToggleWorkLines()
LinesShow = Not LinesShow
End Function
addcallback callmenu,Hex(2004),ToggleWorkLines


' Scroll
Function ScrollUp()		screeny:-(defaultgridh/2) End Function; Addcallback callmenu,Hex(3001),scrollup
Function ScrollDown()	screeny:+(defaultgridh/2) End Function; Addcallback callmenu,Hex(3002),scrolldown
Function ScrollLEFT()	screenx:-(defaultgridh/2) End Function; Addcallback callmenu,Hex(3003),scrollleft
Function ScrollRight()	screenx:+(defaultgridh/2) End Function; Addcallback callmenu,Hex(3004),scrollright


' Save all this shit
Function EditorSave()
Csay "Saving: "+Mapfile
SaveKthura kthmap,mapfile
End Function
addcallback callmenu,Hex(1000),editorsave

Function WantToSave()
Local r = Proceed("Do you wish to save?") 
If r=1 EditorSave
Return r<>-1
End Function


' How to respond to the pulldown menus
Function ToggleGridMode()
Gridmode = Not Gridmode
gad_usegrid.setselected gridmode
End Function
Addcallback callmenu,Hex(2002),ToggleGridMode

Function ToggleShowGrid()
Gridshow = Not gridshow
gad_showgrid.setselected gridshow
End Function
AddCallBack CallMenu,Hex(2003),toggleShowgrid


Global CanvasAction:TCanvasActionBase[5]


' What to do with the canvases?
Type TCanvasActionBase Abstract

	Method MouseEnter() End Method
	Method MouseLeave() End Method
	Method MouseMove() End Method

	Method MouseDown() End Method
	
	Method MouseUp() End Method
	
	Method XDrawCanvas() End Method

	End Type


Type TCanvasTiledArea Extends tcanvasactionbase
	
	Field startx,starty,work,endx,endy
	
	Method MouseDown()
	Local s = SelectedGadgetItem(Texturebox)
	Local tex$
	If True 'ButtonState(NewObject)
		If s<0 Return Notify("Please select a texture first")
		work=True
		' standard setting
		startx=ex
		starty=ey
		' mod by grid if set that way
		If gridmode
			startx = Floor(startx/currentgridw)*currentgridw
			starty = Floor(starty/currentgridh)*currentgridh
			EndIf
		' end is by default the same as the start. The user will move the mouse later.
		endx=startx
		endy=starty
		EndIf
	End Method

	Method MouseUp()
	If Not work Return
	If endx=startx Return
	If endx=starty Return
	If endx<startx SwapInt endx,startx
	If endy<starty SwapInt endy,starty
	Local O:TKthuraObject = kthmap.createobject(False)
	Local w = endx - startx
	Local h = endy - starty
	Local s = SelectedGadgetItem(Texturebox)
	Local tex$ = GadgetItemText(texturebox,s)
	O.X = startx + Screenx
	o.y = starty + screeny
	o.w = w
	o.h = h
	o.texturefile = tex
	o.kind = "TiledArea"
	o.dominance = TextFieldText(TiledAreaData.Dominance).toInt()
	o.alpha = SliderValue(TiledAreaData.Alpha) / Double(1000)
	o.impassible = ButtonState(tiledareadata.impassible)
	o.labels = TextFieldText(TiledAreaData.Labels)
	'CSay "Created "+o.kind; CSay "~tdom = "+O.dominance; CSay "~tAlpha = "+o.alpha	
	kthmap.totalremap
	work=False
	End Method
	
	Method MouseLeave()
	work=False
	End Method
	
	Method MouseMove()
	If Not work Return
	' Basic values
	endx = mx
	endy = my
	' modify by grid
	If gridmode And (Not autotextsize)
		endx = Floor(endx/currentgridw)*currentgridw
		endy = Floor(endy/currentgridh)*currentgridh		
	' modify by auto tile size (this is dominant over the grid)
	ElseIf autotextsize
		EndIf
	End Method
	
	Method XDrawCanvas()
	If Not work Return
	Local r = 100 + (Sin(MilliSecs()/100)*100)
	Local g = 100 + (Cos(MilliSecs()/100)*100)
	Local b = 100 + (Sin(MilliSecs()/500)*100)
	SetColor r,g,b	
	SetAlpha .25
	Local x,y,w,h
	x = startx
	y = starty
	w = endx - startx
	h = endy - starty
	DrawRect x,y,w,h
	End Method
	

	End Type


Type TCanvasObstacle Extends Tcanvasactionbase

	Method MouseDown()
	Local s = SelectedGadgetItem(Texturebox); If s<0 Return Notify("I cannot place an obstacle without a texture")
	Local tex$ = GadgetItemText(texturebox,s)
	Local O:TKthuraObject = kthmap.createobject(False)
	O.X = MX + ScreenX
	O.Y = MY + ScreenY
	If gridmode
		O.X = (Floor(o.x/currentgridw)*currentgridw)+(currentgridw/2)
		O.Y = (Floor(o.y/currentgridh)*currentgridh)+ currentgridh
		EndIf
	O.Kind = "Obstacle"
	O.W=0
	O.H=0
	O.Texturefile = tex
	O.dominance = TextFieldText(ObstacleData.Dominance).toInt()
	o.alpha = SliderValue(ObstacleData.Alpha) / Double(1000)
	o.impassible = ButtonState(ObstacleData.impassible)
	o.labels = TextFieldText(ObstacleData.Labels)
	kthmap.totalremap
	End Method

	End Type


Type TCanvasZones Extends tcanvasactionbase
	
	Field startx,starty
	Field work
	
	Method MouseDown()
	End Method

	Method MouseUp()
	End Method

	End Type
	
Type TCanvasOther Extends tcanvasactionbase
	
	Field startx,starty
	
	Method MouseDown()
	Local s = SelectedGadgetItem(OtherObjects)
	If s<0 Return Notify("Please select an object type first!")
	Local ot$ = GadgetItemText(OtherObjects,s)
	If Not MapContains(OM,ot) Return Notify("Trying to place an unknown object")
	om.get(ot).Place(ex,ey)
	End Method

	Method MouseUp()
	End Method

	End Type

Type TCanvasModify Extends tcanvasactionbase
	
	Field startx,starty
	
	Method MouseDown()
	Local P:Tworkpanel = modifydata ' I'm lazy, I don't wanna type that all the time :P
	selectedobject = Null
	Local cdom = -1
	Local KO:TKthuraObject
	Local w,h
	For KO=EachIn kthmap.fullobjectlist
		If selectedobject cdom=selectedobject.dominance
		Select KO.Kind
			Case "TiledArea"	
				If KO.x<ex+screenx And KO.x+ko.w>ex+screenx And KO.y<ey+screeny And KO.y+ko.h>ey+screeny And KO.dominance>=cdom SelectedObject = KO
			Case "Exit","Entrance"
				If ex+screenX>KO.x-3 And ex+screenX<KO.X+3 And ey+screeny>KO.y-3 And ey+screeny<KO.y+3 And KO.dominance>=cdom SelectedObject = KO
			Case "Obstacle"
				If KO.textureImage
					w = ImageWidth(KO.textureimage)
					h = ImageHeight(KO.textureimage)
					If ex+screenx>KO.X-(w/2) And ex+screenx<KO.X+(w/2) And ey+screeny>KO.Y-h And ey+screeny<KO.Y And KO.dominance>=cdom SELECTEDOBJECT = KO
					'Print "Obstacle check: ~n- Mouse: ("+Int(ex+screenx)+","+Int(ey+screeny)+")~n- Area: ("+Int(KO.X-(w/2))+","+Int(KO.Y-h)+") - ("+Int(KO.X+(w/2))+","+KO.Y+")~n- Dominance:"+KO.Dominance+" ___ Old: "+cdom+"~n- Boolcheck: "+Int(ex+screenx>KO.X-(w/2) And ex+screenx<KO.X+(w/2) And ey-screeny>KO.Y-h And ey-screeny<KO.Y And KO.dominance>=cdom)+"~n- Selected: "+Int(SelectedObject=KO)
					EndIf	
			Default
				Select Chr(KO.Kind[0])
					Case "$"
						LuaClicked.truex=ex
						LuaClicked.truey=ey
						luaclicked.x=ex+screenx
						luaclicked.y=ey+screeny
						LuaClicked.ret=-1
						SpotMe = KO
						projectscript.run Replace(ko.kind,"$","CSpot_")+"_Click",Null
						If LuaClicked.Ret<0
							CSay("? ERROR! No proper value seemed to be returned from Click Script in object #"+KO.idnum+">"+KO.Kind)
						Else
							If LuaClicked.Ret SelectedObject = KO
							EndIf
					End Select		
			End Select		
		Next
	allowmodifypanel selectedobject<>Null
	If selectedobject
		KO = Selectedobject
		SetGadgetText P.X,KO.X
		SetGadgetText P.Y,KO.Y
		SetGadgetText P.W,KO.W
		SetGadgetText P.H,KO.H
		SetGadgetText P.Kind,KO.Kind; DisableGadget P.Kind ' Never change a kind manually. Unless you know what you are doing, this is dangerous.
		SetGadgetText P.Tag,KO.Tag
		SetGadgetText P.Labels,KO.Labels
		SetGadgetText P.Dominance,KO.Dominance
		SetSliderValue P.alpha,KO.Alpha*1000
		SetButtonState P.Impassible,KO.Impassible
		EndIf		
	?debug
	If selectedobject csay "Selected object #"+SelectedObject.idnum Else csay "No object selected"
	?
	End Method

	Method MouseUp()
	End Method

	Method XDrawCanvas()
	If selectedobject
		SetAlpha(.4)
		SetColor 255,180,0
		DrawRect selectedobject.x-screenx,selectedobject.y-screeny,selectedobject.w,selectedobject.h
		EndIf
	End Method	

	End Type
	
Function ModifyMove()
Local P:Tworkpanel = modifydata
Local KO:TKthuraObject = SelectedObject
If Not ko Return
KO.X = TextFieldText(P.X).toint()
KO.Y = TextFieldText(P.Y).toint()
KO.W = TextFieldText(P.W).toint()
KO.H = TextFieldText(P.H).toint()
KO.dominance = TextFieldText(P.dominance).Toint()
Kthmap.totalremap
End Function	

Function ModifyImpassible()
Local P:Tworkpanel = modifydata
Local KO:TKthuraObject = SelectedObject
If Not ko Return
KO.Impassible = ButtonState(P.Impassible)
End Function

Function ModifyLabels()
Local P:Tworkpanel = modifydata
Local KO:TKthuraObject = SelectedObject
KO.Labels = TextFieldText(P.Labels)
End Function

Function ModifyReTag()
'Local P:Tworkpanel = modifydata
Local KO:TKthuraObject = SelectedObject
If Not KO CSay("No modification.... Could not get an object"); Return
HideGadget window
Local tag$=MaxGUI_Input("Please tag this object:")
ShowGadget window
If MaxGUI_InputAccepted 
	KO.Tag = tag
	SetGadgetText modifydata.tag,tag
	EndIf
End Function

Function ModifyAlpha()
Local KO:TKthuraObject = SelectedObject
If Not KO CSay("No modification.... Could not get an object"); Return
KO.alpha = SliderValue(modifydata.alpha)
End Function

Function DeleteObject()
Local P:Tworkpanel = modifydata
Local KO:TKthuraObject = SelectedObject
If Proceed("Do you really wish to delete object #"+KO.IdNum+"?")<>1 Return
ListRemove Kthmap.fullobjectlist,KO
kthmap.totalremap
End Function

Function OtherSelect()
Local s = SelectedGadgetItem(otherobjects)
If s<0
	SetGadgetText otherdata.kind,""
Else
	SetGadgetText otherdata.kind,GadgetItemText(otherobjects,s)
	EndIf
End Function


addcallback callaction,modifydata.x,modifymove
addcallback callaction,modifydata.y,modifymove
addcallback callaction,modifydata.w,modifymove
addcallback callaction,modifydata.h,modifymove
addcallback callaction,modifydata.dominance,modifymove
addcallback callaction,modifydata.impassible,modifyimpassible
addcallback callaction,modifydata.Labels,modifylabels
addcallback callaction,modifyremove,deleteobject
addcallback callaction,modifydata.edittag,modifyretag
addcallback callaction,modifydata.alpha,modifyalpha
addcallback callselect,otherobjects,otherselect
	
CanvasAction[0] = New TCanvasTiledArea
canvasaction[1] = New TcanvasObstacle
canvasaction[2] = New TCanvasZones
canvasaction[3] = New TCanvasOther
canvasaction[4] = New TCanvasModify
