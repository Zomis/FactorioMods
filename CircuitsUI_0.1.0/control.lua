--control.lua
-- Show ALL signals connected to network, and the value of them
-- Button in top left to open up list of all UI Combinators
-- Condition on UI combinator for when to auto-show the data
-- Work in multiplayer
-- Configure update interval

require "signal_gui"

--We'll keep our own base of belts to not iterate trough all belts everytime
local combinatorsToUI = {}
local update_interval = 30 --That's a lot I think.


--Helper method for my debugging while coding
local function out(txt)
  debug = false
  if debug then
    game.print(txt)
  end
end

local function txtpos(pos)
  return "{" .. pos["x"] .. ", " .. pos["y"] .."}"
end

--Creates a new GUI and returns it's var
local function createGUI(entity)
  local id = #combinatorsToUI
  local centerpane = game.players[1].gui.left
  if centerpane["fum_frame"] == nil then
    centerpane.add({type = "frame", name = "fum_frame"})
    centerpane["fum_frame"].add({type = "flow", name = "fum_panel", direction = "vertical"})
  end

  while centerpane["fum_frame"]["fum_panel"]["gauge" .. id] do
    id = id + 1
  end
  
  local newGui = centerpane["fum_frame"]["fum_panel"].add({
    type = "scroll-pane", name = "gauge" .. id, vertical_scroll_policy = "never", horizontal_scroll_policy = "auto",
    style = "circuits_ui_scroll"
  })
  newGui.add({type = "label", name = "gauge_label"})
  newGui["gauge_label"].caption = "ID : " .. id
  CreateSignalGuiPanel(newGui, nil)
  return newGui
end

--We add all the belts in the game to our data
local function onInit()
  if not global.fum_uic then
    global.fum_uic = {}
  end
  combinatorsToUI = global.fum_uic

  local toRemove = {}
  for k, v in pairs(combinatorsToUI) do
    if v[1] then
      v.entity = v[1]
    end
    if v[2] then
      v.ui = v[2]
    end
    if not v.entity or not v.entity.valid then
        table.insert(toRemove, key)
    end
  end
  for k, v in pairs(toRemove) do
    destroyCombinator(k)
  end
  
end

--We store which belts are in the world for next time
local function onLoad()
  combinatorsToUI = global.fum_uic
end 

--Destroys a gui and removes from table
local function destroyGui(entity)
  --out("Tries to remove : " .. tostring(entity) .. "at : " .. txtpos(entity.position))
  out(#combinatorsToUI)
  for k, v in pairs(combinatorsToUI) do
    --out(tostring(v.entity) .. ", " .. tostring(v[2]))
    local ent = v.entity
    if ent and ent.valid then
        out(txtpos(ent.position))
    end
    if not ent or not ent.valid then
      destroyCombinator(k)
      return
    end
    if entity.valid and txtpos(ent.position) == txtpos(entity.position) then
      destroyCombinator(k)
    end
  end
end

function destroyCombinator(key)
    local v = combinatorsToUI[key]
    if v then
      v.ui.destroy()
    end
    out("destroy")
    table.remove(combinatorsToUI, key)
    local centerpane = game.players[1].gui.left
    if #centerpane["fum_frame"]["fum_panel"].children == 0 then
        centerpane["fum_frame"].destroy()
    end
end

--When we place a new ui combinator, it's stored. Value is {entity, ui}
local function onPlaceEntity(event)
  if event.created_entity.name == "ui-combinator" then
    local newUI = createGUI(event.created_entity)
    local temp = {entity = event.created_entity, ui = newUI}
    table.insert(combinatorsToUI, temp)
    --out("Added : ".. tostring(event.created_entity) .. " at : " .. txtpos(event.created_entity.position) )
    out("Size : " .. #combinatorsToUI)
  end
end

--Entity removed from table when removed from world
local function onRemoveEntity(event)
  if event.entity.name == "ui-combinator" then
    destroyGui(event.entity)
    out("Size : " .. #combinatorsToUI)
  end
end


--Updates UI based on blocks signals
local function updateUICombinator(uicomb)
  local entity = uicomb.entity
  if not entity then
    return
  end
  if not entity.valid then
    destroyGui(entity)
    return
  end
  local circuit = entity.get_circuit_network(defines.wire_type.red)
  if not circuit then
    circuit = entity.get_circuit_network(defines.wire_type.green)
  end
  UpdateSignalGuiPanel(uicomb.ui.signals, circuit)
end


local function onTick()
  if 0 == game.tick % update_interval then
    for k, v in pairs(combinatorsToUI) do
      updateUICombinator(combinatorsToUI[k])
    end
  end
end


script.on_init(onInit)
script.on_configuration_changed(onInit)
script.on_load(onLoad)

script.on_event(defines.events.on_built_entity, onPlaceEntity)
script.on_event(defines.events.on_robot_built_entity, onPlaceEntity)

script.on_event(defines.events.on_preplayer_mined_item, onRemoveEntity)
script.on_event(defines.events.on_robot_pre_mined, onRemoveEntity)
script.on_event(defines.events.on_entity_died, onRemoveEntity)

script.on_event(defines.events.on_tick, onTick)
