local function check_for_loot(unit_type)
    for _, unit in pairs(unit_type) do
        if unit.minable then
            unit.minable.result = nil
        end
    end
end

for type_name, raw_table in pairs(data.raw) do
    if type_name ~= "resource" then
        check_for_loot(raw_table)
    end
end
