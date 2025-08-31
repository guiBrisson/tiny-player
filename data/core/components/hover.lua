local hover = {}

function hover.new(onHover)
    return {
        isHovered = false,
        onHover = onHover,
    }
end

return hover
