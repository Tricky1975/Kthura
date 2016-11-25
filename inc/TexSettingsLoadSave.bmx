Rem
	Kthura
	
	
	
	
	(c) Jeroen P. Broks, 2016, All rights reserved
	
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
Version: 16.11.25
End Rem
Function SaveTexSettings(J:TJCRCreate)
	Local bt:TJCRCreateStream = j.createentry("KME.TextureSettings","zlib")
	For Local key$=EachIn MapKeys(TextureSettings)   
		WriteByte   bt.stream,1
		WriteInt    bt.stream,Len(key)
		WriteString bt.stream,key
		For Local subkey$=EachIn MapKeys(GetTextureSettings(key))
			WriteByte   bt.stream,2
			WriteInt    bt.stream,Len(subkey)
			WriteString bt.stream,subkey
			WriteInt    bt.stream,Len(GetTextureSettings(key).value(subkey))
			WriteString bt.stream,GetTextureSettings(key).value(subkey)
			DebugLog "Texture: "+key+"   >>> "+subkey+" = "+GetTextureSettings(key).value(subkey)
		Next			
	Next
	WriteByte bt.stream,$ff
	bt.close
	Rem
	Local ed:TJCREntry = TJCREntry(MapValueForKey(j.entries,"KME.TextureSettings")) ' As the creator does not (yet) use all caps, it can otherwise result to "null"
	If Not ed 
		Print "WARNING! ~qDon't Merge Me~q not added as the entry is non-existent!"
	Else
		ed.md "&__DONTMERGEME",1 ' -- This will lead into the upcoming version of JCR_Add to ignore this particular entry, as games don't need it. Only this editor does.
	EndIf	
	End Rem
End Function

KthuraSave_AddAction SaveTexSettings,"Saving: Texture Settings"


Function TexError(Error$)
	Notify "ERROR IN TEXSETTINGSLOADER~n~n"+Error+"~n~nI will continue, but any saved texture settings are lost!"
	ClearMap TextureSettings
End Function	

Function LoadTexSettings(file$)
	If Not JCR_Exists(file,"KME.TextureSettings") 
		Print "No textures settings present, so let's ignore the whole thing!"
		Return
	EndIf
	Local BT:TStream = ReadFile(JCR_B(file,"KME.TextureSettings"))
	Local key$,SubKey$,Value$,L
	Local tag:Byte
	While Not Eof(BT)
		tag = ReadByte(BT); DebugLog "Textsettings tag = "+Tag
		Select tag
			Case 1
				L = ReadInt(BT)
				key = ReadString(BT,L)
				MapInsert texturesettings,key,New StringMap
				DebugLog "Texture:"+Key
			Case 2
				If Not key
					texerror "Cannot assign data when no texture is set"; Exit
				End If
				L = ReadInt(BT)	subkey = ReadString(BT,L)
				L = ReadInt(BT)	value  = ReadString(BT,L)
				DebugLog key+" <<< "+subkey+" = "+value
				If Not subkey Then TexError("Empty sub key in texture ~q"+key+"~q"); Exit
				MapInsert GetTextureSettings(key),subkey,value
			Case $ff,$00
				Exit		
			Default
				TexError "Invalid Tag ("+tag+")"; Exit
		End Select		
	Wend
	CloseFile bt
	ResetTexList
End Function	

Function ResetTexList()
	ClearGadgetItems Texturequick
	For Local k$ = EachIn MapKeys(texturesettings)
		AddGadgetItem texturequick,K
	Next
End Function

Function Tex_WPSave(P:TWorkPanel)
	Local I = SelectedGadgetItem(TextureBox); If I<0 Return
	Local Tex$ = GadgetItemText(TextureBox,I)
	Local SM:StringMap = New StringMap 
	DebugLog "Saving stuff into: "+GadgetItemText(TextureBox,I)
	Rem
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

	End Rem
	MapInsert SM, "ToolTab",String(SelectedGadgetItem(Tooltabber))
	MapInsert SM, "X",GadgetText(P.X)
	MapInsert SM, "Y",GadgetText(P.Y)
	MapInsert SM, "InsertX",GadgetText(P.InsX)
	MapInsert SM, "InsertY",GadgetText(P.InsY)
	MapInsert SM, "Width",GadgetText(P.W)
	MapInsert SM, "Height",GadgetText(P.H)
	MapInsert SM, "Kind",GadgetText(P.Kind)
	MapInsert SM, "Labels",GadgetText(P.Labels)
	MapInsert SM, "Dominance",GadgetText(P.Dominance)
	MapInsert SM, "Alpha",SliderValue(P.Alpha)+""
	MapInsert SM, "Impassible",ButtonState(P.Impassible)+""
	MapInsert SM, "ForcePassible",ButtonState(P.fcpassible)+""
	MapInsert SM, "Rotation",GadgetText(P.Rotation)
	MapInsert SM, "Color.R",GadgetText(P.R)
	MapInsert SM, "Color.G",GadgetText(P.G)
	MapInsert SM, "Color.B",GadgetText(P.B)
	MapInsert SM, "AnimSpeed",GadgetText(P.AnimSpeed)
	MapInsert SM, "Frame",GadgetText(P.Frame)
	MapInsert SM, "Scale.X",GadgetText(P.ScaleX)
	MapInsert SM, "Scale.Y",GadgetText(P.ScaleY)
	MapInsert SM, "Scale.Link",ButtonState(P.ScaleLink)+""
	
	MapInsert Texturesettings,tex,sm

	ResetTexList
	
End Function

Function Tex_WPLoad()
	Local I = SelectedGadgetItem(TextureQuick); DebugLog "Selected item: "+I; If I<0 Return
	Local Tex$ = GadgetItemText(TextureQuick,I)
	DeselectGadgetItem Texturequick,I
	Local SM:StringMap = gettexturesettings(tex)
	Local P:Tworkpanel
	Select SM.value("Kind")
		Case "TiledArea"
			P = TiledAreaData
		Case "Obstacle"
			P = ObstacleData
		Default
			Notify "This texture is asigned to kind ~q"+SM.Value("Kind")+"~q.~n~nEither that's not a valid Kthura kind, or it's not supported by this version of the Kthura Map Editor."
			Return		
	End Select
	If Not SM Return Notify("This texture contains no data.~nPerhaps something went wrong.")
	SelectGadgetItem Tooltabber,SM.value("ToolTab").toint()
	SetGadgetText P.X,SM.Value("X").toint()
	SetGadgetText P.Y,SM.Value("Y").toint()
	SetGadgetText P.insx,SM.Value("InsertX").toint()
	SetGadgetText P.insy,SM.Value("InsertY").toint()
	SetGadgetText P.w,SM.Value("Width").toint()
	SetGadgetText P.h,SM.Value("Height").toint()
	SetGadgetText P.Kind,SM.value("Kind")
	SetGadgetText P.Labels,SM.value("Labels")
	SetGadgetText P.Dominance,SM.Value("Dominance").toint()
	SetSliderValue P.Alpha,SM.Value("Alpha").todouble()
	SetButtonState P.Impassible,SM.Value("Impassible")="1"
	SetButtonState P.fcpassible,SM.Value("ForceImpassible")="1"
	SetGadgetText P.Rotation,SM.Value("Rotation").toint()
	SetGadgetText P.R,SM.Value("Color.R").toint()
	SetGadgetText P.G,SM.Value("Color.G").toint()
	SetGadgetText P.B,SM.Value("Color.B").toint()
	SetGadgetText P.AnimSpeed,SM.value("AnimSpeed").toint()
	SetGadgetText P.Frame,SM.Value("Frame").toint()
	SetGadgetText P.ScaleX,SM.Value("Scale.X")
	SetGadgetText P.ScaleY,SM.Value("Scale.Y")
	SetButtonState P.ScaleLink,SM.Value("Scale.Link")="1"
	
	Local I2 = -1
	For Local ak=0 Until CountGadgetItems(TextureBox)
		If GadgetItemText(TextureBox,ak)=tex I2=ak
	Next
	If I2<0
		Notify "I could not find the specific texture in the list.~nPossibly it's deleted."
	Else	
		SelectGadgetItem TextureBox,I2
	EndIf		

	ResetTexList
	updatetooltabber

End Function


