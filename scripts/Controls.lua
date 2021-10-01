local Controls = {}
local Config = require "Config"

local DefaultMapping = "%s,%s,a:b0,b:b1,back:b6,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,dpup:h0.1,guide:b8,leftshoulder:b4,leftstick:b9,lefttrigger:a2,leftx:a0,lefty:a1,rightshoulder:b5,rightstick:b10,righttrigger:a5,rightx:a3,righty:a4,start:b7,x:b2,y:b3,platform:%s,"

local buttonspressed = {}

function Controls.init()
	if love.filesystem.getInfo("data/gamecontrollerdb.txt", "file") then
		love.joystick.loadGamepadMappings("data/gamecontrollerdb.txt")
	end
    if love.filesystem.getInfo("gamecontrollerdb.txt", "file") then
        love.joystick.loadGamepadMappings("gamecontrollerdb.txt")
    end
	local os = love.system.getOS()
	local GCDBOS = {
		["OS X"] = "Mac OS X"
	}
	os = GCDBOS[os] or os
	local joysticks = love.joystick:getJoysticks()
	for i = 1, #joysticks do
		local joystick = joysticks[i]
		if not joystick:isGamepad() then
			local mapping = string.format(DefaultMapping, joystick:getGUID(), joystick:getName(), os)
			love.joystick.loadGamepadMappings(mapping)
		end
	end
	love.joystick.saveGamepadMappings("gamecontrollerdb.txt")
end

function Controls.getDirectionInput()
	local numinputs = 0
	local x, y = 0, 0
	local deadzonesq = 1/16

	local joysticks = love.joystick:getJoysticks()
	for i = 1, #joysticks do
		local joystick = joysticks[i]
		local jx = joystick:getGamepadAxis("leftx")
		local jy = joystick:getGamepadAxis("lefty")
		local hl = joystick:isGamepadDown("dpleft")
		local hr = joystick:isGamepadDown("dpright")
		local hu = joystick:isGamepadDown("dpup")
		local hd = joystick:isGamepadDown("dpdown")
		if jx*jx + jy*jy > deadzonesq then
			numinputs = numinputs + 1
			x = x + jx
			y = y + jy
		end
		if hl or hr or hu or hd then numinputs = numinputs + 1 end
		if hl then x = x - 1 end
		if hr then x = x + 1 end
		if hu then y = y - 1 end
		if hd then y = y + 1 end
	end

	local kl = love.keyboard.isDown(Config.key_left)
	local kr = love.keyboard.isDown(Config.key_right)
	local ku = love.keyboard.isDown(Config.key_up)
	local kd = love.keyboard.isDown(Config.key_down)
	if kl or kr or ku or kd then numinputs = numinputs + 1 end
	if kl then x = x - 1 end
	if kr then x = x + 1 end
	if ku then y = y - 1 end
	if kd then y = y + 1 end

	if numinputs > 1 then
		x = x / numinputs
		y = y / numinputs
	end
	return x, y
end

function Controls.getButtonsDown()
	local action1 = love.keyboard.isDown(Config.key_action1)
	local action2 = love.keyboard.isDown(Config.key_action2)
	local action3 = love.keyboard.isDown(Config.key_action3)

	local joysticks = love.joystick:getJoysticks()
	for i = 1, #joysticks do
		local joystick = joysticks[i]
		action1  = action1  or joystick:isGamepadDown(Config.joy_action1)
		action2 = action2 or joystick:isGamepadDown(Config.joy_action2)
		action3  = action3  or joystick:isGamepadDown(Config.joy_action3)
	end
	return action1, action2, action3
end

function Controls.getButtonsPressed()
	return buttonspressed.action1, buttonspressed.action2, buttonspressed.action3, buttonspressed.start
end

function Controls.keypressed(key)
	if key == Config.key_action1 then
		buttonspressed.action1 = true
	elseif key == Config.key_action2 then
		buttonspressed.action2 = true
	elseif key == Config.key_action3 then
		buttonspressed.action3 = true
	elseif key == Config.key_start then
		buttonspressed.start = true
	end
end

function Controls.gamepadpressed(joystick, button)
	if button == Config.joy_action1 then
		buttonspressed.action1 = true
	elseif button == Config.joy_action2 then
		buttonspressed.action2 = true
	elseif button == Config.joy_action3 then
		buttonspressed.action3 = true
	elseif button == Config.joy_start then
		buttonspressed.start = true
	end
end

function Controls.clearButtonsPressed()
	for k,v in pairs(buttonspressed) do
		buttonspressed[k] = nil
	end
end

function Controls.updateDialogueState(dialoguestate)
	if not Config.game_dialogue or dialoguestate == "skip" then
		return "skip"
	end
	local action1, action2, action3, start = Controls.getButtonsPressed()
	if start then
		return "skip"
	end
	if action1 or action2 or action3 then
		return "advance"
	end
end

return Controls