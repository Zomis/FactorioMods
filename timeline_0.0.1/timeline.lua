local gui = require "gui"

local function markTimeline(force, name, params, value)
	for _, player in ipairs(force.players) do
		gui.create_menu_gui_for(player)
	end
	local mark = { name = name, param = params, tick = game.tick }
	if value then
		mark.value = value
	end
	local forceData = global.forces[force.name]
	if not forceData then
		forceData = {}
		global.forces[force.name] = forceData
	end
	forceData.allMarks = forceData.allMarks or {}

	-- mark timeline
	table.insert(forceData.allMarks, mark)
	force.print("Timeline: " .. mark.name .. " - " .. mark.param .. " with value " .. tostring(value) .. " at " .. mark.tick)
end

return markTimeline
