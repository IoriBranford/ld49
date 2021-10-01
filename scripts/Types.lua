local Types = {}
local Tiled = require "Tiled"

local types = {}

local function parseValue(v)
    if v == "true" or v == "TRUE" then
        v = true
    elseif v == "false" or v == "FALSE" then
        v = false
    else
        local tileset, tile = v:match("^tile/(%w+)/(%w+)$")
        tileset = tileset and Tiled.tilesets[tileset]
        tile = tileset and tileset[tile]
        v = tile or tonumber(v) or v or ""
    end
    return v
end

function Types.load(csvfilename)
    local loaded = {}
    for line in love.filesystem.lines(csvfilename) do
        local row = {}
        for v in line:gmatch("%s*([^,]-)%s*,") do
            row[#row+1] = parseValue(v)
        end
        row[#row+1] = parseValue(line:match("%s*([^,]-)%s*$"))
        loaded[#loaded+1] = row
    end

    local fieldnames = loaded[1]
    for i = 1, #fieldnames do
        fieldnames[i] = fieldnames[i]:match("^([_A-Za-z]+)")
    end
    for i = 2, #loaded do
        local t = loaded[i]
        local typename = t[1]
        types[typename] = t
        loaded[typename] = t
        for i = #t, 1, -1 do
            if t[i] ~= "" then
                t[fieldnames[i]] = t[i]
            end
            t[i] = nil
        end
    end
    for i = #loaded, 1, -1 do
        loaded[i] = nil
    end
    return loaded
end

function Types.clear()
    types = {}
end

function Types.fillBlanks(unit, t)
    t = types[t]
    if t then
        for k,v in pairs(t) do
            if unit[k] == nil then
                unit[k] = v
            end
        end
    end
end

function Types.fill(unit, typ)
    local t = types[typ]
    if t then
        for k,v in pairs(t) do
            unit[k] = v
        end
    end
end

function Types.forEach(func)
    for name, properties in pairs(types) do
        func(name, properties)
    end
end

return Types