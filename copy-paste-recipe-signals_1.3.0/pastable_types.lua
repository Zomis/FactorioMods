local function mod_exists(mod_name)
    if mods and mods[mod_name] then
        return true
    end
    if game and game.active_mods[mod_name] then
        return true
    end
    return false
end

return function()
    local pastable_types = {
        "constant-combinator",
        "arithmetic-combinator",
        "decider-combinator",
        "pump",
        "stack-filter-inserter"
    }
    
    if mod_exists("LTN_Combinator_Modernized") then
        table.insert(pastable_types, "ltn-combinator")
    end
    return pastable_types
end
