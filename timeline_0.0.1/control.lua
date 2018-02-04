require "interface"
require "htmlsave"

local force_data
local player_data

script.on_init(function()
	global.forces = global.forces or {}
	global.players = global.players or {}
	force_data = global.forces
	player_data = global.players
end)

script.on_load(function()
	force_data = global.forces
	player_data = global.players
end)

script.on_event(defines.events.on_rocket_launched, function(event)
    local forceData = global.forces[event.rocket.force.name]
	forceData.rockets_launched = forceData.rockets_launched or 0
	forceData.rockets_launched = forceData.rockets_launched + 1
	markTimeline(event.rocket.force, "rocket-launched", forceData.rockets_launched, forceData.rockets_launched)
end)

function markTimeline(force, name, params, value)
	for _, player in ipairs(force.players) do
		initPlayer(player)
	end
	local mark = { name = name, param = params, tick = game.tick }
	if value then
		mark.value = value
	end
	local forceData = global.forces[force.name]
	if not forceData then
		forceData = {}
		global.forces[force.name] = forceData
	end
	forceData.allMarks = forceData.allMarks or {}

	-- mark timeline
	table.insert(forceData.allMarks, mark)
	force.print("Timeline: " .. mark.name .. " - " .. mark.param .. " with value " .. tostring(value) .. " at " .. mark.tick)
end

function initPlayer(player)
	if not player.gui.top.timeline then
  	player.gui.top.add { type = "button", name = "timeline", caption = "Timeline" }
	end
end

script.on_event(defines.events.on_research_finished, function(event)
	local name = event.research.name
	local force = event.research.force
	local forceData = global.forces[force.name]
	forceData.research = forceData.research or {}
	local level = forceData.research[name] or 0
	forceData.research[name] = level + 1
	markTimeline(force, "research-finished", name, level + 1)
end)

script.on_event(defines.events.on_gui_click, function(event)
	local element = event.element
	local playerIndex = event.player_index
	local player = game.players[playerIndex]
	local force = player.force
	if element.name == "timeline" then
		setTimelineMark(player, 0)
		showTimeline(player)
    end
	if element.name == "hideTimeline" then
		hideTimeline(player)
		return
	end
	if element.name == "nextMark" then
		nextMark(player)
	end
	if element.name == "saveTimeline" then
		saveTimeline(player, "timeline-" .. event.tick .. ".html")
	end
end)

function setTimelineMark(player, index)
	
end

function getTimelineMark(player)
	
end

function nextMark(player)
	if not global.players[player.index] then
		global.players[player.index] = { markIndex = 0 }
	end
	local marks = global.forces[player.force.name].allMarks
	local playerData = global.players[player.index]
	if playerData.markIndex <= 1 then
		playerData.markIndex = #marks
	else
		playerData.markIndex = playerData.markIndex - 1
	end

	local showMark = marks[playerData.markIndex]
	player.gui.center.timelineFrame.currentMark.caption = showMark.name .. " - " .. showMark.param .. " - " .. showMark.tick
end

function hideTimeline(player)
	local frame = player.gui.center.timelineFrame
	if frame then
		frame.destroy()
	end
end

function saveTimeline(player, filename)
	game.write_file(filename, htmlString(player))
end

function showTimeline(player)
	if player.gui.center.timelineFrame then
		hideTimeline(player)
		return
	end
	local frame = player.gui.center.add { type = "frame", name = "timelineFrame", direction = "vertical" }
	frame.add { type = "label", name = "currentMark", caption = "current" }
	frame.add { type = "button", name = "nextMark", caption = "Next" }
	frame.add { type = "button", name = "hideTimeline", caption = "Hide" }
	frame.add { type = "button", name = "saveTimeline", caption = "Save" }
	nextMark(player)
end

function on_tick()
	-- /c for k, v in pairs(game.player.force.item_production_statistics.input_counts) do game.print(k .. " = " .. v) end
	for _, force in pairs(game.forces) do
		if not force_data[force.name] then
			force_data[force.name] = {}
		end
		if not force_data[force.name].next_stats then
			force_data[force.name].next_stats = {}
		end

		local next_stats = force_data[force.name].next_stats
		-- force.item_production_statistics.get_input_count("stone-brick")
		for key, count in pairs(force.item_production_statistics.input_counts) do
			if not next_stats[key] then
				markTimeline(force, "produced", key, 1)
				next_stats[key] = 10
			elseif count >= next_stats[key] then
				markTimeline(force, "produced", key, next_stats[key])
				next_stats[key] = next_stats[key] * 10
			end
		end
	end
end

script.on_event(defines.events.on_tick, on_tick)
