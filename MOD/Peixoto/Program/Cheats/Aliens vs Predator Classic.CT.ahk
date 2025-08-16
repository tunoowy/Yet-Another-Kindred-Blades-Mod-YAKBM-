#NoEnv  
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#include CEpluginLib.ahk
#persistent

CETrainer.help := 
(
"270x100
==============================
INFINITE BULLETS
This gives infinite magazines
==============================
"
)

global Auto     := new CEEntry("Auto")
global HP       := new CEEntry("H - inf HP")
global EZKills  := new CEEntry("K - easy kills")
global Ammo     := new CEEntry("B - inf Bullets")

class AVPClassicTrainer extends CETrainer
{
    OnLoop() 
    {    
        if (!Auto.IsFrozen())
		{
            Auto.SetFrozen(1, 1)			
		}
        
        if CETrainer.keyevent("h") > 0 
        {   
            this.Speak(HP.Toogle("Infinite HP"))
        }			        

        else if CETrainer.keyevent("k") > 0  	
        {		
            this.Speak(EZKills.Toogle("One hit kills"))	
        }

        else if CETrainer.keyevent("B") > 0  	
        {		
            this.Speak(Ammo.Toogle("Infinite magazines"))	
        } 
    }        
}
AVPClassicTrainer.__Init().TrainerLoop("AvP_Classic.exe", 100)
return




