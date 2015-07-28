Rem
/**********************************************
  
  This file is part of a closed-source 
  project by Jeroen Petrus Broks and should
  therefore not be in your pocession without
  his permission which should be obtained 
  PRIOR to obtaining this file.
  
  You may not distribute this file under 
  any circumstances or distribute the 
  binary file it procudes by the use of 
  compiler software without PRIOR written
  permission from Jeroen P. Broks.
  
  If you did obtain this file in any way
  please remove it from your system and 
  notify Jeroen Broks you got it somehow. If
  you have downloaded it from a website 
  please notify the webmaster to remove it
  IMMEDIATELY!
  
  Thank you for your cooperation!
  
  
 **********************************************/
 



Version: 15.04.16

End Rem
Strict

Import onlytricky.modupdate

Import tricky_units.ListDir
Import tricky_units.advdatetime

Global modname$,moddir$,modmainfile$,L$
Global BT:TStream,BTO:TStream

Print "BlitzMax dir: "+blitzmax

For Local F$=EachIn ListDir(".")
	If Left(F,7).toupper()="KTHURA_" And ExtractExt(f).toupper()="BMX"
		modname = "tricky_kthura."+Lower(StripAll(f))		
		Print "- Creating module: "+modname
		moddir = BlitzMax + "mod/tricky_kthura.mod/"+Lower(StripAll(F))+".mod/"
		modmainfile = moddir + Lower(f)
		Print "  = Deleting dir: "+moddir
		DeleteDir moddir,1
		Print "  = Creating dir: "+moddir
		CreateDir moddir,1
		Print "  = Creating module file: "+modmainfile
		bt = WriteFile(modmainfile)
		WriteLine bt,"strict~nrem~nbbdoc: Module "+modname+"~nendrem~nmodule "+modname+"~n~n~n"
		WriteLine bt,"moduleinfo ~qAuthor: Jeroen P. Broks~q"
		WriteLine bt,"moduleinfo ~qCopyright: (c) 2015-"+Year()+" Jeroen P. Broks~q"
		WriteLine bt,"moduleinfo ~qLicense: Mozilla Public License 2.0~q"
		WriteLine bt,"moduleinfo ~qNotice: The character 'Kthura' which this system is named after and the world and stories she belongs to are property of Jeroen P. Broks and may only be used with his permission. The name 'Kthura' may freely be used in any system related to the Kthura engine as long as it clearly refers to this system and not to the actual character~q"
		WriteLine bt,"moduleinfo ~qVersion: "+Right(Year(),2)+"."+Right("0"+Month(),2)+"."+Right("0"+Day(),2)+"~q"
		WriteLine bt,"moduleinfo ~qQuote: How appropriate! You fight like a cow~q"
		WriteLine BT,"~n~n~nimport ~qIMPORT_"+Upper(StripAll(F))+".bmx"+"~q"
		CloseFile bt
		Print "  = Copying source to module"
		'CopyFile F,moddir+"IMPORT_"+Upper(StripAll(F))+".bmx"
		bt  = ReadFile(f)
		bto = WriteFile(moddir+"IMPORT_"+Upper(StripAll(F))+".bmx")
		While Not Eof(bt)
			L = ReadLine(BT)
			If Trim(Upper(L)) = "IMPORT ~qKTHURA_CORE.BMX~q" L="IMPORT TRICKY_KTHURA.KTHURA_CORE"
			WriteLine bto,L
			Wend
		CloseFile BT
		CloseFile BTO
		'Print "FileType(~q"+StripExt(F)+".doc~q) = "+FileType(StripExt(F)+".doc")
		If FileType(StripExt(F)+".doc")=2
			Print "  = Copying documentation!"
			CopyDir StripExt(F)+".doc",moddir+"doc"
			Else
			Print "  = No Documentation, so let's skip this!"
			EndIf
		EndIf
	Next
Print "~n~n~n"
UpdateMods
