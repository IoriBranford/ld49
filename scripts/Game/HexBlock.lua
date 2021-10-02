local Sprite = require "Component.Sprite"
local Body   = require "Component.Body"

local HexBlock = {}
HexBlock.metatable = {
    __index = HexBlock
}

function HexBlock:start(scene)
    Sprite.start(self, scene)
    Body.start(self)
end

function HexBlock:think()
    self.body:applyForce(0, .25)
    if not self.body:isAwake() then
        print(self.id, "is asleep")
    end
end

return HexBlock