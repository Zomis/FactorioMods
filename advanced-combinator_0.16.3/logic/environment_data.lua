local common = require "../common"

return {
  gameData = {
    description = "Get data from current game",
    parameters = { "game-data" },
    result = "number",
    parse = function(params, logic)
      local param = params[1]
      return function()
        return logic.numeric(game[param])
      end
    end
  },
  surfaceData = {
    description = "Get data from current surface",
    parameters = { "surface-data" },
    result = "number",
    parse = function(params, logic)
      local param = params[1]
      return function(entity)
        return logic.numeric(entity.surface[param])
      end
    end
  },
  forceData = {
    description = "Get data from the force owning this Advanced Combinator",
    parameters = { "force-data" },
    result = "number",
    parse = function(params, logic)
      local param = params[1]
      return function(entity)
        return logic.numeric(entity.force[param])
      end
    end
  },
  entityData = {
    description = "Get data from an entity",
    parameters = { "entity", "entity-data" },
    result = "number",
    parse = function(params, logic)
      local target = params[1]
      local param = params[2]
      return function(entity)
        local resolved = logic.resolve_entity(entity, target)
        if not resolved or not resolved.valid then
          return 0
        end
        local status, result = pcall(function()
          return logic.numeric(resolved[param])
        end)
        if not status then
          entity.force.print("[Advanced Combinator] " .. common.worldAndPos(entity) .. ": " .. result)
          return 0
        end
        return result
      end
    end
  }
}
