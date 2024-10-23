local random = math.random

-- Explosions = {
-- "explosion", "explosion-hit", "ground-explosion", "massive-explosion",
-- "medium-explosion", "nuke-explosion", "crash-site-explosion-smoke"
-- }

local function get_random_position(box)
	local x1 = box.left_top.x
	local y1 = box.left_top.y
	local x2 = box.right_bottom.x
	local y2 = box.right_bottom.y
	local x = ((x2 - x1) * (random() - 0.5)) + ((x1 + x2) / 2)
	local y = ((y2 - y1) * (random() - 0.5)) + ((y1 + y2) / 2)
	return {x, y}
end

local function explode(entity)
	local surface = entity.surface
	local effects = 1

	local box = entity.bounding_box

	for _ = 1, effects do
		local position = get_random_position(box, 0.8, 0.5)
		surface.create_entity {
		    name = "explosion",
		    position = position
		}
		surface.create_entity {
		    name = "crash-site-fire-smoke",
		    position = position
		}
	end
end

local function handle_event(event_type, event)
	if storage.random == nil then
		storage.random = game.create_random_generator()
	end

	local upper_bound = 0
	if event_type == "on_player_mined_entity" then
		upper_bound = settings.global["exploding-trees-probability"].value
	elseif event_type == "on_robot_mined_entity" then
		upper_bound = settings.global["exploding-trees-probability-robots"].value
	elseif event_type == "on_entity_died" and event.force and event.damage_type then
		-- only trigger when the death happened when the tree got damaged by a specific force
		upper_bound = settings.global["exploding-trees-probability-kill"].value
	end

	if storage.random(1, 100) <= upper_bound then
		explode(event.entity)
	end
end

local filter = {
	filter = "type",
	type = "tree",
}

for _, event_type in pairs({"on_player_mined_entity", "on_robot_mined_entity", "on_entity_died"}) do
	script.on_event(defines.events[event_type], function(event) handle_event(event_type, event) end, {
		filter,
	})
end
