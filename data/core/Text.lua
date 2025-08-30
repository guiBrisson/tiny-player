---@class Text
---@field text string
---@field x number
---@field y number
---@field width number
---@field height number
---@field font_id string
---@field color table
local Text = {}
Text.__index = Text

---@param text Text
---@return number width
---@return number height
local function calculateTextSize(text)
    local w, h = gfx.get_text_size(text.font_id, text.text)
    return w, h
end

---@param font_id string
---@param text string | nil
---@param x number | nil
---@param y number | nil
---@param color table | nil
---@return Text
function Text.new(font_id, text, x, y, color)
    local obj = {
        text = text or "",
        x = x or 0,
        y = y or 0,
        width = 0,
        height = 0,
        font_id = font_id,
        color = color or { 255, 255, 255, 255 } -- white by default
    }

    obj.width, obj.height = calculateTextSize(obj)
    return setmetatable(obj, Text)
end

---@param text string
---@return Text
function Text:set_text(text)
    self.text = text
    self.width, self.height = calculateTextSize(self)
    return self
end

---@param font_id string
---@return Text
function Text:set_font_id(font_id)
    self.font_id = font_id
    self.width, self.height = calculateTextSize(self)
    return self
end

---@param color table
---@return Text
function Text:set_color(color)
    if type(color) ~= "table" then return self end
    self.color = color
    return self
end

---@param x number
---@param y number
---@return Text
function Text:set_position(x, y)
    self.x = x
    self.y = y
    return self
end

function Text:draw()
    gfx.draw_text_colored(
        self.font_id,
        self.text,
        self.x,
        self.y,
        table.unpack(self.color)
    )
end

return Text
