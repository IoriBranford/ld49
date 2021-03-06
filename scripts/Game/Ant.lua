local Sprite = require "Component.Sprite"
local Body   = require "Component.Body"
local Pathing= require "Component.Pathing"
local HexBlock = require "Game.HexBlock"
local Units    = require "Units"
local Audio    = require "Audio"
local Game = require "Game"

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
    if other.health then
        if other.damage then
            Audio.play("sounds/squish.mp3")
            self:remove()
        elseif not self.eatinghex then
            self.eatinghex = other
            self.speed = 0
        end
    end
end

function Ant:think()
    Body.thinkCollision(self, Ant.onCollision)
    if self.eatinghex then
        if HexBlock.eat(self.eatinghex, 1) <= 0 then
            if self.eatinghex.honey then
                if not self.honey then
                    Pathing.reverseDirection(self)
                    self.sprite.sx = -self.sprite.sx
                    Sprite.changeTile(self, "full")
                    self.honey = true
                end
            end
            if self.honey then
                self.speed = 1
            else
                self.speed = 2
            end
            self.eatinghex = nil
        end
    end
    Pathing.walkPath(self)
    if self.velx ~= 0 and self.vely ~= 0 then
        self.rotation = math.atan2(self.vely, self.velx)
        if self.sprite.sx < 0 then
            self.rotation = self.rotation - math.pi
        end
    elseif Pathing.isAtEnd(self) then
        self:remove()
    end
end

function Ant:eat()
    Audio.play(string.format("sounds/eat%d.wav", love.math.random(3)))
    self:remove()
end

function Ant:remove()
    Units.remove(self)
    Game.antRemoved()
end

return Ant