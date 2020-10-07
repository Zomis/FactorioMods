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

function Searcher:loop_function(loop)
    local type = loop.type
    local search_options = loop.search_options[1] -- FIXME: Add support for multiple search options!

    local search_plugins_for_type = self.search_plugins[type]
    local search_plugins_for_options = search_plugins_for_type[search_options]

    local search_loops = search_plugins_for_options.search_loops
    local search_loops_for_type = search_loops[type]
    return search_loops_for_type[search_options]
end

function Searcher:create_search(player, search_params)
    global.searches_active = global.searches_active or {}
    local task_data = {
        player_index = player.index,
        id = player.index .. "_" .. game.tick,
        type = "search",
        search_params = search_params,
        results = {}
    }
    local loops = { Async:loop_func("item", search_params) }

    local task = Async:perform_once(task_data, loops)
    task.steps_per_interval = 100
    global.searches_active[task_data.id] = task
    return task
end

function Searcher:search_step(task_data, values)
    local type = task_data.search_params.type
    local search_options = task_data.search_params.search_options[1] -- FIXME: Add support for multiple search options!

    local search_plugins_for_type = self.search_plugins[type]
    local search_plugins_for_options = search_plugins_for_type[search_options]

    local search_filters = search_plugins_for_options.search_filters
    local search_filters_for_type = search_filters[type]
    local search_filters_func = search_filters_for_type[search_options][1] -- TODO: Add support for multiple search filters? Or change API to not be a table.

    local player = game.get_player(task_data.player_index)
    local filter_result = search_filters_func(player, task_data.search_params, values.item)
    if filter_result then
        table.insert(task_data.results, filter_result)
    end
end

return Searcher
