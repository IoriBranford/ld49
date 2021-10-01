local Element = {}
Element.metatable = {
    __index = Element
}

function Element:start(scene)
end

function Element:setHidden(hidden)
end

return Element