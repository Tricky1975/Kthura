Rem
	Kthura
	Area Effect Support
	
	
	
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
Version: 16.12.04
End Rem
Type TAEGadget
	Field G:TGadget
	Field altg:TGadget
	Field class$
	Field defaultvalue$
	End Type

Type TBaseAreaEffect

	Field MyOwnTag$
	Field DialogWindow:TGadget
	Field DialogFieldsGadgetMap:TMap = New TMap
	Field DialogFields:TMap = New TMap
	Field dialogOk:TGadget
	Field dialogcancel:TGadget
	Field Tag$ = "<NEW AE OBJ>"
	Method Action(X,Y,W,H) Abstract
	
	Method Results:StringMap() Final
	Local Ret:StringMap = New StringMap
	Local k$,GF:TAEGadget
	Local tf$[]=["false","true"]
	For k=EachIn MapKeys(dialogfieldsgadgetmap)
		gf = AEGF(Self,k)
		Select gf.class
			Case "string" 
				MapInsert ret,k,TextFieldText(gf.g)
			Case "bool"	
				MapInsert ret,k,tf[ButtonState(gf.g)]
			Case "int" 
				MapInsert ret,k,TextFieldText(gf.g).toint()+""
			Case "double" 
				MapInsert ret,k,TextFieldText(gf.g).todouble()+""
			Default
				CSay "WARNING! Unknown class for dialog variable "+k
			End Select
		Next
	Return ret	
	End Method
	
	Method GetResults:StringMap() Final
	If MapIsEmpty(dialogfieldsgadgetmap) Return New StringMap
	DisableGadget Window
	ShowGadget dialogwindow
	Local Evid
	Local ret:StringMap
	Local K$,gf:TAEGadget
	For K=EachIn MapKeys(dialogfieldsgadgetmap)
		gf = AEGF(Self,k)
		Select gf.class
			Case "string","int","double"
				SetGadgetText gf.g,gf.defaultvalue
			Case "bool"
				SetButtonState gf.g,gf.defaultvalue="true"
				SetButtonState gf.altg,Not ButtonState(gf.g)
			End Select
		Next	
	Repeat
	WaitEvent
	evid = EventID()
	If evid = event_gadgetaction
		Select EventSource()
			Case dialogok
				ret = results()
				Exit
			Case dialogcancel
				ret = Null
				Exit
			End Select
		EndIf
	Forever
	HideGadget dialogwindow
	EnableGadget window	
	Return ret
	End Method
	
	End Type
	
Global MapAreaEffect:TMap = New TMap


Function CreateAEG(Me:TBaseAreaEffect,VTag$,class$,DefaultValue$,gadget:TGadget)
Local G:TAEGadget = New TAEGadget
g.g = gadget
g.class=class
g.defaultvalue = defaultvalue
MapInsert me.dialogfieldsgadgetmap,vtag,g
End Function

Function AEGF:TAEGadget(Me:TBaseAreaEffect,VTag$)
Return TaeGadget(MapValueForKey(me.dialogfieldsgadgetmap,vtag))
End Function

Function AEG:TGadget(me:TBaseAreaEffect,VTag$)
Return AEGF(me,VTag).G
End Function

Function AEE:TBaseAreaEffect(Tag$)
Local ret:Tbaseareaeffect = tbaseareaeffect(MapValueForKey(MapAreaEffect,Tag))
If Not ret
	Notify "FATAL ERROR!~n~nUnknown Area Effect tag: "+Tag
	Bye
	EndIf
End Function

Function AEAF(Tag$,X,Y,W,H)
Local LX=X
Local LY=Y
Local LH=H
Local LW=W
If W<0 LX:+W; LW=Abs(W)
If H<0 LY:+H; LH=Abs(H)
Return AEE(Tag).Action(LX,LY,LW,LH)
End Function

Function UntagString$(TaggedString$)
Local ret$ = TaggedString$
Local Tag = "#"[0]
Local H$,NH$,DH,PH
For Local ASCII=0 Until 256
	If ASCII<>Tag 	
		ret = Replace(ret,"#("+ASCII+")",Chr(ASCII))
		H = Hex(ASCII); DH=False; NH=""
		For PH=0 Until Len(H)
			DH = H[PH]<>0 Or PH=Len(H)-1
			If DH NH:+Chr(H[PH])
			Next
		ret = Replace(ret,"$("+NH+")",Chr(ASCII))
		EndIf
	Next
Return ret
End Function

Function CreateAreaEffectDialog(Obj:Object,Caption$,Script$)
Local Tag$
Local Me:TBaseAreaEffect 
If tbaseareaeffect(obj)
	me = tbaseareaeffect(obj)
	tag = me.tag
ElseIf String(obj)
	tag = String(obj)
	me = AEE(Tag)
Else
	Notify "Fatal Error!~n~nIllegal area effect to create a dialog for"
	EndIf
Local Line$
Local Realscript$ = Replace(Script,"~n",";")
Local ListScript$[] = realscript.split(";")
If Not Me Return CSay("WARNING!~nArea effect object "+Tag+" does not exist and I can therefore not setup a dialog box for that!")
Local cmd$,id$,defaultvalue$,remfield$,tline$,total
Local p
Local y=0
Local temppanel:TGadget
CSay("Creating dialog for: "+Tag)
Me.DialogWindow = CreateWindow(Caption,0,0,500,25*(Len(listscript)+1),Null,Window_titlebar|window_clientcoords|window_center|Window_Hidden)
For line = EachIn(ListScript)
	tline = Trim(line)
	If tline And Left(tline,3)<>"rem"
		p = tline.find(" ")
		If p<0 p=Len(tline)-1
		cmd = tline[..p]
		remfield = tline[p+1..]
		defaultvalue=""
		If remfield
			p = remfield.find(" ")
			If p<0 p=Len(remfield)
			id = remfield[..p]
			defaultvalue=remfield[p+1..]
			EndIf
		Select cmd
			Case "label","info","text","explain","explanation"
				CreateLabel untagstring(remfield),0,y,500,25,me.dialogwindow
				y:+25
			Case "string"
				CreateLabel untagstring(id),0,y,200,25,me.dialogwindow
				createAEG me,id,"string",defaultvalue,CreateTextField(250,y,200,25,me.dialogwindow)
				SetGadgetColor aeg(me,id),180,255,180
				y:+25
			Case "int","integer"
				CreateLabel untagstring(id),0,y,200,25,me.dialogwindow
				createAEG me,id,"int",defaultvalue,CreateTextField(250,y,200,25,me.dialogwindow)
				SetGadgetColor aeg(me,id),0,0,180
				SetGadgetColor aeg(me,id),0,180,255,0
				y:+25
			Case  "real","float","double"
				CreateLabel untagstring(id),0,y,200,25,me.dialogwindow
				createAEG me,id,"double",defaultvalue,CreateTextField(250,y,200,25,me.dialogwindow)
				SetGadgetColor aeg(me,id),180,0,0
				SetGadgetColor aeg(me,id),255,180,0,0
				y:+25
			Case "bool","boolean","logic"
				CreateLabel untagstring(id),0,y,200,25,me.dialogwindow
				Temppanel = CreatePanel(250,y,200,25,me.dialogwindow)
				createAEG me,id,"bool",defaultvalue,CreateButton("true",0,0,100,25,temppanel,button_radio)
				AEGF(me,id).AltG = CreateButton("false",100,0,100,25,temppanel,button_radio)
				y:+25
			Default 
				CSay("= WARNING! Unknown command in dialog setup "+tag+": "+tline)
			End Select
		EndIf	
	Next
me.dialogok = CreateButton("Ok",ClientWidth(me.dialogwindow)-150,y,150,25,me.dialogwindow,button_Ok)
me.dialogcancel = CreateButton("Cancel",ClientWidth(me.dialogwindow)-300,y,150,25,me.dialogwindow,button_cancel)
End Function

Function CreateAE(Tag$,AE:Tbaseareaeffect)
AE.Tag = Tag
MapInsert MapAreaEffect,Tag,Ae
End Function

Type TForcePassible Extends tbaseareaeffect
	Method Action(X,Y,W,H)
		Local cnt,letsdoit
		For Local O:TKthuraObject = EachIn kthmap.fullobjectlist
			Select O.kind
				Case "TiledArea","Zone"
					letsdoit = (o.x>x And o.x<x+w And o.y>y And o.y<y+h) Or (o.x+o.w>x And o.x+o.w<x+w And o.y+o.h>y And o.y+o.h<y+h)
					Print "TiledArea/Zone("+O.kind+") "+O.IDNUM+" result "+letsdoit
				Default
					letsdoit = (o.x>x And o.x<x+w And o.y>y And o.y<y+h)	
					Print "Other."+o.kind+" "+O.IDNUM+" result "+letsdoit+"     itemcoords("+O.X+","+O.Y+")   Range("+x+","+y+")-("+Int(x+w)+","+Int(y+h)+")"
				End Select	
			If letsdoit
				o.forcepassible = 1
				cnt:+1
			EndIf
		Next
		Notify "Number of objects modified: "+cnt
	End Method
End Type		


Type TRelabel Extends Tbaseareaeffect

	Method New()
	CreateAreaEffectDialog Self,"Please set up how to relabel","string Label;bool Replace false;bool ConfirmEverything false;label When ~qReplace~q is true, the original labels will be replaced;label otherwise the new labels will be added to the existing ones;label When ~qConfirm~q is true, the system will ask permission;label for each object to be relabeled"
	End Method
	
	Method Action(X,Y,W,H)
	Local ok,letsdoit
	Local AE:Trelabel = trelabel(Self)
	Local s:StringMap = AE.GetResults()
	Local pt$
	Local orilabel$
	If Not s Return Print("Request cancelled")
	For Local O:TKthuraObject = EachIn kthmap.fullobjectlist
		Select O.kind
			Case "TiledArea","Zone"
				letsdoit = (o.x>x And o.x<x+w And o.y>y And o.y<y+h) Or (o.x+o.w>x And o.x+o.w<x+w And o.y+o.h>y And o.y+o.h<y+h)
				Print "TiledArea/Zone("+O.kind+") "+O.IDNUM+" result "+letsdoit
			Default
				letsdoit = (o.x>x And o.x<x+w And o.y>y And o.y<y+h)	
				Print "Other."+o.kind+" "+O.IDNUM+" result "+letsdoit+"     itemcoords("+O.X+","+O.Y+")   Range("+x+","+y+")-("+Int(x+w)+","+Int(y+h)+")"
			End Select	
		If letsdoit
			If s.value("ConfirmEverything")="true"
				pt = "Shall I relabel this object?~n~n~tID~t="+o.idnum+"~n~tKind=~t"+o.kind
				If o.tag pt:+"~n~tTag=~t"+o.tag			
				ok = Proceed(pt)
				If ok<0 Return Notify("Operation aborted!")
			Else 
				ok=True
				EndIf
			For Local lab$=EachIn o.labels.split(",")
				ok = ok And  lab<>s.value("Label") 
				Next
			If ok
				If s.value("Replace")="true" orilabel="" Else orilabel = O.labels
				Print "Replace="+s.value("Replace")+"; o.labels="+o.labels+"; orilabel="+orilabel
				If orilabel Orilabel:+","				
				o.labels=orilabel+s.value("Label")
				EndIf
			EndIf
		Next
	End Method

	End Type
	
Type TMove Extends TBaseAreaEffect

	Method New()
		createareaeffectdialog Self,"Please set up how much I need to move things","string X;string Y"
	End Method
	
	Method action(X,Y,W,H)
		Local ok,letsdoit
		Local s:StringMap = GetResults()
		If Not s Return Print("Request Cancelled")
		Local mx=s.value("X").toint()
		Local my=s.value("Y").toint()
		For Local O:TKthuraObject = EachIn kthmap.fullobjectlist
			Select O.kind
				Case "TiledArea","Zone"
					letsdoit = (o.x>x And o.x<x+w And o.y>y And o.y<y+h) Or (o.x+o.w>x And o.x+o.w<x+w And o.y+o.h>y And o.y+o.h<y+h)
					Print "TiledArea/Zone("+O.kind+") "+O.IDNUM+" result "+letsdoit
				Default
					letsdoit = (o.x>x And o.x<x+w And o.y>y And o.y<y+h)	
					Print "Other."+o.kind+" "+O.IDNUM+" result "+letsdoit+"     itemcoords("+O.X+","+O.Y+")   Range("+x+","+y+")-("+Int(x+w)+","+Int(y+h)+")"
			End Select	
			If letsdoit
				O.X:+mx
				O.Y:+my
			EndIf
		Next
	End Method
End Type	
			
CreateAE "Relabel", New TRelabel
CreateAE "Force Passibe", New TForcePassible
createAE "Move objects", New TMove










' The part below this comment must ALWAYS be at the bottom of this file
For Local AEK$=EachIn MapKeys(MapAreaEffect)
	AddGadgetItem AreaEffectList,AEK
	Next
