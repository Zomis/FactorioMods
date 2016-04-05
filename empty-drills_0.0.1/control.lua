require "defines"
require "tempview"

function distance(position1, position2)
	return ((position1.x - position2.x)^2 + (position1.y - position2.y)^2)^0.5
end

script.on_init(function()
    initPlayers()
end)

script.on_event(defines.events.on_player_created, function(event)
    playerCreated(event)
end)

script.on_event(defines.events.on_resource_depleted, function(event)
	local resource = event.entity
    for _, player in ipairs(game.players) do
		local drills = findMiningDrillsFor(resource)
		for i, drill in pairs(drills) do
			if drillIsEmpty(drill) then
				player.print("Useless Drill " .. drill.name .. " at " .. drill.position.x .. ", " .. drill.position.y .. " used to mine " .. resource.name)
			end
		end
    end
end)

script.on_event(defines.events.on_gui_click, function(event)
	local element = event.element
	local playerIndex = event.player_index
	local player = game.players[playerIndex]
	local force = player.force
	if element.name == "empty_drills" then
		-- loop through map and scan for empty drills
		local drills = scanEmptyDrills(force)
		local uselessCount = #drills
		player.print("There are " .. uselessCount .. " useless drills. Showing closest")
		
		-- Find closest unused drill
		local minDistance = nil
		local closestDrill = nil
		for _, drill in ipairs(drills) do
			local distance = distance(player.position, drill.position)
			if minDistance == nil or distance < minDistance then
				minDistance = distance
				closestDrill = drill
			end
		end
		if closestDrill ~= nil then
			viewPosition(player, playerIndex, closestDrill.position)
		end
		
		local drillsPerResource = scanUsedDrills(force)
		for resourceName, data in pairs(drillsPerResource) do
			local count = data.count
			local sum = data.sum
			player.print(count .. " drills for " .. resourceName .. " having " .. sum .. " resources remaining")
		end
    end
	
	if element.name == "locationViewBack" then
		resetPosition(player, playerIndex)
	end
end)

function scanEmptyDrills(force)
	local drills = { }
	local surface = game.get_surface(1)
	for coord in surface.get_chunks() do
		local X, Y = coord.x, coord.y;

		if surface.is_chunk_generated { X, Y } then
			local area = {{X*32, Y*32}, {X*32 + 32, Y*32 + 32}}
			for _, entity in pairs(surface.find_entities_filtered { area = area, type = "mining-drill", force = force.name}) do
				if drillIsEmpty(entity) then
					table.insert(drills, entity)
				end
			end
		end
	end
	return drills
end

function scanUsedDrills(force)
	local drills = { }
	local surface = game.get_surface(1)
	for coord in surface.get_chunks() do
		local X, Y = coord.x, coord.y;

		if surface.is_chunk_generated { X, Y } then
			local area = {{X*32, Y*32}, {X*32 + 32, Y*32 + 32}}
			for _, entity in pairs(surface.find_entities_filtered { area = area, type = "mining-drill", force = force.name}) do
				local drillResources = findResourcesFor(entity)
				for resourceName, amount in pairs(drillResources) do
					if drills[resourceName] == nil then
						drills[resourceName] = { count = 0, sum = 0 }
					end
					drills[resourceName].count = drills[resourceName].count + 1
					drills[resourceName].sum = drills[resourceName].sum + amount
				end
			end
		end
	end
	return drills
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
    if not player.gui.top["empty_drills"] then
		player.gui.left.add{ type = "button", name = "empty_drills", caption = "Drills" }
    end
end

function findMiningDrillsFor(resource)
	local pos = resource.position
	local range = 5
	local surface = game.get_surface(1)
	local drills = surface.find_entities_filtered{area = {{pos.x - range, pos.y - range}, {pos.x + range, pos.y + range}}, type = "mining-drill" }
	
	local result = {}
	
	for _, drill in pairs(drills) do
		local drillRange = getDrillRange(drill)
		if isInDrillRange(drill, resource) then
			table.insert(result, drill)
		end
	end
	
    return result
end

function getDrillRange(drill)
	-- drill resource_searching_radius is defined in data, but not yet accessible through this script
	if drill.name == "burner-mining-drill" then
		return 0.99
	end
	if drill.name == "basic-mining-drill" then
		return 2.49
	end
	return 1
end

function isInDrillRange(drill, resource)
	local range = getDrillRange(drill)
	return distance(drill.position, resource.position) <= range
end

function findResourcesFor(drill)
	local pos = drill.position
	local range = getDrillRange(drill)
	local surface = game.get_surface(1)
	local resources = surface.find_entities_filtered({area = {{pos.x - range, pos.y - range}, {pos.x + range, pos.y + range}}, type = "resource" })
	local sum = {}
	for i, resource in pairs(resources) do
		if sum[resource.name] == nil then
			sum[resource.name] = 0
		end
		sum[resource.name] = sum[resource.name] + resource.amount
	end
	return sum
end

function drillIsEmpty(drill)
	local resources = findResourcesFor(drill)
	for name, amount in pairs(resources) do
		if amount > 0 then
			return false
		end
	end
	return true
end








