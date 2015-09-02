Rem
	Kthura
	Let's Go!
	
	
	
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
Version: 15.09.02
End Rem
Rem
/*
	Kthura
	Let's go
	
	
	
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
MKL_Version "Kthura Map System - Go.bmx","15.09.02"
MKL_Lic     "Kthura Map System - Go.bmx","GNU General Public License 3"


Function Run()
ShowGadget window
Repeat
If oldconsoletext<>TextFieldText(PConsole)
	FormatTextAreaText( Pconsole ,255,180,0 ,0 ) ' If I don't do this, Windows will always put on unreadable text in the textfield. Oh well. Crappy systems require crappy results I suppose.
	oldconsoletext = TextFieldText(PConsole)
	EndIf
GetEvent
If paintedbefore Drawcanvas
Select eid
	Case Event_windowClose
		If esource=window 
			If WantToSave() Exit
			EndIf
	Case Event_AppTerminate
		If wanttosave() Exit
	Case event_gadgetaction
		callback callaction,esource
	Case event_gadgetselect
		callback callselect,esource
	Case event_menuaction
		callback callmenu,Hex(edata)
		?Not MacOS
		If edata = 1999 
			If wanttosave() Exit
			EndIf
		?	
	Case Event_GadgetPaint
		DrawCanvas
		paintedbefore = True
	End Select
If esource = canvas runcanvas	
Forever
End Function





Function RunCanvas()
Local t = SelectedGadgetItem(ToolTabber)
Local ca:Tcanvasactionbase = canvasaction[t]
'Print "Canvas call. Tool: "+t
Select eid
	Case event_mousedown
		ca.MouseDown
	Case event_mousemove
		mx = ex
		my = ey
		ca.mousemove
		SetStatusText window,"Project:"+project+"~t"+MapFile+"~tMouse ("+mx+","+my+"); Screen("+ScreenX+","+ScreenY+"); TruePos ("+Int(mx+screenx)+","+Int(my+screeny)+")"
	Case event_mouseup
		ca.MouseUp
	Case event_mouseenter
		ca.MouseEnter
	Case event_mouseleave
		ca.Mouseleave
	End Select
End Function
