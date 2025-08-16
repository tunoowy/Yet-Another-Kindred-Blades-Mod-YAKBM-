class KbrdMenuButton extends HTMLElement
{
	Init(name, subitems, parent, targetid)
	{
		this.ahk.subitems             := subitems
		this.ahk.parent_id            := parent
		this.ahk.targetid             := targetid
		this["style.height"]          := "18px"
		this["style.width"]           := "200px"
		this["style.position"]        := "relative"
		this.innerHTML                := name
		this["style.border"]          := "none"
		this["style.outline"]         := "none"			
		this["style.backgroundColor"] := g_.color_d
		this["style.textAlign"]       := "left"
		this["style.marginBottom"]    := "2px"
		this["style.display"]         := "block"
		this["style.zIndex"]          := 1
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
		parent      := this.body().child(this.ahk.parent_id)
		parent.lvl2 := ""
		parent.lvl2 := new KbrdMenulvl2(parent, "level2", "div").init(parent, this.ahk.subitems, this.ahk.targetid)
	}
}

class KbrdMenuLvl2Button extends HTMLElement
{
	Init(targetid)
	{
		this.ahk.subitems             := subitems
		this.ahk.parent_id            := parent
		this.ahk.targetid             := targetid
		this["style.height"]          := "18px"
		this["style.width"]           := "200px"
		this["style.position"]        := "relative"
		this.innerHTML                := name
		this["style.border"]          := "none"
		this["style.outline"]         := "none"			
		this["style.backgroundColor"] := g_.color_d
		this["style.textAlign"]       := "left"
		this["style.marginBottom"]    := "2px"
		this["style.height"]          := "18px"
		this["style.left"]            := "5px"
		this["style.top"]             := "-50px"
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
		this.body().child(this.ahk.targetid).Update(this.js_element_id)
	}
}

class KbrdMenulvl2 extends HTMLElement
{
	Init(byref parent, byref subitems, byref targetid)
	{
		this.ahk.parent_id     := parent.js_element_id
		this["style.display"]  := "block"		
		this["style.position"] := "absolute"
		this["style.left"]     := "200px"
		this["style.top"]      := "-" parent["style.height"] 
		this["style.zIndex"]   := 1			

		for k, v in subitems
		{
			this[v] := new KbrdMenuLvl2Button(this, v, "BUTTON").Init(targetid)
			this[v].innerHTML := v
		}
		return this
	}
}

class KbrdMenuDissmissButton extends KbrdMenuButton
{
	Clicked()
	{
		this.body().Child(this.ahk.targetid).DissmissKbrdMenu()
	}
}

class KbrdMenu extends HTMLElement
{
	Init(byref parent)
	{
		this.ahk.parent_id     := parent.js_element_id
		this["style.display"]  := "block"		
		this["style.position"] := "absolute"
		this["style.left"]     := parent["style.width"] 		 	
		this["style.zIndex"]   := 1	
		
		for k, v in {"Lettters":strsplit("ABCDEFGHIJKLMNOPQRSTUVWXYZ"),"Numbers":strsplit("0123456789")
			        ,"Numpad numbers":strsplit("Numpad0,Numpad1,Numpad2,Numpad3,Numpad4,Numpad5,Numpad6,Numpad7,Numpad8,Numpad9,NumpadMult,NumpadDiv,NumpadAdd,NumpadSub,NumpadEnter", ",")
		            ,"Numpad":strsplit("Up,Down,Left,Right,Home,End,Ins,Del,PgUp,PgDn", ","),"Function keys":strsplit("F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,F11,F12", ",")
					,"Symbols":strsplit("[,],/,\\,-,+,<,>,~,:,""", ","),"Other":strsplit("CapsLock,Space,Tab,Enter,Esc,Backspace,Ctrl,Alt,Shift", ",")
					,"Mouse":strsplit("LButton,RButton,MButton,WheelDown,WheelUp", ",")}
		{
			this[k] := new KbrdMenuButton(this, k "_menu_item", "Button").init(k, v, this.js_element_id, parent.js_element_id)			
		}
		this["Dissmiss"] := new KbrdMenuDissmissButton(this, "dissmiss_keyboard_menu", "Button").init("Dissmiss", "", this.js_element_id, parent.js_element_id)
		return this
	}	
}

Class ExpandDiv extends HTMLElement 
{
	init(parent)
	{
		this["style.top"]             := "-20px"
		this["style.backgroundColor"] := "#f9edbe"
		this["style.zIndex"]          := 1		
		return this
	}
	out()
	{
		this["style.display"] := "none"
	}
}

Class HiddenDiv extends HTMLElement 
{
	Init(parent, id, link, expand)
	{
		this["style.position"]    := "relative"
		this["style.marginLeft"]  := "5px"
		this.innerHTML            := "more &#8690<br>" ;link 
		this.href                 := "javascript:function(e){QWebChannelCallback.Clicked(document.activeElement.id); e.stopPropagation();};"
		
		this.div                  := new ExpandDiv(parent, id "_text", "div").init(this)
		this.div.innerHTML        := expand
		
		this.div["style.display"] := "none"
		return this
	}
	Clicked()
	{
		;msgbox
	}
	over()
	{
		this.div["style.display"] := "block"
	}	
}		

Class DropDownInput extends HTMLElement
{
	Init(parentid, options)
	{
		ObjInsert(this, "parentid", parentid)
		for k, v in strsplit(options, ", ")
		{  
			this[v]                := new HTMLElement(this, this.js_element_id "_" v, "option")
			this[v].value          := v
			this[v].innerHTML      := v
			this["style.position"] := "relative"
			this["style.left"]     := "5px"
			this.body().__Exec( "document.getElementById(""" this.js_element_id """).onchange=function(){SliderValueChanged()};" ) 
		}
		return this
	}
	ValueChanged(value)
	{
		this.body().Child(this.parentid).ValueChanged(Value)
	}
}

Class DropDown extends HTMLElement
{
	Init(byref cfg, parent, id, label_text, details, options)
	{
		this["style.position"]             := "relative"
		this["style.left"]                 := "3px"
		this.innerHTML                     := "&#9658;" label_text 
		this.for                           := ID
		this.input                         := new DropDownInput(parent, id, "select").init(id "_label", options)
		this.details_div                   := new HTMLElement(parent, id "_details", "div")
		this.details_div.innerHTML         := details 
		this.details_div["style.position"] := "relative"
		this.details_div["style.left"]     := "20px"
		
		ObjInsert(this, "sec", strsplit(id, ".")[1])
		ObjInsert(this, "key", strsplit(id, ".")[2])
		if (!this.key)
		{
			this.key := this.sec
			this.sec := ""
		}
		ObjInsert(this, "cfg", cfg)		
		this.ahk.initial    := new ini(cfg).read(this.key, this.sec, "None")		
		this.input.value    := this.ahk.initial 						
		
		return this
	}
	ValueChanged(value)
	{		
		cfg:= new ini(this.cfg)
		cfg.edit(this.key, value, this.sec)
		cfg.save()
	}
}

Class CompatLayer extends DropDown
{
	_init(byref cfg, parent, id, label_text, details, options)
	{
		this.init(cfg, parent, id, label_text, details, options)
		if (this.ahk.initial = "")
			this.input.value := "None"
		else if (this.ahk.initial = "#")
			this.input.value := "Don't Change"
		return this
	}
	ValueChanged(value)
	{
		if (value = "None")
			value := ""
		else if (value = "Don't Change")
			value := "#"
		cfg:= new ini(this.cfg)
		cfg.edit(this.key, value, this.sec)
		cfg.save()
	}
}

class InputDetails extends HTMLElement
{
	Disable()
	{
		;fileopen("*", "w").WriteLine("disable sons of " this.js_element_id)	
		this.ahk.disabled := True
		this.body().EnumChildren(this.js_element_id)
	}
	Enable()
	{
		;fileopen("*", "w").WriteLine("enable sons of " this.js_element_id)
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

class RadioHead extends HTMLElement
{
	init(parent, id, label_text, details)
	{
		this["style.display"]               := "block"
		this["style.position"]              := "relative"
		this["style.left"]                  := "2px"
		this["style.marginBottom"]          := "10px"
		this.innerHTML                      := "&#9658;" label_text "<br>"
		
		this.butttond_div                   := new HTMLElement(this, id "_buttons", "div")
		this.butttond_div["style.position"] := "relative"
		this.butttond_div["style.left"]     := "13px"	
		
		this.details_div                    := new InputDetails(this, id "_details", "div")
		this.details_div.innerHTML          := details
		this.details_div["style.position"]  := "relative"
		this.details_div["style.left"]      := "13px"		
		return this
	}
	Disable()
	{
		this.body().child(this.js_element_id "=False").Disable()			
	}
	Enable()
	{
		this.body().child(this.js_element_id "=False").Enable()		
	}
	EnumChildrenCallback(child)
	{
		;child.disable()
		this.body().child(child).disable()		
	}
}

class RadioInput extends HTMLElement
{
	init(byref cfg, parent, id, name, label_text, details)
	{
		;fileopen("*", "w").writeline("Radio " id)
		this["style.position"]             := "relative"	
		this["style.left"]                 := "10px"		
		this.type                          := "radio"
		this.name                          := name		
		
		this.label                         := new HTMLElement(parent, id "_label", "label")
		;this.label.for                       := parent ;crash 
		this.label.innerHTML               := label_text
		this.label["style.position"]       := "relative"	
		this.label["style.left"]           := "10px"	
		this.details_div                   := new InputDetails(parent, id "_details", "div")
		this.details_div.innerHTML         := details 
		this.details_div["style.position"] := "relative"
		this.details_div["style.left"]     := "31px"
		;fileopen("*", "w").writeline(id)
		
		ObjInsert(this, "sec", strsplit(id, ".")[1])
		ObjInsert(this, "key", strsplit(id, ".")[2])
		if (!this.key)
		{
			this.key := this.sec
			this.sec := ""
		}
		this.key   := strsplit(this.key, "=")[1]
		ObjInsert(this, "val", StrReplace(strsplit(id, "=")[2], "0", ""))
		ObjInsert(this, "cfg", cfg)				
		if ( StrReplace(new ini(cfg).read(this.key, this.sec, "0"), "\", "/") = this.val)
		{
			this.checked := "True"	
			if (this.val = "false")
				this.body().child(this.key "_details").disable()
		}						
		return this
	}
	Disable()
	{
		js := "document.getElementById(""" this.js_element_id """).checked = true;"
		this.body().__Exec(js)
		js := "document.getElementById(""" this.js_element_id """).disabled = true;"
		this.body().__Exec(js)	
		this.StateChanged("True")	
		this.body().EnumChildren(this.key)		
	}
	Enable()
	{
		js := "document.getElementById(""" this.js_element_id """).disabled = false;"
		this.body().__Exec(js)	
		this.body().__Eval(this.checked, this, "StateChanged")
	}
	Clicked()
	{
		this.body().__Eval(this.checked, this, "StateChanged")
	}
	UpdateState()
	{
		this.body().__Eval(this.checked, this, "StateChanged")
	}
	EnumChildrenCallback(child)
	{
		child.disable()
	}
	StateChanged(state)
	{
		if (state="True")
		{
			if (this.val = "false")
			{
				this.body().child(this.key "_details").disable()
				this.body().child(this.key "_buttons").disable()
			}
			else 
			{
				this.body().child(this.key "_details").enable()
				this.body().child(this.key "_buttons").enable()
			}
			cfg := new ini(this.cfg)
			cfg.edit(this.key, StrReplace(this.val, "/", "\"), this.sec)
			cfg.save()
		}		
	}	
}

Class xBRzTxlSize extends FloatInput
{
	ValueChanged(value)
	{
		this.face.innerHTML := ["Disabled", "Auto", "Auto - Large pixels", "x2"][value+1]				
		cfg                 := new ini(this.cfg)
		cfg.edit(this.key, value, this.sec)
		cfg.save()
	}
	__Init__()
	{
		v          := new ini(this.cfg).read(this.key, this.sec, 0)
		if (v="")
			v      := 0
		this.value := v	
		this.ValueChanged(v)
		return this
	}
}

Class ResLimit extends FloatInput
{
	ValueChanged(value)
	{
		this.face.innerHTML := ["No limit", "640x480", "800x600", "1024x768", "960x540", "1280x720", "1366x768", "1920x1080"][value+1]		
		this.face.innerHTML := ["No limit", "640x480", "800x600", "1024x768", "960x540", "1280x720", "1366x768", "1600x900"
		                       ,"1920x1080", "2560x1440", "3840x2160"][value+1]	
		value               := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11][value+1]	
		cfg                 := new ini(this.cfg)
		cfg.edit(this.key, value, this.sec)
		cfg.save()
	}
	__Init__()
	{
		v          := new ini(this.cfg).read(this.key, this.sec, 0)
		if (v="")
			v      := 0
		this.value := v	
		this.ValueChanged(v)
		return this
	}
}
Class FloatInput extends HTMLElement
{
	Init(byref cfg, parent, id, label_text, rng, details)
	{
		this.label                     := new HTMLElement(parent, id "_label", "label")
		;this.label.for                 := parent ;crash
		this.label.innerHTML           := "&#9658;" label_text 
		this.label["style.position"]   := "relative"
		this.label["style.left"]       := "3px"
		this.label["style.top"]        := "-10px"
		
		js := "document.getElementById(""" this.js_element_id """).parentNode.removeChild(document.getElementById(""" this.js_element_id """));"
		this.body().__Exec(js)	
		js := "InsertElementOnElement(""" "input" """, """ id """ , """ parent.js_element_id """);"
		this.body().__Exec(js)
		
		this.type                     := "range"			
		this["style.position"]        := "relative"
		this["style.left"]            := "10px"
		this["style.top"]             := "-7px"	
		this["style.border"]          := "0px"
		this["style.outline"]         := "none"	
		this.min                      := strsplit(rng, "-")[1]
		this.max                      := strsplit(rng, "-")[2]
		this.step                     := strsplit(rng, "-")[3]
		this.body().__Exec( "document.getElementById(""" this.js_element_id """).onchange=function(){SliderValueChanged()};" ) 
		
		this.face                     := new HTMLElement(parent, id "_face", "label")
		;this.label.for                := parent ;crash
		this.face.innerHTML           := this.value
		this.face["style.position"]   := "relative"		
		this.face["style.left"]       := "15px"	
		this.face["style.top"]        := "-10px"		
			
		this.details_div                       := new InputDetails(parent, id "_details", "div")
		this.details_div.innerHTML             := details 
		this.details_div["style.position"]     := "relative"
		this.details_div["style.left"]         := "20px"
		this.details_div["style.top"]          := "-10px"
		;this.details_div["style.marginBottom"] := "-10px"		
		
		ObjInsert(this, "sec", strsplit(id, ".")[1])
		ObjInsert(this, "key", strsplit(id, ".")[2])
		if (!this.key)
		{
			this.key := this.sec
			this.sec := ""
		}
		ObjInsert(this, "cfg", cfg)			
		this.value          := new ini(cfg).read(this.key, this.sec, strsplit(rng, "-")[1])
		this.face.innerHTML := this.value	
		return this
	}
	Clicked()
	{
		this.body().__Eval(this.checked, this, "StateChanged")
	}
	ValueChanged(value)
	{
		this.face.innerHTML := value
		cfg                 := new ini(this.cfg)
		cfg.edit(this.key, value, this.sec)
		cfg.save()
	}
}

Class HOTKEYInput extends HTMLElement
{
	Init(byref cfg, parent, id, label_text, details)
	{
		this["style.position"]        := "relative"
		this["style.backgroundColor"] := g_.color_d
		this["style.border"]          := "0px"
		this["style.outline"]         := "none"		
		this["style.width"]           := "100px"
		this["style.height"]          := "20px"
		 
		this.label           := new HTMLElement(parent, this.js_element_id "_label", "label")
		this.label.for       := this.js_element_id
		this.label.innerHTML := "&#9658;" label_text 
		this.label["style.position"]   := "relative"
		this.label["style.left"]       := "-100px"
		this["style.left"]             := "110px"
		;this["style.top"]              := "3px"
		
		this.details_div                       := new InputDetails(parent, id "_details", "div")
		this.details_div.innerHTML             := details 
		this.details_div["style.position"]     := "relative"
		this.details_div["style.left"]         := "20px"		
		
		ObjInsert(this, "sec", strsplit(id, ".")[1])
		ObjInsert(this, "key", strsplit(id, ".")[2])
		if (!this.key)
		{
			this.key := this.sec
				this.sec := ""
		}
		ObjInsert(this, "cfg", cfg)			
		this.innerHTML := new ini(cfg).read(this.key, this.sec, "False")	
		return this
	}
	Clicked()
	{
		this.menu := ""
		this.menu := new KbrdMenu(this, this.js_element_id "_menu", "div").init(this)
	}
	DissmissKbrdMenu()
	{
		this.update("")
	}
	Update(key)
	{
		this.menu      := ""
		this.innerHTML := key
		c := new ini(this.cfg)
		c.edit(this.key, key, this.sec)	
		c.save()
	}
	Over()
	{
		this["style.border"] := "1px solid " g_.color_c	 
	}
	Out()
	{
		this["style.border"] := "1px solid " g_.color_d		 
	}
}

Class HidenBOOLInput extends BOOLInput
{
	StateChanged(state)
	{
		if (state="False")
			 this.details_div.Disable()
		else this.details_div.Enable()		
	}
}

Class BOOLInput extends HTMLElement
{
	Init(byref cfg, parent, id, label_text, details)
	{
		this["style.position"]               := "relative"
		this.type                            := "checkbox"
		this["style.webkitBorder"]     := "0px" 
		this["style.border"]                 := "0px"
		this["style.outline"]                := "none"
		this.label                           := new HTMLElement(parent, id "_label", "label")
		;this.label.for                       := parent ;crash
		this.label.innerHTML                 := label_text
		this.details_div                     := new InputDetails(parent, id "_details", "div")
		this.details_div.innerHTML           := details 
		this.details_div["style.position"]   := "relative"
		this.details_div["style.marginLeft"] := "20px"
			
		ObjInsert(this, "sec", strsplit(id, ".")[1])
		ObjInsert(this, "key", strsplit(id, ".")[2])
		if (!this.key)
		{
			this.key := this.sec
				this.sec := ""
		}
		ObjInsert(this, "cfg", cfg)			
		val		  := new ini(cfg).read(this.key, this.sec, "False")	
		if (val = True or val = "True")
			this.checked := "True"
				
		return this
	}
	Disable()
	{
		js := "document.getElementById(""" this.js_element_id """).checked = false;"
		this.body().__Exec(js)
		js := "document.getElementById(""" this.js_element_id """).disabled = true;"
		this.body().__Exec(js)	
		this.StateChanged("False")				
	}
	Enable()
	{
		js := "document.getElementById(""" this.js_element_id """).disabled = false;"
		this.body().__Exec(js)	
		this.body().__Eval(this.checked, this, "StateChanged")
	}
	Clicked()
	{
		this.body().__Eval(this.checked, this, "StateChanged")
	}
	UpdateState()
	{
		this.body().__Eval(this.checked, this, "StateChanged")
	}
	EnumChildrenCallback(child)
	{
		child.disable()
	}
	StateChanged(state)
	{
		if (state="False")
			 this.details_div.Disable()
		else this.details_div.Enable()
		cfg := new ini(this.cfg)
		cfg.edit(this.key, state, this.sec)
		cfg.save()
	}
}