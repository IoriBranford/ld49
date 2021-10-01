local Units = require "Units"
local Body = require "Component.Body"
local Sprite = require "Component.Sprite"
local Timer = require "Component.Timer"
local Health= require "Component.Health"
local Audio = require "Audio"
local Team   = require "Component.Team"
local Autofire= require "Component.Autofire"

local Bullet = {}
Bullet.metatable = {
    __index = Bullet
}

function Bullet:start(scene)
    if self.team == "PlayerShot" then
        Team.start(self, self.team, "EnemyTeam")
        self.health = self.health or 1
        self.hitdamageself = self.hitdamageself or 1
        self.offscreenremove = true
    elseif self.team == "PlayerBomb" then
        Team.start(self, self.team, "EnemyTeam EnemyShot")
        self.hitdamageself = self.hitdamageself or 0
    else
        Team.start(self, "EnemyShot", "PlayerTeam PlayerBomb")
        self.health = self.health or 1
        self.hitdamageself = self.hitdamageself or 1
        self.offscreenremove = true
    end
    self.hitdamageenemy = self.hitdamageenemy or 1
    if self.lifetime then
        Timer.start(self, "lifetime")
        self.think = Bullet.thinkAdvanced
    end
    self.inbattle = true
    if Autofire.hasAutofire(self) then
        self.think = Bullet.thinkAdvanced
    end
    self.bodytype = self.bodytype or "dynamic"
    self.bodybullet = true
    if self.bodyrotation == nil then
        self.bodyrotation = true
    end
    if self.bodyrotation then
        local velx, vely = self.velx or 0, self.vely or 0
        if velx ~= 0 or vely ~= 0 then
            self.rotation = math.atan2(vely, velx)
        end
    end
    Sprite.start(self, scene)
    Body.start(self)
    Audio.play(self.sound)
end

function Bullet:thinkAdvanced()
    Body.thinkCollision(self, Health.onCollision_damage)
    if self.health then
        if self.health < 1 then
            Units.remove(self)
        end
    end
    if Timer.think(self, "lifetime") < 0 then
        Units.remove(self)
    end
    Autofire.think(self)
end

return Bullet