-- Given a text, show possible things to search for
-- If only one thing matches, move automatically to next step
-- Pass results on to next step.

local event = require("__flib__.event")
local gui = require("__flib__.gui")

local function add_matching_text_results(parent, results, searcher)
    for result_type, v in pairs(results) do
        local elems = gui.build(parent, {
            {type="flow", direction="vertical", children={
              {type="label", caption={"search_engine.types." .. result_type}},
              {type="flow", save_as="content." .. result_type, children={}},
            }}
        })
        searcher.type_plugins[result_type].options_render(elems.content[result_type], v)
        --elems.content[result_type].add()
    end
--    gui.update_filters("inventory.slot_button", player.index, {"demo_slot_button"}, "add")
--    global.players[player.index].small_search_gui = { elems = elems, small_search_location = location_elems.small_search_location_label }
end
  
return {
    add_matching_text_results = add_matching_text_results
}
