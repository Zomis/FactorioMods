local event = require("__flib__.event")
local gui = require("__flib__.gui")
local migration = require("__flib__.migration")
local mod_gui = require("__core__.lualib.mod-gui")

local function perform_search(event, search)
    local player = game.players[event.player_index]
    player.print("Searching for " .. search)
end

local function destroy_guis(player)
    local player_table = global.players[player.index]
    -- destroy parents for both GUIs and clean up tables
    player_table.small_search_gui.elems.window.destroy()
    player_table.small_search_gui.small_search_location.destroy()
    player_table.small_search_gui = nil
  
    gui.update_filters("small_search_window", player.index, nil, "remove")
    gui.update_filters("small_search_location", player.index, nil, "remove")
end

gui.add_templates {
    mouse_filter = { type = "button", mouse_button_filter = { "left" } },
    drag_handle = { type = "empty-widget", style = "flib_titlebar_drag_handle", elem_mods = { ignored_by_interaction = true } },
    frame_action_button = { template = "mouse_filter", style = "frame_action_button" }
  }
  
  gui.add_handlers {
    small_search_window = {
      titlebar = {
        close = {
          on_gui_click = function(e)
            destroy_guis(game.get_player(e.player_index))
          end
        }
      },
      search_text = {
        on_gui_confirmed = function(e)
          perform_search(e, e.element.text)
        end
      },
      search_button = {
        on_gui_click = function(e)
            local search_text = global.players[e.player_index].small_search_gui.elems.search_text.text
            perform_search(e, search_text)
        end
      },
      window = {
        on_gui_location_changed = function(e)
          local location = e.element.location
          global.players[e.player_index].small_search_gui.small_search_location.caption = location.x..", "..location.y
        end
      }
    },
    small_search_location = {
      on_gui_click = function(e)
        global.players[e.player_index].small_search_gui.elems.window.force_auto_center()
      end
    }
  }
  
local function open_small_gui(player)
    -- location button - kept in the `mod-gui` button flow
    local location_elems = gui.build(mod_gui.get_button_flow(player), {
      {type="button", style=mod_gui.button_style, caption="0, 0", handlers="small_search_location", save_as="small_search_location_label"}
    })
  
    local elems = gui.build(player.gui.screen, {
      {type="frame", direction="vertical", handlers="small_search_window.window", save_as="window", children={
        -- save_as - dot-deliminated path to save this element to in `inventory_elems`
        {type="flow", save_as="titlebar.flow", children={
          {type="label", style="frame_title", caption={"search_engine.header"}, elem_mods={ignored_by_interaction=true}},
          {template="drag_handle"},
          -- you can assign multiple elements to the same handler group
          {template="frame_action_button", handlers="small_search_window.titlebar.close", caption="X"}
        }},
        {type="textfield", save_as="search_text", handlers="small_search_window.search_text"},
        {type="button", save_as="search_button", handlers="small_search_window.search_button", caption = { "search_engine.search_button" }}
      }}
    })
    elems.search_text.focus()
  
    elems.titlebar.flow.drag_target = elems.window
    elems.window.force_auto_center()
  
--    gui.update_filters("inventory.slot_button", player.index, {"demo_slot_button"}, "add")
  
    global.players[player.index].small_search_gui = { elems = elems, small_search_location = location_elems.small_search_location_label }
end
  
event.on_configuration_changed(function(e)
  if migration.on_config_changed(e, {}) then
    gui.check_filter_validity()
  end
end)
  
event.on_gui_click(function(e)
  if not gui.dispatch_handlers(e) then
    game.print("no handler found")
  end
end)
  
event.on_lua_shortcut(function(event)
	if event.prototype_name == "factorio-search-engine" then
		open_small_gui(game.players[event.player_index])
	end
end)

event.register("factorio-search-engine-open-search", function(event)
	open_small_gui(game.players[event.player_index])
end)
