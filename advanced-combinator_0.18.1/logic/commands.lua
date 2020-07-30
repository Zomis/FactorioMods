return {
  print = {
    description = "Print a message to all players in the force. Allows substitution of current signal values using $1, $2, etc.",
    parameters = { "string" },
    result = "command",
    parse = function(params)
      local param_message = params[1]
      return function(entity, current)
        local message = param_message
        for search_result in string.gmatch(message, "$%d+") do
          local search_index = tonumber(string.sub(search_result, 2))
          local replace = "0"
          if current[search_index] then
            replace = current[search_index].count
          end
          message = string.gsub(message, search_result, replace)
        end
        entity.force.print(message)
      end
    end
  },
  comment = {
    description = "Does nothing. Just allows you to add a comment",
    parameters = { "string" },
    result = "command",
    parse = function()
      return function() end
    end
  }
}
