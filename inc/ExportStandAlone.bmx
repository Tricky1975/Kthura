Rem
	Kthura
	Stand alone exporter
	
	
	
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
MKL_Version "Kthura Map System - ExportStandAlone.bmx","17.05.05"
MKL_Lic     "Kthura Map System - ExportStandAlone.bmx","GNU General Public License 3"

Global extpackerexec:StringMap = New StringMap
MapInsert extpackerexec,"zip","-r ~q$out$~q *"
MapInsert extpackerexec,"7z","a ~q$out$~q *"
MapInsert extpackerexec,"rar","a -r -m5 ~q$out$~q *"
MapInsert extpackerexec,"tar","-cf ~q$out$~q *"
?Not win32
MapInsert extpackerexec,"tar.gz","-czf ~q$out$~q *"

?win32
MapInsert extpackerexec,"arj","a -r ~q$out$~q"
?

Global extpackneed:StringMap = New StringMap
MapInsert extpackneed,"zip","zip"
MapInsert extpackneed,"7z","7z"
MapInsert extpackneed,"rar","rar"
MapInsert extpackneed,"tar","tar"
MapInsert extpackneed,"tar.gz","tar"
?win32
MapInsert extpackneed,"arj","arj32"
?

?win32
Global allowpacker$[] = [AppDir+"/Archivers/"]
?Not win32
Global allowpacker$[] = ["/bin/","/usr/bin/","/usr/local/bin/",Dirry("$Home$/bin/")]
?

Global exp_win:TGadget = CreateWindow("Stand Alone Export",0,0,400,800,Null,window_clientcoords|window_center|window_titlebar|window_hidden)
CreateLabel "Export to: ",0,0,200,25,exp_win
CreateLabel "Include texture files into export:",0,25,200,25,exp_win
CreateLabel "Export as:",0,50,200,25,exp_win

Global exp_extpan:TGadget = CreatePanel(200,50,200,ClientHeight(exp_win)-75,exp_win)
Global exp_extreal:TGadget = CreateButton("Real Directory",0,0,200,25,exp_extpan,button_radio); SetButtonState exp_extreal,True
Global exp_extjcr6:TGadget = CreateButton("JCR6",0,25,200,25,exp_extpan,button_radio)
Global exp_extpacker:TMap = New TMap
Global exp_y = 50
For Local k$=EachIn MapKeys(extpackerexec)
        Local g:TGadget = CreateButton(k,0,exp_y,200,25,exp_extpan,button_radio)
	MapInsert exp_extpacker,k,g; exp_y:+25
	'?win32
	'g.setenabled FileType(AppDir+"/"+extpackneed.value(k)+".exe")=1
	'?Not win32
	Rem
	CreateDir Dirry("$AppSupport$/Kthura/QuickSwap/TypeCheck"),1
	system_ "type "+extpackneed.value(k)+" > "+Dirry("~q$AppSupport$/Kthura/QuickSwap/TypeCheck/Result~q") 
	Local result$ 
	If FileType(Dirry("$AppSupport$/Kthura/QuickSwap/TypeCheck/Result")) result$=LoadString(Dirry("$AppSupport$/Kthura/QuickSwap/TypeCheck/Result"))
	g.setenabled result<>"" And (Not Prefixed(result,"-bash:"))
	End Rem
	'Local ad$[]=["/bin/","/usr/bin/","/usr/local/bin/",Dirry("$Home$/bin/")]
	Local en=0
	For Local d$ = EachIn allowpacker
	        ?Not win32
		en = en Or FileType(d+extpackneed.value(k))
		?win32
		en = en Or FileType(d+extpackneed.value(k)+".exe")
		?
		DebugLog d+extpackneed.value(k)+" >> "+FileType(d+extpackneed.value(k))+" >> "+en
	Next
	g.setenabled en
	'?
Next

Global exp_to:TGadget = CreateTextField(200,0,175,25,exp_win)
Global exp_browse:TGadget = CreateButton("...",375,0,25,25,exp_win)
Global exp_texinclude:TGadget = CreateButton("Yes",200,25,200,25,exp_win,button_checkbox)

Global exp_ok    :TGadget = CreateButton("Ok",ClientWidth(exp_win)-100,ClientHeight(exp_win)-25,100,25,exp_win); DisableGadget exp_ok
Global exp_cancel:TGadget = CreateButton("Cancel",ClientWidth(exp_win)-200,ClientHeight(exp_win)-25,100,25,exp_win)

Function ToExportWindow()
	HideGadget window
	ShowGadget exp_win
End Function

addcallback callmenu,Hex(1003),ToExportWindow

Function LeaveExportWindow()
	ShowGadget window
	HideGadget exp_win
End Function

addcallback callaction,exp_cancel,LeaveExportWindow

Function expokisok()
	exp_ok.setenabled Trim(GadgetText(exp_to))<>""
End Function
addcallback callaction,exp_to,expokisok


Function ExportStandalone()
	Notify "During the export all windows will be closed and you will see no activity until the export has been completed. This is normal, the program did NOT crash!"
	?win32
	If Not ( ButtonState(exp_extreal) Or ButtonState(exp_extjcr6) )
		Notify "While creating the actual file you may see a few command windows popping up and disappear all the same.~n~nThis is normal behavior, so no need to be alarmed about that."
	EndIf
	?
	Local TempDir$ = Dirry("$AppSupport$/Kthura/ExportSwap")
	HideGadget exp_win
	If ButtonState(exp_extreal) TempDir = GadgetText(exp_to)
	If Prefixed (tempdir,"~~/") Or Prefixed(tempdir,"~~\") tempdir=Dirry("$Home$")+tempdir[1..]
	' Destroy the old
	Select FileType(tempDir)
		Case 1
			Print "Deleting: "+tempdir
			DeleteFile tempdir
		Case 2
			Print "Destroying: "+tempdir 
			DeleteDir tempdir,1
		End Select
	If FileType(tempdir)
		Notify "I could not destroy the old data, exporting is therefore impossible."
		ShowGadget exp_win
		Return	
	EndIf
	' Create the new workdir
	Print "Creating dir: "+tempdir
	If Not CreateDir(tempdir,1)
		Notify "Creating folder "+tempdir+" failed, and exporting is therefore not possible (code1)"
		ShowGadget exp_win
		Return
	EndIf	
	If Not FileType(tempdir) 
		Notify "Creating folder "+tempdir+" failed, and exporting is therefore not possible (code2)"
		ShowGadget exp_win
		Return
	EndIf	
	' Save the current map so we can start exporting
	editorsave
	' Let's export the work files
	Local tJ:TJCRDir = JCR_Dir(mapfile)
	CreateDir tempdir+"/Kthura",1
	For Local tE$=EachIn MapKeys(tj.entries) 
		If Not Prefixed(tE,"KME.") 
			Print "Extracting: "+tE+ " to "+tempdir
			JCR_Extract tj,tE,tempdir+"/Kthura"
		EndIf
	Next
	' Export textures if asked for
	Local needexport:TList = New TList
	If ButtonState(exp_texinclude)
		For Local rl$=EachIn Listfile(tempdir+"/Kthura/OBJECTS")
			Local l$=Trim(rl)
			If Prefixed(l,"TEXTURE =") 
				Local tex$=Trim(l[(Len "TEXTURE = ")..])
				If Tex
					If JCR_Exists(texturedir,tex)
						If Not ListContains(needexport,tex) ListAddLast needexport,tex
					Else
						Notify "WARNING!~nThe requested texture file ~q"+tex+"~q does not appear to be in the texture list.~n~nThe exported file/folder will very likely malfunction as a result."
					EndIf
				EndIf
			EndIf
		Next
		SortList needexport
		For Local tf$=EachIn needexport
			If Prefixed(Upper(tf),"KTHURA/") Notify "WARNING! ~nThe subfolder Kthura is reserved for Kthura's own data. I will export the file "+tf+", but conflicts can happen!"
			Print "Exporting: "+tf+" to "+tempdir
			JCR_Extract texturedir,tf,tempdir 
		Next
	EndIf
	If ButtonState(exp_extjcr6)
		Local f$ = GadgetText(exp_to)
		If Prefixed (f,"~~/") Or Prefixed(f,"~~\") f=Dirry("$Home$")+f[1..]
		If Not(ExtractExt(F)) f:+".jcr"
		Print "Creating output JCR6: "+f
		Local fk:TJCRDir = JCR_Dir(tempdir)
		Local JO:TJCRCreate = JCR_Create(f)
		For Local e$=EachIn MapKeys(fk.entries) 
			Print "Freezing: "+e
			jo.addentry JCR_B(fk,e),e,"zlib"
		Next
		jo.close "zlib"	
	ElseIf Not ButtonState(exp_extreal)
		Local od$=CurrentDir()
		ChangeDir Tempdir
		Local outf$=GadgetText(exp_to)
		If Prefixed (outf,"~~/") Or Prefixed(outf,"~~\") outf=Dirry("$Home$")+outf[1..]
		?win32
		outf=Replace(outf,"/","\")
		?
		For Local k$=EachIn(MapKeys(extpackerexec))
			Print "Checking packer: "+k
			Local g:TGadget = TGadget(MapValueForKey(exp_extpacker,k))
			If Not g Notify "Something went wrong with the packer selection!~nThis is an internal error, meaning you encountered a bug!~nPlease report this on http://github.com/tricky1975/kthura/issues~n~nThank you!"; Return
			If ButtonState(g)
				Print "Selected packer: "+k
				Local exe$=""
				Local net$=""
				?win32
				net=".exe"
				?
				For Local d$ = EachIn allowpacker
					Print "Looking for packer: "+d+extpackneed.value(k)+net
					If FileType(d+extpackneed.value(k)+net) exe=d+extpackneed.value(k)+net+" "
				Next
				exe:+Replace(extpackerexec.value(k),"$out$",outf)
				Print "Executing command:> "+exe
				system_ exe
				If Not(FileType(outf) Or FileType(outf+"."+k))
					Notify "WARNING!~nI was unable to check if the file was succesfully created.~nPlease check this out yourself."
				EndIf	
			EndIf		
		Next
		ChangeDir od
	EndIf			
	' All done
	Notify "Export complete"
	ShowGadget Window		
End Function
addcallback callaction,exp_ok,exportstandalone
