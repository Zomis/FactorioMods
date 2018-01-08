local function openGUI(player, entity)
  if player.gui.center["advancedCombinatorUI"] then
    player.gui.center["advancedCombinatorUI"].destroy()
  end

  local frameRoot = player.gui.center.add({type = "frame", name = "advancedCombinatorUI"})
  local frame = frameRoot.add({type = "scroll-pane", name = "advancedCombinator_scroll", style = "advanced_combinator_list2"})

  -- types: wire-color (green / red), number(+const?), entity (top/this/left/right/bottom), array...

  -- Header: Title(?), update frequency, re-parse button, close GUI button
  -- List:
  -- - index
  -- - signal-type (may be functions...)
  -- - value (functions...)
  -- Calculate button to calculate current value, show all calculated steps (for debugging)


end

return { openGUI = openGUI }
