package api

import "core:fmt"
import "core:log"
import "core:strings"
import lua "vendor:lua/5.4"
import sdl "vendor:sdl2"


@(private)
safe_dostring :: proc(L: ^lua.State, string, fn_call: string) {
	c_string := strings.clone_to_cstring(string)
	defer delete(c_string)

	if lua.L_dostring(L, c_string) != 0 {
		err := lua.tostring(L, -1)
		log.errorf("Lua %s failed: %s\n", fn_call, err)
	}
}

@(private)
keycode_name :: proc(key: sdl.Keycode, allocator := context.allocator) -> string {
	key_name_cstr := sdl.GetKeyName(key)
	key_name_str := string(key_name_cstr)

	return strings.to_lower(key_name_str, allocator)
}

@(private)
button_name :: proc(button: u8) -> string {
	switch button {
	case 1:
		return "left"
	case 2:
		return "middle"
	case 3:
		return "right"
	case 4:
		return "XButton1"
	case 5:
		return "XButton2"
	case:
		return "?"
	}
}

lua_draw :: proc(L: ^lua.State) {
	code := "local core = require('core'); pcall(function() core.draw() end)"
	safe_dostring(L, code, "draw")
}

lua_update :: proc(L: ^lua.State, dt: f64) {
	code := fmt.tprintf("local core = require('core'); pcall(function() core.update(%f) end)", dt)
	safe_dostring(L, code, "update")
}

lua_keydown :: proc(L: ^lua.State, key: sdl.Keycode) {
	key_str := keycode_name(key)
	defer delete(key_str)

	code := fmt.tprintf(
		`local core = require('core'); pcall(function() core.on_keydown("%s") end)`,
		key_str,
	)

	safe_dostring(L, code, "on_keydown")
}

lua_mousedown :: proc(L: ^lua.State, button: u8, x, y: i32) {
	button_name := button_name(button)

	code := fmt.tprintf(
		`local core = require('core'); pcall(function() core.on_mousedown("%s", %i, %i) end)`,
		button_name,
		x,
		y,
	)

	safe_dostring(L, code, "on_mousedown")
}

lua_mouseup :: proc(L: ^lua.State, button: u8, x, y: i32) {
	button_name := button_name(button)

	code := fmt.tprintf(
		`local core = require('core'); pcall(function() core.on_mouseup("%s", %i, %i) end)`,
		button_name,
		x,
		y,
	)

	safe_dostring(L, code, "on_mouseup")
}

lua_dropfile :: proc(L: ^lua.State, file: cstring) {
	file_str := strings.clone_from_cstring(file)
	defer delete(file_str)

	// Escape backslashes for Lua
	escaped_file, _ := strings.replace_all(file_str, `\`, `\\`)
	defer delete(escaped_file)

	code := fmt.tprintf(
		`local core = require('core'); pcall(function() core.on_dropfile("%s") end)`,
		escaped_file,
	)

	safe_dostring(L, code, "on_dropfile")
}
