local probability = settings.startup["no-loot-probability-of-loot"].value

local function check_for_loot(unit_type)
    for _, unit in pairs(unit_type) do
        if unit.minable then
            if not unit.minable.results then
              unit.minable.results = {}
            end
            if unit.minable.result then
              table.insert(unit.minable.results, {
                name = unit.minable.result,
                amount_min = 1,
                amount_max = 1,
                probability = probability / 100.0
              })
            end
            unit.minable.result = nil
        end
    end
end

local ignored_types = {}
ignored_types["resource"] = true
ignored_types["tree"] = true
ignored_types["simple-entity"] = true
ignored_types["simple-entity-with-owner"] = true
ignored_types["simple-entity-with-force"] = true

for type_name, raw_table in pairs(data.raw) do
    if not ignored_types[type_name] then
        check_for_loot(raw_table)
    end
end
