local Sprite = require "Component.Sprite"
local Body   = require "Component.Body"

local HexBlock = {}
HexBlock.metatable = {
    __index = HexBlock
}

function HexBlock:start(scene)
    Sprite.start(self, scene)
    Body.start(self)
    self.joints = {}
end

function HexBlock:onCollision_stick(other)
    if not self.joints or not other.joints then return end
    if self.joints[other.id] then
        return
    end
    local x, y = self.body:getPosition()
    local otherx, othery = other.body:getPosition()
    local joint = love.physics.newWeldJoint(self.body, other.body, math.mid(x, y, otherx, othery))
    self.joints[other.id] = joint
    other.joints[self.id] = joint
end

function HexBlock:think()
    -- self.body:applyForce(0, .25)
    Body.thinkCollision(self, HexBlock.onCollision_stick)
end

return HexBlock