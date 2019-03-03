-- Use item tags. When removing an item, save its tags,
-- when placing item use tags if any exist. Use the config string as the tag

local gui = require "gui"
local model = require "model"
local common = require "common"
local advanced_combinators = {}
local runtime_combinators = {}
require "interface"

local function onInit()
  global.advanced_combinators = {}
end

local function onLoad()
  advanced_combinators = global.advanced_combinators
end

local function parse_combinator(advanced_combinator)
  local v = advanced_combinator
  local status, result = pcall(function()
    return model.parse(v, v.entity)
  end)
  if not status then
--    runtime_combinators[k] = result
--  else
    v.entity.force.print("[Advanced Combinator] Unable to parse combinator at " ..
      common.worldAndPos(v.entity) .. ": " .. result)
  end
  for _, player in pairs(v.entity.force.players) do
    if player.gui.center["advancedCombinatorUI"] then
      player.gui.center["advancedCombinatorUI"].destroy()
    end
  end
  if status then
    return result
  end
end

local function updateConfiguration(entity)
  if entity.name ~= "advanced-combinator" then
    game.print("Can't update configuration of a non-advanced-combinator")
    return
  end
  local status, result = pcall(function()
    return model.parse(advanced_combinators[common.worldAndPos(entity)], entity)
  end)
  if status then
    runtime_combinators[common.worldAndPos(entity)] = result
    entity.force.print("[Advanced Combinator] Updated Advanced Combinator at " ..
      common.worldAndPos(entity))
    return result
  else
    entity.force.print("[Advanced Combinator] Error parsing combinator at " ..
      common.worldAndPos(entity) .. result)
  end
end

local function onPlaceEntity(event)
  local entity = event.created_entity
  if entity.name == "advanced-combinator" then
    advanced_combinators[common.worldAndPos(entity)] = {
      entity = event.created_entity,
      updatePeriod = 1,
      config = "comment(Output the number of minutes you have played this map);\n" ..
          "set_simple(1,virtual/signal-T,div(gameData(tick),const(3600)));"
    }
    updateConfiguration(entity)
  end
end

local function onRemoveEntity(event)
  local entity = event.entity
  if entity.name == "advanced-combinator" then
    advanced_combinators[common.worldAndPos(entity)] = nil
  end
end

local function onTick()
  for k, v in pairs(advanced_combinators) do
    if not runtime_combinators[k] then
      runtime_combinators[k] = parse_combinator(v)
    end
    if game.tick % v.updatePeriod == 0 then
      model.perform(v, runtime_combinators[k])
    end
  end
end

local function onGuiOpened(event)
  local player = game.players[event.player_index]
  if event.gui_type ~= defines.gui_type.entity then
    return
  end
  local entity = event.entity
  if entity.name == "advanced-combinator" then
    local advanced_combinator = advanced_combinators[common.worldAndPos(entity)]
    if not advanced_combinator then
      player.print("Advanced Combinator does not seem to exist.")
      return
    end
    if advanced_combinator.entity and advanced_combinator.entity.valid and advanced_combinator.entity == entity then
      local runtime = runtime_combinators[common.worldAndPos(entity)]
      gui.openGUI(player, advanced_combinator, runtime)
    end
  end
end

local function onClick(event)
  local player = game.players[event.player_index]
  gui.click(player, event.element, updateConfiguration)
end

local function onGuiChange(event)
  local player = game.players[event.player_index]
  gui.change(player, event.element)
end

script.on_init(onInit)
script.on_load(onLoad)

script.on_event(defines.events.on_built_entity, onPlaceEntity)
script.on_event(defines.events.on_robot_built_entity, onPlaceEntity)

script.on_event(defines.events.on_pre_player_mined_item, onRemoveEntity)
script.on_event(defines.events.on_robot_pre_mined, onRemoveEntity)
script.on_event(defines.events.on_entity_died, onRemoveEntity)

script.on_event(defines.events.on_tick, onTick)
script.on_event(defines.events.on_gui_opened, onGuiOpened)
script.on_event(defines.events.on_gui_click, onClick)
script.on_event(defines.events.on_gui_elem_changed, onGuiChange)
script.on_event(defines.events.on_gui_selection_state_changed, onGuiChange)
script.on_event(defines.events.on_gui_text_changed, onGuiChange)

--script.on_event(defines.events.on_gui_click, onClick)
--script.on_event(defines.events.on_gui_elem_changed, onChosenElementChanged)
--script.on_event(defines.events.on_gui_checked_state_changed, onCheckboxClick)
--script.on_event(defines.events.on_selected_entity_changed, onSelectedEntityChanged)
--script.on_event(defines.events.on_entity_settings_pasted, onPasteSettings) !!!
--script.on_event(defines.events.on_gui_closed, onGuiClosed)
--script.on_configuration_changed(onConfigurationChanged)
