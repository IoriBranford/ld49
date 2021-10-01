local Physics = require "Physics"
local Units = require "Units"
local Body  = require "Component.Body"
local Camera = {}

Camera.metatable = {
	__index = Camera
}

Camera.Prefab = {
	stringid = "camera",
	width = 240, height = 320,
	x = 0, y = 0,
	velx = 0, vely = -1,
	script = "Camera",
	bodytype = "dynamic",
	sensor = true,
	battlezonex = 32,
	battlezoney = 32,
	battlezonew = 240-64,
	battlezoneh = 320-64
}

function Camera:start()
    Body.start(self)

	local width = self.width
	local height = self.height
	local margin = 64
	local thickness = 64
	local offscreenrects = {
		{x = -thickness/2 - margin, y = height/2, w = thickness, h = height+2*thickness},
		{x = width + thickness/2 + margin, y = height/2, w = thickness, h = height+2*thickness},
		{x = width/2, y = -thickness/2 - margin, w = width+2*thickness, h = thickness},
		{x = width/2, y = height + thickness/2 + margin, w = width+2*thickness, h = thickness},
	}
	for i, rect in ipairs(offscreenrects) do
		local offscreeneater = Physics.addRectangleFixture(self.id,
			rect.w, rect.h, rect.x, rect.y)
		offscreeneater:setUserData("offscreeneater")
		offscreeneater:setSensor(true)
	end
end

function Camera:inputVelX(velx)
    self.velx = velx
    self.body:setLinearVelocity(self.velx, self.vely)
end

function Camera:inputVelY(vely)
    self.vely = vely
    self.body:setLinearVelocity(self.velx, self.vely)
end

function Camera:inputMove(stagewidth, vxscale)
	local player = Units.get("player")
	local playervx = player and player.velx or 0
    self.velx = playervx * vxscale

    local cameranextx = self.x + self.velx
    if cameranextx < 0 then
        self.velx = -self.x
    elseif cameranextx > stagewidth - self.width then
        self.velx = stagewidth - self.width - self.x
    end

    if self.y <= 0 then
        self.vely = -self.y
    end

    self.body:setLinearVelocity(self.velx, self.vely)
end

function Camera:think()
	self:thinkCollision()
end

function Camera:rectOnScreen(x, y, width, height)
	return math.testrects(
		self.x, self.y, self.width, self.height,
		x, y, width, height)
end

function Camera:rectInBattleZone(x, y, width, height)
	return math.testrects(
		self.x + self.battlezonex,
		self.y + self.battlezoney,
		self.width + self.battlezonew,
		self.height + self.battlezoneh,
		x, y, width, height)
end

function Camera:rectCast(callback)
	Physics.rectCast(self.x, self.y, self.width, self.height, callback)
end

function Camera:isCloseEnough(x, y)
	local hw = self.width/2
	local hh = self.height/2
	return math.lensq(self.x + hw - x, self.y + hh - y) < (hw+hh)*(hw+hh)
end

function Camera:thinkCollision()
	local body = self.body
	local contacts = body:getContacts()
	for i = 1, #contacts do
		local contact = contacts[i]
		if contact:isTouching() then
			local f1, f2 = contact:getFixtures()
			local b1, b2 = f1:getBody(), f2:getBody()
			if b2 == body then
				f1, f2 = f2, f1
				b1, b2 = b2, b1
			end
			if f1:getUserData() == "offscreeneater" then
				local id2 = b2:getUserData()
				local u2 = Units.get(id2)
				if u2 and u2.offscreenremove then
					if u2.remove then
						u2:remove("offscreen")
					else
						Units.remove(id2)
					end
				end
			end
		end
	end
end

return Camera