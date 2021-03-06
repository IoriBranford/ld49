local Sprite = require "Component.Sprite"
local Body   = require "Component.Body"
local Units  = require "Units"
local Audio  = require "Audio"
local Game = require "Game"

local HexBlock = {}
HexBlock.metatable = {
    __index = HexBlock
}

function HexBlock:start(scene)
    Sprite.start(self, scene)
    Body.start(self)
    self.joints = {}
    self.health = self.health or 120
    if self.damage then
        Audio.play("sounds/throw.mp3")
    end
end

function HexBlock:onCollision_stick(other)
    if not self.joints or not other.joints then return end
    if self.joints[other.id] then
        return
    end
    -- self.damage = nil
    -- other.damage = nil
    local x, y = self.body:getPosition()
    local otherx, othery = other.body:getPosition()
    local joint = love.physics.newWeldJoint(self.body, other.body, math.mid(x, y, otherx, othery))
    self.joints[other.id] = joint
    other.joints[self.id] = joint
    Audio.play("sounds/stick.mp3")
end

function HexBlock:think()
    -- self.body:applyForce(0, .25)
    if next(self.joints) then
        self.damage = nil
    end
    Body.thinkCollision(self, HexBlock.onCollision_stick)
    if self.x < -16 or self.y > 640 then
        self:remove()
    end
end

function HexBlock:eat(damage)
    self.health = self.health - damage
    if self.health <= 0 then
        self:remove()
    end
    return self.health
end

function HexBlock:remove()
    Units.remove(self)
    if self.honey then
        Game.honeyLost()
    end
end

return HexBlock