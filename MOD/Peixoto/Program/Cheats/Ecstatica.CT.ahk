#NoEnv
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#include CEpluginLib.ahk
#persistent

CETrainer.help := 
(
"480x100
 The cheats only work with the FEMALE

 EASY KILLS doesn't work 100% of the time, and even with INFINITE HP on, you can still 
 take damage, but the HP regeneration boost will make you pretty much invincible
"
)

global __auto   := new CEEntry("Auto")
global HP       := new CEEntry("H - inf HP")
global EZKills  := new CEEntry("K - easy Kills")
global regen    := new CEEntry("Auto - HP regeneration")
class EcstaticaTainer extends CETrainer
{
	OnLoop()
	{
		if (!__auto.IsFrozen())
		{
			__auto.SetFrozen(1)			
		}

	    if CETrainer.keyevent("k") > 0				
		this.Speak(EZKills.Toogle("easy kills"))	

		else if CETrainer.keyevent("h") > 0				
		this.Speak(HP.Toogle("Infinite HP"))	
		
		if (HP.IsFrozen())
		{
			if (!regen.IsFrozen(400))
                regen.SetFrozen(1, 1)
		} else {
            if regen.IsFrozen(400)
               regen.SetFrozen(0, 1)
        }	 			
	}
}

EcstaticaTainer.TrainerLoop("Ecstatic.exe", 100)
return






