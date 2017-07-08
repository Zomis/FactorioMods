--control.lua
-- Panel to the left, visible for each player from the start
-- Possible to customize for each player
-- Use the player's force

-- When game is loaded/on startup, scan for all machines
--- mining drills
--- furnaces
--- assembling machines
--- labs
--- rocket silo

-- /c game.player.print(#game.player.force.recipes)
-- /c game.player.print(game.player.selected.recipe.category)
-- /c  local surface = game.player.surface  local count = 0  for c in surface.get_chunks() do    for key, ent in pairs(surface.find_entities_filtered({area={{c.x * 32, c.y * 32}, {c.x * 32 + 32, c.y * 32 + 32}}, force= game.player.force})) do      if ent.type == "assembling-machine" then        count = count + 1      end    end  end  game.player.print(count)
-- x MASSIVE PROBLEM: No event when Factories change recipe. See https://forums.factorio.com/viewtopic.php?f=6&t=50485
-- x Need to re-scan Factories for recipe changes. Technically only those that have been selected need a check.
-- x keep a LOCAL table of KEY: position -- VALUE: entity + recipe. Check one machine per tick.


-- x Table with product as key and a list of machines that is producing that as value
require "entity_tick_iterate"

local STEP_BY_STEP = false

local machines = {}
local machineRecipes = {} -- KEY: position, VALUE: entity + recipe. Check one machine per tick

-- Table with player index as key and a list of that player's searches as value (product name)
local searches = {}
local update_interval = 60

local function out(txt)
  debug = true
  if debug then
    game.print(txt)
  end
end

-- player left GUI
-- Satellite
-- Low Density, Solar Panel, Accumulator, Radar, Processing Unit, Rocket Fuel
-- chains:
--   list of list of outputs that should be produced


local function createGUI(player)
    local top = player.gui.top
    if top["missing_perform"] == nil then
        top.add({type = "button", name = "missing_perform", caption = "Perform"})
        -- out("Top UI Created for " .. player.name)
    end

    local left = player.gui.left
    if left["what_is_missing"] == nil then
        left.add({type = "frame", name = "what_is_missing"})
        left["what_is_missing"].add({type = "flow", name = "panel", direction = "vertical"})
        -- out("Left UI Created for " .. player.name)
    end

    if not left.what_is_missing.panel["research"] then
        local flow = left.what_is_missing.panel
        flow.add({type = "checkbox", name = "research", caption = "Current Research", state = false})
        flow.add({type = "flow", name = "missing0", direction = "horizontal"})
        flow.add({type = "checkbox", name = "rocket", caption = "Rocket", state = false})
        flow.add({type = "flow", name = "missing1", direction = "horizontal"})
        
        flow.add({type = "flow", name = "missing2", direction = "horizontal"})
        flow.missing2.add({type = "button", name = "what_is_missing_delete2", caption = "X"})
        flow.missing2.add({type = "choose-elem-button", name = "wanted", elem_type = "item"})
    end
end

function getOutputsForMachine(entity)
    if entity.type == "assembling-machine" then
        local recipe = entity.recipe
        if recipe ~= nil then
            return recipe.products
        end
    end
    return nil
end

local function txtpos(pos)
  return "{" .. pos["x"] .. ", " .. pos["y"] .."}"
end

local function addMachine(entity)
    if entity.type == "assembling-machine" then
        local pos = txtpos(entity.position)
        -- out("Add " .. pos)
        -- checkMachine(entity)
        local outputs = getOutputsForMachine(entity)
        if outputs == nil then
            return
        end
        for i, product in ipairs(outputs) do
            --product.type
            machines[product.name] = machines[product.name] or {}
            table.insert(machines[product.name], entity)
        end
        --        entity.previous_recipe
    end
--    machines
end

local function removeValueFromList(list, value)
    for k, v in pairs(list) do
        if v == value then
            list[k] = nil
            return
        end
    end
end

local function removeMachine(entity)
    local outputs = getOutputsForMachine(entity)
    if outputs == nil then
        return
    end
    local pos = txtpos(entity.position)
    -- out("Remove " .. pos)
    machineRecipes[pos] = nil
    for i, product in ipairs(outputs) do
        local list = machines[product.name] or {}
        removeValueFromList(list, entity)
    end
end

local function checkMachine(entity)
    if not entity.valid then
        return
    end
    if entity.type == "assembling-machine" then
        local pos = txtpos(entity.position)
        -- out("Checking " .. pos)
        if not machineRecipes[pos] then
            -- out("Add machineRecipes " .. pos)
            machineRecipes[pos] = { entity = entity, recipe = entity.recipe }
        else
            local intable = machineRecipes[pos].recipe
            local inentity = entity.recipe
            if intable == inentity then
                return
            end
            local previous = machineRecipes[pos].recipe
            local current = entity.recipe
            machineRecipes[pos] = { entity = entity, recipe = entity.recipe }
            if previous then
                 removeMachine(entity)
                 -- remove from machines
                 previous = previous.name
            end
            if current then
                 addMachine(entity)
                 current = current.name
            end
            out("Changed recipe at " .. pos .. " from " .. tostring(previous) .. " to " .. tostring(current))
        end
    end
end    

-- Add all machines in the game to our machines table
local function onInit()
    for forceIndex, f in pairs(game.forces) do
        for surfaceIndex, surface in pairs(game.surfaces) do
            for c in surface.get_chunks() do
                for key, ent in pairs(surface.find_entities_filtered({area={{c.x * 32, c.y * 32}, {c.x * 32 + 32, c.y * 32 + 32}}, force = f, type = "assembling-machine"})) do
                  if ent.type == "assembling-machine" then
                    addMachine(ent)
                  end
                  if ent.type == "furnace" then
                    addMachine(ent)
                  end
                  if ent.type == "mining-drill" then
                    addMachine(ent)
                  end
--                ent.type
--                ent.get_inventory
--                ent.get_output_inventory
--                ent.get_fuel_inventory
--                ent.get_burnt_result_inventory()
                end
            end
        end
    end
end

-- We store which belts are in the world for next time
local function onLoad()
    searches = global.what_is_missing_search
end 

-- When we place a new entity, we need to add it to our list of machines
local function onPlaceEntity(event)
    addMachine(event.created_entity)
    if event.player_index ~= nil then
        local player = game.players[event.player_index]
        createGUI(player)
    end
end

-- When we remove an entity, we need to remove it from our list of machines
local function onRemoveEntity(event)
    removeMachine(event.entity)
end

local function scanMissing(target, reportTo)
--    out("Scan missing " .. target .. " and report to " .. reportTo.name)
    local machineList = machines[target] or {}
    local missing = {}
    
    for j, entity in pairs(machineList) do
        if entity.valid and entity.type == "assembling-machine" then
            local awaitingOutput = entity.get_inventory(defines.inventory.assembling_machine_output)
            local recipe = entity.recipe
            local available = true
            if not awaitingOutput.is_empty() then
                -- entity not empty, probably waiting for something to be output.
                -- inserters do not insert anything if output of machine is full
                -- TODO: Check for multiple outputs. Consider oil refinery with full light oil for example. Or Uranium 238.
                available = false
            end
        
            local ingredients = recipe.ingredients
            local current = entity.get_inventory(defines.inventory.assembling_machine_input)
            local fluidBoxCount = 1
            for i, ingredient in ipairs(ingredients) do
                if not available then
                    break
                end
                local wanted = ingredient.amount
                
                local have = 0
                if ingredient.type == "fluid" then
                    local fluidBox = entity.fluidbox[fluidBoxCount]
                    if fluidBox ~= nil then -- if this is nil then the fluidBox is empty
                        have = fluidBox.amount
                    end
                    fluidBoxCount = fluidBoxCount + 1
                elseif ingredient.type == "item" then
                    have = current.get_item_count(ingredient.name)
                end
                if have < wanted then
                    missing[ingredient.name] = entity
                end
            end
        end
    end
    
    for missingName, entity in pairs(missing) do
        local pos = txtpos(entity.position)
        local playerPos = txtpos(reportTo.position)
        reportTo.print(target .. " is missing " .. missingName .. " in " .. pos .. " player is at " .. playerPos)
        scanMissing(missingName, reportTo)
    end
end

-- Perform a scan to find bottlenecks
local function perform(player)
    -- local player_search = 
--    out("Performing for " .. player.name)
    if STEP_BY_STEP then
        local entity = entityTickIterateNext()
        if entity then
            local str = txtpos(entity.position)
            -- out("Found entity " .. str)
            checkMachine(entity)
        end
    end
    
    local left = player.gui.left
    local panel = left.what_is_missing.panel
    local player_search = { }
    if panel.research.state then
        -- Scan research (Find labs and check current force research and required stuff)
    end
    if panel.rocket.state then
        -- Scan rocket (Find rocket-silo and check inventory - and recipe?)
    end
    if panel.missing2.wanted.elem_value then
        table.insert(player_search, panel.missing2.wanted.elem_value)
    end

    for k, target in pairs(player_search) do
        -- find machines and check what is missing, recursive
        scanMissing(target, player)
    end
end

local function onTick()
    if not STEP_BY_STEP then
        local entity = entityTickIterateNext()
        if entity then
            checkMachine(entity)
        end
    end
    if 0 == game.tick % update_interval then
        for k, player in pairs(game.players) do
            --perform(player)
        end
    end
end

local function onClick(event)
    local player = game.players[event.player_index]
    if event.element.name ~= "missing_perform" then
        return
    end
    perform(player)
end

script.on_init(onInit)
script.on_configuration_changed(onInit)
script.on_load(onLoad)

script.on_event(defines.events.on_built_entity, onPlaceEntity)
script.on_event(defines.events.on_robot_built_entity, onPlaceEntity)

script.on_event(defines.events.on_preplayer_mined_item, onRemoveEntity)
script.on_event(defines.events.on_robot_pre_mined, onRemoveEntity)
script.on_event(defines.events.on_entity_died, onRemoveEntity)

script.on_event(defines.events.on_tick, onTick)
script.on_event(defines.events.on_gui_click, onClick)

function onChangeSelect(event)
    local player = game.players[event.player_index]
    local previous = event.last_entity
    local str = ""
    if previous then
        str = "was " .. previous.name
    end
    if player.selected then
        str = str .. " is now " .. player.selected.name
    end
    out(str)

end
