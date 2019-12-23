Inventory = {}
Inventory.__index = Inventory

local function productAmount(product)
    if product.amount then
        return product.amount
    end
    return product.probability * (product.amount_max + product.amount_min) / 2
end

function Inventory:applyRecipe(recipe, want)
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
    local results = self:copy()
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
    obj.recipes = {}
    obj.banned_ingredients = {}
    obj.debug = {}
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

function Inventory:recipeAllowed(recipe)
    for _, ingredient in pairs(recipe.ingredients) do
        if self.banned_ingredients[ingredient.type .. "/" .. ingredient.name] then
            return false
        end
    end
    return true
end

function Inventory:print(prefix)
    for k, v in pairs(self.data) do
        if v.count ~= 0 and v.type ~= "technology" then
            self.force.print(prefix .. v.type .. "/" .. v.name .. ": " .. v.count)
        end
    end
end

function Inventory:findBestRecipe(product)
    local options = {}
    local productKey = product.type .. "/" .. product.name
    for k, recipe in pairs(self.force.recipes) do
        for _, recipe_product in pairs(recipe.products) do
            if recipe_product.type == product.type and recipe_product.name == product.name and self:recipeAllowed(recipe) then
                table.insert(options, recipe)
            end
        end
    end
    if #options > 1 then
        local filtered_options = {}
        self.force.print("Multiple recipes for " .. product.type .. "/" .. product.name)
        for optionKey, option in pairs(options) do
            local subhave = self:copyModel()
            subhave.banned_ingredients[productKey] = true
            for k, ingredient in pairs(option.ingredients) do
                subhave:modify(ingredient.type, ingredient.name, -1)
            end
            if option.name == "advanced-oil-processing" then
                subhave.debug["resolve"] = true
            end
            subhave = subhave:resolveRequirements(4)
            local allowed = true
            for k, ingredient in pairs(option.ingredients) do
                local ingredientKey = ingredient.type .. "/" .. ingredient.name
                local dataForIngredient = subhave.data[ingredientKey]
                if dataForIngredient.count < 0 and ingredientKey ~= "fluid/water" then-- and self.recipes[ingredientKey] and self.recipes[ingredientKey].type then
                    self.force.print("DISQUALIFIED Recipe: " .. option.name .. " because of " .. ingredientKey .. "=" .. dataForIngredient.count)
                    allowed = false
                end
            end
            if subhave.debug["resolve"] then
                subhave:print("Option " .. option.name .. " - " .. tostring(allowed) .. " - ")
            end
            if allowed then
                table.insert(filtered_options, option)
            end
        end
        options = filtered_options
    end
    
    -- for each option
    --   create a copy of Inventory and ban the recipe
    --      set all ingredients to want and see if it's possible

-- If a product that this recipe has appears as an ingredient for any required item recipe


    for k, recipe in pairs(options) do
        for _, recipe_product in pairs(recipe.products) do
            if recipe_product.type == product.type and recipe_product.name == product.name then
                if not recipe.enabled and not self.data["recipe/" .. recipe.name] then
--                        self.force.print("Recipe " .. recipe.name .. " is not available yet" .. ". " .. math.random(1, 10))
                    return self:findRecipeFor({type = "recipe", name = recipe.name})
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
    return { type = false }
end

function Inventory:findRecipeFor(product)
    local productKey = product.type .. "/" .. product.name
    self:debugIf("resolve", "Product " .. productKey)
    if product.type == "recipe" then
        for _, tech in pairs(self.force.technologies) do
            for _, modifier in pairs(tech.effects) do
                if modifier.type == "unlock-recipe" and modifier.recipe == product.name then
                    return self:findRecipeFor({type = "technology", name = tech.name})
                end
            end
        end
    end
    if product.type == "technology" then
        local recipe = self.force.technologies[product.name]
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
        if not self.recipes[productKey] or self.recipes[productKey].type ~= "recipe" then
            self.recipes[productKey] = self:findBestRecipe(product)
        end
        return self.recipes[productKey]
    end
    return { type = false } -- Empty result to indicate that it has been processed but no recipe found
end

function Inventory:findMissingItem()
    self:debugIf("resolve", "Find missing " .. math.random(1, 100))
    for _, v in pairs(self.data) do
        self:debugIf("resolve", "Product " .. v.type .. "/" .. v.name .. " == " .. v.count)
        if v.count < 0 and self:findRecipeFor(v).type then
            return v
        end
    end
    return nil
end

function Inventory:copyModel()
    local newInventory = Inventory:new(self.force)
    newInventory.recipes = self.recipes -- If copy finds a good recipe, parent should know about it too.
    for k, v in pairs(self.banned_ingredients) do
        newInventory.banned_ingredients[k] = v
    end
    return newInventory
end

function Inventory:copy()
    local newInventory = self:copyModel()
    for _, v in pairs(self.data) do
        newInventory:modify(v.type, v.name, v.count)
    end
    return newInventory
end

function Inventory:debugIf(condition, message)
    if self.debug[condition] then
        self.force.print(message)
    end
end

function Inventory:resolveRequirements(limit)
  local have = self:copy()
  local tries = 0
  while tries < limit do
    tries = tries + 1
    local product = have:findMissingItem()
    if product == nil then
        return have
    end
    local recipe = have:findRecipeFor(product)
    have = have:applyRecipe(recipe, product)
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
--  have:modify("item", "assembling-machine-1", -1)
--  have:modify("item", "rocket-part", -100)
--  have:modify("item", "satellite", -1)
  have:modify("item", "plastic-bar", -1)
  have = have:resolveRequirements(10)
--  have:print("Required ")
end

return {
  MissingGoal = MissingGoal
}

--[[
    Find item prototypes with filter = "fuel"



    Find recipe that has specific product
/c for r, v in pairs(game.player.force.recipes) do     for prod, prodv in pairs(v.products) do if prodv.name == "crude-oil-barrel" then game.print(r) end end end
/c for r, v in pairs(game.player.force.recipes["fill-crude-oil-barrel"].ingredients) do game.print(v.name) end


    This finds too many things. All entities are minable :(
minable={}
a=game.get_filtered_entity_prototypes({{ filter = "minable" }})
for k,v in pairs(a) do b = v.mineable_properties.products
    if b then
        for ki,vi in pairs(b) do
            minable[vi.type .. "/" .. vi.name] = true
        end
    end
end
for k,v in pairs(minable) do
    game.print(k)
end
]]--


