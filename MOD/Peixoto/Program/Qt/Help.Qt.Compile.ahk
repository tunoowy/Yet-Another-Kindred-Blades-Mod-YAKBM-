#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

runwait, Compiler\Ahk2Exe.exe /in "%A_scriptdir%\Help.Qt.ahk" /out "%A_scriptdir%\Help.Qt.exe" /mpress 0 ;/icon icon.ico
fileopen("HelpQt.ahk", "w").write( LoadResource(">AUTOHOTKEY SCRIPT<", "Help.Qt.exe") )

LoadResource(res, _mod = "")
{
	hmod    := dllcall("LoadLibraryW", str, _mod)
	HRSRC   := dllcall("FindResourceW", uint, hmod, str, res, ptr, 10)
	hRes    := dllcall("LoadResource", uint, hmod, uint, HRSRC)
	sz      := DllCall("SizeofResource", ptr, hmod, ptr, HRSRC, uint)
	pResDt  := dllcall("LockResource", uint, hRes, ptr)
	ret     := strget(pResDt, sz, "UTF-8")	
	dllcall("FreeLibrary", uint, hmod)	
	return ret
}
run HelpQt.ahk -wip