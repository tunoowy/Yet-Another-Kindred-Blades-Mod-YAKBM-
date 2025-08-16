backto=%1%
;msgbox % backto
runwait, ..\injector.exe src\injector.txt -f InstallShield\InstallShield.ini, ..\
run HelpQt.exe "HelpQt.ahk" -g "%backto%"