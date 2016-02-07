Rem
	Kthura
	Editor itself
	
	
	
	(c) Jeroen P. Broks, 2015, 2016, All rights reserved
	
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
Version: 16.02.07
End Rem

' updates
' 15.08.15 - Initial version
' 16.01.07 - Scaling support added

MKL_Version "Kthura Map System - Editor.bmx","16.02.07"
MKL_Lic     "Kthura Map System - Editor.bmx","GNU General Public License 3"


' Draw the canvas
Function DrawCanvas()
If SelectedGadgetItem(Tabber)<>2 Return
'If Not  CanvasGraphics(Canvas) Print "No canvas?"
SetGraphics CanvasGraphics(Canvas)
SetBlend alphablend
Cls
' If past the null barrier, make the background red
If screenx<0 Then
	SetColor 255,0,0
	DrawRect 0,0,Abs(screenx),GadgetHeight(canvas)
	EndIf
If screeny<0 Then
	SetColor 255,0,0
	DrawRect 0,0,GadgetWidth(canvas),Abs(screeny)
	EndIf
' Draw the map
DrawKthura kthmap,screenx,screeny
' Extra draw canvas
Local t = SelectedGadgetItem(ToolTabber)
Local ca:Tcanvasactionbase = canvasaction[t]
ca.xdrawcanvas
' Draw "Other" spots
For Local KO:TKthuraObject = EachIn Kthmap.fullobjectlist
	'Print "D: "+KO.Kind
	If OM.Have(KO.Kind) OM.Get(KO.Kind).Show(KO)
	Next
'Print "D: DONE!"	
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
'LoadProject ' Should not be needed any more.
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


Global CanvasAction:TCanvasActionBase[6]


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
	o.R = TextFieldText(TiledAreaData.R).toInt() If O.R<0 O.R=0 ElseIf O.R>255 O.R=255
	o.G = TextFieldText(TiledAreaData.G).toInt() If O.G<0 O.G=0 ElseIf O.G>255 O.G=255
	o.B = TextFieldText(TiledAreaData.B).toInt() If O.B<0 O.B=0 ElseIf O.B>255 O.B=255
	o.texturefile = tex
	o.kind = "TiledArea"
	o.dominance = TextFieldText(TiledAreaData.Dominance).toInt()
	o.alpha = SliderValue(TiledAreaData.Alpha) / Double(1000)
	o.impassible = ButtonState(tiledareadata.impassible)
	o.forcepassible = ButtonState(tiledareadata.fcpassible)
	o.labels = TextFieldText(TiledAreaData.Labels)
	o.rotation = TextFieldText(TiledAreaData.Rotation).toint(); While O.rotation>=360 o.rotation:-360 Wend; While O.rotation<=-360 o.rotation:+360 Wend	
	If ButtonState(InsertPosLink)
		o.insertx = -o.x
		o.inserty = -o.y
	Else
		o.insertx = TextFieldText(TiledAreaData.InsX).toInt()
		o.inserty = TextFieldText(TiledAreaData.InsY).toInt()
		EndIf
	o.framespeed = TextFieldText(tiledareadata.animspeed).toint()
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
	O.R=TextFieldText(obstacledata.r).toint()
	O.G=TextFieldText(obstacledata.g).toint()
	O.B=TextFieldText(obstacledata.b).toint()
	O.Texturefile = tex
	O.dominance = TextFieldText(ObstacleData.Dominance).toInt()
	o.alpha = SliderValue(ObstacleData.Alpha) / Double(1000)
	o.impassible = ButtonState(ObstacleData.impassible)
	o.labels = TextFieldText(ObstacleData.Labels)
	o.rotation = TextFieldText(ObstacleData.Rotation).toint(); While O.rotation>=360 o.rotation:-360 Wend; While O.rotation<=-360 o.rotation:+360 Wend	
	o.framespeed = TextFieldText(obstacledata.animspeed).toint()
	o.scalex = TextFieldText(obstacledata.scalex).toint()
	o.scaley = TextFieldText(obstacledata.scaley).toint()
	kthmap.totalremap
	End Method


	End Type


Type TCanvasZones Extends TCanvasTiledArea

	Method MouseDown()
	Local tex$
	If True 'ButtonState(NewObject)
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
	'Local s = SelectedGadgetItem(Texturebox)
	'Local tex$ = GadgetItemText(texturebox,s)
	O.X = startx + Screenx
	o.y = starty + screeny
	o.w = w
	o.h = h
	'o.texturefile = tex
	o.kind = "Zone"
	o.dominance = "$ffffff".toInt()
	o.impassible = ButtonState(zonedata.impassible)
	o.forcepassible = ButtonState(zonedata.fcpassible)
	o.labels = TextFieldText(zoneData.Labels)
	o.r = Rand(0,255)
	o.g = Rand(0,255)
	o.b = Rand(0,255)
	Repeat
	o.tag = "Zone "+Hex(Rand(0,Abs(MilliSecs())))
	Until Not MapContains(kthmap.tagmap,o.tag)
	'CSay "Created "+o.kind; CSay "~tdom = "+O.dominance; CSay "~tAlpha = "+o.alpha	
	kthmap.totalremap
	work=False	
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
			Case "TiledArea","Zone"	
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
		SetGadgetText P.R,KO.R
		SetGadgetText P.G,KO.G
		SetGadgetText P.B,KO.B
		SetGadgetText P.Kind,KO.Kind; DisableGadget P.Kind ' Never change a kind manually. Unless you know what you are doing, this is dangerous.
		SetGadgetText P.Tag,KO.Tag
		SetGadgetText P.Labels,KO.Labels
		SetGadgetText P.Dominance,KO.Dominance
		SetSliderValue P.alpha,KO.Alpha*1000
		SetButtonState P.Impassible,KO.Impassible
		SetButtonState P.FcPassible,KO.ForcePassible
		SetGadgetText P.Rotation,KO.Rotation
		SetGadgetText P.insx,KO.insertx
		SetGadgetText p.insy,KO.inserty
		SetGadgetText p.animspeed,ko.framespeed
		SetGadgetText p.scalex,ko.scalex
		SetGadgetText p.scaley,ko.scaley
		SetButtonState p.scalelink,ko.scalex=ko.scaley
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
	
Type TCanvasAreaEffect Extends TCanvasActionBase

     	Field down,x,y,w,h,endx,endy
	Field AEI$

	Method MouseEnter() End Method
	Method MouseLeave() down=False End Method
	Method MouseMove() 
	endx = ex
	endy = ey
	End Method

	Method MouseDown() 
	Local i = SelectedGadgetItem(areaeffectlist)
	If i<0 Return Notify("Please select something from the effect list first!")
	AEI = GadgetItemText(areaeffectlist,i)
	down=True
	x = ex
	y = ey
	endx = ex
	endy = ey
	End Method
	
	Method MouseUp() 
	If Not down Return
	down=False
	w = endx - x
	h = endy - y
	Local AEA:Tbaseareaeffect = tbaseareaeffect(MapValueForKey(MapAreaEffect,AEI))
	If Not AEA Return Notify("SOMETHING'S WRONG!!!~n~nNo instruction object was assigned to Area Effect type "+AEI+". This is very likely the result of an internal error.~n~nPlease visit https://github.com/Tricky1975/Kthura/issues and report it!")
	AEA.Action(x+screenx,y+screeny,w,h)
	End Method
	
	Method XDrawCanvas()
	If Not down Return
	Local r = 100 + (Sin(MilliSecs()/100)*100)
	Local g = 100 + (Cos(MilliSecs()/100)*100)
	Local b = 100 + (Sin(MilliSecs()/500)*100)
	SetColor r,g,b	
	SetAlpha .25
	Local mx,my,mw,mh
	mx = x
	my = y
	mw = endx - x 
	mh = endy - y
	DrawRect mx,my,mw,mh
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
KO.R = TextFieldText(P.R).toint(); If KO.R<0 KO.R=0 ElseIf KO.R>255 KO.R=255
KO.G = TextFieldText(P.G).toint(); If KO.G<0 KO.G=0 ElseIf KO.G>255 KO.G=255
KO.B = TextFieldText(P.B).toint(); If KO.B<0 KO.B=0 ElseIf KO.B>255 KO.B=255
KO.InsertX = TextFieldText(P.InsX).toint()
KO.InsertY = TextFieldText(P.InsY).toint()
KO.Rotation = TextFieldText(P.Rotation).toint(); While kO.rotation>=360 ko.rotation:-360 Wend; While kO.rotation<=-360 ko.rotation:+360 Wend	
KO.dominance = TextFieldText(P.dominance).Toint()
ko.framespeed = TextFieldText(p.animspeed).toint()
ko.scalex = TextFieldText(p.scalex).toint()
ko.scaley = TextFieldText(p.scaley).toint()
Kthmap.totalremap
DebugLog "ModifyMove() called and executed"
End Function	

Function FieldScaleX(P:TWorkPanel)
If ButtonState(p.scalelink) SetGadgetText P.scaley,GadgetText(P.scalex)
End Function

Function FieldScaleY(P:TWorkPanel)
If ButtonState(p.scalelink) SetGadgetText P.scalex,GadgetText(P.scaley)
End Function

Function modifyscalex() FieldScaleX Modifydata modifymove; End Function
Function modifyscaley() fieldscaleY modifydata modifymove; End Function
Function obstaclescalex() FieldScaleX obstacledata End Function
Function obstaclescaley() FieldScaleY obstacledata End Function

Function ModifyImpassible()
Local P:Tworkpanel = modifydata
Local KO:TKthuraObject = SelectedObject
If Not ko Return
KO.Impassible = ButtonState(P.Impassible)
KO.ForcePassible = ButtonState(P.FcPassible)
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
	If KO.Tag=Tag Then Return
	If MapContains(KO.Parent.TagMap,Tag) 
		Notify "ERROR! Tag ~q"+Tag+"~q already exists! Please Select another!"
		Return
		EndIf
	KO.Tag = tag
	SetGadgetText modifydata.tag,tag
	EndIf
End Function

Function ModifyAlpha()
Local KO:TKthuraObject = SelectedObject
If Not KO CSay("No modification.... Could not get an object"); Return
KO.alpha = SliderValue(modifydata.alpha)/Double(1000)
End Function

Function DeleteObject()
Local P:Tworkpanel = modifydata
Local KO:TKthuraObject = SelectedObject
If Proceed("Do you really wish to delete object #"+KO.IdNum+"?")<>1 Return
ListRemove Kthmap.fullobjectlist,KO
kthmap.totalremap
SelectedObject = Null
allowmodifypanel False
End Function

Function OtherSelect()
Local s = SelectedGadgetItem(otherobjects)
If s<0
	SetGadgetText otherdata.kind,""
Else
	SetGadgetText otherdata.kind,GadgetItemText(otherobjects,s)
	EndIf
End Function

Function Link2PosOrNot()
tiledareadata.insx.setenabled Not ButtonState(insertposlink)
tiledareadata.insy.setenabled Not ButtonState(insertposlink)
End Function
addcallback callaction,insertposlink,link2posornot

addcallback callaction,modifydata.x,modifymove
addcallback callaction,modifydata.y,modifymove
addcallback callaction,modifydata.w,modifymove
addcallback callaction,modifydata.h,modifymove
addcallback callaction,modifydata.r,modifymove
addcallback callaction,modifydata.g,modifymove
addcallback callaction,modifydata.b,modifymove
addcallback callaction,modifydata.insx,modifymove
addcallback callaction,modifydata.insy,modifymove
addcallback callaction,modifydata.rotation,modifymove
addcallback callaction,modifydata.dominance,modifymove
addcallback callaction,modifydata.animspeed,modifymove
addcallback callaction,modifydata.impassible,modifyimpassible
addcallback callaction,modifydata.fcpassible,modifyimpassible
addcallback callaction,modifydata.Labels,modifylabels
addcallback callaction,modifyremove,deleteobject
addcallback callaction,modifydata.edittag,modifyretag
addcallback callaction,modifydata.alpha,modifyalpha
addcallback callselect,otherobjects,otherselect
ADDCALLBACK CALLACTION,MODIFYDATA.SCALEX,MODIFYSCALEX
ADDCALLBACK CALLACTION,MODIFYDATA.SCALEY,MODIFYSCALEY
ADDCALLBACK CALLACTION,OBSTACLEDATA.SCALEX,OBSTACLESCALEX
ADDCALLBACK CALLACTION,OBSTACLEDATA.SCALEY,OBSTACLESCALEY

	
CanvasAction[0] = New TCanvasTiledArea
canvasaction[1] = New TcanvasObstacle
canvasaction[2] = New TCanvasZones
canvasaction[3] = New TCanvasOther
canvasaction[4] = New TCanvasAreaEffect
canvasaction[5] = New TCanvasModify
