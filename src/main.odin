package tiny_player

import "api"
import "core:log"
import "core:os"
import lua "vendor:lua/5.4"
import sdl "vendor:sdl2"


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

	api.init_font_system()

	dm: sdl.DisplayMode
	sdl.GetCurrentDisplayMode(0, &dm)

	ctx.window = sdl.CreateWindow(
		"Tiny Player",
		sdl.WINDOWPOS_UNDEFINED,
		sdl.WINDOWPOS_UNDEFINED,
		i32(f32(dm.w) * 0.6),
		i32(f32(dm.h) * 0.6),
		{.HIDDEN, .RESIZABLE, .ALLOW_HIGHDPI},
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
	api.cleanup_font_system()
	sdl.DestroyWindow(ctx.window)
	sdl.Quit()
}

process_input :: proc(ctx: ^App_Context) {
	e: sdl.Event

	for sdl.PollEvent(&e) {
		#partial switch (e.type) {
		case .QUIT:
			ctx.should_close = true
		case .DROPFILE:
			api.lua_dropfile(ctx.lua, e.drop.file)
		case .KEYDOWN:
			api.lua_keydown(ctx.lua, e.key.keysym.sym)
		case .MOUSEBUTTONDOWN:
			api.lua_mousedown(ctx.lua, e.button.button, e.button.x, e.button.y)
		case .MOUSEBUTTONUP:
			api.lua_mouseup(ctx.lua, e.button.button, e.button.x, e.button.y)
		}
	}
}

draw :: proc(ctx: ^App_Context) {
	sdl.SetRenderDrawColor(ctx.renderer, 0, 0, 0, 255)
	sdl.RenderClear(ctx.renderer)
	api.lua_draw(ctx.lua)
	sdl.RenderPresent(ctx.renderer)
}

update :: proc(ctx: ^App_Context, dt: f64) {
	api.lua_update(ctx.lua, dt)
}

main_loop :: proc(ctx: ^App_Context) {
	lastFrameTick: u64
	deltaTime: f64
	performanceFrequency := sdl.GetPerformanceFrequency()

	for !ctx.should_close {
		currentFrameTicks := sdl.GetPerformanceCounter()

		deltaTime = f64(currentFrameTicks - lastFrameTick) / f64(performanceFrequency)
		lastFrameTick = currentFrameTicks

		process_input(ctx)
		update(ctx, deltaTime)
		draw(ctx)
	}
}

main :: proc() {
	context.logger = log.create_console_logger()

	ctx: App_Context = init_ctx()
	defer cleanup_ctx(&ctx)

	api.set_sdl_window_and_renderer(ctx.window, ctx.renderer)
	api.lua_bootstrap(ctx.lua)

	main_loop(&ctx)
}
