local view = {}

local id_counter = 0

local function generate_id()
    id_counter = id_counter + 1
    return "view_" .. id_counter
end

function view.new(args)
    return {
        id = args.id or generate_id(),
        x = args.x or 0,
        y = args.y or 0,
        width = args.width or 0,
        height = args.width or 0,
        visible = args.visible ~= false, -- default true
    }
end

return view