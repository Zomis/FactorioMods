Inventory = {}
Inventory.__index = Inventory

local function productAmount(product)
    if product.amount then
        return product.amount
    end
    return product.probability * (product.amount_max + product.amount_min) / 2
end

local function applyRecipe(force, recipe, inventory, want)
    local times = 1
    if recipe.type ~= "technology" then
        local product = nil
        for _, result in pairs(recipe.products) do
            if (result.type == want.type and result.name == want.name) then
                product = result
            end
        end
        if not product then
            error({message = "Trying to apply the incorrect recipe to get " .. want.name})
        end
        times = math.ceil(math.abs(want.count) / productAmount(product))
    end
    local results = inventory:copy()
    for _, i in pairs(recipe.ingredients) do
        results:modify(i.type, i.name, -i.amount * times)
    end
    for _, o in pairs(recipe.products) do
        results:modify(o.type, o.name, productAmount(o) * times)
    end
    return results
end

function Inventory:new(force)
    local obj = {}
    setmetatable(obj, Inventory)
    obj.data = {}
    obj.force = force
    return obj
end

function find(t, func)
    for k, v in pairs(t) do
        if func(v, k) then
            return v
        end
    end
end

function Inventory:modify(type, itemName, count)
    local existing = self.data[type .. "/" .. itemName]
    if (existing ~= nil) then
        if existing.type ~= "technology" or count > 0 then -- don't remove a technology once it is researched
            existing.count = existing.count + count
        end
    else
        self.data[type .. "/" .. itemName] = {type = type, name = itemName, count = count}
    end
end
  
function Inventory:hasMissingItems()
    for k, v in pairs(self.data) do
        if v.count < 0 then
            return true
        end
    end
    return false
end

function Inventory:findRecipeFor(force, product)
    if product.type == "recipe" then
        for _, tech in pairs(force.technologies) do
            for _, modifier in pairs(tech.effects) do
                if modifier.type == "unlock-recipe" and modifier.recipe == product.name then
                    return self:findRecipeFor(force, {type = "technology", name = tech.name})
                end
            end
        end
    end
    if product.type == "technology" then
        local recipe = force.technologies[product.name]
        local count = recipe.research_unit_count
        local research_ingredients = recipe.research_unit_ingredients
        local time = count * recipe.research_unit_energy

        local ingredients = {}
        for _, v in pairs(research_ingredients) do
            -- TODO: Detect and ignore recipes that cause loops
            -- TODO: Consider Ingredient.catalyst_amount ?
            table.insert(ingredients, {type = v.type, name = v.name, amount = v.amount * count})
        end
        for _, prerequisite in pairs(recipe.prerequisites) do
            table.insert(ingredients, {type = "technology", name = prerequisite.name, amount = 1 })
        end
        local products = { { type = "technology", name = recipe.name, amount = 1 } }
        for _, modifier in pairs(recipe.effects) do
            if modifier.type == "unlock-recipe" then
                table.insert(products, {type = "recipe", name = modifier.recipe, amount = 0})
            end
        end

        -- TODO: Add time
        return {
            type = "technology",
            name = recipe.name,
            ingredients = ingredients,
            products = products
        }
    end
    if product.type == "item" or product.type == "fluid" then
        for k, recipe in pairs(force.recipes) do
            for _, recipe_product in pairs(recipe.products) do
                if recipe_product.type == product.type and recipe_product.name == product.name then
                    if not recipe.enabled and not self.data["recipe/" .. recipe.name] then
--                        force.print("Recipe " .. recipe.name .. " is not available yet" .. ". " .. math.random(1, 10))
                        return self:findRecipeFor(force, {type = "recipe", name = recipe.name})
                    end
                    return {
                        type = "recipe",
                        name = recipe.name,
                        ingredients = recipe.ingredients,
                        products = recipe.products
                    }
                end
            end
        end
    end
    return nil
    -- error({ message = "Unknown product: " .. product.type .. "/" .. product.name })
end

function Inventory:findMissingItem(force)
    for _, v in pairs(self.data) do
        if v.count < 0 and self:findRecipeFor(force, v) then
            return v
        end
    end
    return nil
end

function Inventory:copy()
    local newInventory = Inventory:new(self.force)
    for k, v in pairs(self.data) do
        newInventory:modify(v.type, v.name, v.count)
    end
    return newInventory
end

function Inventory:resolveRequirements(force)
  local have = self:copy()
  local tries = 0
  while tries < 100000 do
    tries = tries + 1
    local product = have:findMissingItem(force)
    if product == nil then
        return have
    end
    local recipe = have:findRecipeFor(force, product)
    have = applyRecipe(force, recipe, have, product)
  end
  return have
end

function Inventory:resourceCount(name)
  for _, v in pairs(inventory) do
    if v.name == name then
      return v.count
    end
  end
  return 0
end

local function MissingGoal(player)
  local have = Inventory:new(player.force)
  have:modify("item", "assembling-machine-1", -1)
--  have:modify("item", "rocket-part", -100)
--  have:modify("item", "satellite", -1)
  have = have:resolveRequirements(player.force)
  for k, v in pairs(have.data) do
    if v.count ~= 0 and v.type ~= "technology" then
        player.print(v.name .. ": " .. v.count)
    end
  end
end

return {
  MissingGoal = MissingGoal
}