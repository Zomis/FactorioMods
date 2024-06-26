local pastable_types = require "pastable_types"
local pastable_types_table = pastable_types()

local function make_pastable(entity_type)
    if not entity_type.additional_pastable_entities then
        entity_type.additional_pastable_entities = {}
    end

    for _, other in pairs(pastable_types_table) do
        if other ~= entity_type.name then
            table.insert(entity_type.additional_pastable_entities, other)
        end
    end
end


for _, entity_type in pairs(data.raw["assembling-machine"]) do
    make_pastable(entity_type)
end

for _, entity_type in pairs(data.raw["furnace"]) do
    make_pastable(entity_type)
end
