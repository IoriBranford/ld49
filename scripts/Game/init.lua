
local Tiled = require "Tiled"
local Types = require "Types"
local Physics = require "Physics"
local Units   = require "Units"
local Config  = require "Config"
local Controls= require "Controls"

local Scene = require "Scene"
local Game = {}

local scene
local map
local canvas
local canvastransform
local started

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
    started = false
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
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
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