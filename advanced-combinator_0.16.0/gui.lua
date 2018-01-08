local current = { gui = nil, combinator = nil }

local function openGUI(player, advanced_combinator)
  if player.gui.center["advancedCombinatorUI"] then
    player.gui.center["advancedCombinatorUI"].destroy()
  end

  local frameRoot = player.gui.center.add({ type = "frame", name = "advancedCombinatorUI", direction = "vertical" })
  current = { gui = frameRoot, combinator = advanced_combinator }

  local header = frameRoot.add({ type = "flow", name = "header", direction = "horizontal" })
  header.add({ type = "label", name = "label_update_frequency", caption = "Update interval:" })
  local update_frequency = header.add({ type = "textfield", name = "update_frequency", text = advanced_combinator.updatePeriod })
  update_frequency.style.width = 100
  local frame = frameRoot.add({type = "scroll-pane", name = "advancedCombinator_scroll", style = "advanced_combinator_list2"})

  local editor = frame.add({ type = "text-box", name = "commands", text = advanced_combinator.config })
  editor.word_wrap = false
  editor.style.width = 400
  editor.style.height = 400

  -- add(add(green(this,item/iron-plate),red(this,item/copper-plate)),current(1))
  -- { func = "add", params = { { func = "add", params = { {}, {} } }, { func = "current", params = { 1 } } } }


  -- types: wire-color (green / red), number(+const?), entity (top/this/left/right/bottom), array...

  -- Header: Title(?), update frequency, close GUI button
  -- Undo, Redo
  -- Apply/Re-parse

  -- List:
  -- - index
  -- - signal-type (may be functions...)
  -- - value (functions...)
  -- Calculate button to calculate current value, show all calculated steps (for debugging)


end

return { openGUI = openGUI }
