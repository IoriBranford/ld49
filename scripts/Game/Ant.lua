local Sprite = require "Component.Sprite"
local Body   = require "Component.Body"
local Pathing= require "Component.Pathing"
local HexBlock = require "Game.HexBlock"
local Units    = require "Units"

local Ant = {}
Ant.metatable = {
    __index = Ant
}

function Ant:start(scene)
    Sprite.start(self, scene)
    Body.start(self)
    Pathing.start(self)
    self.speed = self.speed or 2
    self.body:setGravityScale(0)
end

function Ant:onCollision(other)
    if other.health and not self.eatinghex then
        self.eatinghex = other
    end
end

function Ant:think()
    Body.thinkCollision(self, Ant.onCollision)
    if self.eatinghex then
        if HexBlock.eat(self.eatinghex, 1) <= 0 then
            self.eatinghex = nil
        end
        self.speed = 0
    else
        self.speed = 2
    end
    Pathing.walkPath(self)
    if self.velx ~= 0 and self.vely ~= 0 then
        self.rotation = math.atan2(self.vely, self.velx)
        if self.scalex < 0 then
            self.rotation = self.rotation - math.pi
        end
    end
end

return Ant