package api

import lua "vendor:lua/5.4"

load_libs :: proc(L: ^lua.State) {
	libs: []lua.L_Reg = {{"core", lua_load_core}}

	for lib in libs {
		lua.L_requiref(L, lib.name, lib.func, 1)
	}
}
