local Physics = require "Physics"
local Types   = require "Types"
local Prefabs  = require "Prefabs"

local Unit
local type = type
local require = require
local Units = {}

local nextunitid
local unitsbyid
local unitsbystringid
local thinkingunits
local thinkingarray
local newunitqueue
local unitstoremove
local removedunitids
local scene

function Units.init(scene0)
    Unit = require "Unit"
    nextunitid = 1
    unitsbyid = {}
    unitsbystringid = {}
    thinkingunits = {}
    thinkingarray = {}
    newunitqueue = {}
    unitstoremove = {}
    removedunitids = {}
    scene = scene0
end

function Units.setNextId(id)
    nextunitid = id
end

function Units.clear()
    unitsbyid = nil
    unitsbystringid = nil
    thinkingunits = nil
    thinkingarray = nil
    newunitqueue = nil
    unitstoremove = nil
    removedunitids = nil
    scene = nil
end

local function activateUnit(unit)
    local id = unit.id
    unitsbyid[id] = unit

    local start = unit.start or Unit.startDefault
    unit.start = start
    if type(start) == "function" then
        start(unit, scene)
    end

    if type(unit.think) == "function" then
        thinkingunits[unit.id] = unit
    end

    local stringid = unit.stringid
    if stringid then
        unitsbystringid[stringid] = unit
    end

    return unit
end

local function initScript(unit)
    local script = unit.script
    local ok
    if type(script) == "string" then
        ok, script = pcall(require, script)
        if not ok then
            print(script)
        end
    end

    if type(script) == "table" then
        local metatable = script.metatable
        if metatable then
            setmetatable(unit, metatable)
        end

        local start = unit.start
        local think = unit.think
        if type(start) == "string"  then
            unit.start = script[start]
        end
        if type(think) == "string"  then
            unit.think = script[think]
        end
    end

    return unit
end

function Units.addUnit(unit)
    local stringid = unit.stringid
    if unitsbystringid[stringid] then
        return nil, string.format("Duplicate unit string id %s", stringid)
    end

    local id = unit.id
    if unitsbyid[id] or removedunitids[id] then
        print("W: an object tried to reuse id "..id)
        id = nil
    end

    if not id then
        id = nextunitid
        nextunitid = nextunitid + 1
        unit.id = id
    end

    Types.fillBlanks(unit, unit.type)

    unit.age = unit.age or 0
    unit.width = unit.width or 0
    unit.height = unit.height or 0
    unit.x = unit.x or 0
    unit.y = unit.y or 0
    unit.z = unit.z or 0
    unit.rotation = unit.rotation or 0
    unit.velx = unit.velx or 0
    unit.vely = unit.vely or 0
    unit.avel = unit.avel or 0
    unit.thinkorder = unit.thinkorder or 0
    initScript(unit)
    newunitqueue[#newunitqueue+1] = unit
    return unit
end

function Units.newUnit(prefab, stringid)
    if type(prefab) ~= "table" then
        if prefab then
            prefab = Prefabs.get(prefab)
            if not prefab then
                return nil, string.format("No such prefab %s", prefab)
            end
        end
    end

    local unit = {
        -- id = id,
        -- stringid = stringid
        -- age = 0,
        -- width = 0,
        -- height = 0,
        -- x = 0,
        -- y = 0,
        -- z = 0,
        -- rotation = 0,

        -- velx = 0,
        -- vely = 0,
        -- avel = 0,

        -- tile = nil,
        -- sprite = nil,
        -- spritebatch = nil,
        -- spritebatchindex = nil,

        -- body = nil,
        -- bodytype = nil,
        -- bodyshape = nil,
        -- bodyrotation = nil,

        -- script = nil,
        -- start = nil,
        -- think = nil,
        -- thinkorder = 0
    }

    if prefab then
        for k, v in pairs(prefab) do
            unit[k] = v
        end
    end
    unit.stringid = stringid or unit.stringid
    return Units.addUnit(unit)
end

function Units.newUnit_position(base, x, y, z)
    return Units.newUnit_stringid_position(base, nil, x, y, z)
end

function Units.newUnit_stringid_position(base, stringid, x, y, z)
    local unit, err = Units.newUnit(base, stringid)
    if not unit then
        return nil, err
    end

    if x then
        unit.x = x
    end
    if y then
        unit.y = y
    end
    if z then
        unit.z = z
    end

    return unit
end

function Units.get(id)
    if type(id) == "string" then
        return unitsbystringid[id]
    end
    return unitsbyid[id]
end

function Units.remove(unit)
    if type(unit) ~= "table" then
        unitstoremove[unit] = unitsbyid[unit]
    else
        unitstoremove[unit.id] = unit
    end
end

local function sortThinkingUnits(a, b)
    local ordera, orderb = a.thinkorder, b.thinkorder
    return ordera < orderb or ordera == orderb and a.id < b.id
end

local function updateThinkingArray()
    local n = 0
    for id, unit in pairs(thinkingunits) do
        n = n + 1
        thinkingarray[n] = unit
    end
    for i = #thinkingarray, n+1, -1 do
        thinkingarray[i] = nil
    end
    table.sort(thinkingarray, sortThinkingUnits)
end

function Units.activateAdded()
    local i = 1
    local addedthinking = false
    while i <= #newunitqueue do
        local unit = activateUnit(newunitqueue[i])
        if thinkingunits[unit.id] then
            addedthinking = true
        end
        i = i + 1
    end
    if addedthinking then
        updateThinkingArray()
    end
    for i = #newunitqueue, 1, -1 do
        newunitqueue[i] = nil
    end
end

function Units.deleteRemoved()
    local removedthinking = false
    for id, unit in pairs(unitstoremove) do
        scene:remove(id)
        Physics.removeBody(id)
        unit.body = nil
        local stringid = unit.stringid
        if stringid then
            unitsbystringid[stringid] = nil
        end
        unitsbyid[id] = nil
        if thinkingunits[id] then
            removedthinking = true
        end
        thinkingunits[id] = nil
        unitstoremove[id] = nil
        removedunitids[id] = true
    end
    if removedthinking then
        updateThinkingArray()
    end
end

function Units.isRemoved(id)
    return removedunitids[id]
end

function Units.think()
    for i = 1, #thinkingarray do
        local unit = thinkingarray[i]
        unit.age = unit.age + 1
        if unit.think then
            unit:think()
        end
    end
end

function Units.updateFromBody(id, body)
    local unit = unitsbyid[id]
    if unit then
        assert(unit.body == body, "unit.body ~= body")
        unit.velx, unit.vely = body:getLinearVelocity()
        unit.avel = body:getAngularVelocity()
        unit.x, unit.y = body:getPosition()
        unit.rotation = body:getAngle()
    end
end

function Units.updatePositions()
    for id, unit in pairs(unitsbyid) do
        local body = unit.body
        if body then
            unit.velx, unit.vely = body:getLinearVelocity()
            unit.avel = body:getAngularVelocity()
            unit.x, unit.y = body:getPosition()
            unit.rotation = body:getAngle()
        else
            unit.x = unit.x + unit.velx
            unit.y = unit.y + unit.vely
            unit.rotation = unit.rotation + unit.avel
        end
    end
end

function Units.updateBody(id, body)
    local unit = unitsbyid[id]
    if unit then
        assert(unit.body == body, "unit.body ~= body")
        body:setLinearVelocity(unit.velx, unit.vely)
        body:setAngularVelocity(unit.avel)
        body:setPosition(unit.x, unit.y)
        body:setAngle(unit.rotation)
    end
end

function Units.onCollisionEvent(event, f1, f2, contact)
    local id1, id2 = f1:getUserData(), f2:getUserData()
    local u1, u2 = unitsbyid[id1], unitsbyid[id2]
    local fun1, fun2 = u1[event], u2[event]
    if type(fun1) == "function" then
        fun1(u1, u2, contact)
    end
    if type(fun2) == "function" then
        fun2(u2, u1, contact)
    end
end

function Units.updateScene(fixedfrac)
    for id, unit in pairs(unitsbyid) do
        scene:updateFromUnit(id, unit, fixedfrac)
    end
end

return Units