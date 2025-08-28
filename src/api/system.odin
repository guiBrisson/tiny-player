package api

import "base:runtime"
import "core:c/libc"
import lua "vendor:lua/5.4"
import sdl "vendor:sdl2"

print_console :: proc "c" (L: ^lua.State) -> i32 {
	argc := lua.gettop(L)

	if argc > 0 {
		msg := lua.tostring(L, 1)
		if msg != nil {
			libc.printf("Lua says: %s", msg)
		}
	}

	return 0
}

set_window_title :: proc "c" (L: ^lua.State) -> i32 {
    title := lua.L_checkstring(L, 1)
    sdl.SetWindowTitle(window, title)
    return 0
}

lua_load_system :: proc "c" (L: ^lua.State) -> i32 {
	context = runtime.default_context()

	lib: []lua.L_Reg = {
        { "print_console", print_console },
        { "set_window_title", set_window_title },
    }

	lua.L_newlib(L, lib)
	return 1
}
