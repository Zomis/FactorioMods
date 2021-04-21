script.on_event(defines.events.on_player_main_inventory_changed, function(event)
	local player = game.players[event.player_index]
	if player.cursor_ghost then
		local inventory = player.get_main_inventory()
		if inventory.get_item_count(player.cursor_ghost.name) > 0 then
			local entity_result = player.cursor_ghost.place_result
			if not entity_result then
				player.print { "auto_pipette.no_entity_result", player.cursor_ghost.name }
				return
			end

			local entities = player.surface.find_entities_filtered { name = entity_result.name, force = player.force }
			local _, entity = next(entities)
			if not entity then
				game.print { "auto_pipette.no_entity_pipettable", player.cursor_ghost.name, entity_result.name }
				return
			end

			player.pipette_entity(entity)
		end
	end
end)
