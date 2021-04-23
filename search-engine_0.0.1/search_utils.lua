local function clean_name(name)
    -- Replace '-' with ' ' and make lowercase
    return name:gsub("-", " "):lower()
end

local function name_contains(haystack, needle)
    return clean_name(haystack):find(needle) and true or false
end

return {
    clean_name = clean_name,
    name_contains = name_contains,
}
