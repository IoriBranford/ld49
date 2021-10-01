local Units = require "Units"
local Audio = require "Audio"
local Team   = require "Component.Team"
local Prefabs  = require "Prefabs"

local Health = {}

local function calcHitDamage(unit, other)
	if not Team.isEnemyOf(unit, other) then
		return 0
	end

	local damagefromenemy = other.hitdamageenemy or 0
	local damageself = unit.hitdamageself or 0
	local damage = damagefromenemy + damageself

	local hitspark = damage > 0 and other.enemydamagespark or other.enemyguardspark
	hitspark = Prefabs.get(hitspark)
	if hitspark then
		local x1, y1 = unit.x, unit.y
		local x2, y2 = other.x, other.y
		local distx, disty = x2-x1, y2-y1
		local x, y = x1 + distx/4, y1 + disty/4
		Units.newUnit_position(hitspark, x, y, unit.z)
	end

	return damage
end

function Health.onCollision_damage(unit, other)
    if unit.health then
		local damage = calcHitDamage(unit, other)
	    unit.health = unit.health - damage
    end

	if not other.think then
		local health = other.health
		if health then
			local damage = calcHitDamage(other, unit)
			health = health - damage
			other.health = health
			if health < 1 then
				Units.remove(other)
			end
		end
	end
end


function Health.changeColor(unit, r, g, b)
    local health = unit.health
    if health and health < unit.starthealth/2 and unit.age % health == 0 then
		r = 1
        g = 0
        b = 0
    end
	return r, g, b
end

return Health