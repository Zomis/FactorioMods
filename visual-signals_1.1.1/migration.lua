local event = require("__flib__.event")
local migration = require("__flib__.migration")
local gui2 = require("gui2")

local function migrate_global()
    local old_global = global.fum_uic
    local result = {}
    local changes = {}
    for k, v in pairs(old_global) do
        local entity = v.entity
        local new_key = "vs-" .. entity.surface.index .. "_" .. entity.position.x .. "_" .. entity.position.y
        local new_value = {
            entity = v.entity,
            title = v.title
        }
        result[new_key] = new_value
        table.insert(changes, {
            old_key = k,
            new_key = new_key,
            new_value = new_value
        })
        -- game.print("migrate from " .. k .. " to " .. new_key)
    end
    global.visual_signals = result
    global.guis = {}

    return changes
end

local migrations = {
    ["1.1.0"] = function()
        -- Common migration code for all versions prior to 1.1.0
        for _, player in pairs(game.players) do
            if player.gui.top["visual_signals"] then
              player.gui.top["visual_signals"].style = "slot_button"
            end
        
            local pane = player.gui.left
            if pane["gui_signal_display"] then
              local parent = pane["gui_signal_display"]["gui_signal_panel"]
              for _, element_name in ipairs(parent.children_names) do
                -- 0.16 changed the style name to "slot_button"
                local panel = parent[element_name]
                if panel.signals then
                  for _, el in ipairs(panel.signals.children_names) do
                    local signalElement = panel.signals[el].icon
                    if signalElement.type == "sprite-button" then
                      signalElement.style = "slot_button"
                    end
                  end
                end
        
                -- Migration code to fix #27 in version 0.15.6
                if string.find(element_name, "label") then
                  local key = string.sub(element_name, 6)
                  if not parent["panel" .. key] then
                    parent["label" .. key].destroy()
                  end
                end
              end
            end
        end
    end,
    ["1.1.1"] = function()
        -- global.fum_uic
        -- game.print(serpent.block(global.fum_uic)) -- key is an integer, value is a table with "entity" and "title".
        local global_change = migrate_global()

        for _, player in pairs(game.players) do
            if player.gui.top.visual_signals then
                player.gui.top.visual_signals.destroy()
                gui2.add_mod_gui_button(player)
            end
            local new_guis = {}

            if player.gui.left.gui_signal_display then
                local old = player.gui.left.gui_signal_display
                if old.gui_signal_panel then
                    for _, diff in pairs(global_change) do
                        if old.gui_signal_panel["label" .. diff.old_key] then
                            table.insert(new_guis, gui2.for_display(diff.new_key))
                        end
                    end
                end
                old.destroy()
                gui2.create_gui(player, new_guis)
            end
        end
    end
}

event.on_configuration_changed(function(e)
    if migration.on_config_changed(e, migrations) then
        -- this does return true or false, but we don't care about the result.
    end
end)
