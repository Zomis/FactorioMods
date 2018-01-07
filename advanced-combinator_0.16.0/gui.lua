local function openGUI(player, entity)
  if player.gui.center["advancedCombinatorUI"] then
    player.gui.center["advancedCombinatorUI"].destroy()
  end

  local frameRoot = player.gui.center.add({type = "frame", name = "advancedCombinatorUI"})
  local frame = frameRoot.add({type = "scroll-pane", name = "advancedCombinator_scroll", style = "advanced_combinator_list2"})
end

return { openGUI = openGUI }
