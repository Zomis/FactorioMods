local searcher = require "searcher/main_searcher"
local step3 = require "gui/step_3_progress_and_result"

local function async_search_step(values, task_data)
    searcher:search_step(task_data, values)
end

local function async_search_update(task)
    step3.search_progress(task)
end

local function async_search_completed(task_data, task)
    step3.search_completed(task_data, task)
end

Async:configure_loop_functions(function(loop)
    return searcher:loop_function(loop)
end)

Async:configure(function(task)
    if task.type == "search" then
        return {
            perform_function = async_search_step,
            progress_function = async_search_update,
            on_finished = async_search_completed
        }
    end
    error("Unrecognized async task.")
end)
