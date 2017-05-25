--control.lua
-- Show ALL signals connected to network, and the value of them
-- Button in top left to open up list of all UI Combinators
-- Condition on UI combinator for when to auto-show the data
-- Work in multiplayer
-- Configure update interval

require "libs.itemselection"

--We'll keep our own base of belts to not iterate trough all belts everytime
local combinatorsToUI = {}
local update_interval = 30 --That's a lot I think.


local color_table = {
  ["signal-red"] = {r=1},
  ["signal-green"] = {g=1},
  ["signal-blue"] = {b=1},
  ["signal-yellow"] = {r=1, g=1},
  ["signal-pink"] = {r=1, b=1},
  ["signal-cyan"] = {b=1, g=1},
  ["signal-white"] = {r = 1, g = 1, b = 1},
  ["signal-grey"] = {r=0.5, g=0.5, b=0.5},
  ["signal-black"] ={}
}


--Helper method for my debugging while coding
local function out( txt)
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
    centerpane["fum_frame"].add({type = "scroll-pane", name = "fum_panel"})
  end

  while centerpane["fum_frame"]["fum_panel"]["gauge" .. id] do
    id = id + 1
  end
  
  local newGui = centerpane["fum_frame"]["fum_panel"].add({type = "scroll-pane", name = "gauge" .. id, direction="horizontal"})
  newGui.add({type = "textfield", name = "gauge_label"})
  newGui["gauge_label"].text = "ID : " .. id
  newGui.add({type = "progressbar", name = "gauge_bar", size=5, value = 0.0, style = "custom_bar_style"})
  newGui.add({type = "sprite-button", name = "zomissignal", style = "slot_button_style", sprite=""})
  
  
  return newGui
end

--Destroys a gui and removes from table
local function destroyGui(entity)
  local centerpane = game.players[1].gui.left
  --out("Tries to remove : " .. tostring(entity) .. "at : " .. txtpos(entity.position))
  out(#combinatorsToUI)
  for k, v in pairs(combinatorsToUI) do
    --out(tostring(v[1]) .. ", " .. tostring(v[2]))
    local ent = v[1]
    out(txtpos(ent.position))
    if txtpos(ent.position) == txtpos(entity.position) then
      v[2].destroy()
      out("destroy")
      table.remove(combinatorsToUI, k)
      if #centerpane["fum_frame"]["fum_panel"].children == 0 then
        centerpane["fum_frame"].destroy()
      end
    end
  end
end


local function valorForCircuit(circuit)
  if circuit then
    if circuit.signals then
      for k, signal in pairs(circuit.signals) do
        if signal then
          return signal
        end
      end
    end
  end
  return nil
end

-- Tells signal of the gauge based on entity (and signals associed)
local function combinatorSignal(entity)
  local circuit = entity.get_circuit_network(defines.wire_type.red)
  local signal = valorForCircuit(circuit)
  if signal == nil then
    circuit = entity.get_circuit_network(defines.wire_type.green)
    signal = valorForCircuit(circuit)
  end
  return signal
end

--When we place a new ui combinator, it's stored. Value is {entity, ui}
local function onPlaceEntity(event)
  if event.created_entity.name == "ui-combinator" then
    newUI = createGUI(event.created_entity)
    local temp = {event.created_entity, newUI}
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
local function onTick()
  if 0 == game.tick % update_interval then

    for k, v in pairs(combinatorsToUI) do
      signal = combinatorSignal(combinatorsToUI[k][1])
      if signal then
        out(signal.signal.name)
        
		local signal2 = combinatorsToUI[k][2]["zomissignal"]
        local typename = signal.signal.type
        if typename == "virtual" then
            typename = "virtual-signal"
        end
        signal2.sprite = typename .. "/" .. signal.signal.name
        local prototypes = itemSelection_prototypesForGroup(typename)
        signal2.tooltip = prototypes[signal.signal.name].localised_name

        combinatorsToUI[k][2]["gauge_bar"].value = signal.count / 100.0
        combinatorsToUI[k][2]["gauge_bar"].style.smooth_color = color_table[signal.signal.name]
      else
        combinatorsToUI[k][2]["gauge_bar"].value = 0
        signal2.sprite = ""
        signal2.tooltip = ""
      end
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
