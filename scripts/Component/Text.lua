local Color = require "Color"

local Text = {}
Text.metatable = {
    __index = Text
}

function Text.start(unit, scene)
    local str = unit.string
    if str then
        local text = scene:addTextObject(unit)
        unit.text = text
        return text
    end
end

function Text.setHidden(unit, hidden)
    unit.text.hidden = hidden
end

function Text.setString(unit, str)
    local text = unit.text
    if text then
        text.string = str
    end
end

return Text