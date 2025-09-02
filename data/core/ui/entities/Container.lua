local view = require "data.core.ui.components.view"
local hover = require "data.core.ui.components.hover"

local Container = {}
Container.__index = Container

Container.Direction = {
    ROW = 1,
    COLUMN = 2,
}

Container.JustifyContent = {
    FLEX_START = 1,
    FLEX_END = 2,
    CENTER = 3,
    SPACE_BETWEEN = 4,
    SPACE_AROUND = 5,
    SPACE_EVENLY = 6,
}

Container.AlignItems = {
    STRETCH = 1,
    FLEX_START = 2,
    FLEX_END = 3,
    CENTER = 4,
    BASELINE = 5,
}

function Container.new(args)
    local viewComponent = view.new({
        x = args.x,
        y = args.y,
        width = args.width,
        height = args.height,
        visible = args.visible or true,
    })

    local hoverComponent = hover.new(args.onHover)

    local container = {
        view = viewComponent,
        hover = hoverComponent,
        container = {
            direction = args.direction or Container.Direction.ROW,
            justifyContent = args.justifyContent or Container.JustifyContent.FLEX_START,
            alignItems = args.alignItems or Container.AlignItems.STRETCH,
            gap = args.gap or 0,
            padding = args.padding or {
                top = 0, right = 0, bottom = 0, left = 0,
            },
            autoWidth = args.autoWidth or false,
            autoHeight = args.autoHeight or false,
            fillWidth = args.fillWidth or false,
            fillHeight = args.fillHeight or false,
            children = args.children or {},
        },
    }

    if not args.width then
        container.container.autoWidth = true
    end

    if not args.height then
        container.container.autoHeight = true
    end

    if type(container.container.padding) == "number" then
        local p = container.container.padding
        container.container.padding = { top = p, right = p, bottom = p, left = p }
    end

    container.container._layoutCache = {
        contentWidth = 0,
        contentHeight = 0,
        childSizes = {}
    }

    return setmetatable(container, Container)
end

return Container
