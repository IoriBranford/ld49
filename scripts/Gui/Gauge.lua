local Color = require "Color"
local Sprite= require "Component.Sprite"

local Gauge = {}
setmetatable(Gauge, Sprite.metatable)
Gauge.metatable = {
    __index = Gauge
}

local function draw(gauge)
	local barw = gauge.barw
	local barh = gauge.barh
	if barw > 0 or barh > 0 then
		love.graphics.setColor(gauge.barred, gauge.bargreen, gauge.barblue, gauge.baralpha)
		local barx = gauge.barx
		local bary = gauge.bary
		love.graphics.push()
		gauge:applyTransform()
		local rects = gauge.barrects
		if rects then
			local barx2 = barx + barw
			local bary2 = bary + barh
			for i = 1, #rects do
				local rect = rects[i]
				local rectx, recty = rect.x, rect.y
				local width, height = rect.width, rect.height
				local x = math.max(rectx, barx)
				local y = math.max(recty, bary)
				local x2 = math.min(rectx + width, barx2)
				local y2 = math.min(recty + height, bary2)
				if x < x2 and y < y2 then
					love.graphics.rectangle("fill", x, y, x2-x, y2-y,
						rect.roundx, rect.roundy)
				end
			end
		else
			love.graphics.rectangle("fill", barx, bary, barw, barh)
		end
		love.graphics.pop()
	end
    if gauge.quad then
        gauge:drawQuad()
    end
end

function Gauge:setHidden(hidden)
	self.gauge.hidden = hidden
end

function Gauge:getPercent()
	return self.gaugepercent
end

function Gauge:setPercent(percent)
	self.gaugepercent = percent
	local barminx = self.barminx
	local barminy = self.barminy
	local barmaxw = self.barmaxw
	local barmaxh = self.barmaxh

	local gauge = self.gauge
	local direction = self.gaugedirection
	if direction == "left" then
		gauge.barx = barminx + barmaxw*(1 - percent)
		gauge.bary = barminy
		gauge.barw = barmaxw*percent
		gauge.barh = barmaxh
	elseif direction == "up" then
		gauge.barx = barminx
		gauge.bary = barminy + barmaxh*(1 - percent)
		gauge.barw = barmaxw
		gauge.barh = barmaxh*percent
	elseif direction == "right" then
		gauge.barx = barminx
		gauge.bary = barminy
		gauge.barw = barmaxw*percent
		gauge.barh = barmaxh
	else
		gauge.barx = barminx
		gauge.bary = barminy
		gauge.barw = barmaxw
		gauge.barh = barmaxh*percent
	end
end

function Gauge:start(scene)
	local barx = math.huge
	local bary = math.huge
	local barw = 0
	local barh = 0

    local tile = self.tile
    local gauge = Sprite.start(self, scene)
    if gauge then
        gauge.draw = draw
    else
        gauge = scene:add(self.id, draw, nil, nil, self.width, self.height, self.x, self.y, self.z, self.rotation, self.scalex, self.scaley)
    end

    local gaugecolor = self.gaugecolor or "ffffffff"
    gauge.barred, gauge.bargreen, gauge.barblue, gauge.baralpha = Color.unpack(gaugecolor)

    local shapes = tile and tile.shapes
	if shapes then
        local barrects = {}
        gauge.barrects = barrects
		local barx2 = -math.huge
		local bary2 = -math.huge
		for _, shape in ipairs(shapes) do
			if shape.shape == "rectangle" then
				local roundx = shape.roundx or 0
				local roundy = shape.roundy or roundx
				local rect = {
					roundx = roundx,
					roundy = roundy,
					width = shape.width,
					height = shape.height
				}
				barrects[#barrects+1] = rect

                local rectx, recty = shape.x + tile.objectoriginx, shape.y + tile.objectoriginy
				rect.x = rectx
				rect.y = recty

				barx = math.min(barx, rectx)
				bary = math.min(bary, recty)
				barx2 = math.max(barx2, rectx + rect.width)
				bary2 = math.max(bary2, recty + rect.height)
			end
		end
		barw = barx2 - barx
		barh = bary2 - bary
	else
		barx = 0
		bary = 0
		barw = self.width
		barh = self.height
	end

	self.gauge = gauge
	self.barminx = barx
	self.barminy = bary
	self.barmaxw = barw
	self.barmaxh = barh
	gauge.barx = barx
	gauge.bary = bary
	gauge.barw = barw
	gauge.barh = barh
	self:setPercent(1)
	return gauge
end

return Gauge
