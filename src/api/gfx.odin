package api

import "base:runtime"
import "core:strings"
import lua "vendor:lua/5.4"
import sdl "vendor:sdl2"

@(private)
lua_draw_rect :: proc "c" (L: ^lua.State) -> i32 {
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

@(private)
lua_set_color :: proc "c" (L: ^lua.State) -> i32 {
	r := u8(lua.L_checkinteger(L, 1))
	g := u8(lua.L_checkinteger(L, 2))
	b := u8(lua.L_checkinteger(L, 3))
	a := u8(lua.L_checkinteger(L, 4))

	sdl.SetRenderDrawColor(renderer, r, g, b, a)
	return 0
}

@(private)
lua_load_font :: proc "c" (L: ^lua.State) -> i32 {
	context = runtime.default_context()

	filename := string(lua.L_checkstring(L, 1))
	size := i32(lua.L_checknumber(L, 2))
	font_id := string(lua.L_checkstring(L, 3))

	if !load_font(filename, size, font_id) {
		lua.L_error(L, "failed to load font")
		return 0
	}

	lua.pushstring(L, strings.clone_to_cstring(font_id, context.temp_allocator))
	return 1
}

@(private)
lua_draw_text :: proc "c" (L: ^lua.State) -> i32 {
	context = runtime.default_context()

	font_id := string(lua.L_checkstring(L, 1))
	text := string(lua.L_checkstring(L, 2))
	x := i32(lua.L_checknumber(L, 3))
	y := i32(lua.L_checknumber(L, 4))

	if !draw_text(font_id, text, x, y) {
		lua.L_error(L, "failed to draw text")
	}

	return 0
}

@(private)
lua_draw_text_colored :: proc "c" (L: ^lua.State) -> i32 {
	context = runtime.default_context()

	font_id := string(lua.L_checkstring(L, 1))
	text := string(lua.L_checkstring(L, 2))
	x := i32(lua.L_checknumber(L, 3))
	y := i32(lua.L_checknumber(L, 4))
	r := u8(lua.L_checknumber(L, 5))
	g := u8(lua.L_checknumber(L, 6))
	b := u8(lua.L_checknumber(L, 7))
	a := u8(lua.L_checknumber(L, 8))

	if !draw_text_colored(font_id, text, x, y, r, g, b, a) {
		lua.L_error(L, "failed to draw text")
	}

	return 0
}

@(private)
lua_get_text_size :: proc "c" (L: ^lua.State) -> i32 {
	context = runtime.default_context()

	font_id := string(lua.L_checkstring(L, 1))
	text := string(lua.L_checkstring(L, 2))

	width, height, success := get_text_size(font_id, text)

	if !success {
		lua.pushnil(L)
		lua.pushnil(L)
		return 2
	}

	lua.pushinteger(L, lua.Integer(width))
	lua.pushinteger(L, lua.Integer(height))
	return 2
}

@(private)
lua_set_text_color :: proc "c" (L: ^lua.State) -> i32 {
	context = runtime.default_context()

	r := u8(lua.L_checknumber(L, 1))
	g := u8(lua.L_checknumber(L, 2))
	b := u8(lua.L_checknumber(L, 3))
	a := u8(lua.L_checknumber(L, 4))

	set_text_color(r, g, b, a)
	return 0
}

lua_load_gfx :: proc "c" (L: ^lua.State) -> i32 {
	context = runtime.default_context()

	lib: []lua.L_Reg = {
		{"drawRect", lua_draw_rect},
		{"setColor", lua_set_color},
		{"loadFont", lua_load_font},
		{"drawText", lua_draw_text},
		{"drawTextColored", lua_draw_text_colored},
		{"getTextSize", lua_get_text_size},
		{"setTextColor", lua_set_text_color},
	}

	lua.L_newlib(L, lib)
	return 1
}
