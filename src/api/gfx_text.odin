package api

import "core:hash"
import "core:log"
import "core:strings"
import sdl "vendor:sdl2"
import ttf "vendor:sdl2/ttf"

@(private)
Font_Cache_Entry :: struct {
	font: ^ttf.Font,
	size: i32,
	path: string,
}

@(private)
Text_Cache_Entry :: struct {
	texture: ^sdl.Texture,
	width:   i32,
	height:  i32,
}

@(private)
Text_Cache_Key :: struct {
	font_id: string,
	text:    string,
	color:   sdl.Color,
}

@(private)
font_cache: map[string]Font_Cache_Entry

@(private)
text_cache: map[u64]Text_Cache_Entry

init_font_system :: proc() -> bool {
	if ttf_res := ttf.Init(); ttf_res < 0 {
		log.errorf("ttf.Init return %v", ttf_res)
		return false
	}

	font_cache = make(map[string]Font_Cache_Entry)
	text_cache = make(map[u64]Text_Cache_Entry)
	return true
}

cleanup_font_system :: proc() {
	for id, entry in font_cache {
		if entry.font != nil {
			ttf.CloseFont(entry.font)
		}
		delete_key(&font_cache, id)
	}
	delete(font_cache)

	for key, entry in text_cache {
		if entry.texture != nil {
			sdl.DestroyTexture(entry.texture)
		}
		delete_key(&text_cache, key)
	}
	delete(text_cache)

	ttf.Quit()
}

@(private)
load_font :: proc(font_path: string, size: i32, font_id: string) -> bool {
	if font_id in font_cache {
		existing := font_cache[font_id]
		if existing.font != nil {
			ttf.CloseFont(existing.font)
		}
	}

	c_path := strings.clone_to_cstring(font_path, context.temp_allocator)
	defer delete(c_path, context.temp_allocator)

	font := ttf.OpenFont(c_path, size)
	if font == nil {
		return false
	}

	font_cache[font_id] = Font_Cache_Entry {
		font = font,
		size = size,
		path = strings.clone(font_path),
	}
	return true
}

@(private)
get_font :: proc(font_id: string) -> ^ttf.Font {
	if entry, exists := font_cache[font_id]; exists {
		return entry.font
	}
	return nil
}

@(private)
unload_font :: proc(font_id: string) -> bool {
	if entry, exists := font_cache[font_id]; exists {
		if entry.font != nil {
			ttf.CloseFont(entry.font)
		}
		delete(entry.path)
		delete_key(&font_cache, font_id)
		return true
	}
	return false
}

@(private)
font_exists :: proc(font_id: string) -> bool {
	_, exists := font_cache[font_id]
	return exists
}

@(private)
get_font_info :: proc(font_id: string) -> (i32, string, bool) {
	if entry, exists := font_cache[font_id]; exists {
		return entry.size, entry.path, exists
	}
	return 0, "", false
}

@(private)
generate_text_cache_key :: proc(font_id, text: string, color: sdl.Color) -> u64 {
	h: u64 = 0

	// Hash font_id
	if len(font_id) > 0 {
		font_id_bytes := transmute([]u8)font_id
		h = hash.crc64_ecma_182(font_id_bytes, h)
	}

	// Hash text
	if len(text) > 0 {
		text_bytes := transmute([]u8)text
		h = hash.crc64_ecma_182(text_bytes, h)
	}

	// Hash color
	color_bytes := transmute([4]u8)color
	h = hash.crc64_ecma_182(color_bytes[:], h)

	return h
}

@(private)
create_text_texture :: proc(
	font: ^ttf.Font,
	text: string,
	color: sdl.Color,
) -> (
	^sdl.Texture,
	i32,
	i32,
) {
	if font == nil || renderer == nil {
		return nil, 0, 0
	}

	c_text := strings.clone_to_cstring(text, context.temp_allocator)
	defer delete(c_text, context.temp_allocator)

	surface := ttf.RenderText_Solid(font, c_text, color)
	if surface == nil {
		return nil, 0, 0
	}
	defer sdl.FreeSurface(surface)

	texture := sdl.CreateTextureFromSurface(renderer, surface)
	if texture == nil {
		return nil, 0, 0
	}

	return texture, surface.w, surface.h
}

@(private)
get_cached_text :: proc(
	font_id, text: string,
	color: sdl.Color,
) -> (
	^sdl.Texture,
	i32,
	i32,
	bool,
) {
	cache_key := generate_text_cache_key(font_id, text, color)

	if entry, exists := text_cache[cache_key]; exists {
		return entry.texture, entry.width, entry.height, true
	}

	font := get_font(font_id)
	if font == nil {
		return nil, 0, 0, false
	}

	texture, width, height := create_text_texture(font, text, color)
	if texture == nil {
		return nil, 0, 0, false
	}

	text_cache[cache_key] = Text_Cache_Entry {
		texture = texture,
		width   = width,
		height  = height,
	}

	return texture, width, height, true
}

current_text_color := sdl.Color{255, 255, 255, 255}

@(private)
set_text_color :: proc(r, g, b, a: u8) {
	current_text_color = sdl.Color{r, g, b, a}
}

@(private)
draw_text_colored :: proc(font_id, text: string, x, y: i32, r, g, b, a: u8) -> bool {
	if renderer == nil {
		return false
	}

	color := sdl.Color{r, g, b, a}
	texture, width, height, success := get_cached_text(font_id, text, color)

	if !success || texture == nil {
		return false
	}

	dst_rect := sdl.Rect {
		x = x,
		y = y,
		w = width,
		h = height,
	}

	result := sdl.RenderCopy(renderer, texture, nil, &dst_rect)
	return result == 0
}

@(private)
draw_text :: proc(font_id, text: string, x, y: i32) -> bool {
	return draw_text_colored(
		font_id,
		text,
		x,
		y,
		current_text_color.r,
		current_text_color.g,
		current_text_color.b,
		current_text_color.a,
	)
}

@(private)
get_text_size :: proc(font_id, text: string) -> (width, height: i32, success: bool) {
	dummy_color := sdl.Color{255, 255, 255, 255}
	_, w, h, ok := get_cached_text(font_id, text, dummy_color)
	return w, h, ok
}
