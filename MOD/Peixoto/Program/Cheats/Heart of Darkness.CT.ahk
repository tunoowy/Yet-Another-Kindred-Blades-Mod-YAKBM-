#NoEnv
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#include CEpluginLib.ahk
#persistent

global flag     := new CEEntry("Auto - fly direction")
global xpos     := new CEEntry("X")
global __auto   := new CEEntry("Auto Position")
global __scans  := new CEEntry("Auto Position Scans")
global __enable := new CEEntry("Auto enable")

class HODTrainer extends CETrainer
{
    OnLoop()
	{   
        if (!__auto_player.IsFrozen())
        {
            __scans.SetFrozen(1, 1)	
            __auto.SetFrozen(1, 1)	            		
        }  

        f := CETrainer.keyevent("f")
        if (f > 0)
        {
            __enable.SetFrozen(1, 1)	
            flag.SetValue(3)
        } else if  (f < 0)
        {
            __enable.SetFrozen(0, 1)	
            flag.SetValue(0)
        }

        if __enable.IsFrozen()
        {           
            __up   := CETrainer.keyevent("Up")
            __down := CETrainer.keyevent("down")
            if (__up = 1)
            flag.SetValue(1)
            else if (__down = -1) 
            flag.SetValue(2) 
            else if (__down < 0 or __up < 0)                
            flag.SetValue(3)    

            if getkeystate("left", "p")
            xpos.SetValue(xpos.GetValue(16)-2)  
            else if getkeystate("right", "p")
            xpos.SetValue(xpos.GetValue(16)+2)             
        }           
    }
}
HODTrainer.__init().TrainerLoop("HODWin32.exe", 15)
return






