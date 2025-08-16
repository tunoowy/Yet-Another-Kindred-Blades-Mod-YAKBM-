#NoEnv  
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#include CEpluginLib.ahk
#persistent

global HP         := new CEEntry("H - inf HP")
global Magic      := new CEEntry("M - inf Magic")
global __auto     := new CEEntry("Auto")
class MAGESLAYTrainer extends CETrainer
{
	OnLoop() 
	{
        if (!__auto.IsFrozen())
		{
            __auto.SetFrozen(1)			
		}

		if CETrainer.keyevent("h") > 0				
		this.Speak(HP.Toogle("Infinite Health"))        	   

        else if CETrainer.keyevent("m") > 0				
		this.Speak(Magic.Toogle("Infinite magic"))	      	        			
	}
}
MAGESLAYTrainer.__init().TrainerLoop("MAGESLAY.exe", 100)
return


