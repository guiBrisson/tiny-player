package api

import "base:runtime"
import lua "vendor:lua/5.4"
import sdl "vendor:sdl2"

draw_rect :: proc "c" (L: ^lua.State) -> i32 {
	rect: sdl.FRect
	rect.x = f32(lua.L_checknumber(L, 1))
	rect.y = f32(lua.L_checknumber(L, 2))
	rect.w = f32(lua.L_checknumber(L, 3))
	rect.h = f32(lua.L_checknumber(L, 4))

	mode := "fill"
	if lua.gettop(L) >= 5 {
		mode_cstr := lua.L_checkstring(L, 5)
		mode = string(mode_cstr)
	}

	switch mode {
	case "fill":
		sdl.RenderFillRectF(renderer, &rect)
	case "line":
		sdl.RenderDrawRectF(renderer, &rect)
	case:
		sdl.RenderFillRectF(renderer, &rect)
	}

	return 0
}

set_color :: proc "c" (L: ^lua.State) -> i32 {
	r := u8(lua.L_checkinteger(L, 1))
	g := u8(lua.L_checkinteger(L, 2))
	b := u8(lua.L_checkinteger(L, 3))
	a := u8(lua.L_checkinteger(L, 4))

	sdl.SetRenderDrawColor(renderer, r, g, b, a)
	return 0
}

lua_load_gfx :: proc "c" (L: ^lua.State) -> i32 {
	context = runtime.default_context()

	lib: []lua.L_Reg = {{"draw_rect", draw_rect}, {"set_color", set_color}}

	lua.L_newlib(L, lib)
	return 1
}
