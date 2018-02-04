local player_guis = {}

local function create_menu_gui_for(player)
	if not player.gui.top.timeline then
  	player.gui.top.add { type = "button", name = "timeline", caption = "Timeline" }
	end
end

local function next_mark(player)
	if not player_guis[player.index] then
		player_guis[player.index] = { mark_index = 0 }
	end

	local marks = global.forces[player.force.name].allMarks
	local player_data = player_guis[player.index]
	if player_data.mark_index <= 1 then
		player_data.mark_index = #marks
	else
		player_data.mark_index = player_data.mark_index - 1
	end

	local showMark = marks[player_data.mark_index]
	player.gui.center.timelineFrame.currentMark.caption = showMark.name .. " - " .. showMark.param .. " - " .. showMark.tick
end

function hide_timeline(player)
	local frame = player.gui.center.timelineFrame
	if frame then
		frame.destroy()
	end
end

function saveTimeline(player, filename)
	game.write_file(filename, htmlString(player))
end

function showTimeline(player)
	-- custom marks
	if player.gui.center.timelineFrame then
		hide_timeline(player)
		return
	end
	local frame = player.gui.center.add { type = "frame", name = "timelineFrame", direction = "vertical" }
	frame.add { type = "label", name = "currentMark", caption = "current" }
	frame.add { type = "button", name = "nextMark", caption = "Next" }
	frame.add { type = "button", name = "hideTimeline", caption = "Hide" }
	frame.add { type = "button", name = "saveTimeline", caption = "Save" }
	next_mark(player)
end

script.on_event(defines.events.on_gui_click, function(event)
	local element = event.element
	local playerIndex = event.player_index
	local player = game.players[playerIndex]
	local force = player.force
	if element == player.gui.top.timeline then
		-- player_guis[player.index].mark_index = 0
		showTimeline(player)
    end
	if element.name == "hideTimeline" then
		hide_timeline(player)
		return
	end
	if element.name == "nextMark" then
		next_mark(player)
	end
	if element.name == "saveTimeline" then
		saveTimeline(player, "timeline-" .. event.tick .. ".html")
	end
end)

return { create_menu_gui_for = create_menu_gui_for }
