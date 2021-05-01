local gui = require("__flib__.gui-beta")
local toolbar = require("gui/toolbar")
local events_table = require("gui/events_table")

local function header(gui_id)
    return {
        type = "flow",
        ref = {"titlebar"},
        children = {
            {type = "label", style = "frame_title", caption = {"train-log.header"}, ignored_by_interaction = true},
            {type = "empty-widget", style = "flib_titlebar_drag_handle", ignored_by_interaction = true},
            {
                type = "button",
                caption = "x",
                style = "frame_action_button",
                actions = {
                    on_click = { type = "generic", action = "close-window", gui_id = gui_id },
                }
            }
        }
    }
end

local function open_gui(player)
    local gui_id = "gui-" .. player.index .. "-" .. game.tick
    local gui_contents = {
        {
            type = "frame",
            direction = "vertical",
            ref = { "window" },
            children = {
                header(gui_id),
                toolbar.create_toolbar(gui_id),
                {
                    type = "tabbed-pane",
                    ref = { "tabs", "pane" },
                    children = {
                        {
                            type = "tab",
                            caption = { "train-log.tab-events" },
                            ref = { "tabs", "events" }
                        },
                        {
                            type = "tab",
                            caption = { "train-log.tab-summary" },
                            ref = { "tabs", "summary" }
                        },
                        {
                            type = "flow",
                            direction = "vertical",
                            ref = { "tabs", "events_contents" }
                        },
                        {
                            type = "flow",
                            direction = "vertical",
                            ref = { "tabs", "summary_contents" }
                        },
                    }
                },
            }
        }
    }
    local train_log_gui = gui.build(player.gui.screen, gui_contents)
    global.guis[gui_id] = {
        gui_id = gui_id,
        gui = train_log_gui,
        player = player
    }
    train_log_gui.titlebar.drag_target = train_log_gui.window
    train_log_gui.window.force_auto_center()
    local tabs = train_log_gui.tabs
    local tabbed_pane = tabs.pane
    tabbed_pane.add_tab(tabs.events, tabs.events_contents)
    tabbed_pane.add_tab(tabs.summary, tabs.summary_contents)

    events_table.create_events_table(gui_id)
end

local function destroy_gui(gui_id)
    local train_log_gui = global.guis[gui_id]
    train_log_gui.gui.window.destroy()
    global.guis[gui_id] = nil
end

local function open_or_close_gui(player, always_open)
    if always_open then
        -- open a new gui either way
        open_gui(player)
        return
    end

    -- close existing gui if one is open
    for gui_id, train_log_gui in pairs(global.guis) do
        if train_log_gui.player == player then
            destroy_gui(gui_id)
            return
        end
    end

    -- no existing gui for player, open a new gui
    open_gui(player)
end

local function handle_action(action, event)
    if action.action == "close-window" then
        destroy_gui(action.gui_id)
    end
    if action.action == "open-train-log" then -- mod-gui-button
        local player = game.players[event.player_index]
        open_or_close_gui(player, event.control or event.shift)
    end
end

gui.hook_events(function(event)
	local action = gui.read_action(event)
	if action then
        if action.type == "generic" then
            handle_action(action, event)
        elseif action.type == "table" then
            events_table.handle_action(action, event)
        elseif action.type == "toolbar" then
            toolbar.handle_action(action, event)
        end
	end
end)

return {
    open_or_close_gui = open_or_close_gui,
    open = open_gui
}