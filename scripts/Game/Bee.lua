local Controls = require "Controls"
local Sprite   = require "Component.Sprite"
local Body     = require "Component.Body"
local Units    = require "Units"
local Audio    = require "Audio"

local Bee = {}
Bee.metatable = {
    __index = Bee
}

function Bee:start(scene)
    Sprite.start(self, scene)
    Body.start(self)
    self.body:setGravityScale(0)
    self.lastmovex, self.lastmovey = 1, 0
    self.maxammo = self.maxammo or 20
    self.ammo = self.ammo or self.maxammo
    self.speed = self.speed or 4
end

function Bee:onCollision_eatAnt(other)
    if other.type:find("^Ant") then
        if other.honey and not self.honey then
            self.speed = self.speed + 2
            self.honey = true
            Audio.play("sounds/speedup.mp3")
        end
        if self.ammo < self.maxammo then
            self.ammo = self.ammo + 1
        end
        Audio.play(string.format("sounds/eat%d.wav", love.math.random(3)))
        Units.remove(other)
    end
end

function Bee:think()
    Body.thinkCollision(self, Bee.onCollision_eatAnt)
    local speed = self.speed
    local dx, dy = Controls.getDirectionInput()
    local throw = Controls.getButtonsPressed()
    if dx ~= 0 then
        self.sprite.sx = dx
    end
    if self.velx ~= 0 or self.vely ~= 0 then
        self.lastmovex = self.velx
        self.lastmovey = self.vely
    end
    self.velx, self.vely = dx*speed, dy*speed
    if throw and self.ammo > 0 then
        local hex = Units.newUnit_position("HexThrown", self.x, self.y)
        local dirx, diry = math.norm(self.lastmovex, self.lastmovey)
        local speed = hex.speed or 8
        hex.velx = dirx*speed
        hex.vely = diry*speed
        hex.x = hex.x + hex.velx
        hex.y = hex.y + hex.vely
        self.ammo = self.ammo - 1
    end
end

return Bee