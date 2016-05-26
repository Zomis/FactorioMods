require "defines"

script.on_event(defines.events.on_tick, function(event)
	if event.tick % 60 == 0 then
		for name, force in pairs(game.forces) do
			local silos = findType("rocket-silo", force)
			for i, entity in ipairs(silos) do
				launchIfReady(entity)
			end
		end
	end
end)

function scanAllRockets(event)
	full_scan("silos", { "rocket-silo" })
	
end

script.on_init(scanAllRockets)
script.on_load(scanAllRockets)

setup("silos", { "rocket-silo" })

function launchIfReady(silo)
	if siloIsReady(silo) then
		silo.launch_rocket()
	end
end

function siloIsReady(silo)
	return silo.get_item_count("satellite") > 0
end

function findType(entity_type, force)
	if force == nil then
		return {}
	end
	local results = { }
	local surface = game.get_surface(1)
	for coord in surface.get_chunks() do
		local X, Y = coord.x, coord.y;

		if surface.is_chunk_generated { X, Y } then
			local area = {{X*32, Y*32}, {X*32 + 32, Y*32 + 32}}
			for _, entity in pairs(surface.find_entities_filtered { area = area, type = entity_type, force = force.name}) do
				table.insert(results, entity)
			end
		end
	end
	return results
end

