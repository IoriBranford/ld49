local Units = require "Units"
local Prefabs = require "Prefabs"

local Shooting = {}

local function shoot(shooter, shottype)
    local x, y = shooter.x, shooter.y
    local shot = Units.newUnit_position(shottype, x, y)
    if shooter.firesilent then
        shot.sound = nil
    end
    shot.shooterid = shooter.id
    return shot
end
Shooting.shoot = shoot

local function shoot_vel(shooter, shottype, velx, vely)
    local shot = shoot(shooter, shottype)
    shot.velx, shot.vely = velx, vely
    return shot
end
Shooting.shoot_vel = shoot_vel

local function shoot_dir(shooter, shottype, dirx, diry)
    if type(shottype) ~= "table" then
        shottype = Prefabs.get(shottype)
    end
    local speed = shottype and shottype.speed or 0
    local velx = (dirx or 0)*speed
    local vely = (diry or 0)*speed
    return shoot_vel(shooter, shottype, velx, vely)
end
Shooting.shoot_dir = shoot_dir

function Shooting.shoot_dir_offset(shooter, shottype, dirx, diry, offsetx, offsety)
    local bullet = shoot_dir(shooter, shottype, dirx, diry)
    if bullet then
        bullet.x = bullet.x + (offsetx or 0)
        bullet.y = bullet.y + (offsety or 0)
    end
    return bullet
end
local shoot_dir_offset = Shooting.shoot_dir_offset

function Shooting.shoot_angle(shooter, shottype, angle)
    return shoot_dir(shooter, shottype, math.cos(angle), math.sin(angle))
end
local shoot_angle = Shooting.shoot_angle

local function shoot_dir_speed(shooter, shottype, dirx, diry, speed)
    return shoot_vel(shooter, shottype, dirx*speed, diry*speed)
end
Shooting.shoot_dir_speed = shoot_dir_speed

local function shoot_targetPos_speed(shooter, shottype, targetx, targety, speed)
    local x, y = shooter.x, shooter.y
    local distx, disty = targetx-x, targety-y
    local dist = math.sqrt(distx*distx+disty*disty)
    local dirx, diry = 0, 0
    if dist > 0 then
        dirx, diry = distx/dist, disty/dist
    end
    return speed and shoot_dir_speed(shooter, shottype, dirx, diry, speed)
        or shoot_dir(shooter, shottype, dirx, diry)
end
Shooting.shoot_targetPos_speed = shoot_targetPos_speed

local function shoot_targetPos(shooter, shottype, targetx, targety)
    return shoot_targetPos_speed(shooter, shottype, targetx, targety, nil)
end
Shooting.shoot_targetPos = shoot_targetPos

local function shoot_targetUnit_speed(shooter, shottype, targetunit, speed)
    local targetx, targety = targetunit.x, targetunit.y
    local shot = shoot_targetPos_speed(shooter, shottype, targetx, targety, speed)
    shot.z = targetunit.z
    return shot
end
Shooting.shoot_targetUnit_speed = shoot_targetUnit_speed

local function shoot_targetUnit(shooter, shottype, targetunit)
    return shoot_targetUnit_speed(shooter, shottype, targetunit, nil)
end
Shooting.shoot_targetUnit = shoot_targetUnit

local firedshots = {}

local function shootMulti_fan(shooter, shottype, aimx, aimy, count, arc)
    arc = arc or math.pi
    local angle = 0
    if aimx ~= 0 or aimy ~= 0 then
        angle = math.atan2(aimy, aimx)
    end
    local slice = arc / (count - 1)
    angle = angle - (arc/2)
    for i = 1, count do
        firedshots[i] = shoot_angle(shooter, shottype, angle)
        angle = angle + slice
    end
    for i = #firedshots, count+1, -1 do
        firedshots[i] = nil
    end
    return firedshots
end

local function shootMulti_ring(shooter, shottype, aimx, aimy, count, radius)
    local angle = 0
    if aimx ~= 0 or aimy ~= 0 then
        angle = math.atan2(aimy, aimx)
    end
    radius = radius or 16
    local slice = 2*math.pi / count
    for i = 1, count do
        local offsetx = math.cos(angle) * radius
        local offsety = math.sin(angle) * radius
        firedshots[i] = shoot_dir_offset(shooter, shottype, aimx, aimy, offsetx, offsety)
        angle = angle + slice
    end
    for i = #firedshots, count+1, -1 do
        firedshots[i] = nil
    end
    return firedshots
end

local function shootMulti_row(shooter, shottype, aimx, aimy, count, length)
    length = length or 32
    local perpaimx, perpaimy = -aimy, aimx
    local offsetx = -perpaimx * length/2
    local offsety = -perpaimy * length/2
    local space = length / (count-1)
    for i = 1, count do
        firedshots[i] = shoot_dir_offset(shooter, shottype, aimx, aimy, offsetx, offsety)
        offsetx = offsetx + perpaimx * space
        offsety = offsety + perpaimy * space
    end
    for i = #firedshots, count+1, -1 do
        firedshots[i] = nil
    end
    return firedshots
end

function Shooting.unitFire(unit)
    local firebullet = unit.firebullet
    local count = unit.firemulti or 1

    local aimx, aimy = unit.aimx or 0, unit.aimy or 0
    if count < 2 then
        firedshots[1] = Shooting.shoot_dir(unit, firebullet, aimx, aimy)
        for i = #firedshots, count+1, -1 do
            firedshots[i] = nil
        end
    else
        local firemultishape = unit.firemultishape
        if firemultishape == "fan" then
            shootMulti_fan(unit, firebullet, aimx, aimy, count, unit.firefanarc)
        elseif firemultishape == "ring" then
            shootMulti_ring(unit, firebullet, aimx, aimy, count, unit.firemultiradius)
        else--if firemultishape == "row" then
            shootMulti_row(unit, firebullet, aimx, aimy, count, unit.firerowlength)
        end
    end
    return firedshots
end

return Shooting