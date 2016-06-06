require "defines"
require "trackentities"

script.on_event(defines.events.on_tick, function(event)
	if event.tick % 60 == 0 then
		for name, force in pairs(game.forces) do
			local silos = global.silos
			for i, entity in ipairs(silos) do
				launchIfReady(entity)
			end
		end
	end
end)

function scanAllRockets(event)
	full_scan(game.get_surface(1), "silos", nil, { "rocket-silo" })
end

script.on_init(scanAllRockets)

setupTracking("silos", { "rocket-silo" })

function launchIfReady(silo)
    if not silo.valid then
        return false
    end
	if siloIsReady(silo) then
		silo.launch_rocket()
	end
end

function siloIsReady(silo)
    if not silo.valid then
        return false
    end
	return silo.get_item_count("satellite") > 0
end
