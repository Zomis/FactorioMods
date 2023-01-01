local guis = require("__flib__.gui")
local header = require("gui/header")

local function scan_entities(entities_to_scan)
    local entities = {}
    local contents = {}
    local settings = {}
    local signals = {}
    local text = {}
    for k, entity in pairs(entities_to_scan) do
        text["TYPE: " .. entity.type] = "TYPE: " .. entity.type
        text[entity.name] = entity.name
        if entity.type == "character" then
        end
    end

    return {
        entities = entities,
        contents = contents,
        settings = settings,
        signals = signals,
        text = text
    }
end

local function build_ui(groups)
    local results = {}
    for _, text in pairs(groups.text) do
        table.insert(results, {
            type = "label",
            caption = text
        })
    end
    return results
end

local function show_entities(player, entities)
    -- Entities
    -- Contents (inventories, storage, belts, pipes)
    -- Settings (e.g. recipes, signals)
    -- Signals (active signals)
    local result_groups = scan_entities(entities)

    local gui = guis.build(player.gui.screen, {
        {
            type = "frame",
            direction = "vertical",
            ref = { "window" },
            children = {
                header({ "foogle.selection-title" }),
                {
                    type = "flow",
                    direction = "vertical",
                    children = build_ui(result_groups)
                }
            }
        }
    })
    gui.titlebar.drag_target = gui.window
    gui.window.force_auto_center()
end

return {
    show_entities = show_entities
}