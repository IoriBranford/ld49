
local Tiled = require "Tiled"
local Types = require "Types"
local Physics = require "Physics"
local Units   = require "Units"
local Config  = require "Config"

local Scene = require "Scene"
local Game = {}

local scene
local map

function Game.loadphase()
    Types.load("data/types.csv")
    Physics.init()
    scene = Scene.new()
    Units.init(scene)
    map = Tiled.load("data/map.lua")

    scene:addMap(map, "tilelayer,imagelayer")

    for i, layer in ipairs(map.layers) do
        if layer.type == "objectgroup" then
            for i, object in ipairs(layer) do
                Units.addUnit(object)
            end
        end
    end
    Units.activateAdded()
end

function Game.quitphase()
    Units.clear()
    Types.clear()
    Physics.clear()
    scene = nil
    map = nil
end

function Game.fixedupdate()
    Physics.fixedupdate()
    Units.updatePositions()
    Units.think()
    -- for id, body in Physics.iterateBodies() do
    --     Units.updateBody(id, body)
    -- end
    Units.activateAdded()
    Units.deleteRemoved()
end

function Game.update(dsecs, fixedfrac)
    for id, body in Physics.iterateBodies() do
        scene:updateFromBody(id, body, fixedfrac)
    end
    scene:animate(dsecs*1000)
    -- Units.updateScene(fixedfrac)
end

function Game.draw()
    scene:draw()
    if Config.drawbodies then
        Physics.draw(0, 0, 640, 480)
    end
end

return Game