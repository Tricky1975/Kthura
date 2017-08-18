Rem
	Kthura
	Setup GUI
	
	
	
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
Version: 17.08.18
End Rem
MKL_Version "Kthura Map System - GUI.bmx","17.08.18"
MKL_Lic     "Kthura Map System - GUI.bmx","GNU General Public License 3"

Global CallBackXTRA:Object

' Call back functions
Type TCallBackfunction
	Field func()
	Field XTRA:Object
	End Type

Global CallAction:TMap = New TMap	
Global CallMenu:TMap = New TMap
Global CallSelect:TMap = New TMap


Function AddCallBack(CallMap:TMap,tag:Object,f(),XTRA:Object=Null)
Local r:TCallBackfunction = New tcallbackfunction
r.func = f
r.XTRA=XTRA
MapInsert callmap,tag,r
End Function

Function CallBack(CallMap:TMap,Tag:Object)
Local r:TCallBackfunction = tcallbackfunction(MapValueForKey(callmap,tag))
If Not r Return
CallBackXTRA = r.XTRA
r.func()
End Function


' Grab the events
Function GetEvent()
PollEvent
eid = EventID()
esource = TGadget(EventSource())
ex = EventX()
ey = EventY()
edata = EventData()
End Function



' Define the main window
AppTitle = "Kthura Map Editor"

Global fixedfont  :tguifont = LookupGuiFont(guifont_monospaced,15)
Global fixedfont10:tguifont = LookupGuiFont(guifont_monospaced,10)

Global DSW = ClientWidth(Desktop())
Global DSH = ClientHeight(Desktop())
Print "Desktop format "+DSW+"x"+DSH


Global Window:TGadget = CreateWindow("Kthura Map Editor - version "+MKL_NewestVersion()+" - Coded by Tricky",0,0,dsw,dsh,Null,Window_titlebar|window_menu|window_hidden|Window_Status)
Global WW = ClientWidth(window)
Global WH = ClientHeight(window)

Global Tabber:TGadget = CreateTabber(0,0,ww,wh,window)
Global TW = ClientWidth(tabber)
Global TH = ClientHeight(tabber)
AddGadgetItem tabber,"About Kthura"
AddGadgetItem tabber,"General Map Data"
AddGadgetItem tabber,"Map Editor"
AddGadgetItem tabber,"Console Output"

' The tabber panels
Global TabPanels:TGadget[4]
TabPanels[0] = CreateLabel("Kthura map editor "+MKL_NewestVersion()+"~n~nCoded by Tricky~n~n(c) Jeroen P Broks 2015-"+Year()+"~n~nThe Kthura modules have been licensed under the Mozilla Public License 2.0~nThis editor has been licensed under the GNU General Public License v3~n~n"+MKL_GetAllversions(),0,0,tw,th,tabber)
SetGadgetFont tabpanels[0],fixedfont10
TabPanels[1] = CreateTabber(0,0,tw,th,tabber)
Global GeneralTabber:TGadget = TabPanels[1]
Global GTW = ClientWidth (GeneralTabber)
Global GTH = ClientHeight(GeneralTabber) ; Print "Client format General Data Tab: "+GTW+"x"+GTH
TabPanels[2] = CreatePanel(0,0,tw,th,tabber)
Global Editor:TGadget = TabPanels[2]
tabpanels[3] = CreateTextArea(0,0,tw,th,tabber)
PConsole = tabpanels[3]
SetGadgetColor tabpanels[3],0,0,0
SetGadgetColor tabpanels[3],255,180,0,False
GALE_ConsoleGadget = tabpanels[3]
GALE_ExitGadget    = tabpanels[3]
SetGadgetText tabpanels[3],"Kthura Map system~nVersion: "+MKL_NewestVersion()+"~n(c) Jeroen P. Broks~n~n"
SetGadgetFont tabpanels[3],fixedfont
FormatTextAreaText( Tabpanels[3],255,180,0 ,0 )
TabUpdate
For Local G:TGadget=EachIn TabPanels ListAddLast GALEGUI_HideOnError,G Next

Function GeneralDataUpdate()
Local g:TGadget
For Local K$ = EachIn MapKeys(GDfields)
	g = TGadget(MapValueForKey(gdfields,k))
	If Not g csay "Illegal gadget on key "+k Else MapInsert kthmap.data,k,TextFieldText(g)
	Next
End Function

Function TabUpdate()
For Local k=0 Until 4
	tabpanels[k].setshow k=SelectedGadgetItem(tabber)
	Next
'Print "Show tab: "+SelectedGadgetItem(tabber)	
End Function
addcallback callaction,tabber,tabupdate


' Pull down menus
Global FileMenu:TGadget = CreateMenu("General",0,WindowMenu(Window))
CreateMenu "Save",1000,FileMenu,KEY_S,Modifier_command
CreateMenu "Reload",1001,FileMenu
Global ExportMenu:TGadget = CreateMenu("Export as picture",0,FileMenu)
	Global BExport:TGadget = CreateMenu("Project set export",1500,exportmenu,key_p,modifier_command)
	CreateMenu "",0,exportmenu
	CreateMenu "Export screen to PNG",1501,exportmenu
	CreateMenu "Export screen to JPG",1502,exportmenu
	'CreateMenu "Export screen to BMP",1503,exportmenu
	'CreateMenu "Export screen to TGA",1504,exportmenu
	'Blitz only supports BMP and TGA for input. If you got a driver for either of those, feel free to unrem these, and attach the proper code to it :)
Global ExportScriptMenu:TGadget = CreateMenu("Export as script",0,filemenu)
	CreateMenu "Export to Python",1600,exportscriptmenu
	CreateMenu "Export to Lua",1601,exportscriptmenu
CreateMenu "Export as standalone",1003		,filemenu
?Not MacOS
CreateMenu "",0,filemenu
CreateMenu "Exit",1999,fileMenu,KEY_X,Modifier_command
?
Global GridMenu:TGadget = CreateMenu("Grid",0,WindowMenu(Window))
CreateMenu "Use Default grid",2000,gridmenu
CreateMenu "Edit Custom grid",2001,gridmenu
CreateMenu "",0,gridmenu
Global gad_usegrid:TGadget = CreateMenu("Grid mode",2002,gridmenu,key_g,modifier_command)
Global Gad_ShowGrid:TGadget = CreateMenu("Show Grid",2003,gridmenu,key_d,Modifier_command)
CreateMenu "",0,gridmenu
CreateMenu "Show Work Lines",2004,Gridmenu,Key_L,modifier_command
CreateMenu "",0,gridmenu
CreateMenu "Auto tile size on texture",2005,gridmenu,key_t,modifier_command
CheckMenu gad_usegrid
CheckMenu gad_showgrid

Global ScrollMenu:TGadget = CreateMenu("Scroll",0,WindowMenu(window))
CreateMenu "Scroll Up"   ,3001,scrollmenu,KEY_UP,MODIFIER_COMMAND
CreateMenu "Scroll Down" ,3002,scrollmenu,KEY_DOWN,MODIFIER_COMMAND
CreateMenu "Scroll Left" ,3003,scrollmenu,KEY_LEFT,MODIFIER_COMMAND
CreateMenu "Scroll Right",3004,scrollmenu,KEY_RIGHT,MODIFIER_COMMAND


Global DebugMenu:TGadget = CreateMenu("Debug",0,WindowMenu(Window))
CreateMenu "ShowBlockMap",4001,debugmenu
Function DebugShowBlockMap()
Local F$[] = [".","X"]
AddTextAreaText GALE_ExitGadget,"Blockmap Dump~n"
kthmap.buildblockmap
For Local ay=0 To kthmap.blockmapboundH 
	For Local ax=0 To kthmap.blockmapboundW
	    AddTextAreaText GALE_ExitGadget,F[kthmap.blockmap[ax,ay]]
	    Next
	AddTextAreaText GALE_ExitGadget,"~n"
	Next
AddTextAreaText GALE_ExitGadget,"Blockmap Boundaries: "+kthmap.blockmapboundW+"x"+kthmap.blockmapboundH+"~n~n"
End Function
addcallback callmenu,Hex(4001),debugshowblockmap

CreateMenu "Scan and Remove ~qrotten~q objects",4002,debugmenu
Include "RemoveRotten.bmx"
addcallback callmenu,Hex(4002),removerotten

CreateMenu "Count Objects",4003,debugmenu
Include "CountObjects.bmx"
addcallback callmenu,Hex(4003),CountObjects

CreateMenu "List object tags",4005,debugmenu
Function ListTags()
Local c = 0
AddTextAreaText GALE_ExitGadget,"~nTags:~n"
For Local tag$=EachIn MapKeys(kthmap.tagmap)
	AddTextAreaText GALE_ExitGadget," = "+tag+"  ("+TKthuraObject(MapValueForKey(kthmap.tagmap,tag)).Kind+")~n"
	C:+1
	Next
AddTextAreaText GALE_ExitGadget,"Total Tags:"+c+"~n~n"
End Function
addcallback callmenu,Hex(4005),ListTags


CreateMenu "Go To Screen Position",4004,debugmenu
Function GoToScreenPosition()
Local pos$ = MaxGUI_Input("Please enter the X and Y separated by a comma")
Local Pss$[] = pos.split(",")
If Len(pss)<>2 Then Return Notify("Invalid input")
screenx = pss[0].toint()
screeny = pss[1].toint()
End Function
addcallback callmenu,Hex(4004),GoToScreenPosition

CreateMenu "Check canvas format",4006,debugmenu
Function CheckCanvasFormat()
	Notify "Canvas Format: "+ClientWidth(canvas)+"x"+ClientHeight(canvas)
End Function
addcallback callmenu,Hex(4006),CheckCanvasFormat


' Debug build menu. This one should ONLY be used in the debug build and should therefore not appear in the release build. Oh yeah, and let's always make this menu go last (for obvious reasons). :-P
?Debug
Global KthuraDebugMenu:TGadget = CreateMenu("Debug Kthura Itself",0,WindowMenu(window))
CreateMenu "Annoy",1,kthuradebugmenu
Function DebugAnnoy() Notify "Annoy test!" End Function addcallback callmenu,Hex(1),DebugAnnoy

CreateMenu "Show Detailed BlockMap",2,kthuradebugmenu
Function DebugDShowBlockMap()
Local F$[] = [".","X"]
If Not Confirm("This can take a loong time.~nAre you sure?") Return
'AddTextAreaText GALE_ExitGadget,"Blockmap Dump~n"
kthmap.buildblockmap
Graphics  kthmap.blockmapboundW*kthmap.blockmapgridW , kthmap.blockmapboundH*kthmap.BlockmapgridH
Local c
For Local ay=0 To kthmap.blockmapboundH*kthmap.blockmapgridH 
	For Local ax=0 To kthmap.blockmapboundW*kthmap.BlockmapgridW
	    'AddTextAreaText GALE_ExitGadget,F[kthmap.Block(ax,ay)]
		c = kthmap.Block(ax,ay)
		SetColor c*255,c*180,0
		DrawRect ax,ay,1,1
	    Next
	'AddTextAreaText GALE_ExitGadget,"~n"
	Next
'AddTextAreaText GALE_ExitGadget,"Blockmap Boundaries: "+kthmap.blockmapboundW+"x"+kthmap.blockmapboundH+"~n~n"
Flip
End Function
addcallback callmenu,Hex(2),debugDshowblockmap

CreateMenu "List Scriptfiles",3,kthuradebugmenu
Function JCRScriptDirOverview()
Local O$
For Local E:TJCREntry = EachIn MapValues(ScriptJCR.entries)
	O = E.filename+"~t~t("+E.Mainfile+")"
	CSay O
	Next
End Function
addcallback callmenu,Hex(3),jcrscriptdiroverview
?

UpdateWindowMenu Window


' Editor base tab
Global edw = ClientWidth(editor)
Global edh = ClientHeight(editor)
Global LayerSelector:TGadget = CreateListBox(0,0,199,edh-25,editor); SetGadgetColor layerselector,0,0,0,1; SetGadgetColor layerselector,0,180,255,0
Global LayerAdd:TGadget = CreateButton("+",0,edh-25,50,25,editor)
Global layerremove:TGadget = CreateButton("-",55,edh-25,50,25,editor)
Global Canvas:TGadget = CreateCanvas(200,0,edw-(500+200),edh,editor)
Global ToolTabber:TGadget = CreateTabber(edw-500,0,500,edh,editor)
Global cvw = ClientWidth(canvas)
Global cvh = ClientHeight(canvas)
Print "Canvas format: "+cvw+"x"+cvh
Global ttw = ClientWidth(tooltabber)
Global tth = ClientHeight(tooltabber)
Global paintedbefore
Print "Tool tabber: "+ttw+"x"+tth
AddGadgetItem tooltabber,"Tiled Areas"	' 0
AddGadgetItem tooltabber,"Obstacles"	' 1
AddGadgetItem tooltabber,"Pictures"      ' 2
AddGadgetItem tooltabber,"Zones"		' 3
AddGadgetItem tooltabber,"Other"		' 4
AddGadgetItem tooltabber,"Area Effects"  ' 5
AddGadgetItem tooltabber,"Modify"		' 6
If Not CanvasGraphics(Canvas) AddTextAreaText GALE_ConsoleGadget,"WARNING! Something went wrong in the canvas definitions!~n"
Global ToolGadgets:TList[] = [New TList,New TList,New TList,New TList,New TList,New TList,New TList]

Global TextureQuick:TGadget = CreateComboBox(0,0,ttw,25,tooltabber)
Global TextureBox:TGadget = CreateListBox(0,25,ttw,275,tooltabber)
ListAddLast toolgadgets[0],texturebox 
ListAddLast toolgadgets[1],texturebox
ListAddLast toolgadgets[2],texturebox

Addcallback CallAction,TextureQuick,Tex_WPLoad
Addcallback CallSelect,TextureQuick,Tex_WPLoad
Rem
Global NewObject:TGadget = CreateButton("New Object",0,300,250,25,tooltabber,button_radio)
SetButtonState NewObject,1
ListAddLast toolgadgets[0],NewObject
ListAddLast toolgadgets[1],NewObject
Global ModifyObject:TGadget = CreateButton("Modify Object",300,300,250,25,tooltabber,button_radio)
SetButtonState ModifyObject,0
ListAddLast toolgadgets[0],ModifyObject
ListAddLast toolgadgets[1],ModifyObject
End Rem

Global ParentGadget:TGadget
Type TWorkPanel

	Field pw = ClientWidth(parentgadget)
	Field ph = ClientHeight(parentgadget)
	Field X:TGadget          = CreateTextField   (250,  0, 50,25,parentgadget)
	Field Y:TGadget          = CreateTextField   (300,  0, 50,25,parentgadget)
	Field InsX:TGadget       = CreateTextField   (250, 25, 40,25,parentgadget)
	Field InsY:TGadget       = CreateTextField   (300, 25, 40,25,parentgadget)
	Field W:TGadget          = CreateTextField   (250, 50, 50,25,parentgadget)
	Field H:TGadget          = CreateTextField   (300, 50, 50,25,parentgadget)
	Field Kind:TGadget       = CreateTextField   (250, 75,200,25,parentgadget)
	Field EditTag:TGadget    = CreateButton("Tag:" ,0,100,200,25,parentgadget)
	Field Tag:TGadget        = CreateLabel ("--" ,250,100,200,25,parentgadget)
	Field Labels:TGadget     = CreateTextField   (250,125,200,25,parentgadget)
	Field Dominance:TGadget  = CreateTextField   (250,150,200,25,parentgadget)
	Field alpha:TGadget      = CreateSlider      (250,175,200,25,parentGadget,Slider_horizontal | SLIDER_TRACKBAR)		
	Field Impassible:TGadget = CreateButton(""   ,250,200,200,25,parentgadget,button_checkbox)
	Field FcPassible:TGadget = CreateButton(""   ,250,225,200,25,parentgadget,button_checkbox)
	Field Rotation:TGadget   = CreateTextField    (250,250, 50,25,parentgadget)
	Field R:TGadget          = CreateTextField    (250,275, 50,25,parentgadget) 
	Field G:TGadget          = CreateTextField    (300,275, 50,25,parentgadget) 
	Field B:TGadget          = CreateTextField    (350,275, 50,25,parentgadget) 
	Field ColorSelector:TGadget = CreateButton("..",400,275,50,25,parentgadget)
	Field UseColor:Byte      = 1
	Field AnimSpeed:TGadget  = CreateTextField    (250,300, 50,25,parentgadget)
	Field Frame:TGadget      = CreateTextField    (250,325, 50,25,parentgadget)
	Field ScaleX:TGadget     = CreateTextField    (250,350, 50,25,parentgadget)
	Field ScaleY:TGadget     = CreateTextField    (300,350, 50,25,parentgadget)
	Field ScaleLink:TGadget  = CreateButton("Link",375,350, 50,25,parentgadget,button_checkbox)
	Field AltBlend:TGadget   = CreateComboBox     (250,375,200,25,parentgadget)
	Field DataField:TGadget  = CreateComboBox     (  0,400,200,25,parentgadget)
	Field DataValue:TGadget  = CreateTextField    (250,400,200,25,parentgadget)
	Field dataAdd:TGadget    = CreateButton   ("+",250,425, 50,25,parentgadget)
	Field dataRem:TGadget    = CreateButton   ("-",325,425, 50,25,parentgadget)
	
	'Field frames:TGadget     = CreateTextField  (250,225,200,25,parentgadget)
	'Field framew:TGadget     = CreateTextField  (250,250,200,25,parentgadget)
	'Field frameh:TGadget     = CreateTextField  (250,275,200,25,parentgadget)


	Method New()
	CreateLabel "Coordinates:"    ,0,  0,250,25,ParentGadget
	CreateLabel "Insert Point:"   ,0, 25,250,25,parentgadget
	CreateLabel "Size:"           ,0, 50,250,25,parentgadget
	CreateLabel "Kind:"           ,0, 75,250,25,ParentGadget
	CreateLabel "Labels:"         ,0,125,250,25,parentgadget
	CreateLabel "Dominance:"      ,0,150,250,25,Parentgadget
	CreateLabel "Alpha:"          ,0,175,250,25,parentgadget
	CreateLabel "Impassible:"     ,0,200,250,25,parentgadget
	CreateLabel "Force Passible:" ,0,225,250,25,parentgadget
	CreateLabel "Rotation:"       ,0,250,250,25,parentgadget; CreateLabel "degrees",310,250, 150,25,parentgadget
	CreateLabel "Color:"          ,0,275,250,25,parentgadget
	CreateLabel "Animation Speed:",0,300,250,25,parentgadget; CreateLabel "(higher=slower)",310,300,150,25,parentgadget
	CreateLabel "Frame:"          ,0,325,250,25,parentgadget
	CreateLabel "Scale:"          ,0,350,250,25,parentgadget
	CreateLabel "Alternate Blend:",0,375,250,25,parentgadget
	AddGadgetItem AltBlend,"Don't use"
	AddGadgetItem AltBlend,"Mask"
	AddGadgetItem AltBlend,"Solid"
	AddGadgetItem AltBlend,"Alpha"
	AddGadgetItem AltBlend,"Light"
	AddGadgetItem AltBlend,"Shade"
	SelectGadgetItem altblend,0
	'CreateLabel ""             ,0,200,pw ,25,parentgadget,Label_separator
	'CreateLabel "Frames:"      ,0,225,250,25,parentgadget
	'CreateLabel "Frame Width:" ,0,250,250,25,parentgadget
	'CreateLabel "Frame Height:",0,275,250,25,parentgadget
	SetGadgetColor R,255,180,180; SetGadgetText R,255
	SetGadgetColor G,180,255,180; SetGadgetText G,255
	SetGadgetColor B,180,180,255; SetGadgetText B,255	
	SetSliderRange alpha,0,1000; SetSliderValue alpha,1000
	SetButtonState scalelink,1
	SetGadgetText scalex,1000
	SetGadgetText scaley,1000
	End Method
	End Type

Global WorkPanelList:TList = New TList

Function NewWorkPanel:TWorkPanel(Parent:TGadget)
Parentgadget = Parent
Local ret:Tworkpanel = New TWorkPanel
ListAddLast Workpanellist,ret
Return ret
End Function

Function KidColor(gadget:tgadget,R,G,B,Back=True)
	SetGadgetColor gadget,r,g,b,back
	For Local Gd:TGadget = EachIn gadget.kids
		If GadgetClass(gd)=gadget_label Or GadgetClass(gd)=gadget_panel
			kidcolor gd,r,g,b,back
		EndIf
	Next
End Function

' 0
Global TiledAreaPanel:TGadget = CreatePanel(0,300,ttw,tth-300,tooltabber)
Kidcolor TiledAreaPanel,255,180,0
Global TiledAreaData:TWorkPanel = newworkpanel(Tiledareapanel)
tiledareadata.x.setenabled False
tiledareadata.y.setenabled False
tiledareadata.w.setenabled False
tiledareadata.h.setenabled False
tiledareadata.kind.setenabled False
tiledareadata.edittag.setenabled False
Global insertposlink:TGadget = CreateButton("Link2Pos",350, 25, 80,25,TiledAreaPanel,button_checkbox)
SetGadgetText tiledareadata.kind,"TiledArea"
SetGadgetText tiledareadata.dominance,"20"
SetGadgetText tiledareadata.animspeed,"-1"
SetButtonState tiledAreaData.impassible,1	
ListAddLast toolgadgets[0],tiledareapanel
tiledareadata.scalex.setenabled False
tiledareadata.scaley.setenabled False
tiledareadata.scalelink.setenabled False
tiledareadata.datafield.setenabled False
tiledareadata.datavalue.setenabled False
tiledareadata.dataadd.setenabled False
tiledareadata.datarem.setenabled False


' 1
Global ObstaclePanel:TGadget = CreatePanel(0,300,ttw,tth-300,tooltabber)
KidColor ObstaclePanel,0,180,255
Global ObstacleData:TWorkPanel = newworkpanel(ObstaclePanel)
ListAddLast toolgadgets[1],ObstaclePanel
ObstacleData.x.setenabled False
ObstacleData.y.setenabled False
obstacledata.insx.setenabled False
obstacledata.insy.setenabled False
ObstacleData.w.setenabled False
ObstacleData.h.setenabled False
ObstacleData.kind.setenabled False
ObstacleData.edittag.setenabled False
ObstacleData.FcPassible.SetEnabled False
SetGadgetText ObstacleData.kind,"Obstacle"
SetGadgetText ObstacleData.dominance,"20"
SetGadgetText obstacledata.animspeed,"-1"
SetButtonState ObstacleData.impassible,1	
obstacledata.datafield.setenabled False
obstacledata.datavalue.setenabled False
obstacledata.dataadd.setenabled False
obstacledata.datarem.setenabled False

' 2
Global PicturePanel:TGadget = CreatePanel(0,300,ttw,tth-300,tooltabber)
Global PictureData:Tworkpanel = newworkpanel(PicturePanel)
KidColor picturepanel,255,0,0
KidColor PicturePanel,255,200,200,false
ListAddLast toolgadgets[2],PicturePanel
PictureData.x.setenabled False
PictureData.y.setenabled False
Picturedata.insx.setenabled False
Picturedata.insy.setenabled False
PictureData.w.setenabled False
PictureData.h.setenabled False
PictureData.kind.setenabled False
PictureData.edittag.setenabled False
PictureData.FcPassible.SetEnabled False
SetGadgetText PictureData.kind,"Picture"
SetGadgetText PictureData.dominance,"20"
SetGadgetText PictureData.animspeed,"-1"
SetButtonState PictureData.impassible,0
PictureData.datafield.setenabled False
PictureData.datavalue.setenabled False
PictureData.dataadd.setenabled False
PictureData.datarem.setenabled False
Global PicRepeat:TGadget = CreateButton("Allow Repeat",350, 50, 80,25,PicturePanel,button_checkbox)



' 3
Global ZonePanel:TGadget = CreatePanel(0,300,ttw,tth-300,tooltabber)
Global ZoneData:TWorkPanel = newworkpanel(Zonepanel)
KidColor zonepanel,0,50,0
KidColor zonepanel,180,255,0,False
Zonedata.x.setenabled False
Zonedata.y.setenabled False
Zonedata.w.setenabled False
Zonedata.h.setenabled False
zonedata.insx.setenabled False
zonedata.insy.setenabled False
zonedata.kind.setenabled False
zonedata.edittag.setenabled False
zonedata.alpha.setenabled False
zonedata.dominance.setenabled False
'zonedata.r.setenabled False
'zonedata.g.setenabled False
'zonedata.b.setenabled False
zonedata.usecolor = False
zonedata.animspeed.setenabled False
zonedata.scalex.setenabled False
zonedata.scaley.setenabled False
zonedata.scalelink.setenabled False
SetGadgetText ZoneData.kind,"Zone"
SetGadgetText Zonedata.dominance,"$ffffff"
SetButtonState ZoneData.impassible,0	
ListAddLast toolgadgets[3],ZonePanel
zonedata.altblend.setenabled False
zonedata.datafield.setenabled False
zonedata.datavalue.setenabled False
zonedata.dataadd.setenabled False
zonedata.datarem.setenabled False



'4
Global OtherObjects:TGadget = CreateListBox(0,0,ttw,300,tooltabber)
Global OtherPanel:TGadget = CreatePanel(0,300,ttw,tth-300,tooltabber)
Global OtherData:Tworkpanel = newworkpanel(OtherPanel)
ListAddLast toolgadgets[4],OtherObjects
ListAddLast toolgadgets[4],OtherPanel
KidColor otherpanel,255,100,100
KidColor otherpanel,255,180,180
'SetButtonState OtherObjects.impassible,0
OtherData.x.setenabled False
OtherData.y.setenabled False
OtherData.w.setenabled False
OtherData.h.setenabled False
OtherData.kind.setenabled False
OtherData.edittag.setenabled False
'OtherData.r.setenabled False
'OtherData.g.setenabled False
'OtherData.b.setenabled False
Otherdata.UseColor = False
otherdata.animspeed.setenabled False
otherData.FcPassible.SetEnabled False
SetGadgetText OtherData.kind,""
SetGadgetText OtherData.dominance,"20"
SetButtonState OtherData.impassible,0	
otherdata.scalex.setenabled False
otherdata.scaley.setenabled False
otherdata.scalelink.setenabled False
otherdata.datafield.setenabled False
otherdata.datavalue.setenabled False
otherdata.dataadd.setenabled False
otherdata.datarem.setenabled False


'5
'Global AreaEffectPanel:TGadget = CreatePanel(0,300,ttw,tth-300,tooltabber)
Global AreaEffectList:TGadget= CreateListBox(0,00,ttw,tth,tooltabber)
ListAddLast toolgadgets[5],AreaEffectList
SetGadgetColor areaeffectlist,200,100,40


'6
Global ModifyPanel:TGadget = CreatePanel(0,300,ttw,tth-300,tooltabber)
Global ModifyData:TWorkPanel = Newworkpanel(Modifypanel)
KidColor modifypanel,0,  0,100
KidColor modifypanel,0,180,255,False
Global ModifyRemove:TGadget = CreateButton("Delete",0,ClientHeight(ModifyPanel)-25,ClientWidth(ModifyPanel),25,ModifyPanel)
ListAddLast toolgadgets[6],ModifyPanel

AllowModifyPanel False

Function AllowModifyPanel(A:Byte)
For Local G:TGadget = EachIn modifypanel.kids G.setenabled A Next
End Function


Function UpdateTooltabber()
DebugLog "Tool tab: "+SelectedGadgetItem(tooltabber)
For Local K=0 Until Len toolgadgets
	For Local G:TGadget = EachIn toolgadgets[k]
		G.setshow False
		Next
	Next
For Local G:TGadget = EachIn toolgadgets[SelectedGadgetItem(tooltabber)]
	g.setshow True
	Next
End Function
UpdateTooltabber
addcallback callaction,tooltabber,updatetooltabber

Function ColorSelector()
Local p:Tworkpanel=tworkpanel(CallBackXTRA)
If Not p Then Notify "Internal Error~n~nCallBackXTRA = NULL~n~nPlease report this as a bug!"; End
Local ok  = RequestColor(TextFieldText(P.R).toInt(),TextFieldText(P.G).toInt(),TextFieldText(P.B).toInt())
If ok
	SetGadgetText p.r,RequestedRed()
	SetGadgetText p.g,RequestedGreen()
	SetGadgetText p.b,RequestedBlue()
	EndIf
End Function


'Initiate stuff that goes for all panels
Function Init4AllPanels()
For Local P:TWorkPanel = EachIn WorkPanelList
	p.r.setenabled p.usecolor
	p.g.setenabled p.usecolor
	p.b.setenabled p.usecolor
	p.colorselector.setenabled p.usecolor
	If p.usecolor AddCallBack CallAction,p.colorselector,colorselector,p
	Next
End Function
init4allpanels



' Add Text to the console
Function CSay(Txt$,CRatEnd=True)
Local CR$[] = ["","~n"]
AddTextAreaText GALE_ConsoleGadget,txt+CR[CRatEnd<>0]
End Function
