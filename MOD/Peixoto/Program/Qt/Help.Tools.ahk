class InstallShieldButton extends HTMLElement
{
	init()
	{
		this["style.backgroundColor"] := g_.color_d
		this["style.border"]          := "0px"
		this["style.outline"]         := "none"
		this["style.marginLeft"]      := "5px"
		this["style.width"]           := "160px"
		this["style.height"]          := "30px"
		this["style.marginBottom"]    := "20px"
		this["style.marginTop"]       := "5px"
		this.innerHTML := "Play"
		return this
	}
	clicked()
	{
		this.body().__Eval(this.innerHTML, this, "Install")		
	}
	Over()
	{
		this["style.border"] := "1px solid " g_.color_c	 
	}
	Out()
	{
		this["style.border"] := "1px solid " g_.color_d		 
	}
	Install(html)
	{
		this.prog := ""
		this.prog := new DocDiv(this.body().docs_div, "progress", "div").init()
		this.prog["style.height"]    := "350px"
		this.prog["style.overflow"]  := "scroll" 
		this.prog["style.display"]   := "block"
		this.__Install(Strsplit(HTML, "v")[2])
	}	
	Append(txt)
	{
		txt := strreplace(this.body().ProcessText(txt), "'", "&#39;")		
		js := "document.getElementById(""" this.prog.js_element_id """).innerHTML += '" txt "<br>';"
		this.body().__Exec(js)
	}
	Clone(Template, Clone)
	{
		FileCreateDir, %Clone%\
		loop, %Template%*.*, 1, 1
		{
			lnk := StrReplace(A_LoopFileFullPath, Template, Clone)		
			if InStr(FileExist(A_LoopFileFullPath), "D")  
			{
				FileCreateDir, %lnk%\
				msg := "Createdir " lnk " " A_lasterror "`n"
			}		
			else 
			{
				msg := "Create link : " lnk "`nto          : " A_LoopFileFullPath "`n"
				dllcall("CreateSymbolicLinkW", str, lnk, str, A_LoopFileFullPath, uint, 0)
			}
			Dllcall("WriteConsole", "ptr", DllCall("GetStdHandle", "int", -11, ptr), "ptr", &msg, "int", strlen(msg), uint, 0, ptr, 0)
		}
	}
	__Install(v, backto="InstallShield")
	{
		FileRemoveDir, %A_Temp%\InstallShield v3, 1
		FileRemoveDir, %A_Temp%\InstallShield v5, 1
		
		msg = 
		(LTRIM
		You will  now  be asked to point to the 16 bit setup
		program in the game's CD ROM. 
		
		This is usually named: "setup.exe"
		
		If you left click that file to examine its properties, you 
		will see in the details tab:
		
		Product name: InstallShield		
		)
		msgbox, 64, ,% msg		
		FileSelectFile, setup, 3, c:\, Please select the 16-bit setup executable file, *.exe
		if !setup
		return
		SplitPath, setup, ,dir , , ,Drv
		FileGetAttrib, att, %setup%
		setup_temp := StrReplace(dir, Drv, A_Temp "\InstallShield v" v)
		read_only  := instr(att, "R") ? "Yes" : "No"  
		Drv_type   := "DRIVE_UNKNOWN DRIVE_NO_ROOT_DIR DRIVE_REMOVABLE DRIVE_FIXED DRIVE_REMOTE DRIVE_CDROM DRIVE_RAMDISK"
		Drv_type   := strsplit(Drv_type, " ")[dllcall("GetDriveTypeA", astr, Drv "\", uint)+1]
		msg= 
		(LTRIM
		Setup File : %setup%
		Read Only  : %read_only%
		Drive      : %Drv%
		Type       : %Drv_type% 	
		New Path   : %setup_temp%`n
		)	
		DllCall("AllocConsole")	
		Dllcall("WriteConsole", "ptr", DllCall("GetStdHandle", "int", -11, ptr), "ptr", &msg, "int", strlen(msg), uint, 0, ptr, 0)
		
		if (dllcall("GetDriveTypeA", astr, Drv "\", uint) != 5)
		{
			msgbox, 16, ,Drive: %Drv%\ is not a CDRom Drive
			return	
		}
		
		if (!instr(att, "R"))
		{
			msgbox, 16, ,File: "%setup%\" is not Read Only
			return	
		}	
		
			
		Progress, w200 h50 FS16 M C0 zh0, ,Creating symbolic links
		this.Clone(Drv "\", A_Temp "\InstallShield v" v "\")
		Progress, off
		dllcall("FreeConsole")
		filecopy, ..\InstallShield\setupv%v%.exe, %setup_temp%\setupv%v%.exe 
		
		ini :=  new ini("..\InstallShield\InstallShield.ini")
		ini.edit("target", setup_temp "\setupv" v ".exe")
		ini.edit("drive", Drv)
		ini.edit("tempdir", A_Temp "\InstallShield v" v "\")
		if (v=3)
		msgbox, 36, ,Set Windows 95 compatibility ?
		else 
		msgbox, 36, ,Set Windows 98 compatibility ?	
		IfMsgBox, yes
		ini.edit("compatlayer", v = 3 ? "win95" : "win98")	
		else ini.edit("compatlayer", "HIGHDPIAWARE")	
		ini.save()
		
		
		;run ..\Injector.exe -f InstallShield\InstallShield.ini, ..\
		;run InstallShield.bat
		run HelpQt.exe InstallShield.ahk "%backto%"
		exitapp
		return
	}
}

class InstallShield
{
	__new(body, v="")
	{
		txt             := fileopen("..\Help\InstallShield.txt", "r").read()		 
		body.links	    := body.GetLinks(strsplit(txt, "::"))	
		body.docs_items := {} 		
		
		div                         := new DocDiv(body.docs_div , "Install_Shield", "div").init()
		div.title                   := new DocSectionHead(div , "Install_Shield_Title", "div").init()
		div.title["style.marginBottom"]           := "2px"
		div.title.textContent       := "InstallShield Tool"
		
		div.buts         := new HTMLElement(div, "Install_Shield_buts", "div")
		v!=5 ? div.v3    := new InstallShieldButton(div.buts, "v3", "BUTTON").init()
		v!=3 ? div.v5    := new InstallShieldButton(div.buts, "v5", "BUTTON").init()
		div.v3.innerHTML := "Install - InstallShield v3"
		div.v5.innerHTML := "Install - InstallShield v5"
		
		div.contents                := new DocSectionContent(div, "Install_Shield_Contents", "div").init()
		div.contents.innerHTML      := body.ProcessText(strsplit(txt, "::")[1])	
		body.docs_items             := {"main" : div}
	}
}

Class ModsBOOLInput extends HTMLElement
{
	Init(cfg, parent, label_text)
	{	
		this.ahk.md             := label_text
		this.ahk.cfg            := cfg
		this["style.position"]  := "relative"
		this.type               := "checkbox"
		this["style.border"]    := "0px"
		this["style.outline"]   := "none"
		this.label              := new HTMLElement(parent, this.js_element_id "_label", "label")
		this.label.for          := this.js_element_id
		this.label.innerHTML    := label_text "<br>"	

		if instr(new ini(cfg).read("mods"), label_text ";")
			this.checked := "True"
		return this
	}
	Clicked()
	{
		this.body().__Eval(this.checked, this, "StateChanged")
	}
	StateChanged(state)
	{
		cfg := new ini(this.ahk.cfg)
		val := cfg.read("mods")
		if (state="False")
			val := StrReplace(val, this.ahk.md ";")			
		else 
			val .= this.ahk.md ";"		
		cfg.edit("mods", val)	
		cfg.save()
	}	
}

class ModsManager extends HTMLElement
{
	init(cfg)
	{
		path := "%__path__%"
		mods_tuto =
		(LTRIM
		This will let you install and manage mods for the game with no need to move files arround
		and overwrite the game's files. The process is very simple|n
		<ul>	
		l|Start the game using the program, so the directory: i|%path%mods|i will be created, if it doesn't alreay exists</li>		
		l|For each mod you wish to install, create one folder inside that directory and copy all the files of each mod to its respective folder</li>			
		l|<a id="Refreshtotab_file system_modstuto" href="javascript:dummy()">Refresh</a> this page and now you should see a list of all installed mods bellow.
		Check the ones you want active and play. The game's files wont be modified and the mods will only be active
		when you start the game with the program</li></ul><br>					
		)
		
		this.ahk.cfg                      := cfg
		this.innerHTML                    := "&#9658;Mods manager <br>"
		this.style().display              := "block"
		
		this.content                      := new HTMLElement(this, "modstuto", "div")
		this.content.style().marginLeft   := "20px"
		this.content.style().display      := "block"
		this.content.innerHTML            := this.body().processtext(mods_tuto)
		
		this.mods := []
		path      := this.body().__path__
		loop, files, %path%\mods\*.*, D 
		{
			this.mods.push( new ModsBOOLInput(this.content, "mods_mod_" A_LoopFileName, "input").init(cfg, this.content, A_LoopFileName) )
		}
		return this
	}
}

class ScalersDialogClose extends HTMLElement
{
	Over()
	{
		this["style.cursor"] := "pointer"
	}
	Out()
	{
		this["style.cursor"] := "Default"
	}
	clicked()
	{
		this.body().child("_scaler_").dialog := ""
	}
}

class ScalersDialog extends HTMLElement
{
	init(parent, cfg)
	{
		cfg := new ini(cfg)
		dir := A_mydocuments "\Games\" cfg.read("path") "\" cfg.read("path", "Textswap")
		this.ahk.dir := dir
		
		this.ahk.api        := ""
		this.ahk.scale      := 2
		this.ahk.method     := "xBRz"
		this.ahk.overwrite  := False
		this.ahk.rgba       := False
			
		css := this.style()
		css.display         := "block"
		css.position        := "absolute"	
		css.zIndex          := 1
		css.backgroundColor := "#f9edbe"
		css.top             := parent.h/2-200 "px"
		css.left            := parent.w/2-400 "px"
		css.width           := "900px"
		css.height          := "375px"
		css.border          := "3px solid black"
			
		this.c              := new ScalersDialogClose(this, "Scalers_Dialog_Close", "BUTTON")
		css                 := this.c.style()
		css.display         := "block"
		css.border          := "none"
		css.outline         := "none"
		css.zIndex          := 1
		css.position        := "relative"
		css.width           := "25px"
		css.backgroundColor := "#f9edbe"
		css.left            := "870px"
		css.top             := "2px"
		css.fontSize        := "16px"
		this.c.innerHTML    := "[X]"
		
		this.src                         := new HTMLElement(this, "ScalersDialogsrc", "label")
		this.src.style().position        := "Relative"
		this.src.style().left            := "5px"
		this.src.style().top             := "15px"
		this.src.style()["margin.left"]  := "5px"
		this.src.style()["margin.right"] := "5px"
		this.src.innerHTML               := this.body().ProcessText("Source directory: " dir "\dumps<br>")
		
		this.dst                         := new HTMLElement(this, "ScalersDialogdst", "label")
		this.dst.style().position        := "Relative"
		this.dst.style().left            := "5px"
		this.dst.style().top             := "15px"
		this.dst.style()["margin.left"]  := "5px"
		this.dst.style()["margin.right"] := "5px"
		this.dst.innerHTML               := this.body().ProcessText("Destination directory: " dir "\Replacements<br><br><br>")
		
		this.method_field                := new HTMLElement(this, "methods_field", "fieldset")
		this.method_field.style().top    := "25px"
		this.method_legend               := new HTMLElement(this.method_field, "method_legend", "legend")
		this.method_legend.innerHTML     := "Method"
		this.method_xBRz                 := new HTMLElement(this.method_field, "method_xBRz", "input")
		this.method_xBRz.type            := "radio"
		this.method_xBRz.checked         := True
		this.method_xBRz_label           := new HTMLElement(this.method_field, "method_xBRz_label", "label")
		this.method_xBRz_label.for       := "method_xBRz"
		this.method_xBRz_label.innerHTML := "xBRz"
		this.method_AI                   := new HTMLElement(this.method_field, "method_AI", "input")
		this.method_AI.type              := "radio"
		this.method_AI.disable()
		this.method_AI_label             := new HTMLElement(this.method_field, "method_AI_label", "label")
		this.method_AI_label.for         := "method_AI"
		this.method_AI_label.innerHTML   := "AI upscale - Comming soon"
		
		this.scale_field                := new HTMLElement(this, "scale_field", "fieldset")
		this.scale_field.style().top    := "10px"
		this.scale_legend               := new HTMLElement(this.scale_field, "scale_legend", "legend")
		this.scale_legend.innerHTML     := "Scale"
		for k, v in strsplit("2x 3x 4x 5x 6x", " ")
		{
			this["scale_" v]	                := new HTMLElement(this.scale_field, "scale_" v, "input")
			this["scale_" v].OnClickId(this, "ScaleSet")
			this["scale_" v].type               := "radio"	
			this["scale_" v].name               := "scale"			
			this["scale_" v "_label"]           := new HTMLElement(this.scale_field, "scale_" v "_label", "label")
			this["scale_" v "_label"].for       := "scale_" v
			this["scale_" v "_label"].innerHTML := v
		}
		this["scale_4x"].checked             := True
		
		
		this.overwrite_field                := new HTMLElement(this, "overwrite_field", "fieldset")
		this.overwrite_field.style().top    := "10px"
		this.overwrite_legend               := new HTMLElement(this.overwrite_field, "overwrite_legend", "legend")
		this.overwrite_legend.innerHTML     := "Overwrite ?"
		this.overwrite_skip                 := new HTMLElement(this.overwrite_field, "overwrite_skip", "input")
		this.overwrite_skip.type            := "radio"
		this.overwrite_skip.name            := "overwrite"
		this.overwrite_skip.checked         := True
		this.overwrite_skip_label           := new HTMLElement(this.overwrite_field, "overwrite_skip_label", "label")
		this.overwrite_skip_label.for       := "overwrite_skip"
		this.overwrite_skip_label.innerHTML := "Skip"
		this.overwrite_overwrite                 := new HTMLElement(this.overwrite_field, "overwrite_overwrite", "input")
		this.overwrite_overwrite.type            := "radio"
		this.overwrite_overwrite.style().left    := "5px"
		this.overwrite_overwrite.name            := "overwrite"
		this.overwrite_overwrite_label           := new HTMLElement(this.overwrite_field, "overwrite_overwrite_label", "label")
		this.overwrite_overwrite_label.for       := "overwrite_skip"
		this.overwrite_overwrite_label.innerHTML := "Overwrite"
		this.overwrite_skip.OnClickId(this, "OverWriteSet")
		this.overwrite_overwrite.OnClickId(this, "OverWriteSet")
		
		this.rbga_field                      := new HTMLElement(this, "rbgafield", "fieldset")
		this.rbga_legend                     := new HTMLElement(this.rbga_field, "rbgafield_legend", "legend")
		this.rbga_legend.innerHTML           := "Uncompressed output ?"		
		this.rbga                            := new HTMLElement(this.rbga_field, "scale_grba", "input")
		this.rbga.type                       := "checkbox"
		this.rbga_label                      := new HTMLElement(this.rbga_field, "scale_grba_label", "label")
		this.rbga_label.for                  := "scale_grba"
		this.rbga_label.innerHTML            := "Use this if the original textures use colorkey transparency"
		this.rbga.OnChecked(this, "OutPutSet")		
		
		this.ScalersDialog_scale                  := new CreateDialogCreate(this, "ScalersDialog_scale", "Button")
		this.ScalersDialog_scale.style().display  := "block"
		this.ScalersDialog_scale.style().position := "relative"
		this.ScalersDialog_scale.style().left     := "797px"
		this.ScalersDialog_scale.style().top      := "30px"
		this.ScalersDialog_scale.style().width    := "100px"
		this.ScalersDialog_scale.style().outline  := "none"
		this.ScalersDialog_scale.style().border   := "none"
		this.ScalersDialog_scale.style().height   := "30px"
		this.ScalersDialog_scale.style().color    := "white"
		this.ScalersDialog_scale.innerHTML        := "Scale"
		this.ScalersDialog_scale.OnClick(this, "Scale")
		this.ScalersDialog_scale.out()
		
		return this
	}
	OutPutSet(state)
	{
		this.ahk.rgba := state="true"?True:False		
	}
	ScaleSet(scale)
	{
		this.ahk.scale := strsplit(strsplit(scale, "_")[2], "x")[1]		
	}
	OverWriteSet(over)
	{
		this.ahk.overwrite := over="overwrite_overwrite" ? True : False		
	}
	Scale()
	{
		dllcall("AllocConsole")	
		p := FileExist("..\peixoto.dll") ? "..\peixoto.dll" : A_mydocuments "\Autohotkey\dlls\peixoto.dll"	
		r := dllcall("LoadLibraryW", str, p) 
		if (r = 0)
		{
			msgbox, 16, ,Failed to load peixoto.dll with error %A_lasterror%
			return
		}
		err := dllcall("peixoto.dll\xBRzCreate", "ptr*", xBRz, astr) 
		FileOpen("*", "w").WriteLine("xBRzCreate " err " " errorlevel " " xBRz)	
		if (err != "Success")
		{
			msgbox, 16, ,Failed to create the xBRz scaler`n%err%
			return
		}
		
		dir := this.ahk.dir
		loop, Files, %dir%\dumps\*.dds
		{
			rep := StrReplace(A_LoopFileFullPath, "dumps", "Replacements")
			if (fileexist(rep) && !this.ahk.overwrite)
				 FileOpen("*", "w").WriteLine("Skiping " A_LoopFileFullPath)	
			else 
			{
				FileOpen("*", "w").WriteLine("Upscaling " A_LoopFileFullPath "to`n " rep)
				FileOpen("*", "w").WriteLine( dllcall("peixoto.dll\xBRzUPscale", ptr, xBRz, str, A_LoopFileFullPath, str, rep, uint, this.ahk.scale, uint, this.ahk.rgba, astr) errorlevel)
			}
		}
		msgbox,64, , Done! 
		dllcall("FreeConsole")		
	}
}

class Scaler extends HTMLElement
{
	init(cfg)
	{
		this.ahk.cfg                  := cfg
		this.style().marginBottom     := "10px"
		this["style.border"]          := "none"			
		this["style.outline"]         := "none"
		this["style.backgroundColor"] := "RoyalBlue" 
		this["style.color"]           := "white" 
		this.style().position         := "Relative"
		this.style().width            := "150px"
		this.style().height           := "30px"
		this.style().left             := "5px"
		this.innerHTML                := "Texture scalers"
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
	Clicked()
	{
		cfg     := new ini(this.ahk.cfg)
		src     := A_mydocuments "\Games\" cfg.read("path") "\" cfg.read("path", "Textswap") "\dumps"
		if not fileexist(src "\*.dds")
		{
			msgbox, 16, , No dds files in`n`n%src%
			return
		}
		
		this.dialog := new ScalersDialog(this.body(), "Scalers_Dialog", "div").init(this.body(), this.ahk.cfg)
	}	
}

class Compiler extends HTMLElement
{
	init(cfg)
	{
		this.ahk.cfg                  := cfg
		this.style().marginBottom     := "10px"
		this["style.border"]          := "none"			
		this["style.outline"]         := "none"
		this["style.backgroundColor"] := "RoyalBlue" 
		this["style.color"]           := "white" 
		this.style().position         := "Relative"
		this.style().width            := "150px"
		this.style().height           := "30px"
		this.innerHTML                := "Compile dumps"
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
	Write(str)
	{
		fileopen("*", "w").writeline(str)
	}
	Clicked()
	{
		path := A_mydocuments "\games\" new ini(this.ahk.cfg).read("path") "\" new ini(this.ahk.cfg).read("path", "Textswap")	
		if (! FileExist(path) )
		{
			msgbox, 16, % Invalid path
			return
		}
		s := new ini(this.ahk.cfg).read("s", "Textswap")	
		msgbox, 33, ,Compile dumps in %path%`nWith %s% samples`nIs that ok?
		IfMsgBox, Cancel
			return
		CompileTextureDumps(path "\Dumps\", "dump", 4)	
	}	
}

class CreateDialogClose extends HTMLElement
{
	Over()
	{
		this["style.cursor"] := "pointer"
	}
	Out()
	{
		this["style.cursor"] := "Default"
	}
	clicked()
	{
		this.body().child("create_new").dialog := ""
		this.body().child("AddGame").dialog := ""
	}
}

class CreateDialogPath extends CreateDialogClose
{
	Over()
	{
		this["style.cursor"] := "pointer"
	}
	Out()
	{
		this["style.cursor"] := "Default"
	}
	clicked()
	{
		FileSelectFile, game, Options, , , *.exe
		if (!game)
			return
		this.innerHTML := StrReplace(game, "\", "\\")
		this.body().child("create_new_dialog").TargetSet(game)
	}
}

class CreateDialogApi extends CreateDialogClose
{
	clicked()
	{
		api    := StrSplit(this.js_element_id, "_radio_")[2]
		target := this.body().child("create_new_dialog")
		this.body().__Eval(api, target, "SetApi")		
	}
}
 
class CreateDialogCreate extends HTMLElement
{
	Over()
	{
		this["style.backgroundColor"] := "DodgerBlue"
	}
	Out()
	{
		this["style.backgroundColor"] := "RoyalBlue" 
	}	
}

class CreateNewDialog extends HTMLElement
{
	init(parent)
	{
		this.ahk.api        := ""
		
		css := this.style()
		css.display         := "block"
		css.position        := "absolute"
		;this.body().__Exec("dragElement('" this.js_element_id "');")
		css.zIndex          := 1
		css.backgroundColor := "#f9edbe"
		css.top             := parent.h/2-200 "px"
		css.left            := parent.w/2-200 "px"
		css.width           := "400px"
		css.height          := "390px"
		css.border          := "3px solid black"
		
		this.c              := new CreateDialogClose(this, "create_dialog_close", "BUTTON")
		css                 := this.c.style()
		css.display         := "block"
		css.border          := "none"
		css.outline         := "none"
		css.zIndex          := 1
		css.position        := "relative"
		css.width           := "25px"
		css.backgroundColor := "#f9edbe"
		css.left            := "370px"
		css.top             := "2px"
		css.fontSize        := "16px"
		this.c.innerHTML    := "[X]"
		
		this.radios := []
		this.labels := []
		apis := StrSplit("OpenGl,DirectX 1-6,DirectX 7,DirectX 8,DirectX 9,DirectX 10,DirectX 11, DirectX 12", ",")
		if (g_.wip)
		{
			;apis.Insert("DirectX 12")
			apis.Insert("Vulkan")
		}
		for k, v in apis
		{
			r                       := new CreateDialogApi(this, "create_dialog_radio_" k, "input")
			r.style().display       := "inline"
			r.style().marginBottom  := "0px"
			r.style().marginTop     := "0px"
			r.type                  := "radio"
			r.name                  := "API"
			this.radios.push( r )
			
			l                      := new HTMLElement(this, "create_dialog_label_" k, "label")
			l.style().display      := "block"
			l.for                  := "create_dialog_radio_" k
			l.style().position     := "relative"
			l.style().left         := "20px"
			l.style().top          := "-20px"
			l.style().marginBottom := "-20px"
			l.innerHTML        := v
			this.labels.push( l )
		}
		
		this.path           := new CreateDialogPath(this, "create_dialog_path", "BUTTON")
		css                 := this.path.style()
		css.height          := "40px"
		css.width           := "395px"
		css.textAlign       := "left"
		css.color           := "#0000FF"
		css.top             := "10px"
		css.display         := "block"
		css.border          := "none"
		css.outline         := "none"
		css.zIndex          := 1
		css.position        := "relative"		
		css.backgroundColor := "#f9edbe"	
		this.path.innerHTML := "Game Path"
		
		this.entry_name                  := new HTMLElement(this, "create_dialog_new_entry_name_label", "label")
		this.entry_name.innerHTML        := "New entry name"
		this.entry_name.style().display  := "inline"
		this.entry_name.style().position := "relative"
		this.entry_name.style().top      := "25px"
		this.entry_name.style().left     := "6px"
		
		this.entry_name_name                  := new HTMLElement(this, "create_dialog_new_entry_name", "input")
		this.entry_name_name.style().display  := "block"
		this.entry_name_name.style().position := "relative"
		this.entry_name_name.style().left     := "130px"
		this.entry_name_name.style().top      := "5px"
		this.entry_name_name.style().width    := "260px"
		this.entry_name_name.Onkeypress(this, "NameSet")
		
		this.entry_path_label                  := new HTMLElement(this, "create_dialog_new_entry_path_label", "label")
		this.entry_path_label.innerHTML        := "Path"
		this.entry_path_label.style().display  := "inline"
		this.entry_path_label.style().position := "relative"
		this.entry_path_label.style().top      := "25px"
		this.entry_path_label.style().left     := "6px"
		
		this.entry_path_help                  := new HTMLElement(this, "create_dialog_new_entry_path_help", "label")
		this.entry_path_help.innerHTML        := "[ ? ]"
		this.entry_path_help.style().display  := "inline"
		this.entry_path_help.style().position := "relative"
		this.entry_path_help.style().top      := "25px"
		this.entry_path_help.style().left     := "10px"
		this.entry_path_help.style().color    := "#0000ff"
		this.entry_path_help.style().cursor   := "pointer"
		this.entry_path_help.OnClick(this, "PathHelp")
		
		this.entry_path                  := new HTMLElement(this, "create_dialog_new_entry_path", "input")
		this.entry_path.style().display  := "block"
		this.entry_path.style().position := "relative"
		this.entry_path.style().left     := "130px"
		this.entry_path.style().top      := "5px"
		this.entry_path.style().width    := "260px"
		this.entry_path.Onkeypress(this, "PathSet")
		
		this.cmd_label                  := new HTMLElement(this, "create_dialog_cmd_label", "label")
		this.cmd_label.innerHTML        := "Arguments"
		this.cmd_label.style().display  := "inline"
		this.cmd_label.style().position := "relative"
		this.cmd_label.style().top      := "25px"
		this.cmd_label.style().left     := "6px"
		
		this.cmd_label_help                  := new HTMLElement(this, "create_dialog_cmd_help", "label")
		this.cmd_label_help.innerHTML        := "[ ? ]"
		this.cmd_label_help.style().display  := "inline"
		this.cmd_label_help.style().position := "relative"
		this.cmd_label_help.style().top      := "25px"
		this.cmd_label_help.style().left     := "10px"
		this.cmd_label_help.style().color    := "#0000ff"
		this.cmd_label_help.style().cursor   := "pointer"
		this.cmd_label_help.OnClick(this, "CmdHelp")
		
		this.cmd                  := new HTMLElement(this, "create_dialog_cmd", "input")
		this.cmd.enable()
		this.cmd.style().display  := "block"
		this.cmd.style().position := "relative"
		this.cmd.style().left     := "130px"
		this.cmd.style().top      := "5px"
		this.cmd.style().width    := "260px"
		this.cmd.Onkeypress(this, "CmdLineSet")
		
		this.create                  := new CreateDialogCreate(this, "create_dialog_create", "Button")
		this.create.style().display  := "block"
		this.create.style().position := "relative"
		this.create.style().left     := "293px"
		this.create.style().top      := "50px"
		this.create.style().width    := "100px"
		this.create.style().outline  := "none"
		this.create.style().border   := "none"
		this.create.style().height   := "30px"
		this.create.style().color    := "white"
		this.create.innerHTML        := "Create"
		this.create.OnClick(this, "CeateEntry")
		this.create.out()
		
		;this.innerHTML := "____________<br>"
		return this
	}
	IsPathValid(p)
	{
		if fileexist(p)
		return 2	
		
		FileCreateDir, %p%
		if ( errorlevel=0 )
		{
			FileRemoveDir, %p%
			return 1
		}
		return 0
	}
	CeateEntry()
	{
		if (!this.ahk.path)
		{
			msgbox, 16, ,No path selected
			return
		} else {
			p     := A_mydocuments "\games\" this.ahk.path
			valid := this.IsPathValid(p) 
			if (valid=2)
			{
				msgbox, 36, ,"%p%" Already exits? Continue?
				IfMsgBox, No
					return
			} else if (!valid) {
				msgbox, 16, ,"%p%" is not a valid path
				return
			}
		}
			
		if (!this.ahk.Name)
		{
			msgbox, 16, ,No Name selected
			return
		}
		if (!this.ahk.Target)
		{
			msgbox, 16, ,No Target selected
			return
		}
		if (!this.ahk.api)
		{
			msgbox, 16, ,No API selected
			return
		}
		if (fileexist("..\" g_.profiles "\" this.ahk.Name ".ini"))
		{
			msgbox, 36, ,% g_.profiles "\" this.ahk.Name ".ini  Already exits? Continue?" 
			IfMsgBox, No
				return			
		}
		
		api    := strsplit("Gl 1 7 8 9 10 11 12 Vk", " ")[this.ahk.api]
		help   := strsplit("Gl ddraw ddraw DX8 DX9 DX10 DX11 DX12 Vulkan", " ")[this.ahk.api]
		target := this.ahk.Target
		path   := this.ahk.path
		
		cfg=
		(LTRIM
		Target=%target%
		D3D=%api%
		Help=%help%
		path=%path%
		RLMT=0
		
		[Textswap]
		e=False
		sw=End
		n=>
		p=<
		d=Home
		q=Shift
		sz=256
		s=4
		path=Textures\VOKSI		
		)
		
		name := this.ahk.Name
		fileopen("..\" g_.profiles "\" this.ahk.Name ".ini", "w").Write(cfg)
		run Help.Qt.exe "Help.Qt.ahk" -g "%name%"
		exitapp
	}
	TargetSet(t)
	{
		this.ahk.Target := t
	}
	CmdLineSet(cmd)
	{
		this.ahk.cmd := cmd
	}
	PathSet(path)
	{
		fileappend, % path, *
		this.ahk.path := path
	}
	NameSet(name)
	{
		this.ahk.name := name
		for k, v in strsplit("*.""/\[]:;|=,")
		{
			if instr(this.ahk.name, v)
			{
				msgbox, 16, , The entry name can't have any of these characters:`n*."/\[]:;|=,
				this.entry_name_name.value := ""
			}
		}
	}
	PathHelp()
	{
		msg =
		(LTRIM
		The path - relative to %A_mydocuments%\games - the program uses to:`n 
		dump textures and load replacements, if textureswapp is anabled`n
		dump shader and load replacements, if shaderoverride is anabled`n
		keep save games, if file redirection is enabled `n
		load mods, if the mods manager is enabled `n
		)
		msgbox, 64, ,  % msg
	}
	CmdHelp()
	{
		msgbox, 64, ,Command line arguments pased to the game
	}
	SetApi(api)
	{
		this.ahk.api := api		
	}
}

DDS_PIXELFORMAT := "DWORD dwSize; DWORD dwFlags; DWORD dwFourCC; DWORD dwRGBBitCount; DWORD dwRBitMask; "
.  "DWORD dwGBitMask; DWORD dwBBitMask; DWORD dwABitMask;"

global DDS_HEADER := new _Struct("DWORD dwSize; DWORD  dwFlags; DWORD dwHeight; DWORD dwWidth; DWORD dwPitchOrLinearSize; "
.  "DWORD dwDepth; DWORD dwMipMapCount; DWORD dwReserved1[11]; DDS_PIXELFORMAT ddspf; DWORD dwCaps; DWORD dwCaps2; "
.  "DWORD dwCaps3; DWORD dwCaps4; DWORD dwReserved2;")

GetFilesList(dir, dump, byref samples)
{
	files := []
	loop, %dir%\*.dds, 0, 0
	{
		FileGetSize, sz, %A_loopfilefullpath%
		files.insert( {"f" : A_loopfilename, "l" : sz} )
	}	
	return files
}

GetHeaderFromFile(f, samples)
{
	file := FileOpen(f, "r") 
	VarSetCapacity(data, DDS_HEADER.size()+4, 0)
	file.RawRead(data, DDS_HEADER.size()+4)		
	dllcall("RtlMoveMemory", ptr, DDS_HEADER[], ptr, &data + 4, int, DDS_HEADER.size())
	
	data_sz := file.Length - DDS_HEADER.size() - 4
	data_sz *= samples/DDS_HEADER.dwHeight
		
	if (DDS_HEADER.ddspf.dwFlags & 4) 
	{
		data_sz           := file.Length - DDS_HEADER.size() - 4
		data_rows_count   := DDS_HEADER.dwHeight/4
		pitch             := data_sz/data_rows_count	
		data_sz           := pitch*samples
	}
		
	file.close()
	return data_sz 
}

GetDataFromFile(f, samples, byRef RetData)
{
	file := FileOpen(f, "r") 
	VarSetCapacity(data, file.Length, 0)
	file.RawRead(data, file.Length)
		
	dllcall("RtlMoveMemory", ptr, DDS_HEADER[], ptr, &data + 4, int, DDS_HEADER.size())
	offset := &data + DDS_HEADER.size() + 4	
		
	if (DDS_HEADER.ddspf.dwFlags & 4) ; DDPF_FOURCC
	{
		data_sz           := file.Length - DDS_HEADER.size() - 4
		data_rows_count   := DDS_HEADER.dwHeight/4
		pitch             := data_sz/data_rows_count		
		jump              := round(data_rows_count/samples)
		sz                := VarSetCapacity(RetData, pitch*samples)		
		loop, %samples%
		{
			dllcall("RtlMoveMemory", ptr, &RetData + pitch * (A_index - 1)
			                       , ptr, offset + (pitch * (A_index - 1) * jump), uint, pitch)
		}				
	}		
	else 
	{		
		data_sz := file.Length - DDS_HEADER.size() - 4
		pitch   := data_sz/DDS_HEADER.dwHeight		
		jump    := round(DDS_HEADER.dwHeight/samples)
		sz      := VarSetCapacity(RetData, pitch*samples)		
		loop, %samples%
		{
			dllcall("RtlMoveMemory", ptr, &RetData + pitch * (A_index - 1)
			                       , ptr, offset + (pitch * (A_index - 1) * jump), uint, pitch)
		}				
	}	
	file.close()
	return sz
}

CompileTextureDumps(dir, outfile, samples = 4)
{
	CoordMode, Mouse, screen
	MouseGetPos, x, y
	Progress, b x%x% y%y% h19 ZH10
	
	files       := GetFilesList(dir, outfile "._dds", samples)		
	dump        := fileopen("temp._dds", "w")
	header_size := (510 + 8) * files._MaxIndex()  
	sum         := 4 + header_size	
	offsets     := []
	
	dump.writeUshort(files._MaxIndex())
	dump.writeUshort(samples)
	for k, v in files
	{	
		offsets.insert(sum)
		VarSetCapacity(fname, 510, 0)
		strput(v.f, &fname, 255, "UTF-8")
		dump.rawwrite(&fname, 510)	
		
		data_sz := GetHeaderFromFile(dir v.f, samples)		
		size    := DDS_HEADER.size() + 4 + data_sz
		
		dump.writeUint(sum)
		dump.writeUint(size)
		sum += size		
	}
			    
	for k, v in files
	{		
		p := k/files._MaxIndex() * 100
		Progress, % p
		dump.seek(offsets[k])
		sz := GetDataFromFile(dir v.f, samples, pData)
		dump.writeint(5)	
		dump.rawwrite(DDS_HEADER[], DDS_HEADER.size())	
		dump.rawwrite(&pData, sz)		
	}
	dump.close()	
	filecopy, temp._dds, %dir%%outfile%._dds, 1
	Progress, off
	MsgBox, 64,,Done!	
}

