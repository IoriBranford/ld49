local Units = require "Units"
local Prefabs = require "Prefabs"
local Shooting = require "Shooting"
local Cover = require "Component.Cover"

local Autofire = {}

function Autofire.hasAutofire(unit)
    local firetime = unit.firetime or 0
    if firetime <= 0 then
        return false
    end
    local firebullet = Prefabs.get(unit.firebullet)
    if not firebullet then
        return false
    end
    if not unit.inbattle then
        return false
    end
    return true
end

function Autofire.printHasAutofire(unit)
    print("firetime", unit.firetime or 0)
    print("firebullet", Prefabs.get(unit.firebullet))
    print("inbattle", unit.inbattle)
end

function Autofire.think(unit)
    if not Autofire.hasAutofire(unit) then
        return
    end
    local firetime = unit.firetime
    local firetimer = unit.firetimer or 0
    if not Cover.isInCover(unit) then
        firetimer = firetimer + 1
    end
    local firedshots
    if firetimer >= firetime then
        firedshots = Shooting.unitFire(unit)
        firetimer = firetimer - firetime
    end
    unit.firetimer = firetimer
    return firedshots
end

return Autofire