local Ground = {}

local Body = require "Component.Body"
function Ground:start(scene)
    Body.start(self)
end

return Ground