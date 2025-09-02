local UI = {}
UI.__index = UI

local ecs = require 'data.lib.tiny'

local function addAllViewEntities(world, views)
    for _, view in ipairs(views) do
        if view.container and view.container.children and #view.container.children > 0 then
            addAllViewEntities(world, view.container.children)
        end
        world:addEntity(view)
    end
end

function UI.load(args)
    local world = ecs.world()

    local ui = {
        world = world,
        views = args.views or {},
    }

    world:addSystem(require('data.core.ui.systems.containerSystem'))
    world:addSystem(require('data.core.ui.systems.drawTextSystem'))
    world:addSystem(require('data.core.ui.systems.hoverSystem'))

    addAllViewEntities(world, ui.views)

    return setmetatable(ui, UI)
end

function UI:draw()
    self.world:update(-1, ecs.requireAll("drawSystem"))
end

function UI:update(dt)
    self.world:update(dt, ecs.rejectAny("drawSystem"))
end

return UI
