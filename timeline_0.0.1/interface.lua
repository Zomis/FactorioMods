local mark_timeline = require "timeline"

remote.add_interface("timeline", {
  add_timeline_mark = function(force, name, params, value)
    mark_timeline(force, name, params, value)
  end,
  advanced_combinator_callback = function(params, entity, current)
    local param_name = params[1]
    local param_params = params[2]
    local param_value = params[3]
    local value = remote.call("advanced-combinator", "resolve", param_value, entity, current)
    mark_timeline(entity.force, param_name, param_params, value)
  end
})

local function setup_integrations()
  if remote.interfaces["advanced-combinator"] then
    local advanced_combinator = remote.interfaces["advanced-combinator"]
    remote.call("advanced-combinator", "add_function", "add_timeline_mark", {
      description = "Add a mark to the timeline, with the specified name, params and value.",
      parameters = { "string", "string", "number" },
      result = "command",
      parse = { interface = "timeline", func = "advanced_combinator_callback" }
    })
  end
end

return { setup_integrations = setup_integrations }
