package tiny_player

import "api"
import "core:fmt"
import "core:log"
import "core:os"
import "core:strings"
import lua "vendor:lua/5.4"
import sdl "vendor:sdl2"
import ttf "vendor:sdl2/ttf"

WINDOW_TITLE :: "Tiny Player"
WINDOW_X := i32(100)
WINDOW_Y := i32(100)
WINDOW_WIDTH := i32(800)
WINDOW_HEIGHT := i32(600)
WINDOW_FLAGS :: sdl.WindowFlags{.SHOWN, .RESIZABLE}

CTX :: struct {
	window:       ^sdl.Window,
	renderer:     ^sdl.Renderer,
	should_close: bool,
}

ctx := CTX{}

init_sdl :: proc() -> (ok: bool) {
	if sdl_res := sdl.Init(sdl.INIT_VIDEO); sdl_res < 0 {
		log.errorf("sdl.Init return %v", sdl_res)
		return false
	}

	if ttf_res := ttf.Init(); ttf_res < 0 {
		log.errorf("ttf.Init return %v", ttf_res)
		return false
	}

	ctx.window = sdl.CreateWindow(
		WINDOW_TITLE,
		WINDOW_X,
		WINDOW_Y,
		WINDOW_WIDTH,
		WINDOW_HEIGHT,
		WINDOW_FLAGS,
	)
	if ctx.window == nil {
		log.errorf("sdl.CreateWindow failed.")
		return false
	}

	ctx.renderer = sdl.CreateRenderer(ctx.window, -1, {.ACCELERATED, .PRESENTVSYNC})
	if ctx.renderer == nil {
		log.errorf("sdl.CreateRenderer failed.")
		return false
	}

	return true
}

cleanup :: proc() {
	ttf.Quit()
	sdl.DestroyWindow(ctx.window)
	sdl.Quit()
}

process_input :: proc() {
	e: sdl.Event

	for sdl.PollEvent(&e) {
		#partial switch (e.type) {
		case .QUIT:
			ctx.should_close = true
		case .KEYDOWN:
			#partial switch (e.key.keysym.sym) {
			case .ESCAPE:
				ctx.should_close = true
			}
		}
	}
}

draw :: proc() {
	sdl.RenderClear(ctx.renderer)
	sdl.RenderPresent(ctx.renderer)
}

main_loop :: proc() {
	for !ctx.should_close {
		process_input()
		//update
		draw()
	}
}

main :: proc() {
	context.logger = log.create_console_logger()

	L: ^lua.State = lua.L_newstate()
	defer lua.close(L)

	lua.L_openlibs(L)
	api.load_libs(L)

	code := "core.print_console('Hello from Lua!')"
	if lua.L_dostring(L, strings.clone_to_cstring(code)) != 0 {
		err := lua.tostring(L, -1)
		fmt.println("Lua error:", strings.clone_from_cstring(err))
	}

	if res := init_sdl(); !res {
		log.errorf("Initialization failed.")
		os.exit(1)
	}

	main_loop()

	defer cleanup()
}
