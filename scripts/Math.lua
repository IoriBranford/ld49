function math.clamp(x, min, max)
    return math.max(min, math.min(x, max))
end

function math.dot(x, y, x2, y2)
    return x2*x + y2*y
end

function math.det(x, y, x2, y2)
    return x*y2 - y*x2
end

function math.lensq(x, y)
    return x*x+y*y
end

function math.len(x, y)
    return math.sqrt(x*x + y*y)
end

function math.norm(x, y)
    local len = math.sqrt(x*x + y*y)
    return x/len, y/len
end

function math.testrects(ax, ay, aw, ah, bx, by, bw, bh)
    if ax + aw < bx then return false end
    if bx + bw < ax then return false end
    if ay + ah < by then return false end
    if by + bh < ay then return false end
    return true
end

function math.table_rad(t, k)
    local x = t[k]
    if type(x) == "number" then
        t[k] = math.rad(x)
    end
end