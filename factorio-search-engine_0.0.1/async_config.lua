local searcher = require "searcher/main_searcher"
local step3 = require "gui/step_3_progress_and_result"

local function async_search_step(values, task)
    searcher:search_step(task, values)
end

local function async_search_completed(task)
    step3.search_completed(task)
end

Async:configure_loop_functions(function(loop)
    return searcher:loop_function(loop)
end)

Async:configure(function(task)
    if task.type == "search" then
        return {
            perform_function = async_search_step,
            on_finished = async_search_completed
        }
    end
    error("Unrecognized async task.")
end)
