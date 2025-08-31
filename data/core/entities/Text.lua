local view = require "data.core.components.view"
local hover = require "data.core.components.hover"

local Text = {}
Text.__index = Text

function Text.new(args)
    local viewComponent = view.new({
        x = args.x,
        y = args.y,
        visible = args.visible,
    })

    local hoverComponent = hover.new(args.onHover)

    local text = {
        view = viewComponent,
        hover = hoverComponent,
        text = {
            font_id = args.font_id,
            color = args.color or "#FFFFFFFF", --defaults to white
            text = args.text or "",
        }
    }
    return setmetatable(text, Text)
end

---@param text string
function Text:set_text(text)
    self.text.text = text
    self.text._changed = true
end

return Text
