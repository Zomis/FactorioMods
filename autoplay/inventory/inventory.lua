local FactorioData = require "autoplay/inventory/required_data"

local Inventory = {}
Inventory.__index = Inventory

local function key(item_or_fluid)
    if type(item_or_fluid) ~= "table" then
        return item_or_fluid
    end
    return item_or_fluid.type .. "/" .. item_or_fluid.name
end

function Inventory:new(data)
    local inv = {}
    setmetatable(inv, Inventory)
    inv.data = data
    inv.values = {}
    return inv
end

function Inventory:set(item, value)
    self.values[key(item)] = value
end

function Inventory:change(item, value)
    if item.type == "tech" then
        if self:get(item) > 0 then
            -- Once you have unlocked a technology, it doesn't go away.
            return
        end
        if value < 0 then
            -- You just require the technology once.
            value = -1
        end
    end
    local key = key(item)
    if not self.values[key] then
        self.values[key] = 0
    end
    self.values[key] = self.values[key] + value
end

function Inventory:get(item)
    return self.values[key(item)] or 0
end

function Inventory:research_recipe(recipe)
    if recipe.enabled then
        return nil
    end
    local tech_options = self.data.tech_requirements[recipe.name]
    print("Checking tech-options for " .. json.encode(recipe.name))
    if table_size(tech_options) ~= 1 then
        error("There are " .. #tech_options .. " technologies for " .. key)
    end

    local technology = tech_options[1]
    if self:get({ type = "tech", name = technology.name }) > 0 then
        return nil
    end
    local prerequisites_and_ingredients = {}
    for _, v in pairs(technology.ingredients) do table.insert(prerequisites_and_ingredients, v) end
    for _, v in pairs(technology.requires) do table.insert(prerequisites_and_ingredients, { type = "tech", name = v, amount = 1 }) end

    return {
        ingredients = prerequisites_and_ingredients,
        products = { { name = technology.name, type = "tech", amount = 1000 } },
        energy = technology.research_unit_energy,
        research_unit_count = technology.research_unit_count
    }
end

function Inventory:find_recipe(key)
    local possible_recipes = self.data.recipes_by_product[key]
    print("Recipes for " .. key .. ": " .. json.encode(map(function(r) return r.name end, possible_recipes)))
    if not possible_recipes then error("no recipes for " .. key) end
    if table_size(possible_recipes) ~= 1 then
        error("There are " .. #possible_recipes .. " recipes for " .. key)
    end

    local chosen_recipe = possible_recipes[1]

    print("Found recipe: " .. chosen_recipe.name)
    return chosen_recipe
end

function Inventory:apply_repeatedly(recipe)
    local times = recipe.research_unit_count or 1
    while any(recipe.products, function(product) return self:get(product) < 0 end) do
        -- TODO: When performance is bad, pre-calculate how many times we need to perform this
        for k, product in pairs(recipe.products) do
            self:change(product, FactorioData:expected_amount(product) * times)
        end
        for k, ingredient in pairs(recipe.ingredients) do
            self:change(ingredient, -FactorioData:expected_amount(ingredient) * times)
        end
    end
end

function Inventory:resolve_steps()
    local next = Inventory:new(self.data)
    for k, v in pairs(self.values) do
        if v < 0 then
            print("")
            print("Fixing " .. k .. " " .. v)
            next:change(k, v) -- Copy current value to next so that it can resolve it
            local recipe = next:find_recipe(k)
            local research_recipe = self:research_recipe(recipe)
            if research_recipe then
                print("Resolve research: " .. json.encode(research_recipe))
                next:change(research_recipe.products[1], -1)
                next:apply_repeatedly(research_recipe)
            end

            print("Resolve recipe: " .. json.encode(recipe))
            next:apply_repeatedly(recipe)
        end
    end
    print("")
    print("Next Result: " .. json.encode(next.values))
end

return Inventory
