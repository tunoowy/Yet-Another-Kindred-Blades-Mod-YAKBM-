#NoEnv  
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#include CEpluginLib.ahk
#persistent

CETrainer.help := 
(
"480x100
 ========================================================
 GAIN STYLE POINT 
 With this active, you gain one style point everytime you access the Style menu 
 ========================================================
"
)

global __auto       := new CEEntry("Auto")
global HP           := new CEEntry("H - inf HP")
global EZKills      := new CEEntry("K - easy kills")
global style        := new CEEntry("G - Gain style point")
class JadeEmpireTrainer extends CETrainer
{    
	OnLoop()
	{        
		if (!__auto.IsFrozen())
        {
            this.open("JadeEmpire.exe")
            __auto.SetFrozen(1, 0)	     
            florins.SetFrozen(1, 0)	       
        }           
		if CETrainer.keyevent("h") > 0	
		{	
			this.Speak(HP.Toogle("Infinite HP"))	
		}	
		else if CETrainer.keyevent("k") > 0				
		{	
			this.Speak(EZKills.Toogle("One hit kills"))	
		}	
        if CETrainer.keyevent("g") > 0	 
        {
            this.Speak(style.Toogle("Gain style points"))	
        }   
            
	}
}

JadeEmpireTrainer.__Init().TrainerLoop("JadeEmpire.exe", 100)
return




