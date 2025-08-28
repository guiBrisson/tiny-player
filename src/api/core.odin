package api

import "base:runtime"
import "core:c/libc"
import "core:fmt"
import "core:strings"
import lua "vendor:lua/5.4"


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

lua_load_core :: proc "c" (L: ^lua.State) -> i32 {
	context = runtime.default_context()

	lib: []lua.L_Reg = {
        { "print_console", print_console }
    }

	lua.L_newlib(L, lib)
	return 1
}
