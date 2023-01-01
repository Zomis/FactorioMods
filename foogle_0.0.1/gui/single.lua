local guis = require("__flib__.gui")
local tables = require("__flib__.table")
local integrations = require("integrations")
local header = require("gui/header")

local function open(action, event)
    -- List thing, list integrations, possibly add other built-in links.
    local player = game.players[event.player_index]
    local info = action
    local integrations = integrations.find(info)
    local gui = guis.build(player.gui.screen, {
        {
            type = "frame",
            direction = "vertical",
            ref = { "window" },
            children = {
                header({ "foogle.title-single" }),
                {
                    type = "sprite",
                    sprite = action.sprite
                },
                {
                    type = "scroll-pane",
                    style = "flib_naked_scroll_pane_no_padding",
                    vertical_scroll_policy = "always",
                    style_mods = {width = 650, height = 400, padding = 6},
                    children = {
                        {
                            type = "flow",
                            direction = "vertical",
                            children = tables.map(integrations, function(v)
                                return {
                                    type = "button",
                                    caption = "HELLO WORLD " .. v.mod_name,
                                    actions = {
                                        on_click = { type = "integration", integration = v, player = player, info = info }
                                    }
                                }
                            end)
                        },
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