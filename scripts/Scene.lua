local Tiled = require "Tiled"
local Color = require "Color"

local SceneObject = {}
SceneObject.__index = SceneObject

local temptransform = love.math.newTransform()

function SceneObject.__lt(a, b)
    local az = a.z or 0
    local bz = b.z or 0
    if az < bz then
        return true
    end
    if az == bz then
        local ay = a.y or 0
        local by = b.y or 0
        if ay < by then
            return true
        end
        if ay == by then
            local ax = a.x or 0
            local bx = b.x or 0
            return ax < bx
        end
    end
end

local function animateTile(sceneobject, dt)
    local animation = sceneobject.animation
    if animation then
        local aframe = sceneobject.animationframe
        local atime = sceneobject.animationtime
        aframe, atime = Tiled.getAnimationUpdate(animation, aframe, atime + dt)
        sceneobject.animationframe = aframe
        sceneobject.animationtime = atime
        sceneobject.quad = animation[aframe].tile.quad
    end
end

function SceneObject.setTile(sceneobject, tile)
    sceneobject.drawable = tile.image
    sceneobject.quad = tile.quad
    sceneobject.width = tile.width
    sceneobject.height = tile.height
    sceneobject.ox = tile.objectoriginx
    sceneobject.oy = tile.objectoriginy
    sceneobject.animation = tile.animation
    sceneobject.animationframe = 1
    sceneobject.animationtime = 0
    sceneobject.animate = animateTile
end
local setTile = SceneObject.setTile

function SceneObject.applyTransform(sceneobject)
    temptransform:setTransformation(
        math.floor(sceneobject.x), math.floor(sceneobject.y),
        sceneobject.r,
        sceneobject.sx, sceneobject.sy,
        sceneobject.ox, sceneobject.oy,
        sceneobject.kx, sceneobject.ky)
    love.graphics.applyTransform(temptransform)
end
local applyTransform = SceneObject.applyTransform

function SceneObject.drawLine(sceneobject)
    love.graphics.push()
    applyTransform(sceneobject)

    love.graphics.setColor(sceneobject.red, sceneobject.green, sceneobject.blue, sceneobject.alpha)
    love.graphics.line(sceneobject.drawable)

    love.graphics.pop()
end
local drawLine = SceneObject.drawLine

function SceneObject.drawPolygon(sceneobject)
    love.graphics.push()
    applyTransform(sceneobject)

    local r,g,b,a = sceneobject.red, sceneobject.green, sceneobject.blue, sceneobject.alpha
    love.graphics.setColor(r,g,b,a)
    local triangles = sceneobject.drawable
    for i = 6, #triangles, 6 do
        love.graphics.polygon("fill",
            triangles[i-5], triangles[i-4],
            triangles[i-3], triangles[i-2],
            triangles[i-1], triangles[i-0])
    end

    r,g,b,a = sceneobject.linered, sceneobject.linegreen, sceneobject.lineblue, sceneobject.linealpha
    if a then
        love.graphics.setColor(r,g,b,a)
        love.graphics.polygon("line", sceneobject.points)
    end

    love.graphics.pop()
end
local drawPolygon = SceneObject.drawPolygon

function SceneObject.drawRectangle(sceneobject)
    love.graphics.push()
    applyTransform(sceneobject)

    local r,g,b,a = sceneobject.red, sceneobject.green, sceneobject.blue, sceneobject.alpha
    love.graphics.setColor(r,g,b,a)
    love.graphics.rectangle("fill", 0, 0, sceneobject.w, sceneobject.h, sceneobject.round or 0)

    r,g,b,a = sceneobject.linered, sceneobject.linegreen, sceneobject.lineblue, sceneobject.linealpha
    if a then
        love.graphics.setColor(r,g,b,a)
        love.graphics.rectangle("line", 0, 0, sceneobject.w, sceneobject.h, sceneobject.round or 0)
    end

    love.graphics.pop()
end
local drawRectangle = SceneObject.drawRectangle

function SceneObject.drawEllipse(sceneobject)
    love.graphics.push()
    applyTransform(sceneobject)

    local hw, hh = sceneobject.w/2, sceneobject.h/2

    local r,g,b,a = sceneobject.red, sceneobject.green, sceneobject.blue, sceneobject.alpha
    love.graphics.setColor(r,g,b,a)
    love.graphics.ellipse("fill", hw, hh, hw, hh)

    r,g,b,a = sceneobject.linered, sceneobject.linegreen, sceneobject.lineblue, sceneobject.linealpha
    if a then
        love.graphics.setColor(r,g,b,a)
        love.graphics.ellipse("line", hw, hh, hw, hh)
    end

    love.graphics.pop()
end
local drawEllipse = SceneObject.drawEllipse

function SceneObject.drawQuad(sceneobject)
    love.graphics.setColor(sceneobject.red, sceneobject.green, sceneobject.blue, sceneobject.alpha)
    love.graphics.draw(sceneobject.drawable, sceneobject.quad,
        math.floor(sceneobject.x), math.floor(sceneobject.y),
        sceneobject.r,
        sceneobject.sx, sceneobject.sy,
        sceneobject.ox, sceneobject.oy,
        sceneobject.kx, sceneobject.ky)
end
local drawQuad = SceneObject.drawQuad

local function drawString(sceneobject)
    love.graphics.setColor(sceneobject.red, sceneobject.green, sceneobject.blue, sceneobject.alpha)
    love.graphics.printf(sceneobject.string, sceneobject.font,
        math.floor(sceneobject.x), math.floor(sceneobject.y),
        sceneobject.w, sceneobject.halign,
        sceneobject.r,
        sceneobject.sx, sceneobject.sy,
        sceneobject.ox, sceneobject.oy,
        sceneobject.kx, sceneobject.ky)
end
SceneObject.drawString = drawString

local function drawGeneric(sceneobject)
    love.graphics.setColor(sceneobject.red, sceneobject.green, sceneobject.blue, sceneobject.alpha)
    love.graphics.draw(sceneobject.drawable,
        math.floor(sceneobject.x), math.floor(sceneobject.y),
        sceneobject.r,
        sceneobject.sx, sceneobject.sy,
        sceneobject.ox, sceneobject.oy,
        sceneobject.kx, sceneobject.ky)
end
SceneObject.drawGeneric = drawGeneric

local Scene = {}
Scene.__index = Scene

function Scene.new()
    local scene = {
        byid = {},
        animating = {}
    }
    return setmetatable(scene, Scene)
end

function Scene:add(id, draw, drawable, quad, w, h, x, y, z, r, sx, sy, ox, oy, kx, ky)
    local sceneobject = setmetatable({}, SceneObject)
    sceneobject.id = id
    sceneobject.draw = draw
    sceneobject.drawable = drawable
    if type(drawable) == "string" then
        sceneobject.string = drawable
    elseif drawable and drawable.type then
        sceneobject[drawable:type():lower()] = drawable
    end
    sceneobject.quad = quad
    sceneobject.w = w or math.huge
    sceneobject.h = h or math.huge
    sceneobject.x = x or 0
    sceneobject.y = y or 0
    sceneobject.z = z or 0
    sceneobject.r = r or 0
    sceneobject.sx = sx or 1
    sceneobject.sy = sy or sx or 1
    sceneobject.ox = ox or 0
    sceneobject.oy = oy or 0
    sceneobject.kx = kx or 0
    sceneobject.ky = ky or 0
    sceneobject.hidden = nil
    sceneobject.red = sceneobject.red or 1
    sceneobject.green = sceneobject.green or 1
    sceneobject.blue = sceneobject.blue or 1
    sceneobject.alpha = sceneobject.alpha or 1

    self.byid[id] = sceneobject
    return sceneobject
end

function Scene:addShapeObject(shapeobject)
    local w, h, x, y, z, r, sx, sy
        = shapeobject.width, shapeobject.height,
        shapeobject.x, shapeobject.y, shapeobject.z,
        shapeobject.rotation, shapeobject.scalex, shapeobject.scaley

    local sceneobject
    local shape = shapeobject.shape
    local id = shapeobject.id
    if shape == "rectangle" then
        sceneobject = self:add(id, drawRectangle, nil, nil, w, h, x, y, z, r, sx, sy)
    elseif shape == "ellipse" then
        sceneobject = self:add(id, drawEllipse, nil, nil, w, h, x, y, z, r, sx, sy)
    elseif shape == "polyline" then
        sceneobject = self:add(id, drawLine, shapeobject.points, nil, w, h, x, y, z, r, sx, sy)
    elseif shape == "polygon" then
        local triangles = shapeobject.triangles
        if triangles then
            sceneobject = self:add(id, drawPolygon, triangles, nil, w, h, x, y, z, r, sx, sy)
            sceneobject.points = shapeobject.points -- for drawing outline
        else
            sceneobject = self:add(id, drawLine, shapeobject.points, nil, w, h, x, y, z, r, sx, sy)
        end
    end

    if not sceneobject then
        return
    end

    local color = shapeobject.color
    if color then
        sceneobject.red, sceneobject.green, sceneobject.blue, sceneobject.alpha = Color.unpack(color)
    end

    local linecolor = shapeobject.linecolor
    if linecolor then
        sceneobject.linered, sceneobject.linegreen, sceneobject.lineblue, sceneobject.linealpha
            = Color.unpack(linecolor)
    end

    return sceneobject
end

function Scene:addChunk(id, chunk, x, y, z, r, sx, sy, ox, oy, kx, ky)
    local w = chunk.width * chunk.tilewidth
    local h = chunk.height * chunk.tileheight
    local sceneobject = self:add(id, drawGeneric, chunk.tilebatch, nil, w, h, x, y, z, r, sx, sy, ox, oy, kx, ky)
    return sceneobject
end

function Scene:addAnimatedChunk(id, chunk, x, y, z, r, sx, sy, ox, oy, kx, ky)
    local sceneobject = self:addChunk(id, chunk, x, y, z, r, sx, sy, ox, oy, kx, ky)
    sceneobject.batchanimations = chunk.batchanimations
    sceneobject.animationtime = 0
    sceneobject.animate = Tiled.animateChunk
    sceneobject.width = chunk.width
    sceneobject.tilewidth = chunk.tilewidth
    sceneobject.tileheight = chunk.tileheight
    sceneobject.data = chunk.data
    self.animating[id] = sceneobject
    return sceneobject
end

function Scene:addTile(id, tile, x, y, z, r, sx, sy, ox, oy, kx, ky)
    local sceneobject = self:add(id, drawQuad, tile.image, nil, nil, nil, x, y, z, r, sx, sy, nil, nil, kx, ky)
    setTile(sceneobject, tile)
    if ox then
        sceneobject.ox = ox
    end
    if oy then
        sceneobject.oy = oy
    end
    return sceneobject
end

function Scene:addAnimatedTile(id, tile, x, y, z, r, sx, sy, ox, oy, kx, ky)
    local sceneobject = self:addTile(id, tile, x, y, z, r, sx, sy, ox, oy, kx, ky)
    self.animating[id] = sceneobject
    return sceneobject
end

function Scene:addTextObject(textobject)
    local sceneobject = self:add(textobject.id, drawString, textobject.string, nil,
        textobject.width, textobject.height, textobject.x, textobject.y, textobject.z,
        textobject.rotation, textobject.scalex, textobject.scaley,
        textobject.originx, textobject.originy,
        textobject.skewx, textobject.skewy)
    sceneobject.font = textobject.font
    sceneobject.halign = textobject.halign or "left"
    sceneobject.valign = textobject.valign or "top"
    local color = textobject.color
    if color then
        sceneobject.red, sceneobject.green, sceneobject.blue = color[1], color[2], color[3]
    end
    return sceneobject
end

function Scene:addImage(id, image, x, y, z, r, sx, sy, ox, oy, kx, ky)
    return self:add(id, drawGeneric, image, nil, image:getWidth(), image:getHeight(), x, y, z, r, sx, sy, ox, oy, kx, ky)
end

function Scene:addImageLayer(imagelayer)
    local image = imagelayer.image
    local sceneobject = self:add('l'..imagelayer.id, drawGeneric, image, nil, image:getWidth(), image:getHeight(), imagelayer.x, imagelayer.y, imagelayer.z)
    sceneobject.alpha = imagelayer.opacity
    return sceneobject
end

function Scene:addTileLayer(tilelayer)
    local tilebatch = tilelayer.tilebatch
    local id = 'l'..tilelayer.id
    local layerx = tilelayer.x
    local layery = tilelayer.y
    local layerz = tilelayer.z
    if tilebatch then
        return {self:addAnimatedChunk(id, tilelayer, layerx, layery, layerz)}
    end
    local chunks = tilelayer.chunks
    if chunks then
        local cellwidth = tilelayer.tilewidth
        local cellheight = tilelayer.tileheight
        local sceneobjects = {}
        for i = 1, #chunks do
            local chunk = chunks[i]
            local chunkid = id .. 'c' .. i
            local w = chunk.width * cellwidth
            local h = chunk.height * cellheight
            local cx = chunk.x * cellwidth
            local cy = chunk.y * cellheight
            sceneobjects[i] = self:addAnimatedChunk(chunkid, chunk, layerx+cx, layery+cy, layerz)
        end
        return sceneobjects
    end
end

function Scene:addTileObject(tileobject)
    local tile = tileobject.tile
    local id = tileobject.id
    local x = tileobject.x
    local y = tileobject.y
    local z = tileobject.z
    local sprite = tileobject.animated == false
        and self:addTile(id, tile, x, y, z, tileobject.rotation, tileobject.scalex, tileobject.scaley)
        or self:addAnimatedTile(id, tile, x, y, z, tileobject.rotation, tileobject.scalex, tileobject.scaley)
    local color = tileobject.color
    if color then
        sprite.red, sprite.green, sprite.blue, sprite.alpha = Color.unpack(color)
    end
    return sprite
end

function Scene:addObject(object)
    local str = object.string
    if str then
        return self:addTextObject(object)
    end
    local tile = object.tile
    if tile then
        return self:addTileObject(object)
    end
    return self:addShapeObject(object)
end

function Scene:addMap(map, layerfilter)
    local function addLayers(layers)
        for i = 1, #layers do
            local layer = layers[i]
            local layertype = layer.type
            if layer.type == "group" then
                addLayers(layer)
            elseif not layerfilter or layerfilter:find(layertype) then
                if layertype == "tilelayer" then
                    layer.sprites = self:addTileLayer(layer)
                elseif layertype == "objectgroup" then
                    for i = 1, #layer do
                        local object = layer[i]
                        object.sprite = self:addObject(object)
                    end
                elseif layertype == "imagelayer" then
                    layer.sprite = self:addImageLayer(layer)
                end
            end
        end
    end

    addLayers(map.layers)
end

function Scene:get(id)
    return self.byid[id]
end

function Scene:remove(id)
    self.byid[id] = nil
    self.animating[id] = nil
end

function Scene:clear()
    local byid = self.byid
    local animating = self.animating
    for id, _ in pairs(byid) do
        byid[id] = nil
        animating[id] = nil
    end
    for i = #self, 1, -1 do
        self[i] = nil
    end
end

function Scene:updateFromUnit(id, unit, fixedfrac)
    local sceneobject = self.byid[id]
    if sceneobject then
        local vx, vy, vz = unit.velx, unit.vely, unit.velz or 0
        local av = unit.avel
        local x, y, z = unit.x, unit.y, unit.z
        local r = unit.rotation
        sceneobject.x = x + vx * fixedfrac
        sceneobject.y = y + vy * fixedfrac
        sceneobject.z = z + vz * fixedfrac
        sceneobject.r = r + av * fixedfrac
    end
end

function Scene:updateFromBody(id, body, fixedfrac)
    local sceneobject = self.byid[id]
    if sceneobject then
        local vx, vy = body:getLinearVelocity()
        local av = body:getAngularVelocity()
        local x, y = body:getPosition()
        local r = body:getAngle()
        sceneobject.x = x + vx * fixedfrac
        sceneobject.y = y + vy * fixedfrac
        sceneobject.r = r + av * fixedfrac
    end
end

function Scene:animate(dt)
    for id, sceneobject in pairs(self.animating) do
        sceneobject:animate(dt)
    end
end

-- local sqrt2 = math.sqrt(2)
function Scene:draw()
    -- local viewr = viewx + vieww
    -- local viewb = viewy + viewh
    local count = 0
    for id, sceneobject in pairs(self.byid) do
        -- local x = sceneobject.x
        -- local y = sceneobject.y
        -- local ox = sceneobject.ox
        -- local oy = sceneobject.oy
        -- local sx = sceneobject.sx
        -- local sy = sceneobject.sy
        -- local sxsqrt2 = sx*sqrt2
        -- local sysqrt2 = sy*sqrt2
        -- local l = x - sxsqrt2*ox
        -- local t = y - sysqrt2*oy
        -- local r = l + sxsqrt2*sceneobject.w
        -- local b = t + sysqrt2*sceneobject.h
        -- l, r = math.min(l, r), math.max(l, r)
        -- t, b = math.min(t, b), math.max(t, b)
        -- if r > viewx and viewr > l and b > viewy and viewb > t then
        if not sceneobject.hidden then
            count = count + 1
            self[count] = sceneobject
        end
        -- end
    end
    for i = #self, count+1, -1 do
        self[i] = nil
    end
    table.sort(self)

    for i = 1, #self do
        self[i]:draw()
    end
end

return Scene
