local Units = require "Units"
local Pathing = require "Component.Pathing"
local Sprite  = require "Component.Sprite"
local Body    = require "Component.Body"

local Unit = {}

local function matchVelocity(follower, leader)
	follower.velx, follower.vely = leader.velx, leader.vely
end

function Unit.startDefeatedDrunkEnemy(unit, scene)
    Sprite.start(unit, scene)
    Body.start(unit)
	unit.emote = Units.newUnit_position("emotes_drunk", unit.x, unit.y-16, unit.z+1)
end

function Unit.thinkDefeatedDrunkEnemy(unit)
	local camera = Units.get("camera")
	local camerabottom = camera.y + camera.height
	if unit.y > camerabottom then
		Units.remove(unit)
		Units.remove(unit.emote)
	end
end

function Unit.startFleeingCivilian(unit, scene)
    Sprite.start(unit, scene)
    Body.start(unit)
    Pathing.start(unit)
	unit.emote = Units.newUnit_position("emotes_sweat", unit.x, unit.y-16, unit.z+1)
end

function Unit.thinkFleeingCivilian(unit)
	Pathing.walkPath(unit)
	local emote = unit.emote
	if Pathing.isAtEnd(unit) then
		Units.remove(unit)
		Units.remove(emote)
	else
		matchVelocity(emote, unit)
	end
end

function Unit:startDefault(scene)
	Sprite.start(self, scene)
	Body.start(self)
end

function Unit.isOnScreen(unit)
	local camera = Units.get("camera")
	local x, y, w, h = unit.x, unit.y, unit.width, unit.height
	local sprite = unit.sprite
	if sprite then
		x = x - sprite.ox
		y = y - sprite.oy
	end
	return camera:rectOnScreen(x, y, w, h)
end

function Unit.isInBattle(unit)
	local camera = Units.get("camera")
	local x, y, w, h = unit.x, unit.y, unit.width, unit.height
	local sprite = unit.sprite
	if sprite then
		x = x - sprite.ox
		y = y - sprite.oy
	end
	return camera:rectInBattleZone(x, y, w, h)
end

return Unit