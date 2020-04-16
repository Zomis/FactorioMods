local tasks = {}

-- Functions for handling long-running things over a period of time.

Async = {}
Async.__index = Async

local async_tasks = {}

local function add_async_task(task)
    for k, existing_task in pairs(async_tasks) do
        if existing_task:is_completed() then
            async_tasks[k] = task
            return
        end
    end
    table.insert(async_tasks, task)
end

function Async:perform_once(loops, perform_function)
    local obj = {}
    setmetatable(obj, Async)
    obj.completions = 0
    obj.interval = 1
    obj.remaining = 1
    obj.loops = loops
    obj.loop_counts = table_size(loops)
    obj.perform_function = perform_function
    obj:restart_loops()
    add_async_task(obj)
    return obj
end

function Async:loop(name, start, stop)
    local values = {}
    for i = start, stop do
        table.insert(values, i)
    end
    return { type = "loop", identifier = name, values = values }
end

function Async:loop_values(name, values)
    return { type = "loop", identifier = name, values = values }
end

function Async:restart_loops()
    self.state = {}
    self.loops_iterator = nil
    self.iterators = {}

    for loop_index, loop in pairs(self.loops) do
        local loop = self.loops[loop_index]
        local it, value = next(loop.values, nil)
        self.iterators[loop_index] = it
        self.state[loop.identifier] = value
    end
end

function Async:next_iteration()
    local loop_index = self.loop_counts

    while true do
        local loop = self.loops[loop_index]
        local it, value = next(loop.values, self.iterators[loop_index])
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

function Async:finished()
    self.completions = self.completions + 1
    self.remaining = self.remaining - 1
end

function Async:call_perform_function()
    log("Call perform with " .. serpent.line(self.state))
    self.perform_function(self.state)
end

function Async:tick(tick)
    if self.remaining == 0 then
        return
    end
    if tick % self.interval == 0 then
        self:call_perform_function()
        self:next_iteration()
    end
end

function Async:is_completed()
    return self.remaining == 0
end

function Async:on_tick()
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
end

function Async:on_init()
    global.async_tasks = global.async_tasks or {}
    async_tasks = global.async_tasks
end

local function async_command_step(event)
    local player = game.players[event.player_index]
    if event.command == "async_create" then
        local loop1 = Async:loop("a", 1, 3)
        local loop2 = Async:loop("b", 1, 2)
        local loop3 = Async:loop("c", 1, 3)
        local perform = function(state)
            game.print(serpent.line(state))
        end
        local new_async = Async:perform_once({ loop1, loop2, loop3 }, perform)
        game.print("Created loop example task")
    end
    if event.command == "async_test" then
        for _, task in pairs(async_tasks) do
            task:tick(game.tick)
        end
    end
    if event.command == "async_once" then
    end
end

script.on_event(defines.events.on_console_command, async_command_step)

return Async
