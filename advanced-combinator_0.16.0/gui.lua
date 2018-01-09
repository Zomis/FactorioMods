local logic = require "logic"
local common = require "common"
local current = {} -- Key: player index, Value: { gui = frameRoot, combinator = advanced_combinator }

local function click(player, element, update_callback)
  local player_current = current[player.index]
  if not player_current then
    return
  end
  if element == player_current.gui.header.apply_button then
    player_current.combinator.updatePeriod = tonumber(player_current.gui.header.update_frequency.text)
    player_current.combinator.config = player_current.gui.commands.text
    update_callback(player_current.combinator.entity)
    return
  end
  if element == player_current.gui.header.close_button then
    player_current.gui.destroy()
    current[player.index] = nil
  end
end

local function find_functions_for_type(type)
  local result = {}
  for name, data in pairs(logic.logic) do
    if data.result == type then
      table.insert(result, name)
    end
  end
  return result
end

local enum_types = {
  ["game-data"] = {
    "tick", "speed"
    --, "players"--, active_mods?, connected_players, #item_prototypes?
  },
  ["surface-data"] = {
    "daytime", "darkness", "wind_speed", "wind_orientation", "wind_orientation_change", "ticks_per_day", "dusk", "dawn", "evening", "morning"
    -- "peaceful_mode", "freeze_daytime",
  },
  ["entity"] = { "this", "top", "left", "right", "bottom" },
  ["wire-color"] = { "green", "red" }
}

local function add_parameters_gui(parameters_gui, logic_data, model, add_calculation_gui)
  common.print_recursive_table(logic_data, "logic for " .. model.name)
  local params_count = #logic_data.parameters
  for i=1,params_count do
    local param_flow = parameters_gui.add({ type = "flow", name = "param" .. i, direction = "horizontal" })
    local type = logic_data.parameters[i]
    add_calculation_gui(param_flow, model.params[i], type)
    if i < params_count then
      parameters_gui.add({ type = "label", name = "comma" .. i, caption = ", " })
    end
  end
end

local function add_calculation_gui(gui, model, expected_result)
  if expected_result == "string" then
    local textfield = gui.add({ type = "textfield", name = "textfield", text = model })
    textfield.style.width = 50
    return
  end
  if expected_result == "signal-id" then
    local textfield = gui.add({ type = "textfield", name = "textfield", text = model })
    textfield.style.width = 50
    return
  end
  if enum_types[expected_result] then
    local items = enum_types[expected_result]
    local selected_index = common.table_indexof(items, model)
    gui.add({ type = "drop-down", name = "enum_value", items = items, selected_index = selected_index })
    return
  end
  game.print("add_calculation_gui for " .. expected_result .. " model:")
  common.print_recursive_table(model, "")

  -- model.name, model.params[1], model.params[2]
  local data = logic.logic[model.name]

  local flow = gui.add({ type = "flow", name = "flow", direction = "horizontal" })
  local function_options = find_functions_for_type(expected_result)
  local selected_index = common.table_indexof(function_options, model.name)
  local function_name = flow.add({ type = "drop-down", name = "function_name", items = function_options, selected_index = selected_index })
  function_name.tooltip = data.description
  flow.add({ type = "label", name = "start_parenthesis", caption = "(" })

  local parameters_flow = flow.add({ type = "flow", name = "parameters", direction = "horizontal" })
  add_parameters_gui(parameters_flow, data, model, add_calculation_gui)

  flow.add({ type = "label", name = "end_parenthesis", caption = ")" })
end

local function openGUI(player, advanced_combinator, runtime)
  if player.gui.center["advancedCombinatorUI"] then
    player.gui.center["advancedCombinatorUI"].destroy()
  end

  local frameRoot = player.gui.center.add({ type = "frame", name = "advancedCombinatorUI", direction = "vertical" })
  current[player.index] = { gui = frameRoot, combinator = advanced_combinator }

  -- Header: Title(?), update frequency, close GUI button
  local header = frameRoot.add({ type = "flow", name = "header", direction = "horizontal" })
  header.add({ type = "label", name = "label_update_frequency", caption = "Update interval:" })
  local update_frequency = header.add({ type = "textfield", name = "update_frequency", text = advanced_combinator.updatePeriod })
  update_frequency.style.width = 100

  -- Undo, Redo
  -- Apply/Re-parse
  header.add({ type = "button", name = "apply_button", caption = "Apply" })
  header.add({ type = "button", name = "close_button", caption = "Close" })

  local frame = frameRoot.add({type = "scroll-pane", name = "advancedCombinator_scroll", style = "advanced_combinator_list2"})

  local editor = frameRoot.add({ type = "text-box", name = "commands", text = advanced_combinator.config })
  editor.word_wrap = false
  editor.style.width = 400
  editor.style.height = 400

  common.print_recursive_table(runtime, "data")

  local list = frame
  for k, command in ipairs(runtime.commands) do
    -- Move Up, Move Down, Delete
    local flow = list.add({ type = "flow", name = "index" .. k, direction = "horizontal" })
    flow = flow.add({ type = "flow", name = "command", direction = "horizontal" })
    local index_box = flow.add({ type = "textfield", name = "index_box", text = command.index })
    index_box.tooltip = { "", "The index to use on the constant combinator" }
    index_box.style.width = 30

    local signal_result = flow.add({ type = "choose-elem-button", name = "signal_result", elem_type = "signal", signal = command.signal_result })
    signal_result.tooltip = { "", "The signal to use as result for this calculation" }

    local calculation = flow.add({ type = "flow", name = "calculation", direction = "horizontal" })
    add_calculation_gui(calculation, command.calculation, "number")

  end

  -- add(add(green(this,item/iron-plate),red(this,item/copper-plate)),current(1))
-- COMBO_BOX '(' COMBO_BOX '(' COMBO_BOX '(' ENUM_DROP_DOWN ', ' SIGNAL_SELECT ')' ')'  ')'
-- Use http://lua-api.factorio.com/latest/LuaGuiElement.html#LuaGuiElement.tooltip on all COMBO_BOX

  -- POTENTIAL OUTPUT for easier debugging
  -- green(this,item/iron-plate) gives 42
  -- add(add(42,red(this,item/copper-plate)),current(1))
  -- red(this,item/copper-plate) gives 21
  -- add(add(42,21),current(1))
  -- add(42,21) gives 63
  -- current(1) gives 2
  -- add(63,2) gives 65

  -- { func = "add", params = { { func = "add", params = { {}, {} } }, { func = "current", params = { 1 } } } }


  -- types: wire-color (green / red), number(+const?), entity (top/this/left/right/bottom), array...


  -- List:
  -- - index
  -- - signal-type (may be functions...)
  -- - value (functions...)
  -- Calculate button to calculate current value, show all calculated steps (for debugging)


end

local function get_default_model(function_name, advanced_combinator)
  local data = logic.logic[function_name]
  local params = {}

  for _, param_type in ipairs(data.parameters) do
    if param_type == "string" then
      table.insert(params, "1")
    elseif param_type == "string-signal" then
      table.insert(params, "virtual/signal-0")
    elseif enum_types[param_type] then
      table.insert(params, enum_types[param_type][1])
    elseif param_type == "number" then
      table.insert(params, { name = "const", params = { "1" } })
    elseif param_type == "signal-id" then
      table.insert(params, "virtual/signal-0")
--      table.insert(params, { name = "signal_type", params = { "virtual/signal-0" } })
    end
  end


  local entity = advanced_combinator.entity
  return { name = function_name, params = params, func = data.parse(params, entity) }
end

local function change_verified(player, player_current, element)
  -- We have verified that the element clicked is in the heirarchy

  -- DROPDOWN: Wipe children and rebuild
  -- TEXT: Change parameter
  -- ELEMENT: Change parameter

  -- Parse GUI to create multi-line string
  -- if DROPDOWN: Parse multi-line string to re-create GUI?
  if element.type == "drop-down" and element.name == "function_name" then
    local new_function_name = element.get_item(element.selected_index)
    local logic_data = logic.logic[new_function_name]
    local model = get_default_model(new_function_name, player_current.combinator)
    local parameters_sibling = element.parent["parameters"]
    -- Destroy children of the parameters element
    local children = {}
    for k, v in pairs(parameters_sibling.children) do
      table.insert(children, v)
    end
    for _, v in ipairs(children) do
      v.destroy()
    end
    -- Recreate new parameters GUI
    add_parameters_gui(parameters_sibling, logic_data, model, add_calculation_gui)
  elseif element.type == "choose-elem-button" then
  elseif element.type == "textfield" then

  end

  -- Update multiline string

end

local function change(player, element)
  local player_current = current[player.index]
  if not player_current then
    return
  end
  local expected_gui = player_current.gui
  local el = element
  while el.parent do
    if el.parent == expected_gui then
      change_verified(player, player_current, element)
    end
    el = el.parent
  end
end

return { openGUI = openGUI, click = click, change = change }
