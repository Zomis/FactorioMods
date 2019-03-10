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
                probability = 0.5
              })
            end
            unit.minable.result = nil
        end
    end
end

for type_name, raw_table in pairs(data.raw) do
    if type_name ~= "resource" then
        check_for_loot(raw_table)
    end
end
