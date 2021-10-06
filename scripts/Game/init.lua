
local Tiled = require "Tiled"
local Types = require "Types"
local Physics = require "Physics"
local Units   = require "Units"
local Config  = require "Config"
local Controls= require "Controls"
local Prefabs = require "Prefabs"
local Sprite  = require "Component.Sprite"
local Audio   = require "Audio"

local Scene = require "Scene"
local Game = {}

local scene
local map
local canvas
local canvastransform
local started
local antcount
local antspawntime
local antspawntimedec
local antspawntimer
local antspawntype
local ammobar
local bee

function Game.loadphase(mapfile)
    antcount = 50
    antspawntime = 160
    antspawntimedec = 2
    antspawntimer = 0
    antspawntype = "Ant1"

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
    map = Tiled.load(mapfile)
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

    bee = worldlayer.bee
    local hexbar = worldlayer.hexbar
    local x, y = hexbar.points[1], hexbar.points[2]
    local dx = hexbar.points[3] - x
    ammobar = {}
    for i = 1, (bee.maxammo or 20) do
        ammobar[i] = Units.newUnit_position("HexIcon", x, y)
        x = x + dx
    end

    Units.activateAdded()
    started = mapfile == "data/map.lua"
    if map.backgroundcolor then
        love.graphics.setBackgroundColor(table.unpack(map.backgroundcolor))
    end
    Physics.setGravity(0, .125)
end

function Game.quitphase()
    Units.clear()
    Types.clear()
    Physics.clear()
    Prefabs.clear()
    scene = nil
    map = nil
    canvas = nil
    canvastransform = nil
    ammobar = nil
    bee = nil
end

function Game.keypressed(key)
    if key == "f12" then
        love.graphics.captureScreenshot(os.date("%Y-%m-%d-%H-%M-%S")..".png")
    else
        Game.start()
    end
end

function Game.gamepadpressed(gamepad, button)
    Game.start()
end

function Game.gamepadaxis(gamepad, axis, value)
    Game.start()
end

function Game.start()
    if not started then
        love.event.loadphase("Game", "data/map.lua")
    end
end

function Game.fixedupdate()
    Physics.fixedupdate()
    Units.updatePositions()
    Units.think()
    for id, body in Physics.iterateBodies() do
        Units.updateBody(id, body)
    end
    if started then
        if antcount > 0 then
            antspawntimer = antspawntimer + 1
            if antspawntimer >= antspawntime then
                Units.newUnit(antspawntype)
                antcount = antcount - 1
                antspawntype = antspawntype == "Ant1" and "Ant2" or "Ant1"
                antspawntime = antspawntime - antspawntimedec
                antspawntimer = antspawntimer - antspawntime
            end
        end
    end
    Units.activateAdded()
    Units.deleteRemoved()
    if not Audio.isPlayingMusic() then
        local music = Audio.playMusic("sounds/ambience_outdoor.mp3")
        music:setLooping(true)
    end
    Controls.clearButtonsPressed()
end

function Game.update(dsecs, fixedfrac)
    for i, ammoicon in ipairs(ammobar) do
        Sprite.setHidden(ammoicon, i > bee.ammo)
    end
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