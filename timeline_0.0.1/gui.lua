local tick_to_timestring = require "tick_to_timestring"
local htmlString = require "htmlsave"
local player_guis = {}

local function create_menu_gui_for(player)
	if not player.gui.top.timeline then
  	player.gui.top.add { type = "button", name = "timeline", caption = "Timeline" }
	end
end

local function show_marks(player)
	if not player_guis[player.index] then
		player_guis[player.index] = { mark_index = 0 }
	end
	local marks = global.forces[player.force.name].allMarks
	local mark_count = #marks

	local player_data = player_guis[player.index]
	local frame = player.gui.center.timelineFrame
	frame.table_container.table.destroy()
	local table = frame.table_container.add({type = "table", name = "table", column_count = 5})

	local delta = -1
	local start_mark = mark_count - player_data.mark_index
	player.print("start_mark is " .. start_mark .. " mark_count: " .. mark_count .. " mark_index: " .. player_data.mark_index)

	table.add({ type = "label", name = "header_tick", caption = "Tick" })
	table.add({ type = "label", name = "header_time", caption = "Time" })
	table.add({ type = "label", name = "header_name", caption = "Type" })
	table.add({ type = "label", name = "header_param", caption = "Name" })
	table.add({ type = "label", name = "header_value", caption = "Value" })
	for i = 0,9 do
		local index = start_mark + delta * i
		local mark = marks[index]
		player.print("mark at " .. index .. " = " .. tostring(mark))
		if mark then
			local append = "row" .. i .. "_"
			local timestring = tick_to_timestring(mark.tick)
			table.add({ type = "label", name = append .. "tick", caption = mark.tick })
			table.add({ type = "label", name = append .. "time", caption = timestring })
			table.add({ type = "label", name = append .. "name", caption = mark.name })
			table.add({ type = "label", name = append .. "param", caption = mark.param })
			table.add({ type = "label", name = append .. "value", caption = mark.value })
		end
	end
end


local function next_mark(player)
	local marks = global.forces[player.force.name].allMarks
	local mark_count = #marks

	if not player_guis[player.index] then
		player_guis[player.index] = { mark_index = 0 }
	else
		local player_data = player_guis[player.index]
		player_data.mark_index = player_data.mark_index - 1
		if player_data.mark_index < 0 then
			player_data.mark_index = mark_count
		end
	end
	show_marks(player)
end

function hide_timeline(player)
	local frame = player.gui.center.timelineFrame
	if frame then
		frame.destroy()
	end
end

function saveTimeline(player, filename)
  local force = player.force
  local forceData = global.forces[force.name]
  local marks = forceData.allMarks
	game.write_file(filename, htmlString(marks))
end

function showTimeline(player)
	-- custom marks
	if player.gui.center.timelineFrame then
		hide_timeline(player)
		return
	end
	local frame = player.gui.center.add { type = "frame", name = "timelineFrame", direction = "vertical" }
	local header = frame.add({ type = "flow", name = "header", direction = "horizontal" })
	header.add { type = "button", name = "nextMark", caption = "Next" }
	header.add { type = "button", name = "hideTimeline", caption = "Hide" }
	header.add { type = "button", name = "saveTimeline", caption = "Save" }

	local table_container = frame.add({ type = "flow", name = "table_container", direction = "horizontal" })
	local tableui = table_container.add({type = "table", name = "table", column_count = 3})
	show_marks(player)
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
	if not player.gui.center.timelineFrame then
		return
	end
	local frame = player.gui.center.timelineFrame
	if element == frame.header.hideTimeline then
		hide_timeline(player)
		return
	end
	if element == frame.header.nextMark then
		next_mark(player)
	end
	if element == frame.header.saveTimeline then
		saveTimeline(player, "timeline-" .. event.tick .. ".html")
	end
end)

return { create_menu_gui_for = create_menu_gui_for }
