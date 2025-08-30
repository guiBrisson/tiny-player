local core = {}

local Text = require 'data.core.Text'
local color = require 'data.core.color'

local theme = {"#272829", "#D8D9DA"}

function core.load()
    system.show_window()
    FONT = gfx.load_font("data/assets/fonts/BoldPixels1.4.ttf", 28, "bold_pixels_24")
    FPS = Text.new(FONT)
end

function core.update(dt)
    local windowW, windowH = system.get_window_size()

    local fps = string.format("FPS: %.1f", 1 / dt)
    FPS:set_text(fps):set_position(windowW - FPS.width, 0)
end

function core.draw()
    local r, g, b = color.hex_to_rgb(theme[1])
    gfx.set_color(r, g, b, 255)
    gfx.draw_rect(10, 10, 100, 100)

    gfx.set_color(255, 255, 0, 255)
    gfx.draw_rect(120, 10, 100, 100, "line")

    local red = { 255, 0, 0, 255 }
    local hello_mom = Text.new(FONT, "Hello, mom", 300, 100, red)

    FPS:draw()
    hello_mom:draw()
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
