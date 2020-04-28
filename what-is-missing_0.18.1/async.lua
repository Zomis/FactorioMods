local tasks = {}

-- Functions for handling long-running things over a period of time.

Async = {}
Async.__index = Async
AsyncTask = {}
AsyncTask.__index = AsyncTask

local async_tasks = {}

local function add_async_task(task)
    if not async_tasks then
        async_tasks = {}
        global.async_tasks = async_tasks
    end
    for k, existing_task in pairs(async_tasks) do
        if existing_task:is_completed() then
            async_tasks[k] = task
            return
        end
    end
    table.insert(async_tasks, task)
end

function Async:perform_once(loops, perform_function, on_finished)
    if not perform_function then
        error("No perform function specified")
    end
    local obj = {}
    setmetatable(obj, AsyncTask)
    obj.completions = 0
    obj.interval = 1
    obj.remaining = 1
    obj.loops = loops
    obj.loop_counts = table_size(loops)
    obj.perform_function = perform_function
    obj.on_finished = on_finished
    obj:restart_loops()
    add_async_task(obj)
    return obj
end

function Async:delayed(delay_ticks, perform_function)
    local sleep_loop = Async:loop("sleep", 1, delay_ticks)
    return Async:perform_once({ sleep_loop }, function() end, perform_function)
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
    return { type = "loop", identifier = name, start = start, stop = stop }
end

function Async:loop_func(name, func)
    return { type = "loop_func", identifier = name, func = func }
end

function Async:loop_values(name, values)
    return { type = "loop_values", identifier = name, values = values }
end

function AsyncTask:restart_loops()
    self.state = {}
    self.loops_iterator = nil
    self.iterators = {}

    for loop_index, loop in pairs(self.loops) do
        local loop = self.loops[loop_index]
        local it, value = loop_next(loop, nil, self.iterators, self.state)
        self.iterators[loop_index] = it
        self.state[loop.identifier] = value
        if it == nil then
            -- if any of the loops are empty, there is nothing to loop
            self:finished()
            return
        end
    end
end

function AsyncTask:next_iteration()
    local loop_index = self.loop_counts

    while true do
        local loop = self.loops[loop_index]
        local it, value = loop_next(loop, self.iterators[loop_index], self.iterators, self.state)
        self.iterators[loop_index] = it
        self.state[loop.identifier] = value
        if it == nil then
            -- if iterator on loop_index is nil, then the current loop is finished so we must go to the next loop and iterate to the next there
            loop_index = loop_index - 1
            if loop_index == 0 then
                self:finished()
                return
            end
        elseif self.iterators[loop_index] and loop_index == self.loop_counts then
            -- if we're on last loop and last loop is not nil, then we're good to go for next perform call.
            return
        else
            loop_index = loop_index + 1
        end
    end
end

function AsyncTask:finished()
    self.completions = self.completions + 1
    self.remaining = self.remaining - 1
    if self.on_finished then
        game.print("Finished")
        game.print(serpent.line(self.on_finished))
        self.on_finished(self)
    end
end

function AsyncTask:call_perform_function()
--    log("Call perform with " .. serpent.line(self.state))
    self.perform_function(self.state)
end

function AsyncTask:tick(tick)
    if self.remaining == 0 then
        return
    end
    if tick % self.interval == 0 then
        self:call_perform_function()
        self:next_iteration()
    end
end

function AsyncTask:is_completed()
    return self.remaining == 0
end

function Async:on_tick()
    if async_tasks == nil then
        return
    end
    local tick = game.tick
    for k, task in pairs(async_tasks) do
        task:tick(tick)
    end
    if tick % 3600 == 2700 then
        -- Cleanup tasks
        log("Cleanup async tasks")
        for k, task in pairs(async_tasks) do
            if task:is_completed() then
                log("Cleaned async task " .. k)
                async_tasks[k] = nil
            end
        end
        return
    end
end

function Async:on_load()
    async_tasks = global.async_tasks
    if async_tasks then
        for _, task in pairs(async_tasks) do
            setmetatable(task, AsyncTask)
        end
    end
end

function Async:on_init()
    global.async_tasks = global.async_tasks or {}
    async_tasks = global.async_tasks
end

return Async
