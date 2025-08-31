local ecs = require 'data.lib.tiny'
local Container = require 'data.core.entities.Container'

local containerSystem = ecs.processingSystem()
containerSystem.drawSystem = true
containerSystem.filter = ecs.requireAll("view", "container")

local function positionChildren(entity)
    local container = entity.container
    if #container.children == 0 then return end

    local isRow = container.direction == Container.Direction.ROW
    local contentWidth = container._layoutCache.contentWidth
    local contentHeight = container._layoutCache.contentHeight
    local childSizes = container._layoutCache.childSizes

    -- Calculate total main size used by children
    local totalUsedMainSize = 0
    local visibleChildren = {}

    for i, child in ipairs(container.children) do
        if child.view.visible then
            table.insert(visibleChildren, { child = child, index = i })
            totalUsedMainSize = totalUsedMainSize + childSizes[i].main
            if #visibleChildren > 1 then
                totalUsedMainSize = totalUsedMainSize + container.gap
            end
        end
    end

    -- Calculate starting position and spacing
    local mainStart = container.padding.left
    local crossStart = container.padding.top
    local extraSpace = 0
    local spaceBetween = 0

    if isRow then
        extraSpace = math.max(0, contentWidth - totalUsedMainSize)
    else
        extraSpace = math.max(0, contentHeight - totalUsedMainSize)
        mainStart = container.padding.top
        crossStart = container.padding.left
    end

    -- Apply justify-content
    if container.justifyContent == Container.JustifyContent.FLEX_END then
        mainStart = mainStart + extraSpace
    elseif container.justifyContent == Container.JustifyContent.CENTER then
        mainStart = mainStart + extraSpace / 2
    elseif container.justifyContent == Container.JustifyContent.SPACE_BETWEEN then
        if #visibleChildren > 1 then
            spaceBetween = extraSpace / (#visibleChildren - 1)
        end
    elseif container.justifyContent == Container.JustifyContent.SPACE_AROUND then
        spaceBetween = extraSpace / #visibleChildren
        mainStart = mainStart + spaceBetween / 2
    elseif container.justifyContent == Container.JustifyContent.SPACE_EVENLY then
        spaceBetween = extraSpace / (#visibleChildren + 1)
        mainStart = mainStart + spaceBetween
    end

    -- Position each child
    local currentMainPos = mainStart

    for _, item in ipairs(visibleChildren) do
        local child = item.child
        local index = item.index
        local childSize = childSizes[index]

        -- Calculate cross-axis position
        local crossPos = crossStart
        local crossSize = isRow and contentHeight or contentWidth

        if container.alignItems == Container.AlignItems.FLEX_END then
            crossPos = crossPos + crossSize - childSize.cross
        elseif container.alignItems == Container.AlignItems.CENTER then
            crossPos = crossPos + (crossSize - childSize.cross) / 2
        elseif container.alignItems == Container.AlignItems.STRETCH then
            -- Stretch child to fill cross axis
            if isRow then
                child.view.height = crossSize
            else
                child.view.width = crossSize
            end
        end
        -- "flex-start" and "baseline" use crossPos as is (for now)

        -- Set child position
        if isRow then
            child.view.x = entity.view.x + currentMainPos
            child.view.y = entity.view.y + crossPos
        else
            child.view.x = entity.view.x + crossPos
            child.view.y = entity.view.y + currentMainPos
        end

        -- Move to next position
        currentMainPos = currentMainPos + childSize.main + container.gap + spaceBetween
    end
end

local function calculateLayout(entity)
    local container = entity.container
    local view = entity.view
    if #container.children == 0 then
        if container.autoWidth then view.width = container.padding.left + container.padding.right end
        if container.autoHeight then view.height = container.padding.top + container.padding.bottom end
        return
    end

    local isRow = container.direction == Container.Direction.ROW
    local contentWidth = view.width - container.padding.left - container.padding.right
    local contentHeight = view.height - container.padding.top - container.padding.bottom

    -- First pass: measure children and calculate required space
    local totalMainSize = 0
    local maxCrossSize = 0
    local childSizes = {}

    for i, child in ipairs(container.children) do
        if child.view.visible then
            -- If child is also a Container, calculate its layout first
            if child.container then
                calculateLayout(child)
            end

            local childMainSize, childCrossSize
            if isRow then
                childMainSize = child.view.width
                childCrossSize = child.view.height
            else
                childMainSize = child.view.height
                childCrossSize = child.view.width
            end

            childSizes[i] = { main = childMainSize, cross = childCrossSize }
            totalMainSize = totalMainSize + childMainSize
            maxCrossSize = math.max(maxCrossSize, childCrossSize)

            -- Add gap (except for last child)
            if i < #container.children then
                totalMainSize = totalMainSize + container.gap
            end
        end
    end

    -- Cache the calculations
    container._layoutCache.childSizes = childSizes

    -- Calculate auto-size if needed
    if container.autoWidth then
        if isRow then
            view.width = totalMainSize + container.padding.left + container.padding.right
        else
            view.width = maxCrossSize + container.padding.left + container.padding.right
        end
        contentWidth = view.width - container.padding.left - container.padding.right
    end

    if container.autoHeight then
        if isRow then
            view.height = maxCrossSize + container.padding.top + container.padding.bottom
        else
            view.height = totalMainSize + container.padding.top + container.padding.bottom
        end
        contentHeight = view.height - container.padding.top - container.padding.bottom
    end

    -- Store content dimensions
    container._layoutCache.contentWidth = contentWidth
    container._layoutCache.contentHeight = contentHeight

    -- Second pass: position children
    positionChildren(entity)
end

function containerSystem:process(entity, dt)
    local view = entity.view
    if false then -- change this to see the container bounds
        gfx.setColor(255, 255, 255, 255)
        gfx.drawRect(
            view.x, view.y,
            view.width, view.height,
            "line"
        )
    end
    calculateLayout(entity)
end

function containerSystem:onAdd(entity)
    calculateLayout(entity)
end

return containerSystem
