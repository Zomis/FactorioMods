local tasks = {}

-- Functions for handling long-running things over a period of time.

Async = {}
Async.__index = Async
AsyncTask = {}
AsyncTask.__index = AsyncTask

local async_tasks = nil
local async_runtimes = {}
local async_initialized = false -- can't use configuration_function because that's set before LuaGameScript is available
local async_configuration_function = nil
local async_loop_function = nil

local function add_async_task(task)
    if not async_tasks then
        async_tasks = {}
        global.async_tasks = async_tasks
    end
    for k, existing_task in pairs(async_tasks) do
        if async_tasks[k] == task.save_state then
            -- Just load task, no need for inserting anything
            async_runtimes[k] = task
            return
        end
    end
    for k, existing_task in pairs(async_runtimes) do
        if existing_task:is_completed() then
            async_tasks[k] = task.save_state
            async_runtimes[k] = task
            return
        end
    end
    table.insert(async_tasks, task.save_state)
    table.insert(async_runtimes, task)
end

function Async:configure(configuration_function)
    async_configuration_function = configuration_function
end

function Async:configure_loop_functions(loop_lookup_function)
    async_loop_function = loop_lookup_function
end

function Async:load_task(task_state)
    local task = {}
    setmetatable(task, AsyncTask)
    task.save_state = task_state

    local task_config = Async:config_lookup(task_state.task_data)
    task:load_loop_functions()
    task.perform_function = task_config.perform_function
    task.on_finished = task_config.on_finished
    add_async_task(task)
    return task
end

function Async:perform_once(task_data, loops)
    local save_state = {}
    save_state.task_data = task_data
    save_state.completions = 0
    save_state.interval = 1
    save_state.steps_per_interval = 1
    save_state.remaining = 1
    save_state.loops = loops
    save_state.loop_counts = table_size(loops)
    local task = Async:load_task(save_state)
    task:restart_loops()
    return task.save_state
end

function Async:delayed(task_data, delay_ticks)
    local sleep_loop = Async:loop("sleep", 1, delay_ticks)
    local task = Async:perform_once(task_data, { sleep_loop })
    return task
end

function Async:config_lookup(task_data)
    if not async_configuration_function then
        error("Async has not been configured correctly. Call Async:configure(...)")
    end
    local result = async_configuration_function(task_data)
    if not result.perform_function then
        error("No perform_function for task " .. serpent.line(task_data) .. ". Check async configuration.")
    end
    return result
end

local function loop_next(loop, current, all_iterators, all_state)
    if loop.type == "loop" then
        if current == nil then
            return loop.start, loop.start
        elseif current == loop.stop then
            return nil, nil
        else
            return current + 1, current + 1
        end
    elseif loop.type == "loop_values" then
        return next(loop.values, current)
    elseif loop.type == "chunks" then
        local value = loop.iterator()
        return value, value
    elseif loop.type == "loop_func" then
        if current == nil then
            loop.values = loop.func(all_state, all_iterators)
        end
        return next(loop.values, current)
    elseif loop.type == "dynamic" then
        local value = loop.func(all_state, all_iterators, current)
        return value, value
    else
        error("Unknown loop type: " .. loop.type)
    end
end

function Async:chunks(name, surface)
    return { type = "chunks", identifier = name, iterator = surface.get_chunks() }
end

function Async:dynamic(name, func)
    return { type = "dynamic", identifier = name, func = func }
end

function Async:loop(name, start, stop)
    if start == nil or stop == nil then
        error("Unable to loop using start or stop as nil: " .. tostring(start) .. " - " .. tostring(stop))
    end
    return { type = "loop", identifier = name, start = start, stop = stop }
end

function Async:loop_func(name)
    return { type = "loop_func", identifier = name }
end

function Async:loop_values(name, values)
    return { type = "loop_values", identifier = name, values = values }
end

function AsyncTask:load_loop_functions()
    for _, loop in pairs(self.save_state.loops) do
        if loop.type == "loop_func" then
            if not async_loop_function then
                error("No loop lookup function set. Need to call Async:configure_loop_functions")
            end
            loop.func = async_loop_function(loop.identifier)
            if not loop.func then
                error("No loop lookup function found for " .. loop.identifier .. ". Need to check Async:configure_loop_functions configuration")
            end
        end
    end
end

function AsyncTask:restart_loops()
    local save_state = self.save_state
    save_state.state = {}
    save_state.loops_iterator = nil
    save_state.iterators = {}

    for loop_index, loop in pairs(save_state.loops) do
        local loop = save_state.loops[loop_index]
        local it, value = loop_next(loop, nil, save_state.iterators, save_state.state)
        save_state.iterators[loop_index] = it
        save_state.state[loop.identifier] = value
        if it == nil then
            -- if any of the loops are empty, there is nothing to loop
            self:finished()
            return
        end
    end
end

function AsyncTask:next_iteration()
    local save_state = self.save_state
    local loop_index = save_state.loop_counts

    while true do
        local loop = save_state.loops[loop_index]
        local it, value = loop_next(loop, save_state.iterators[loop_index], save_state.iterators, save_state.state)
        save_state.iterators[loop_index] = it
        save_state.state[loop.identifier] = value
        if it == nil then
            -- if iterator on loop_index is nil, then the current loop is finished so we must go to the next loop and iterate to the next there
            loop_index = loop_index - 1
            if loop_index == 0 then
                self:finished()
                return
            end
        elseif save_state.iterators[loop_index] and loop_index == save_state.loop_counts then
            -- if we're on last loop and last loop is not nil, then we're good to go for next perform call.
            return
        else
            loop_index = loop_index + 1
        end
    end
end

function AsyncTask:finished()
    self.save_state.completions = self.save_state.completions + 1
    self.save_state.remaining = self.save_state.remaining - 1
    if self.on_finished then
        -- game.print("Finished")
        self.on_finished(self.save_state.task_data)
    end
end

function AsyncTask:call_perform_function()
--    log("Call perform with " .. serpent.line(self.state))
    self.perform_function(self.save_state.state, self.save_state.task_data)
end

function AsyncTask:tick(tick)
    if self.save_state.remaining == 0 then
        return
    end
    if tick % self.save_state.interval == 0 then
        local steps_per_interval = self.save_state.steps_per_interval or 1
        for i = 1, steps_per_interval do
            if self.save_state.remaining ~= 0 then
                self:call_perform_function()
                self:next_iteration()
            end
        end
    end
end

function AsyncTask:is_completed()
    return self.save_state.remaining == 0
end

function Async:initialize()
    -- game.print("Async:initialize")
    -- perform configuration step
    if not global.async_tasks then
        global.async_tasks = {}
    end
    async_tasks = global.async_tasks
    for _, task_state in pairs(async_tasks) do
        Async:load_task(task_state)
    end
end

function Async:on_tick()
    if not async_initialized then
        Async:initialize()
        async_initialized = true
    end
    local tick = game.tick
    for _, task in pairs(async_runtimes) do
        task:tick(tick)
    end
    if tick % 3600 == 2700 then
        -- Cleanup tasks
        -- log("Cleanup async tasks")
        for k, task in pairs(async_runtimes) do
            if task:is_completed() then
                -- log("Cleaned async task " .. k)
                async_tasks[k] = nil
                async_runtimes[k] = nil
            end
        end
        return
    end
end

return Async
