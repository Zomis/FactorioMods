function CreateSignalGuiPanel(parent, signals, name)
  local gui = parent.add({type = "flow", direction = "horizontal", name = name})

  if signals ~= nil then
    UpdateSignalGuiPanel(gui, signals)
  end
  return gui
end

local suffixChars = { "", "k", "M", "G", "T", "P", "E" }

local function CountString(count)
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
  local prototype
  if typename == "item" then
    prototype = game.item_prototypes[signal.signal.name]
  elseif typename == "fluid" then
    prototype = game.fluid_prototypes[signal.signal.name]
  elseif typename == "virtual-signal" then
    prototype = game.virtual_signal_prototypes[signal.signal.name]
  end
  local spriteName = typename .. "/" .. signal.signal.name
  if gui.icon.sprite ~= spriteName then
    gui.icon.tooltip = prototype.localised_name
    gui.icon.sprite = typename .. "/" .. signal.signal.name
  end
  gui.valueLabel.caption = CountString(signal.count)
end

local function DestroyExcessGui(gui, count)
  while gui["signal" .. count] do
    gui["signal" .. count].destroy()
    count = count + 1
  end
end

function UpdateSignalGuiPanel(gui, circuit_network)
  if not gui then
    return
  end
  local count = 1
  if not circuit_network or not circuit_network.signals then
    DestroyExcessGui(gui, count)
    return
  end
  for _, v in ipairs(circuit_network.signals) do
    if not gui["signal" .. count] then
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
