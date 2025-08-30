local core = {}

function core.load()
    system.show_window()
    FONT = gfx.load_font("data/assets/fonts/BoldPixels1.4.ttf", 28, "bold_pixels_24")
end

function core.draw()
    gfx.set_color(0, 255, 250, 255)
    gfx.draw_rect(10, 10, 100, 100)

    gfx.set_color(255, 255, 0, 255)
    gfx.draw_rect(120, 10, 100, 100, "line")

    gfx.draw_text(FONT, "Hello, Mom!", 300, 100)

    local windowW, windowH = system.get_window_size()
    local fpsW, fpsH = gfx.get_text_size(FONT, FPS)
    gfx.draw_text_colored(FONT, FPS, windowW - fpsW, 0, 250, 250, 250, 120)
end

function core.update(dt)
    FPS = string.format("FPS: %.1f", 1 / dt)
    -- print("fps: " .. fps)
end

function core.on_keydown(key)
    -- print(key)
end

function core.on_mousedown(button, x, y)
    -- print(button, x, y)
end

function core.on_mouseup(button, x, y)
    -- print(button, x, y)
end

function core.on_dropfile(file)
    -- print(file)
end

function core.on_error(err)
    -- write error to file
    local fp = io.open(EXEDIR .. "/error.txt", "wb")
    if fp == nil then return end
    fp:write("Error: " .. tostring(err) .. "\n")
    fp:write(debug.traceback(nil, 4))
    fp:close()
    -- save copy of all unsaved documents
    for _, doc in ipairs(core.docs) do
        if doc:is_dirty() and doc.filename then
            doc:save(doc.filename .. "~")
        end
    end
end

return core
