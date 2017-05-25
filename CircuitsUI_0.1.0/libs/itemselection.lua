local mainMaxRows = 5
local mainMaxEntries = 30
local maxRecentEntries = 20

--------------------------------------------------
-- API
--------------------------------------------------

-- call this to open the item selection gui
-- @param player: Object of the player opening the gui
-- @param types: array of things to show {TYPE_ITEM, TYPE_FLUID, TYPE_SIGNAL, TYPE_HIDE_ALL_EACH_ANY}
-- @param callback: Passed function used as callback when action is taken
--		accept a table with: {type=$,name=$,prototype=$}
-- itemSelection_open(player, types, callback)

-- Call this to migrate when updating the library to 2.9
-- itemSelection_migration_2_9()

-- Resolve a type name into the factorio prototypes array
-- itemSelection_prototypesForGroup(type)

--------------------------------------------------
-- Global data
--------------------------------------------------

-- This helper file uses the following global data variables:
-- global.itemSelection[$playerName]
--				.recent= { {$type, $name}, {"item", "iron-plate"}, {"fluid", "water"}, ... }
--        .callback = function({type=$,name=$,prototype=$})
--				.showGroups = set of type values. e.g: { "item"=true, "fluid"=true, "signal"=true }

--------------------------------------------------
-- Constants
--------------------------------------------------
TYPE_ITEM = "item"
TYPE_FLUID = "fluid"
TYPE_SIGNAL = "virtual-signal"
TYPE_SPECIAL1 = "special1"
TYPE_HIDE_ALL_EACH_ANY = "hide_all_each_any"
TYPE_ALL = {TYPE_ITEM, TYPE_FLUID, TYPE_SIGNAL}

------------------------------------
-- Helper methods
------------------------------------

local function initGuiForPlayerName(playerName)
	if global.itemSelection == nil then global.itemSelection = {} end
	local is = global.itemSelection
	if is[playerName] == nil then is[playerName] = {} end
	if is[playerName].recent == nil then is[playerName].recent = {} end
end

local function checkBoxForItem(type,name)
	local prototype = itemSelection_prototypesForGroup(type)[name]
	if prototype == nil then return nil end
	local tip = prototype.localised_name
	--local tip = type.."/"..name
	return {
		type = "sprite-button",
		name = "itemSelection."..type.."."..name,
		style = "slot_button_style",
		tooltip = tip,
		sprite = type.."/"..name
	}
end

local function addCheckboxToTable(itemType,itemName,itemsTable)
	local checkbox = checkBoxForItem(itemType,itemName)
	if checkbox ~= nil then
		local status, err = pcall(function() itemsTable.add(checkbox) end)
		if not status then
			warn("Error occured with item: "..itemType.."/"..itemName)
			warn(err)
		end
	end
end

local function selectItem(playerData,player,type,itemName)
	-- add to recent items
	table.insert(playerData.recent,1,{type,itemName})
	-- prevent duplicates
	for i=#playerData.recent,2,-1 do
		if playerData.recent[i][2] == itemName then table.remove(playerData.recent,i) end
	end
	-- remove oldest items from history
	if #playerData.recent > maxRecentEntries then
		table.remove(playerData.recent,maxRecentEntries)
	end

	if global.itemSelection[player.name].callback then
		global.itemSelection[player.name].callback({
			name=itemName,
			type=type,
			prototype=itemSelection_prototypesForGroup(type)[itemName]
		})
		global.itemSelection[player.name].callback = nil
	end
	itemSelection_close(player)
end


local function rebuildItemList(player)
	local frame = player.gui.left.itemSelection.main
	if frame.itemsScrollPane then
		frame.itemsScrollPane.destroy()
	end

	local scroll = frame.add{type="scroll-pane", name="itemsScrollPane"}
	--scroll.style.maximal_width=450  --Needed to produce horizontal scroll bars
	scroll.style.maximal_height=180 --Needed to produce vertical scroll bars
	scroll.horizontal_scroll_policy = "never"
	scroll.vertical_scroll_policy = "auto"
	local items = scroll.add{type="table",name="itemsX",colspan=mainMaxEntries}
	
	local filter = frame.search["itemSelection.field"].text
	local playerData = global.itemSelection[player.name]
	local showGroups = playerData.showGroups
	
	for _,type in pairs(TYPE_ALL) do
		if showGroups[type] then
			for name,prototype in pairs(itemSelection_prototypesForGroup(type)) do
				local specialCondition = true
				if type == TYPE_ITEM then
					specialCondition = not prototype.has_flag("hidden")
				end
				if type == TYPE_SIGNAL and showGroups[TYPE_HIDE_ALL_EACH_ANY] then
					if name == "signal-everything" or name == "signal-anything" or name == "signal-each" then
						specialCondition = false
					end
				end
				if specialCondition and (filter == "" or string.find(name,filter)) then
					addCheckboxToTable(type,name,items)
				end
			end
		end
	end
end

------------------------------------
-- Events
------------------------------------

itemSelection_close = function(player)
	if player.gui.left.itemSelection ~= nil then
		player.gui.left.itemSelection.destroy()
	end
	initGuiForPlayerName(player.name)
	local playerData = global.itemSelection[player.name]
	playerData.callback = nil
end


itemSelection_open = function(player,types,callback)
	initGuiForPlayerName(player.name)
	local playerData = global.itemSelection[player.name]
	playerData.showGroups = table.set(types)

	if player.gui.left.itemSelection ~= nil then
		itemSelection_close(player)
	end

	local frame = player.gui.left.add{type="frame",name="itemSelection",direction="vertical",caption={"item-selection"}}
	frame.add{type="table",name="main",colspan=1}
	frame = frame.main

	if #playerData.recent > 0 then
		frame.add{type="table",name="recent",colspan=2}
		frame.recent.add{type="label",name="title",caption={"",{"recent"},":"}}
		local items = frame.recent.add{type="table",name="itemsX",colspan=#playerData.recent}
		for _,recentTable in pairs(playerData.recent) do
			if type(recentTable) == "string" then
				playerData.recent = {}
				break
			end
			addCheckboxToTable(recentTable[1],recentTable[2],items)
		end
	end

	if playerData.showGroups[TYPE_SPECIAL1] then
		frame.add{type="table",name="special",colspan=2}
		frame.special.add{type="label",name="title",caption={"",{"special"},":"}}
		frame.special.add{type="table",name="itemsX",colspan=1}
		addCheckboxToTable("item","belt-sorter-everythingelse",frame.special.itemsX)
	end
	
	frame.add{type="table",name="search",colspan=2}
	frame.search.add{type="label",name="title",caption={"",{"search"},":"}}
	frame.search.add{type="textfield",name="itemSelection.field"}
	
	rebuildItemList(player)
	-- Store reference for callback

	global.itemSelection[player.name].callback = callback
	global.itemSelection[player.name].filter = ""
	gui_scheduleEvent("itemSelection.updateFilter",player)
end

itemSelection_gui_event = function(guiEvent,player)
	initGuiForPlayerName(player.name)
	local fieldName = guiEvent[1]
	local playerData = global.itemSelection[player.name]
	if playerData == nil then return end
	if playerData.callback == nil then return end
	if fieldName == "field" then
		rebuildItemList(player)
	elseif fieldName == "updateFilter" then
		local frame = player.gui.left.itemSelection.main
		local filter = frame.search["itemSelection.field"].text
		if filter ~= playerData.filter then
			playerData.filter = filter
			rebuildItemList(player)
		end
		if player.gui.left.itemSelection.valid then
			gui_scheduleEvent("itemSelection.updateFilter",player)
		end
	elseif table.set(TYPE_ALL)[fieldName] then -- if any slot was clicked of any type
		local itemName = guiEvent[2]
		selectItem(playerData,player,fieldName,itemName)
	else
		warn("Unknown fieldName for itemSelection_gui_event: "..tostring(fieldName))
	end
end

itemSelection_prototypesForGroup = function(type)
	if type == TYPE_ITEM then
		return game.item_prototypes
	elseif type == TYPE_FLUID then
		return game.fluid_prototypes
	elseif type == TYPE_SIGNAL then
		return game.virtual_signal_prototypes
	end
end


-- The format how recent objects were stored has changed, therefore this table needs to be cleared
itemSelection_migration_2_9 = function()
	for playerName, arr in pairs(global.itemSelection) do
		arr.recent = {}
	end
end



