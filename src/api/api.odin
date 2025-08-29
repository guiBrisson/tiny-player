package api

import "core:log"
import "core:strings"
import lua "vendor:lua/5.4"
import sdl "vendor:sdl2"

window: ^sdl.Window

set_sdl_window :: proc(w: ^sdl.Window) {
	window = w
}

load_libs :: proc(L: ^lua.State) {
	libs: []lua.L_Reg = {{"system", lua_load_system}}

	for lib in libs {
		lua.L_requiref(L, lib.name, lib.func, 1)
	}
}

lua_bootstrap :: proc(L: ^lua.State) {
	// TODO: the executable name will be different for linux (not have .exe, basically)
	exename := "tiny-player.exe"
	lua.pushstring(L, strings.clone_to_cstring(exename))
	lua.setglobal(L, "EXEFILE")

	code := `
local core
xpcall(function()
    EXEDIR = EXEFILE:match("^(.+)[/\\].*$") or "."
    package.path = EXEDIR .. '/data/?.lua;' .. package.path
    package.path = EXEDIR .. '/data/?/init.lua;' .. package.path
    core = require("core")
    core.load()
end, function(err)
    print("Lua error: "..tostring(err))
    print(debug.traceback(nil, 2))
    if core and core.on_error then
        pcall(core.on_error, err)
    end
    os.exit(1)
end)`


	if lua.L_dostring(L, strings.clone_to_cstring(code)) != 0 {
		err := lua.tostring(L, -1)
		log.errorf("Lua bootstrap failed: %s\n", err)
	}
}
