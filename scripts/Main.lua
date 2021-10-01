require("pl.strict").module("_G", _G)
require "Math"
require "Coroutine"
local Tiled = require "Tiled"
local Audio = require "Audio"
local Config = require "Config"
local Time   = require "Time"
local Controls= require "Controls"

local profile

local dsecs = 0
local dfixed = 0
local numfixed = 0
local fixedfrac = 0
local fixedrate = Time.FixedUpdateRate
local fixedlimit = 1
local variableupdate = true

function love.load()--args, unfilteredargs)
    Config.load()
    Controls.init()

    local firstphase = "Game"
    local firstmap = "data/stage_demonrealm.lua"

    local Usage = {
        Desc =	"Demonizer 1.5 engine\n",
        Console="  --console				Output to a console window\n",
        Version="  --version				Print LOVE version\n",
        Fused =	"  --fused				Force running in fused mode\n",
        Game =	"  <game>	(string)		Game assets location\n",
        Debug =	"  -debug				Debug in Zerobrane Studio\n",
        Prefs = [[
            --fullscreen			Start in fullscreen mode
            --windowed				Start in windowed mode
            --rotation	(number default -1)	Screen orientation in degrees clockwise
            --drawstats				Draw performance stats
            --drawbodies				Draw physical bodies
            --profile				Profile code performance
            --exhibit				Exhibit mode - disable options menu and quit
            --exclusive				Exclusive fullscreen
            --buildmegatilesets	(optional string)	Build megatilesets for all maps in the given text file
        ]],
        Map =	[[
            --stage  (optional string)	Name of stage to start
            --test  (optional string)	Name of test to start
            --stagestart (optional string)   Name of stage start point
        ]]
    }
	local lapp = require "pl.lapp"
	lapp.slack = true

	local options = Usage.Desc..Usage.Console..Usage.Version..Usage.Fused
	if not love.filesystem.isFused() then
		options = options .. Usage.Game
	end
	options = options .. Usage.Debug..Usage.Prefs
	options = options .. string.format(Usage.Map, firstmap)

	local args = lapp (options)

	if args.profile then
        profile = require "profile"
		profile.start()
	end

	if args.debug then
		require("mobdebug").start()
		require("mobdebug").off()
	end

    local mapname = args.stage or args.test
	if mapname then
        local map = args.stage and string.format("data/stage_%s.lua", mapname)
            or string.format("data/test_%s.lua", mapname)
		if love.filesystem.getInfo(map, "file") then
            firstphase = "Game"
			firstmap = map
		end
	end

	Config.exhibit = args.exhibit
	Config.drawbodies = args.drawbodies
	Config.drawstats = args.drawstats
	Config.exclusive = args.exclusive
    if args.rotation ~= -1 then
		Config.rotation = args.rotation
	end
    if args.fullscreen then
        Config.fullscreen = true
    elseif args.windowed then
        Config.fullscreen = false
    end
    Config.applyDisplayMode()
	love.window.setTitle(love.filesystem.getIdentity())

    Tiled.animationtimeunit = "fixedupdates"
    Tiled.setFontPath("data/fonts/")
    love.graphics.setLineStyle("rough")

    local files = love.filesystem.getDirectoryItems("data/sounds/")
    for _, file in ipairs(files) do
        Audio.load("sounds/"..file)
    end

    local stagestart = args.stagestart
    love.event.loadphase(firstphase, firstmap, stagestart)
end

local blankphase = {
    loadphase   = function() end,
    fixedupdate = function() end,
    update      = function(dsecs, fixedfrac) end,
    draw        = function(fixedfrac) end,
    quitphase   = function() end,

    displayrotated   = function(index, orientation) end,
    directorydropped = function(path) end,
    filedropped      = function(file) end,
    focus            = function(focus) end,
    mousefocus       = function(focus) end,
    resize           = function(w, h) end,
    visible          = function(visible) end,

    keypressed  = function(key, scancode, isrepeat) end,
    keyreleased = function(key, scancode) end,
    textedited  = function(text, start, length) end,
    textinput   = function(text) end,

    mousemoved    = function(x, y, dx, dy, istouch) end,
    mousepressed  = function(x, y, button, istouch, presses) end,
    mousereleased = function(x, y, button, istouch, presses) end,
    wheelmoved    = function(x, y) end,

    joystickadded   = function(joystick) end,
    joystickremoved = function(joystick) end,
    gamepadaxis     = function(joystick, axis, value) end,
    gamepadpressed  = function(joystick, button) end,
    gamepadreleased = function(joystick, button) end,

    touchmoved    = function(id, x, y, dx, dy, pressure) end,
    touchpressed  = function(id, x, y, dx, dy, pressure) end,
    touchreleased = function(id, x, y, dx, dy, pressure) end
}

function love.event.loadphase(name, ...)
    love.event.push("loadphase", name, ...)
end

function love.handlers.loadphase(name, ...)
    local nextphase = require(name)
    if love.quitphase then
        love.quitphase()
    end
    for k, v in pairs(blankphase) do
        love[k] = nextphase[k] or v
    end
    if love.loadphase then
        love.loadphase(...)
    end
    collectgarbage()
    if love.timer then
        love.timer.step()
        fixedfrac = 0
    end
end

local keypressedhandler = love.handlers.keypressed
function love.handlers.keypressed(...)
    keypressedhandler(...)
    Controls.keypressed(...)
end

local gamepadpressedhandler = love.handlers.gamepadpressed
function love.handlers.gamepadpressed(...)
    gamepadpressedhandler(...)
    Controls.gamepadpressed(...)
end

function love.quit()
    if love.quitphase then
        love.quitphase()
    end
    Audio.clear()
    Config.save()
	if profile then
		local filename = os.date("profile_%Y-%m-%d_%H-%M-%S")..".txt"
		love.filesystem.write(filename, profile.report())
	end
end

function love.run()
    if love.load then
        love.load(love.arg.parseGameArguments(arg), arg)
    end
    collectgarbage()

    -- We don't want the first frame's dsecs to include time taken by love.load.
    if love.timer then
        love.timer.step()
    end

    local mainloop = function()
        -- Process events.
        if love.event then
            love.event.pump()
            for name, a, b, c, d, e, f in love.event.poll() do
                if name == "quit" then
                    if not love.quit or not love.quit() then
                        return a or 0
                    end
                else
                    love.handlers[name](a, b, c, d, e, f)
                end
            end
        end

        -- Update dsecs, as we'll be passing it to update
        if love.timer then
            dsecs = love.timer.step()
        end

        -- Call update and draw
        if love.fixedupdate then
            dfixed = dsecs * fixedrate
            fixedfrac = fixedfrac + dfixed
            numfixed, fixedfrac = math.modf(fixedfrac)
            numfixed = math.min(numfixed, fixedlimit)
            for i = 1, numfixed do
                love.fixedupdate()
                Controls.clearButtonsPressed()
                collectgarbage("step", 1)
            end
        end

        if love.update then
            if variableupdate then
                love.update(dsecs, fixedfrac)
            elseif numfixed > 0 then
                love.update(numfixed / fixedrate, 0)
            end
        end -- will pass 0 if love.timer is disabled

        if love.graphics and love.graphics.isActive() then
            love.graphics.origin()
            love.graphics.clear(love.graphics.getBackgroundColor())

            if love.draw then
                love.draw(fixedfrac)
            end

            if Config.drawstats then
                love.graphics.printf(tostring(love.timer.getFPS()).." fps", 0, 0, love.graphics.getWidth(), "right")
                love.graphics.printf(tostring(math.floor(collectgarbage("count"))).." kb", 0, 16, love.graphics.getWidth(), "right")
            end

            love.graphics.present()
        end

        collectgarbage("step", 2)
        if love.timer then
            love.timer.sleep(0.001)
        end
    end

    return mainloop
end
