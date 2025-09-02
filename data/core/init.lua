DEBUG = false
Mouse = { x = 0, y = 0 }
Window = { width = 0, height = 0 }

local core = {}

local Container = require 'data.core.ui.entities.Container'
local Text = require 'data.core.ui.entities.Text'
local Ui = require 'data.core.ui'

local UI

local theme = {
    fonts = {
        small = gfx.loadFont("data/assets/fonts/BoldPixels1.4.ttf", 16, "bold_pixels_16"),
        normal = gfx.loadFont("data/assets/fonts/BoldPixels1.4.ttf", 20, "bold_pixels_20"),
        large = gfx.loadFont("data/assets/fonts/BoldPixels1.4.ttf", 24, "bold_pixels_24"),
    },
    colors = { light = "#ff272829", dark = "#ffD8D9DA" }
}

function core.load()
    Fps = Text.new({ font_id = theme.fonts.small })

    local container = Container.new({
        direction = Container.Direction.COLUMN,
        alignItems = Container.AlignItems.FLEX_END,
        padding = 10,
        fillWidth = true,
        children = { Fps },
    })

    local container2 = Container.new({
        direction = Container.Direction.COLUMN,
        alignItems = Container.AlignItems.FLEX_START,
        fillWidth = true,
        fillHeight = true,
        padding = 10,
        children = {
            Text.new({ font_id = theme.fonts.normal, text = "Hello, World!" }),
            Text.new({ font_id = theme.fonts.normal, text = "Hello, Mom!" })
        }
    })

    BaseContainer = Container.new({
        direction = Container.Direction.COLUMN,
        justifyContent = Container.JustifyContent.FLEX_START,
        alignItems = Container.AlignItems.FLEX_START,
        width = 0,
        height = 0,
        children = { container, container2 },
    })

    UI = Ui.load({ views = { BaseContainer } })

    system.showWindow()
end

function core.update(dt)
    Mouse.x, Mouse.y = system.getMouseState()
    Window.width, Window.height = system.getWindowSize()

    BaseContainer.view.width = Window.width
    BaseContainer.view.height = Window.height

    local fps = 1 / dt
    Fps:setText(string.format("FPS: %.2f", fps))

    UI:update(dt)
end

function core.draw()
    local r, g, b, a = require('data.core.color').hexToRgba(theme.colors.dark)
    gfx.setColor(r, g, b, a)
    UI:draw()
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
