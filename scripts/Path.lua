local Path = {}

function Path.getWorldPoint(path, i)
    if not path or not i then
        return
    end
	local points = path.points
    if i < 2 then
        i = 2
    elseif i > #points then
        i = #points
    end
    local dx = points[i-1]
    local dy = points[i]
    return path.x + dx, path.y + dy
end

function Path.getNextIndex(path, i, di)
    if not i then return end

    di = di or 1
    i = i + 2*di
    if path then
        local points = path.points
        if path.shape == "polygon" then
            if i > #points then
                i = 2
            elseif i < 2 then
                i = #points
            end
        end
    end
    return i
end

return Path