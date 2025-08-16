;REMOTE SCRIPT START
logerr(IDirect3DSurface8.UnHook("LockRect"))		
logerr(IDirect3DSurface8.UnHook("UnLockRect"))	
logerr(IDirect3DDevice8.UnHook("DrawPrimitiveUp"))	
; pointer is bad after unhooking
dvc                                 := new ComInterfaceWrapper(D3D8.IDirect3DDevice8, IDirect3DDevice8.p, True)
IDirect3DDevice8.DrawPrimitiveUp	:= dvc.DrawPrimitiveUp
D3D8_HOOKS.p_DrawPrimitiveUP        := IDirect3DDevice8.DrawPrimitiveUp	