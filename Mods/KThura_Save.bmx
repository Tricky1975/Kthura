Rem
        KThura_Save.bmx
	(c) 2015, 2016, 2017 Jeroen Petrus Broks.
	
	This Source Code Form is subject to the terms of the 
	Mozilla Public License, v. 2.0. If a copy of the MPL was not 
	distributed with this file, You can obtain one at 
	http://mozilla.org/MPL/2.0/.
        Version: 17.01.16
End Rem

' 15.09.22 - A few adaptions to make animated texturing possible
' 16.01.07 - Scaling support added
' 16.05.08 - Blockmap grid can now be read from object file. This in order to have better support for multi-maps.
'          - Reading Blockmap grid is now deprecated for the settings file. I will still leave it in in order not to have to re-save all Star Story maps, but giant remakes of Kthura or ports to other languages will NOT support it. (In this save routine the feature is already removed) :)


Strict
Import "kthura_core.bmx"

Import jcr6.zlibdriver


MKL_Version "Kthura Map System - KThura_Save.bmx","17.01.16"
MKL_Lic     "Kthura Map System - KThura_Save.bmx","Mozilla Public License 2.0"


Rem
bbdoc: This type can be used to add extra data to Kthura. Most Kthura based games will not use it (unless you code them yourself to do so), but it can still be handy, especially for editor settings etc.
End Rem
Type T_Kthura_XSaveFunctions
	Rem
	bbdoc: Define the function used for saving in this field.
	End Rem
	Field Action(J:TJCRCreate)
	
	Rem
	bbdoc: You can name the stuff you save here, which can appear on the std-out. Just for debugging purposes.
	End Rem
	Field Name$
	
	
	Rem
	'' bbdoc: This will contain the JCR6 object Kthura is saving to. KthuraSave() defines this for you, and it's best not to assign any data to this yourself (unless you know what you are doing).
	'' Removed from docs, as I found out this one was not gonna work.
	End Rem
	' Field J:TJCRCreate
	
End Type


Rem
bbdoc: The list used by Kthura while saving.
End Rem
Global L_Kthura_XSaveFunctions:TList = New TList

Rem
bbdoc: Just a quick way to add extra actions. Kthura_Save() will execute them in the same order as they are added.
End Rem
Function KthuraSave_AddAction(Action(J:TJCRCreate),Name$="")	
	Local T:T_Kthura_XSaveFunctions = New T_Kthura_XSaveFunctions
	t.action=action
	t.name = name
	ListAddLast L_Kthura_XSaveFunctions,t
	Print "Extra save action added"
End Function


Private
Function F_GetCam(X Var,Y Var) x=0; Y=0 End Function
Public
Rem
bbdoc: This function allows you to tell Kthura the camera settings to save. Just create your function and assign it to this variable.
about: This function came to life to allow the editor to save the camera settings, and to also keep this available if alterante editors or a complete new version of the editor from scratch would ever come to be (Though I highly doubt the latter's gonna happen).
End Rem
Global Kthura_GetCam(X Var,Y Var)
Kthura_GetCam = F_GetCam


Rem
bbdoc: Saves the Kthura map
about: url can be either a filename or a TJCRCreate type. It's up to you if you save the blockmap by default, but it can save time if you do. By default all maps will be packed with "zlib". If you have JCR6 drivers for other compression ratios loaded ("lzma" for example if you got such a driver) you may use that in stead.
End Rem
Function SaveKthura(KMap:TKthura,url:Object,prefix:String="",SaveBlockMap=True,algorithm$="zlib")
Local BTO:TJCRCreate
Local BTE:TJCRCreateStream
If TJCRCreate(url) 
	BTO = TJCRCreate(url)
ElseIf String(url)
	BTO = JCR_Create(String(url))
	Else
	Return KthuraError("Kthura: Cannot save to that kind of object")
	EndIf
If Not KMap Return KthuraError("Kthura: Trying to save a null-map")
SaveStringMap bto,"Data",kmap.data,"zlib"
bte = bto.createentry(prefix+"Objects",algorithm)
WriteLine bte.stream,"-- Generated: "+CurrentDate()+"; "+CurrentTime()
If kmap.multi Then
	WriteLine bte.stream,"~n~nLAYERS"
	For Local K$=EachIn MapKeys(kmap.multi)
		WriteLine bte.stream,"~t"+k$
		Next
	WriteLine bte.stream,"__END"
	For Local K$=EachIn MapKeys(kmap.multi)
		WriteLine bte.stream,"~n~nLAYER = "+k$
		writelayer bte,kmap.getmultilayer(k)
		Next
	For Local Klay$=EachIn	MapKeys(kmap.multi)
		If kmap.getmultilayer(klay)=kmap WriteLine bte.stream,"~n~nLAYER = "+Klay+"~n-- This last definition will make sure the system will chose the layer given up as base when this file was saved."
		Next
Else
	Writelayer bte,kmap
	EndIf
bte.close	
bte = bto.createentry(prefix+"Settings",algorithm)
Local cx,cy
WriteLine bte.stream,"-- Generated: "+CurrentDate()+"; "+CurrentTime()
Kthura_GetCam cx,cy
WriteLine bte.stream,"CAM = "+cx+"x"+cy	
'WriteLine bte.stream,"BLOCKMAPGRID = "+KMap.blockmapgridw+"x"+KMap.BlockmapGridh
For Local KS:T_Kthura_XSaveFunctions = EachIn L_Kthura_XSaveFunctions
	If KS.Name Print "Kthura Save XTRA> "+KS.Name
	'KS.J = bto
	If Not KS.Action Then Print "WARNING! No action function!" Else KS.Action(bto)
Next	
bte.close	
BTO.CLOSE "zlib"	
End Function

Private
Function WriteLayer(bte:TJCRCreateStream,Layer:TKthura)
WriteLine bte.stream,"~nBLOCKMAPGRID = "+Layer.blockmapgridw+"x"+Layer.BlockmapGridh+"~n"
Local O:TKthuraObject
For O=EachIn Layer.fullobjectlist
	WriteLine bte.stream,"~n~nNEW"
	WriteLine bte.stream,"~tKIND = "+o.kind
	WriteLine bte.stream,"~tCOORD = "+o.X+","+o.y
	WriteLine bte.stream,"~tINSERT = "+o.InsertX+","+O.InsertY
	WriteLine bte.stream,"~tROTATION = "+o.rotation
	WriteLine bte.stream,"~tSIZE = "+o.w+"x"+o.h
	WriteLine bte.stream,"~tTAG = "+o.tag
	WriteLine bte.stream,"~tLABELS = "+o.labels
	WriteLine bte.stream,"~tDOMINANCE = "+o.dominance
	WriteLine bte.stream,"~tTEXTURE = "+o.Texturefile
	WriteLine bte.stream,"~tCURRENTFRAME = "+o.frame
	WriteLine bte.stream,"~tFRAMESPEED = "+Int(o.framespeed)
	'WriteLine bte.stream,"~tFRAMES = "+o.Frames       ' These two were already technically taken out of use. They will remain in the core for awhile (being deprecated) to prevent trouble with older maps.
	'WriteLine bte.stream,"~tFRAMESIZE = "+o.framewidth+"x"+o.frameheight      
	WriteLine bte.stream,"~tALPHA = "+o.alpha
	WriteLine bte.stream,"~tVISIBLE = "+o.visible
	WriteLine bte.stream,"~tCOLOR = "+o.r+","+o.g+","+O.b
	WriteLine bte.stream,"~tIMPASSIBLE = "+o.Impassible
	WriteLine bte.stream,"~tFORCEPASSIBLE = "+o.ForcePassible
	WriteLine bte.stream,"~tSCALE = "+O.ScaleX+","+O.ScaleY
	WriteLine bte.stream,"~tBLEND = "+O.AltBlend
	For Local dk$=EachIn MapKeys(o.data)
		WriteLine bte.stream,"~tDATA."+dk+" = "+Replace(o.data.value(dk),"=","<is>")
		Next
	Next
End Function
