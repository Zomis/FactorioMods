local tables = require("__flib__.table")
local MAX_KEEP = 60 * 60 * 60 * 24 -- ticks * seconds * minutes * hours

local function clear_older_force(force_index, older_than)
    -- local old_size = table_size(storage.history)
    storage.history = tables.filter(storage.history, function(v)
        return v.force_index ~= force_index or v.last_change >= older_than
    end, true)
    storage.trains = tables.filter(storage.trains, function(v)
        return v.train.valid
    end, false)
    -- game.print("Clear older " .. old_size .. " => " .. table_size(storage.history) .. " for force " .. force_index)
end

local function clear_older(player_index, older_than)
    local force_index = game.players[player_index].force.index
    clear_older_force(force_index, older_than)
end

local function new_current(train)
    return {
        -- Required because front_stock might not be valid later
        force_index = train.front_stock.force.index,
        train = train,
        started_at = game.tick,
        last_change = game.tick,
        contents = {},
        events = {}
    }
end

local function diff(old_values, new_values)
    local result = {}
    if old_values then
        for k, v in pairs(old_values) do
            result[k] = -v
        end
    end
    if new_values then
        for k, v in pairs(new_values) do
            local old_value = result[k] or 0
            result[k] = old_value + v
        end
    end
    return result
end

local function get_train_data(train, train_id)
    if not storage.trains[train_id] then
        storage.trains[train_id] = new_current(train)
    end

    return storage.trains[train_id]
end

local function get_logs(force)
    return tables.filter(storage.trains, function(train_data)
        return train_data.force_index == force.index
    end)
end

local function add_log(train_data, log_event)
    train_data.last_change = game.tick
    table.insert(train_data.events, log_event)
end

local function finish_current_log(train, train_id, train_data)
    table.insert(storage.history, train_data)
    local new_data = new_current(train)
    storage.trains[train_id] = new_data
    clear_older_force(new_data.force_index, game.tick - MAX_KEEP)
end

script.on_event(defines.events.on_train_schedule_changed, function(event)
    local train = event.train
    local train_id = train.id
    local train_data = get_train_data(train, train_id)
    add_log(train_data, {
        tick = game.tick,
        schedule = train.schedule,
        changed_by = event.player_index
    })
end)

local interesting_states = {
    [defines.train_state.no_schedule] = true,
    [defines.train_state.no_path] = true,
    [defines.train_state.wait_signal] = false, -- TODO: Add wait at signal info later
    [defines.train_state.wait_station] = true,
    [defines.train_state.manual_control_stop] = true,
    [defines.train_state.manual_control] = true,
    [defines.train_state.destination_full] = true
}

local function contents_as_table(contents)
    local result = {}
    for _, v in pairs(contents) do
        result[v.name] = v.count -- TODO: Consider quality!
    end
    return result
end

local function read_contents(train)
    return {
        items = contents_as_table(train.get_contents()),
        fluids = train.get_fluid_contents()
    }
end

script.on_event(defines.events.on_train_changed_state, function(event)
    local train = event.train
    local train_id = train.id
    local train_data = get_train_data(train, train_id)

    local new_state = train.state
    local interesting_event = interesting_states[event.old_state] or interesting_states[new_state]
    if not interesting_event then
        return
    end

    --if event.old_state == defines.train_state.wait_station and new_state == defines.train_state.arrive_station then
        -- Temporary stop at the same position as a station (common with LTN)
    --    return
    --end

    local log = {
        tick = game.tick,
        old_state = event.old_state,
        state = train.state
    }
    if event.old_state == defines.train_state.wait_station then
        local diff_items = diff(train_data.contents.items, contents_as_table(train.get_contents()))
        local diff_fluids = diff(train_data.contents.fluids, train.get_fluid_contents())
        train_data.contents = read_contents(train)
        log.diff = {
            items = diff_items,
            fluids = diff_fluids
        }
        log.surface = train.front_end.rail.surface.name
        -- end old entry, but save timestamp somewhere
    end
    if new_state == defines.train_state.wait_station then
        -- create new entry
        -- train_data.contents_on_enter = ...

        -- always log position
        log.position = train.front_stock.position
        if train.station then
            train_data.contents = read_contents(train)
            log.contents = train_data.contents.items
            log.fluids = train_data.contents.fluids
            log.station = train.station
            log.surface = train.front_end.rail.surface.name
        end
    end

    -- Show train, time since last station, station name, entered with contents, and content diff

    -- Save waiting for signals, start and end in the same
       -- time waited at signal, signal entity + position
    -- Save waiting at temporary stop, as long as it doesn't change from wait_station to arrive_station
    -- Save waiting at train station

    add_log(train_data, log)

    if train.state == defines.train_state.wait_station and train.schedule.current == 1 then
        finish_current_log(train, train_id, train_data)
    end
end)

return {
    clear_older = clear_older,
    get_logs = get_logs
}
