require "util"

script.on_event(
  defines.events.on_tick,
  function(event)
    OnTick(event)
  end
)

script.on_event({
    defines.events.on_built_entity, 
    defines.events.on_robot_built_entity
  },
  function(event)
    OnPlaced(event)
  end
)

script.on_event({
    defines.events.on_preplayer_mined_item, 
    defines.events.on_robot_pre_mined, 
    defines.events.on_entity_died
  }, 
  function(event)
    OnRemoved(event)
  end
)

function OnPlaced(event)
  if event.created_entity.name == "cheat-chest" then
    AddEntityToGlobalList(event.created_entity)
  end
end

function OnRemoved(event)
end

function AddEntityToGlobalList(entity)
    if global.cheat_chests == nil then
        global.cheat_chests = {}
    end
    table.insert(global.cheat_chests, entity)
end

function fixChest(entity)
    local cheat_chest = entity
    local network = cheat_chest.get_circuit_network(defines.wire_type.green)
    local inventory = cheat_chest.get_inventory(defines.inventory.chest)
    if network == nil then
        return
    end
    if network.signals == nil then
        return
    end
    -- Red = Also remove. Green = Add only.
    for j, signal in ipairs(network.signals) do
        if signal.signal.type == "item" then
            local itemName = signal.signal.name
            local existing = inventory.get_item_count(itemName)
            local wanted = signal.count - existing -- exclude contents of chest
            if existing < wanted then
                local item_stack_to_insert = {name = itemName, count = wanted - existing}
                inventory.insert(item_stack_to_insert)
            end
            if existing > wanted then
                local item_stack_to_remove = {name = itemName, count = existing - wanted}
                inventory.remove(item_stack_to_remove)
            end
        end
    end
end

function OnTick(event)
    if global.cheat_chests == nil then
        return
    end
    for i = #global.cheat_chests,1,-1 do
        local cheat_chest = global.cheat_chests[i]
        if not cheat_chest.valid then
            table.remove(global.cheat_chests, i)
        else
            fixChest(cheat_chest)
        end
    end
end
