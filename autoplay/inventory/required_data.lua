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

function FactorioData:prepare_research()
    -- Loop through all technologies and create a Map<Recipe, Technology(single or array)> for what each recipe needs.
    -- when you need a technology, check if it is enabled. If it is then you have infinite of it (is not consumed)
    -- when you need a recipe that is not unlocked, you set its technology to -1. So tech/automation: -1.
    -- when you need the tech, add all its required science packs and speed. (1 * amount)

    self.tech_requirements = {}
    for _, tech in pairs(self.data.technologies) do
        for _, effect in pairs(tech.effects) do
            if effect.type == "unlock-recipe" then
                self:add_tech_requirement(effect.recipe, tech)
            end
        end
    end
end

function FactorioData:prepare_recipes()
    self.recipes_by_product = {}
    self:prepare_research()
    -- self.recipes_by_product["rocket-part"] = filter(function(r) return r.category == "rocket-building" end, self.data.recipes)
    -- at the end, loop over recipes and check what we can do and not do. Set a 'tier'/'total_cost' for each recipe/technology.
    for k, recipe in pairs(self.data.recipes) do
        for _, product in pairs(recipe.products) do
            local product_key = key(product)
            if not self.recipes_by_product[product_key] then
                self.recipes_by_product[product_key] = {}
            end

--            print("Recipe for " .. product_key .. ": " .. recipe.name)
            table.insert(self.recipes_by_product[product_key], recipe)
        end
    end
end

return FactorioData
