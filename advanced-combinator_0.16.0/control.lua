-- Use item tags. When removing an item, save its tags,
-- when placing item use tags if any exist. Use the config string as the tag

local gui = require "gui"
local model = require "model"
local common = require "common"
local advanced_combinators = {}
local runtime_combinators = {}

local function onInit()
  global.advanced_combinators = {}
end

local function onLoad()
  advanced_combinators = global.advanced_combinators
  for k, v in pairs(advanced_combinators) do
    local status, result = pcall(function()
      return model.parse(v, v.entity)
    end)
    if status then
      runtime_combinators[k] = result
    else
      v.entity.force.print("[Advanced Combinator] Unable to parse combinator at " ..
        common.worldAndPos(v.entity) .. ": " .. result)
    end

    for _, player in pairs(v.entity.force.players) do
      if player.gui.center["advancedCombinatorUI"] then
        player.gui.center["advancedCombinatorUI"].destroy()
      end
    end
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
      config =
--        "1:virtual/signal-A = mod(add(previous(1),const(1)),const(60))\n" ..
--        "2:virtual/signal-B = current(1)\n" ..
--        "3:virtual/signal-C = add(green(this,item/iron-plate),red(this,item/copper-plate))\n" ..
        "4:virtual/signal-T = gameData(tick)\n" ..
        "5:virtual/signal-S = div(current(4),const(60))\n" ..
        "6:virtual/signal-H = div(current(5),const(3600))\n" ..
        "7:virtual/signal-M = mod(div(current(5),const(60)),const(60))\n" ..
        "5:virtual/signal-S = mod(current(5),const(60))\n"
--        "8:virtual/signal-W = mult(surfaceData(daytime),const(1000))\n" ..
--        "20:virtual/signal-Z = add(previous(4),green(this,item/iron-plate))"
    }
    updateConfiguration(entity)
  end
end

local function onRemoveEntity(event)
  local entity = event.entity
  advanced_combinators[common.worldAndPos(entity)] = nil
end

local function onTick()
  for k, v in pairs(advanced_combinators) do
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
