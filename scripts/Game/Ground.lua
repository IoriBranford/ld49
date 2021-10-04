local Ground = {}
Ground.metatable = {
    __index = Ground
}

local Body = require "Component.Body"
function Ground:start(scene)
    self.sprite = scene:addObject(self)
    Body.start(self)
    self.joints = {}
end

return Ground