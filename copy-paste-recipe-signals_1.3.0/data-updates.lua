local function make_pastable(entity_type)
    if not entity_type.additional_pastable_entities then
        entity_type.additional_pastable_entities = {}
    end

    table.insert(entity_type.additional_pastable_entities, "constant-combinator")
    table.insert(entity_type.additional_pastable_entities, "arithmetic-combinator")
    table.insert(entity_type.additional_pastable_entities, "decider-combinator")

    if mods["LTN_Combinator_Modernized"] then
        table.insert(entity_type.additional_pastable_entities, "ltn-combinator")
    end
end


for _, entity_type in pairs(data.raw["assembling-machine"]) do
    make_pastable(entity_type)
end

for _, entity_type in pairs(data.raw["furnace"]) do
    make_pastable(entity_type)
end
