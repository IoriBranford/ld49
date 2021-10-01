local Physics = require "Physics"
local Units = require "Units"
local Sprite = require "Component.Sprite"
local Time    = require "Time"

local Target = {}

function Target.start(unit)
	local targetcrosshairs = {}
	unit.targetcrosshairs = targetcrosshairs
	for i = 1, 4 do
		local crosshair = Units.newUnit("crosshair"..i)
		if not crosshair then
			break
		end
		crosshair.visible = false
		targetcrosshairs[i] = crosshair
	end
end

function Target.remove(unit)
	local targetcrosshairs = unit.targetcrosshairs
	if not targetcrosshairs then
		return
	end
	for i = 1, #targetcrosshairs do
		Units.remove(targetcrosshairs[i])
	end
end

local PulseAmplitude = 4
local PulseFrequency = 2

function Target.thinkCrosshairs(unit, target)
	local targetcrosshairs = unit.targetcrosshairs
	if not targetcrosshairs then
		return
	end

	if not target then
		for i = 1, #targetcrosshairs do
			local crosshair = targetcrosshairs[i]
			Sprite.setHidden(crosshair, true)
		end
		return
	end

	local t = unit.age * math.pi * PulseFrequency / Time.FixedUpdateRate
	local pulse = PulseAmplitude * math.sin(t)
	local targetx, targety = target.x, target.y
	local targethw = target.width/2
	local targethh = target.height/2
	for i = 1, #targetcrosshairs do
		local crosshair = targetcrosshairs[i]
		Sprite.setHidden(crosshair, false)

		local x, y = targetx, targety
		local pulseangle = crosshair.pulseangle
		if pulseangle then
			x = x + math.cos(pulseangle) * (targethw + pulse)
			y = y + math.sin(pulseangle) * (targethh + pulse)
		end
		crosshair.x = x
		crosshair.y = y
	end
end

local function accept() return true end

function Target.rayCast(x1, y1, x2, y2, filter)
	local foundtarget = nil
	local foundtargetdist = math.huge
	filter = filter or accept
	Physics.rayCast(x1, y1, x2, y2, function(fixture, x, y, xn, yn, fraction)
		local id = fixture:getUserData()
		if not id then
			return -1
		end

		local unit = Units.get(id)
		if not unit then
			return -1
		end

		if not filter(unit) then
			return -1
		end

		if not foundtargetdist or fraction < foundtargetdist then
			foundtarget = unit
			foundtargetdist = fraction
		end
		return 1
	end)

	return foundtarget
end

return Target
