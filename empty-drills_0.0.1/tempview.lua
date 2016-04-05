script.on_init(function()
    global.character = global.character or {}
end)
script.on_load(function()
    global.character = global.character or {}
end)

--- moves a player ghost to a position and highlights it
function viewPosition(player, index, position)
    local ghost = createGhostController(player, position)

    changeCharacter(player, ghost)
    -- hideGUI(player, index)

    local locationFlow = player.gui.center.locationFlow
    if locationFlow ~= nil then
        locationFlow.destroy()
    end
    locationFlow = player.gui.center.add({type = "flow", name = "locationFlow", direction = "horizontal"})
    locationFlow.add({type = "button", name = "locationViewBack", caption = {"location-back"}, style = "lv_location_view"})
end

--- moves a player back to it's original character and position
function resetPosition(player, index)
    local character = global.character[index]
    if character ~= nil and player.character.name == "ls-controller" then
        local locationFlow = player.gui.center.locationFlow
        if locationFlow ~= nil then
            locationFlow.destroy()
        end

        if changeCharacter(player, character) then
            global.character[index] = nil
		else
			player.print("Your character was dead. Respawning.")
			local force = player.force
			local surface = game.get_surface(1)
			local spawn = force.get_spawn_position(surface)
			local newPlayer = surface.create_entity({name = "player", position = spawn, force = force})
			changeCharacter(player, newPlayer)
        end
    end
end

--- creates a new player ghost controller
function createGhostController(player, position)
    local position = position or player.position
    local surface = player.surface
    local entity = surface.create_entity({name="ls-controller", position=position, force=player.force})
    return entity
end

--- changes the player character
function changeCharacter(player, character)
    if player.character ~= nil and character ~= nil and player.character.valid and character.valid then
        if player.character.name ~= "ls-controller" then
            global.character[player.index] = player.character
        elseif player.character.name == "ls-controller" then
            player.character.destroy()
        end
        player.character = character
        return true
    end
    return false
end
