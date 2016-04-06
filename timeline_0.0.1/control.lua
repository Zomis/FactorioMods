require "defines"
require "interface"

script.on_init(function()
	global.forces = global.forces or {}
	global.players = global.players or {}
    initPlayers()
end)

script.on_event(defines.events.on_player_created, function(event)
    playerCreated(event)
end)

script.on_event(defines.events.on_built_entity, function(event)
	local player = game.players[event.player_index]
	local force = player.force
    markTimeline(force, "built-entity", event.created_entity.name)
end)

function markTimeline(force, name, params)
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

script.on_event(defines.events.on_gui_click, function(event)
	local element = event.element
	local playerIndex = event.player_index
	local player = game.players[playerIndex]
	local force = player.force
	if element.name == "timeline" then
		showTimeline(player)
    end
	if element.name == "hideTimeline" then
		local frame = player.gui.center.timelineFrame
		if frame then
			frame.destroy()
			return
		end
	end
	if element.name == "nextMark" then
		nextMark(player)
	end
end)

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

function showTimeline(player)
	local frame = player.gui.center.add { type = "frame", name = "timelineFrame", direction = "vertical" }
	frame.add { type = "label", name = "currentMark", caption = "current" }
	frame.add { type = "button", name = "nextMark", caption = "Next" }
	frame.add { type = "button", name = "hideTimeline", caption = "Hide" }
	nextMark(player)
end
