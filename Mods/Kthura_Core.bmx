Rem
        Kthura_Core.bmx
	(c) 2015 Jeroen Petrus Broks.
	
	This Source Code Form is subject to the terms of the 
	Mozilla Public License, v. 2.0. If a copy of the MPL was not 
	distributed with this file, You can obtain one at 
	http://mozilla.org/MPL/2.0/.
        Version: 15.10.03
End Rem

' 15.08.15 - First version considered in 'Alpha' (though earlier releases exist, this is where the project has been declared safe enough to use, though keep in mind that stuff may still be subject to change)
'          - Documentation has been adapted to this new status in all three modules. (I will only make this notice in the core, but this one and the previous one goes for all mods in Kthura).
'          - Quick data access within a Kthura map done
'          - BUGFIX: The actor pic synchronizer returned null if a picture was already loaded. This has been fixed as it had to return the memory reference of the loaded picture already. (Trying to save memory, don't you sometimes just hate it) :)
'          - BUGFIX: Auto hotspot bottom center for single pic actors. I forgot to set this right ;)
' 15.09.10 - DEBUG: Added a feature to list out all picture tags tied to an actor
' 15.09.12 - Cam Setting will now only be reported in the debug build
' 15.09.16 - IgnoreBlocks ignored by MoveTo. Not any more.
' 15.09.22 - A few tiny core adaptions to make animated texturing possible (though the draw mode has to deal with it more) :)
' 15.09.23 - "ForcePassible" support
' 15.09.29 - Negative dominance blocked
' 15.10.03 - DataDump() debug function added. I don't know why, but I need it now (for a bug that can't possibly come to be).


Strict
Import tricky_units.MKL_Version
Import jcr6.zlibdriver
Import brl.max2d
Import tricky_units.jcr6stringmap
Import tricky_units.Listfile
Import tricky_units.HotSpot
Import tricky_units.Pathfinder
Import tricky_units.serialtrim

MKL_Version "Kthura Map System - Kthura_Core.bmx","15.10.03"
MKL_Lic     "Kthura Map System - Kthura_Core.bmx","Mozilla Public License 2.0"


Rem
bbdoc: This function is called whenever an error occurs within Kthura. If you want you can replace this function in order to create your own error routines for Kthura.
End Rem
Global KthuraError(ErrMessage$)

Rem
bbdoc: This function is called whenever Kthrura sends out a warning. If you want you can replace this function in order to create your own warning routines for Kthura.
End Rem
Global KthuraWarning(WarnMessage$)

Rem 
bbdoc: This function can be used to allow the Kthura loader to define the camera by the map settings in the map file. Just replace it with your own function to make this happen.
about: This function is only meant for editors. If you are not writing an editor, you can best ignore this function.
End Rem
Global Kthura_SetCam(X,Y)

Private
Const debugchat = True

Function DefaultKthuraError(ErrMessage$)
Print "KTHURA ERROR: "+ErrMessage
End Function
KthuraError = DefaultKthuraError

Function DefaultKthuraWarning(WarnMessage$)
Print "KTHURA WARNING: "+WarnMessage
End Function
KthuraWarning = DefaultKthuraWarning

Function Default_SetCam(X,Y) End Function
Kthura_SetCam = default_setcam

Public 

Rem
bbdoc: This type contains data of an object within a Kthura map. 
End Rem
Type TKthuraObject 
	Field IDNum
	Field Kind$
	Field Tag$
	Field x,y,w,h
	Field Labels$
	Field Dominance=20
	Field TextureFile$
	Field TextureImage:TImage
	Field LoadTried
	Field Frame
	Field Frames,FrameWidth,FrameHeight
	Field FrameSpeed = -1
	Field framespeedticker
	'Field AnimationSpeed = -1 ' This setting automatically sets older objects not supporting animation. The editor will by default set this value to 4.
	Field InMotion = True
	Field PlusX,PlusY,MinusX,MinusY
	Field Rotation
	Field InsertX,InsertY
	Field R=255,G=255,B=255
	Field Alpha:Double = 1
	Field Impassible = 1
	Field ForcePassible = 0 ' Forces the blockmap builder to create a path, even if the other objects blocked it already. Only works on TiledAreas and Zones.
	Field Visible = True
	Field Data:StringMap = New StringMap
	Field Parent:TKthura	
	
	Rem
	bbdoc: Moves an object.
	about: You won't have to remap the drawmaps as that will happen automatically, however rebuilding the blockmap can be in order, which will happen here. If you want to make multiple movements you can turn it off, but then it will have to happen after the last change you make or the way the player can or cannot walk to will act very strangely.
	End Rem
	Method Move(nx,ny,updateblockmap=True)
	MapRemove Parent.DrawMap,Hex(dominance)+"."+Hex(Y)+"."+Hex(idnum)
	X = nx
	Y = ny
	MapInsert parent.drawmap,Hex(dominance)+"."+Hex(Y)+"."+Hex(idnum),Self
	If updateblockmap parent.BuildBlockmap
	End Method
	
	Rem
	bbdoc: Set the a new size for the object.
	End Rem
	Method ReShape(nw,nh,updateblockmap=True)
	w = nw
	h = nh
	If updateblockmap parent.BuildBlockmap
	End Method
	
	Rem
	bbdoc: Moves and reshapes.
	End Rem
	Method Reform(nx,ny,nw,nh,UpdateBlockMap=True)
	Move nx,ny,False ' Don't build the blockmap twice, that only eats performance for no reason at all.
	ReShape nw,nh,updateblockmap
	End Method
	
	Rem
	bbdoc: Assign data to a Kthura object
	End Rem
	Method DataDef(FieldName$,Value$)
	MapInsert data,fieldname,value
	End Method
	
	Rem
	bbdoc: Alias for DataDef
	End Rem
	Method DataSet(F$,V$) 
	datadef f,v 
	End Method
	
	Rem
	bbdoc: Retrieve data from a Kthura Object
	End Rem
	Method DataGet$(FieldName$)
	Return Data.Value(fieldName)
	End Method
	
	Rem 
	bbdoc: Dumps all data fields
	about: This function is soley meant for debugging purposes
	End Rem
	Method DataDump$()
	Local ret$
	For Local k$=EachIn MapKeys(data)
		ret:+k+"="+data.value(k)+"; "
		Next
	Return ret
	End Method
	
	End Type
	
	
Private 
Global UKthura:TKthura
Function KAB3(X,Y)
If Not UKthura Print "WARNING! No Map to give to an actor walkto"; Return ' Ignore if not set
If X>ukthura.blockmapboundW Return True
If Y>ukthura.blockmapboundH Return True
If X<0 Return True
If Y<0 Return True
Return ukthura.blockmap[X,Y]
End Function

Public
Rem
bbdoc: This type is used for actors in a Kthura Map. It's an extended TKthuraObject as actors have some additional data which you won't need in the other objects.
End Rem	
Type TKthuraActor Extends TKthuraObject
	Field SinglePicFile$,PicBundleDir$
	Field SinglePic:TImage
	Field PicBundle:TMap
	Field ChosenPic$
	Field InMotion = False
	Field NotInMotionThen0 = True
	Field Walking
	Field WalkingIsMotion = True
	Field WalkX, WalkY
	Field Moving,MoveIgnoreBlock
	Field UnMoveTimer = 4
	Field MoveX, MoveY
	Field MoveSkip = 4
	Field FrameSpeed = 4
	Field FrameSpeedCount
	'Field WalkSkip = 4 'no longer needed
	Field WalkSpot = 0
	Field Wind$ = "North"
	Field WalkingToX,WalkingToY	
	Field FoundPath:PathFinderUnit
	Field PathLength
	Field Cycle = -1
	
	Rem
	bbdoc:Will return a string containing all pictures tied to an actor as a string (with ; as separators).<br>This only works on picbundle actors.
	End Rem
	Method HavePics$()
	Local ret$
	For Local k$=EachIn MapKeys(Picbundle)
		If ret ret:+";"
		ret:+k
		Next
	End Method	
	
	Rem
	bbdoc: Increases frame of the current picture
	End Rem
	Method IncFrame(IncValue=1)
	Local I:TImage
	If SinglePicfile
		I = SinglePic
	Else
		If ChosenPic 
			I = TImage(MapValueForKey(PicBundle,ChosenPic))
			EndIf
		EndIf
	If Not I Return
	Frame:+IncValue
	If Frame>=Len(I.Pixmaps) Frame:-Len(I.Pixmaps)
	If Frame<0 Frame=0 ' Basically it should be impossible for the frame to get lower than 0, but I've seen crazier things, so this safety precaution was still in order.		
	End Method
	
	
	Rem
	bbdoc: Makes an actor walk to a target position.
	about: If the target coordinates are impossible to reach, your request will simply be ignored.
	End Rem
	Method WalkTo(TX,TY)
	UKthura = parent
	PF_Block = KAB3
	SetUpPathFinder 1, parent.BlockMapboundW, parent.BlockMapBoundH
	'DebugLog "Trying make an actor walk."
	'DebugLog "= Original X: "+ x+" >> "+Floor(X/Parent.BlockMapGridW)	
	'DebugLog "= Original Y: "+ y+" >> "+Floor(Y/Parent.BlockMapGridH)	
	'DebugLog "= Target   X: "+tx+" >> "+Floor(TX/Parent.BlockMapGridW)	
	'DebugLog "= Target   Y: "+ty+" >> "+Floor(TY/Parent.BlockMapGridH)	
	Local p:PathFinderUnit = FindTheWay(Floor(X/Parent.BlockMapGridW)		,Floor(Y/Parent.BlockMapGridH)		,Floor(TX/Parent.BlockMapGridW)		,Floor(TY/Parent.BlockMapGridH)		)
	If p.success
		walkspot=0
		FoundPath = p
		Walking = True
		WalkX = TX
		WalkY = TY
		Pathlength = LengthWay(p)
		EndIf
	End Method
	
	
	Rem
	bbdoc: Makes the character walk to a target position
	about: Contrary to WalkTo, MoveTo uses a rather primitive way to find the way and the character will not be able to find the way when there are obstacles in the way. The character will simply stop moving upon touching those. An advantage of this routine is that it's able to be more precize than WalkTo. Please note the routine should not be used when the character is already walking with WalkTo, or you may get some very odd behavior.
	End Rem
	Method MoveTo(TX,TY,TIgnoreBlocks=False)
	Moving = True
	MoveX = TX
	MoveY = TY
	MoveIgnoreBlock = TIgnoreBlocks
	End Method
	
	End Type
	
	
	
Type TKthuraMap Extends TMap
	
	Method Get:TKthuraObject(Tag$)
	Return TKthuraObject(MapValueForKey(Self,tag))
	End Method
	
	End Type
	
Type tkthuraListmap Extends TMap
	
	Method List:TList(Tag$,CIN=1)
	If CIN If Not MapContains(Self,tag) MapInsert Self,tag,New TList
	Return TList(MapValueForKey(Self,tag))
	End Method
	
	End Type
	
Type TKthuraImageMap Extends TMap
	
	Method Img:TImage(Tag$)	
	Return TImage(MapValueForKey(Self,Upper(tag)))
	End Method
	
	Method Load:TImage(JCR:TJCRDir,File$,Prefix$,StandardHot$="")
	If MapContains(Self,Upper(Prefix+":"+File)) Return TImage(MapValueForKey(Self,Upper(Prefix+":"+File)))
	Local hotf$ = StripExt(file)+".hot"
	Local anim$ = StripExt(file)+".frames"
	Local w,h,s,f,RL$,RS$[],I:TImage
	If JCR_Exists(JCR,anim)
		RL = Trim(LoadString(JCR_B(JCR,anim)))
		RS = RL.Split(",")
		If Len(RS)>=4
			w = Trim(RS[0]).toint()
			h = Trim(RS[1]).toint()
			s = Trim(RS[2]).toint()
			f = Trim(RS[3]).toint()
			I = LoadAnimImage(JCR_B(JCR,File),w,h,s,f)
			EndIf			
	Else
		DebugLog "Loading image for Kthura Image map: "+File
		If Not file KthuraError "Request done to load an image into a Kthura Image map, but no filename was defined"
		I = LoadImage(JCR_B(JCR,File))
		EndIf
	If Not I 
		KthuraWarning "Kthura.Image.Load: Image loader failed to load: "+File
		Return	
		EndIf
	'Print "Hotspot for "+Prefix+":"+File+" = "+StandardHot	
	Select StandardHot
		Case "BOTTOMCENTER"
			HotSpot I,2,1
			End Select
	If JCR_Exists(JCR,hotf)
		RL = Trim(LoadString(JCR_B(JCR,hotf)))
		RL = Replace(RL,"#WC#",Int(ImageWidth(I)/2))
		RL = Replace(RL,"#HC#",Int(ImageHeight(I)/2))
		RL = Replace(RL,"#WE#",Int(ImageWidth(I)))
		RL = Replace(RL,"#HE#",Int(ImageHeight(I)))	
		If Left(RL,5)="@HOT:"
			RS=Replace(RL,"@HOT:","").Split(",")
			If Len(RS)>=2
				HotSpot I,RS[0].toint(),RS[1].toint()
				EndIf
		ElseIf RL="@HOTCENTER"
			HotCenter I
		ElseIf RL="@HOTEND"
			HotEnd I
		Else
			RS = RL.Split(",")
			SetImageHandle I,RS[0].toint(),RS[1].toint()	
			EndIf			
		EndIf
	MapInsert Self,Upper(Prefix+":"+file),I
	DebugLog "Picture stored "+Prefix+":"+file
	Return I
	End Method
	
	End Type


Type tkthuralabelmap Extends TMap

	Method Get:TKthuramap(Label$,CreateIfNew=False) 
	If createifnew And (Not MapContains(Self,label)) MapInsert Self,label, New tkthuramap
	Return tkthuramap(MapValueForKey(Self,label)) 
	End Method
	

	
	End Type
	
	
Rem 
bbdoc: This type is used to store a level set up in Kthura.  
End Rem
Type TKthura 
	Field data:StringMap = New StringMap
	Field FullObjectList:TList = New TList
	Field DrawMap:TKthuramap = New TKthuramap
	Field LabelMap:TKthuralistmap = New TKthuralistmap
	Field ForeignMap:TKthuralistMap = New TKthuralistmap
	Field TagMap:TKThuramap = New TKThuramap
	Field TagMapByLabel:TkthuraLabelMap = New TKThuraLabelMap
	Field Cycle:Long = 0
	
	Field textures:TKthuraImageMap = New TKThuraImageMap
	
	Field TextureJCR:TJCRDir
	
	Field BlockMapGridW = 32
	Field BlockMapGridH = 32
	Field BlockMapBoundW = 100
	Field BlockMapBoundH = 100
	
	Field BlockMap:Byte[,] = New Byte[100+1,100+1]
	
	Method CreateObject:TKthuraObject(Update=True)
	Local ret:TKthuraObject = New TKthuraObject
	ret.parent = Self
	Local o:TKthuraObject
	For o=EachIn FullObjectList
		If o.IDNum>=ret.idnum ret.idnum=o.idnum+1
		Next
	ListAddLast fullobjectlist,ret
	If update TotalRemap
	Return ret		
	End Method
	
	Rem
	bbdoc: Look up the general data inside a Kthura map
	returns: A string containing the data. If the data does not exist, an empty string is returned
	End Rem
	Method GetData$(key$)
	Return data.value(key)
	End Method
	
	Rem
	bbdoc: Define data inside a Kthura map.
	End Rem
	Method SetData(key$,Value$)
	MapInsert data,key,value
	End Method
	
	Rem
	bbdoc: Is a coordinate within an object or not.
	about: This function will check based on the object type if a coordinate is within an object or not. <p>Currently supported objects: Zone, TiledArea, Obstacle.
	returns: True if this is the case, and False if not. (duh)<p>Unsupported object types will always return False
	End Rem
	Method CoordInObject(KObject:TKthuraObject,x,y)
	Local s
	Select KObject.Kind
		Case "Zone","TiledArea"
			Return x>=KObject.x And x<=KObject.x+KObject.w And y>=KObject.y And y<=KObject.y+KObject.h
		Case "Obstacle"
			If Not kobject.textureimage Return
			s = ImageWidth(kobject.textureimage)
			Return x>=KObject.x-(S/2) And X<=KObject.x+(S/2) And y>=KObject.y-ImageHeight(KObject.textureimage) And y<=KObject.y
		End Select
	End Method
	
	Rem
	bbdoc: Retrieve an object from a tag and performs a check if the coordinate is within the object or not.
	returns: True if this is the case, and False if not. (duh)
	End Rem	
	Method CoordInObjectFromTag(Tag$,x,y)
	Local O:TKthuraObject = tagmap.get(Tag)
	If Not O Return Print("WARNING! <TKthura>. CoordInObjectFromTag("+Tag+","+x+","+y+"): There is no object with tag: "+Tag)
	Return CoordInObject(O,x,y)
	End Method
	
	Rem
	bbdoc: Creates an actor on the given coordinates and returns it.
	about: SorB means 'single' or 'bundle'. 0 = single and 1 = bundle. A single picture can be animated, but it is only one picture. A bundle is read from an entire JCR6 directory and the files are stored stripped from the full path name and picture extention (case insensitive) in a library tied to this picture. I need to note that if the bundle contains MyPicture.png and MYPICTURE.JPG that they will both stored on the same spot and that the last one read (due to the alphabetic nature of JCR6 that will be MyPicture.png) will be kept. Keep this very important part in mind! (Also note that the Pic Bundle reader does not find the files recursively)
	End Rem
	Method CreateActor:TKthuraActor(X,Y,Pics$,Tag$,SorB=1,Update=True)
	Local ret:TKthuraActor = New TKthuraActor
	ret.parent = Self
	Local o:TKthuraObject
	For o=EachIn FullObjectList
		If o.IDNum>=ret.idnum ret.idnum=o.idnum+1
		Next
	ListAddLast fullobjectlist,ret
	ret.kind = "Actor"
	ret.x = x
	ret.y = y
	ret.Tag = Tag
	SyncActorPics ret,Pics,SorB
	If update TotalRemap;
	Return ret
	End Method
	
	Rem
	bbdoc: Renews an actor with the same data. It's a bit of a "filthy" way to fixing some bugs that can pop up in an actor after moving it. The "Actor" can either be the actors tag, or the existing Kthura object. Please note the actor MUST be part of the map this method is tied upon. "Foreign" actors are not accepted!<p>This feature will just use some basic data to renew the actor (this was the entire point as faulty actors are very likely created from some extra data), meaning that some data inside the actor WILL get lost.
	End Rem
	Method RenewActor:TKthuraActor(actor:Object,Update=True)
	Local AT$ = "<Actor>"
	Local Ret:TKthuraActor
	Local A:TKthuraActor = TKthuraActor(Actor)
	If Not A And String(actor) 
		A = TKthuraActor(tagmap.get(String(actor)))
		AT = "~q"+String(actor)+"~q"
		If Not A Then KthuraError "RenewActor("+AT+"): Actor not found!"
		End If
	If Not A KthuraError "RenewActor(???): Requested Actor type not recognized"; Return
	If A.parent<>Self KthuraError "RenewActor(<Actor>): Requested actor not tied to the requested map"; Return
	ListRemove fullobjectlist,A
	If A.Tag MapRemove tagmap,A.Tag
	If A.PicBundle
		ret = createactor(A.X,A.Y,A.PicBundleDir ,A.Tag,1,update)		
	ElseIf A.SinglePic
		ret = Createactor(A.X,A.Y,A.SinglePicFile,A.Tag,1,update)
	Else
		KthuraError "RenewActor("+AT+"): No picture data found in actor! (Broken actor?)"
		EndIf
	ret.dominance = a.dominance	
	End Method	
	

	Method SyncActorPics(ret:TKthuraActor,Pics$,SorB)
	Local PicList$,Ex$
	Local I:TImage
	Local PicPrefix$ = "Actor.Bundle"
	Select SorB
		Case 1
			PicList = Upper(Replace(Pics,"\","/"))			
			If Right(PicList,1)="/" Print "WARNING! A picbundle request may not end with '/'"
			ret.PicBundleDir = Pics
			ret.PicBundle = New TMap
			For Local F$=EachIn MapKeys(TextureJCR.Entries)
				Ex = ExtractExt(F)
				If (Ex="PNG" Or Ex="JPG" Or Ex="JPEG" Or Ex="BMP") And ExtractDir(F)=PicList ' Please note that the respective loaders must be imported or none of these extentions will work. If you use Brucey's picture loader in stead allowing more picture types you may need to add their respective extentions to this list (I never tried Brucey's module in combination with JCR6, but if Brucey's module supports reading pictures from memory banks it will support reading pictures from JCR6).
					I = Textures.Load(TextureJCR,F,PicPrefix,"BOTTOMCENTER")
					If Not I I = Textures.Img("Actor.Bundle:"+F)
					If Not I
						KthuraWarning "CreateActor: Loading picture '"+F+"' failed!"
					Else
						MapInsert ret.Picbundle,StripAll(F),I
						EndIf
					EndIf										
				Next
		Default
			If SorB<>0 Print "WARNING! Unknown SorB code found ("+SorB+") using the single picture setting in stead"
			ret.SinglePic = Textures.Load(TextureJCR,Pics,"Actor.Single","BOTTOMCENTER")
			ret.SinglePicFile = Pics
		End Select	
	End Method
	
	
	Method RemoveObjectkind(kind$)
	For Local o:TKthuraObject=EachIn fullobjectlist
		If o.kind=kind ListRemove fullobjectlist, o
		Next
	TotalRemap
	End Method
	
	
	Rem
	bbdoc: Remove all actors from a Kthura map
	End Rem
	Method RemoveActors()
	RemoveObjectkind "Actor"
	End Method
	
	Rem	
	bbdoc: Creates an actor by using an 'entrace' or 'exit' spot.
	about: In basic speaking, ANY object can be used as a start spot, as long as it has a tag (as that what we respond to here). Though it's recommended to ONLY use entrance/exit points as you may turn things into chaos if you don't. (Please note "Spot" refers to the tag of the object we should spawn upon. "Tag" refers to the tag of the actor itself).<p>The advantage of this routine that it also copies the dominance setting and some other data tied to the entrance point.
	End Rem
	Method SpawnActor:TKthuraActor(Spot$,Pics$,Tag$,SorB=1,Update=True)
	Local SpawnExit:TKthuraObject = TagMap.Get(Spot)
	If Not SpawnExit KthuraError "Cannot spawn an actor on a spot that does not exist! ("+Spot+")"; Return	
	?debug
	?debug
	Local sorbn$[] = ["Single","Bundle"]
	DebugLog "I have to spawn an actor on spot: "+spot
	DebugLog "= Coordinates:  "+SpawnExit.X+","+SpawnExit.Y
	DebugLog "= Tag:          "+Tag
	DebugLog "= Picture file: "+Pics
	DebugLog "= SorB:         "+SorB+" ("+sorbn[sorb]+")"
	DebugLog "= Update:       "+Update
	DebugLog "= Let's go!"
	?
	Local ret:TKthuraActor = createactor(SpawnExit.X,SpawnExit.Y,Pics,Tag,Sorb,update)
	ret.dominance = spawnexit.dominance
	ret.R = spawnexit.R
	ret.G = spawnexit.G
	ret.B = spawnexit.B
	ret.Impassible = spawnexit.impassible
	ret.alpha = spawnexit.alpha
	ret.labels = spawnexit.labels
	If spawnexit.data.value("Wind") ret.wind=spawnexit.data.value("Wind")
	Return ret
	End Method
	
	Rem
	bbdoc: This function recalculates the entire drawmap. 
	about: This function can when you use it a lot slow down your program performance so it should only be used when you need to.<p>When a new object is created this function is called automatically. Because of that it can sometimes be a faster solution to have all objects created from the start but have them outside of the screen and move them in screen, in stead of creating objects in-game real-time.
	End Rem
	Method RemapDrawMap()
	ClearMap drawmap
	For Local O:TKthuraObject=EachIn fullobjectlist
		If o.dominance<0 
			o.dominance = 0
			KthuraWarning "Negative dominance value in object #"+O.IDNum+" has been set to zero."
			EndIf
		MapInsert drawmap,Hex(O.dominance)+"."+Hex(+O.Y)+"."+Hex(O.idnum),O
		Next
	End Method

	Rem
	bbdoc: This function recalculates the entire label map and foreign map
	about: This function can when you use it a lot slow down your program performance so it should only be used when you need to.<p>When a new object is created this function is called automatically. Because of that it can sometimes be a faster solution to have all objects created from the start but have them outside of the screen and move them in screen, in stead of creating objects in-game real-time.
	End Rem
	Method RemapLabelMap()
	ClearMap Labelmap
	ClearMap Tagmapbylabel	
	ClearMap ForeignMap
	Local labs$[],labs2$[],ck$,ck2$,foreign
	' Label Map
	For Local O:TKthuraObject=EachIn fullobjectlist
		labs = O.Labels.split(",")
		For Local L$=EachIn labs
			'MapInsert Labelmap,Trim(L),O
			ListAddLast labelmap.list(Trim(L)),O
			MapInsert TagMapByLabel.Get(Trim(L),True),Hex(O.dominance)+"."+Hex(+O.Y)+"."+Hex(O.idnum),O
			Next
		Next
	' Foreign map
	For Local O:TKthuraObject=EachIn fullobjectlist
		labs = o.labels.split(",")
		If O.kind="TiledArea" Or O.kind="Zone"
			For Local O2:TKthuraObject=EachIn fullobjectlist
				labs2 = o2.labels.split(",")
				For ck=EachIn labs For ck2=EachIn labs2
					If Trim(ck)<>Trim(ck2) And (Not o.impassible) And (Not o2.impassible) 
						foreign = False
						foreign = foreign Or (o.x>o2.x-32 And o.x<o2.x+32)
						foreign = foreign Or (o.y>o2.y-32 And o.y<o2.y+32)
						foreign = foreign Or (o.x+o.w>o2.x-32 And o.x+o.w<o2.x+32)
						foreign = foreign Or (o.y+o.h>o2.y-32 And o.y+o.h<o2.y+32)
						foreign = foreign Or (o.x>(o2.x+o2.w)-32 And o.x<(o2.x+o2.w)+32)
						foreign = foreign Or (o.y>(o2.y+o2.h)-32 And o.x<(o2.y+o2.h)+32)
						foreign = foreign Or (o.x+o.w>(o2.x+o2.w)-32 And o.x+o.w<(o2.x+o2.w)+32)
						foreign = foreign Or (o.y+o.h>(o2.y+o2.h)-32 And o.y+o.h<(o2.y+o2.h)+32)
						If foreign And (Not ListContains(foreignmap.list(Trim(ck2)),O)) ListAddLast foreignmap.list(Trim(ck2)),O
						EndIf
					Next Next ' 2x for = 2x next
				Next
			EndIf
		Next		
	End Method
	
	Rem
	bbdoc: This function recalculates the entire tagmap. 
	about: This function can when you use it a lot slow down your program performance so it should only be used when you need to.<p>When a new object is created this function is called automatically. Because of that it can sometimes be a faster solution to have all objects created from the start but have them outside of the screen and move them in screen, in stead of creating objects in-game real-time.
	End Rem
	Method RemapTagMap()
	ClearMap Tagmap
	For Local O:TKthuraObject=EachIn fullobjectlist
		If MapContains(Tagmap,O.Tag) KthuraError "Duplicate object tag: "+O.Tag
		If o.tag MapInsert tagmap,O.Tag,O
		Next	
	End Method
	

	
	
	Rem
	bbdoc: Remaps everything.
	about: Using this too much may slow down your game, so only use this when you really need to.
	End Rem
	Method TotalRemap()
	RemapDrawMap()
	remaplabelmap()
	remaptagmap()
	BuildBlockMap()
	End Method
	
	Rem
	bbdoc: Gets an object through searching by ID number. 
	about: Returns the object if it exists, otherwise it returns 0. 
	End Rem
	Method GetObjectByID:TKthuraObject(ID)	
	For Local O:TKthuraObject = EachIn fullobjectlist
		If O.idnum = ID Return O
		Next
	End Method
	
	Rem
	bbdoc: Gets an object by searching for a tag!
	End Rem
	Method GetObjectByTag:TKthuraObject(Tag$)
	Return tagmap.get(Tag$)
	End Method
	
	Rem
	bbdoc: Sets a new tag. 
	about: Each tag must be unique. Giving this object a tag which already exists will cause an error.<p>You don't need to remap the tags, as this routine will automatically update the tagmap and in a faster manner than #RemapTagMap does too.<p>Oh yeah, tags are case sensitive!
	End Rem
	Method GiveTag(O:TKthuraObject,tag$)
	If Not O KthuraError "Cannot tag null!"
	If Not ListContains(fullobjectlist,O) KthuraError "GiveTag: Object not part of this map!"
	If O.Tag MapRemove Tagmap,O.Tag
	O.Tag = Tag
	If MapContains(TagMap,O.Tag) Return KthuraError("Tag ~q"+Tag+"~q already exists")
	If O.Tag MapInsert TagMap,O.Tag,O
	End Method		
	
	Rem
	bbdoc: Finds an object with a certain tag and gives it a new tag.
	End Rem
	Method ReTag(OldTag$,NewTag$)
	givetag tagmap.get(oldtag),newtag
	End Method
	
	Rem
	bbdoc: Builds the blockmap. 
	about: This can happen automatically when placing, removing, moving or reshaping any object. Please note that overusing this will slow down the performance. Most functions calling this can be instructed not to do so and so you can save it for last if you do multiple modifications.<p>Please note that objects with coordinates lower than 0 will have the coordinates set to 0 in the blockmap calculation. There is no official limit in the height of coordinates, but please keep in mind that going overboard in that, can be very demanding on your memory.<p>The blockmap builds the map on a 32x32 pixel grid by default. You can set the BlockmapGridW and BlockMapGridH variables (which are field vars of your tKthura map) to adjust this, please keep in mind, the lower the number, the more memory this will take up, so handle with care.
	End Rem
	Method BuildBlockmap()
	Local O:TKthuraObject
	Local GW = BlockMapGridW
	Local GH = BlockMapGridH
	Local X,Y,W,H,BX,BY,TX,TY,AX,AY,TW,TH
	Local BoundX,BoundY
	Local iw,tiw
	' Let's first get the bounderies
	For O=EachIn fullobjectlist
			X = O.X;   If X<0 X=0
			Y = O.Y;   If Y<0 Y=0
			W = O.W-1; If W<0 W=0
			H = O.H-1; If H<0 H=0
			Select O.kind
				Case "TiledArea","Zone"
					TX = Ceil((X+W)/GW)
					TY = Ceil((Y+H)/GH)
					If TX>BoundX BoundX=TX
					If TY>BoundY BoundY=TY
				Case "Obstacle"
					TX = Floor(X/GW)
					TY = Floor(Y/GH)						
					If TX>BoundX BoundX=TX
					If TY>BoundY BoundY=TY						
				End Select
		Next
	BlockMapBoundW = BoundX
	BlockMapBoundH = BoundY
	Blockmap = New Byte[BoundX+1,BoundY+1]	
	' And now for the REAL work.		
	For O=EachIn fullobjectlist If O.impassible
		X = O.X;   If X<0 X=0
		Y = O.Y;   If Y<0 Y=0
		W = O.W-1; If W<0 W=0
		H = O.H-1; If H<0 H=0
		Select O.Kind
			Case "TiledArea","Zone"
				TX = Floor(X/GW)
				TY = Floor(Y/GH)						
				TW = Ceil((X+W)/GW)
				TH = Ceil((Y+H)/GH)
				'Print "DEBUG: Blockmapping area ("+TX+","+TY+") to ("+TW+","+TH+")"
				For AX=TX To TW
					For AY=TY To TH
						Blockmap[ax,ay]=True
						Next
					Next
			Case "Obstacle"
				TX  = Floor( X   /GW)
				TY  = Floor((Y-1)/GH)		
				blockmap[tx,ty]=True			
				If o.textureimage
					iw  = ImageWidth(o.textureimage)
					tiw = Ceil(iw / GW)-1
					For ax=TX-(tiw) To tx+(tiw)
						If ax>=0 And ax<=BoundX And ty<=boundy And ty>=0 blockmap[ax,ty]=True 
						Next
					EndIf	
			End Select					
		EndIf Next
	' And this will force a way open if applicable	
	For O=EachIn fullobjectlist If O.ForcePassible
		X = O.X;   If X<0 X=0
		Y = O.Y;   If Y<0 Y=0
		W = O.W-1; If W<0 W=0
		H = O.H-1; If H<0 H=0
		Select O.Kind
			Case "TiledArea","Zone"
				TX = Floor(X/GW)
				TY = Floor(Y/GH)						
				TW = Ceil((X+W)/GW)
				TH = Ceil((Y+H)/GH)
				'Print "DEBUG: Blockmapping area ("+TX+","+TY+") to ("+TW+","+TH+")"
				For AX=TX To TW
					For AY=TY To TH
						Blockmap[ax,ay]=False
						Next
					Next
			End Select					
		EndIf Next
	End Method
	
	Rem
	bbdoc: False if a pixel is free, True if a pixel is blocked.
	about: Please note that this method only works well, if the blockmap is built (or loaded from a kthuramap). This one works it out from the pixel, not the BlockMap Grid, however, the smaller the grid, the more precize this feature becomes (although it's more memory eating, so think well where you put your emphasis).
	End Rem
	Method Block(X,Y)
	Local GW = BlockMapGridW
	Local GH = BlockMapGridH
	Local TX = Floor(X/GW)
	Local ty = Floor(Y/GH)
	Local BX = blockmapboundW 
	Local BY = blockmapboundH
	If TX<0	Return True
	If TY<0	Return True
	If TX>BX	Return True
	If TY>BY	Return True
	Return Blockmap[tx,ty]
	End Method
	
	Rem
	bbdoc: Counts all actors currently walking (basically what the name implies).
	End Rem
	Method CountWalkingActors()
	Local ret=0
	For Local A:TKthuraActor=EachIn FullObjectList
		If A.Walking ret:+1
		Next
	Return ret
	End Method

	Rem
	bbdoc: Counts all actors currently moving. (Actors set on the move with both WalkTo and MoveTo will be counted).
	End Rem
	Method CountMovingActors()
	Local ret=0
	For Local A:TKthuraActor=EachIn FullObjectList
		If A.Moving ret:+1
		Next
	Return ret
	End Method
	
	Method VisibleByLabel(lab$,VisBoolean,unique)
	Local o:TKthuraObject
	Local cl$
	Local reqlab:TList = ListFromArray(TrimSplit(lab,","))
	Local ok
	For o = EachIn fullobjectlist
		ok=False
		For cl=EachIn reqlab
			ok = ok Or ListContains(ListFromArray(TrimSplit(o.labels,",")),cl)
			Next
		If ok
			o.visible = visboolean
			'Print "showing #"+o.idnum
		ElseIf unique
			o.visible = Not visboolean
			'Print "hiding #"+o.idnum
			EndIf	
		Next		
	End Method
	
	Rem
	bbdoc: Shows all objects containing a certain label.
	about: All labels should be in one string separated by commas.
	End Rem
	Method ShowLabel(labels$)
	VisibleByLabel labels,True,False
	End Method
	
	Rem 
	bbdoc: Show all objects only containing the labels
	End Rem
	Method ShowOnlyLabel(Labels$)
	VisibleByLabel labels,True,True
	End Method
	
	Rem
	bbdoc: Shows all objects containing a certain label.
	about: All labels should be in one string separated by commas.
	End Rem
	Method HideLabel(labels$)
	VisibleByLabel labels,False,False
	End Method
	
	
	End Type


Rem
bbdoc: Load Kthura map
about: File can be either a file name or a TJCRDir map. The prefix is mostly used for entering pathname within the JCR file in which the the Kthura map has been stored. AltTextJCR can be used if you used a separate JCR file or a regular directory to store your textures. Personally I only placed it in to make this routine work well with the editor, since if your maps and textures are in the same JCR file, you should just ignore this parameter!
End Rem
Function LoadKthura:TKthura(url:Object,prefix$="",AltTextJCR:TJCRDir=Null)
Local JCR:TJCRDir
Local ret:TKthura = New TKthura
Local RL$,L$,SL$[],DL$[],ak,cl,o:TKthuraObject
If TJCRDir(url) 
	JCR = TJCRDir(url)
ElseIf String(url)
	JCR = JCR_Dir(String(url))
	If Not jcr KthuraError "JCR6 could apparently not read the file. What is wrong here?"; Return
ElseIf Not url
	?debug
	Throw "LoadKthura(Null,~q"+Prefix+"~q): I cannot load a map from a Null object!"
	?Not debug
	KthuraError "LoadKthura(Null,~q"+Prefix+"~q): I cannot load a map from a Null object!"
	?
	Return	
Else
	?debug
	Throw "LoadKthura(<????>,~q"+Prefix+"~q): I can only load a map from a filename or a TJCRDir type object.~nThe variable give appears to be neither."
	?Not debug
	KthuraError "LoadKthura(<????>,~q"+Prefix+"~q): I can only load a map from a filename or a TJCRDir type object.~nThe variable give appears to be neither."
	?
	Return
	EndIf	
' Let's check if all the files we need are actually there.	
Local Musthave$[] = ["Data","Objects"]
For Local MH$=EachIn Musthave
	If Not JCR_Exists(JCR,prefix+MH)  KthuraError("LoadKthura: Entry "+prefix+MH+" does not exist in map resource!") Return
	If debugchat DebugLog "Entry ~q"+Prefix+MH+"~q is present"
	Next
If alttextjcr ret.texturejcr = alttextjcr Else ret.texturejcr = jcr
' Load Data
ret.data = LoadStringMap(jcr,prefix+"Data")
' Load Settings
For RL=EachIn Listfile(JCR_B(JCR,prefix+"Settings"))
	CL:+1
	L = Trim(RL)
	If L And Left(L,2)<>"--"
		SL = L.Split("=")
		If Len(SL)>2 
			KthuraWarning "Invalid settings definition in line #"+CL+" >> "+L
		Else
			Select Trim(Upper(SL[0]))
				Case "CAM"
					DL = SL[1].split("x")
					If Len(DL)<2 
						KthuraWarning " Invalid cam definition in line #"+cl+" >> "+L
					Else
						Kthura_SetCam DL[0].toint(),DL[1].toint()	
						?Debug
						Print "Cam set to: "+DL[0].toint()+"x"+DL[1].toint()	
						?
						EndIf
				Case "BLOCKMAPGRID"		
					DL = SL[1].split("x")
					If Len(DL)<2 
						KthuraWarning " Invalid blockmap grid definition in line #"+cl+" >> "+L
					Else
						ret.blockmapgridw = DL[0].toint()
						ret.blockmapgridh = DL[1].toint()
						EndIf
				Default
					KthuraWarning " Unknown settings variable "+SL[0]+"! In line #"+CL+". Request ignored >> "+L												
				End Select	
			EndIf
		EndIf
	Next				
		
' Load Objects
CL=0
For RL=EachIn Listfile(JCR_B(JCR,prefix+"Objects"))
	CL:+1
	L = Trim(RL)
	If L And Left(L,2)<>"--"
		SL = L.Split("=")
		For ak=0 Until Len SL SL[ak]=Trim(SL[ak]) Next
		If Left(SL[0],5).toupper()="DATA."
			DL = SL[0].split(".")
			If Not DL[1] 
				KthuraWarning " Nameless field in data in objects line #"+cl+" >> "+L
			ElseIf Len(SL)<2
				KthuraWarning " Invalid data definition in objects line #"+cl+" >> "+L
			ElseIf Not O
				KthuraError "ERROR! Cannot define data when no object is defined! Line #"+cl+" >> "+L
				Return
			Else
				MapInsert o.data,DL[1],Replace(SL[1],"<is>","=")
				EndIf
		Else
			SL[0]=Upper(SL[0])
			If Len(SL)<2 And SL[0]<>"NEW"
				KthuraWarning " Invalid definition in line #"+CL+" >> "+L
			ElseIf SL[0]<>"NEW" And (Not O)
				KthuraError "ERROR! Cannot define data when no object is defined! Line #"+cl+" >> "+L
				Return				
			Else
				Select SL[0]
					Case "NEW"
						O = ret.CreateObject(False)
					Case "KIND" 
						O.Kind = SL[1]
					Case "INSERT"
						DL = SL[1].split(",")
						If Len(DL)<2 
							KthuraWarning " Invalid coordinate definition in line #"+cl+" >> "+L
						Else
							O.insertX = DL[0].toint()
							O.insertY = DL[1].toint()
							EndIf
					Case "COORD"
						DL = SL[1].split(",")
						If Len(DL)<2 
							KthuraWarning " Invalid coordinate definition in line #"+cl+" >> "+L
						Else
							O.X = DL[0].toint()
							O.Y = DL[1].toint()
							EndIf
					Case "TAG"
						O.Tag = SL[1]
					Case "SIZE"
						DL = SL[1].split("x")
						If Len(DL)<2 
							KthuraWarning " Invalid size definition in line #"+cl+" >> "+L
						Else
							O.W = DL[0].toint()
							O.H = DL[1].toint()
							EndIf
					Case "LABELS","LABEL"
						O.Labels = SL[1]
					Case "COLOR"
						DL = SL[1].split(",")
						If Len DL<3
							KthuraWarning " Invalid color definition in line #"+cl+" >> "+L
						Else
							o.r = DL[0].toint()
							o.g = dl[1].toint()
							o.b = DL[2].toint()	
							EndIf
					Case "DOMINANCE"
						O.Dominance = SL[1].toInt()
					Case "TEXTURE","TEXTUREFILE"
						O.Texturefile = SL[1]
					Case "FRAMES" ' Deprecated
						O.Frames = SL[1].toInt()
						KthuraWarning "FRAMES command inside an Kthura object map has been deprecated. Please remove it as soon as possible."
					Case "CURRENTFRAME","FRAME"
						O.FRAME = SL[1].TOINT()
					Case "FRAMESIZE" ' Deprecated
						KthuraWarning "FRAMESIZE command inside an Kthura object map has been deprecated. Please remove it as soon as possible."
						DL = SL[1].split("x")
						If Len(DL)<2 
							KthuraWarning " Invalid size definition in line #"+cl+" >> "+L
						Else
							O.FrameWidth  = DL[0].toint()
							O.FrameHeight = DL[1].toint()
							EndIf
					Case "FRAMESPEED"
						o.FrameSpeed = SL[1].toint()
						'Print "Receveid string: "+DL[0]+" translated to: "+o.framespeed						
					Case "ROTATION"
						O.Rotation = SL[1].toint()		
					Case "ALPHA"
						O.Alpha = SL[1].todouble()
					Case "IMPASSIBLE"
						O.Impassible = SL[1].toint()					
					Case "FORCEPASSIBLE"
						O.ForcePassible = SL[1].toint()
					Case "VISIBLE"
						O.Visible = SL[1].toint()	
					Default
						KthuraWarning " Unknown variable "+SL[0]+"! In line #"+CL+". Request ignored >> "+L												
					End Select
				EndIf
			EndIf
		EndIf
	Next	
' Return all this shit
ret.totalremap
Return ret	
End Function
