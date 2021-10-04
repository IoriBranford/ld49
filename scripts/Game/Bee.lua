local Controls = require "Controls"
local Sprite   = require "Component.Sprite"
local Body     = require "Component.Body"

local Bee = {}
Bee.metatable = {
    __index = Bee
}

function Bee:start(scene)
    Sprite.start(self, scene)
    Body.start(self)
    self.body:setGravityScale(0)
end

function Bee:think()
    local speed = self.speed or 4
    local dx, dy = Controls.getDirectionInput()
    if dx ~= 0 then
        self.sprite.sx = dx
    end
    self.velx, self.vely = dx*speed, dy*speed
end

return Bee