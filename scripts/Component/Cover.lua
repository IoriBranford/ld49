local Cover = {}

local covergrid

function Cover.setGrid(grid)
    covergrid = grid
end

function Cover.think_beforeCollisions(unit)
    if not unit.takescover then
        return
    end
    unit.cover = covergrid and covergrid:getAtPosition(unit.x, unit.y) and 1 or 0
end

function Cover.isInCover(unit)
    return unit.cover and unit.cover > 0
end

function Cover.onCollision_takeCover(unit, other)
    if not unit.takescover then
        return
    end
    if other and other.iscover then
        unit.cover = unit.cover + 1
    end
end

function Cover.draw(x, y)
    if covergrid then
        covergrid:draw(x, y)
    end
end

function Cover.changeColor(unit, r, g, b)
    if Cover.isInCover(unit) then
        r = r/2
        g = g/2
        b = b/2
    end
    return r, g, b
end

return Cover