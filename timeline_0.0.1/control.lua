require "defines"
require "interface"
require "htmlsave"

script.on_init(function()
	global.forces = global.forces or {}
	global.players = global.players or {}
    initPlayers()
end)

script.on_event(defines.events.on_player_created, function(event)
    playerCreated(event)
end)

script.on_event(defines.events.on_rocket_launched, function(event)
    local forceData = global.forces[event.rocket.force.name]
	forceData.rockets_launched = forceData.rockets_launched or 0
	forceData.rockets_launched = forceData.rockets_launched + 1
	markTimeline(event.rocket.force, "rocket-launched", forceData.rockets_launched, forceData.rockets_launched)
end)

script.on_event(defines.events.on_built_entity, function(event)
	local player = game.players[event.player_index]
	local force = player.force
    markTimeline(force, "built-entity", event.created_entity.name, nil)
end)

function markTimeline(force, name, params, value)
	local mark = { name = name, param = params, tick = game.tick }
	local forceData = global.forces[force.name]
	if not forceData then
		forceData = {}
		global.forces[force.name] = forceData
	end
	if not forceData.marks then
		forceData.marks = {}
	end
	if not forceData.marks[name] then
		forceData.marks[name] = {}
	end
	forceData.allMarks = forceData.allMarks or {}
	local marks = forceData.marks[name]
	if marks[params] then
		-- timeline was already marked
		return marks[params]
	end
	
	-- mark timeline
	marks[params] = mark
	table.insert(forceData.allMarks, mark)
	
	for i, player in pairs(force.players) do
		player.print("Timeline: " .. mark.name .. " - " .. mark.param .. " at " .. mark.tick)
	end
end

function initPlayers()
    for _, player in ipairs(game.players) do
        initPlayer(player)
    end
end

function playerCreated(event)
    local player = game.players[event.player_index]
    initPlayer(player)
end

function initPlayer(player)
    player.gui.top.add { type = "button", name = "timeline", caption = "Timeline" }
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
