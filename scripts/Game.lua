
local Tiled = require "Tiled"

local Scene = require "Scene"
local Game = {}

local scene
local map

function Game.loadphase()
    scene = Scene.new()
    map = Tiled.load("data/map.lua")
    scene:addMap(map)
end

function Game.quitphase()
    scene = nil
    map = nil
end

function Game.fixedupdate()
    scene:animate(1)
end

function Game.draw()
    scene:draw()
end

return Game