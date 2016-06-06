function full_scan(key, force, entity_types)
	global[key] = findTypes(entity_types, force)
end

function findTypes(entity_types, force)
	local results = { }
	local surface = game.get_surface(1)
    for i, entity_type in ipairs(entity_types) do
        for coord in surface.get_chunks() do
            local X, Y = coord.x, coord.y;

            if surface.is_chunk_generated { X, Y } then
                local area = {{X*32, Y*32}, {X*32 + 32, Y*32 + 32}}
                for _, entity in pairs(surface.find_entities_filtered { area = area, name = entity_type, force = force}) do
                    table.insert(results, entity)
                end
            end
        end
    end
	return results
end

function setupTracking(key, entity_types)
	function entityBuilt(event, entity)
		for i, entity_type in ipairs(entity_types) do
			if entity_type == entity.name then
				global[key] = global[key] or {}
				table.insert(global[key], entity)
			end
		end
	end

	function entityMined(event, entity)
		for i, entity_type in ipairs(entity_types) do
			if entity_type == entity.name then
				global[key] = global[key] or {}
				for idx, e in pairs(global[key]) do
					if e == entity then
						table.remove(global[key], idx)
					end
				end
			end
		end
	end

    global[key] = global[key] or {}

	script.on_event(defines.events.on_built_entity, function(event)
		entityBuilt(event, event.created_entity)
	end)

	script.on_event(defines.events.on_robot_built_entity, function(event)
		entityBuilt(event, event.created_entity)
	end)

	script.on_event(defines.events.on_preplayer_mined_item, function(event)
		entityMined(event, event.entity)
	end)

	script.on_event(defines.events.on_robot_pre_mined, function(event)
		entityMined(event, event.entity)
	end)

	script.on_event(defines.events.on_entity_died, function(event)
		entityMined(event, event.entity)
	end)
end
