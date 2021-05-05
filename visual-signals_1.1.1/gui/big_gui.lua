local mod_gui = require("__core__.lualib.mod-gui")
local gui = require("__flib__.gui-beta")
local tables = require("__flib__.table")
local display_gui = require("gui/display")

local function add_mod_gui_button(player)
    mod_gui.get_button_flow(player).add {
        type = "sprite-button",
        style = "slot_button", --mod_gui.button_style, -- or "slot_button" ?
        sprite = "item/gui-signal-display",
        tags = {
            [script.mod_name] = {
                flib = {
                    on_click = { type = "mod-gui", action = "open" }
                }
            }
        },
        tooltip = { "visual-signals.mod-gui-tooltip" }
    }
end

local function owned_by_force(force)
    return function(display)
        local entity = display.entity
        return entity.valid and entity.force == force
    end
end

local function open_big_gui(player_index)
    local player = game.players[player_index]
    local display_guis = tables.filter(tables.map(
        tables.filter(global.visual_signals, owned_by_force(player.force)),
        display_gui.editable_title
    ), function() return true end, true)

    local gui_result = gui.build(player.gui.screen, {
        {
            type = "frame",
            direction = "vertical",
            ref = { "window" },
            children = {
                {
                    type = "flow", ref = {"titlebar"},
                    children = {
                        {
                            type = "label",
                            style = "frame_title",
                            caption = { "visual-signals.window-title" },
                            ignored_by_interaction = true
                        },
                        {
                            type = "empty-widget",
                            style = "flib_titlebar_drag_handle",
                            ignored_by_interaction = true
                        },
                        {
                            type = "sprite-button",
                            style = "frame_action_button",
                            sprite = "utility/close_white",
                            hovered_sprite = "utility/close_black",
                            clicked_sprite = "utility/close_black",
                            actions = {
                                on_click = { type = "generic", action = "close" }
                            }
                        }
                    }
                },
                {
                    type = "flow", direction = "vertical",
                    children = display_guis
                }
            }
        }
        -- closable-frame, scroll, displays for all but with edit-boxes to change label. No reference to this window needed
    })
    gui_result.titlebar.drag_target = gui_result.window
    gui_result.window.force_auto_center()

    if gui_result.displays then
        for visual_signal_key, visual_signal_gui in pairs(gui_result.displays) do
            display_gui.update(visual_signal_key, visual_signal_gui)
        end
    end
end

local function handle_action(action, event)
    if action.type == "mod-gui" and action.action == "open" then
        open_big_gui(event.player_index)
    end
    if action.action == "title-change" then
        local visual_signal_entry = global.visual_signals[action.key]
        if visual_signal_entry then
            visual_signal_entry.title = event.element.text
        end
    end
end

return {
    handle_action = handle_action,
    add_mod_gui_button = add_mod_gui_button
}
