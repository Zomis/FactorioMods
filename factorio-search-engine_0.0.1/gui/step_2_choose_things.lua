-- Given a text, show possible things to search for
-- If only one thing matches, move automatically to next step
-- Pass results on to next step.

local event = require("__flib__.event")
local gui = require("__flib__.gui")

local function perform_search(event, search)
    -- TODO: Left-click = Search directly, right click -> add to search? Or Shift+Click or something
    local player = game.players[event.player_index]
    local clicked_element = event.element.name
    local search_for_name = clicked_element:sub(clicked_element:find("__") + 2)
    local search_for_type = clicked_element:sub(1, clicked_element:find("_") - 1)

    local player_table = global.players[player.index]
    local search_options_elements = player_table.search_options.search_options[search_for_type].children
    local search_options = {}
    for _, search_option in pairs(search_options_elements) do
      if search_option.state then
        table.insert(search_options, search_option.name)
      end
    end

    local search_params = {
      type = search_for_type,
      name = search_for_name,
      search_options = search_options
    }
--    local search = searcher:create_search(player, search_params)
--    step3.progress_gui(search)
end

gui.add_handlers {
  small_search_window = {
    choose_things = {
      result_button = {
        on_gui_click = function(e)
          perform_search(e)
        end
      }
    },
  }
}

local function add_matching_text_results(context, results, searcher)
    for result_type, v in pairs(results) do
        local elems = gui.build(context.parent, {
            {type="flow", direction="vertical", children={
              {type="label", caption={"search_engine.types." .. result_type}},
              {type="flow", direction="horizontal", save_as="content." .. result_type, children={}},
              {type="flow", direction="vertical", save_as="search_options." .. result_type, children={}},
            }}
        })
        searcher.type_plugins[result_type].options_render({ player = context.player, parent = elems.content[result_type] }, v)
        for search_plugin_name, search_plugin in pairs(searcher.search_plugins[result_type] or {}) do
          elems.search_options[result_type].add {
            type = "checkbox",
            name = search_plugin_name,
            caption = { "search_engine.types." .. result_type .. "." .. search_plugin_name },
            state = true
          }
        end
        local player_table = global.players[context.player.index]
        player_table.search_options = elems
    end
end
  
return {
    add_matching_text_results = add_matching_text_results
}
