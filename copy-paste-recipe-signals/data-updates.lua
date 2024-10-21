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

for _, entity_type in pairs(data.raw["assembling-machine"]) do
    make_pastable(entity_type)
end

for _, entity_type in pairs(data.raw["furnace"]) do
    make_pastable(entity_type)
end

--- PASTE DIFFERENT VALUES when copying to a constant-combinator. e.g. copy water=-1000, water=-2400 based on the other values
for _, entity_type in pairs(data.raw["storage-tank"]) do
    make_pastable(entity_type)
end
for _, entity_type in pairs(data.raw["pipe"]) do
    make_pastable(entity_type)
end
for _, entity_type in pairs(data.raw["splitter"]) do
    make_pastable(entity_type)
end
for _, entity_type in pairs(data.raw["underground-belt"]) do
    make_pastable(entity_type)
end
for _, entity_type in pairs(data.raw["pipe-to-ground"]) do
    make_pastable(entity_type)
end
for _, entity_type in pairs(data.raw["transport-belt"]) do
    make_pastable(entity_type)
end
for _, entity_type in pairs(data.raw["container"]) do
    make_pastable(entity_type)
end
for _, entity_type in pairs(data.raw["inserter"]) do
    make_pastable(entity_type)
end

for _, entity_type in pairs(data.raw["furnace"]) do
    make_pastable(entity_type)
end

for _, entity_type in pairs(data.raw["constant-combinator"]) do
    make_pastable(entity_type)
end
