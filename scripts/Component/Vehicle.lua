-- local ThinkOrder = require "Demonizer.ThinkOrder"

local Vehicle = {}

function Vehicle.findNearestVehicle(unit)
    local units = unit.layer.units
    local nearest
    local nearestdsq = math.huge
    for i, vehicle in pairs(units) do
        if vehicle ~= unit and vehicle.isvehicle then
            local dsq = math.lensq(vehicle.x - unit.x, vehicle.y - unit.y)
            if nearestdsq > dsq then
                nearest = vehicle
                nearestdsq = dsq
            end
        end
    end
    return nearest
end

function Vehicle.start(vehicle)
    if not vehicle.isvehicle then return end
    if not vehicle.riders then
        vehicle.riders = {}
    end
    -- vehicle.thinkorder = ThinkOrder.Vehicle
end

function Vehicle.addRider(vehicle, rider)
    if not vehicle.isvehicle then return end
    Vehicle.start(vehicle)
    vehicle.riders[#vehicle.riders + 1] = rider
end

function Vehicle.removeRider(vehicle, rider)
    if not vehicle.isvehicle then return end
    Vehicle.start(vehicle)
    local riders = vehicle.riders
    for i = 1, #riders do
        if riders[i] == rider then
            riders[i] = riders[#riders]
            riders[#riders] = nil
            break
        end
    end
end

function Vehicle.clearRiders(vehicle)
    if not vehicle.isvehicle then return end
    local riders = vehicle.riders
    if not riders then return end
    for i = #riders, 1, -1 do
        riders[i] = nil
    end
end

function Vehicle.think(vehicle)
    if not vehicle.isvehicle then return end
    local x, y = vehicle.x, vehicle.y
    local vx, vy = vehicle.velx, vehicle.vely
    local riders = vehicle.riders
    local tile = vehicle.sprite.tile
    local shapes = tile and tile.shapes
    for i = 1, #riders do
        local rider = riders[i]
        local seatname = rider.vehicleseat
        local seat = shapes and shapes[seatname]
        if seat then
            rider.x, rider.y = x + seat.x, y + seat.y
        end
        rider.velx, rider.vely = vx, vy
    end
end

return Vehicle