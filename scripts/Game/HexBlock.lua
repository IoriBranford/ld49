local Sprite = require "Component.Sprite"
local Body   = require "Component.Body"

local HexBlock = {}
HexBlock.metatable = {
    __index = HexBlock
}

function HexBlock:start(scene)
    if not self.sprite then
        Sprite.start(self, scene)
    end
    Body.start(self)
end

function HexBlock:think()
    self.vely = self.vely + 0.25
end

return HexBlock