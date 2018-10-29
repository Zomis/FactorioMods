local usage_detector = require "usage_detector"

local function setupGui(player)
  local top = player.gui.top

  if top["usage_detector"] == nil then
    top.add({
      type = "button",
      name = "usage_detector",
      caption = "U",
      style = "usage_detector_small_button"
    })
  end
end

local started = false
local function onClick(event)
  if event.element.name == "usage_detector" then
    if not started then
      usage_detector.start({ type = "item", name = "iron-plate" })
    else
      usage_detector.stop()
    end
    started = not started
  end
end

return {
  setupGui = setupGui,
  onTick = usage_detector.onTick,
  onClick = onClick
}
