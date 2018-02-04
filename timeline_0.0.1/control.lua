local gui = require "gui"
require "interface"
require "htmlsave"

local force_data

script.on_init(function()
	global.forces = global.forces or {}
	force_data = global.forces
end)

script.on_load(function()
	force_data = global.forces
end)

script.on_event(defines.events.on_rocket_launched, function(event)
  local forceData = global.forces[event.rocket.force.name]
	forceData.rockets_launched = forceData.rockets_launched or 0
	forceData.rockets_launched = forceData.rockets_launched + 1
	markTimeline(event.rocket.force, "rocket-launched", forceData.rockets_launched, forceData.rockets_launched)
end)

function markTimeline(force, name, params, value)
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

script.on_event(defines.events.on_research_finished, function(event)
	local name = event.research.name
	local force = event.research.force
	local forceData = global.forces[force.name]
	forceData.research = forceData.research or {}
	local level = forceData.research[name] or 0
	forceData.research[name] = level + 1
	markTimeline(force, "research-finished", name, level + 1)
end)

function on_tick()
	-- /c for k, v in pairs(game.player.force.item_production_statistics.input_counts) do game.print(k .. " = " .. v) end
	for _, force in pairs(game.forces) do
		if not force_data[force.name] then
			force_data[force.name] = {}
		end
		if not force_data[force.name].next_stats then
			force_data[force.name].next_stats = {}
		end

		local next_stats = force_data[force.name].next_stats
		-- force.item_production_statistics.get_input_count("stone-brick")
		for key, count in pairs(force.item_production_statistics.input_counts) do
			if not next_stats[key] then
				markTimeline(force, "produced", key, 1)
				next_stats[key] = 10
			elseif count >= next_stats[key] then
				markTimeline(force, "produced", key, next_stats[key])
				next_stats[key] = next_stats[key] * 10
			end
		end
	end
end

script.on_event(defines.events.on_tick, on_tick)
