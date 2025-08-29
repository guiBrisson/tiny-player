local core = {}

function core.load()
    
end

function core.draw()
    gfx.set_color(0, 255, 250, 255)
    gfx.draw_rect(10, 10, 100, 100)
end

function core.update(dt)
    local fps = 1 / dt
    -- print("fps: " .. fps)
end

function core.on_keydown(key)
    -- print(key)
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

function core.on_error()
    -- write error to file
    local fp = io.open(EXEDIR .. "/error.txt", "wb")
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
