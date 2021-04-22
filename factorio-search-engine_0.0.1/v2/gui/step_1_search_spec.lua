local gui = require("__flib__.gui-beta")

--Buttons: Entities / Recipes / ...
--  On-click, change subsection
--Subsection: Depending on button active
--  Entities: Assembling machines, furnaces, belts, pipes, vehicles, containers, constant combinators, decider combinator, arithmetic combinator, programmable speaker

local loop_plugins = require("v2/plugins/loops/loops")
local filter_plugins = require("v2/plugins/filters/filters")
local data_fillers = require("v2/plugins/data_fill/data_fillers")
local gui_generic = require("v2/gui/gui_generic")

local function search_params_gui(search_id)
    return {
        type = "frame", direction = "vertical", style = "inside_shallow_frame_with_padding", style_mods = {padding = 12},
        children = {
            {
                type = "label", caption = {"search_engine.looking_for"}
            },
            {
                type = "flow", direction = "horizontal", ref = { "loop_plugins" }, children = loop_plugins.gui_elements()
            },
            {
                type = "flow", direction = "vertical", ref = { "loop_params" }
            },
            {
                type = "label", caption = {"search_engine.where_filters"}
            },
            filter_plugins.generic_controls(search_id),
            {
                type = "label", caption = {"search_engine.would_like_to_know"}
            },
            {
                type = "button", caption = {"search_engine.search_button"}, actions = {
                    on_click = { action = "start_search", gui = 1, search_id = search_id }
                }
            },
            {
                type = "label", caption = {"search_engine.progress",0,0,0}, ref = { "results_count" }
            }
        }
    }
end

local function create_guis(player)
    local search_id = "search-" .. player.index .. "-" .. game.tick
    local search_gui = gui.build(player.gui.screen, {
        {
          type = "frame",
          direction = "vertical",
          ref = {"search_window"},
          tags = { search_id = search_id },
          children = {
            gui_generic.header(),
            {
                type = "flow", direction = "vertical", ref = { "internal" }, children = {
                    search_params_gui(search_id)
                }
            }
          }
        }
    })

    local loop_id = gui.get_tags(search_gui.loop_plugins.children[1]).loop_id
    local loop_params = gui.build(search_gui.loop_params, loop_plugins.controls(loop_id))

    search_gui.titlebar.flow.drag_target = search_gui.search_window
    search_gui.search_window.force_auto_center()
    global.searches = global.searches or {}
    global.searches[search_id] = {
        search_id = search_id,
        filters = {},
        player = player,
        gui = search_gui,
        gui_loop_params = loop_params,
        params = {}
    }
end

local function determine_provides(search)
    local provides = {}
    search.provides = provides
    provides[search.job.loop_provides] = true
    for _, data_filler_id in pairs(search.job.data_fillers) do
        if data_fillers.plugins_support.is_supported_key(data_filler_id, search) then
            for k in pairs(data_fillers.provides(data_filler_id)) do
                provides[k] = true
            end
        end
    end
    return provides
end

local function start_search(msg, e)
    local search = global.searches[msg.search_id]
    local loop_id = gui.get_tags(search.gui.loop_plugins.children[1]).loop_id
    local loop_data = loop_plugins.create_loop(loop_id, search)
    local loop_provides = loop_plugins.provides(loop_id)

    local data_fillers = { "position", "circuit_networks", "recipe" }
    -- TODO: search.plugins = { filters = ..., data_fillers = ..., gui = ... } ???
    search.results = {}
    search.results_count = 0
    search.result_headers = { loop_provides }
    
    search.job = {
        loop_provides = loop_provides,
        running = true,
        progress = nil,
        loop_id = loop_id,
        loop_data = loop_data,
        loop_data_count = table_size(loop_data),
        data_fillers = data_fillers
    }
    search.provides = determine_provides(search)
end

local function handle_action(msg, e)
    if msg.action == "start_search" then
        start_search(msg, e)
    end
end

return {
    open_small_gui = create_guis, handle_action = handle_action
}
