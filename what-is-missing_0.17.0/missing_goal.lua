--[[
class Item {
  constructor(public count: number, public name: string) {}
}

class Recipe {
  constructor(public inputs: Array<Item>, public result: Item) {}

  toString(): string {
    return `${this.inputs} => ${this.result}`
  }
}

function parseItem(item: string): Item {
  let split = item.split(" ")
  return new Item(parseInt(split[0], 10), split[1])
}

function parseRecipe(line: string): Recipe {
  let split = line.split(" => ")
  let ingredients = split[0].split(", ")
  let result = split[1]
  return new Recipe(ingredients.map(parseItem), parseItem(result))
}

class Recipes {
  public recipes: Array<Recipe> = new Array<Recipe>()

  add(line: string) {
    this.recipes.push(parseRecipe(line.trim()))
  }

  findRecipeFor(name: string): Recipe | undefined {
    return this.recipes.find((r: Recipe) => r.result.name == name)
  }

}

function itemIsMissing(item: Item): boolean {
  return item.count < 0 && item.name != "ORE"
}

  part2(input: Recipes): any {
    let have = new Array<Item>()
    let requiredForOne = this.part1(input) as number
    have.push(new Item(1000000000000, "ORE"))
    let totalFuelAdded = 0
    while (this.resourceCount(have, "ORE") > 0) {
      let moreFuel = Math.floor(this.resourceCount(have, "ORE") / requiredForOne)
      if (moreFuel == 0) {
        moreFuel = 1
      }
      totalFuelAdded += moreFuel

      modify(have, "FUEL", -moreFuel)
      have = this.resolveRequirements(input, have)
    }
    return totalFuelAdded - 1;// this.resourceCount(have, "FUEL");
  }

}
--]]

Inventory = {}
Inventory.__index = Inventory

local function productAmount(product)
    if product.amount then
        return product.amount
    end
    return product.probability * (product.amount_max + product.amount_min) / 2
end

local function applyRecipe(recipe, inventory, want)
    recipe.force.print("Applying recipe: " .. recipe.name)
    local product = nil
    for _, result in pairs(recipe.products) do
        if (result.type == want.type and result.name == want.name) then
            product = result
        end
    end
    if not product then
        error({message = "Trying to apply the incorrect recipe to get " .. want})
    end
    local results = inventory:copy()
    local times = math.ceil(math.abs(want.count) / product.amount)
    for _, i in pairs(recipe.ingredients) do
        results:modify(i.type, i.name, -i.amount * times)
    end
    for _, o in pairs(recipe.products) do
        results:modify(o.type, o.name, productAmount(o) * times)
    end
    return results
end

function Inventory:new()
    local obj = {}
    setmetatable(obj, Inventory)
    obj.data = {}
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
--    local existing = find(self.data, function(i) return i.name == itemName end)
    if (existing ~= nil) then
        if existing.type ~= "technology" or count > 0 then -- don't remove a technology once it is researched
            existing.count = existing.count + count
        end
    else
        self.data[type .. "/" .. itemName] = {type = type, name = itemName, count = count}
        --table.insert(self.data, { name = name, count = count })
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

local function findRecipeFor(force, product)
    if product.type == "technology" then
        local recipe = force.technologies[product.name]
        local count = recipe.research_unit_count
        local research_ingredients = recipe.research_unit_ingredients
        local time = count * recipe.research_unit_energy

        local ingredients = {}
        for _, v in pairs(research_ingredients) do
            -- TODO: Detect and ignore recipes that cause loops
            table.insert(ingredients, {type = v.type, name = v.name, amount = v.amount * count}) -- TODO: Consider Ingredient.catalyst_amount ?
        end
        for _, prerequisite in pairs(prerequisites) do
            table.insert(ingredients, {type = "technology", name = prerequisite.name, amount = 1 })
        end

        -- time, research ingredients, prerequisites
        return {
            name = recipe.name,
            time = time,
            ingredients = ingredients,
            products = { { type = "technology", name = recipe.name, amount = 1 } }
        }
    end
    if product.type == "item" or product.type == "fluid" then
        for k, recipe in pairs(force.recipes) do
            for _, recipe_product in pairs(recipe.products) do
                if recipe_product.type == product.type and recipe_product.name == product.name then
                    return recipe
                end
            end
        end
    end
    return nil
    -- error({ message = "Unknown product: " .. product.type .. "/" .. product.name })
end

function Inventory:findMissingItem(force)
    for _, v in pairs(self.data) do
        if v.count < 0 and findRecipeFor(force, v) then
            return v
        end
    end
    return nil
end

function Inventory:copy()
    local newInventory = Inventory:new()
    for k, v in pairs(self.data) do
        newInventory:modify(v.type, v.name, v.count)
    end
    return newInventory
end

function Inventory:resolveRequirements(force)
  local have = self:copy()
  while true do
    local product = have:findMissingItem(force)
    if product == nil then
        return have
    end
    local recipe = findRecipeFor(force, product)
--    force.print("Found recipe " .. recipe.name)
    have = applyRecipe(recipe, have, product)
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
  local have = Inventory:new()
  have:modify("item", "assembling-machine-1", -1)
  have = have:resolveRequirements(player.force)
  for k, v in pairs(have.data) do
    if v.count ~= 0 then
        player.print(v.name .. ": " .. v.count)
    end
  end
end

return {
  MissingGoal = MissingGoal
}