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
  for k,v in pairs(data) do
    if type(v) == "table" then
      print_recursive_table(v, indentation .. "." .. k)
    elseif type(v) ~= "function" then
      game.print(indentation .. "[" .. k .. "]" .. " = " .. tostring(v))
    end
  end
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
