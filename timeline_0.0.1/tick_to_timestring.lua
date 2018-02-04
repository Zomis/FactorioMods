local TICKS_PER_SECOND = 60

local function tick_to_timestring(tick)
  local seconds = math.floor(tick / TICKS_PER_SECOND)
	local minutes = math.floor(seconds / 60)
	local hours = math.floor(minutes / 60)
	return string.format("%02d:%02d:%02d", hours, minutes % 60, seconds % 60)
end

return tick_to_timestring
