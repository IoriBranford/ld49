local Tiled = require "Tiled"
local Color = require "Color"

local Sprite = {}
Sprite.metatable = {
    __index = Sprite
}

function Sprite.start(unit, scene)
    local id, x, y, z = unit.id, unit.x, unit.y, unit.z
    local tile = unit.tile
    if not tile then
        local tileset = unit.tileset
        local tileid = unit.tileid
        tileset = tileset and Tiled.tilesets[tileset]
        tile = tileset and tileid and tileset[tileid]
        unit.tile = tile
    end
    if tile then
        local sprite = unit.animated == false
			and scene:addTile(id, tile, x, y, z, unit.rotation, unit.scalex, unit.scaley)
			or scene:addAnimatedTile(id, tile, x, y, z, unit.rotation, unit.scalex, unit.scaley)
        unit.sprite = sprite
        unit.tileset = Tiled.tilesets[tile.tileset]
        if sprite then
            Sprite.setColor(unit, unit.color)
        end
        return sprite
    end
end

function Sprite.setHidden(unit, hidden)
    unit.sprite.hidden = hidden
end

function Sprite.setTile(unit, tile)
    unit.tile = tile
    unit.tileset = Tiled.tilesets[tile.tileset]
    unit.sprite:setTile(tile)
end

function Sprite.changeTile(unit, tile)
    if type(tile) ~= "table" then
        tile = unit.tileset[tile]
    end
    if unit.tile ~= tile then
        Sprite.setTile(unit, tile)
    end
end

function Sprite.setColor(unit, r, g, b, a)
    local sprite = unit.sprite
    if not sprite then
        return
    end
    if type(r) ~= "number" then
        unit.color = r
        r, g, b, a = Color.unpack(r)
    end
    sprite.red, sprite.green, sprite.blue = r, g, b
    if a then
        sprite.alpha = a
    end
end

function Sprite.isAnimationEnding(unit)
    local sprite = unit.sprite
    if not sprite then
        return
    end
    local nextaniframe = Tiled.getAnimationUpdate(sprite.animation, sprite.animationframe, sprite.animationtime+1)
    return nextaniframe < sprite.animationframe
end

function Sprite.thinkFacing(unit)
    local tileset = unit.tileset
    if not tileset then
        return
    end

    local numdirections = tileset.numdirections or 0
    if numdirections < 2 then
        return
    end

    local aimx, aimy = unit.aimx or 0, unit.aimy or 0
    if aimx == 0 and aimy == 0 then
        return
    end

    local directionangle0 = math.rad(tileset.directionangle0 or 0)
    local dirarc = 2 * math.pi / numdirections
    local angle = math.atan2(aimy, aimx) + dirarc/2 - directionangle0
    local dirindex = math.floor(angle / dirarc) % numdirections
    local pose = unit.pose or "walk"
    local facetileid = pose..dirindex
    local facetile = tileset[facetileid]
    if facetile and facetile ~= unit.tile then
        Sprite.setTile(unit, facetile)
    -- else
    --     print(facetileid, facetile)
    end
end

return Sprite