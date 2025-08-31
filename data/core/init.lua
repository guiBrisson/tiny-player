Mouse = { x = 0, y = 0 }

local core = {}

local ecs = require 'data.lib.tiny'
local world

function core.load()
    world = ecs.world()
    FONT = gfx.loadFont("data/assets/fonts/BoldPixels1.4.ttf", 18, "bold_pixels_24")

    Fps = require('data.core.entities.Text').new({
        x = 10,
        y = 10,
        font_id = FONT,
    })

    world:addEntity(Fps)
    local hoverSystem = require 'data.core.systems.hoverSystem'
    world:addSystem(hoverSystem)
    world:addSystem(require('data.core.systems.drawTextSystem'))

    system.showWindow()
end

function core.update(dt)
    Mouse.x, Mouse.y = system.getMouseState()

    local fps = 1 / dt
    Fps:set_text(string.format("FPS: %.2f", fps))

    world:update(dt, ecs.rejectAny("drawSystem"))
end

function core.draw()
    world:update(-1, ecs.requireAll("drawSystem"))
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
