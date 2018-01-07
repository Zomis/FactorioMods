local function txtpos(pos)
  return "{" .. pos["x"] .. ", " .. pos["y"] .."}"
end

local function worldAndPos(entity, key)
  return entity.surface.name .. txtpos(entity.position)
end



local function perform(advanced_combinator, runtime_combinator)
  runtime_combinator(advanced_combinator.entity)
end

local function parse(advanced_combinator)
  local commands = {}
  for command in string.gmatch(advanced_combinator.config, "[^\n]+") do
    table.insert(commands, command)
  end

  return function(entity)
    local control = entity.get_control_behavior()
    local result = {}
    table.insert(result, {signal = { type = "item", name = "iron-plate" }, count = 1, index = 1})
    table.insert(result, {signal = { type = "item", name = "copper-plate" }, count = 2, index = 2})
    control.parameters = { parameters = result }

    -- game.print("Performing! " .. worldAndPos(entity) .. "@" .. game.tick)
  end
end

return { perform = perform, parse = parse }
