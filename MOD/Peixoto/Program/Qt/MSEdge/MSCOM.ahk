class WeakRef
{
	__new(Objct)
	{
		this._add := Object(Objct)
		ObjRelease(this._add)
	}
	Objct()
	{
		return Object(this._add)
	}
}

Class Interface 
{
	__new(pIntrfc, def)
	{
		def    := "destructor;" def
		vtbl   := numget(pIntrfc + 0, "Ptr")
		this.p := pIntrfc
		
		for k, v in strsplit(def, ";")
			this[v] := numget(vtbl + (k-1)*A_PtrSize, "Ptr")	
	}

	__delete()
	{
		if (this.destructor)
		dllcall(this.destructor, uint, this.p, uint)
	}
}

Class InterfaceImp 
{
	__new(name, def, byref parent)
	{
		this.vtable := dllcall("VirtualAlloc", uint, 0, uint, A_ptrsize*(StrSplit(def, " ").Length()), Int, 0x00001000, uint, 0x04)   
		this.ptr    := dllcall("VirtualAlloc", uint, 0, uint, A_ptrsize*2, Int, 0x00001000, uint, 0x04) 		
		p           := Object(parent)
		
		numput(this.vtable+0, this.ptr+0, "ptr")
		numput(p, this.ptr+A_ptrsize, "ptr")
		ObjRelease(p)
		
		for k, v in StrSplit(def, " ")
			numput(Registercallback(name "_" v), this.vtable+((k-1)*A_ptrsize), "ptr")
		
	}
	__delete(){
		dllcall("VirtualFree", ptr, this.vtable, ptr, 0x00008000, uint, 0x04) 
		dllcall("VirtualFree", ptr, this.ptr, ptr, 0x00008000, uint, 0x04) 
	}
}
