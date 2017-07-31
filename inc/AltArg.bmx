Rem
	Kthura Map Editor
	Argument handler
	
	
	
	(c) Jeroen P. Broks, 2017, All rights reserved
	
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
'Notify Len(AppArgs)
For Local iarg$=EachIn AppArgs
	Local p=iarg.find("=")
	'Notify "Processing: "+iarg+" "+p
	If Left(iarg,1)="_" And P>1 Then
		MapInsert argsettings,iarg[1..p],iarg[p+1..]
		'Notify iarg[1..p]+" is now "+iarg[p+1..]
	EndIf
Next


Function arg$(a$) 
	Return argsettings.value(a) 
End Function

Function defbyarg(a$,variable$ Var)
	If MapContains(argsettings,a) variable=arg(a)		
End Function

defbyarg "AltMainDir",AltMainDir
altmaindir = Replace(altmaindir,"\","/")
If Right(altmaindir,1)<>"/" altmaindir:+"/"
