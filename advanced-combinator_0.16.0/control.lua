-- Use item tags. When removing an item, save its tags, when placing item use tags if any exist. Use the config string as the tag
-- /c local t = game.player.selected.get_control_behavior().parameters.parameters[1].signal; for i, v in pairs(t) do game.print(i .. " = " .. v) end

local logic = require "logic"
local gui = require "gui"
local model = require "model"
local perform = model.perform
local advanced_combinators = {}
local runtime_combinators = {}

local function out(txt)
  local debug = false
  if debug then
    game.print(txt)
  end
end

local function txtpos(pos)
  return "{" .. pos["x"] .. ", " .. pos["y"] .."}"
end

local function worldAndPos(entity, key)
  return entity.surface.name .. txtpos(entity.position)
end

local function onInit()
  global.advanced_combinators = {}
end

local function onLoad()
  advanced_combinators = global.advanced_combinators
  for k, v in pairs(advanced_combinators) do
    runtime_combinators[k] = model.parse(v)
  end
end

local function updateConfiguration(entity)
  if entity.name ~= "advanced-combinator" then
    game.print("Can't update configuration of a non-advanced-combinator")
    return
  end
  runtime_combinators[worldAndPos(entity)] = model.parse(advanced_combinators[worldAndPos(entity)], entity)
end

local function onPlaceEntity(event)
  local entity = event.created_entity
  if entity.name == "advanced-combinator" then
    advanced_combinators[worldAndPos(entity)] = {
      entity = event.created_entity,
      updatePeriod = 1,
      config = "item/iron-plate = const(20)\nvirtual/signal-A = green(this,item/iron-plate)\nvirtual/signal-B = add(const(20),green(this,item/copper-plate))"
      -- config = "iron-plate = sum(const(20), green(this, copper-plate))"
    }
    updateConfiguration(entity)
  end
end

local function onRemoveEntity(event)
  local entity = event.entity
  advanced_combinators[worldAndPos(entity)] = nil
end

local function onTick()
  for k, v in pairs(advanced_combinators) do
    if game.tick % v.updatePeriod == 0 then
      model.perform(v, runtime_combinators[k])
    end
  end
end

function onGuiOpened(event)
  local player = game.players[event.player_index]
  if event.gui_type ~= defines.gui_type.entity then
    return
  end
  local entity = event.entity
  if entity.name == "advanced-combinator" then
    local advanced_combinator = advanced_combinators[worldAndPos(entity)]
    if advanced_combinator.entity and advanced_combinator.entity.valid and advanced_combinator.entity == entity then
      gui.openGUI(player, entity)
    end
  end
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


--script.on_event(defines.events.on_gui_click, onClick)
--script.on_event(defines.events.on_gui_elem_changed, onChosenElementChanged)
--script.on_event(defines.events.on_gui_checked_state_changed, onCheckboxClick)
--script.on_event(defines.events.on_selected_entity_changed, onSelectedEntityChanged)
--script.on_event(defines.events.on_entity_settings_pasted, onPasteSettings)
--script.on_event(defines.events.on_gui_closed, onGuiClosed)
--script.on_configuration_changed(onConfigurationChanged)
