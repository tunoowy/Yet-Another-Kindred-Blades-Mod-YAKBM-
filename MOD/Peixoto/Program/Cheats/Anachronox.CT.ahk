#NoEnv  
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#include CEpluginLib.ahk
#persistent

global __auto   := new CEEntry("Auto")
global HP       := new CEEntry("H - inf HP")
global EZKills  := new CEEntry("K - easy kills")
class AnoxTrainer extends CETrainer
{    
	OnLoop()
	{
        
		if (!__auto.IsFrozen())
        {
            this.Open("AnoxTrainer.exe")
            __auto.SetFrozen(1)	           
        }
		if CETrainer.keyevent("h") > 0	
		{	
			this.Speak(HP.Toogle("Infinite HP"))	
		}	
		else if CETrainer.keyevent("k") > 0				
		{	
			this.Speak(EZKills.Toogle("One hit kills"))	
		}		
	}
}

AnoxTrainer.__Init().TrainerLoop("Anox.exe", 100)
return




