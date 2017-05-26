local function out(txt)
  debug = false
  if debug then
    game.print(txt)
  end
end

function CreateSignalGuiPanel(parent, signals)
  local gui = parent.add({type = "flow", direction = "horizontal", name = "signals"})
  out("Create gui")
  
  if signals ~= nil then
    UpdateSignalGuiPanel(gui, signals)
  end
  return gui
end

local suffixChars = { "", "k", "M", "G", "T", "P", "E" }

function CountString(count)
  local absValue = math.abs(count)
  local prefix = ""
  if count < 0 then
    prefix = "-"
  end
  local suffix = 1
  while absValue >= 1000 do
    absValue = absValue / 1000
    suffix = suffix + 1
  end
  
  local str = tostring(absValue)
  if absValue < 10 then
    return prefix .. string.sub(str, 1, 3) .. suffixChars[suffix]
  end
  if absValue < 100 then
    return prefix .. string.sub(str, 1, 2) .. suffixChars[suffix]
  end
  return prefix .. string.sub(str, 1, 3) .. suffixChars[suffix]
end

local function UpdateSingleSignal(gui, signal)
  local typename = signal.signal.type
  if typename == "virtual" then
    typename = "virtual-signal"
  end
  out("Updating: " .. typename .. "/" .. signal.signal.name .. " value " .. signal.count)
  gui.icon.sprite = typename .. "/" .. signal.signal.name
  gui.valueLabel.caption = CountString(signal.count)
--        local prototypes = itemSelection_prototypesForGroup(typename)
--        gui.icon.tooltip = prototypes[signal.signal.name].localised_name -- signal.count
end

function DestroyExcessGui(gui, count)
  while gui["signal" .. count] do
    out("Destroying " .. count)
    gui["signal" .. count].destroy()
    count = count + 1
  end
end

function UpdateSignalGuiPanel(gui, circuit_network)
  if not gui then
    out("No gui")
    return
  end
  local count = 1
  if not circuit_network or not circuit_network.signals then
    out("No signals")
    DestroyExcessGui(gui, count)
    return
  end
  for k, v in pairs(circuit_network.signals) do
    out("Signal " .. v.signal.name .. " has " .. v.count)
    if not gui["signal" .. count] then
      out("Creating " .. count)
      local signalGUI = gui.add({type = "flow", direction = "vertical", name = "signal" .. count})
      signalGUI.add({type = "sprite-button", name = "icon", style = "slot_button_style", sprite=""})
      signalGUI.add({type = "label", name = "valueLabel"})
    end
    local signalUI = gui["signal" .. count]
    UpdateSingleSignal(signalUI, v)
    count = count + 1
  end
  DestroyExcessGui(gui, count)
end

