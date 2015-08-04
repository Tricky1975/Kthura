Rem
/*
	Kthura
	Get project data
	
	
	
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
*/


Version: 15.08.01

End Rem
MKL_Version "Kthura Map Editor - inc/GetProject.bmx","15.08.01"
MKL_Lic     "Kthura Map Editor - inc/GetProject.bmx","GNU - General Public License ver3"

Function GetProject()
?debug
CSay "Loaded JCR dir drivers: "+JCR_DirDrivers()
?
Project = FilePicker("Please select your project:","Projects"); If Not project Bye
PRID = LoadIni("Projects/"+Project)
Local File$ = FilePicker("Please select your map file:",PRID.C("Maps"),1,True)
If Not file Bye
mapfile = PRID.C("Maps")+"/"+File
mapfile = Replace(mapfile,"//","/")
SetStatusText window,"Project: "+Project+"~tMap: "+file+"~tKthura"
If prid.c("Grid.Default.W") defaultgridw = prid.c("Grid.Default.W").toint()	
If prid.c("Grid.Default.W") defaultgridh = prid.c("Grid.Default.H").toint()	
' grab texture dirs
Local f$,ff$,BD
ShowGadget window
If prid.list("TexturesGrabFolders")
	For f=EachIn prid.list("TexturesGrabFolders")
		csay "Grabbing texture dir: "+F
		ff = Replace(f,"\","/")
		If Right(ff,1)<>"/" ff:+"/"
		JCR_AddPatch TextureDir,JCR_Dir(f)
		Next
	EndIf
If prid.list("TexturesGrabFoldersMerge")
	For f=EachIn prid.list("TexturesGrabFoldersMerge")
		csay "Grabbing texture dir: "+F
		ff = Replace(f,"\","/")
		If Right(ff,1)<>"/" ff:+"/"
		For Local D$ = EachIn ListDir(f,LISTDIR_DIRONLY)
			JCR_AddPatch TextureDir,JCR_Dir(ff+D)
			Next
		Next
	EndIf
Local fs$[]	
Local l:TLine
If prid.list("Lines")
	For f=EachIn prid.list("Lines")
		fs=f.split(":")
		If Len fs <> 4 
			csay "Incorrect line: "+F
		Else
			l = New tline
			l.sx=fs[0].toint()
			l.sy=fs[1].toint()
			l.ex=fs[2].toint()
			l.ey=fs[3].toint()
			ListAddLast worklines,l
			EndIf
		Next
	EndIf
		
	
' Put it all in the texture box
ClearGadgetItems texturebox
Local E$
For f=EachIn MapKeys(texturedir.entries)
	E = ExtractExt(f)
	Select E
		Case "PNG","JPG","JPEG","BMP","TGA"
			AddGadgetItem texturebox,f
		End Select	
	Next
' Load the map AFTER the textures are loaded
If FileType(mapfile) 'And False ' And False was used in the early draft of the editor as the saving routine did not yet fully work. ;)
	csay "Loading: "+Mapfile
	kthmap = LoadKthura(mapfile,"",texturedir)
	Else
	csay "No map found, so creating a new map"
	kthmap = New TKthura
	kthmap.texturejcr = texturedir
	End If
' Disable standard export if things are not set right
Local bea = True
bea = bea And prid.c("ShotDir")
bea = bea And prid.c("ShotWidth").toint()
bea = bea And prid.c("ShotHeight").toint()
BExport.setenabled bea	
ShotFile = Prid.c("ShotDir")+"/"+File+".png"
Local skipped$
Local HaveSpots=prid.list("CSpots")<>Null
If havespots havespots = CountList(prid.list("CSpots"))>0
' Add custom spots
For Local CS$=EachIn prid.list("CSpots")

	If Left(CS$,1)<>"$" 
		CSay "WARNING! Custom spots MUST be prefixed with a '$'"
		CSay "The spot "+CS+" has been ignored for security reasons as a result!"
	Else
		CSay "Custom spot: "+CS	
		If Not FileType("Scripts/Projects/"+Project+".lua")
			skipped:+"- Custom Spot: "+CS+"~n"
			CSay "? ERROR: Can't add due to missing script: Scripts/Projects/"+Project+".lua"
		Else
			MapInsert om,CS,New tcustomexit
			AddGadgetItem OtherObjects,CS
			EndIf
		EndIf
	Next
If skipped And havespots
	Notify "The following items require a script file dedicated to this project which doesn't exist:~n~n"+skipped+"~n~nPlease create a file named "+CurrentDir()+"/Scripts/Projects/"+Project+".lua in order to get them to work!"
Else
	JCR_AddPatch scriptjcr,Raw2JCR("Scripts/Projects/"+Project+".lua","0_MyProject.lua")	
	EndIf
Print "Listing Script JCR:"	
For E$=EachIn EntryList(scriptjcr) Print "JCR contains: "+E Next
If havespots projectscript = GALE_LoadScript(scriptjcr,"0_MyProject.lua")	
End Function
