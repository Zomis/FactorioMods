local FactorioData = {}
FactorioData.__index = FactorioData

local function key(item_or_fluid)
    return item_or_fluid.type .. "/" .. item_or_fluid.name
end

function FactorioData:new(values)
    local data = {}
    data.data = values
    setmetatable(data, FactorioData)
    data:prepare_recipes()
    return data
end

function FactorioData:expected_amount(product)
    local expected_amount = product.amount
    if not expected_amount then
        expected_amount = (product.amount_min + product.amount_max) / 2.0
    end
    local probability = product.probability or 1

    return expected_amount * probability
end

function FactorioData:add_tech_requirement(recipe_name, technology)
    if not self.tech_requirements[recipe_name] then
        self.tech_requirements[recipe_name] = {}
    end
    table.insert(self.tech_requirements[recipe_name], technology)
end

function FactorioData:_determine_tech_complexity(tech)
    if tech.complexity then return end
    if tech.researched then
        tech.complexity = 0
        return
    end
    local sum = 1
    for _, prerequisite_name in pairs(tech.requires or {}) do
        local prerequisite_tech = self.data.technologies[prerequisite_name]
        self:_determine_tech_complexity(prerequisite_tech)
        sum = sum + prerequisite_tech.complexity
    end
    tech.complexity = sum
end

function FactorioData:prepare_research()
    -- Loop through all technologies and create a Map<Recipe, Technology(single or array)> for what each recipe needs.
    -- when you need a technology, check if it is enabled. If it is then you have infinite of it (is not consumed)
    -- when you need a recipe that is not unlocked, you set its technology to -1. So tech/automation: -1.
    -- when you need the tech, add all its required science packs and speed. (1 * amount)

    for _, tech in pairs(self.data.technologies) do
        self:_determine_tech_complexity(tech)
--        self.complexities[key({ type = "tech", name = tech.name })] = tech.complexity
    end

    self.tech_requirements = {}
    for _, tech in pairs(self.data.technologies) do
        for _, effect in pairs(tech.effects) do
            if effect.type == "unlock-recipe" then
                self:add_tech_requirement(effect.recipe, tech)
            end
        end
    end
end

function FactorioData:_tech_recipe(technology)
    local prerequisites_and_ingredients = {}
    for _, v in pairs(technology.ingredients) do table.insert(prerequisites_and_ingredients, v) end
    for _, v in pairs(technology.requires) do table.insert(prerequisites_and_ingredients, { type = "tech", name = v, amount = 1 }) end

    return {
        name = technology.name,
        ingredients = prerequisites_and_ingredients,
        products = { { name = technology.name, type = "tech", amount = 1000 } },
        energy = technology.research_unit_energy,
        research_unit_count = technology.research_unit_count
    }
end

function FactorioData:_recipe_complexity(recipe)
    if recipe.enabled or not self.tech_requirements[recipe.name] then
        return 0
    end
    local sum = 0
    for _, tech in pairs(self.tech_requirements[recipe.name]) do
        sum = sum + tech.complexity
    end
    return sum
end

function FactorioData:prepare_recipes()
    self.recipes_by_product = {}
    self:prepare_research()
    for _, recipe in pairs(self.data.recipes) do
        recipe.complexity = recipe.complexity or self:_recipe_complexity(recipe)
    end

    for k, recipe in pairs(self.data.recipes) do
        if not recipe.enabled then
            local tech_requirements = self.tech_requirements[recipe.name]
            if tech_requirements and #tech_requirements ~= 1 then
                -- Loader for example might not have a technology that unlocks it.
                print("WARNING: There are " .. #tech_requirements .. " technologies for recipe " .. recipe.name .. ": " .. json.encode(tech_requirements))
            end
            if tech_requirements then
                table.insert(recipe.ingredients, { type = "tech", name = tech_requirements[1].name, amount = 1 })
            end
        end
        for _, product in pairs(recipe.products) do
            local product_key = key(product)
            if not self.recipes_by_product[product_key] then
                self.recipes_by_product[product_key] = {}
            end
            table.insert(self.recipes_by_product[product_key], recipe)
        end
    end

    for _, tech in pairs(self.data.technologies) do
        local product = { type = "tech", name = tech.name }
        self.recipes_by_product[key(product)] = { self:_tech_recipe(tech) }
    end
end

return FactorioData
