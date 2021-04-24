local events = require("__flib__.event")

-- TODO: Auto-delete events after 6h or so?

local function new_current(train)
    return {
        -- Required because front_stock might not be valid later
        force_index = train.front_stock.force.index,
        train = train,
        started_at = game.tick,
        last_change = game.tick,
        events = {}
    }
end

local function train_data(train, train_id)
    if not global.trains[train_id] then
        global.trains[train_id] = new_current(train)
    end

    return global.trains[train_id]
end

local function get_logs(force)
    return tables.filter(global.trains, function(train_data)
        return train_data.force_index == force.index
    end)
end

local function add_log(train_data, log_event)
    train_data.last_change = game.tick
    table.insert(train_data.events, log_event)
end

local function finish_current_log(train, train_id, train_data)
    table.insert(global.history, train_data)
    global.trains[train_id] = new_current(train)
end

events.on_train_schedule_changed(function(event)
    local train = event.train
    local train_id = train.id
    local train_data = train_data(train, train_id)
    add_log(train_data, {
        tick = game.tick,
        schedule = train.schedule,
        changed_by = event.player_index
    })
end)

local interesting_states = {
    [defines.train_state.path_lost] = true,
    [defines.train_state.no_schedule] = true,
    [defines.train_state.no_path] = true,
    [defines.train_state.wait_signal] = true,
    [defines.train_state.wait_station] = true,
    [defines.train_state.manual_control_stop] = true,
    [defines.train_state.manual_control] = true,
    [defines.train_state.destination_full] = true
}

events.on_train_changed_state(function(event)
    local train = event.train
    local train_id = train.id
    local train_data = train_data(train, train_id)

    local interesting_event = interesting_states[event.old_state] or interesting_states[train.state]
    if not interesting_event then
        return
    end

    if event.old_state == defines.train_state.wait_station and event.train.state == defines.train_state.arrive_station then
        -- Temporary stop at the same position as a station (common with LTN)
        return
    end



    -- Save waiting for signals, start and end in the same
       -- time waited at signal, signal entity + position
    -- Save waiting at temporary stop, as long as it doesn't change from wait_station to arrive_stations
    -- Save waiting at train station

    local log = {
        tick = game.tick,
        old_state = event.old_state,
        state = train.state
    }
    if event.old_state == defines.train_state.wait_station then
        log.contents = train.get_contents()
        log.fluids = train.get_fluid_contents()
    end
    if train.state == defines.train_state.wait_station then
        -- TODO: if it is a temporary train stop, then save position instead and show something like virtual/signal-dot (use material design icon)
        log.station = train.station
    end
    add_log(train_data, log)

    if train.state == defines.train_state.wait_station and train.schedule.current == 1 then
        finish_current_log(train, train_id, train_data)
    end
end)

return {
    get_logs = get_logs
}
