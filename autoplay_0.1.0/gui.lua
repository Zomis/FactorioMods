local GUI = {}
GUI.__index = GUI

require "functional_library"

local autoplay = require "autoplay/main"

function GUI:on_click(event)
    if event.element.name ~= "autoplay" then
      return
    end
    autoplay:tick()
end

function GUI:create_gui(player)
    local top = player.gui.top
    if top["autoplay"] == nil then
      top.add({type = "sprite-button", name = "autoplay",
        style = "slot_button", sprite = "item/wood"})
    end
end
  
function GUI:autoplay_command(event)
    local player = game.players[event.player_index]
    if event.command == "autoplay_calc" then
        
    end
    if event.command == "autoplay_start" then

        -- FIXER: Detect enemies consuming pollution. Don't build anything 1-2 chunks away from enemies. Use turret defenses.

        -- GOAL: Find out how much has been researched, find target research/thing
        -- FIXER: Find out how many machines we have and what the status of them is. https://lua-api.factorio.com/latest/defines.html#defines.entity_status
        -- xxx for what purpose? : Find how much have been produced/used: game.print(serpent.block(game.player.force.item_production_statistics.output_counts))

        -- Check what chunks have been marked and start marking chunks
    end
end


  
return GUI
