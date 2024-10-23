local gui_utils = require("gui/gui_utils")
local tables = require("__flib__.table")

local USE_STATION_PAYLOAD_SUMMARY = true

local function flat_map(tbl, mapper)
    local output = {}
    for k, v in pairs(tbl) do
        local result = mapper(v, k)
        for _, item in pairs(result) do
            table.insert(output, item)
        end
    end
    return output
end

local function create_new_summary()
    return {
        stations = {},
        items = {},
        fluids = {}
    }
end

local function add_station_payload_summary(summary, station, type, name, count)
    local station_name = station.backer_name
    local payload_summary = summary.stations[station_name].payload_summary
    if not payload_summary[type] then
        payload_summary[type] = {}
    end
    local payload_type_summary = payload_summary[type]
    if not payload_type_summary[name] then
        payload_type_summary[name] = 0
    end
    payload_type_summary[name] = payload_type_summary[name] + count
end

local function station_summary_children(station_payload_summary, gui_id)
    local children = {}
    for type, v in pairs(station_payload_summary) do
        for name, count in pairs(v) do
            -- For station summary, reverse count so that positive = give to station, negative = take from station. Instead of "to/from train"
            local color = -count > 0 and "green" or "red"
            table.insert(children, gui_utils.sprite_button_type_name_amount(type, name, -count, color, gui_id))
        end
    end
    return children
end

local function add_diff(event, summary, last_station)
    if event.diff then
        local has_station = last_station and last_station.valid
        for name, count in pairs(event.diff.items) do
            summary.items[name] = summary.items[name] or { loaded = 0, unloaded = 0, sum = 0, name = name }
            local data = summary.items[name]
            data.loaded = data.loaded + (count > 0 and count or 0)
            data.unloaded = data.unloaded + (count < 0 and count or 0)
            data.sum = data.sum + count
            if USE_STATION_PAYLOAD_SUMMARY and has_station then
                add_station_payload_summary(summary, last_station, "item", name, count)
            end
        end
        for name, count in pairs(event.diff.fluids) do
            summary.fluids[name] = summary.fluids[name] or { loaded = 0, unloaded = 0, sum = 0, name = name }
            local data = summary.fluids[name]
            data.loaded = data.loaded + (count > 0 and count or 0)
            data.unloaded = data.unloaded + (count < 0 and count or 0)
            data.sum = data.sum + count
            if USE_STATION_PAYLOAD_SUMMARY and has_station then
                add_station_payload_summary(summary, last_station, "fluid", name, count)
            end
        end
    end
end

local function add_station_stop(event, summary)
    if event.station and event.station.valid then
        local station_name = event.station.backer_name
        local stations = summary.stations
        stations[station_name] = stations[station_name] or {
            station = event.station,
            stops = 0,
            payload_summary = {},
            position = event.station.position
        }
        stations[station_name].stops = stations[station_name].stops + 1
    end
end

local function create_gui(summary, gui_id)
    local stations = tables.filter(summary.stations, function() return true end, true)
    local items = tables.filter(summary.items, function() return true end, true)
    local fluids = tables.filter(summary.fluids, function() return true end, true)

    table.sort(stations, function(a, b) return a.stops > b.stops end)
    table.sort(items, function(a, b) return a.loaded > b.loaded end)
    table.sort(fluids, function(a, b) return a.loaded > b.loaded end)

    local _, stations_top = tables.for_n_of(stations, nil, 10, function(station)
        return {
            icon = {
                type = "sprite-button",
                sprite = "entity/" .. station.station.name,
                actions = {
                    on_click = { type = "table", action = "position", position = station.position }
                }
            },
            name = {
                type = "label",
                caption = station.station.backer_name
            },
            count = {
                type = "label",
                caption = tostring(station.stops)
            },
            payload = {
                type = "table",
                column_count = 6,
                children = station_summary_children(station.payload_summary, gui_id)
            }
        }
    end)

    local _, items_top = tables.for_n_of(items, nil, 30, function(item)
        local prototype = prototypes.item[item.name]
        local sprite = prototype and ("item/" .. item.name) or nil
        local tooltip = prototype and prototype.localised_name or ("item/" .. item.name)
        return {
            type = "sprite-button",
            sprite = sprite,
            number = item.loaded,
            actions = {
                on_click = {
                    type = "toolbar", action = "filter",
                    filter = "item", value = item.name, gui_id = gui_id
                }
            },
            tooltip = tooltip
        }
    end)

    local _, fluids_top = tables.for_n_of(fluids, nil, 30, function(fluid)
        local prototype = prototypes.fluid[fluid.name]
        local sprite = prototype and ("fluid/" .. fluid.name) or nil
        local tooltip = prototype and prototype.localised_name or ("fluid/" .. fluid.name)
        return {
            type = "sprite-button",
            sprite = sprite,
            number = fluid.loaded,
            actions = {
                on_click = {
                    type = "toolbar", action = "filter",
                    filter = "fluid", value = fluid.name, gui_id = gui_id
                }
            },
            tooltip = tooltip
        }
    end)

    return {
        {
            type = "label",
            caption = { "train-log.summary-top-stations" }
        },
        {
            type = "table",
            column_count = 4,
            children = flat_map(stations_top, function(v)
                return { v.icon, v.name, v.count, v.payload }
            end)
        },
        {
            type = "label",
            caption = { "train-log.summary-top-items" }
        },
        {
            type = "table",
            column_count = 10,
            children = items_top
        },
        {
            type = "label",
            caption = { "train-log.summary-top-fluids" }
        },
        {
            type = "table",
            column_count = 10,
            children = fluids_top
        }
    }
end

return {
    add_diff = add_diff,
    create_new_summary = create_new_summary,
    add_station_stop = add_station_stop,
    create_gui = create_gui
}
