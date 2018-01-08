local logic = require "logic"
local common = require "common"
local current = {}

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

local function print_recursive_table(data, indentation)
  if type(data) ~= "table" then
    game.print(indentation .. tostring(data))
    return
  end
  for k,v in pairs(data) do
    if type(v) == "table" then
      print_recursive_table(v, indentation .. "." .. k)
    elseif type(v) ~= "function" then
      game.print(indentation .. "[" .. k .. "]" .. " = " .. tostring(v))
    end
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

local function add_calculation_gui(gui, model, expected_result)
  if expected_result == "string" then
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
  print_recursive_table(model, "")

  -- model.name, model.params[1], model.params[2]
  local data = logic.logic[model.name]

  local flow = gui.add({ type = "flow", name = "flow", direction = "horizontal" })
  local function_options = find_functions_for_type(expected_result)
  local selected_index = common.table_indexof(function_options, model.name)
  local function_name = flow.add({ type = "drop-down", name = "function_name", items = function_options, selected_index = selected_index })
  function_name.tooltip = data.description
  flow.add({ type = "label", name = "start_parenthesis", caption = "(" })

  print_recursive_table(data, "logic for " .. model.name)
  local params_count = #data.parameters
  for i=1,params_count do
    local param_flow = flow.add({ type = "flow", name = "param" .. i, direction = "horizontal" })
    local type = data.parameters[i]
    add_calculation_gui(param_flow, model.params[i], type)
    if i < params_count then
      flow.add({ type = "label", name = "comma" .. i, caption = ", " })
    end
  end
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

  print_recursive_table(runtime, "data")

  local list = frame
  for k, command in ipairs(runtime.commands) do
    local flow = list.add({ type = "flow", name = "command" .. k, direction = "horizontal" })
    local index_box = flow.add({ type = "textfield", name = "index_box", text = command.index })
    index_box.tooltip = { "", "The index to use on the constant combinator" }
    index_box.style.width = 30

    local signal_result = flow.add({ type = "choose-elem-button", name = "signal_result", elem_type = "signal", signal = command.signal_result })

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

return { openGUI = openGUI, click = click }
