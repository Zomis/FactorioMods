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
    if (player.selected == nil) or (player.selected.prototype.type ~= "resource") then
        player.gui.top.resource_total.caption = ""
        return
    end
    local count = floodCount({}, player.selected)
    player.gui.top.resource_total.caption = player.selected.name .. ": " .. count
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
    player.gui.top.add{type="label", name="resource_total", caption="0"}
end

function floodCount(checked, entity)
    local name = entity.name
    local pos = entity.position
    local key = pos.x .. "," .. pos.y
    if checked[key] then
        return 0
    end
    checked[key] = true
    local total = entity.amount
    for y = -1, 1 do
        for x = -1, 1 do
            if (x ~= 0 or y ~= 0) then
                local xx = pos.x + x
                local yy = pos.y + y
                local neighbor = entity.surface.find_entity(name, { xx, yy })
                if neighbor ~= nil then
                    total = total + floodCount(checked, neighbor)
                end
            end
        end
    end
    return total
end
