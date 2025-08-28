package tiny_player

import "api"
import "core:log"
import "core:os"
import lua "vendor:lua/5.4"
import sdl "vendor:sdl2"
import ttf "vendor:sdl2/ttf"


App_Context :: struct {
	window:       ^sdl.Window,
	renderer:     ^sdl.Renderer,
	should_close: bool,
	lua:          ^lua.State,
}

init_ctx :: proc() -> App_Context {
	ctx := App_Context{}

	if sdl_res := sdl.Init(sdl.INIT_VIDEO); sdl_res < 0 {
		log.errorf("sdl.Init return %v", sdl_res)
		os.exit(1)
	}

	if ttf_res := ttf.Init(); ttf_res < 0 {
		log.errorf("ttf.Init return %v", ttf_res)
		os.exit(1)
	}

	dm: sdl.DisplayMode
	sdl.GetCurrentDisplayMode(0, &dm)

	ctx.window = sdl.CreateWindow(
		"Tiny Player",
		sdl.WINDOWPOS_UNDEFINED,
		sdl.WINDOWPOS_UNDEFINED,
		i32(f32(dm.w) * 0.6),
		i32(f32(dm.h) * 0.6),
		{.SHOWN, .RESIZABLE, .ALLOW_HIGHDPI},
	)
	if ctx.window == nil {
		log.errorf("sdl.CreateWindow failed.")
		os.exit(1)
	}

	sdl.SetWindowMinimumSize(ctx.window, 756, 440)

	ctx.renderer = sdl.CreateRenderer(ctx.window, -1, {.ACCELERATED, .PRESENTVSYNC})
	if ctx.renderer == nil {
		log.errorf("sdl.CreateRenderer failed.")
		os.exit(1)
	}

	ctx.lua = lua.L_newstate()
	if ctx.lua == nil {
		log.errorf("lua.L_newstate failed.")
		os.exit(1)
	}
	lua.L_openlibs(ctx.lua)
	api.load_libs(ctx.lua)

	return ctx
}

cleanup_ctx :: proc(ctx: ^App_Context) {
	lua.close(ctx.lua)
	ttf.Quit()
	sdl.DestroyWindow(ctx.window)
	sdl.Quit()
}

process_input :: proc(ctx: ^App_Context) {
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

draw :: proc(ctx: ^App_Context) {
	sdl.RenderClear(ctx.renderer)
	sdl.RenderPresent(ctx.renderer)
}

main_loop :: proc(ctx: ^App_Context) {
	for !ctx.should_close {
		process_input(ctx)
		//update(dt)
		draw(ctx)
	}
}

main :: proc() {
	context.logger = log.create_console_logger()

	ctx: App_Context = init_ctx()
	defer cleanup_ctx(&ctx)

	api.set_sdl_window(ctx.window)
	api.lua_bootstrap(ctx.lua)

	main_loop(&ctx)
}
