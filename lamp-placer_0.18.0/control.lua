local Async = require "async"

local function droppedItem(event)
    if not event.entity or not event.entity.stack then
        return
    end
    if event.entity.stack.name == "lamp-placer" then
        event.entity.stack.clear()
    end
end

local function isInRange(position, x, y, range)
    local diffX = math.abs(position.x - x)
    local diffY = math.abs(position.y - y)
    local diff = math.max(diffX, diffY)
    return diff <= range
end

local function findElectricity(poles, x, y)
    for _, entity in ipairs(poles) do
        if entity.valid and isInRange(entity.position, x, y, entity.prototype.supply_area_distance) then
            return true
        end
    end
    return false
end

local function findLamp(lamp_positions, x, y, lamp_distance)
    for _, position in ipairs(lamp_positions) do
        -- Do not perform valid check because ghosts that get placed are no longer valid. All we are interested in is the positions
        if isInRange(position, x, y, lamp_distance) then
            return true
        end
    end
end

local function round(value)
    return math.floor(value + 0.5)
end

local function on_player_selected_area(event)
    if event.item ~= "lamp-placer" then
        return
    end
    local player = game.players[event.player_index]
    local surface = player.surface
    local player_settings = settings.get_player_settings(player)
    local lamp_distance = player_settings["lamp-placer-lamp-distance"].value

    -- local searchEntities = event.entities
    local extra = lamp_distance + 10
    local searchEntities = surface.find_entities({ { event.area.left_top.x - extra, event.area.left_top.y - extra },
      { event.area.right_bottom.x + extra, event.area.right_bottom.y + extra } })

    local electricity = {}
    local lamp_positions = {}
    for _, entity in ipairs(searchEntities) do
        if entity.type == "electric-pole" then
            table.insert(electricity, entity)
        end
        if entity.type == "lamp" then
            table.insert(lamp_positions, entity.position)
        end
    end

    local width = round(event.area.right_bottom.x) - round(event.area.left_top.x)
    local height = round(event.area.right_bottom.y) - round(event.area.left_top.y)
    local xloop = Async:loop("x", round(event.area.left_top.x) + 0.5, round(event.area.right_bottom.x) - 0.5)
    local yloop = Async:loop("y", round(event.area.left_top.y) + 0.5, round(event.area.right_bottom.y) - 0.5)
    local task_data = {
        lamp_positions = lamp_positions, electricity = electricity,
        placables = 0, electricities = 0, lamps_placed = 0,
        lamp_distance = lamp_distance,
        player = player, force = player.force, surface = player.surface
    }
    local place = Async:perform_once(task_data, { xloop, yloop })
    player.print("[Lamp Placer] Starting placing lamps in an area of " .. width .. " x " .. height .. " using distance of " .. lamp_distance)
end

local function async_place_lamp(values, task_data)
    local x = values.x
    local y = values.y
    local position = { x = x, y = y }
    local placable = task_data.surface.can_place_entity({ name = "small-lamp", position = position, force = task_data.force })
    if not placable then
        return
    end
    task_data.placables = task_data.placables + 1
    -- Check if there is electricity in area
    local electricityFound = findElectricity(task_data.electricity, x, y)
    if not electricityFound then
        return
    end
    task_data.electricities = task_data.electricities + 1
    -- Check if there is an existing lamp in area
    local lampFound = findLamp(task_data.lamp_positions, x, y, task_data.lamp_distance)
    if not lampFound then
        task_data.lamps_placed = task_data.lamps_placed + 1
        local newLamp = task_data.surface.create_entity({ name = "entity-ghost",
            inner_name = "small-lamp", expires = false, position = position, force = task_data.force })
        table.insert(task_data.lamp_positions, newLamp.position)
    end
end

local function async_place_lamp_finished(task_data)
    task_data.player.print("[Lamp Placer] Placed " .. task_data.lamps_placed .. " lamps on " .. task_data.placables .. " placable positions. " .. task_data.electricities .. " of which had electricity.")
end

Async:configure(function(task)
    return { perform_function = async_place_lamp, on_finished = async_place_lamp_finished }
end)

local function on_tick(event)
    Async:on_tick()
end

script.on_event(defines.events.on_tick, on_tick)
script.on_event(defines.events.on_player_selected_area, on_player_selected_area)
script.on_event(defines.events.on_player_alt_selected_area, on_player_selected_area)
script.on_event(defines.events.on_player_dropped_item, droppedItem)
