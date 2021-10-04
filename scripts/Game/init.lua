
local Tiled = require "Tiled"
local Types = require "Types"
local Physics = require "Physics"
local Units   = require "Units"
local Config  = require "Config"
local Controls= require "Controls"
local Prefabs = require "Prefabs"

local Scene = require "Scene"
local Game = {}

local scene
local map
local canvas
local canvastransform
local started
local antspawntime = 120
local antspawntimer

function Game.loadphase()
    canvas = love.graphics.newCanvas(Config.basewindowwidth, Config.basewindowheight)
    canvas:setFilter("nearest", "nearest")

    local gw = love.graphics.getWidth()
    local gh = love.graphics.getHeight()
    local ghw = gw / 2
    local ghh = gh / 2
    local chw = canvas:getWidth() / 2
    local chh = canvas:getHeight() / 2
    local canvasscale

    local rotation = math.rad(Config.rotation)
    local portraitrotation = Config.isPortraitRotation()
    if portraitrotation then
        canvasscale = math.min(ghh / chw, ghw / chh)
    else
        canvasscale = math.min(ghw / chw, ghh / chh)
    end

    if Config.canvasscaleint then
        canvasscale = math.floor(canvasscale)
    end

    canvastransform = love.math.newTransform()
    canvastransform:translate(math.floor(ghw), math.floor(ghh))
    canvastransform:rotate(rotation)
    canvastransform:scale(canvasscale)
    canvastransform:translate(-chw, -chh)

    Types.load("data/types.csv")
    Physics.init()
    scene = Scene.new()
    Units.init(scene)
    map = Tiled.load("data/map2.lua")
    Units.setNextId(map.nextobjectid)

    scene:addMap(map, "tilelayer,imagelayer")

    local worldlayer = map.layers.world
    for i, layer in ipairs(map.layers) do
        if layer.type == "objectgroup" then
            layer.paths = {}
            if layer.name:find("^prefabs") then
                Prefabs.add(layer)
                for i, object in ipairs(layer) do
                    object.layer = worldlayer
                end
            else
                for i, object in ipairs(layer) do
                    for i, object in ipairs(layer) do
                        object.layer = layer
                    end
                    if object.type == "Path" then
                        layer.paths[object.id] = object
                    else
                        Units.addUnit(object)
                    end
                end
            end
        end
    end
    Units.activateAdded()
    started = false
    if map.backgroundcolor then
        love.graphics.setBackgroundColor(table.unpack(map.backgroundcolor))
    end
    Physics.setGravity(0, .125)
    antspawntimer = 0
end

function Game.quitphase()
    Units.clear()
    Types.clear()
    Physics.clear()
    scene = nil
    map = nil
end

function Game.fixedupdate()
    if not started then
        if Controls.getButtonsPressed() then
            started = true
        end
        return
    end
    Physics.fixedupdate()
    Units.updatePositions()
    Units.think()
    for id, body in Physics.iterateBodies() do
        Units.updateBody(id, body)
    end
    antspawntimer = antspawntimer + 1
    if antspawntimer >= antspawntime then
        Units.newUnit("Ant1")
        Units.newUnit("Ant2")
        antspawntimer = antspawntimer - antspawntime
    end
    Units.activateAdded()
    Units.deleteRemoved()
end

function Game.update(dsecs, fixedfrac)
    scene:animate(dsecs*1000)
    Units.updateScene(fixedfrac)
end

function Game.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear(love.graphics.getBackgroundColor())
    scene:draw()
    if Config.drawbodies then
        Physics.draw(0, 0, Config.basewindowwidth, Config.basewindowheight)
    end
    love.graphics.setCanvas()

    love.graphics.push()
    love.graphics.applyTransform(canvastransform)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(canvas)

    love.graphics.pop()
end

return Game