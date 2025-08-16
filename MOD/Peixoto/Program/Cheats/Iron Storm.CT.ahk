#NoEnv  
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#include CEpluginLib.ahk
#persistent


global __Auto     := new CEEntry("Auto")
global HP       := new CEEntry("H - inf HP")
global EZKills  := new CEEntry("K - easy kills")
global Ammo     := new CEEntry("B - inf Bullets")
global light    := new CEEntry("L - inf flashlight")

class IronTrainer extends CETrainer
{
    OnLoop() 
    {    
        if (!__Auto.IsFrozen())
		{
            this.open("IronStorm.exe")
            __Auto.SetFrozen(1, 1)	
            this.Playsound(1)		
		}
                
        if CETrainer.keyevent("h") > 0 
        {   
            this.Speak(HP.Toogle("Infinite HP"))
        }			        

        else if CETrainer.keyevent("k") > 0  	
        {		
            this.Speak(EZKills.Toogle("One hit kills"))	
        }

        else if CETrainer.keyevent("b") > 0  	
        {		
            this.Speak(Ammo.Toogle("Infinite ammo"))	
        }        
    }        
}
IronTrainer.__init().TrainerLoop("IronStorm.exe", 100)
return




