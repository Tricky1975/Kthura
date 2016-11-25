Rem
	Kthura Map Editor - Layer Manager
	
	
	
	
	(c) Jeroen P. Broks, 2015, 2016, All rights reserved
	
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
Version: 16.02.07
End Rem
MKL_Lic     "Kthura Map System - Layers.bmx","GNU General Public License 3"
MKL_Version "Kthura Map System - Layers.bmx","16.02.07"

Function UpdateLayerBox(Update=True)
Local seli=-1
Local itm=-1
If Not kthmap.multi Return
If update ClearGadgetItems layerselector
For Local K$=EachIn MapKeys(kthmap.multi)
	itm:+1
	If update AddGadgetItem layerselector,k
	If TKthura(MapValueForKey(kthmap.multi,K))=kthmap Then seli=itm
	Next
If seli < 0 
	Notify "FATAL ERROR!~nListing the layers did not work!~n~nThis error is impossible to happen unless there is a bug, please notify the developer immediately though the issue tracker: ~nhttps://github.com/Tricky1975/Kthura/issues"; End
	EndIf
SelectGadgetItem layerselector,seli
End Function	

Function Layer_Add()
Local n$,ok
If Not kthmap.multi
	If Not Confirm("This map is not a multimap yet.~nBefore we can start adding layers I first need to turn this map into a multi-map which I will do when you proceed.") Return
	Repeat
	n = Trim(MaxGUI_Input("The current map will be turned into the first layer. Please give it a name (when not entering anything it will be named ~q__BASE~q"))
	ok = Not Prefixed(n,"__")
	If Not ok Notify "The name you entered is illegal. Possible reasons:~n-~tNames may not be prefixed with ~q__~q as that is reseved for Kthura itself."
	Until ok
	If Not n n="__BASE"
	kthmap.makemulti n
	UpdateLayerbox
	Return
	EndIf
n = Trim(MaxGUI_Input("Enter a name for the new layer"))	
If n 
	ok = Not Prefixed(n,"__")
	ok = ok And (Not MapContains(kthmap.multi,n))
	If Not ok Notify "The name you entered is illegal. Possible reasons:~n-~tNames may not be prefixed with ~q__~q as that is reseved for Kthura itself.~n- The name of this layer may already exist." Else kthmap.addtomulti n
	updatelayerbox
	EndIf
End Function
addcallback callaction,LayerAdd,Layer_Add

Function Layer_Select()
Local s = SelectedGadgetItem(layerselector)
Local u
If s<0 ' prevent illegal selections
	s=0
	u=True
	EndIf
Local l$=GadgetItemText(LayerSelector,s)
kthmap = kthmap.getmultilayer(l)	
If u UpdateLayerBox False
SelectedObject = Null
End Function
addcallback callselect,LayerSelector,Layer_select

Function Layer_Destroy()
Local s = SelectedGadgetItem(layerselector)
If s<0 Return ' prevent crashes.
Local l$=GadgetItemText(LayerSelector,s)
MapRemove kthmap.multi,l
Local tempmap:TKthura
For tempmap = EachIn MapValues(kthmap.multi) Exit Next
kthmap = tempmap
UpdateLayerBox
Layer_Select()
End Function
addcallback callaction,LayerRemove,Layer_Destroy
