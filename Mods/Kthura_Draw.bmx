Rem
        Kthura_Draw.bmx
	(c) 2015 Jeroen Petrus Broks.
	
	This Source Code Form is subject to the terms of the 
	Mozilla Public License, v. 2.0. If a copy of the MPL was not 
	distributed with this file, You can obtain one at 
	http://mozilla.org/MPL/2.0/.
        Version: 15.10.06
End Rem

' 15.07.12 - First set release
' 15.08.04 - Support for customized spots
' 15.09.10 - Fixed: No textures needed for zones, so why try to load them?
' 15.09.22 - Added color support on tiled areas and obstacles
' 15.09.28 - Added boundary support

Strict
Import "Kthura_core.bmx"
Import brl.map
Import brl.max2d
Import tricky_units.MKL_Version

MKL_Version "Kthura Map System - Kthura_Draw.bmx","15.10.06"
MKL_Lic     "Kthura Map System - Kthura_Draw.bmx","Mozilla Public License 2.0"

Rem
bbdoc: Start X Boundary
about: Boundaries can be set up to improve performance. If they are set everything that falls outside the boudaries, will simply be ignored by the drawer. If the boundaries are not set, the drawer will draw everything regardless if it will be seen by the user or not. Proper usage of these values will speed up the performance. Inproper usage will result into very undesirable effects. People using Kthura in a full Max2D screen (I mean not in a MaxGUI canvas) may want to use @Kthura_GrabBoundaries in stead to be sure this is done the way it should be done.
End Rem
Global Kthura_Boundaries_Begin_X
Rem
bbdoc: Start Y Boundary
End Rem
Global Kthura_Boundaries_Begin_Y
Rem
bbdoc: End X Boundary
End Rem
Global Kthura_Boundaries_End_X
Rem
bbdoc: End Y Boundary
End Rem
Global Kthura_Boundaries_End_Y

Rem
bbdoc: Sets the boundaries based on the sizes of your graphics screen. This should work in Max2D games either in Windowed or full screen mode. I really don't know how this will behave within a MaxGUI canvas.
End Rem
Function Kthura_GrabBoundaries()
Kthura_Boundaries_Begin_X = -5
Kthura_Boundaries_Begin_Y = -5
Kthura_Boundaries_End_X   = GraphicsWidth()+5
Kthura_Boundaries_End_Y   = GraphicsHeight()+5
' The -5 and +5 are just a few "security" margins, they should not be needed, but they were put in just in case.
End Function


Rem
bbdoc: When set to true, the zones will be drawn. 
about: When you use Kthura in games, you can best leave this variable be, however when you decide to use this module to build your own editor, this setting can come in handy.
End Rem
Global Kthura_DrawZones = False

Rem
bbdoc: Draws a Kthura level
about: By setting the x And y coordinates you can decide the starting point, handy For If you want To scroll the level in play. If you set the "OnlyLabels" parameter you can tell Kthura To only draw objects with a certain label.
End Rem
Function DrawKthura(KMap:TKthura,x=0,y=0,ForceVisible=False,OnlyLabels$[]=Null)
Assert KMap Else "Cannot draw a map when it's null"
If Not KMap Return KthuraError("Cannot draw a map when it's null") ' Make sure we don't deal with null, since "Assert" only works in debug mode.
Local k$,O:TKthuraObject
Local d:ktdrawdriver
Local okind$
Local olist:TList = New TList
Local ok
Local boundaries = Kthura_Boundaries_Begin_X <> Kthura_Boundaries_End_X And Kthura_Boundaries_Begin_Y <> Kthura_Boundaries_End_Y
kmap.cycle:+1
For k=EachIn MapKeys(KMap.DrawMap)
	o = kmap.drawmap.get(k)	
	ok=True
	ok = ok And (o.visible Or ForceVisible)
	okind = o.kind
	If Prefixed(okind,"$") okind="CSpot"
	If boundaries
		d = ktdrawdriver(MapValueForKey(drawdrivers,okind))
		Assert d Else "Unknown object kind: "+okind
		ok = ok And d.inboundaries(o,x,y)
		EndIf
	If ok ListAddLast olist,o
	Next
For o=EachIn olist	
	If o ' -- The actor engine can sometimes cause an empty object to be created. This should fix that.
'		If o.visible Or ForceVisible
		 	If Left(o.kind,1)="$" 
				okind = "CSpot"
				Else
				okind=o.kind
				EndIf
			d = ktdrawdriver(MapValueForKey(drawdrivers,okind))
			Assert d Else "Unknown object kind: "+okind
			If Not d Return KthuraError("Unknown object kind: "+o.kind)
			d.ocol o
			d.oalpha o
			d.ogettex o			
			d.draw o,x,y
			'DrawText "MAPTAG: "+k,x+o.x,y+o.y ' Debug line. There were some issues with the DrawMap builder in the first drafts of Kthura
			EndIf
'		EndIf
	Next
SetRotation 0	
End Function





Private
Type KTDrawDriver

	Field hot$ = ""
	
	Method Draw(O:TKthuraObject,x,y) Abstract
	
	Method OCol(O:TKthuraObject)
	SetColor O.r,O.g,O.b
	End Method
	
	Method OAlpha(O:TKthuraObject)
	SetAlpha O.alpha
	End Method
	
	Method OGetTex(O:TKthuraObject)		
	If Not O.texturefile
		If Not O.loadtried KthuraWarning O.kind+" #"+O.IDNum+" has no valid texture file tied to it!"
		O.loadtried = True
		Return
		EndIf
	o.parent.textures.Load(O.parent.textureJCR,o.texturefile,o.kind,hot)
	o.textureimage = o.parent.textures.img(o.kind+":"+o.texturefile)	
	o.Frames = Len(o.textureimage.pixmaps)
	o.FrameWidth = ImageWidth(o.textureimage)
	o.Frameheight = ImageHeight(o.textureimage)
	End Method
	
	Method InBoundaries(O:TKthuraObject,sx,sy) Return True End Method ' If no boundaries setting is know just return true.
	
		
	End Type
	
Type KTDrawZones Extends ktdrawdriver

	Method Draw(O:TKthuraObject,x,y)
	If Not Kthura_DrawZones Return
	SetRotation 0
	SetColor O.R,O.G,O.B
	SetAlpha .5
	DrawRect O.X-x,O.Y-y,O.W,O.H	
	SetAlpha 1
	SetColor 0,0,0
	DrawText O.Tag,(O.X-x)-1,(O.Y-y)-1
	DrawText O.Tag,(O.X-x)+1,(O.Y-y)+1
	SetColor O.R,O.G,O.B
	DrawText O.Tag,(O.X-x)  ,(O.Y-y) 	
	End Method
	
	Method OGetTex(O:TKthuraObject) End Method
	
	End Type
	

Type KTDrawTiledArea Extends ktdrawdriver

	'Method OGetText(O:TKthuraObject)
	'End Method
	
	Method Draw(O:TKthuraObject,x,y)
	Local vx,vy,vw,vh ',ox#,oy#
	If o.FrameSpeed>=0 And o.Frames
		O.FrameSpeedTicker:+1
		If O.FrameSpeedTicker>O.Framespeed O.Frame:+1 O.FrameSpeedTicker=0
		If O.Frame>=O.Frames O.Frame=0
		EndIf
	SetColor o.r,o.g,o.b	
	GetViewport vx,vy,vw,vh
	'GetOrigin ox,oy
	SetViewport O.X-x,O.Y-y,O.W,O.H
	'SetOrigin O.X+x,O.Y+y
	SetRotation O.Rotation
	If O.textureimage TileImage O.TextureImage,(O.X-x)+O.insertX,(O.Y-y)+O.InsertY,O.Frame Else DrawText "<TEXERROR>",O.X,O.Y
	SetViewport vx,vy,vw,vh
	End Method
	
	Method InBoundaries(O:TKthuraObject,sx,sy)
	Rem
	Return ..
		( ..
		O.X-sx    >=Kthura_Boundaries_Begin_X And ..
		O.Y-sy    >=Kthura_Boundaries_Begin_Y ..
		) Or ( ..
		(O.X+O.W)-sx<=Kthura_Boundaries_End_X   And ..
		(O.Y+O.H)-sy<=Kthura_Boundaries_End_Y  )
	End Rem
	If (O.X+O.W)-sx<Kthura_Boundaries_Begin_X Return False
	If (O.Y+O.H)-sy<Kthura_Boundaries_Begin_Y Return False
	If O.X-sx      >Kthura_Boundaries_End_X   Return False
	If O.Y-sy      >Kthura_Boundaries_End_Y   Return False
	Return True
	End Method
	
	End Type
	
Type ktDrawObstacle Extends ktdrawdriver
	Field Hot$="BOTTOMCENTER"

	Method OGetTex(O:TKthuraObject)		
	' I now this is kinda double, however, BlitzMax does not accept it in the "clean" way, so this "dirty" way will have to suffice.
	If Not O.texturefile
		If Not O.loadtried KthuraWarning O.kind+" #"+O.IDNum+" has no valid texture file tied to it!"
		O.loadtried = True
		Return
		EndIf	
	o.parent.textures.Load(O.parent.textureJCR,o.texturefile,o.kind,"BOTTOMCENTER")
	o.textureimage = o.parent.textures.img(o.kind+":"+o.texturefile)	
	If o.textureimage
		o.Frames = Len(o.textureimage.pixmaps)
		o.FrameWidth = ImageWidth(o.textureimage)
		o.Frameheight = ImageHeight(o.textureimage)
		Else 
		KthuraError "Texture "+o.texturefile+" not properly loaded" 
		EndIf
	End Method

		
	Method Draw(O:TKthuraObject,x,y)
	SetRotation O.Rotation
	If o.FrameSpeed>=0 And o.Frames
		O.FrameSpeedTicker:+1
		If O.FrameSpeedTicker>O.Framespeed O.Frame:+1 O.FrameSpeedTicker=0
		If O.Frame>=O.Frames O.Frame=0
		'Print O.framespeed+":"+o.frames
		EndIf
	SetColor o.r,o.g,o.b	
	If O.textureimage DrawImage O.TextureImage,O.X-x,O.Y-y,O.Frame Else DrawText "<TEXERROR>",O.X,O.Y
	End Method

	Method InBoundaries(O:TKthuraObject,sx,sy)
	If Not O.textureimage Return True ' Let the drawer itself handle this as an error, we cannot handle it!
	Return ..
		(O.Y-sy)+ImageHeight(o.textureimage)>= Kthura_Boundaries_Begin_Y And ..
		(O.Y-sy)-ImageHeight(o.textureimage)<= Kthura_Boundaries_End_Y And ..
		(O.X-sx)+ImageWidth(o.textureImage)>=Kthura_Boundaries_Begin_X And ..
		(O.X-sx)-ImageWidth(o.textureImage)<=Kthura_Boundaries_End_X
		' I wanted to make sure stuff always pops up. 
		' It will make the system only more demanding to take all handles added to the images into account and this way we also have no trouble with rotations.		
	End Method
	
	End Type
		
	
Type KTDrawActor Extends ktdrawdriver

	Method OGetTex(O:TKthuraObject)
	'Return ' Crashout for debugging
	Local A:TKthuraActor = TKthuraActor(O)
	Local PicList$,Ex$,I:TImage
	If Not A Return KthuraError("Actor #"+O.idnum+" is not an actor but nevertheless still marked as such")		
	If A.Picbundledir	
		If Not A.PicBundle A.PicBundle = New TMap
		If Not MapIsEmpty(A.PicBundle) Return 'DebugLog("Pictures for actor #"+A.idNum+" have already been loaded")
		DebugLog "Pictures for actor #"+A.IdNum+" have not yet been loaded, so let's do it!"
		PicList = A.picbundledir 'Upper(Replace(Pics,"\","/"))			
		If Right(PicList,1)="/" KthuraWarning "WARNING! A picbundle request may not end with '/'"
		A.PicBundle = New TMap
		For Local F$=EachIn MapKeys(a.parent.TextureJCR.Entries)
			Ex = ExtractExt(F)
			If (Ex="PNG" Or Ex="JPG" Or Ex="JPEG" Or Ex="BMP") And ExtractDir(F)=PicList ' Please note that the respective loaders must be imported or none of these extentions will work. If you use Brucey's picture loader in stead allowing more picture types you may need to add their respective extentions to this list (I never tried Brucey's module in combination with JCR6, but if Brucey's module supports reading pictures from memory banks it will support reading pictures from JCR6).
				I = a.parent.Textures.Load(a.parent.TextureJCR,F,"Actor.Bundle","BOTTOMCENTER")
				If Not I
					KthuraWarning "KthuraOGetText: Loading picture '"+F+"' failed!"
				Else
					MapInsert A.Picbundle,StripAll(F),I
					EndIf
				EndIf										
			Next
	ElseIf A.SinglePicfile 
		'DebugLog "Need a single pic?   '"+A.singlepicfile+"'"
		If Not A.SinglePic A.SinglePic = a.parent.Textures.Load(a.parent.TextureJCR,A.singlepicfile,"Actor.Single")
	Else
		KthuraError "Cannot load any actor pictures on actor #"+O.IDNum
		EndIf
	End Method		
		

	Method Draw(O:TKthuraObject,x,y)
	Local A:TKthuraActor = TKthuraActor(O)
	If Not A Return KthuraError("Actor #"+O.idnum+" is not an actor but nevertheless still marked as such")
	If A.singlepicfile And a.picbundledir Return KthuraError("Actor #"+O.IDnum+" has both a picbundle and a singlepic, which is not allowed!")
	If A.Cycle = A.Parent.Cycle Return
	A.Cycle = A.Parent.Cycle
	SetRotation A.Rotation
	Local I:TImage
	Local ErrorText$ = "Ok!"
	Local AcX,AcY
	Local ak,GoX,GoY,GoW$,WtX,WtY,timeout
	Local ABX,ABY,TBX,TBY
	SetColor A.R,A.G,A.B
	If A.SinglePicfile
		I = A.SinglePic
		If Not I ErrorText="<SinglePic not properly defined>"
	Else
		If Not A.ChosenPic 
			ErrorText = "<No Chosen Picture>"
		Else
			I = TImage(MapValueForKey(A.PicBundle,A.ChosenPic))
			If Not I ErrorText = "<Actor Pic Error>"
			EndIf
		EndIf
	If I
		' Animate actor
		If A.InMotion Or (A.Moving And A.WalkingIsMotion) 
			A.FrameSpeedCount:+1
			If A.FrameSpeedCount>=A.FrameSpeed
				A.IncFrame()
				A.FrameSpeedCount=0
				EndIf
			A.UnMoveTimer=4	
		ElseIf A.NotInMotionThen0 And (Not A.Moving)
			If A.UnMoveTimer>0
				A.UnMovetimer:-1
			Else
				A.Frame=0		
				EndIf
			EndIf
		If A.Walking And (Not A.Moving)
			ABX = Floor(A.X/A.parent.BlockmapgridW)
			ABY = Floor(A.Y/A.parent.BlockmapgridH)
			ReadWaySpot A.FoundPath,A.WalkSpot,TBX,TBY
			'Print "ABX = "+ABX+"; TBX = "+TBX+"; ABY = "+ABY+"; TBY = "+TBY+"; Spot = "+A.WalkSpot+"; Length = "+LengthWay(A.FoundPath) ' debugline
			If ABX=Floor(TBX) And ABY=Floor(TBY)
				A.WalkSpot:+1
				A.Walking = A.WalkSpot<=LengthWay(A.FoundPath)
				EndIf
			If A.Walking
				ReadWaySpot A.FoundPath,A.WalkSpot,TBX,TBY				
				AcX = (abX*A.Parent.BlockMapGridW)+(A.Parent.BlockMapGridW/2)
 				AcY = ((abY+1)*A.Parent.BlockMapGridH)-1
				GoX = (tbX*A.Parent.BlockMapGridW)+(A.Parent.BlockMapGridW/2)
 				GoY = ((tbY+1)*A.Parent.BlockMapGridH)-1
				'print "ABX = "+ABX+"; TBX = "+TBX+"; ABY = "+ABY+"; TBY = "+TBY+"; Spot = "+A.WalkSpot+"; Length = "+LengthWay(A.FoundPath)+" AcX = "+AcX+"; GoX = "+GoX+"; AcY = "+AcY+"; GoY = "+GoY ' debugline
				If ABX<>TBX
					A.MoveTo(GoX,AcY,1)
					'Print "Going to "+GoX+","+AcY+" Moving Horizontally"
				ElseIf ABY<>TBY
					A.MoveTo(AcX,GoY,1)
					'Print "Going to "+AcX+","+GoY+" Moving Vertically"
					EndIf
				EndIf					
			EndIf
		If A.MOVING Then
			For ak=0 Until A.Moveskip
				Local labs$[] = O.Labels.split(",")
				For Local L$=EachIn labs
					MapRemove A.parent.TagMapByLabel.Get(Trim(L),True),Hex(A.dominance)+"."+Hex(+A.Y)+"."+Hex(A.idnum)
					Next
				MapRemove A.parent.Drawmap,Hex(A.dominance)+"."+Hex(+A.Y)+"."+Hex(A.idnum)									
				GoX=A.X
				GoY=A.Y
				GoW=A.Wind
				If A.MoveY<A.Y GoY=A.Y-1; GoW="North"
				If A.MoveY>A.Y GoY=A.Y+1; GoW="South"
				If A.MoveX<A.X GoX=A.X-1; GoW="West"
				If A.MoveX>A.X GoX=A.X+1; GoW="East"
				If A.MoveIgnoreBlock Or (Not A.Parent.Block(GoX,GoY))
					A.X=GoX
					A.Y=GoY
					A.Wind = GoW
					Else
					A.Moving=False ' Destination is blocked.
					EndIf
				If A.X=A.MoveX And A.Y=A.MoveY Then A.Moving=False ' We reached the destination
				labs = O.Labels.split(",")
				For Local L$=EachIn labs
					MapInsert A.parent.TagMapByLabel.Get(Trim(L),True),Hex(A.dominance)+"."+Hex(+A.Y)+"."+Hex(A.idnum),A
					Next
				MapInsert A.parent.Drawmap,Hex(A.dominance)+"."+Hex(+A.Y)+"."+Hex(A.idnum),A
				Next
			EndIf	
		DrawImage I,A.X-x,A.Y-y,A.Frame
	Else
		DrawText ErrorText,(A.X-(TextWidth(ErrorText)/2))-x,(A.Y-TextHeight(ErrorText))-y
		EndIf				
	End Method
	
	End Type
	
	
Type KTOther Extends Ktdrawdriver
	Method draw(O:TKthuraObject,x,y) End Method
	Method Ocol(O:TKthuraObject) End Method
	Method OAlpha(O:TKthuraObject) End Method
	Method OGetTex(O:TKthuraObject) End Method
	End Type
Global DKOther:KTOther = New KTOther
Global OtherNames$[] = ["Exit","Entrance","CSpot"] ' All objects marked with $ will be taken as a CSpot (or customized spot)
	



Global DrawDrivers:TMap = New TMap
MapInsert drawdrivers,"TiledArea",New ktdrawtiledarea
MapInsert drawdrivers,"Zone",New ktdrawzones
MapInsert drawdrivers,"Actor",New ktdrawactor
MapInsert DrawDrivers,"Obstacle",New ktdrawobstacle
For Local K$=EachIn OtherNames MapInsert drawdrivers,K,DKOther Next



