Rem
	Kthura Copy
	Copies elements of a kthura map into a new Kthura Map
	
	
	
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
Version: 15.09.23
End Rem
Strict
Import tricky_units.MKL_Version
Import tricky_units.StringMap
Import tricky_units.Bye
Import tricky_kthura.Kthura_core
Import tricky_kthura.Kthura_save

MKL_Version "Kthura Map System - Kthura_Copy.bmx","15.09.23"
MKL_Lic     "Kthura Map System - Kthura_Copy.bmx","GNU General Public License 3"

Print "Kthura Copy"
Print "Version: "+MKL_NewestVersion()
Print "(c) Jeroen Petrus Broks"
Print
Print MKL_GetAllversions()
Print
ChangeDir LaunchDir

'Global Tags:StringMap = New StringMap
'Global Options:TList = New TList
Global InputFile$,Outputfile$,Labels$[],Tags$[],Kinds$[],xmod,ymod

Global argpos = 1

Function NextArg$()
argpos:+1
If argpos>=Len(AppArgs) 
	Print "ERROR! Invalid command line arguments"
	Bye
	EndIf
Return AppArgs[argpos]
End Function

	
While argpos < Len(AppArgs)
	If Left(AppArgs[argpos],1)<>"-"
		Inputfile = AppArgs[argpos]
	Else
		Select AppArgs[argpos]
			Case "-o"
				OutputFile = NextArg()
			Case "-l"
				Labels = nextArg().split(",")
			Case "-t"
				Tags = Nextarg().split(",")	
			Case "-k"
				Kinds = Nextarg().split(",")	
			Case "-x"
				xmod = Nextarg().toint()
			Case "-y"
				ymod = Nextarg().toint()	
			Default
				Print "Unknown switch: "+AppArgs[argpos]
			End Select
		EndIf
	argpos:+1
	Wend

If Not inputfile
	Print "Usage: "+StripAll(AppFile)+" <inputfile> [switches + args]"
	Print ""
	Print "-o <Output file>   (default is ~q<inputfile> (copy)~q)"
	Print "-l <Labels>        only act on labels <labels>. Separated by commas)"
	Print "-t <Tags>          only act on tags   <tags>.   Separated by commas)"
	Print "-k <Kinds>         only act on kinds  <tags>.   Separated by commas)"
	Print "-x <coords>        modify x coordniates by <coords> pixels"
	Print "-y <coords>        modify y coordniates by <coords> pixels"
	Bye
	EndIf

If Not outputfile 
	Repeat
	outputfile=inputfile+" (copy)"
	Until Not FileType(outputfile)
	EndIf
	
Print "Input:  "+inputfile
Print "Output: "+outputfile
'If labels Print "Labels: "+Labels.join(", ")
'If tags   Print "Tags:   "+Tags.join(", ")
'If kinds  Print "Kinds:  "+Kinds.join(", ")

If outputfile = inputfile Print "ERROR: Input and output file may not be the same"; Bye

If FileType(outputfile)
	If Upper(Input("Target file exists. Overwrite ? <Y/N> "))<>"Y" Bye
	EndIf
	
Function AllowObject(OL$[],AL$[])
If Not AL Return True
If Not OL Return False	
Local ret = False
Local O$,A$
For O=EachIn OL For A=EachIn AL
	ret = ret Or O=A
	Next Next
Return ret
End Function

	
Print "~n~n"
Print "Loading: "+Inputfile
Global InKthura:TKthura = LoadKthura(inputfile)
Global outkthura:TKthura = New TKthura
Global O:TKthuraObject
Global copied
Global Ok
For O = EachIn inkthura.fullobjectlist
	WriteStdout "~t"+O.IDNum+"~r"
	ok = True
	ok = ok And AllowObject(O.Labels.split(","),Labels)
	ok = ok And allowobject(O.Tag.split(","),Tags)
	ok = ok And allowobject([O.kind],Kinds)
	If ok 
		ListAddLast outkthura.fullobjectlist,O
		O.X:+xmod
		O.Y:+ymod
		Print "Copied object #"+O.idnum
		copied:+1
		EndIf
	Next
Print "Objects copied: "+copied
Print "~n~nSaving: "+Outputfile
SaveKthura outkthura,outputfile
