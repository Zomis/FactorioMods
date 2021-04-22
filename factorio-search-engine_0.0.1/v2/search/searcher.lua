local tables = require("__flib__/table")
local data_fillers = require("v2/plugins/data_fill/data_fillers")
local search_results = require("v2/gui/search_results")
local filters = require("v2/plugins/filters/filters")

local function search_process(search, data)
    -- on each element: add all mappers/fillers/interceptors.
    for _, data_filler_id in pairs(search.job.data_fillers) do
        data_fillers.data_fill(data_filler_id, data)
    end

    if filters.apply_filters(data, search) then
        return data
    end
    -- on each element: check for filters

    return nil
end

local function on_tick()
    local searches = global.searches or {}

    for _, search in pairs(searches) do
        if search.job and search.job.running then
            local callback = function(v)
                local data = {}
                data[search.job.loop_provides] = v
                return search_process(search, data)
            end
            local results
            local table_end_reached
            search.job.progress, results, table_end_reached = tables.for_n_of(
                search.job.loop_data, search.job.progress, 100, callback
            )
            if results then
                local results_count = search.results_count
                for _, result in pairs(results) do
                    if result then
                        results_count = results_count + 1
                        search.results[results_count] = result
                    end
                end
                search.results_count = results_count
                search.gui.results_count.caption = {
                    "search_engine.progress",
                    search.results_count,
                    search.job.progress,
                    search.job.loop_data_count
                }
            end
            if table_end_reached then
                search.job.running = false
                search_results.show_results(search)
            end
        end
    end
end

return {
    on_tick = on_tick
}