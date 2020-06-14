local json = require "lib/json"
local default_file = "export.json"

local function recipe_table(recipe)
    return {
        name = recipe.name,
        enabled = recipe.enabled,
        category = recipe.category,
        ingredients = recipe.ingredients,
        products = recipe.products,
        energy = recipe.energy
    }
end

local function item_table(item)
    return {
        name = item.name,
        type = item.type,
        stack_size = item.stack_size
    }
end

local function tech_table(tech)
    if not tech.enabled then
        return
    end
    local result = {
        upgrade = tech.upgrade,
        requires = {},
        ingredients = {},
        effects = {},
        researched = tech.researched,
        research_unit_count = tech.research_unit_count,
        research_unit_energy = tech.research_unit_energy,
        level = tech.level,
        max_level = tech.prototype.max_level,
        research_unit_count_formula = tech.prototype.research_unit_count_formula,
        name = tech.name
    }
    for _, parent in pairs(tech.prerequisites) do
        table.insert(result.requires, parent.name)
    end
    for _, ingredient in pairs(tech.research_unit_ingredients) do
        table.insert(result.ingredients, ingredient)
    end
    for _, effect in pairs(tech.effects) do
        table.insert(result.effects, effect)
    end
    return result
end

local function fluid_table(fluid)
    return {
        name = fluid.name,
        type = "fluid"
    }
end

local function assembler_table(assembler)
    local result = {
        crafting_speed = assembler.crafting_speed,
        ingredient_count = assembler.ingredient_count,
        crafting_categories = {}
    }

    for category, bool in pairs(assembler.crafting_categories) do
        if bool then
            table.insert(result.crafting_categories , category)
        end
    end

    return result
end

local function miner_table(miner)
    local result = {
	    mining_speed = miner.mining_speed,
    	mining_drill_radius = miner.mining_drill_radius,
        resource_categories = {}
    }

    for category, bool in pairs(miner.resource_categories) do
        if bool then
            table.insert(result.resource_categories, category)
        end
    end

    return result
end

local function resource_table(resource)
    return {
        resource_category = resource.resource_category,
        hardness = resource.mineable_properties.hardness,
        mining_time = resource.mineable_properties.mining_time,
        products = resource.mineable_properties.products,
        required_fluid = resource.mineable_properties.required_fluid,
        fluid_amount = resource.mineable_properties.fluid_amount,
    }
end

local function factorio_data(player)
    local output = {}
    output.recipes = {}
    for name, recipe in pairs(game.recipe_prototypes) do
        output.recipes[name] = recipe_table(recipe)
    end

    output.items = {}
    for name, item in pairs(game.item_prototypes) do
        output.items[name] = item_table(item)
    end
    for name, fluid in pairs(game.fluid_prototypes) do
        output.items[name] = fluid_table(fluid)
    end

    output.technologies = {}
    for name, tech in pairs(player.force.technologies) do
        output.technologies[name] = tech_table(tech)
    end

	output.assemblers = {}
    output.miners = {}
    output.resources = {}
	for name, entity in pairs(game.entity_prototypes) do
		if (entity.crafting_categories and entity.name ~= "player") then
            output.assemblers[name] = assembler_table(entity)
        end
        if (entity.resource_categories) then
            output.miners[name] = miner_table(entity)
        end
        if (entity.resource_category) then
            output.resources[name] = resource_table(entity)
        end
    end
    return output
end

commands.add_command("exportz", nil, function(event)
    local player = game.players[event.player_index]
    local output = factorio_data(player)
    local file = event.parameter or default_file
    game.remove_path(file)
    game.write_file(file, json.encode(output), true)
end)

return {
    factorio_data = factorio_data
}