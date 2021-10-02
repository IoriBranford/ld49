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
end

return HexBlock