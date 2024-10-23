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
  local typename = signal.signal.type or "item"
  if typename == "virtual" then
    typename = "virtual-signal"
  end
  local prototype
  if typename == "item" then
    prototype = prototypes.item[signal.signal.name]
  elseif typename == "fluid" then
    prototype = prototypes.fluid[signal.signal.name]
  elseif typename == "virtual-signal" then
    prototype = prototypes.virtual_signal[signal.signal.name]
  end
  local spriteName = typename .. "/" .. signal.signal.name
  if gui.icon.sprite ~= spriteName then
    gui.icon.tooltip = prototype.localised_name
    gui.icon.sprite = spriteName
  end
  gui.valueLabel.caption = CountString(signal.count)
end

local function DestroyExcessGui(gui, count)
  while gui["signal" .. count] do
    gui["signal" .. count].destroy()
    count = count + 1
  end
end

local function addSignalsToGui(signals, gui, count)
  for _, v in ipairs(signals) do
    if not gui["signal" .. count] then
      local signalGUI = gui.add({type = "flow", direction = "vertical", name = "signal" .. count})
      signalGUI.add({type = "sprite-button", name = "icon", style = "slot_button", sprite=""})
      signalGUI.add({type = "label", name = "valueLabel"})
    end
    local signalUI = gui["signal" .. count]
    UpdateSingleSignal(signalUI, v)
    count = count + 1
  end
  return count
end

local function UpdateSignalGuiPanel(gui, circuit_network_1, circuit_network_2)
  if not gui then
    return
  end
  local count = 1
  if circuit_network_1 and circuit_network_1.signals then
    count = addSignalsToGui(circuit_network_1.signals, gui, count)
  end
  if circuit_network_2 and circuit_network_2.signals then
    count = addSignalsToGui(circuit_network_2.signals, gui, count)
  end
  DestroyExcessGui(gui, count)
end

local function CreateSignalGuiPanel(parent, circuit_red, circuit_green, name)
  local gui = parent.add({type = "flow", direction = "horizontal", name = name})
  if circuit_red or circuit_green then
    UpdateSignalGuiPanel(gui, circuit_red, circuit_green)
  end
  return gui
end

return { UpdateSignalGuiPanel = UpdateSignalGuiPanel, CreateSignalGuiPanel = CreateSignalGuiPanel }
