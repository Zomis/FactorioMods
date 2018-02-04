local markTimeline = require "timeline"
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
	local force = event.rocket.force
	local inventory = event.rocket.get_inventory(defines.inventory.item_main)
	for k, v in pairs(inventory.get_contents()) do
		local total = force.get_item_launched(k)
		markTimeline(event.rocket.force, "rocket-launched", k, total)
	end
end)

script.on_event(defines.events.on_research_finished, function(event)
	local name = event.research.name
	local force = event.research.force
	local level = event.research.level
	markTimeline(force, "research-finished", name, level)
end)

script.on_event(defines.events.on_player_died, function(event)
	local player = game.players[event.player_index]
	markTimeline(player.force, "player-died", player.name, nil)
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
