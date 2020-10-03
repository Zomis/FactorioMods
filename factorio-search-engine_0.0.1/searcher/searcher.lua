local Searcher = {}
Searcher.__index = Searcher

function Searcher:new()
    local searcher = {}
    setmetatable(searcher, Searcher)
    searcher.type_plugins = {}
    return searcher
end

function Searcher:add_type_plugin(type_plugin)
    -- TODO: Do some validation to check that it contains all the necessary functions
    if not type_plugin.options_type then error("type_plugin is missing options_type") end
    if not type_plugin.options_search then error("type_plugin is missing options_search") end
    if self.type_plugins[type_plugin.options_type] then
        error("Colliding type plugins, " .. type_plugin.options_type .. " is already defined.")
    end
    self.type_plugins[type_plugin.options_type] = type_plugin
end

function Searcher:find_things_matching_text(force, text)
    -- Returns: A nested table with search results, such as { items: { iron ore, iron plates... }, fluids: ..., entities: ... }
    -- This method should be quite quick and typically focus on types / entity-prototypes / etc.
    local results = {}
    for type, value in pairs(self.type_plugins) do
        results[type] = value.options_search(force, text)
    end
    return results
end

return Searcher
