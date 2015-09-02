Rem
	Kthura
	Remove "Rotten" objects
	
	
	
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


Version: 15.04.29

End Rem
Function RemoveRotten() 
Local O:TKthuraObject 
Local Problem$
For O=EachIn kthmap.fullobjectlist
	problem = ""
	If O.W<0 Or O.H<0 problem="Negative size or width: "+O.W+"x"+O.Y
	If (O.W=0 Or O.H=0) And O.kind = "TiledArea" problem="Tiled area needs to be at least 1x1 pixels~n~n"+O.W+"x"+O.H
	If problem
		Select Proceed("Problem with object #"+O.idnum+"~nKind: "+O.Kind+"~n~n"+problem+"~n~n~nDo you want to remove it?")
			Case -1 kthmap.totalremap; Return
			Case 1 ListRemove kthmap.fullobjectlist,o; csay "Object #"+O.IDNum+" has been removed by the cleaner!"
			End Select
		EndIf
	Next
kthmap.totalremap
Notify "Scanning complete!"	
End Function
