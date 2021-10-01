local Timer = {}

function Timer.start(unit, timername)
	local time = unit[timername]
	if time == "animation" then
		local tile = unit.tile
		local animation = tile and tile.animation
		time = animation and animation.duration or 60
		-- time = math.floor(time)
		unit[timername] = time
	end
end

function Timer.think(unit, timername)
	local time = unit[timername] or 60
	time = time - 1
	unit[timername] = time
	return time
end

return Timer