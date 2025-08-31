DEBUG = false
Mouse = { x = 0, y = 0 }
Window = { width = 0, height = 0 }

local core = {}

local ecs = require 'data.lib.tiny'
local Container = require 'data.core.entities.Container'
local Text = require 'data.core.entities.Text'
local world

function core.load()
    world = ecs.world()
    FONT = gfx.loadFont("data/assets/fonts/BoldPixels1.4.ttf", 18, "bold_pixels_24")

    Fps = Text.new({ font_id = FONT })

    local container = Container.new({
        direction = Container.Direction.COLUMN,
        alignItems = Container.AlignItems.FLEX_END,
        padding = 10,
        fillWidth = true,
        children = { Fps },
    })

    BaseContainer = Container.new({
        direction = Container.Direction.COLUMN,
        justifyContent = Container.JustifyContent.FLEX_START,
        alignItems = Container.AlignItems.FLEX_END,
        width = Window.width,
        height = Window.height,
        children = { container },
    })

    world:addEntity(BaseContainer)
    world:addEntity(Fps)
    world:addEntity(container)
    world:addSystem(require('data.core.systems.drawTextSystem'))
    world:addSystem(require('data.core.systems.hoverSystem'))
    world:addSystem(require('data.core.systems.containerSystem'))

    system.showWindow()
end

function core.update(dt)
    Mouse.x, Mouse.y = system.getMouseState()
    Window.width, Window.height = system.getWindowSize()

    local fps = 1 / dt
    Fps:set_text(string.format("FPS: %.2f", fps))

    BaseContainer.view.width = Window.width
    BaseContainer.view.height = Window.height

    world:update(dt, ecs.rejectAny("drawSystem"))
end

function core.draw()
    world:update(-1, ecs.requireAll("drawSystem"))
end

function core.on_keydown(key)
    if key == "f1" then
        DEBUG = not DEBUG
    end
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
