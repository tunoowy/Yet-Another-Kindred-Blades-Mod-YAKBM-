class EzObject
{
    __new(Vtable_Ptr)
    { 
        this._Object := Object(numget(Vtable_Ptr+A_ptrsize, "ptr"))
    }
    __delete()
    {
        if (this._Object)
           ObjRelease(this._Object)
    }
}

EZWebView2App_err(ptr, err){
    new EzObject(ptr)._Object.err(strget(err+0, "UTF-16"))	    
}
EZWebView2App_init(ptr, p){
    new EzObject(ptr)._Object.Init(p)    	
}
EZWebView2App_msg(ptr, p){
    new EzObject(ptr)._Object.Msg(strget(p, "UTF-16"))    	
}
EZWebView2App_resized(ptr, w, h){
    new EzObject(ptr)._Object.__Resized(w, h)    	
}
EZWebView2App_navigation_complete(ptr, null){
    new EzObject(ptr)._Object.NavigationComplete()   
}

class IJson
{
    __new(jsn)
    {
        for k, v in strsplit("getkey getstr getint getuint getint64 getuint64 getfloat getdouble deljsn", " ")   
        this[v]  := numget(numget(jsn+0, "ptr")+A_ptrsize*(k-1), "ptr")  
        this.jsn := jsn             
    }
    Key(i)
    {
        return dllcall(this.getkey, ptr, this.jsn, uint, i, astr) 
    }
    Str(k)
    {
        return dllcall(this.getstr, ptr, this.jsn, astr, k, astr) 
    }
    Int(k)
    {
        return dllcall(this.getint, ptr, this.jsn, astr, k, int) 
    }
    UInt(k)
    {
        return dllcall(this.getuint, ptr, this.jsn, astr, k, UInt) 
    }
    Int64(k)
    {
        return dllcall(this.getint64, ptr, this.jsn, astr, k, Int64) 
    }
    UInt64(k)
    {
        return dllcall(this.getuint64, ptr, this.jsn, astr, k, UInt64) 
    }
    float(k)
    {
        return dllcall(this.getfloat, ptr, this.jsn, astr, k, float) 
    }
    double(k)
    {
        return dllcall(this.getdouble, ptr, this.jsn, astr, k, double) 
    }
    __delete()
    {
        dllcall(this.deljsn, ptr, this.jsn) 
    }
}

class EZWebView2App 
{        
    __new(ptr)
    {          
        this.ptr       := ptr
        this.interface := dllcall("VirtualAlloc", uint, 0, uint, A_ptrsize*2, Int, 0x00001000, uint, 0x04) 	
        numput(EZWebView2App.VTable, this.interface+0,         "ptr")	
        numput( this.ptr,            this.interface+A_ptrsize, "ptr")
          
        hdll                := this.Gethdll() ;dllcall("LoadLibraryW", "wstr", A_workingdir "\MSEdge\IEzWebview2.dll", ptr)
		pfn                 := dllcall("GetProcAddress", "ptr", hdll, "astr", "CreateWebView2App", ptr)	
        this.IEZWebView     := {"ptr" : dllcall(pfn, ptr, this.interface, wstr, "Peixoto's patch", ptr)}  
        this.IEZWebView.shw := numget(numget(this.IEZWebView.ptr+0, "ptr")+A_ptrsize*1, "ptr")  
        this.IEZWebView.nav := numget(numget(this.IEZWebView.ptr+0, "ptr")+A_ptrsize*2, "ptr")  
        this.IEZWebView.js  := numget(numget(this.IEZWebView.ptr+0, "ptr")+A_ptrsize*3, "ptr")            
        this.IEZWebView.jsn := numget(numget(this.IEZWebView.ptr+0, "ptr")+A_ptrsize*4, "ptr")    
        this.IEZWebView.mnt := numget(numget(this.IEZWebView.ptr+0, "ptr")+A_ptrsize*6, "ptr")  
        this.IEZWebView.stt := numget(numget(this.IEZWebView.ptr+0, "ptr")+A_ptrsize*7, "ptr")                 
        dllcall(numget(numget(this.IEZWebView.ptr+0, "ptr")+0, "ptr"), ptr, this.IEZWebView.ptr, uint, 500, uint, 500)         
    }
    Gethdll()
    {
        hdll     := dllcall("LoadLibraryW", "wstr", A_workingdir "\MSEdge\IEzWebview2.dll", ptr)
        ;hdll     := 0
        if (hdll = 0)
        {
            msg=
            (LTRIM            
            Peixoto's patch requires the MS Edge runtime.`n 
            Press OK to donwload the runtime and try again after you install it
            )
            msgbox, 65, ,% msg
            IfMsgBox OK
            run, https://go.microsoft.com/fwlink/p/?LinkId=2124703
            exitapp    
        }
        return hdll
    }
    SetTitle(t)
    {
        return dllcall(this.IEZWebView.stt, ptr, this.IEZWebView.ptr, wstr, t)
    }
    Show(w, h)
    {
        dllcall(this.IEZWebView.shw, ptr, this.IEZWebView.ptr, uint, w, uint, h)
    }
    Js(js)
    {
        return dllcall(this.IEZWebView.js, ptr, this.IEZWebView.ptr, wstr, js, uint)
    }
    Navigate(url)
    {
        return dllcall(this.IEZWebView.nav, ptr, this.IEZWebView.ptr, wstr, url, uint)
    }
    JSon(jsn)
    {
        r := dllcall(this.IEZWebView.jsn, ptr, this.IEZWebView.ptr, wstr, jsn, ptr)        
        return new IJson(r)
    }
    err(err)
    {
        msgbox % err
    }
    Init(p)
    {
        return      
    }
    Msg(msg)
    {
        return
    }
    MountFolder(url, fldr)
    {
        return dllcall(this.IEZWebView.jsn, ptr, this.IEZWebView.mnt, wstr, url, wstr, fldr, uint)    
    }
}

EZWebView2App.VTable := dllcall("VirtualAlloc", uint, 0, uint, A_ptrsize*5, Int, 0x00001000, uint, 0x04) 	
numput(RegisterCallback("EZWebView2App_err",  "F"), EZWebView2App.VTable+0,         "ptr")	
numput(RegisterCallback("EZWebView2App_init", "F"), EZWebView2App.VTable+A_ptrsize, "ptr")
numput(RegisterCallback("EZWebView2App_msg", "F"), EZWebView2App.VTable+A_ptrsize*2, "ptr")
numput(RegisterCallback("EZWebView2App_resized", "F"), EZWebView2App.VTable+A_ptrsize*3, "ptr")
numput(RegisterCallback("EZWebView2App_navigation_complete", "F"), EZWebView2App.VTable+A_ptrsize*4, "ptr")