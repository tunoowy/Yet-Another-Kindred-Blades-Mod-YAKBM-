#include <MSCOM>

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
		;FileAppend, % "Setting " k " to " v "`n", *
		if IsObject(v)
		{
			/*
			for kk, vv in v
			{
				fileappend, assingning %vv% to %k%.%kk%`n, *
				this[k "." kk] := vv
			}
			return true
			*/
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

QtWebEngineCallback_Debug(com_ptr, dbg_str){
	Object(numget(com_ptr+A_ptrsize, "ptr")).Debug(strget(dbg_str+0, "UTF-16"))		
}
QtWebEngineCallback_LoadFinished(com_ptr, success){
	Object(numget(com_ptr+A_ptrsize, "ptr")).LoadFinished(success)		
}
QtWebEngineCallback_Clicked(com_ptr, DOM_ID){
	Object(numget(com_ptr+A_ptrsize, "ptr")).__Clicked(strget(DOM_ID+0, "UTF-16"))		
}
QtWebEngineCallback_KeyDown(com_ptr, DOM_ID, key){
	Object(numget(com_ptr+A_ptrsize, "ptr")).__KeyDown(strget(DOM_ID+0, "UTF-16"), strget(key+0, "UTF-16"))		
}
QtWebEngineCallback_Resized(com_ptr, w, h){
	Object(numget(com_ptr+A_ptrsize, "ptr")).__Resized(strget(w+0, "UTF-16"), strget(h+0, "UTF-16"))		
}
QtWebEngineCallback_Result(com_ptr, result){
	Object(numget(com_ptr+A_ptrsize, "ptr")).Result(strget(result+0, "UTF-16"))		
}
QtWebEngineCallback_Over(com_ptr, eid){
	Object(numget(com_ptr+A_ptrsize, "ptr")).__Over(strget(eid+0, "UTF-16"))		
}
QtWebEngineCallback_Out(com_ptr, eid){
	Object(numget(com_ptr+A_ptrsize, "ptr")).__Out(strget(eid+0, "UTF-16"))		
}
QtWebEngineCallback_SliderValueChanged(com_ptr, eid, value){
	Object(numget(com_ptr+A_ptrsize, "ptr")).__SliderValueChanged(strget(eid+0, "UTF-16"), strget(value+0, "UTF-16"))		
}
QtWebEngineCallback_EnumChildrenCallback(com_ptr, parentid, childid){
	Object(numget(com_ptr+A_ptrsize, "ptr")).__EnumChildrenCallback(strget(parentid+0, "UTF-16"), strget(childid+0, "UTF-16"))		
}
	
class HTMLWindow 
{
	__new(title="")
	{				
		if ( !dllcall("LoadLibraryW", str, "HelpQt.dll") )
		{
			msgbox, 16, ,Failed to load the WebEngine dll with error: %A_Lasterror%
			return
		}	
		
		this.Callbacks  := []	
		this.Children   := {}
		this.Callback   := new InterfaceImp("QtWebEngineCallback", "Debug Result LoadFinished Clicked KeyDown Resized Over Out SliderValueChanged EnumChildrenCallback", this)
		this.prg        := new Interface(dllcall("HelpQt.dll\Create", "ptr", this.Callback.ptr, astr, A_scriptdir "\main.html", str, title, "ptr"), "Run;Show;Exec;Eval;Error")  			
	}
	
	child(id)
	{
		return this.children[id].Objct()
	}
	
	body()
	{
		return this
	}

	Append(_id, tag, byref child)
	{
		js := "InsertElementOnBody(""" tag """, """ _id """);"
		this.__Exec(js)	
		this.AddChild(_id, child)
	}

	AddChild(_id, Objct)
	{
		;fileappend, adding %_id%`n, *
		this.children[_id] := new WeakRef(Objct)
		ObjRelease(this.children[_id])
	}

	Remove(_id)
	{
		;fileappend, removing %_id%`n, *
		this.children[_id] := ""
	}

	Debug(str)
	{
		fileappend, % str, *
		return
	}
	
	LoadFinished(s)
	{
		fileappend, % "Load finished " v, *		
	}

	Result(result)
	{
		call := this.Callbacks[1]
		call.o[call.f].(call.o, result)
		this.Callbacks.RemoveAt(1)
	}

	__Clicked(DOM_ID)
	{
		if ( !this.children[DOM_ID].Objct().Clicked() )
		this.Clicked(DOM_ID)	
	}
	
	__KeyDown(id, key)
	{
		;fileopen("*", "w").WriteLine("Pressed " key " on " id)
		;if (!id)
			;this.Keydown(key)
		;else 
		this.children[id].Objct().KeyDown(key)		
	}
	
	__Resized(w, h)
	{
		this.resized(w, h)
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
	
	EnumChildren(id)
	{
		this.__Exec("EnumChildren(""" id """)")		
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

	Run()
	{
		return dllcall(this.prg.Run, ptr, this.prg.p)
	}

	Show(w=800, h=600)
	{
		return dllcall(this.prg.Show, ptr, this.prg.p, uint, w, uint, h)
	}

	__Exec(js)
	{
		;fileopen("*", "w").WriteLine("Executing " js)
		dllcall(this.prg.Exec, ptr, this.prg.p, str, js)
	}

	__Eval(js, byref objct, callback)
	{
		this.Callbacks.push({"o" : objct, "f" : callback})
		dllcall(this.prg.Exec, ptr, this.prg.p, str, "QWebChannelCallback.Result(" js ");")
	}

	__delete()
	{
		dllcall(this.prg.destructor, ptr, this.prg.p)
	}
}

/*
jsonAHK(s){
	static o:=comobjcreate("scriptcontrol")
	o.language:="jscript"
	return o.eval("(" s ")")
}
jsonBuild(j) { 
	for x,y in j
		s.=((a:=(j.setcapacity(0)=(j.maxindex()-j.minindex()+1)))?"":x ":")(isobject(y)?jsonBuild(y):y/y||y==0?y:"'" y "'") ","	
		;s.=x ":" (isobject(y)?jsonBuild(y):y/y||y==0?y:"'" y "'") ","
	return (a?"[" rtrim(s,",") "]":"{" rtrim(s,",") "}")
	;return ("{" rtrim(s,",") "}")
}
jsonGet(s,k){
	static o:=comobjcreate("scriptcontrol")
	o.language:="jscript"
	return o.eval("(" s ")." k)
}
*/
