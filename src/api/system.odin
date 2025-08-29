package api

import "base:runtime"
import lua "vendor:lua/5.4"
import sdl "vendor:sdl2"

@(private)
lua_set_window_title :: proc "c" (L: ^lua.State) -> i32 {
	title := lua.L_checkstring(L, 1)
	sdl.SetWindowTitle(window, title)
	return 0
}

lua_load_system :: proc "c" (L: ^lua.State) -> i32 {
	context = runtime.default_context()

	lib: []lua.L_Reg = {{"set_window_title", lua_set_window_title}}

	lua.L_newlib(L, lib)
	return 1
}
