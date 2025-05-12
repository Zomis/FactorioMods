local gui = require("__flib__.gui")
local gui_handlers = {}

local function header()
    return {
        type = "flow",
        name = "titlebar",
        children = {
            {type = "label", style = "frame_title", caption = {"fluid-connections-inspector.header"}, ignored_by_interaction = true},
            {type = "empty-widget", style = "flib_titlebar_drag_handle", ignored_by_interaction = true},
            {
                type = "sprite-button",
                style = "frame_action_button",
                sprite = "utility/close",
                hovered_sprite = "utility/close_black",
                clicked_sprite = "utility/close_black",
                handler = { [defines.events.on_gui_click] = gui_handlers.close_window },
            }
        }
    }
end

local function result_entities(tbl)
    local children = {}
    for _, v in pairs(tbl) do
        table.insert(children, {
            type = "sprite-button",
            sprite = "entity/" .. v.name,
            quality = v.quality.name,
            handler = {
                [defines.events.on_gui_click] = gui_handlers.go_to
            },
            tags = {
                surface = v.surface.name,
                x = v.position.x,
                y = v.position.y
            }
        })
    end

    -- Show table with entity link, recipe, contents?
    return {
        type = "table",
        column_count = 10,
        children = children,
        -- entity, recipe?, currently available
    }
end

local function result_array(tbl)
    local children = {}
    for _, v in pairs(tbl) do
        table.insert(children, {
            type = "sprite-button",
            sprite = "entity/" .. v.name,
            number = v.fluidbox[1].amount,
            quality = v.quality.name,
            handler = {
                [defines.events.on_gui_click] = gui_handlers.go_to
            },
            tags = {
                surface = v.surface.name,
                x = v.position.x,
                y = v.position.y
            }
        })
    end

    -- Show table with entity link, recipe, contents?
    return {
        type = "table",
        column_count = 10,
        children = children,
        -- entity, recipe?, currently available
    }
end

local function result_entity_counts(tbl)
    local children = {}
    local counts = {}

    for _, v in pairs(tbl) do
        local id = v.name .. "/" .. v.quality.name
        local entry = counts[id] or { name = v.name, quality = v.quality.name, count = 0 }
        entry.count = entry.count + 1
        counts[id] = entry
    end

    for _, v in pairs(counts) do
        table.insert(children, {
            type = "sprite-button",
            sprite = "entity/" .. v.name,
            number = v.count,
            quality = v.quality
        })
    end

    return {
        type = "table",
        column_count = 10,
        children = children,
    }
end

local function open_gui(player, results)
    local gui_contents = {
        {
            type = "frame",
            direction = "vertical",
            name = "window",
            elem_mods = { auto_center = true },
            children = {
                header(),
                {
                    type = "scroll-pane",
                    style = "flib_naked_scroll_pane_no_padding",
                    vertical_scroll_policy = "always",
                    style_mods = {width = 650, height = 400, padding = 6},
                    children = {
                        {
                            type = "flow",
                            direction = "vertical",
                            children = {
                                {
                                    type = "label",
                                    caption = { "fluid-connections-inspector.segment-id", results.segment_id },
                                },
                                {
                                    type = "label",
                                    caption = { "fluid-connections-inspector.inputs" },
                                },
                                result_entities(results.inputs),
                                {
                                    type = "label",
                                    caption = { "fluid-connections-inspector.outputs" },
                                },
                                result_entities(results.outputs),
                                {
                                    type = "label",
                                    caption = { "fluid-connections-inspector.storages" },
                                },
                                result_array(results.storages),
                                {
                                    type = "label",
                                    caption = { "fluid-connections-inspector.entities" },
                                },
                                result_entity_counts(results.scanned)
                            }
                        }
                    }
                },
            }
        }
    }
    local gui_obj = gui.add(player.gui.screen, gui_contents)
    gui_obj.titlebar.drag_target = gui_obj.window
end

function gui_handlers.go_to(event)
    local elem = event.element
    local player = game.players[event.player_index]
    local zoom = player.zoom
    player.set_controller {
        type = defines.controllers.remote,
        position = {
            x = elem.tags.x,
            y = elem.tags.y,
        },
        surface = elem.tags.surface
    }
    player.zoom = zoom
end

function gui_handlers.close_window(event)
    local el = event.element
    while el.parent do
        if el.name == "window" then
            el.destroy()
            return
        end
        el = el.parent
    end
end

gui.add_handlers(gui_handlers, function(e, handler)
    handler(e)
end)
gui.handle_events()

return {
    open = open_gui
}
