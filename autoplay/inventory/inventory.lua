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
    end
    local key = key(item)
    if not self.values[key] then
        self.values[key] = 0
    end
    self.values[key] = self.values[key] + value
    if item.type == "tech" and self.values[key] < 0 then
        -- You just require a technology once.
        self.values[key] = -1
    end
    if item.type == "tech" and self.values[key] > 0 then
        -- You just require a technology once.
        self.values[key] = 1
    end
    if self.values[key] == 0 then
        self.values[key] = nil
    end
end

function Inventory:get(item)
    return self.values[key(item)] or 0
end

function Inventory:determine_best_recipe(possibilities, key)
    local minv = possibilities[1]
    for _, v in pairs(possibilities) do
        print("Possibility for " .. key .. ": " .. v.name .. " has complexity of " .. v.complexity)
        if v.complexity < minv.complexity then
            minv = v
        end
    end
    return minv
end

function Inventory:find_recipe(key)
    local possible_recipes = self.data.recipes_by_product[key]
    if not possible_recipes then
        error("No possible recipes for " .. key)
    end
    print("Recipes for " .. key .. ": " .. json.encode(map(function(r) return r.name end, possible_recipes)))
    if not possible_recipes then error("no recipes for " .. key) end
    local chosen_recipe = possible_recipes[1]
    if table_size(possible_recipes) ~= 1 then
        chosen_recipe = self:determine_best_recipe(possible_recipes, key)
    end

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

function Inventory:has_negative()
    return any(self.values, function(v) return v < 0 end)
end

function Inventory:resolve()
    local next = Inventory:new(self.data)
    for k, v in pairs(self.values) do
        -- TODO: Resolve the most complex things first.
        -- TODO: Improve the recipe chooser to avoid loops with barrels
        if v < 0 then
            print("")
            print("Fixing " .. k .. " " .. v)
            next:change(k, v) -- Copy current value to next so that it can resolve it
            local recipe = next:find_recipe(k)

            print("Resolve recipe: " .. json.encode(recipe))
            next:apply_repeatedly(recipe)
        end
    end
    print("")
    print("Next Result: " .. json.encode(next.values))
    return next
end

return Inventory
