local Physics = require "Physics"
local Audio   = require "Audio"
local Units   = require "Units"

local Body = {}

function Body.start(unit)
    local id, x, y = unit.id, unit.x, unit.y
    local body = unit.body
    if not body then
        local bodytype = unit.bodytype
        body = bodytype and Physics.addBody(id, x, y, bodytype)
        unit.body = body
    end
    if body then
        body:setFixedRotation(not unit.bodyrotation)
        body:setAngle(unit.bodyrotation and unit.rotation or 0)
        local velx = unit.velx or 0
        local vely = unit.vely or 0
        body:setLinearVelocity(velx, vely)
		body:setSleepingAllowed(not unit.bodystayawake)
        for i, fixture in pairs(body:getFixtures()) do
            fixture:destroy()
        end
		local tile = unit.tile
        if tile then
            -- local bodyshapes = self.bodyshapes or self.bodyshape
            local shapes = tile.shapes
			if shapes then
				for i = 1, #shapes do
					local shapeobject = shapes[i]
					if shapeobject.collidable then
						local shape = shapeobject.shape
						local w = shapeobject.width or 1
						local h = shapeobject.height or 1
						local fixture
						if shape == "rectangle" then
							fixture = Physics.addRectangleFixture(id, w, h,
								shapeobject.x+w/2,
								shapeobject.y+h/2)
						elseif shape == "ellipse" then
							local r = (w + h) / 4
							fixture = Physics.addCircleFixture(id, r,
								shapeobject.x+w/2,
								shapeobject.y+h/2)
						elseif shape == "polygon" then
							local points = shapeobject.points
							if #points <= 16 then
								fixture = Physics.addPolygonFixture(id, points)
							else
								fixture = Physics.addChainFixture(id, true, points)
							end
						elseif shape == "polyline" then
							fixture = Physics.addChainFixture(id, false, shapeobject.points)
						end
						if fixture then
							fixture:setFriction(shapeobject.friction or 0)
							fixture:setSensor(shapeobject.sensor or unit.sensor or false)
						end
					end
				end
			end
			-- if bodyshapes and shapes then
			-- 	for bodyshape in bodyshapes:gmatch("%S+") do
			-- 		local shapeobject = shapes[bodyshape]
			-- 		if shapeobject then
			-- 			local shape = shapeobject.shape
			-- 			local w = shapeobject.width or 1
			-- 			local h = shapeobject.height or 1
			-- 			local fixture
			-- 			if shape == "rectangle" then
			-- 				fixture = Physics.addRectangleFixture(id, w, h, shape.x, shape.y)
			-- 			elseif shape == "ellipse" then
			-- 				local r = (w + h) / 4
			-- 				fixture = Physics.addCircleFixture(id, r, shape.x, shape.y)
			-- 			end
			-- 			if fixture then
			-- 				fixture:setFriction(shapeobject.friction or 0)
			-- 				fixture:setSensor(shapeobject.sensor or false)
			-- 			end
			-- 		end
			-- 	end
			-- end
        else
            local shape = unit.shape
            local fixture
            local w = unit.width or 1
            local h = unit.height or 1
            if shape == "rectangle" then
                fixture = Physics.addRectangleFixture(id, w, h, w/2, h/2)
            elseif shape == "ellipse" then
                local r = (w + h) / 4
                fixture = Physics.addCircleFixture(id, r, w/2, h/2)
            elseif shape == "polygon" then
				local points = unit.points
				if #points <= 16 then
					fixture = Physics.addPolygonFixture(id, points)
				else
					fixture = Physics.addChainFixture(id, true, points)
				end
			elseif shape == "polyline" then
				fixture = Physics.addChainFixture(id, false, unit.points)
            end
            if fixture then
                fixture:setFriction(unit.friction or 0)
				-- fixture:setDensity(0)
                fixture:setSensor(unit.sensor or false)
            end
        end
		body:setBullet(unit.bodybullet or false)
		-- body:setMass(1)
    end
end

local function takeHitDamage(unit, other)
	local otherenemyteams = other.enemyteams
	if not otherenemyteams then
		return 0
	end
	for otherenemyteam in otherenemyteams:gmatch("%S+") do
		if otherenemyteam == unit.team then
			local damagefromenemy = other.hitdamageenemy or 0
			local damageself = unit.hitdamageself or 0
			local hitdamage = damagefromenemy + damageself

			Audio.play("sounds/hit.ogg")
			local hitspark = hitdamage > 0 and "sparks_small_enemydamage" or "sparks_small_enemyguard"
			local x1, y1 = unit.x, unit.y
			local x2, y2 = other.x, other.y
			local distx, disty = x2-x1, y2-y1
			local x, y = x1 + distx/4, y1 + disty/4
			Units.newUnit_position(hitspark, x, y, unit.z)
			return hitdamage
		end
	end
	return 0
end

function Body.thinkCollision(unit, onCollision)
	local body = unit.body
	if not body then
		return
	end
	for _, contact in pairs(body:getContacts()) do
		if contact:isTouching() then
			local f1, f2 = contact:getFixtures()
			local b1, b2 = f1:getBody(), f2:getBody()
			if b2 == body then
				b1, b2 = b2, b1
			end
			local id2 = b2:getUserData()
            local other = id2 and Units.get(id2)
            if other then
				onCollision(unit, other, contact)
            end
		end
	end
end

return Body