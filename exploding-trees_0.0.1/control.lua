local random = math.random

-- Explosions = { "explosion", "explosion-hit", "ground-explosion", "massive-explosion", "medium-explosion", "nuke-explosion", "crash-site-explosion-smoke"

local exploding_trees = {
	["tree-01"] = true,
	["tree-02"] = true,
	["tree-03"] = true,
	["tree-04"] = true,
	["tree-05"] = true,
	["tree-09"] = true,
	["tree-02-red"] = true,
	["tree-07"] = true,
	["tree-06"] = true,
	["tree-06-brown"] = true,
	["tree-09-brown"] = true,
	["tree-09-red"] = true,
	["tree-08"] = true,
	["tree-08-brown"] = true,
	["tree-08-red"] = true,
	["dead-dry-hairy-tree"] = true,
	["dead-grey-trunk"] = true,
	["dead-tree-desert"] = true,
	["dry-hairy-tree"] = true,
	["dry-tree"] = true,
	["tree-01-stump"] = true,
	["tree-02-stump"] = true,
	["tree-03-stump"] = true,
	["tree-04-stump"] = true,
	["tree-05-stump"] = true,
	["tree-06-stump"] = true,
	["tree-07-stump"] = true,
	["tree-08-stump"] = true,
	["tree-09-stump"] = true
}

local function get_random_position(box, x_scale, y_scale)
	local x_scale = x_scale or 1
	local y_scale = y_scale or 1
	local x1 = box.left_top.x
	local y1 = box.left_top.y
	local x2 = box.right_bottom.x
	local y2 = box.right_bottom.y
	local x = ((x2 - x1) * x_scale * (random() - 0.5)) + ((x1 + x2) / 2)
	local y = ((y2 - y1) * y_scale * (random() - 0.5)) + ((y1 + y2) / 2)
	return {x, y}
end

local function explode(entity)
	local surface = entity.surface
	local effects = 1

	local box = entity.bounding_box
	
	for k = 1, effects do
        local position = get_random_position(box, 0.8, 0.5)
        local effect = surface.create_entity {
            name = "explosion",
            position = position
        }
        surface.create_entity {
            name = "crash-site-fire-smoke",
            position = position
        }
	end
end

script.on_event(defines.events.on_player_mined_entity, function(event)
	if not exploding_trees[event.entity.name] then
		return
	end

	if global.random == nil then
		global.random = game.create_random_generator()
	end

	local probability = settings.global["exploding-trees-probability"].value
	if global.random(1, 100) <= probability then
        explode(event.entity)
	end
end)
