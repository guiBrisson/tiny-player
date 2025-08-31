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

@(private)
lua_get_window_size :: proc "c" (L: ^lua.State) -> i32 {
	width, height: i32
	sdl.GetWindowSize(window, &width, &height)

	lua.pushinteger(L, lua.Integer(width))
	lua.pushinteger(L, lua.Integer(height))
	return 2
}

@(private)
lua_show_window :: proc "c" (L: ^lua.State) -> i32 {
	sdl.ShowWindow(window)
	return 0
}

@(private)
lua_get_mouse_state :: proc "c" (L: ^lua.State) -> i32 {
	x, y: i32
	sdl.GetMouseState(&x, &y)

	lua.pushinteger(L, lua.Integer(x))
	lua.pushinteger(L, lua.Integer(y))
	return 2
}

lua_load_system :: proc "c" (L: ^lua.State) -> i32 {
	context = runtime.default_context()

	lib: []lua.L_Reg = {
		{"set_window_title", lua_set_window_title},
		{"get_window_size", lua_get_window_size},
		{"show_window", lua_show_window},
		{"get_mouse_state", lua_get_mouse_state},
	}

	lua.L_newlib(L, lib)
	return 1
}
