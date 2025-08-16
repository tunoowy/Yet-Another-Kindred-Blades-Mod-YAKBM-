#NoEnv  
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#include CEpluginLib.ahk
#persistent

global HPoints      := new CEEntry("H - inf HP")
global EKills       := new CEEntry("K - easy KIlls")
global Bullets      := new CEEntry("B - inf Blaster")
global life         := new CEEntry("L - inf Lives")
class shadowsTrainer extends CETrainer
{
	OnLoop() 
	{	
        if CETrainer.keyevent("h") > 0				
		this.Speak(HPoints.Toogle("Infinite HP"))

		;else if CETrainer.keyevent("k") > 0 				
		;this.Speak(EKills.Toogle("One hit kills"))  only hurman enemies

		else if CETrainer.keyevent("b") > 0				
		this.Speak(Bullets.Toogle("Infinite Blaster"))

		else if CETrainer.keyevent("l") > 0				
		this.Speak(life.Toogle("Infinite Lifes"))        
	}
}
shadowsTrainer.TrainerLoop("shadows.exe", 15)
return




