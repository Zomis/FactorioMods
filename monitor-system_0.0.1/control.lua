require "defines"
--require "craftingcheck"

script.on_init(function()
    initPlayers()
end)

script.on_event(defines.events.on_player_created, function(event)
    playerCreated(event)
end)

function posToString(position)
	return tostring(position.x) .. ", " .. tostring(position.y)
end

script.on_event(defines.events.on_gui_click, function(event)
	local element = event.element
	local playerIndex = event.player_index
	local player = game.players[playerIndex]
	local force = player.force
	if element.name == "monitor" then
		-- in the future, show some GUI
		-- for now, get some data
		
		
		-- scan for assembling machines
		local machines = findType("assembling-machine", force)
		
		-- find assembling machines for science pack 3
		for i, entity in ipairs(machines) do
			local recipe = entity.recipe
			if recipe ~= nil and recipe.name == "science-pack-3" then
				-- find out why they don't do anything
				-- find out their productivity (how often they do something)
				local info = getAssemblingInfo(entity)
				
				-- print information to player
				player.print(tostring(info.productivity) .. " missing " .. info.missing .. " pos " .. posToString(info.position))
			end
		end
    end
	
	if element.name == "locationViewBack-monitor-system" then
		resetPosition(player, playerIndex)
	end
end)

function findFluid(fluidbox, name)
	local count = #fluidbox
	for i = 1, count do
		if fluidbox[i].type == name then
			return fluidbox[i].amount
		end
	end
	return 0
end

function getAssemblingInfo(entity)
	local info = {}
	info.position = entity.position
	info.productivity = -1
	
	local required = entity.recipe.ingredients
	local current = entity.get_inventory(defines.inventory.assembling_machine_input)
	local currentFluid = entity.fluidbox
	
	local missingString = ""
	for i, ingredient in pairs(required) do
		local ingredientName = ingredient.name
		local requiredAmount = ingredient.amount
		local currentAmount
		if ingredient.type == "fluid" then
			currentAmount = findFluid(currentFluid, ingredientName)
		else
			currentAmount = current.get_item_count(ingredientName)
		end
		local missingAmount = requiredAmount - currentAmount
		if missingAmount > 0 then
			if missingString ~= "" then
				missingString = missingString .. ", "
			end
			missingString = missingString .. tostring(missingAmount) .. " " .. ingredientName
		end
	end
	
	info.missing = missingString
	return info
end

function initPlayers()
    for _, player in ipairs(game.players) do
        initPlayer(player)
    end
end

function playerCreated(event)
    local player = game.players[event.player_index]
    initPlayer(player)
end

function initPlayer(player)
    player.gui.left.add { type="button", name="monitor", caption="Monitor" }
end

function findType(entity_type, force)
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

