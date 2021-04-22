local event = require("__flib__.event")
local gui = require("__flib__.gui-beta")

local gui_step1 = require("v2/gui/step_1_search_spec")
local search_results = require("v2/gui/search_results")
local search = require("v2/search/searcher")
local filters = require("v2/plugins/filters/filters")

local function handle_action(msg, e)
--    game.print("HANDLE ACTION " .. game.tick)
--    game.print(serpent.block(e))
--    game.print(serpent.block(msg))

    if msg == "close_window" then
        local element = e.element
        while element.parent and element.parent.parent do
            element = element.parent
        end
        local tags = gui.get_tags(element)
        if tags and tags.search_id then
            global.searches[tags.search_id] = nil
        end
        element.destroy()
    end
    if type(msg) == "table" then
        if msg.gui == 1 then
            gui_step1.handle_action(msg, e)
        end
        if msg.type == "result" or msg.type == "results_batch" then
            search_results.handle_action(msg, e)
        end
        if msg.type == "filters" then
            filters.handle_action(msg, e)
        end
    end
end


gui.hook_events(function(e)
	local msg = gui.read_action(e)
	if msg then
	  handle_action(msg, e)
	end
end)

event.on_lua_shortcut(function(event)
	if event.prototype_name == "factorio-search-engine" then
		gui_step1.open_small_gui(game.players[event.player_index])
	end
end)

event.register("factorio-search-engine-open-search", function(event)
	gui_step1.open_small_gui(game.players[event.player_index])
end)

event.on_tick(function (e) search.on_tick(e) end)
