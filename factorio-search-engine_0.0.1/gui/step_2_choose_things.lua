-- Given a text, show possible things to search for
-- If only one thing matches, move automatically to next step
-- Pass results on to next step.

local event = require("__flib__.event")
local gui = require("__flib__.gui")

gui.add_handlers {
  small_search_window = {
    choose_things = {
      result_button = {
        on_gui_click = function(e)
          game.get_player(e.player_index).print("You clicked " .. e.element.name)
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
            }}
        })
        searcher.type_plugins[result_type].options_render({ player = context.player, parent = elems.content[result_type] }, v)
    end
end
  
return {
    add_matching_text_results = add_matching_text_results
}
