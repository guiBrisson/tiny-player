local ecs = require 'data.lib.tiny'
local color = require 'data.core.color'

local drawTextSystem = ecs.processingSystem()
drawTextSystem.filter = ecs.requireAll("view", "text")
drawTextSystem.drawSystem = true

local function calculateTextSize(entity)
    local text = entity.text
    local view = entity.view
    local w, h = gfx.getTextSize(text.font_id, text.text)
    view.width = w
    view.height = h
end

function drawTextSystem:process(entity)
    local view = entity.view
    local text = entity.text

    if text._changed then
        calculateTextSize(entity)
        text._changed = false
    end

    if view.visible then
        local r, g, b, a = color.hex_to_rgba(text.color)
        gfx.drawTextColored(
            text.font_id,
            text.text,
            view.x,
            view.y,
            r, g, b, a
        )
    end
end

function drawTextSystem:onAdd(entity)
    calculateTextSize(entity)
end

return drawTextSystem
