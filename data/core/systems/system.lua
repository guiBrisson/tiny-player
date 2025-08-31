local ecs = require 'data.lib.tiny'

local hoverSystem = ecs.processingSystem()
hoverSystem.filter = ecs.requireAll("view", "hover")

function hoverSystem:process(entity, _)
    local view = entity.view
    local hover = entity.hover

    local mouseInBounds = Mouse.x >= view.x and Mouse.x <= view.x + view.width and
        Mouse.y >= view.y and Mouse.y + view.y + view.height

    hover.isHovered = mouseInBounds

    if mouseInBounds and hover.onHover then
        hover.onHover()
    end
end

return hoverSystem
