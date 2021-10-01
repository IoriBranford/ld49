local Tiled = require "Tiled"
local Scene = require "Scene"
local Text   = require "Component.Text"
local Sprite  = require "Component.Sprite"
local Element  = require "Gui.Element"

local Gui = {}

local scene

local function addLayerToScene(layer)
    local layertype = layer.type
    local layerhidden = layer.visible == false
    if layertype == "group" then
        for i = 1, #layer do
            addLayerToScene(layer[i])
        end
    elseif layertype == "objectgroup" then
        for i = 1, #layer do
            local object = layer[i]
            local script = object.script
            if script then
                script = require(script)
            elseif object.string then
                script = Text
            elseif object.tile then
                script = Sprite
            else
                script = Element
            end

            setmetatable(object, script.metatable)
            object:start(scene)
            object:setHidden(layerhidden or object.visible == false)
        end
    end
end

function Gui.load(filename)
    scene = Scene.new()
    local map = Tiled.load(filename)
    local layers = map.layers
    Gui.root = layers

    for i, layer in ipairs(layers) do
        addLayerToScene(layer)
    end
end

function Gui.clear()
	scene = nil
    Gui.root = nil
end

function Gui.setLayerHidden(layername, hidden)
    local layer = Gui.root[layername]
    if not layer then
        return
    end
    for _, object in ipairs(layer) do
        object:setHidden(hidden)
    end
end

function Gui.showLayer(layername, visibleobjects)
    Gui.setLayerHidden(layername, nil)
    if visibleobjects then
        Gui.showOnlyLayerObjects(layername, visibleobjects)
    end
end

function Gui.showOnlyLayer(layername, visibleobjects)
    for i, layer in ipairs(Gui.root) do
        Gui.setLayerHidden(layer.name, layer.name ~= layername)
    end
    if visibleobjects then
        Gui.showOnlyLayerObjects(layername, visibleobjects)
    end
end

function Gui.showOnlyLayerObjects(layername, visibleobjects)
    local layer = Gui.root[layername]
    if not layer then
        return
    end
    for i, object in ipairs(layer) do
        object:setHidden(not visibleobjects[object.name])
    end
end

function Gui.fixedupdate()
    scene:animate(1)
end

function Gui.draw()
    scene:draw()
end

return Gui