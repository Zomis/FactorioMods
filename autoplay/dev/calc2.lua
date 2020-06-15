local func = require "autoplay/functional_library"
local Inventory = require "autoplay/inventory/inventory"
local FactorioData = require "autoplay/inventory/required_data"
local calc = {}

function table_size(tbl)
    local count = 0
    for _, _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

function calc.calc(data)
    local fact_data = FactorioData:new(data)

    local inv = Inventory:new(fact_data)
    inv:set("item/rocket-silo", -1)
    inv:set("item/rocket-part", -100)
    inv:set("item/satellite", -1)

    local inventory_resolved = inv
    inventory_resolved = inventory_resolved:resolve()
    inventory_resolved = inventory_resolved:resolve()
    return inventory_resolved
end

return calc
