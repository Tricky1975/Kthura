Rem
	Kthura
	Global Declarations
	
	
	
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
Version: 17.05.05
End Rem
MKL_Version "Kthura Map System - Globals.bmx","17.05.05"
MKL_Lic     "Kthura Map System - Globals.bmx","GNU General Public License 3"

' Project
Global Project$
Global MapFile$
Global FileName$
Global ShotFile$
Global PrID:TIni
Global KthMap:TKthura


' Events
Global EID
Global ESource:TGadget
Global EX,EY
Global EExtra$
Global EExtraObject:Object
Global EData

' Mouse coordinates
Global MX,MY


' Grid
Global DefaultGridW = 32
Global DefaultGridH = 32
Global currentgridW = 32
Global currentgridh = 32
Global GridMode = True
Global GridShow = True
Global AutoTextSize = False

' Lines
Global LinesShow = True
Global WorkLines:TList = New TList

Type TLine
	Field SX,SY,EX,EY
	End Type

' scroll level
Global screenx,screeny

' JCR
Global TextureDir:TJCRDir = New TJCRDir
Global ScriptJCR:TJCRDir = JCR_Dir("Scripts/Libraries.gll"); JCR_AddPatch(ScriptJCR,JCR_Dir("Scripts/Use"),"","Use")

' Script
Global ProjectScript:TLua

' General Data pages
Global GDPanels:TGadget[] = New TGadget[5]
Global GDFields:TMap = New TMap

' Edit
Global SelectedObject:TKthuraObject

' Console will remain amber. In Windows too!!!!
Global PCOnsole:TGadget
Global OldConsoleText$


' Texture Settings
Global TextureSettings:TMap = New TMap

Function GetTextureSettings:StringMap(Tex$) Return StringMap(MapValueForKey(TextureSettings,Tex)) End Function

' Directory redirection
Global AltMainDir$="./"

'ArgSettings
Global ArgSettings:StringMap = New StringMap
