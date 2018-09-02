Framework brl.system
Import    brl.filesystem
Import    brl.retro
AppTitle = StripAll(AppFile)
Global wizard$=AppFile
Global i=10000
While ExtractExt(wizard)<>"app"
	wizard=ExtractDir(wizard)
	Print i+">"+wizard+">"+ExtractExt(wizard)
	i:-1	
	If Not i 
		Notify "Locationing timeout!~n"+wizard
		End
	EndIf
Wend
wizard:+"/Contents/Resources/QuickKthuraProjectSetupWizard.exe"
If Not FileType(wizard)
	Notify "Mising resource:~n"+wizard
	End
EndIf
'system_ "type mono"
Global mono$="/Library/Frameworks/Mono.framework/Versions/Current/Commands/mono"
If Not FileType(mono)
	Notify "Missing dependency:~n"+mono
	end
EndIf
Global s$= mono +" '"+wizard+"' '"+CurrentDir()+"'"
Print "Executing: "+s
system_ s
