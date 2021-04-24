local gui = require("__flib__.gui-beta")
local tables = require("__flib__/table")
local result_gui = require("v2/plugins/result_gui/result_gui")

local function create_result_guis(search, enabled_gui_plugins, columns)
    local children = {}
    for _, column in pairs(columns) do
        table.insert(children, {
            type = "label",
            caption = column
        })
    end
    tables.for_each(search.results, function(result, index)
        result_gui.process_result(result, index, search, enabled_gui_plugins, children)
    end)
    return children
end

local function handle_action(action, e)
    -- local search = global.searches[action.search_id]
    if action.type == "result" or action.type == "results_batch" then
        result_gui.handle_action(action, e)
    end
end

local function show_results(search)
    search.gui.internal.children[1].destroy()

    local enabled_gui_plugins = result_gui.plugins_support.enabled_plugins(search)
    local columns = result_gui.columns(enabled_gui_plugins)

    local gui_contents = {
        {
            type = "flow",
            direction = "vertical",
            children = {
                {
                    type = "label",
                    caption = {"search_engine.results_result_count", table_size(search.results)}
                },
                {
                    type = "flow",
                    direction = "vertical",
                    children = result_gui.create_header(search, enabled_gui_plugins)
                },
                {
                    type = "frame",
                    style = "inside_shallow_frame_with_padding", style_mods = {padding = 12}, children = {
                        {
                            type = "scroll-pane",
                            style = "flib_naked_scroll_pane_no_padding",
                            style_mods = {height = 200},
                            children = {
                                {
                                    type = "table",
                                    column_count = table_size(columns),
                                    draw_vertical_lines = true,
                                    draw_horizontal_lines = true,
                                    draw_horizontal_line_after_headers = true,
                                    ref = {"slot_table"},
                                    children = create_result_guis(search, enabled_gui_plugins, columns)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    local results = gui.build(search.gui.internal, gui_contents)
    search.gui.results = results
end

return {
    show_results = show_results,
    handle_action = handle_action
}
