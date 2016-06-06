require "defines"

script.on_init(function()
    initPlayers()
end)

script.on_event(defines.events.on_player_created, function(event)
    playerCreated(event)
end)

script.on_event(defines.events.on_tick, function(event)
    if event.tick % 10 ~= 0 then
        return
    end
    for index, player in ipairs(game.players) do
        showResourceCount(player)
    end
end)

function showResourceCount(player)
    if (not player.valid) or (not player.connected) then
        return
    end
    if (player.selected == nil) or (player.selected.prototype.type ~= "resource") then
        player.gui.top.resource_total.caption = ""
        return
    end
    global.selects = global.selects or {}
    global.selects[player.index] = global.selects[player.index] or {}
    local previousSelected = global.selects[player.index]
    local key = keyFor(player.selected)
    
    if previousSelected[key] then
        showForResources(player, previousSelected)
    else
        local resources = floodFindResources(player.selected)
        global.selects[player.index] = resources
        showForResources(player, resources)
    end
end

function showForResources(player, resources)
    local count = sumResources(resources)
    player.gui.top.resource_total.caption = player.selected.name .. ": " .. count.total .. " in " .. count.count .. " tiles"
end

function keyFor(entity)
    return entity.position.x .. "," .. entity.position.y
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
    player.gui.top.add{type="label", name="resource_total", caption=""}
end

function sumResources(resources)
    local total = 0
    local count = 0
    for key, resource in pairs(resources) do
        total = total + resource.amount
        count = count + 1
    end
    return {total = total, count = count}
end

function floodFindResources(entity)
    local found = {}
    floodCount(found, entity)
    return found
end

function floodCount(found, entity)
    local name = entity.name
    local key = keyFor(entity)
    if found[key] then
        return
    end
    found[key] = entity
    
    local RANGE = 2.2
    local surface = entity.surface
    local pos = entity.position
    local area = {{pos.x - RANGE, pos.y - RANGE}, {pos.x + RANGE, pos.y + RANGE}}
    for _, res in pairs(surface.find_entities_filtered { area = area, name = entity.name}) do
        local key2 = keyFor(res)
        if not found[key2] then
            floodCount(found, res)
        end
    end
end
