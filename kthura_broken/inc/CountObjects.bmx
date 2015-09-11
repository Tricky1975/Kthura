Rem
	Kthura
	Counts all objects in the map and even does some categorized counting
	
	
	
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
Function SMINC(sm:StringMap,t$)
Local A=sm.value(t).toint()+1
MapInsert sm,t,A+""
End Function

Function CountObjects()
Local sm:StringMap = New StringMap
Local k$,o:TKthuraObject
' Prepare
kthmap.totalremap
' Grand total
MapInsert sm,"ZZZZ.Grand Total",CountList(kthmap.fullobjectlist)+""
' Labelled stuff
For k=EachIn MapKeys(kthmap.Labelmap)
	If Not k
		MapInsert sm,"Unlabelled",""+CountList(kthmap.labelmap.list(k))	
	Else
		MapInsert sm,"Labelled ~q"+k+"~q",""+CountList(kthmap.labelmap.list(k))
		EndIf
	Next
' Tagged stuff & kinds
For o=EachIn kthmap.fullobjectlist
	If o.tag SMINC sm,"Tagged" Else SMINC sm,"Untagged"
	SMINC sm,"Kind "+o.kind
	Next	
' All counted produce some results
Local szh = 0
For k=EachIn MapKeys(sm)
	If szh<Len(k) szh=Len k
	Next
Local szs$,altk$
For Local i=0 Until szh szs:+" "; Next
For k=EachIn MapKeys(sm)
	altk = k
	If Prefixed(altk,"ZZZZ.") altk=Replace(altk,"ZZZZ.","     ")
	csay Right(szs+altk,szh)+": "+sm.value(k)
	Next
End Function
