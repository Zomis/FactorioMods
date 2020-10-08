for _, entity_type in pairs(data.raw["assembling-machine"]) do
    if not entity_type.additional_pastable_entities then
        entity_type.additional_pastable_entities = {}
    end
    table.insert(entity_type.additional_pastable_entities, "constant-combinator")
end
