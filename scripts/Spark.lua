local Audio = require "Audio"
local Units = require "Units"
local Sprite = require "Component.Sprite"
local Timer = require "Component.Timer"
local Text  = require "Component.Text"

local Spark = {}
Spark.metatable = {
    __index = Spark
}

function Spark:start(scene)
    self.lifetime = self.lifetime or "animation"
    Sprite.start(self, scene)
    Timer.start(self, "lifetime")
    Text.start(self, scene)
    Audio.play(self.sound)
end

function Spark:think()
    if Timer.think(self, "lifetime") < 0 then
        Units.remove(self)
    end
end

return Spark