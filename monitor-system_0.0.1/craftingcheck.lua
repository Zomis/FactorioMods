script.on_event(defines.events.on_tick, function(event)
    if event.tick % 10 ~= 0 then
        return
    end
	if true then
		return
	end
	-- for mining drills, add all the resource fields to a list
	-- and check the values every now and then
	-- but do not count resources that the player has mined manually
	
	local machines = global.machines
	if not global.machines then
		machines = findType("assembling-machine", game.players[1].force)
		game.players[1].print("Machines: " .. #machines)
		global.machines = machines
	end
	global.progress = global.progress or {}
	
	
	for index, machine in ipairs(machines) do
		local key = tostring(machine.position.x) .. "x" .. tostring(machine.position.y)
		if not global.progress[key] then
			global.progress[key] = machine.crafting_progress
		end
		if machine.crafting_progress < global.progress[key] then
			if machine.recipe then
				game.players[1].print("Crafted " .. machine.recipe.name)
			end
		end
		global.progress[key] = machine.crafting_progress
    end
end)

