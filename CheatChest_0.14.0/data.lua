require("util")

local cheat_chest

-- TODO: Change requester to provider
--Entity
cheat_chest = util.table.deepcopy(data.raw["logistic-container"]["logistic-chest-requester"])
cheat_chest.name = "cheat-chest"
cheat_chest.minable.result = "cheat-chest"
cheat_chest.logistic_mode = "requester"
data:extend({cheat_chest})

--Item
cheat_chest = util.table.deepcopy(data.raw["item"]["logistic-chest-requester"])
cheat_chest.name = "cheat-chest"
cheat_chest.place_result = "cheat-chest"
data:extend({cheat_chest})

--Recipe
cheat_chest = util.table.deepcopy(data.raw["recipe"]["logistic-chest-requester"])
cheat_chest.name = "cheat-chest"
cheat_chest.enabled = true
cheat_chest.ingredients =
{
  {"iron-plate", 1},
  {"copper-plate", 1}
}
cheat_chest.result = "cheat-chest"
data:extend({cheat_chest})
