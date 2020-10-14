local event = require("__flib__.event")
local gui = require("__flib__.gui")
local tables = require("__flib__.table")
local searcher = require "searcher/main_searcher"

local function destroy_gui(player, search_id)
    global.search_windows = global.search_windows or {}
    global.search_windows[search_id].elems.window.destroy()
    global.search_windows[search_id] = nil
    gui.update_filters("search_engine.step3.actions.zoom_to_map", player.index, nil, "remove")
end

gui.add_handlers {
    search_engine = {
        step3 = {
            actions = {
                zoom_to_map = {
                    on_gui_click = function(e)
                        local separator_start, separator_end = e.element.name:find("_action_zoom_to_map__")
                        local search_id = e.element.name:sub(1, separator_start - 1)
                        local result_index = tonumber(e.element.name:sub(separator_end + 1))
                        
                        local result = global.search_windows[search_id].results[result_index]
                        local player = game.get_player(e.player_index)
                        player.zoom_to_world(result.location) -- TODO: Add second parameter for scale
                    end
                }
            },
            close = {
                on_gui_click = function(e)
                    destroy_gui(game.get_player(e.player_index), e.element.name)
                end
            }
        },
    }
}

local function show_window(search)
    global.search_windows = global.search_windows or {}
    local search_id = search.id
    if global.search_windows[search_id] then
        return global.search_windows[search_id].elems
    end
    local player = game.get_player(search.player_index)
    local elems = gui.build(player.gui.screen, {
        {type="frame", direction="vertical", save_as="window", children={
          {type="flow", save_as="titlebar.flow", children={
            {type="label", style="frame_title", caption={"search_engine.step3_header"}, elem_mods={ignored_by_interaction=true}},
            {template="drag_handle"},
            {template="frame_action_button", name=search_id, handlers="search_engine.step3.close", caption="X"}
          }},
          {type="flow", save_as="status", direction="vertical"}
        }}
    })
    elems.titlebar.flow.drag_target = elems.window
    elems.window.force_auto_center()
    global.search_windows[search.id] = { elems = elems, results = search.results }
    return elems
end

local function add_to_table(search_id, element, result_columns)
    return function(v, k)
        if result_columns["location"] then
            element.add {
                type = "label",
                caption = v.location.x .. ", " .. v.location.y
            }
        end
        if result_columns["count"] then
            element.add {
                type = "label",
                caption = v.count
            }
        end
        if result_columns["actions"] then
            element.add {
                type = "button",
                name = search_id .. "_action_zoom_to_map__" .. k,
                caption = { "search_engine.action_zoom_to_map" }
            }
        end
    end
end

local function progress_gui(search_task)
    if global.search_windows[search_id] then
        return global.search_windows[search_id].elems
    end
    local elems = show_window(search_task.task_data)
    elems.status.clear()
    -- TODO: Show table over loops: identifier (label), step / total (label), progressbar

    local table_children = {}
    for _, loop in pairs(search_task.loops) do
        table.insert(table_children, {type="label", caption=loop.identifier})
        table.insert(table_children, {type="label", save_as="loops." .. loop.identifier .. ".status"})
        table.insert(table_children, {type="progressbar", save_as="loops." .. loop.identifier .. ".progressbar"})
    end
    local elems = gui.build(elems.status, {
        {type="table", column_count=3, children=table_children}
    })
    search_task.task_data.status_progress_gui = elems
end

local function update_progress_gui(search_task)
    local task_data = search_task.save_state.task_data
    local search_id = task_data.id
    if not global.search_windows[search_id] then
        return
    end
    local status = search_task:get_status()
    local status_progress_gui = task_data.status_progress_gui
    if not status_progress_gui then
        return
    end
    for _, loop in pairs(status.loops) do
        if loop.step then
            status_progress_gui.loops[loop.identifier].status.caption = loop.step .. " / " .. loop.total
            status_progress_gui.loops[loop.identifier].progressbar.value = loop.step / loop.total
        else
            status_progress_gui.loops[loop.identifier].status.caption = "??? / " .. loop.total
            status_progress_gui.loops[loop.identifier].progressbar.value = 0
        end
    end
end

local function show_results(search, search_task)
    local window_elems = show_window(search)
    window_elems.status.clear()
    search.status_progress_gui = nil

    -- TODO: Use plugin approach. local result_renders = searcher:result_renders(search)

    local result_columns = { }
    result_columns.actions = true
    if tables.for_each(search.results, function(v) return v.location end) then
        result_columns.location = true
    end
    if tables.for_each(search.results, function(v) return v.count end) then
        result_columns.count = true
    end

    local total_results = table_size(search.results)
    local count_sum = 0
    if result_columns.count then
        for _, v in pairs(search.results) do -- Can't use tables.reduce because it's a table with keys, not an array
            if v and v.count then
                count_sum = count_sum + v.count
            end
        end
    end

    local elems = gui.build(window_elems.status, {
        {type="label", caption={ "search_engine.results_result_count", total_results } },
        {type="label", caption={ "search_engine.results_count_sum", count_sum } },
        {type="scroll-pane", style="flib_naked_scroll_pane_no_padding", style_mods={height=300}, children={
            {type="table", column_count=table_size(result_columns), save_as="table"}
        }}
    })
    tables.for_each(search.results, add_to_table(search.id, elems.table, result_columns))
    gui.update_filters("search_engine.step3.actions.zoom_to_map", search.player_index, {search.id .. "_action_zoom_to_map"}, "add")
end

return {
    search_completed = show_results,
    search_progress = update_progress_gui,
    progress_gui = progress_gui,
}
