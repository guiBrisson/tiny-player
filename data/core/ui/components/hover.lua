local hover = {}

function hover.new(onHover)
    return onHover and {
        isHovered = false,
        onHover = onHover,
    }
end

return hover
