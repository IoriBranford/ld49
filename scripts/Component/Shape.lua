local Shape = {}

Shape.metatable = {
    __index = Shape
}

function Shape.start(unit, scene)
    unit.sprite = scene:addShapeObject(unit)
end

return Shape