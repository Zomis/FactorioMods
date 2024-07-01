local pastable_types = require "pastable_types"
local pastable_entity_names_table = pastable_types.entity_names

local function make_pastable(entity_type)
    if not entity_type.additional_pastable_entities then
        entity_type.additional_pastable_entities = {}
    end

    for _, other in pairs(pastable_entity_names_table) do
        if other ~= entity_type.name then
            table.insert(entity_type.additional_pastable_entities, other)
        end
    end
end

for k, entity_type in pairs(data.raw["assembling-machine"]) do
    make_pastable(entity_type)
    print("other " .. k .. ": " .. serpent.line(entity_type.additional_pastable_entities))
end

for k, entity_type in pairs(data.raw["furnace"]) do
    make_pastable(entity_type)
    print("other " .. k .. ": " .. serpent.line(entity_type.additional_pastable_entities))
end

for k, entity_type in pairs(data.raw["constant-combinator"]) do
    make_pastable(entity_type)
    print("other " .. k .. ": " .. serpent.line(entity_type.additional_pastable_entities))
end
