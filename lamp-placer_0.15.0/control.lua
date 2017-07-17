local LAMP_DISTANCE = 8
local EXTRA = 10

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
        if isInRange(entity.position, x, y, entity.prototype.supply_area_distance) then
            return true
        end
    end
    return false
end

local function findLamp(lamps, x, y)
    for _, entity in ipairs(lamps) do
        if isInRange(entity.position, x, y, LAMP_DISTANCE) then
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
    local destroyed_info = {}
    local area = event.area
    
    -- local searchEntities = event.entities
    local searchEntities = surface.find_entities({ { event.area.left_top.x - EXTRA, event.area.left_top.y - EXTRA },
      { event.area.right_bottom.x + EXTRA, event.area.right_bottom.y + EXTRA } })
    
    local lamps = {}
    
    local electricity = {}
    for _, entity in ipairs(searchEntities) do
        if entity.type == "electric-pole" then
            table.insert(electricity, entity)
        end
        if entity.type == "lamp" then
            table.insert(lamps, entity)
        end
    end
    
    local placables = 0
    local electricities = 0
    local noLamps = 0
    local force = player.force
    for x = round(event.area.left_top.x) + 0.5, round(event.area.right_bottom.x) - 0.5 do
        for y = round(event.area.left_top.y) + 0.5, round(event.area.right_bottom.y) - 0.5 do
            local position = { x = x, y = y }
            local placable = surface.can_place_entity({ name = "small-lamp", position = position, force = force })
            if placable then
                placables = placables + 1
                -- Check if there is electricity in area
                local electricityFound = findElectricity(electricity, x, y)
                if electricityFound then
                    electricities = electricities + 1
                    -- Check if there is an existing lamp in area
                    local lampFound = findLamp(lamps, x, y)
                    if not lampFound then
                        noLamps = noLamps + 1
                        local newLamp = surface.create_entity({ name = "entity-ghost", inner_name = "small-lamp", expires = false, position = { x, y }, force = force })
                        table.insert(lamps, newLamp)
                    end
                end
            end
        end
    end
    player.print("Placed " .. noLamps .. " lamps on " .. placables .. " placable positions. " .. electricities .. " of which had electricity.")
end

script.on_event(defines.events.on_player_selected_area, on_player_selected_area)
script.on_event(defines.events.on_player_alt_selected_area, on_player_selected_area)
script.on_event(defines.events.on_player_dropped_item, droppedItem)
