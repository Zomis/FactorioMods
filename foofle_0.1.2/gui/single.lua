local guis = require("__flib__.gui")
local tables = require("__flib__.table")
local impl = require("impl")
local header = require("gui/header")

local function open(action, event)
    -- List thing, list integrations, possibly add other built-in links.
    local player = game.players[event.player_index]
    local info = action
    local plugins = impl.find(info)
    local sprite = action.sprite or (action.type .. "/" .. action.name)
    local gui = guis.build(player.gui.screen, {
        {
            type = "frame",
            direction = "vertical",
            ref = { "window" },
            children = {
                header({ "foofle.title-single" }),
                {
                    type = "sprite",
                    sprite = sprite
                },
                {
                    type = "scroll-pane",
                    style = "flib_naked_scroll_pane_no_padding",
                    --vertical_scroll_policy = "always",
                    --style_mods = {width = 650, height = 400, padding = 6},
                    children = {
                        {
                            type = "flow",
                            direction = "vertical",
                            children = tables.map(plugins, function(v)
                                if not v.quick_button then
                                    return {}
                                end
                                local button = tables.deep_copy(v.quick_button)
                                button.actions = {
                                    on_click = { type = "plugin", plugin_id = v.id, player = player, info = info }
                                }
                                return button
                            end)
                        },
                        {
                            type = "flow",
                            direction = "vertical",
                            children = tables.map(plugins, function(v)
                                if v.show then
                                    return v.show(player, info)
                                end
                                return {}
                            end)
                        }
                    }
                }
            }
        }
    })
    gui.titlebar.drag_target = gui.window
    gui.window.force_auto_center()
end

return {
    open = open
}