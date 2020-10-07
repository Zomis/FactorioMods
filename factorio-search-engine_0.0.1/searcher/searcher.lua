local Searcher = {}
Searcher.__index = Searcher

function Searcher:new()
    local searcher = {}
    setmetatable(searcher, Searcher)
    searcher.type_plugins = {}
    searcher.search_plugins = {}
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

function Searcher:add_search_plugin(search_plugin)
    -- TODO: Do some validation to check that it contains all the necessary functions
    if not search_plugin.search_options then error("search_plugin is missing search_options") end

    for type, search_options in pairs(search_plugin.search_options) do
        self.search_plugins[type] = self.search_plugins[type] or {}
        for _, search_option in pairs(search_options) do
            if self.search_plugins[type][search_option] then
                error("Colliding search plugins, " .. type .. "/" .. search_option .. " is already defined.")
            end
            self.search_plugins[type][search_option] = search_plugin
        end
    end
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
