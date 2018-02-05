local logic = require "logic"

remote.add_interface("advanced-combinator", {
  resolve = function(param, entity, current)
    local logic_data = logic.logic[param.name]
    if not logic_data then
      error("No such function name: " .. param.name)
    end
    local parsed = logic.parse(logic_data, param.params, entity)
    return parsed(entity, current)
  end,
  add_function = function(name, function_declaration)
    if logic.logic[name] then
      error("Function " .. name .. " already exists")
    end
    local callback_interface = function_declaration.parse
    function_declaration.parse = function(params)
      -- Prepare parameters so that they can be sent between mods.
      -- Mods needs to call `remote.call("advanced-combinator", "resolve", param_value, entity, current)`
      for _, v in pairs(params) do
        if type(v) == "table" then
          v.func = nil
        end
      end
      return function(entity, current)
        return remote.call(callback_interface.interface, callback_interface.func, params, entity, current)
      end
    end
    logic.logic[name] = function_declaration
  end
})
