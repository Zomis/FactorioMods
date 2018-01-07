

local logic = {

  sum = {
    parameters = { "array" },
    result = "number",
    parse = function()
    end
  },
  const = {
    parameters = { "string" },
    result = "number",
    parse = function(params)
      local value = tonumber(params[1])
      return function() return value end
    end
  },
  array = {
    parameters = { "number" },
    varargs = true,
    result = "array",
    parse = function()
    end
  }



}


return logic
