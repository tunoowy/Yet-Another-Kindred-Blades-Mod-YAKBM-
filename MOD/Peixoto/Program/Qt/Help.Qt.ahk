#NoEnv  
#warn, all, OutputDebug 
SendMode Input  
SetWorkingDir %A_ScriptDir%  
#SingleInstance force 
;#include HelpQtLib.ahk
#include MSEdge/src/EZWebView2.ahk
#include MSEdge/src/HelpEZWebView.ahk
#include MSEdge/Lib/ini.ahk
#include Help.Inputs.ahk
#include Help.Tools.ahk
#include shell.ahk
#Include MSEdge/Lib/_struct.ahk
#include memlib.ahk

global g_smallres
global g_   := {}
g_.color_a  := "#ffffff"
g_.color_b  := "#555555"
g_.color_c  := "#0000aa"
g_.color_d  := "#eeeeee"
g_.profiles := "profiles"
if (Instr(dllcall("GetCommandLine", str), "-wip") )
g_.profiles := "dev"

class SearchInput extends HTMLElement
{
	Init()
	{
		this["style.paddingLeft"] := "2px"
		this.value                := "Search"
		this.ahk.v                := "Search"
		this["style.color"]       := "#aaaaaa"		
		return this
	}
	ValueChanged(val)
	{
		this.ahk.v                :=  val
		if (val="Search")
		{
			this.value            := ""
			this["style.color"]   := "#aaaaaa"	
		} 
		for k, v in this.body().games_div_items
		{
			if (k<3)
				continue
			if (instr(v.js_element_id, val) = 1)
			{
				v.Scroll(0)
				;v.clicked()
				this.Scroll(0)
				break				
			}
		}			
	}
	clicked()
	{
		this.body().__Eval(this.value, this, "ValueChanged")
		return 
	}
	KeyDown(key)
	{
		this.body().__Eval(this.value, this, "ValueChanged")
	}		
}

class GamesDiv extends HTMLElement
{
	Resized(w, h)
	{
		this["style.height"] := h "px"					
	}
	KeyDown(key)
	{
		return
		for k, v in this.body().games_div_items
		{
			if (k<3)
				continue
			if (instr(v.js_element_id, key) = 1)
			{
				v.Scroll(0)
				v.clicked()
				break				
			}
		}		
	}	
}

class DocumentsDiv extends HTMLElement
{
	Resized(w, h)
	{
		w -= 280				
		this["style.height"] := h "px"	
		this["style.width"]  := w "px"				
	}	
}

class GameButton extends HTMLElement
{
	Init()
	{
		this["style.textAlign"]       := "left"
		this["style.width"]           := "100`%"
		this["style.border"]          := "0px"
		this["style.outline"]         := "none"
		this["style.backgroundColor"] := g_.color_a  		
		this["style.fontSize"]        := "12px"
		return this		
	}
	AddIcon(i)
	{
		;return this
		this.style().background         := "url('" i "')"
		this.style().backgroundRepeat   := "no-repeat"
		this.style().backgroundPosition := "left"
		this.style().textAlign          := "Center"  
		this.style().height             := "24px" 
		return this
	}
	Over()
	{
		this["style.borderLeft"] := "2px solid " g_.color_c	 
	}
	Out()
	{
		this["style.borderLeft"] := "none"	 
	}
	Clicked()
	{
		this.body().current_game["style.backgroundColor"] := g_.color_a 
		this["style.backgroundColor"]                     := g_.color_d  
		this.body().current_game                          := this
		cfg  := new ini("..\" g_.profiles "\" StrReplace(this.js_element_id, "@", "'") ".ini")
		help := cfg.read("help")
		help := FileExist("..\help\" help ".txt") ? "..\help\" help ".txt" : "..\" g_.profiles "\" help
		help := StrReplace(help, "user\", "")		
		this.body().ShowDocument( help, "..\" g_.profiles "\" StrReplace(this.js_element_id, "@", "'") ".ini")
	}
}

class HelpButton extends GameButton
{
	Clicked()
	{
		this.body().current_game["style.backgroundColor"] := g_.color_a 
		this["style.backgroundColor"]                     := g_.color_d  
		this.body().current_game                          := this
		this.body().ShowDocument("..\Help\HomeQt.txt")		    
	}
}

class ToolButton extends HelpButton
{	
	Clicked()
	{
		this.body().current_tool := ""
		this.body().current_game["style.backgroundColor"] := g_.color_a 
		this["style.backgroundColor"]                     := g_.color_d  
		this.body().current_game                          := this		
		
		if (this.tool = "InstallShield - 16 bit")
			this.body().current_tool := new InstallShield( this.body() )
		else	
			this.body().ShowDocument("..\Help\IShield32.txt")
	}
}

class AddGameButton extends GameButton
{
	Clicked()
	{
		this.body().current_game["style.backgroundColor"] := g_.color_a 
		this["style.backgroundColor"]                     := g_.color_d  
		this.body().current_game                          := this
		this.dialog := new CreateNewDialog(this.body(), "create_new_dialog", "div").init(this.body())
	}	
}

class mGBAButton extends HelpButton
{
	
}

class DocDiv extends HTMLElement
{
	init()
	{
		this["style.paddingBottom"]    := "25px"
		this["style.marginBottom"]     := "15px"
		this["style.position"]         := "relative"				
		this["style.backgroundColor"]  := g_.color_a 
		this["style.border"]   := "1px solid " g_.color_c
		return this
	}
}

Class DocSectionHead extends HTMLElement
{
	init()
	{
		this["style.color"]          := g_.color_c
		this["style.marginBottom"]   := "20px"		
		this["style.marginRight"]    := "20px"
		this["style.paddingLeft"]    := "20px"
		this["style.paddingTop"]     := "20px"
		this["style.fontSize"]       := "30px"
		this["style.fontWeight"]     := "900"
		;this["style.borderBottom"]   := "1px solid " g_.color_c		
		return this
	}
}

Class DocSectionContent extends HTMLElement
{
	init()
	{
		this["style.marginLeft"]   := "5px"	
		this["style.marginRight"]  := "5px"	
		this["style.textAlign"]    := "justify"	
		this["style.fontSize"]     := "18px"
		return this
	}
}

class DocTabsButton extends HTMLElement
{
	Init(tabname)
	{
		this.innerHTML := tabname
		this["style.backgroundColor"]  := g_.color_d 			
		this["style.fontSize"]         := "20x"
		this["style.border"]           := "0px"
		this["style.outline"]          := "none"
		this["style.position"]         := "Relative"		
		this["style.textAlign"]        := "left"
		this["style.color"] := "white"
		this["style.backgroundColor"] := "RoyalBlue"
		this["style.border"]          := "0px"
		return this
	}
	clicked()
	{
		this.ahk.selected := True
		this["style.backgroundColor"]  := g_.color_a 
		this["style.color"]  := "#000000" 
		for k, v in strsplit("...Graphics|Graphics...|Graphics|Sound|Input|File System|CPU", "|")
		{
			id := "doc_settings_" v "_tab_button"
			if (id = this.js_element_id)
			{
				this.body().docs_items[v "_div"]["style.display"] := "block"
				continue
			}
			this.body().docs_items[v "_div"]["style.display"] := "none"
			this.body().child(id).hide()
		}
		;this["style.borderTop"]        := "1px solid " g_.color_d
		;this["style.borderLeft"]       := "1px solid " g_.color_d
		;this["style.borderRight"]      := "1px solid " g_.color_d
	}
	Over()
	{
		if (this.ahk.selected)
			return
		this["style.backgroundColor"] := "DodgerBlue"
	}
	Out()
	{
		if (this.ahk.selected)
			return
		this["style.backgroundColor"] := "RoyalBlue" 
	}
	Hide()
	{
		this.ahk.selected := False
		this["style.backgroundColor"] := "RoyalBlue" 
		this["style.color"] := "white" 
		;this["style.backgroundColor"]  := g_.color_d 		
		;this["style.border"]           := "0px"	
	}		
}

class TSwappButton extends HTMLElement
{
	Init(byref master, cfg)
	{
		this.ahk.master               := master		
		this["style.border"]          := "1px solid " g_.color_d		
		this["style.outline"]         := "none"
		this["style.backgroundColor"] := "#efefff"
		this["style.backgroundColor"] := g_.color_d  
		this["style.textAlign"]       := "left"
		this["style.fontSize"]        := "12px"
		this["style.height"]          := "18px"
		
		ObjInsert(this, "sec", strsplit(this.js_element_id, ".")[1])
		ObjInsert(this, "key", strsplit(this.js_element_id, ".")[2])			
		ObjInsert(this, "cfg", cfg)				
		this.innerHTML      := new ini(cfg).read(this.key, this.sec, "None")		 		
		return this
	}
	Over()
	{
		this.ahk.master.menu := ""
		this["style.border"] := "1px solid blue"	 
	}
	Out()
	{
		this["style.border"] := "1px solid " g_.color_d	  
	}	
	Clicked()
	{
		this.ahk.master.menu              := ""
		this.ahk.master.menu              := new KbrdMenu(this, "texswap_menu", "div").init(this)	
		this.ahk.master.menu["style.top"] := "-" this["style.height"] 		
 	}
	DissmissKbrdMenu()
	{
		this.ahk.master.menu              := ""
	}
	Update(value)
	{
		this.ahk.master.menu := ""
		this.innerHTML       := value
		cfg := new ini(this.cfg)
		cfg.edit(this.key, value, this.sec)
		cfg.save()
	}
}

class TSwappItem extends HTMLElement
{
	Init(byref parent, label_text, master, cfg)
	{
		this["style.display"]       := "block"
		this["style.position"]      := "relative"
		this["style.top"]           := "5px"
		this["style.marginBottom"]  := "-15px"
		
		butid                       := strsplit(this.js_element_id, "_label")[1]
		this.but                    := new TSwappButton(parent, butid, "BUTTON").init(master, cfg)
		this.but["style.position"]  := "relative"		
		this.but["style.left"]      := "180px"
		this.but["style.width"]     := "180px"
		
		this.for                    := butid
		this.innerHTML              := label_text
		this.but.style().display    := "block"
		return this
	}
} 

class TexSwapMasterDiv extends HTMLElement
{
	Disable()
	{
		this.ahk.disabled := True
		this.body().EnumChildren(this.js_element_id)
	}
	Enable()
	{
		this.ahk.disabled := False
		this.body().EnumChildren(this.js_element_id)
	}
	EnumChildrenCallback(child)
	{
		if (this.ahk.disabled ) 
			 this.body().child(child).disable()		
		else this.body().child(child).enable()		
	}
}

class TexSwap 
{
	__new(byref parent, cfg)
	{
		this.master_div := new TexSwapMasterDiv(parent, "tswap_master_div", "div")
		For k, v in ["Show\Hide thumbnail::sw", "Next thumbnail::n", "Previous thumbnail::p"
					,"Dump texture::d", "Quick browsing::q", "Change text color::c"] 
		{
			id                   := "Textswap." strsplit(v, "::")[2]
			parent[id]           := new TSwappItem(this.master_div, id "_label", "label").Init(this.master_div, strsplit(v, "::")[1], this.master_div, cfg)			
		}
		this.thumbsz := new DropDown(this.master_div, "Textswap.sz_label", "label").Init(cfg, this.master_div, "Textswap.sz", "Thumnail size", "", "128, 256, 384, 512")
		this.thumbsz.style().position := "relative"
		this.thumbsz.style().left := "-1px"
		this.thumbsz.style().top  := "5px"
		this.thumbsz.input.style().position := "relative"
		this.thumbsz.input.style().left := "40px"
		this.thumbsz.input.style().top  := "5px"
		this.thumbsz.details_div.style().marginBottom  := "15px"
		
		this.smpls   := new RadioHead(this.master_div, "TextswapSamples", "div").init(this.master_div, "TextswapSamples", "Samples", "")	
		this.smpls["style.marginTop"] := "5px"	
		this.smpls["style.left"]      := "-1px"	
		this.smpls.butttond_div["style.display"]      := "inline"	
		this.smpls_4  := new RadioInput(this.smpls.butttond_div, "smpls_4", "input").init(cfg, this.smpls.butttond_div, "Textswap.s=4", "Textswap_s", "4", "")	
		this.smpls_4["style.position"] := "absolute"
		this.smpls_4.label["style.position"] := "absolute"
		this.smpls_4["style.top"] := "-20px"
		this.smpls_4["style.left"] := "140px"
		this.smpls_4.label["style.top"] := "-20px"
		this.smpls_4.label["style.left"] := "160px"
		this.smpls_8  := new RadioInput(this.smpls.butttond_div, "smpls_8", "input").init(cfg, this.smpls.butttond_div, "Textswap.s=8", "Textswap_s", "8", "")	
		this.smpls_8["style.position"] := "absolute"
		this.smpls_8.label["style.position"] := "absolute"
		this.smpls_8["style.top"] := "-20px"
		this.smpls_8["style.left"] := "180px"
		this.smpls_8.label["style.top"] := "-20px"
		this.smpls_8.label["style.left"] := "200px"		
		this.smpls_16 := new RadioInput(this.smpls.butttond_div, "smpls_16", "input").init(cfg, this.smpls.butttond_div, "Textswap.s=16", "Textswap_s", "16", "")
		this.smpls_16["style.position"] := "absolute"
		this.smpls_16.label["style.position"] := "absolute"
		this.smpls_16["style.top"] := "-20px"
		this.smpls_16["style.left"] := "220px"
		this.smpls_16.label["style.top"] := "-20px"
		this.smpls_16.label["style.left"] := "240px"			
	}		
}

class PxSwap  
{
	__new(byref parent, cfg)
	{
		this.master_div := new TexSwapMasterDiv(parent, "pxwap_master_div", "div")
		For k, v in ["Enable\Disable search::sw", "Next shader::n", "Previous shader::p"
					,"Dump shader::d", "Quick browsing::q", "Change text color::c", "Change shader::s"]
		{
			id                   := "PxSwap." strsplit(v, "::")[2]
			parent[id]           := new TSwappItem(this.master_div, id "_label", "label").Init(this.master_div, strsplit(v, "::")[1], this.master_div, cfg)			
		}			
	}		
}

class DinputEmuGpadMenuButton extends HTMLElement
{
	init(name, target_id, master_id)
	{
		this.ahk.target_id         := target_id
		this.ahk.masteri_id        := master_id
		this.ahk.name              := name
		this.innerHTML             := name
		this["style.display"]      := "block"
		this["style.width"]        := "100%"
		this["style.textAlign"]    := "left"
		this["style.zIndex"]       := 1
		this["style.border"]       := "1px solid " g_.color_d			
		this["style.outline"]      := "none"
		this["style.marginBottom"] := "1px"
		return this	
	}
	Over()
	{
		this["style.border"] := "1px solid blue" 
	}
	Out()
	{
		this["style.border"] := "1px solid " g_.color_d	   
	}
	clicked()
	{
		if (this.ahk.name != "Dissmiss")
		this.body().child(this.ahk.target_id).Update(this.ahk.name)	
		this.body().child(this.ahk.masteri_id).key_menu :=	""
	}
}

class DinputEmuXinputMenu extends HTMLElement
{
	init(parent, master_id)
	{
		this.ahk.parent_id            := parent.js_element_id
		this.ahk.masteri_id           := master_id
		this["style.display"]         := "block"
		this["style.zIndex"]          := 1	
		
		this["style.position"]        := "absolute"
		this["style.backgroundColor"] := g_.color_d
		
		for k, v in strsplit("A,B,X,Y,Left button,Right button,Left Trigger,Right trigger,Back,Start,Left stick,Right stick", ",")
			this["Gpad " k] := new DinputEmuGpadMenuButton(this, "DinputEmuGpadMenuButton_" k, "BUTTON").init(v, parent.js_element_id, master_id)
		this["Dissmiss"] := new DinputEmuGpadMenuButton(this, "DinputEmuGpadMenuButton_" "Dissmiss", "BUTTON").init("Dissmiss", parent.js_element_id, master_id)
			
		return this
	}	
}

class DinputEmuGpadMenu extends HTMLElement
{
	init(parent, master_id)
	{
		this.ahk.parent_id            := parent.js_element_id
		this.ahk.masteri_id           := master_id
		this["style.display"]         := "block"
		this["style.zIndex"]          := 1	
		
		this["style.position"]        := "absolute"
		this["style.backgroundColor"] := g_.color_d
		
		loop, 12
			this["Gpad " A_index] := new DinputEmuGpadMenuButton(this, "DinputEmuGpadMenuButton_" A_index, "BUTTON").init("Gamepad " A_index, parent.js_element_id, master_id)
		this["Dissmiss"] := new DinputEmuGpadMenuButton(this, "DinputEmuGpadMenuButton_" "Dissmiss", "BUTTON").init("Dissmiss", parent.js_element_id, master_id)
			
		return this
	}	
}

class DinputEmuModeMenuButton extends HTMLElement
{
	init(name, master_id)
	{
		this.ahk.masteri_id        := master_id
		this.ahk.name              := name
		this.innerHTML             := name
		this["style.display"]      := "block"
		this["style.width"]        := "100%"
		this["style.textAlign"]    := "left"
		this["style.zIndex"]       := 1
		this["style.border"]       := "1px solid " g_.color_d			
		this["style.outline"]      := "none"
		this["style.marginBottom"] := "1px"
		return this	
	}
	Over()
	{
		this["style.border"] := "1px solid blue" 
	}
	Out()
	{
		this["style.border"] := "1px solid " g_.color_d	   
	}
	clicked()
	{
		if (this.ahk.name != "Dissmiss")
		this.body().child("dinput_mode_menu").ModeChanged(this.ahk.name)	
		this.body().child(this.ahk.masteri_id).mode_menu :=	""
	}
}

class DinputEmuModeMenu extends HTMLElement
{
	init(master_id, parent)
	{
		this.ahk.parent_id            := parent.js_element_id
		this.ahk.masteri_id           := master_id
		this["style.display"]         := "block"
		this["style.zIndex"]          := 1	
		
		this["style.position"]        := "absolute"
		this["style.backgroundColor"] := g_.color_d
		
		for k, v in strsplit("Dinput gamepad,Keyboard,Keyboard tap,Keyboard repeat,Keyboard toggle,Dissmiss", ",")
			this[v] := new DinputEmuModeMenuButton(this, "DinputEmuModeMenuButton_" v, "BUTTON").init(v, master_id)
			
		return this
	}
	ModeChanged(mode)
	{
		this.body().child(this.ahk.parent_id).SetText( mode )
		this.body().child(this.ahk.parent_id).Update( mode )
		for k, v in ["keya", "keyb", "alta", "altb"]
		{
			this.body().child(StrReplace(this.ahk.parent_id, "mode", v)).ModeChanged( mode )
		}
	}
}

class DinputEmuModeButton extends HTMLElement
{
	init(master_id)
	{
		this["style.width"]     := "110px"
		this.ahk.name           := ""
		this.ahk.masteri_id     := master_id
		this["style.border"]    := "0px"		
		this["style.outline"]   := "none"
		return this
	}
	SetText(txt)
	{
		this.ahk.name       := txt
		this.innerHTML      := txt
	}
	Update(mode)
	{
		this.body().child(this.ahk.masteri_id).Set(this.js_element_id, mode)
	}	
	clicked()
	{		
		master           := this.body().child(this.ahk.masteri_id)
		master.mode_menu := ""
		master.mode_menu := new DinputEmuModeMenu(this, "dinput_mode_menu", "div").init(this.ahk.masteri_id, this)
	}
	Over()
	{
		this["style.border"] := "1px solid blue" 
	}
	Out()
	{
		this["style.border"] := "1px solid " g_.color_d	   
	}
}

class DinputEmuLsModeMenuButton extends DinputEmuModeMenuButton
{
	init(name, master_id)
	{
		this.ahk.masteri_id        := master_id
		this.ahk.name              := name
		this.innerHTML             := name
		this["style.display"]      := "block"
		this["style.width"]        := "100%"
		this["style.textAlign"]    := "left"
		this["style.zIndex"]       := 1
		this["style.border"]       := "1px solid " g_.color_d			
		this["style.outline"]      := "none"
		this["style.marginBottom"] := "1px"
		return this	
	}
	Over()
	{
		this["style.border"] := "1px solid blue" 
	}
	Out()
	{
		this["style.border"] := "1px solid " g_.color_d	   
	}
	clicked()
	{
		if (this.ahk.name != "Dissmiss")
		this.body().child("dinput_mode_menu").ModeChanged(this.ahk.name)	
		this.body().child(this.ahk.masteri_id).mode_menu :=	""
	}
}

class DinputEmuLsModeMenu extends DinputEmuModeMenu
{
	init(master_id, parent)
	{
		this.ahk.parent_id            := parent.js_element_id
		this.ahk.masteri_id           := master_id
		this["style.display"]         := "block"
		this["style.zIndex"]          := 1	
		
		this["style.position"]        := "absolute"
		this["style.backgroundColor"] := g_.color_d
		
		for k, v in strsplit("Left stick,Keyboard,Dissmiss", ",")
			this[v] := new DinputEmuLsModeMenuButton(this, "DinputEmuModeMenuButton_" v, "BUTTON").init(v, master_id)
			
		return this
	}
	ModeChanged(mode)
	{
		this.body().child(this.ahk.parent_id).SetText( mode )
		this.body().child(this.ahk.parent_id).Update( mode )
		children_id := StrReplace(this.ahk.parent_id, "_line_modebutton", "_line_keyabutton")
		labels      := ["Left stick up", "Left stick down", "Left stick left", "Left stick right"]
		for k, v in ["leftstickup", "leftstickdown", "leftstickleft", "leftstickright"]
		{
			child_id := StrReplace(children_id, "leftstick", v) 
			child    := this.body().child(child_id)
			child.ModeChanged(mode)	 				
		}
	}
}

class DinputEmuLsModeButton extends DinputEmuModeButton
{
	clicked()
	{		
		master           := this.body().child(this.ahk.masteri_id)
		master.mode_menu := ""
		master.mode_menu := new DinputEmuLsModeMenu(this, "dinput_mode_menu", "div").init(this.ahk.masteri_id, this)
	}
	Over()
	{
		this["style.border"] := "1px solid blue" 
	}
	Out()
	{
		this["style.border"] := "1px solid " g_.color_d	   
	}
	SetText(txt)
	{
		this.ahk.name       := txt
		this.innerHTML      := txt
		if instr(txt, "Key")
			return
		children_id := StrReplace(this.js_element_id, "_line_modebutton", "_line_keyabutton")
		for k, v in ["leftstickup", "leftstickdown", "leftstickleft", "leftstickright"]
		{
			child_id := StrReplace(children_id, "leftstick", v) 
			child    := this.body().child(child_id)			
			child.ModeChanged(txt)	 				
		}
	}
}

class DinputEmuDpModeMenu extends DinputEmuModeMenu
{
	init(master_id, parent)
	{
		this.ahk.parent_id            := parent.js_element_id
		this.ahk.masteri_id           := master_id
		this["style.display"]         := "block"
		this["style.zIndex"]          := 1	
		
		this["style.position"]        := "absolute"
		this["style.backgroundColor"] := g_.color_d
		
		for k, v in strsplit("Dpad,Keyboard,Keyboard tap,Dissmiss", ",")
			this[v] := new DinputEmuLsModeMenuButton(this, "DinputEmuModeMenuButton_" v, "BUTTON").init(v, master_id)
			
		return this
	}
	ModeChanged(mode)
	{
		this.body().child(this.ahk.parent_id).SetText( mode )
		this.body().child(this.ahk.parent_id).Update( mode )
		children_id := StrReplace(this.ahk.parent_id, "_line_modebutton", "_line_keyabutton")
		labels      := ["Left stick up", "Left stick down", "Left stick left", "Left stick right"]
		for k, v in ["dpadup", "dpaddown", "dpadleft", "dpadright"]
		{
			child_id := StrReplace(children_id, "dpad", v) 
			child    := this.body().child(child_id)
			child.ModeChanged(mode)	 				
		}
	}
}

class DinputEmuDpModeButton extends DinputEmuModeButton
{
	clicked()
	{		
		master           := this.body().child(this.ahk.masteri_id)
		master.mode_menu := ""
		master.mode_menu := new DinputEmuDpModeMenu(this, "dinput_mode_menu", "div").init(this.ahk.masteri_id, this)
	}	
	SetText(txt)
	{
		this.ahk.name       := txt
		this.innerHTML      := txt
		if instr(txt, "Key")
			return
		children_id := StrReplace(this.js_element_id, "_line_modebutton", "_line_keyabutton")
		for k, v in ["dpadup", "dpaddown", "dpadleft", "dpadright"]
		{
			child_id := StrReplace(children_id, "dpad", v) 
			child    := this.body().child(child_id)			
			child.ModeChanged(txt)	 				
		}
	}
}

class DinputEmuKeyButton extends HTMLElement
{
	init(master_id)
	{
		this["style.width"]     := "110px"
		this["style.height"]    := "100%"
		this["style.display"]   := "block"
		this.ahk.masteri_id     := master_id
		this["style.border"]    := "0px"		
		this["style.outline"]   := "none"
		return this
	}
	Clicked()
	{
		id   := strsplit(this.js_element_id, "_line_")[1] . "_line_modebutton"
		mode := this.body().Child(id).ahk.name 
		if (mode != "Dinput gamepad")
		{
			master          := this.body().child(this.ahk.masteri_id)
			master.key_menu := ""
			master.key_menu := new KbrdMenu(this, "dinput_key_menu", "div").init(this)	
			master.key_menu["style.left"] := this["style.left"]		
		} else {
			master          := this.body().child(this.ahk.masteri_id)
			master.key_menu := ""
			master.key_menu := new DinputEmuGpadMenu(this, "dinput_key_menu", "div").init(this, this.ahk.masteri_id)	
			master.key_menu["style.left"] := this["style.left"]				
		}
	}
	DissmissKbrdMenu()
	{
		master          := this.body().child(this.ahk.masteri_id)
		master.key_menu := ""
	}
	Update(key)
	{
		master          := this.body().child(this.ahk.masteri_id)
		master.key_menu := ""
		this.ahk.name   := key
		this.innerHTML  := key
		this.body().child(this.ahk.masteri_id).Set(this.js_element_id, key)
	}
	Enable()
	{
		for k, v in strsplit("Up,Down,left,Right", ",")
		{
			if (this.ahk.name = v)
			return
		}
		js := "document.getElementById(""" this.js_element_id """).disabled = false;"
		this.body().__Exec(js)	
	}
	ModeChanged(mode)
	{
		if (mode = "Dinput Gamepad") 
		{
			if (Instr(this.ahk.name, "GamePad") = 0 )
				this.Update("none")
		} 
		else if Instr(this.ahk.name, "GamePad")
			this.Update("none")
		else if (mode = "Left stick")
		{			
			this.Disable()		
			labels := {"leftstickup" : "Up", "leftstickdown" : "Down", "leftstickleft" : "Left", "leftstickright" : "Right"}			
			this.Update(labels[ StrReplace(StrReplace(this.js_element_id, "dinput_table_", ""), "_line_keyabutton", "") ])
			return
		} 
		else if (mode = "Dpad")
		{			
			this.Disable()		
			labels := {"Dpadup" : "Up", "Dpaddown" : "Down", "Dpadleft" : "Left", "Dpadright" : "Right"}			
			this.Update(labels[ StrReplace(StrReplace(this.js_element_id, "dinput_table_", ""), "_line_keyabutton", "") ])
			return
		}
		else if instr(this.js_element_id, "leftstick")
			this.Update("none")
		else if instr(this.js_element_id, "dpad")
			this.Update("none")
		this.enable()
	}	
	Over()
	{
		this["style.border"] := "1px solid blue" 
	}
	Out()
	{
		this["style.border"] := "1px solid " g_.color_d	   
	}	
}

class DinputModifier extends HTMLElement
{
	init(cfg)
	{
		this.ahk.cfg            := cfg
		this["style.width"]     := "110px"
		this["style.height"]    := "100%"
		this["style.display"]   := "block"
		this["style.border"]    := "0px"		
		this["style.outline"]   := "none"
		val                     := StrReplace(new ini(cfg).read("m", "J2K"), "Gamepad ", "")
		this.innerHTML          := val ? val : "none"  
		return this
	}
	Over()
	{
		this["style.border"] := "1px solid blue" 
	}
	Out()
	{
		this["style.border"] := "1px solid " g_.color_d	   
	}	
	Update(key)
	{		
		this.innerHTML := key ? key : "none"
		cfg := new ini(this.ahk.cfg)
		cfg.edit("m", 0, "J2K")
		for k, v in strsplit("A,B,X,Y,Left button,Right button,Left Trigger,Right trigger,Back,Start,Left stick,Right stick", ",")
		{
			if (key=v)
				cfg.edit("m", k+4, "J2K")
		}
		cfg.save()
		
		
		master          := this.body().child("DinputEmu_master_div")
		master.key_menu := ""
	}
	clicked()
	{
		master          := this.body().child("DinputEmu_master_div")
		master.key_menu := ""
		master.key_menu := new DinputEmuXinputMenu(this, "dinput_key_menu", "div").init(this, master.js_element_id)	
		master.key_menu["style.left"] := this["style.left"]	
		master.key_menu.Dissmiss.innerHTML := "none"
		master.key_menu.Dissmiss.ahk.name := "none"
	}
	DissmissKbrdMenu()
	{
		return
	}
}

class MacrosButton extends HTMLElement
{
	init(cfg, key)
	{
		this["style.width"]           := "120px"
		this["style.height"]          := "20px"
		this["style.border"]          := "1px solid " g_.color_d	 
		this["style.outline"]         := "none"		
		this["style.display"]         := "inline-block"
		this["style.backgroundColor"] := g_.color_d
		this.ahk.cfg   := cfg
		this.ahk.key   := key
		val            := new ini(cfg).read(key, "k2k")
		this.innerHTML := val ? val : "none"
		return this
	}
	clicked()
	{
		this.body().child("Macros_master_div").menu := ""
		this.body().child("Macros_master_div").menu := new KbrdMenu(this, "Macros_menu", "div").init(this)	
		this["style.border"] := "1px solid blue" 	
	}
	DissmissKbrdMenu()
	{
		this.body().child("Macros_master_div").menu := ""
	}
	Update(val)
	{
		this.innerHTML := val
		if (val = "none")
			val := ""
		cfg := new ini(this.ahk.cfg)
		cfg.edit(this.ahk.key, val, "k2k")
		cfg.save()
		this.DissmissKbrdMenu() 
	}
	Over()
	{
		this["style.border"] := "1px solid blue" 
	}
	Out()
	{
		this["style.border"] := "1px solid " g_.color_d	   
	}	
}

class Macros extends HTMLElement
{
	init(cfg)
	{
		this["style.marginTop"]  := "20px"
		this["style.marginLeft"] := "5px"
		this.ahk.cfg             := cfg
		this.header              := new HTMLElement(this, "k2k_header", "p")	
		this.header.innerHTML    := "&#9658;" " Macros" 		
		for k, v in strsplit("t0 t1 r0 r1 s0 s1 s2 s3 s4 s5", " ")
		{
			this[v "_e"]      := new BOOLInput(this, "k2k." v ".e", "input").init(this.ahk.cfg , this, "k2k." v "e", "", "")	
			this[v "_e"].details_div["style.top"] := "-22px"	
			this[v "_sender"] := new MacrosButton(this[v "_e"].details_div, "k2k_" v "_sender", "BUTTON").init(cfg, v "k")	
			this[v "_mode"]   := new HTMLElement(this[v "_e"].details_div, "k2k_" v ".mode", "label")		
			this[v "_what"]   := new MacrosButton(this[v "_e"].details_div, "k2k_" v "_what", "BUTTON").init(cfg, v "v")	
			this[v "_mode"]["style.position"] := "relative"
			this[v "_mode"].innerHTML := k < 3 ? " toggles &nbsp; " : k > 4 ? " replaces " : " repeats &nbsp; "		
			this[v "_mode"]["style.width"] := "120px"
		}
		return this
	}	
}

class DinputEmuModeInfo extends HTMLElement
{
	init(parent)
	{
		modes := instr(parent.js_element_id, "left_") ? fileopen("..\Help\DinputLsModes.txt", "r").read()
		: instr(parent.js_element_id, "dpad") ? fileopen("..\Help\DinputDpadModes.txt", "r").read()
		: instr(parent.js_element_id, "right_") ? fileopen("..\Help\DinputRSModes.txt", "r").read() 
		: fileopen("..\Help\DinputModes.txt", "r").read()
		
		
		this["style.padding"]         := "5px"	
		this["style.paddingBottom"]   := "0px"	 
		this["style.textAlign"]       := "justify" 
		this["style.position"]        := "absolute" 
		this["style.backgroundColor"] := "#f9edbe"
		this["style.zIndex"]          := 1
		this["style.top"]             := parent["style.top"]
		this["style.left"]            := parent["style.width"]
		this.innerHTML                := this.body().processtext(modes) 
		return this
	}
	clicked()
	{
		this.body().child("dinput_table").modes_info := ""
	}	
}

class DinputEmuModeHelp extends HTMLElement
{
	init()
	{		
		this["style.border"]          := "none"	 
		this["style.outline"]         := "none"	
		this["style.color"]           := "#0000FF"
		this["style.backgroundColor"] := "Transparent"
		this.innerHTML                := instr(this.js_element_id, "left_") ? "( ? )" 
		: instr(this.js_element_id, "dpad") ? "{ ? }" : "[ ? ]"
		this.href           := "'javascript:dummy()'"
		return this
	}
	Over()
	{
		this["style.cursor"] := "pointer"
	}
	Out()
	{
		this["style.cursor"] := "Default"
	}
	Clicked()
	{
		table := this.body().child("dinput_table")
		table.modes_info := ""		
		table.modes_info := new DinputEmuModeInfo(this, "dinput_modes_info", "div").init(this)		
	}
	disable()
	{
		this.style().color  := "#aaaaFF"
		js := "document.getElementById(""" this.js_element_id """).disabled = true;"
		this.body().__Exec(js)	
	}
	
	enable()
	{
		this.style().color  := "#0000FF"
		js := "document.getElementById(""" this.js_element_id """).disabled = false;"
		this.body().__Exec(js)	
	}
}

class DinputRSButton extends HTMLElement
{
	Init(parentid)
	{
		this.parentid := parentid
		return this
	}	
}

class DInputDropDown extends HTMLElement
{
	Init(parentid, cfg)
	{
		this.ahk.cfg                   := cfg
		this["style.height"]           := "19px"
		this["style.width"]            := "110px"
		this["style.border"]           := "0px"		
		this["style.outline"]          := "none"	
		this["style.position"]         := "relative"	
		this["style.backgroundColor"]  := "#dddddd"
		this["style.textAlignLast"]    := "center"
		this["style.webkitAppearance"] := "none"		
		
		ObjInsert(this, "parentid", parentid)
		for k, v in strsplit("Right Stick,Left Stick,Mouse", ",")
		{  
			this[v]                := new HTMLElement(this, this.js_element_id "_" v, "option")
			this[v].value          := v
			this[v].innerHTML      := v
			this[v]["style.border"]          := "0px"		
			this[v]["style.outline"]         := "none"	
			this[v]["style.backgroundColor"] := "#dddddd"			
		}
		this.value := "Mouse"
		this.body().__Exec( "document.getElementById(""" this.js_element_id """).onchange=function(){SliderValueChanged()};" ) 
		
		line := this.body().child("dinput_table_rightstick_line")
		;this.up_cell   := new HTMLElement(line, "rstick_up_cell", "td")
		;this.up_button := new DinputRSButton(this.up_cell, "rstick_up_button", "BUTTON").init(this.js_element_it) 
		;this.up_button.innerHTML := "ok"
		;this.up_button.OnClickId(this, "ChildClicked")
		return this
	}
	ChildClicked(id)
	{
		msgbox % id " " this.parentid
		parent          := this.body().child(this.parentid)
		parent.key_menu := new DinputEmuGpadMenu(this.body().child(id), "dinput_key_menu", "div").init(this, this.parentid)			
	}
	Update(name)
	{
		msgbox % name
	}
	Over()
	{
		this["style.border"] := "1px solid blue" 
	}
	Out()
	{
		this["style.border"] := "1px solid " g_.color_d	   
	}
	ValueChanged(value)
	{
		val := {"Right stick" : "0", "Left Stick" : "1", "Mouse" : "2"}[value]
		cfg := new ini(this.ahk.cfg)
		cfg.edit("rs", val, "j2k")
		cfg.save()
	}
}

class DinputEmu extends HTMLElement
{
	init(cfg)
	{
		this.ahk.cfg := cfg
		cfg          := new ini(cfg)
		if (! cfg.read("mds", "J2K"))
		{
			cfg.edit("u","False", "J2K")
			cfg.edit("a",",,,,,,,,,,,,,,,,,,,", "J2K")
			cfg.edit("b",",,,,,,,,,,,,,,,,,,,", "J2K")
			cfg.edit("x",",,,,,,,,,,,,,,,,,,,", "J2K")
			cfg.edit("y",",,,,,,,,,,,,,,,,,,,", "J2K")
			cfg.edit("mds","0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0", "J2K")
			cfg.edit("m","", "J2K")
			cfg.edit("spd","", "J2K")
			cfg.edit("dz","0.25", "J2K")						
		}		
		
		this["style.postion"]                 := "absolute"
		this["style.display"]                 := "block"
		;this.layer                            := new BOOLInput(this, "j2k_layer", "input").init(this.ahk.cfg, this, "j2k.layer", "Layer", "")
		this.table                            := new HTMLElement(this, "dinput_table", "table")
		this.table["style.marginTop"]         := "20px"
		this.table["style.marginBottom"]      := "20px"
		this.table["style.borderCollapse"]    := "collapse"
		this.table.head                       := new HTMLElement(this.table, "dinput_table_head", "tr")
		this.table.head["style.textAlign"]    := "center"
		this.table.head.innerHTML             := StrReplace("<td style='text-align:left;'>Button|Mode|Key A|Key B|Alt A|Alt B<td>", "|", "</td><td>")
		this.table.head["style.borderBottom"] := "solid thin"
		this.modes                            := StrSplit(cfg.read("mds", "J2K"), ",")	
		this.keya                             := StrSplit(cfg.read("a", "J2K"), ",")	
		this.keyb                             := StrSplit(cfg.read("b", "J2K"), ",")	
		this.alta                             := StrSplit(cfg.read("x", "J2K"), ",")	
		this.altb                             := StrSplit(cfg.read("y", "J2K"), ",")	
		
		for k, v in strsplit("A,B,X,Y,Left button,Right button,Left trigger,Right trigger,Back,Start,Left Stick - press,Right Stick - press", ",")
		{
			mode := this.modes[k+4]+1 ? this.modes[k+4]+1 : 1
			this.table[v "_line"]                           := new HTMLElement(this.table, "dinput_table_" v "_line", "tr")
			this.table[v "_line"]["label"]                  := new HTMLElement(this.table[v "_line"], "dinput_table_" v "_line_label", "td")
			this.table[v "_line"]["label"].innerHTML        := v
			this.table[v "_line"]["modecell"]               := new HTMLElement(this.table[v "_line"], "dinput_table_" v "_line_modecell", "td")
			this.table[v "_line"]["modebuttton"]            := new DinputEmuModeButton(this.table[v "_line"]["modecell"] , "dinput_table_" v "_line_modebutton", "BUTTON").init(this.js_element_id)
			this.table[v "_line"]["modeinfo"]               := new DinputEmuModeHelp(this.table[v "_line"]["modecell"] , "dinput_table_" v "_line_modeinfo", "BUTTON").init()
						
			this.table[v "_line"]["keyacell"]               := new HTMLElement(this.table[v "_line"], "dinput_table_" v "_line_keyacell", "td")
			this.table[v "_line"]["keyabuttton"]            := new DinputEmuKeyButton(this.table[v "_line"]["keyacell"] , "dinput_table_" v "_line_keyabutton", "BUTTON").init(this.js_element_id)
			this.table[v "_line"]["keyabuttton"].Update(this.keya[k+4] ?  this.keya[k+4] : "none")
			this.table[v "_line"]["keybcell"]               := new HTMLElement(this.table[v "_line"], "dinput_table_" v "_line_keybcell", "td")
			this.table[v "_line"]["keybbuttton"]            := new DinputEmuKeyButton(this.table[v "_line"]["keybcell"] , "dinput_table_" v "_line_keybbutton", "BUTTON").init(this.js_element_id)
			this.table[v "_line"]["keybbuttton"].Update(this.keyb[k+4] ?  this.keyb[k+4] : "none")
			this.table[v "_line"]["altacell"]               := new HTMLElement(this.table[v "_line"], "dinput_table_" v "_line_altacell", "td")
			this.table[v "_line"]["altabuttton"]            := new DinputEmuKeyButton(this.table[v "_line"]["altacell"] , "dinput_table_" v "_line_altabutton", "BUTTON").init(this.js_element_id)
			this.table[v "_line"]["altabuttton"].Update(this.alta[k+4] ?  this.alta[k+4] : "none")
			this.table[v "_line"]["altbcell"]               := new HTMLElement(this.table[v "_line"], "dinput_table_" v "_line_aktbcell", "td")
			this.table[v "_line"]["altbbuttton"]            := new DinputEmuKeyButton(this.table[v "_line"]["altbcell"] , "dinput_table_" v "_line_altbbutton", "BUTTON").init(this.js_element_id)
			this.table[v "_line"]["altbbuttton"].Update(this.altb[k+4] ?  this.altb[k+4] : "none")
			this.table[v "_line"]["modebuttton"].SetText( StrSplit("Keyboard,Keyboard repeat,Keyboard toogle,Dinput gamepad,Keyboard tap", ",")[ mode ] )
		}
		mode := this.modes[k+5]+1 ? this.modes[k+5]+1 : 1	
		this.table["left_stick_span"]                      := new HTMLElement(this.table, "left_stick_span", "tr")
		this.table["left_stick_span"]["style.height"]	   := "20px"	
		this.table["left_stick_header_line"]               := new HTMLElement(this.table, "left_stick_header_line", "tr")
		this.table["left_stick_header_line"]["style.textAlign"] := "center"
		this.table["left_stick_header_line"].innerHTML     := "<td style='text-align:left;'>Analog Sticks\\Dpad</td><td>Mode</td><td>Up</td><td>Down</td><td>Left</td><td>Right</td>"  
		this.table["left_stick_header_line"]["style.borderBottom"] := "solid thin"
		
		this.table["left_stick_line"]                      := new HTMLElement(this.table, "dinput_table_" "leftstick" "_line", "tr")
		this.table["left_stick_line"]["label"]             := new HTMLElement(this.table["left_stick_line"], "dinput_table_" "leftstick" "_line_label", "td")
		this.table["left_stick_line"]["label"].innerHTML   := "Left stick"
		this.table["left_stick_line"]["modecell"]          := new HTMLElement(this.table["left_stick_line"], "dinput_table_" "leftstick" "_line_modecell", "td")
		this.table["left_stick_line"]["modebuttton"]       := new DinputEmuLsModeButton(this.table["left_stick_line"]["modecell"] , "dinput_table_" "leftstick" "_line_modebutton", "BUTTON").init(this.js_element_id)
		this.table["left_stick_line"]["modeinfo"]          := new DinputEmuModeHelp(this.table["left_stick_line"]["modecell"] , "dinput_table_" "left_stick" "_line_modeinfo", "BUTTON").init()					
					
		this.table["left_stick_line"]["upcell"]            := new HTMLElement(this.table["left_stick_line"], "dinput_table_" "leftstickup" "_line_keyacell", "td")
		this.table["left_stick_line"]["upbuttton"]         := new DinputEmuKeyButton(this.table["left_stick_line"]["upcell"] , "dinput_table_" "leftstickup" "_line_keyabutton", "BUTTON").init(this.js_element_id)
		this.table["left_stick_line"]["upbuttton"].Update(this.keya[17] ?  this.keya[17] : "none")
		this.table["left_stick_line"]["downcell"]          := new HTMLElement(this.table["left_stick_line"], "dinput_table_" "leftstickdown" "_line_keyacell", "td")
		this.table["left_stick_line"]["downbuttton"]       := new DinputEmuKeyButton(this.table["left_stick_line"]["downcell"] , "dinput_table_" "leftstickdown" "_line_keyabutton", "BUTTON").init(this.js_element_id)
		this.table["left_stick_line"]["downbuttton"].Update(this.keya[18] ?  this.keya[18] : "none")
		this.table["left_stick_line"]["leftcell"]          := new HTMLElement(this.table["left_stick_line"], "dinput_table_" "leftstickleft" "_line_keyacell", "td")
		this.table["left_stick_line"]["leftbuttton"]       := new DinputEmuKeyButton(this.table["left_stick_line"]["leftcell"] , "dinput_table_" "leftstickleft" "_line_keyabutton", "BUTTON").init(this.js_element_id)
		this.table["left_stick_line"]["leftbuttton"].Update(this.keya[19] ?  this.keya[19] : "none")
		this.table["left_stick_line"]["rightcell"]         := new HTMLElement(this.table["left_stick_line"], "dinput_table_" "leftstickright" "_line_keyacell", "td")
		this.table["left_stick_line"]["rightbuttton"]      := new DinputEmuKeyButton(this.table["left_stick_line"]["rightcell"] , "dinput_table_" "leftstickright" "_line_keyabutton", "BUTTON").init(this.js_element_id)
		this.table["left_stick_line"]["rightbuttton"].Update(this.keya[20] ?  this.keya[20] : "none")
		this.table["left_stick_line"]["modebuttton"].SetText(StrSplit("Keyboard,,,Left stick", ",")[ mode ])		
		
		this.table["right_stick_line"]                      := new HTMLElement(this.table, "dinput_table_" "rightstick" "_line", "tr")
		this.table["right_stick_line"]["label"]             := new HTMLElement(this.table["right_stick_line"], "dinput_table_" "rightstick" "_line_label", "td")
		this.table["right_stick_line"]["label"].innerHTML   := "Right stick"
		this.table["right_stick_line"]["modecell"]          := new HTMLElement(this.table["right_stick_line"], "dinput_table_" "rightstick" "_line_modecell", "td")
		this.table["right_stick_line"]["modebuttton"]       := new DInputDropDown(this.table["right_stick_line"]["modecell"], "dinput_table_" "rightstick" "_line_modebutton", "select").init(this.js_element_id, this.ahk.cfg)
		this.table["right_stick_line"]["modeinfo"]          := new DinputEmuModeHelp(this.table["right_stick_line"]["modecell"] , "dinput_table_" "right_stick" "_line_modeinfo", "BUTTON").init()
		(i := cfg.read("rs", "J2K")+1) ?: i := 1
		this.table["right_stick_line"]["modebuttton"].value := ["Right Stick", "Left Stick", "Mouse"][i]		
		
		mode := this.modes[1] ? this.modes[1] : 1
		;this.table["d_pad_header_line"]               := new HTMLElement(this.table, "d_pad_header_line", "tr")
		;this.table["d_pad_header_line"]["style.textAlign"] := "center"
		;this.table["d_pad_header_line"].innerHTML     := "<td>D pad</td><td>Mode</td><td>Up</td><td>Down</td><td>Left</td><td>Right</td>"  
		this.table["d_pad_line"]                      := new HTMLElement(this.table, "dinput_table_" "dpad" "_line", "tr")
		this.table["d_pad_line"]["label"]             := new HTMLElement(this.table["d_pad_line"], "dinput_table_" "dpad" "_line_label", "td")
		this.table["d_pad_line"]["label"].innerHTML   := "D pad"
		this.table["d_pad_line"]["modecell"]          := new HTMLElement(this.table["d_pad_line"], "dinput_table_" "dpad" "_line_modecell", "td")
		this.table["d_pad_line"]["modebuttton"]       := new DinputEmuDpModeButton(this.table["d_pad_line"]["modecell"] , "dinput_table_" "dpad" "_line_modebutton", "BUTTON").init(this.js_element_id)
		this.table["d_pad_line"]["modeinfo"]          := new DinputEmuModeHelp(this.table["d_pad_line"]["modecell"] , "dinput_table_" "dpad" "_line_modeinfo", "BUTTON").init()		
				
		this.table["d_pad_line"]["upcell"]            := new HTMLElement(this.table["d_pad_line"], "dinput_table_" "dpadup" "_line_keyacell", "td")
		this.table["d_pad_line"]["upbuttton"]         := new DinputEmuKeyButton(this.table["d_pad_line"]["upcell"] , "dinput_table_" "dpadup" "_line_keyabutton", "BUTTON").init(this.js_element_id)
		this.table["d_pad_line"]["upbuttton"].Update(this.keya[1] ?  this.keya[1] : "none")
		this.table["d_pad_line"]["downcell"]          := new HTMLElement(this.table["d_pad_line"], "dinput_table_" "dpaddown" "_line_keyacell", "td")
		this.table["d_pad_line"]["downbuttton"]       := new DinputEmuKeyButton(this.table["d_pad_line"]["downcell"] , "dinput_table_" "dpaddown" "_line_keyabutton", "BUTTON").init(this.js_element_id)
		this.table["d_pad_line"]["downbuttton"].Update(this.keya[2] ?  this.keya[2] : "none")
		this.table["d_pad_line"]["leftcell"]          := new HTMLElement(this.table["d_pad_line"], "dinput_table_" "dpadleft" "_line_keyacell", "td")
		this.table["d_pad_line"]["leftbuttton"]       := new DinputEmuKeyButton(this.table["d_pad_line"]["leftcell"] , "dinput_table_" "dpadleft" "_line_keyabutton", "BUTTON").init(this.js_element_id)
		this.table["d_pad_line"]["leftbuttton"].Update(this.keya[3] ?  this.keya[3] : "none")
		this.table["d_pad_line"]["rightcell"]         := new HTMLElement(this.table["d_pad_line"], "dinput_table_" "dpadright" "_line_keyacell", "td")
		this.table["d_pad_line"]["rightbuttton"]      := new DinputEmuKeyButton(this.table["d_pad_line"]["rightcell"] , "dinput_table_" "dpadright" "_line_keyabutton", "BUTTON").init(this.js_element_id)
		this.table["d_pad_line"]["rightbuttton"].Update(this.keya[4] ?  this.keya[4] : "none")
		this.table["d_pad_line"]["modebuttton"].SetText(StrSplit("Keyboard,,Dpad,Keyboard tap", ",")[ mode ])
		
		this.table["d_pad_modifier_line"]              := new HTMLElement(this.table, "d_pad_modifier_line", "tr")
		this.table["d_pad_modifier_label_cell"]        := new HTMLElement(this.table["d_pad_modifier_line"] , "d_pad_modifier_cell", "td")
		this.table["d_pad_modifier_label"]             := new HTMLElement(this.table["d_pad_modifier_label_cell"], "d_pad_modifier_label", "label")
		this.table["d_pad_modifier_label"].innerHTML   := "Modifier"
		this.table["d_pad_modifier_bttn_cell"]         := new HTMLElement(this.table["d_pad_modifier_line"] , "d_pad_modifier_button_cell", "td")
		this.table["d_pad_modifier_bttn"]              := new DinputModifier(this.table["d_pad_modifier_bttn_cell"], "d_pad_modifier_bttn", "BUTTON").init(this.ahk.cfg)
			
			
		cfg := ""	
		this.summary := new HTMLElement(this, "summary", "p")
		;this.summary.innerHTML := this.ToString(this.modes) "<br>" this.ToString(this.keya) "<br>" this.ToString(this.keyb) "<br>" this.ToString(this.alta) "<br>" this.ToString(this.altb)
		;this.rs  := new BOOLInput(this, "J2K.s", "input").Init(this.ahk.cfg, this, "J2K.rs", "Swap sticks", "If a stick is set as keyboard or mouse, it is ignored")
		this.dz  := new FloatInput(this, "J2K.dz", "input").Init(this.ahk.cfg, this, "J2K.dz", "Dead zone", "0.25-0.50-0.01", "Dead zone of the analog sticks")
		this.spd := new FloatInput(this, "J2K.spd", "input").Init(this.ahk.cfg, this, "J2K.spd", "Mouse sensitivity", "0.05-0.10-0.01", "Applies when the right stick emulates the mouse")

		return this
	}
	DisableAll(objct)
	{
		for k, v in objct
		{
			v.disable()
			this.DisableAll(v)
		}
	}
	Disable()
	{
		for k, v in this
		{
			v.disable()
			this.DisableAll(v)
		}
	}
	EnableAll(objct)
	{
		for k, v in objct
		{
			v.Enable()
			this.EnableAll(v)
		}
	}
	Enable()
	{
		for k, v in this
		{
			v.Enable()
			this.EnableAll(v)
		}
	}
	ToString(lst)
	{
		str := ""
		for k, v in lst
			str .= "," v
		return StrReplace(str, ",", "", ,1)
	}
	Set(id, key)
	{
		split := strsplit(id, "_")
		butt  := split[3]
		what  := StrReplace(split[5], "button", "") 
		;fileopen("*", "w").writeline(butt " " what " = " key)

		if (what = "mode")
		{
			val := 3
			for k, v in strsplit("Keyboard,Keyboard repeat,Keyboard toggle,,Keyboard tap", ",")
			{
				if (key = v)
					val := k-1
			}
			index := []
			for k, v in strsplit("Dpad,Dpad,Dpad,Dpad,A,B,X,Y,Left button,Right button,Left trigger,Right trigger,Back,Start,Left Stick - press,Right Stick - press,"
			. "leftstick,leftstick,leftstick,leftstick", ",")
			{
				if (butt = v)
					index.push(k)
			}
			for k, v in	index	
				this.modes[v] := val
		}
		else 
		{
			index := []
			for k, v in strsplit("Dpadup,Dpaddown,Dpadleft,Dpadright,A,B,X,Y,Left button,Right button,Left trigger,Right trigger,Back,Start,Left Stick - press,Right Stick - press,"
			. "leftstickup,leftstickdown,leftstickleft,leftstickright", ",")
			{
				if (butt = v)
					this[what][k] := StrReplace(key, "none", "")
			}
		}
		;this.summary.innerHTML := this.ToString(this.modes) "<br>" this.ToString(this.keya) "<br>" this.ToString(this.keyb) "<br>" this.ToString(this.alta) "<br>" this.ToString(this.altb)
		cfg := new ini(this.ahk.cfg)
		cfg.edit("mds", this.ToString(this.modes), "J2K")
		cfg.edit("a", this.ToString(this.keya), "J2K")
		cfg.edit("b", this.ToString(this.keyb), "J2K")
		cfg.edit("x", this.ToString(this.alta), "J2K")
		cfg.edit("y", this.ToString(this.altb), "J2K")
		cfg.save()
	}
}

class PlayButton extends HTMLElement
{
	init(cfg)
	{
		this.className                := "fa fa-play"
		this.src                      := "logo.png"
		ObjInsert(this, "cfg", cfg)
		this["style.color"]           := "white"
		this["style.backgroundColor"] := "RoyalBlue"
		this["style.border"]          := "0px"
		this["style.outline"]         := "none"
		this["style.marginLeft"]      := "5px"
		this["style.width"]           := "150px"
		this["style.height"]          := "30px"
		this["style.marginBottom"]    := "20px"
		this["style.marginTop"]       := "5px"
		this.innerHTML                := " Play"
		return this
	}
	Over()
	{
		this["style.backgroundColor"] := "DodgerBlue"
	}
	Out()
	{
		this["style.backgroundColor"] := "RoyalBlue" 
	}	
	clicked()
	{
		target := new ini(this.cfg).read("target")
		if dllcall("GetBinaryTypeW", str, target, "uint*", type:=0)
		{
			cfg  := StrReplace(this.cfg, "..\", "")	
			/*
			name := StrReplace(StrReplace(this.cfg, "..\" g_.profiles "\", ""), ".ini", "")
			iso  := StrSplit(StrSplit(new ini("..\main.ini").read(name, "devflags"), ".iso")[1], "-iso")[2]
			if (iso)
			{
				h := dllcall("LoadLibraryW", str, A_mydocuments "\Autohotkey\dlls\peixoto.dll", ptr)
				new VirtualDisk().Mount("E:\Users\dllob\Downloads\Game ISOS\" trim(iso) ".iso", "D")
				dllcall("FreeLibrary", ptr, h)
			}	
			*/			
			run ..\injector.exe src\injector.txt -f "%cfg%", ..\
			return
		}
		msgbox, 64, ,Prease indicate the path of the game's executable`nThis is a one time only procedure
		FileSelectFile, target, Options, , , (*.exe)
		if not target
		return
		cfg := new ini(this.cfg)
		cfg.edit("Target", target)
		cfg.save()
		return this.clicked()	
	}
}

class ShortcutButton extends PlayButton
{
	_init(cfg)
	{
		this.init(cfg)
		this.innerHTML := " Create shortcut"
		this.className := "fa fa-share"
		return this
	}
	clicked()
	{
		target := new ini(this.cfg).read("target")
		if (!target)
		{
			new PlayButton(this.cfg).clicked()
			target := new ini(this.cfg).read("target")
			if (!target)
				return
		} 
		splitpath, target, , , ,name
		path := StrReplace(A_ScriptDir, "Qt", "injector.exe")
		cfg  := StrSplit(this.cfg, "..\")[2]
		name := StrSplit(StrSplit(cfg, "\")[2], ".")[1]
		lnk  := A_desktop "\" name ".lnk"
		dir  := StrReplace(A_ScriptDir, "Qt", "")
		FileCreateShortcut, %path%, %lnk%, %dir%, src\injector.txt -f "%cfg%", ,%target%
		msgbox, 64, ,Done! A shortcut was placed in the desktop
	}
}

class WikiButton extends PlayButton
{
	_init(cfg, wiki)
	{		
		this.ahk.wiki := wiki
		this.style().position           := "relative"  
		this.style().height             := "30px"
		this.style().top                := "9px"
		this.style().left               := "5px"
		this.style().width              := "150px"
		this.style().display            := "inline-block"
		   
		this.img                        := new ChildDiv(this, "wiki_img", "img").init(this)
		this.img.style().mixBlendMode   := "screen"
		this.img.style().height         := "28px"
		this.img.style().position       := "relative"  
		this.img.style().marginTop      := "1px" 
		this.img.style().marginLeft     := "10px" 
		this.img.style().marginRight    := "1px" 
		this.img.style().marginBottom   := "1px" 		
		this.img.src                    := "PCGamingWiki_wide.png"
		this.style().backgroundColor    := "RoyalBlue" 
		this.style().color              := "white" 
		this.img.style().color          := "white" 
		return this
	}
	clicked()
	{
		run, % this.ahk.wiki
	}
}

class RunCheatEngine extends HTMLElement
{
	_init()
	{
		s                 := this.style()
		s.position        := "Relative"
		s.top             := "-35px"
		s.width           := "150px"
		s.height          := "30px"
		s.left            := "-5px"
		s.float           := "Right"
		s.backgroundColor := "RoyalBlue"
		s.color           := "White"
		this.style().border             := "0px" 
		this.style().OutLine            := "None" 
		return this
	}
	Over()
	{
		this.style().backgroundColor := "DodgerBlue" 
		this.style().border          := "0px" 
		this.style().OutLine         := "None" 		
	}
	Out()
	{
		this.style().backgroundColor := "RoyalBlue" 
		this.style().border          := "0px" 
		this.style().OutLine         := "None" 		
	}	
}

class CheatTip extends HTMLElement
{
	_init(table, target)
	{
		this.ahk.table    := table
		this.ahk.exe      := target
		s                 := this.style()		
		s.left            := "10px"
		s.top             := "-10px"
		s.marginLeft      := "5px" 
		s.marginRight     := "5px" 
		s.marginTop       := "0px" 
		s.marginBottom    := "15px"
		s.display         := "None"
		this.ahk.target   := target
		this.style().backgroundColor := "#f9edbe" 
		
		html =
		(LTRIM
		{b ==[Using cheats]==
			{nfo Install [cheat Cheat engine (64 bit)] if you don't already have it}
			{nfo Click the i<Start cheat engine>i button bellow and [cheat cheat engine ] will be 
			launched and the appropriate cheat table loaded}
			{nfo Provided that you have already launched the game once with peixoto's patch,
			[cheat cheat engine] will automatically attatch to the game - [cheat cheat engine] will also 
			close itselt when you exit the game}	
			{nfo Configure cheat engine to aways exectute lua scripts:<br> 
			edit &#x2192 settings &#x2192 general settings &#x2192 when a table has a lua script, execute it &#x2192 b|ALWAYS|b}		
			{nfo All tables use an Autohotkey plugin, so if you modify or start them directly 
			with cheat engine, they will not work properly}
			{nfo If a cheat doesn't work because you have a differt version of the game, click table extras on cheat engine, 
			exception made for very old games that don't recive updates anymore, I leave comments there which sould help you
			adapt the table}
		<br>
		<br>
		<br>
		<br>			
		}
		)
		this.innerHTML      := this.body().ProcessText(html)
		this._run           := new RunCheatEngine(this, "cheat_tip_run", "Button")._init()
		this._run.innerText := "Start cheat engine"
		this._run.OnClick(this, "Start")
		this._hde           := new RunCheatEngine(this, "cheat_tip_hide", "Button")._init()
		this._hde.innerText := "Close"
		this._hde.style().left := "-10px"
		this._hde.OnClick(this, "HideDiv")		
		return this
	}
	HideDiv()
	{
		this.style().display := "None"
	}
	Start()
	{
		table := this.ahk.table
		exe   := this.ahk.exe
		run ..\injector.exe "Cheat Engine.ahk" "%table%" "%exe%"
	}	
}

class CheatButton extends PlayButton
{
	_init(table, exe)
	{		
		this.ahk.table                  := table
		this.ahk.exe                    := exe
		this.style().position           := "relative"  
		this.style().height             := "30px"
		this.style().top                := "-2px"
		this.style().left               := "10px"
		this.style().width              := "150px"
		this.style().display            := "inline-block"
		this.style().border             := "0px" 
		this.style().OutLine            := "None" 		
		
		this.style().background         := "url('Cheats.png')"
		this.style().backgroundRepeat   := "no-repeat"
		this.style().backgroundPosition := "left"
		
		this.style().backgroundColor    := "#eeeeee" 
		this.style().color              := "Blue" 
		this.innerText                  := "Cheats"
		this.style().textAlign          := "Center"   
		return this
	}	
	Over()
	{
		this.style().backgroundColor    := "#f9edbe" 
		this.style().border             := "0px" 
		this.style().OutLine            := "None" 		
	}
	Out()
	{
		this.style().backgroundColor    := "#eeeeee" 	
		this.style().border             := "0px" 	
		this.style().OutLine            := "None" 
	}	
	Clicked()
	{
		this.body().child("cheat_tip_div").style().display := "block"
		this.style().border             := "0px" 	
		this.style().OutLine            := "None"
	}
}

class ChildDiv extends HTMLElement
{
	init(parent)
	{
		this.ahk.p_id := parent.js_element_id
		;this.style().backgroundColor    := "inherit" 
		this.style().color              := "white" 
		return this
	}
	Over()
	{
		this.body().child(this.ahk.p_id).over()
	}
	Out()
	{
		this.body().child(this.ahk.p_id).out()
	}	
	clicked()
	{
		this.body().child(this.ahk.p_id).clicked()
	}
}

class CreateNew extends PlayButton
{
	_init()
	{	
		this.style().display            := "block"
		this.img                        := new ChildDiv(this, "create_new_img", "img").init(this)
		this.img.style().mixBlendMode   := "screen"
		this.img.style().height         := this.style().height() 
		this.img.style().width          := this.style().width() 
		this.img.style().marginTop      := "0px" 
		this.img.style().marginLeft     := "25px" 		
		this.img.style().display        := "block"
		this.img.src                    := "add.png"
		this.text_div                   := new ChildDiv(this, "create_new_label_div", "div").init(this)
		this.text_div.style().display   := "block"
		this.text_div.innerHTML         := " Add game"
		this.text_div.style().position  := "absolute"
		this.text_div.style().left      := "80px"
		this.text_div.style().top       := "-0px"
		this.text_div.style().marginTop := "3px"
		this.style().backgroundColor    := "RoyalBlue" 
		return this
	}
	clicked()
	{
		this.dialog := new CreateNewDialog(this.body(), "create_new_dialog", "div").init(this.body())
	}
}

class Main extends HTMLWindow
{
	_init(arg)
	{
		this.arg := arg
		return this
	}
	loadFinished()
	{
		this.__init(this.arg)
		return true
	}
	__init(arg)
	{	
		this.show(1180, 600)
		this.games_div := new GamesDiv(this, "games_div", "div")	
		this.games_div["style.position"]         := "absolute"			
		this.games_div["style.top"]               := "5px"
		this.games_div["style.width"]             := "220px"
		this.games_div["style.left"]              := "5px"
		;this.games_div["style.overflow"]          := "hidden" 	
		;this.items_div["style.paddingBottom"]       := "35px"		
		this.games_div["style.backgroundColor"]   := g_.color_a  
		this.games_div["style.overflowFaceColor"] := g_.color_c 
							
		this.docs_div := new DocumentsDiv(this, "docs_div", "div")	
		this.docs_div["style.position"]        := "absolute"	
		this.docs_div["style.top"]             := "5px"
		this.docs_div["style.left"]            := "240px"
		this.docs_div["style.width"]           := "700px"
		this.docs_div["style.overflow"]        := "auto"
		this.docs_div["style.backgroundColor"] := g_.color_b 	
		this.docs_div["style.paddingLeft"]     := "15px"
		this.docs_div["style.paddingRight"]    := "15px"
		this.docs_div["style.paddingTop"]      := "15px"
		this.docs_div["style.paddingBottom"]   := "15px"
		this.games_div["style.fontFamily"]     := this.docs_div["style.fontFamily"]	
		
		this.__Exec("document.documentElement.style.overflow = 'hidden';")	
		this.__Exec("document.body.style.backgroundColor = """ g_.color_a """;")
		js =
		(LTRIM		
		function Donate(e)
		{
			SendMessage('Donate', ''); 					
		};
		function dummy()
		{
			SendMessage('Link', document.activeElement.id);
		};	
		)
		this.__Exec(JS)
		this.PopulateGamesList()
		this.child(arg).scroll()
		this.child(arg).clicked()		
		return this
	}
	PopulateGamesList()
	{
		this.search          := ""
		this.items_div       := ""
		this.create_new      := ""
		this.games_div_items := "" 		
		
		this.search                   := new SearchInput(this.games_div, "games_div_search", "INPUT").Init()
		this.search["style.position"] := "absolute"	
		this.search.innerHTML         := "Search"
		this.search["style.height"]   := "20px"
		this.search["style.width"]    := "213px"
		this.search["style.top"]      := "15px"
		
		this.items_div                       := new HTMLElement(this.games_div, "games_div_items_div", "div")
		this.items_div["style.position"]     := "absolute"	
		this.items_div["style.top"]          := "50px"			
		this.items_div["style.marginBottom"] := "35px"	
		this.items_div["style.marginBottom"] := "5px"			
		this.items_div["style.overflowY"]    := "scroll" 		
		this.items_div["style.overflowX"]    := "hidden"

		this.games_div_items                 := []		
		but           := new HelpButton(this.items_div, "Help", "BUTTON").Init().AddIcon("Home.png")
		but.innerHTML := "Home\\Help"
		this.games_div_items.push( but )
		
		addgame := new AddGameButton(this.items_div, "AddGame", "BUTTON").Init().AddIcon("Add.png")
		addgame.innerHTML := "Add Game"
		this.games_div_items.push( addgame ) 

		for k, v in strsplit("InstallShield - 16 bit, InstallShield - 32 bit", ",")
		{
			icons         := ["setup.png", "nfo.png"]
			but           := new ToolButton(this.items_div, v, "BUTTON").Init().AddIcon(icons[k])
			but.innerHTML := v
			ObjInsert(but, "tool", v)
			but.AddIcon()
			this.games_div_items.push( but )
		}		
		if fileexist("..\" g_.profiles "\mGBA.ini")
		{
			mGBA           := new GameButton(this.items_div, "mGBA", "BUTTON").Init() ;.AddIcon("gba.png")
			mGBA.innerHTML := "mGBA"		
			this.games_div_items.push( mGBA ) 
		}	
		if fileexist("..\" g_.profiles "\Kega.ini")
		{
			Kega           := new GameButton(this.items_div, "Kega", "BUTTON").Init() ;.AddIcon("gba.png")
			Kega.innerHTML := "Kega Fusion"		
			this.games_div_items.push( Kega ) 
		}			
		
		games := {}
		p     := g_.profiles
		cmd   := dllcall("GetCommandLine", str)
		if fileexist("..\" g_.profiles "\Any.ini")
		{
			dx11           := new GameButton(this.items_div, "Any", "BUTTON").Init() ;.AddIcon("gba.png")
			dx11.innerHTML := "Any"		
			this.games_div_items.push( dx11 ) 
			game        := "Any"
			games[game] := True	
		}			
		loop, ..\%p%\*.ini
		{	
			;fileopen("*", "w").WriteLine(new ini(A_LoopFileFullPath).read("d3d"))	
			if instr(cmd, " -dx10+")
			{
				if (new ini(A_LoopFileFullPath).read("D3D")+0 < 10)
				continue
			}
			else if instr(cmd, " -dx9")
			{
				if (new ini(A_LoopFileFullPath).read("D3D")+0 != 9)
				continue
			}
			else if instr(cmd, " -dx8")
			{
				if (new ini(A_LoopFileFullPath).read("D3D")+0 != 8)
				continue
			}
			else if instr(cmd, " -dx7-")
			{
				if !((dx:=new ini(A_LoopFileFullPath).read("D3D")+0) > 0 && dx<8)
				continue
			}	
			else if instr(cmd, " -gl-")
			{
				if (new ini(A_LoopFileFullPath).read("D3D") != "gl")
				continue
			}	
			else if instr(cmd, " -gl")
			{
				if (new ini(A_LoopFileFullPath).read("D3D") != "gl")
				continue
			}	
			else if instr(cmd, " -fldrs")
			{
				if fileexist("..\main.ini")
				{
					SplitPath, A_LoopFileFullPath, OutFileName
					game  := StrReplace(OutFileName, ".ini", "")					
					fldrs := instr(new ini(A_LoopFileFullPath).read("svs"), "fldrs")
					fldrs := fldrs = "false" ? False : fldrs				
					if (!instr(new ini("..\main.ini").read(game, "devflags"), "-svs fldrs") && !fldrs)
					continue
				}		
			}	
			else if instr(cmd, " -links")
			{
				if fileexist("..\main.ini")
				{
					SplitPath, A_LoopFileFullPath, OutFileName
					game  := StrReplace(OutFileName, ".ini", "")					
					links := instr(new ini(A_LoopFileFullPath).read("svs"), "links")
					links := links = "false" ? False : links				
					if (!instr(new ini("..\main.ini").read(game, "devflags"), "-svs links") && !links)
					continue
				}		
			}	
			else if instr(cmd, " -MHKS")
			{
				mhks := new ini(A_LoopFileFullPath).read("MHKS") 
				mhks := mhks = "false" ? False : mhks
				if (!mhks)
				continue
			}	
			else if instr(cmd, " -WHKS")
			{
				whks := new ini(A_LoopFileFullPath).read("WHKS") 
				whks := whks = "false" ? False : mhks
				if (!whks)
				continue
			}	
			else if instr(cmd, " -mci")
			{
				if fileexist("..\main.ini")
				{
					SplitPath, A_LoopFileFullPath, OutFileName
					game := StrReplace(OutFileName, ".ini", "")					
					mci := new ini(A_LoopFileFullPath).read("MCI", "WNMM")
					mci := mci = "false" ? False : mci				
					if (!instr(new ini("..\main.ini").read(game, "devflags"), "MCI=True") && !mci)
					continue
				}			
			}	
			else if instr(cmd, " -dsnd")
			{	
				ds0 := new ini(A_LoopFileFullPath).read("e", "dsnd")
				ds1 := ""
				if fileexist("..\main.ini")
				{
					SplitPath, A_LoopFileFullPath, OutFileName
					game := StrReplace(OutFileName, ".ini", "")					
					ds1	 := instr(new ini("..\main.ini").read(game, "devflags"), "-dsnd e=True")					
				}	
				if !(ds1 || ds0="True" || ds0=1 || game="Max payne" || game="Little Big Adventure 2" || game="The Wheel of Time")	
				continue
			}
			else if instr(cmd, " -j2k")
			{	
				if fileexist("..\main.ini") 
				{
					SplitPath, A_LoopFileFullPath, OutFileName
					game := StrReplace(OutFileName, ".ini", "")					
					j2k  := new ini(A_LoopFileFullPath).read("u", "j2k")
					j2k  := j2k = "false" ? False : j2k				
					if (!instr(new ini("..\main.ini").read(game, "devflags"), "-j2k u=True") && 
					    !instr(game, "Little Big Adventure") && !j2k)
					continue
				}		
			}
							
			n             := strsplit(A_LoopFileName, ".ini")[1] 
			if (n = "mGBA" || n = "Kega" || n = "Any")
			continue
			but           := new GameButton(this.items_div, StrReplace(n, "'", "@"), "BUTTON").Init()
			but.innerHTML := n
			this.games_div_items.push( but )	
			if instr(cmd, " -lst")
			fileopen("*", "w").WriteLine("Added game " n)	
			game        := strsplit(strsplit(strsplit(strsplit(A_LoopFileName, " - Direct")[1], " - OpenGl")[1], " - D3D")[1], " - Opengl")[1]
			game        := StrReplace(game, ".ini", "")
			games[game] := True			
		}	
		i   := 1
		gms := ""
		for k, v in games
		{
			gms .= i . " " k "`n"
			i += 1
		}
		Fileopen("gameslist.txt", "w").write(gms)		
		this.games_div_items[1].clicked()
		this.Resized(this.w, this.h)		
	}
	Clicked(id)
	{
		id   := trim(id)
		href := this.links[id]
		;FileOpen("*", "w").write("`n" id)
		if     (id="InstallShield5")
			InstallShieldButton.__Install(5, this.current_game.js_element_id)
		else if(id="InstallShield3")
			InstallShieldButton.__Install(3, this.current_game.js_element_id)
		else if Instr(id, "SCRIPT")
			runscript(href)
		else if instr(id, "gototab")
		{
			split := strsplit(id, "_")			
			this.docs_items["doc_settings_" split[2] "_tab_button"].clicked()
			this.child(split[3]).scroll()
		}	
		else if instr(id, "goto_")
			this.child(strsplit(id, "_")[2]).scroll()
		else if instr(id, "Refreshtotab")
		{
			this.current_game.clicked()			
			this.clicked(StrReplace(id, "Refresh", "go"))
		}
		else if (id="gammatool")
			SetDeviceGammaRamp(128, 1)
		else if (id="tswaptuto")
		{
			this.games_div_items[1].clicked()
			this.child("doc_section_Texture swapping").scroll()
		}
		else if (id="pxswaptuto")
		{
			this.games_div_items[1].clicked()
			this.child("doc_section_Pixel shader override").scroll()
		}
		else if instr(id, "tswap_link=")
		{
			f := strsplit(id, "=")[2]
			p := this.__path__ "\textures"
			if fileexist(p "\" f)
				run, % p "\" f
			else 
			{
				if !(fileexist(p))
				FileCreateDir, %p%	
				run %p%
			}
		}
		else if (id = "show_ce_div")
			this.child("cheat_tip_div").style().display := "block"
		else if (id = "current_game_ini")	
		{
			curr_ini := "..\" g_.profiles "\" StrReplace(this.current_game.js_element_id, "@", "'") ".ini"
			run, "%curr_ini%"
		}
		else if (id = "ON")
			soundplay, % memlib_sound(1)
		else if (id = "OFF")
			soundplay, % memlib_sound(0)
		else if (id = "FAIL")
			soundplay, % memlib_sound(-1)
		else if (href)
			run % href
        else if(id="old_version_redirect")
            run, % "https://1drv.ms/u/s!ApHOE-Ru-xkGgrAi36Xs1icstHe4FQ?e=I70kYs"
		;else if(c:=this.child(id))		
			;c.clicked()	; colapses the pages
		return
	}	
	ProcessText(txt)
	{
		_MCI =
		(LTRIM
		To get the CD music working properly, check the a|gototab_sound_WNMM.MCI ^ MCI emulation |a option on the 
		a|gototab_sound_WNMM.MCI ^ sound tab |a
		)
		autodmp =
		(
		{b <b>Dumping textures</b>  <br> <br>	

		Manual dumps are impratical for dumping several textures for obvios reazons, plus the fact that there is no check 
		if a texture was already dumped and so one can be dumped many times over <br>	
		Auto dumping in the other hand, never dumps the same texture twice, but for other reazons is still impratical 
		in several games <br>	
		In future versions, a feature to dump all currently loaded texures with a check for duplicates will be added to 
		complement the two curent options}
		)
		autodmp := StrReplace(autodmp, "`n")
		stringreplace, txt, txt, `%_MCI`%, %_MCI%
		txt := StrReplace(txt, "%Xinput%", " Better compatibility with Xinput gamepads, see a|gototab_input_j2k.u ^ this|a")
		txt := StrReplace(txt, "`r", "")
		txt := StrReplace(txt, "`n", " ")	
		txt := StrReplace(txt, "\", "&#92;")	
		;txt := StrReplace(txt, "'", "&#96;")
		txt := StrReplace(txt, "||n", "<br><br>")	
		txt := StrReplace(txt, "|n", "<br>")	
		txt := StrReplace(txt, "i|", "<i>")
		txt := StrReplace(txt, "|i", "</i>")
		txt := StrReplace(txt, "b|", "<b>")
		txt := StrReplace(txt, "|b", "</b>")
		txt := StrReplace(txt, ">>n", "<br><br>")	
		txt := StrReplace(txt, ">n", "<br>")		
		txt := StrReplace(txt, "cc<", "<font color='" g_.color_c "'><b>")
		txt := StrReplace(txt, ">cc", "</b></font>")
		txt := StrReplace(txt, "c<", "<font color='" g_.color_c "'>")
		txt := StrReplace(txt, ">c", "</font>")
		txt := StrReplace(txt, "a|", "<a id='")
		txt := StrReplace(txt, " ^ ", "' href='javascript:dummy()'>")
		txt := StrReplace(txt, "|a", "</a>")	
		txt := StrReplace(txt, "l|", "<li>")	
		txt := StrReplace(txt, "<ul>", "<ul style='margin-top:0px;margin-bottom:0px;'>")
		txt := StrReplace(txt, "%__path__%", this.__path__)
		
		p := A_mydocuments "\games\" new ini(this.cfg_file).read("path") 
		txt := StrReplace(txt, "<td>", "<td style='vertical-align: top; padding-right: 20px'>")
		txt := RegExReplace(txt, "i<([^>.]*)>i", "<i>$1</i>")	
		txt := RegExReplace(txt, "b<([^>.]*)>b", "<b>$1</b>")	
		txt := RegExReplace(txt, "t<([^>.]*)>t", "<table>$1</table>")				
		txt := RegExReplace(txt, "a<([^>.]*)--([^>.]*)>a", "<a id='$1' href='javascript:dummy()'>$2</a>")
		StringReplace, txt, txt, `", `',1
		stringreplace, txt, txt, `%ModsLink`%, <a id='gototab_File System_modstuto' href='javascript:dummy()'>Mods manager</a>
	    stringreplace, txt, txt, `%TexturesB`%, <a id='gototab_graphics..._Textswap.e' href='javascript:dummy()'>Texture swapping</a>
		stringreplace, txt, txt, `%Textures`%, <a id='gototab_graphics..._Textswap.e' href='javascript:dummy()'>Texture swapping</a>
		stringreplace, txt, txt, `%TexturesC`%, <a id='gototab_graphics_Textswap.e' href='javascript:dummy()'>Texture swapping</a>
		stringreplace, txt, txt, `%FOLDERID_LocalAppData`%, % GetCommonPath("LOCAL_APPDATA"), All
		stringreplace, txt, txt, `%FOLDERID_RoamingAppData`%, % GetCommonPath("APPDATA"), All
		stringreplace, txt, txt, `%FOLDERID_ProgramData`%, % GetCommonPath("COMMON_APPDATA"), All
		stringreplace, txt, txt, `%FOLDERID_Documents`%, % A_mydocuments, All	
		stringreplace, txt, txt, `%smallres`%, <b>%g_smallres%</b>, All
		stringreplace, txt, txt, `%path`%, <b>%p%</b>, All
		;stringreplace, txt, txt, `%verysmallres`%, <b>%g_verysmallres%</b>, Al ;g_verysmallres not 'defined'
		txt := StrReplace(txt, "\", "\\")
		txt := StrReplace(txt, "%autodmp%", autodmp)
		
		txt := StrReplace(txt, "{f}", "<img width='20px'; height='20px'; src='fix.svg';></img>")
		txt := StrReplace(txt, "{nfo}", "<img width='20px'; height='20px'; src='nfo.svg';></img>")
		txt := StrReplace(txt, "{i}", "<img width='20px'; height='20px'; src='star.svg';></img>")
		txt := StrReplace(txt, "{bad}", "<img width='20px'; height='20px'; src='bad.svg';></img>")		
		txt := RegExReplace(txt, "s)==\[([^=]*)\]==", "<div class='center'><b>$1</b></div><br><br>" )	
		txt := RegExReplace(txt, "s)=\[([^=]*)\]=", "<b>$1</b>" )	
		txt := RegExReplace(txt, "s)-\[([^-]*)\]-", "<i>$1</i>" )	
		txt := RegExReplace(txt, "s)\[([^]\s]*)\s([^]]*)\]", "<a id='$1' href='javascript:dummy()'>$2</a>" )	
		fix =
		(LTRIM
		<dd><div class='fix-master'>
			<div class='fix-icon'></div>
			<div class='fix-text'>$1</div>
		</div></dd>
		)
		imp =
		(LTRIM
		<dd><div class='fix-master'>
			<div class='improve-icon'></div>
			<div class='fix-text'>$1</div>
		</div></dd>
		)
		nfo =
		(LTRIM
		<dd><div class='fix-master'>
			<div class='nfo-icon'></div>
			<div class='fix-text'>$1</div>
		</div></dd>
		)
		bad =
		(LTRIM
		<dd><div class='fix-master'>
			<div class='bad-icon'></div>
			<div class='fix-text'>$1</div>
		</div></dd>
		)
		ce =
		(LTRIM
		<dd><div class='fix-master'>
			<div class='ce-icon'></div>
			<div class='fix-text'>$1</div>
		</div></dd>
		)
		txt :=  RegExReplace(txt, "s){f\s([^}]*)}", StrReplace(fix, "`n", "") )	
		txt :=  RegExReplace(txt, "s){i\s([^}]*)}", StrReplace(imp, "`n", "") )	
		txt :=  RegExReplace(txt, "s){nfo\s([^}]*)}", StrReplace(nfo, "`n", "") )	
		txt :=  RegExReplace(txt, "s){bad\s([^}]*)}", StrReplace(bad, "`n", "") )	
		txt :=  RegExReplace(txt, "s){ce\s([^}]*)}", StrReplace(ce, "`n", "") )
		fix =
		(LTRIM
		<div class='fix-master'>
			<div class='fix-icon'></div>
			<div class='fix-text'>$1</div>
		</div>
		)
		imp =
		(LTRIM
		<div class='fix-master'>
			<div class='improve-icon'></div>
			<div class='fix-text'>$1</div>
		</div>
		)
		nfo =
		(LTRIM
		<div class='fix-master'>
			<div class='nfo-icon'></div>
			<div class='fix-text'>$1</div>
		</div>
		)		
		txt :=  RegExReplace(txt, "s){F\s([^}]*)}", StrReplace(fix, "`n", "") )	
		txt :=  RegExReplace(txt, "s){I\s([^}]*)}", StrReplace(imp, "`n", "") )	
		txt :=  RegExReplace(txt, "s){NFO\s([^}]*)}", StrReplace(nfo, "`n", "") )		
		txt :=  RegExReplace(txt, "s){ce\s([^}]*)}", StrReplace(ce, "`n", "") )	
		txt :=  RegExReplace(txt, "s){h1\s([^}]*)}", "<div class='features'>$1</div>" )	
		txt :=  RegExReplace(txt, "s){b\s([^}]*)}", "<div class='box'>$1</div>" )					
		return txt
	}
	GetLinks(h)
	{
		l := {"Donate"   : "https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=E68RE3UWG2ZEU&lc=US&"
	    . "item_name=Peixoto&bn=PP%2dDonationsBF%3abtn_donate_LG%2egif%3aNonHosted"
		, "Peixoto"      : "http://www.vogons.org/viewtopic.php?f=24&t=53121"
		, "cheat"        : "https://www.cheatengine.org/"
		, "patreon_home" : "https://www.patreon.com/user?u=44312848"}
		for k, v in h
		{
			if (Trim(v) = "link")
			{
				s := strsplit(h[k+1], "->")
				l[s[1]] := s[2]
			}
		}
		return l
	}
	ShowDocument(doc, cfg="")
	{
        this.games_div.disable()
		CoordMode, Mouse, screen
		MouseGetPos, x, y
		;Progress, b x%x% y%y% h19 ZH10
		
		for k, v in this.games_div_items
		v.disable()
		
		;Progress, 50
		this.__path__    := A_mydocuments "\games\" new ini(cfg).read("path") "\"
		this.currnt_tool := ""
		this.docs_items  := {} 
		help             := fileopen(doc, "r").read()	

		for k, v in {"DX9SSAA" : "DX9", "DX8HDSA" : "DX8", "glSSAA" : "gl", "DX11FSR" : "DX11", "DX12FSR" : "DX12"
					,"DX11CE"  : "DX11", "DX9CE"  : "DX9"} 
		{
			if (new ini(cfg).read("Help") = k)	
			{		
				help  := "::Title::user::{h1 Fixes and improvements}`n" 
				if (instr(k, "SSAA") && (instr(k, "9") || instr(k, "8") || instr(k, "gl")))
				{
					help .= "{i [gototab_graphics_HD Forced resolution], while not absolutely necessary"
					. "  on this game, allows a<gototab_graphics_SSAA -- super sampling anti aliasing>a}"
				}
				if (instr(k, "HDSA") && (instr(k, "9") || instr(k, "8") || instr(k, "gl")))
				{
					help .= "{i [gototab_graphics_HD Forced resolution] allows hight resolution " 
					. "without shrinking the HUD\menus and [gototab_...graphics_SSAA super "
					. " sampling anti aliasing]}"  
				}
				if (instr(k, "CE"))
				{
					help .= "{ce [show_ce_div Cheats]}" 
				}
				if (instr(k, "FSR"))
				{
					help .= "{i [gototab_graphics_HD FidelityFx super resolution] upscaling}" 
				}
				help  .= "%" v "%"								
			}
		}	
		
		for k, v in ["ddraw", "directdraw", "gl", "DX8", "DX9", "DX10","DX11", "DX12", "CPU", "Sound", "Input"]  
		{
			if instr(help, "%" v "%")
			{
				fileread, DX, ..\help\%v%.txt 
				stringreplace, DX, DX,::Title::user,,
				stringreplace, help, help, `%%v%`%, %DX%			
			}
		}	
		
		if (g_.wip)
			help        := StrReplace(StrReplace(help, "wip<", ""), ">wip", "")
		else
		    help        := RegExReplace(help, "wip<.*>wip", "")		
					
		help            := strsplit(help, "::")	
		this.links	    := this.GetLinks(help)	
				
		;Progress, 100
		parent := this.docs_div		
		c      := new ini(cfg)	
		this.cfg_file := cfg		
		if c.read("a", "Textswap") 
		{
			c.edit("a", "false", "Textswap")
			c.save()
		} c=
		for k, v in help
		{
			sec := Trim(v) 
			if (sec = "Title")
			{	
				if (help[k+1] = "user")
				help[k+1] := strsplit( strsplit(cfg, g_.profiles "\")[2], ".ini")[1]	
				
				div       := this.docs_items["doc_title"] := new DocDiv(parent , "doc_title", "div").init()
				div.Scroll()
				div.title                                 := new DocSectionHead(div , "doc_title_header", "div").init()				
				div.title.innerHTML                       := this.ProcessText(help[k+1]) 
				div.title["style.marginBottom"]           := "2px"
				
				if cfg
				{
					play           := this.docs_items["play_bttn_div"] := new HTMLElement(div, "play_bttn_div", "div")
					play["style.display"]                              := "inline"
					play.play      := new PlayButton(play, "play_bttn", "BUTTON").init(cfg)
					play.shortcut  := new ShortcutButton(play, "shortcut_bttn", "BUTTON")._init(cfg)
					wiki           := new ini(cfg).read("wiki") 
					if (wiki)
					play.wiki      := new WikiButton(play, "wiki_bttn", "div")._init(cfg, wiki)	

					cheat := StrReplace(cfg, "/", "\")
					cheat := StrReplace(cheat, "\\", "\")
					cheat := StrReplace(cheat, ".ini", ".ct")
					split := StrSplit(cheat, "\")
					cheat := "..\cheats\" split[split.length()]
					for kk, vv in StrSplit("OpenGl D3D7 D3D8 D3D9 D3D10 D3D11 D3D12 GOG DirectDraw DX6 Software Hardware", " ")
					cheat := StrReplace(cheat, " - " vv, "")	
					if fileexist(cheat)					{
						
						target     := new ini(cfg).read("target") 
						SplitPath, target, name
						
						play.cheat := new CheatButton(play, "cheat_bttn_div", "button")._init(cheat, name)
						play.tip   := new CheatTip(div, "cheat_tip_div", "div")._init(cheat, name)												
					}
                    ver := new ini(cfg).read("ver") 
                    if (ver)
                    {
                        ver_warning           := this.docs_items["version_warning"] := new HTMLElement(div, "version_warning", "div")
                        ver_warning.className := "warning"
                        ver_warning.innerHTML := "<h3>Version warning</h3>This warning means that I don't have this game installed anymore therefore" 
                        . " I can't test it when I make changes on parts of the program that can affect and I don't offer support for it"
                        . "<br><br>This game was last tested on version "
                        . "<a style='color:white' id='old_version_redirect' href='javascript:dummy()'> " . ver . "</a>" 
                    }
				}
				div.contents             := new DocSectionContent(div , "doc_title_contents", "div").init()
				div.contents.innerHTML   := this.ProcessText(help[k+2])					
				
				if fileexist("..\main.ini")
				{
					game := StrSplit(StrSplit(cfg, g_.profiles "\")[2], ".ini")[1]													
					div.contents.innerHTML := this.ProcessText(help[k+2] "||n[current_game_ini Open .ini file]|n" new ini("..\main.ini").read(game, "devflags"))		
				}
			} 
			else if (sec = "Section")
			{
				if (help[k+1] = "Settings")
				{
					div                         := this.docs_items["doc_settings"] := new DocDiv(parent , "doc_settings", "div").init()
					div.title                   := new DocSectionHead(div , "doc_settings_header", "div").init()
					div.title["style.fontSize"] := "20px"
					div.title.textContent       := "Settings"
					div.contents                := new DocSectionContent(div, "doc_settings_contents", "div").init()					
					parent                      := div.contents
					continue
				}
				else if (help[k+1] = "endofsettings")
				{
					parent["HDPI"] := new BOOLInput(parent, "HDPI", "input").init(cfg, parent, "HDPI", "Hight DPI aware<br>", " ")
					parent["CompatLayer_label"] := new CompatLayer(parent, "CompatLayer_label", "label")._init(cfg, parent, "CompatLayer", "Compatibility Settings", " "
					,"Don't Change, None, DWM8And16BitMitigation, Layer_Win95VersionLie, Win95, Win98, FaultTolerantHeap, Win2000, Win2000Sp2, Win2000Sp3, WinXP, WinXPSp2, WinXPSp3, VistaSp2")
										
					continue					
				}
				div := this.docs_items["doc_section_" help[k+1]] := new DocDiv(parent , "doc_section_" help[k+1], "div").init()
				div.title                                        := new DocSectionHead(div , "doc_section_" help[k+1] "_header", "div").init()
				div.title["style.fontSize"]                      := "20px"
				div.title.textContent                            := this.ProcessText(help[k+1])
				div.contents                                     := new DocSectionContent(div, "doc_section_" help[k+1] "_contents", "div").init()
				div.contents.innerHTML                           := this.ProcessText(help[k+2])								
			}	
			else if (sec = "%dsr%")	
			{
				dsr=When forced resolution is enabled, the program chooses the highest resolution available instead of the desktop's
				item              := new BOOLInput(parent, "DSR", "input").init(cfg, parent, "DSR", dsr, this.ProcessText(help[k+1]))				
				parent[help[k+1]] := item
			}
			else if (sec = "BOOL")	
			{
				item              := new BOOLInput(parent, help[k+1], "input").init(cfg, parent, help[k+1], this.ProcessText(help[k+2]), this.ProcessText(help[k+3]))				
				parent[help[k+1]] := item
				if (help[k+1] = "4k")
				{
					item.disable()
					this.__Exec("document.getElementById(""" item.js_element_id """).checked = true;")
				}
			}
			else if (sec = "TEXTID")	
			{
				item                    := new HidenBOOLInput(parent, help[k+1], "input").init(cfg, parent, help[k+1], this.ProcessText(help[k+2]), this.ProcessText(help[k+3]))	
				item.checked            := 1
				item.label.innerHTML    := "&#9658;" this.ProcessText(help[k+2])	
				item.label.style().position := "relative"				
				item.style().visibility     := "hidden"	
				item.label.style().left     := "-18px"					
				parent[help[k+1]]           := item					
			}
			else if (sec = "HOTKEY")	
			{
				item                    := new HOTKEYInput(parent, help[k+1], "BUTTON").init(cfg, parent, help[k+1], this.ProcessText(help[k+2]), this.ProcessText(help[k+3]))	
				parent[help[k+1]]       := item				
			}
			else if (sec = "FLOAT")	
			{
				item              := new FloatInput(parent, help[k+1], "input").init(cfg, parent, help[k+1], this.ProcessText(help[k+2]), this.ProcessText(help[k+3]), this.ProcessText(help[k+4]))				
				parent[help[k+1]] := item
			}
			else if (sec = "_RLMT_")	
			{
				item              := new ResLimit(parent, help[k+1], "input").init(cfg, parent, help[k+1], this.ProcessText(help[k+2]), this.ProcessText(help[k+3]), this.ProcessText(help[k+4])).__init__()				
				parent[help[k+1]] := item
			}
			else if (sec = "xBRzTxlSz")	
			{
				item              := new xBRzTxlSize(parent, help[k+1], "input").init(cfg, parent, help[k+1], this.ProcessText(help[k+2]), this.ProcessText(help[k+3]), this.ProcessText(help[k+4])).__init__()				
				parent[help[k+1]] := item
			}
			else if (sec = "RADIOHEAD")	
			{
				item              := new RadioHead(parent, help[k+1], "div").init(parent, help[k+1], this.ProcessText(help[k+2]), this.ProcessText(help[k+3]))				
				parent[help[k+1]] := item
				if (help[k+1] = "Textswap.path")
					item["style.left"] := "-1px"
			}
			else if (sec = "RADIO")	
			{
				item              := new RadioInput(this.child(help[k+2] "_buttons"), StrReplace(help[k+1], "\", "_"), "input").init(cfg, this.child(help[k+2] "_buttons")
				, help[k+1], help[k+2] "_buttons", this.ProcessText(help[k+3]), this.ProcessText(help[k+4]))					
				this.docs_items[help[k+1]] := item
			}
			else if (sec = "TEXT")	
			{
				id                  := parent.js_element_id "_TEXT"
				this.docs_items[id] := new HTMLElement(parent, id, "div")
				this.docs_items[id].innerHTML := this.ProcessText(help[k+1])
			}
			else if (sec = "HIDDEN")	
			{
				item              := new HiddenDiv(parent, help[k+1], "a").init(parent, help[k+1], this.ProcessText(help[k+2]), this.ProcessText(help[k+3]))				
				parent[help[k+1]] := item
			}
			else if (sec = "%_Textswap_%")	
			{
				parent["%_Textswap_%"] := new TexSwap(parent, cfg)
			}
			else if (sec = "%_Textswap_Compiler%")	
			{
				parent["%_Textswap_Compiler_%"] := new Compiler(parent, "_Textswap_Compiler_", "button").init(cfg)
				parent["_scaler_"]              := new Scaler(parent, "_scaler_", "button").init(cfg)
			}
			else if (sec = "%_PixelSwap_%")	
			{
				parent["%_PixelSwap_%"] := new PxSwap(parent, cfg)
			}
			else if (sec = "%DinputEmu%")	
			{
				parent["%DinputEmu%"] := new DinputEmu(parent, "DinputEmu_master_div", "div").init(cfg)
				parent["%Macros%"]    := new Macros(this.docs_items["Input_div"], "Macros_master_div", "div").init(cfg)
			}
			else if (sec = "__mods__")	
			{
				parent["__mods__"] := new ModsManager(parent, "mods_master_div", "div").init(cfg)				
			}
			else if (sec = "parent")	
			{
				parent := this.child(help[k+1])
			}
			else if (sec = "tab")
			{
				if (! this.docs_items["doc_settings"] )
				{
					div                         := this.docs_items["doc_settings"] := new DocDiv(parent , "doc_settings", "div").init()
					div.title                   := new DocSectionHead(div , "doc_settings_header", "div").init()
					div.title["style.fontSize"] := "20px"
					div.title.textContent       := "Settings"
					parent                      := div						
				}
				
				d := this.docs_items["doc_settings_tabs_buttons_div"] := new DocSectionHead(parent, "doc_settings_tabs_buttons_div", "div").init()
				d["style.backgroundColor"] := "RoyalBlue"
				d["style.border"]          := "none"
				d["style.marginRight"]     := "20px"
				d["style.paddingTop"]      := "0px"
				d["style.fontSize"]        := "12px"
				
				
				for k, v in strsplit(help[k+1], "|")
				{
					d := this.docs_items["doc_settings_" v "_tab_button"] := new DocTabsButton(this.docs_items["doc_settings_tabs_buttons_div"]
					, "doc_settings_" v "_tab_button", "BUTTON").init(v)
					d["style.backgroundColor"] := g_.color_d
					d["style.marginTop"]       := "0px"
					d["style.paddingTop"]      := "0px"
					d["style.height"]          := "40px"	
					d["style.width"]           := "140px"
					d["style.textAlign"]       := "center"
					
					div := this.docs_items[v "_div"] := new DocSectionContent(parent , v "_div", "div").Init()
					div["style.marginRight"] := "10%"
				}
				this.docs_items["doc_settings_" "Graphics..." "_tab_button"].clicked()
				this.docs_items["doc_settings_" "Graphics" "_tab_button"].clicked()
			}
			else if (sec = "GraphicsTab")	
			{
				parent := this.docs_items["Graphics_div"]
			}
			else if (sec = "Graphics...Tab")	
			{
				parent := this.docs_items["Graphics..._div"]
			}
			else if (sec = "...GraphicsTab")	
			{
				parent := this.docs_items["...Graphics_div"]
			}
			else if (sec = "SoundTab")	
			{
				parent := this.docs_items["Sound_div"]
			}
			else if (sec = "InputTab")	
			{
				parent := this.docs_items["Input_div"]
			}
			else if (sec = "File SystemTab")	
			{
				parent := this.docs_items["File System_div"]
			}
			else if (sec = "CPUTab")	
			{
				parent := this.docs_items["CPU_div"]
			}
		}
		div["style.marginBottom"] := "0px"
		
		for, k, v in this.children
			v.objct().UpdateState()
		
        this.games_div.enable()
		for k, v in this.games_div_items
			v.enable()
		
		;Progress, off
		this.Resized(this.w, this.h)
		this.create_new["style.top"] := this.h-15  "px"
	}
	Resized(w, h)
	{	
		FileAppend, % w " " h "`n", *
		this.w := w
		this.h := h
		this.__Exec("document.body.style.width = " w ";")	
		this.__Exec("document.body.style.height = " h ";")			
		this.games_div.resized(w, h-20)
		this.docs_div.resized(w, h-20)			
		this.items_div["style.height"] := h-55 "px"	
		for k, v in this.docs_items
		v.div["style.width"]           := w-240 "px"
		;this.create_new["style.top"]   := h-35  "px"
		this.Child("cheat_tip_div").Resized(w)
	}		
}

main()
main()
{
	arg    := GetCommandLineValueB("-g")
	wip    := Instr(dllcall("GetCommandLine", str), "-wip"  ) ? "-wip"   : "" 
	gl     := Instr(dllcall("GetCommandLine", str), "-gl"   ) ? "-gl"    : "" 
	dx7    := Instr(dllcall("GetCommandLine", str), "-dx7-" ) ? "-dx7-"  : "" 
	dx8    := Instr(dllcall("GetCommandLine", str), "-dx8"  ) ? "-dx8"   : "" 
	dx9    := Instr(dllcall("GetCommandLine", str), "-dx9"  ) ? "-dx9"   : "" 
	dx10   := Instr(dllcall("GetCommandLine", str), "-dx10+") ? "-dx10+" : "" 
	mci    := Instr(dllcall("GetCommandLine", str), "-mci"  ) ? "-mci"   : "" 
	mhks   := Instr(dllcall("GetCommandLine", str), "-mhks" ) ? "-mhks"  : "" 
	whks   := Instr(dllcall("GetCommandLine", str), "-whks" ) ? "-whks"  : "" 
	fldrs  := Instr(dllcall("GetCommandLine", str), "-fldrs") ? "-fldrs" : "" 
	links  := Instr(dllcall("GetCommandLine", str), "-fldrs") ? "-links" : "" 
	dsnd   := Instr(dllcall("GetCommandLine", str), "-dsnd" ) ? "-dsnd"  : "" 
	lst    := Instr(dllcall("GetCommandLine", str), "-lst"  ) ? "-lst"   : "" 
	g_.wip := wip
	;if not A_isadmin
	;{
		;params= "HelpQt.ahk" "--disable-web-security" "%arg%" %wip% %gl% %dx7% %dx8% %dx9% %dx10% %mci% %mhks% %whks% %fldrs% %dsnd% %lst% 
		;DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, """" A_ScriptDir "\HelpQt.exe"""
		                              ;, str, params) 
		;exitapp							  
	;}
	if(wip) 
	dllcall("AllocConsole")
	FileCreateDir, %A_myDocuments%\Games\Peixoto
	fileOpen(s  := A_myDocuments "\Games\Peixoto\Peixoto.ini", "rw")
	g_.isos_dir := StrReplace(new ini(s).read("ISOS"), "%docs%", A_mydocuments)
	GetRes()	
	name  := wip ? "wips" : "Peixoto's patch"
	;new HTMLWindow("MSEdge/help.js")	
	;m     := new Main(name)._init(arg) 
	m     := new Main("MSEdge/help.js", arg, name)
	
	exitapp
}

GetRes()
{
	max_w   := 0 
	max_h   := 0
	reslist := ""
	VarSetCapacity(dm,156,0)
	NumPut(156,dm,36,"UShort")
	Loop
	{
		If !DllCall("EnumDisplaySettingsA", UInt, 0, UInt, A_Index-1, UInt, &dm)
		break
		w   := NumGet(dm,108,"UInt"), h := NumGet(dm, 112, "UInt")
		bpp := NumGet(dm,104,"UInt")
		res := w "x" h
		instr(reslist, res) ?: reslist .= res . A_space
		if ( ( (w>max_w) or (h>max_h) ) and round(w/h*100) = 133 )
		{
			max_w := w
			max_h := h
		}
	}
	native_res := dllcall("GetSystemMetrics", uint,0) "x" dllcall("GetSystemMetrics", uint, 1)
	if ! instr(reslist, native_res)
	{
		VarSetCapacity(lRect, 16)
		hDesktop := dllcall("User32.dll\GetDesktopWindow", uint)
		dllcall("GetWindowRect", uint, hDesktop, uint, &lRect)
		native_res := numget(&lRect+8, "uint") "x" numget(&lRect+12, "uint")
		dllcall("ReleaseDC", uint, 0, uint, hDesktop)
	}
	nat               := strsplit(native_res, "x")
	global g_smallres := round( 540 * nat[1]/nat[2] ) "x" 540
	if (native_res="1366x768")
	g_smallres        := g_smallres 
}

Runscript(script)
{	
	path       := FileExist(path := "..\AutoHotkey.dll") ? path : A_mydocuments "\AutoHotkey\dlls\AutoHotkey.dll"
	ahktextdll := dllcall("GetProcAddress", uint, dllcall("LoadLibraryW", str, path), astr, "ahktextdll")
	hThread    := dllcall(ahktextdll, Str, fileopen("lib.txt", "r").read() "`n" script, Str, "", Str, "", "Cdecl UPTR")
	dllcall("WaitForSingleObject", "ptr", hThread, "uint", 0xffffffff)
}

SetDeviceGammaRamp(brightness, ramp=1.0)
{
	(brightness > 256) ? brightness := 256
	(brightness < 0) ? brightness := 0
	VarSetCapacity(gr, 512*3)
	x := 1/ramp
	Loop, 256
	{
		(nValue:=(brightness+128)*(A_Index-1))>65535 ? nValue:=65535
		nValue := (nValue**x/65535**x)*65535
		NumPut(nValue, gr,      2*(A_Index-1), "Ushort")
		NumPut(nValue, gr,  512+2*(A_Index-1), "Ushort")
		NumPut(nValue, gr, 1024+2*(A_Index-1), "Ushort")
	}
	hDC := DllCall("GetDC", "Uint", A_scripthwnd)
	DllCall("SetDeviceGammaRamp", "Uint", hDC, "Uint", &gr)
	DllCall("ReleaseDC", "Uint", 0, "Uint", hDC)
}

Class VirtualDisk
{	
	Mount(path, drv)
	{
		dllcall("Kernel32.dll\DeleteVolumeMountPointW", str, drv ":\")
		vol := this.EnumVolumes()
		dllcall("peixoto.dll\MountISO", str, path)
		for k, v in this.EnumVolumes()
		{
			if ! vol[k]
			{
				FileAppend, % "Mounted " k "`n", *
				if (dllcall("Kernel32.dll\SetVolumeMountPointW", str, drv ":\", str, k) = 0) 
				return A_Lasterror
				return k
			}
		}	
		return "pocoto"		
	}	
	EnumVolumes()
	{		
		VarSetCapacity(VolName, 1024)	
		Volumes  := []
		hFVol    := dllcall("Kernel32.dll\FindFirstVolumeW", str, VolName, uint, 1024)
		if (hFVol = -1)
		{
			FileAppend, % "FindFirstVolumeW Failed`n", *
		} 		
		Volumes[VolName] := True
		
		success := 1
		while (success)
		{
			success          := dllcall("Kernel32.dll\FindNextVolumeW", ptr, hFVol, str, VolName, uint, 1024)
			Volumes[VolName] := True
		}
		
		for k, v in Volumes
		{
			dllcall("GetVolumePathNameW", str, v, str, VolName, uint, 1024)
			FileAppend, % v " " k " " VolName "`n", *
		}
		return Volumes
	}	
}