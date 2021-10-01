local Grid = {}
Grid.__index = Grid

function Grid.new(width, height, cellwidth, cellheight, margin)
    margin = margin or 0
    width = width + 2*margin
    height = height + 2*margin
    local grid = {
        cellwidth = cellwidth or 1,
        cellheight = cellheight or 1,
        width = width,
        height = height,
        margin = margin
    }
    setmetatable(grid, Grid)
    return grid
end

function Grid.setmetatable(grid)
    return setmetatable(grid, Grid)
end

function Grid:inBounds(column, row)
    -- local margin = self.margin
    -- column = column + margin
    -- row = row + margin
    if column < 1 then return end
    if row < 1 then return end
    if column > self.width then return end
    if row > self.height then return end
    return true
end

function Grid:toCell(i)
    local margin = self.margin
    local width = self.width
    i = i - 1
    margin = margin - 1
    return (i % width) - margin, math.floor(i / width) - margin
end

function Grid:toIndex(column, row)
    local margin = self.margin
    row = row + margin - 1
    column = column + margin
    return row*self.width + column
end

function Grid:getWidth()
    return self.width - 2*self.margin
end

function Grid:getHeight()
    return self.height - 2*self.margin
end

function Grid:get(column, row)
    return self:inBounds(column, row) and self[self:toIndex(column, row)]
end

function Grid:cellAt(x, y)
    return math.ceil(x / self.cellwidth), math.ceil(y / self.cellheight)
end

function Grid:getAtPosition(x, y)
    local c, r = self:cellAt(x, y)
    return self:get(c, r)
end

function Grid:set(column, row, value)
    if self:inBounds(column, row) then
        self[self:toIndex(column, row)] = value
    end
end

function Grid:fill(value)
    for i = 1, self.width*self.height do
        self[i] = value
    end
end

function Grid:draw(x, y)
    local cellwidth = self.cellwidth
    local cellheight = self.cellheight
    local width = self.width
    local height = self.height
    local margin = self.margin

    x = (x or 0) - margin*cellwidth
    y = (y or 0) - margin*cellheight
    local x1 = x
    local i = 1
    for r = 1, height do
        for c = 1, width do
            local data = self[i]
            if data then
                love.graphics.printf(tostring(data), x, y, cellwidth)
            end
            i = i + 1
            x = x + cellwidth
        end
        x = x1
        y = y + cellheight
    end
end

return Grid