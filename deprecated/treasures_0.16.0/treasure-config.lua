local function possible_treasures()
  return {
    {
      name = "start",
      frequency = 1000,
      distanceFrequencyBonus = -20,
      minimumDistance = 0,
      items = {
        { name = "lab", min = 1, max = 3 },
        { name = "science-pack-1", probability = 0.42, min = 10, max = 100 },
        { name = "science-pack-2", probability = 0.42, min = 10, max = 100 }
      }
    },
    {
      name = "basic",
      frequency = 10,
      distanceFrequencyBonus = 0.001,
      minimumDistance = 2,
      items = {
        { name = "iron-plate", min = 10, max = 20 },
        { name = "copper-plate", probability = 0.42, min = 10, max = 100 },
        { name = "iron-plate", probability = 0.1, min = 1, max = 3, multiplier = 3 },
        { name = "transport-belt", probability = 0.2, min = 1, max = 3, multiplier = 3 }
      }
    },
    {
      name = "level 2",
      frequency = 10,
      minimumDistance = 2,
      items = {
        { name = "steel-plate", min = 10, max = 20 },
        { name = "stone", probability = 0.42, min = 10, max = 100 },
      }
    }
  }
end
--
--
--
--
--[[
package:
- contains multiple items
- rarity
- minimum-distance

item:
- probability
- min amount, max amount
- name


iron-plate
transport-belt, inserter, fast-inserter
straight-rail, locomotive, cargo-wagon
assembling-machine-2
lab, science-pack-1, science-pack-2, science-pack-3...
fast-transport-belt

]]


return { possible_treasures = possible_treasures }
