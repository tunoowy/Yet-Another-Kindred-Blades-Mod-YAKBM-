#include MSEdge/MSCOM.ahk
class HTMLStyle
{
	__new(taget)
	{
		ObjInsert(this, "ahk_target", taget)
	}
	__set(k, v)
	{
		this.ahk_target["style." k] := v
	}
}

class HTMLElement
{
	__new(byref parent, name, tag)
	{
		ObjInsert(this, "ahk", {"parent" : new WeakRef(parent.body()), "children" : {}})
		ObjInsert(this, "js_element_id", name)	
		parent.Append(name, tag, this)					
	}	

	style()
	{
		return new HTMLStyle(this)
	}
	__set(k, v)
	{
		if IsObject(v)
		{			
			ObjInsert(this, k, v)
			return True
		}
		else if v is digit 
			js := "document.getElementById(""" this.js_element_id """)." k "=""" v """;"
		else if v is not number
		{
			if instr(v, "document.getElementById(")
				 js := "document.getElementById(""" this.js_element_id """)." k "=" v ";"
			else js := "document.getElementById(""" this.js_element_id """)." k "=""" v """;"
		}
		else
			js := "document.getElementById(""" this.js_element_id """)." k "=" v ";"
		this.body().__Exec(js)
		return true
	}
	
	OnChecked(byref objct, method)
	{
		this.ahk.OnChecked := {"id" : objct.js_element_id, "method" : method}
	}
	
	Onkeypress(byref objct, method)
	{
		this.ahk.Onkeypress := {"id" : objct.js_element_id, "method" : method}
	}
	
	keyDown(value)
	{
		if (this.ahk.Onkeypress and value)
		{
			objct  := this.body().child(this.ahk.Onkeypress["id"])
			method := this.ahk.Onkeypress["method"]	
			this.body().__Eval(this.value, objct, method)				
		}		
	}
	
	OnClickId(byref objct, method)
	{
		this.ahk.onclickid := {"id" : objct.js_element_id, "method" : method}
	}
			
	OnClick(byref objct, method)
	{
		this.ahk.onclick := {"id" : objct.js_element_id, "method" : method}
	}
	
	Clicked()
	{
		if (this.ahk.onclick)
		{
			objct  := this.body().child(this.ahk.onclick["id"])
			method := this.ahk.onclick["method"]	
			objct[method].(objct)						
		} else if (this.ahk.onclickid)
		{
			objct  := this.body().child(this.ahk.onclickid["id"])
			method := this.ahk.onclickid["method"]	
			objct[method].(objct, this.js_element_id)						
		} else if (this.ahk.OnChecked)	
		{
			objct  := this.body().child(this.ahk.OnChecked["id"])
			method := this.ahk.OnChecked["method"]
			this.body().__Eval(this.checked, objct, method)	
		}
	}
	
	Scroll(offset="")
	{
		this.body().scroll(this, offset)
	}	

	__get(k)
	{
		return "document.getElementById(""" this.js_element_id """)." k 	
	}

	body()
	{
		return this.ahk.parent.Objct().body()
	}
	
	disable()
	{
		js := "document.getElementById(""" this.js_element_id """).disabled = true;"
		this.body().__Exec(js)	
	}
	
	enable()
	{
		js := "document.getElementById(""" this.js_element_id """).disabled = false;"
		this.body().__Exec(js)	
	}

	Append(name, tag, byref child)
	{
		js := "InsertElementOnElement(""" tag """, """ name """ , """ this.js_element_id """);"
		this.body().AddChild(name, child)
		this.body().__Exec(js)	
	}

	__delete()
	{
		js := "document.getElementById(""" this.js_element_id """).parentNode.removeChild(document.getElementById(""" this.js_element_id """));"
		js := "RemoveElement(""" this.js_element_id """);"
		this.body().__Exec(js)		
		this.body().Remove(this.js_element_id)
	}
}

class TestButton extends HTMLElement
{
    Clicked()
    {
        this.body().__eval("document.getElementById(""" this.js_element_id """).innerHTML", this, "Callback")
    }
    Callback(r)
    {
        msgbox % r
        this.body().range := ""
    }
    Over()
	{
		this["style.border"] := "2px solid blue"
	}
	Out()
	{
		this["style.border"] := "none"	 
	}
}

class TestDiv extends HTMLElement
{
	Clicked()
    {
        this.body().EnumChildren(this.js_element_id)        
    }
    EnumChildrenCallback(id)
    {
        msgbox % id
    }
}

class TestSlider extends HTMLElement
{
    init()
    {
        this.body().__Exec( "document.getElementById(""" this.js_element_id """).onchange=function(){SliderValueChanged()};")
        return this
    } 
    ValueChanged(v)
    {
        msgbox % v
    }
}

class HTMLWindow extends EZWebView2App 
{
    __new(help_js_path, arg, wintitle)
    {
		this._init(arg)
        this.help_js_path := help_js_path
		this.wintitle     := wintitle
        this.Callbacks    := []	
		this.Children     := {}		
        EZWebView2App.__new(Object(this))                
    }

    Init(p)
    {
		this.Navigate("file://" A_scriptdir "/" StrReplace(this.help_js_path, ".js", ".html"))	
    }

	NavigationComplete()
	{
		this.SetTitle(this.wintitle) "_" errorlevel "+" this.IEZWebView.stt
		this.help_js_path := ""
		this.wintitle     := ""

		if this.loadFinished()
		return
		
        this.div                  := new TestDiv(this, "Div", "Lacraia")
        this.div.innerHTML        := "Eguinha"
        this.but                  := new TestButton(this.div, "Pocoto", "BUTTON")
        this.but.innerHTML        := "Pocoto"   
		this.but.style().background   := "url('file://C:/Users/Peixoto/Documents/AutoHotkey/Lib/DirectX/AHK Injector/Qt/nfo.svg')"
        this.range                := new TestSlider(this.div, "Pacheco", "input").init()
        this.range.type           := "range"      
		this.input                := new HTMLElement(this.div, "haha", "input")
		this.__init(true)	
	}

    Msg(msg)
    {
        j   := this.JSon(msg)
        cmd := j.Str("msg")
        el  := j.Str("id")
        if (cmd = "Over")
            this.__over(el)
        else if (cmd = "Out")
            this.__out(el)
        else if (cmd = "Clicked")
            this.__Clicked(el)    
		else if (cmd = "KeyDown")       
            this.__KeyDown(el, j.str("key")) 	
        else if (cmd = "eval")
            this.Result(el)      
        else if (cmd = "SliderValueChanged")
            this.__SliderValueChanged(el, j.str("value"))  
        else if (cmd = "enumchildren")       
            this.__EnumChildrenCallback(el, j.str("child"))     
	    else if (cmd = "Link")       
            this.Clicked(el)      
        ;fileappend, % el " " cmd "ed", *   
    }

    child(id)
	{
		return this.children[id].Objct()
	}

    Remove(_id)
	{
		this.children[_id] := ""
	}	

    Result(result)
	{
		call := this.Callbacks[1]
		call.o[call.f].(call.o, result)
		this.Callbacks.RemoveAt(1)
	}

    AddChild(_id, Objct)
	{
		this.children[_id] := new WeakRef(Objct)
		ObjRelease(this.children[_id])
	}

    Append(_id, tag, byref child)
	{
		js := "InsertElementOnBody(""" tag """, """ _id """);"
		this.__Exec(js)	
		this.AddChild(_id, child)
	}

    body()
	{
		return this
	}

	__Resized(w, h)
	{
		this.resized(w, h)
	}

	__KeyDown(id, key)
	{
		this.children[id].Objct().KeyDown(key)		
	}

    __Exec(js)
	{
		this.Js(js)
	}

    __Clicked(DOM_ID)
	{
		if ( !this.children[DOM_ID].Objct().Clicked() )
		this.Clicked(DOM_ID)	
	}

    __over(eid)
	{
		this.children[eid].Objct().Over()
	}
	
	__out(eid)
	{
		this.children[eid].Objct().Out()
	}

    __SliderValueChanged(id, value)
	{
		this.children[id].Objct().ValueChanged(value)
	}

    __Eval(js, byref objct, callback)
	{
        this.Callbacks.push({"o" : objct, "f" : callback})
		this.js(StrReplace("SendMessage('eval', {});", "{}", js))
	}

    EnumChildren(id)
	{
        this.js(StrReplace("EnumChildren('{}');", "{}", id))       
	}
	
	__EnumChildrenCallback(parentid, childid)
	{
		this.children[parentid].Objct().EnumChildrenCallback(childid)
	}

	Scroll(objct, offset="")
	{
		id := objct.js_element_id
		if offset
			this.__Exec("document.getElementById(""" id """).scrollTop = " offset ";")
		this.__Exec("document.getElementById(""" id """).scrollIntoView();")		
	}
}

