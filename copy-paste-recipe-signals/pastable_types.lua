local function mod_exists(mod_name)
    if mods and mods[mod_name] then
        return true
    end
    if game and game.active_mods[mod_name] then
        return true
    end
    return false
end

function pastable_entity_names_table()
    local pastable_types = {
        "constant-combinator",
        "arithmetic-combinator",
        "decider-combinator",
        "pump",
        "inserter"
    }
    if data then
        for k in pairs(data.raw["inserter"]) do
            table.insert(pastable_types, k)
        end
        for k in pairs(data.raw["transport-belt"]) do
            table.insert(pastable_types, k)
        end
        for k in pairs(data.raw["splitter"]) do
            table.insert(pastable_types, k)
        end
    end

    if mod_exists("LTN_Combinator_Modernized") then
        table.insert(pastable_types, "ltn-combinator")
    end
    return pastable_types
end

return {
    entity_names = pastable_entity_names_table()
}
