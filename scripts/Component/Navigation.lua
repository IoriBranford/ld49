
local Heap = require "Heap"
local Navigation = {}

local blockgrid

function Navigation.setBlockGrid(grid)
    blockgrid = grid
end

local fscores = {}
local gscores = {}
local prevs = {}
local searchmap = {}
local searchheap = Heap.new(function(i1, i2)
    return fscores[i1] < fscores[i2]
end)

function Navigation.navigateTo(unit, destx, desty)
    searchheap:clear()
    for k,v in pairs(fscores) do
        fscores[k] = nil
    end
    for k,v in pairs(gscores) do
        gscores[k] = nil
    end
    for k,v in pairs(prevs) do
        prevs[k] = nil
    end
    for k,v in pairs(searchmap) do
        searchmap[k] = nil
    end

    local t = love.timer.getTime()
    local destc, destr = blockgrid:cellAt(destx, desty)
    local startc, startr = blockgrid:cellAt(unit.x, unit.y)
    if startc == destc and startr == destr then
        return
    end

    local gridwidth = blockgrid.width
    local gridheight = blockgrid.height
    local starti = blockgrid:toIndex(startc, startr)
    local desti = blockgrid:toIndex(destc, destr)
    if blockgrid[desti] then
        for r = math.max(1, destr - 2), math.min(destr + 2, gridheight) do
            for c = math.max(destc - 2), math.min(destc + 2, gridwidth) do
                if not blockgrid:get(c, r) then
                    local i = blockgrid:toIndex(c, r)
                    fscores[i] = math.lensq(c - startc, r - startr)
                    searchheap:push(i)
                end
            end
        end
        desti = searchheap[1]
        if not desti then
            return
        end
        destc, destr = blockgrid:toCell(desti)
        searchheap:clear()
        for k,v in pairs(fscores) do
            fscores[k] = nil
        end
    end

    local function heuristic(i)
        local c, r = blockgrid:toCell(i)
        return math.lensq(destc - c, destr - r)
    end

    local function tryStep(i, j, d)
        if blockgrid[j] then
            return
        end
        local cost = gscores[i] + d
        if not gscores[j] or cost < gscores[j] then
            prevs[j] = i
            gscores[j] = cost
            local fscore = cost + heuristic(j)
            fscores[j] = fscore

            if not searchmap[j] then
                searchheap:push(j)
                searchmap[j] = true
            end
        end
    end

    searchheap:push(starti)
    searchmap[starti] = true
    gscores[starti] = 0
    fscores[starti] = heuristic(starti)

    local i
    local numsearched = 0
    while #searchheap > 0 do
        numsearched = numsearched + 1
        i = searchheap:pop()
        searchmap[i] = nil

        if i == desti then
            break
        end

        local rightopen = i % gridwidth ~= 0
        local leftopen = i % gridwidth ~= 1
        local upopen = i > gridwidth
        local downopen = i <= gridwidth * (gridheight-1)

        if leftopen then
            tryStep(i, i - 1, 1)

            if upopen then
                tryStep(i, i - 1 - gridwidth, 1.5)
            end
            if downopen then
                tryStep(i, i - 1 + gridwidth, 1.5)
            end
        end

        if rightopen then
            tryStep(i, i + 1, 1)

            if upopen then
                tryStep(i, i + 1 - gridwidth, 1.5)
            end
            if downopen then
                tryStep(i, i + 1 + gridwidth, 1.5)
            end
        end

        if upopen then
            tryStep(i, i - gridwidth, 1)
        end

        if downopen then
            tryStep(i, i + gridwidth, 1)
        end
    end

    local cellwidth = blockgrid.cellwidth
    local cellheight = blockgrid.cellheight
    local c, r = blockgrid:toCell(desti)
    local pathx = (startc - .5) * cellwidth
    local pathy = (startr - .5) * cellheight
    local path = unit.path or {}
    path.x = pathx
    path.y = pathy
    local points = path.points or {}
    path.points = points
    for i = #points, 3, -1 do
        points[i] = nil
    end
    points[1] = (c - .5) * cellwidth - pathx
    points[2] = (r - .5) * cellheight - pathy

    i = desti
    while prevs[i] do
        i = prevs[i]
        c, r = blockgrid:toCell(i)
        points[#points+1] = (c - .5) * cellwidth - pathx
        points[#points+1] = (r - .5) * cellheight - pathy
    end

    for i1 = 2, math.floor(#points/2), 2 do
        local i2 = #points - i1
        local x1, y1 = points[i1 - 1], points[i1]
        local x2, y2 = points[i2 + 1], points[i2 + 2]
        points[i1 - 1] = x2
        points[i1    ] = y2
        points[i2 + 1] = x1
        points[i2 + 2] = y1
    end

    unit.path = path
    unit.pathindex = 2
    -- DEBUG
    -- print(string.format("Navigation searched %d squares and took %f secs", numsearched, love.timer.getTime() - t))
end

return Navigation