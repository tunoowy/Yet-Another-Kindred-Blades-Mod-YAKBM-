#NoEnv  
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#include CEpluginLib.ahk
#persistent

CETrainer.help := 
(
"500x60
 Cheats stop working everytime you clear a level or load a save. Press 'r' to reset them
"
)

global HP    := new CEEntry("H - inf HP")
global ammo  := new CEEntry("B - inf Bullets")

class SlaveZeroTrainer extends CETrainer
{
    OnLoop() 
    {                            
        if CETrainer.keyevent("h") > 0 
        {   
            this.Speak(HP.Toogle("Infinite HP"))
        }			        

        else if CETrainer.keyevent("b") > 0  	
        {		
            this.Speak(ammo.Toogle("Infinite ammo"))	
        }   
        
        else if CETrainer.keyevent("R") > 0  	
        {		
            for k, v in [HP, ammo]
            {
                if v.IsFrozen()
                {
                    v.SetFrozen(0, 1)
                    v.SetFrozen(1, 1)
                }
            }
            this.PlaySound(1)
        }  
    }        
}
SlaveZeroTrainer.__init().TrainerLoop("d3d_SlaveZero.exe", 100)
return




