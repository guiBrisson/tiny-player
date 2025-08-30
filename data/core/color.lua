local color = {}

---Transforms a hexadecimal color to a red, green and blue values.
---e.g. #ff0000 -> 255, 0, 0
---@param hex string hexadecimal
---@return integer r
---@return integer g 
---@return integer b
---@return integer a
function color.hex_to_rgba(hex)
    local hex = string.gsub(hex, "#", "")

    local a = tonumber(hex:sub(1, 2), 16)
    local r = tonumber(hex:sub(3, 4), 16)
    local g = tonumber(hex:sub(5, 6), 16)
    local b = tonumber(hex:sub(7, 8), 16)

    return r, g, b, a
end

return color