Rem
/*
	Kthura Map Editor
	Export Kthura maps to JPEG or PNG
	
	
	
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


Version: 15.08.23

End Rem
Const EX_JPG=0
Const EX_PNG=1
Global Ex_Quality[] = [80,9]
Global Ex_filter$[] = ["JPEG:jpg","Portable Network Graphic:png"]
Global Ex_Pix(Pix:TPixmap,u:Object,Quality)[] = [SavePixmapJPeg,SavePixmapPNG]


Function Export(EX,PJSizes=False)
If SelectedGadgetItem(Tabber)<>2 Return Notify("The export feature may only be used when you are in a tab showing the editor's working canvas!")
SetGraphics CanvasGraphics(canvas)
Cls; DrawKthura kthmap,screenx,screeny; Flip
Cls; DrawKthura kthmap,screenx,screeny; Flip
Local w,h,f$
Select PJSizes
	Case True
		w = prid.c("ShotWidth").toint()
		h = prid.c("ShotHeight").toint()
		f = ShotFile
	Case False
		w = ClientWidth(canvas)
		h = ClientHeight(canvas)
		f = RequestFile("Export to:",ex_filter[ex],True,GetUserHomeDir()+"/"+StripDir(Mapfile))
	End Select
Local Pix:TPixmap = GrabPixmap(0,0,w,h)
csay "Saving ("+w+"x"+h+") as image into: "+f
ex_pix[ex] pix,f,ex_quality[ex]
End Function

Function EXPORTPRJ() Export(EX_PNG,1) End Function; addcallback callmenu,Hex(1500),EXPORTPRJ
Function EXPORTPNG() Export(EX_PNG)   End Function; addcallback callmenu,Hex(1501),EXPORTPNG
Function EXPORTJPG() Export(EX_JPG)   End Function; addcallback callmenu,Hex(1502),EXPORTJPG
