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

-- x MASSIVE PROBLEM: No event when Factories change recipe. See https://forums.factorio.com/viewtopic.php?f=6&t=50485
-- x Need to re-scan Factories for recipe changes. Technically only those that have been selected need a check.
-- x keep a LOCAL table of KEY: position -- VALUE: entity + recipe. Check one machine per tick.


-- x Table with product as key and a list of machines that is producing that as value
require "entity_tick_iterate"

local STEP_BY_STEP = false
local ROCKET_PART = "rocket-part"
local RESEARCH = "RESEARCH"

local machines = {}
local machineRecipes = {} -- KEY: position, VALUE: entity + recipe. Check one machine per tick
local playerDatas = {} -- KEY: Player index, VALUE: research (bool), rocket (bool), wanted (array of string)

local update_interval = 60

local function out(txt)
  local debug = false
  if debug then
    game.print(txt)
  end
end

local function txtpos(pos)
  return "{" .. pos["x"] .. ", " .. pos["y"] .."}"
end

local function worldAndPos(entity, key)
  return entity.surface.name .. txtpos(entity.position)
end

-- player left GUI
-- Satellite
-- Low Density, Solar Panel, Accumulator, Radar, Processing Unit, Rocket Fuel
-- chains:
--   list of list of outputs that should be produced

local function createMissingFlow(parent, id)
    local name = "missing" .. id
    local flow = parent
    flow.add({type = "flow", name = name, direction = "horizontal"})
    flow[name].add({type = "button", name = "what_is_missing_delete", caption = "X"})
    flow[name].add({type = "choose-elem-button", name = "wanted", elem_type = "item"})
    local scroll = flow[name].add({type = "scroll-pane", name = "result",
       vertical_scroll_policy = "never", horizontal_scroll_policy = "auto", style = "what_is_missing_scroll"})
    scroll.add({type = "flow", name = "flow", direction = "horizontal"})
    return flow[name]
end

local function createGUI(player, fromConfig)
    local top = player.gui.top
    if top["missing_perform"] ~= nil then
      top["missing_perform"].destroy()
    end

    if top["what_is_missing"] == nil then
      top.add({
        type = "button",
        name = "what_is_missing",
        caption = "WiM",
        style = "what_is_missing_small_button"
      })
    end

    local left = player.gui.left
    if left["what_is_missing"] == nil then
        left.add({type = "frame", name = "what_is_missing"})
        left["what_is_missing"].add({type = "flow", name = "panel", direction = "vertical"})
        -- out("Left UI Created for " .. player.name)
    end

    if not left.what_is_missing.panel["research"] then
        local flow = left.what_is_missing.panel
        local scroll
        local configResearch = fromConfig and fromConfig.research
        local configRocket = fromConfig and fromConfig.rocket
        flow.add({type = "checkbox", name = "research", caption = "Current Research", state = configResearch})
        scroll = flow.add({type = "scroll-pane", name = "missing_research",
           vertical_scroll_policy = "never", horizontal_scroll_policy = "auto", style = "what_is_missing_scroll"})
        scroll.add({type = "flow", name = "flow", direction = "horizontal"})

        flow.add({type = "checkbox", name = "rocket", caption = "Rocket", state = configRocket})
        scroll = flow.add({type = "scroll-pane", name = "missing_rocket",
           vertical_scroll_policy = "never", horizontal_scroll_policy = "auto", style = "what_is_missing_scroll"})
        scroll.add({type = "flow", name = "flow", direction = "horizontal"})

        if fromConfig then
          for index, wanted in pairs(fromConfig.wanted) do
            local guiFlow = createMissingFlow(flow, index)
            guiFlow.wanted.elem_value = wanted
          end
          createMissingFlow(flow, #fromConfig.wanted + 1)
        else
          createMissingFlow(flow, 2)
        end
    end
end

local function savePlayerSettingsFromGUI()
  -- 0.16 changed style name to "slot_button"
  playerDatas = {}
  for _, player in pairs(game.players) do
    local pane = player.gui.left["what_is_missing"]
    if pane and pane.panel then
      local playerConfig = {
        research = pane.panel.research.state,
        rocket = pane.panel.rocket.state,
        wanted = {}
      }
      for _, element_name in ipairs(pane.panel.children_names) do
        if string.sub(element_name, 1, 7) == "missing" then
          local missingPanel = pane.panel[element_name]
          if missingPanel.wanted and missingPanel.wanted.elem_value ~= nil then
            out(missingPanel.wanted.elem_value)
            table.insert(playerConfig.wanted, missingPanel.wanted.elem_value)
            -- missingPanel.wanted.style = "slot_button"
          end
        end
      end
      pane.destroy()
      createGUI(player, playerConfig)
      playerDatas[player.index] = playerConfig
    end
  end
  global.playerDatas = playerDatas
end

local function getOutputsForMachine(entity)
    if entity.type == "assembling-machine" then
        local recipe = entity.get_recipe()
        if recipe then
            return recipe.products
        end
    end
    if entity.type == "furnace" then
        local recipe = entity.get_recipe()
        if recipe then
            return recipe.products
        elseif entity.previous_recipe then
            return entity.previous_recipe.products
        end
    end
    return nil
end

local function addMachine(entity)
    if entity.type == "assembling-machine" or entity.type == "furnace" then
        local pos = worldAndPos(entity)
        -- out("Add " .. pos)
        -- checkMachine(entity)
        local outputs = getOutputsForMachine(entity)
        if outputs == nil then
            return
        end
        for _, product in ipairs(outputs) do
            -- TODO: consider product.type ?
            machines[product.name] = machines[product.name] or {}
            table.insert(machines[product.name], entity)
        end

        local machineRecipe = entity.get_recipe()
        if entity.type == "furnace" and machineRecipe == nil then
            machineRecipe = entity.previous_recipe
        end
        -- out("Add machineRecipes " .. pos .. " with recipe " .. (machineRecipe and machineRecipe.name or "nil"))
        machineRecipes[pos] = { entity = entity, recipe = machineRecipe }
    end
    if entity.type == "rocket-silo" then
        machines[ROCKET_PART] = machines[ROCKET_PART] or {}
        table.insert(machines[ROCKET_PART], entity)
    end
    if entity.type == "lab" then
        machines[RESEARCH] = machines[RESEARCH] or {}
        table.insert(machines[RESEARCH], entity)
    end
end

local function removeValueFromList(list, value)
    for k, v in pairs(list) do
        if v == value then
            -- out("Remove value in list at " .. k)
            list[k] = nil
            return
        end
    end
end

local function removeMachine(entity, outputs)
    if entity.type == "rocket-silo" then
        local list = machines[ROCKET_PART] or {}
        removeValueFromList(list, entity)
        return
    end
    if entity.type == "lab" then
        local list = machines[RESEARCH] or {}
        removeValueFromList(list, entity)
        return
    end

    if outputs == nil then
        outputs = getOutputsForMachine(entity)
        if not outputs then
            -- out("[What is missing] Remove machine: Cannot fetch outputs for machine at " .. txtpos(entity.position))
            return
        end
    end
    local pos = worldAndPos(entity)
    -- out("Remove " .. pos)
    machineRecipes[pos] = nil
    for _, product in ipairs(outputs) do
        -- out("Removing from list for " .. product.name)
        local list = machines[product.name] or {}
        removeValueFromList(list, entity)
    end
end

local function checkMachine(entity, debug)
    if not entity.valid then
        return
    end
    if entity.type == "assembling-machine" or entity.type == "furnace" then
        local pos = worldAndPos(entity)
        if debug then
          out("Checking " .. entity.type .. " at " .. pos)
        end
        if not machineRecipes[pos] then
            if debug then
              out("Add machine " .. pos)
            end
            addMachine(entity)
        else
            local intable = machineRecipes[pos].recipe
            local inentity = entity.get_recipe()
            if entity.type == "furnace" and inentity == nil then
                inentity = entity.previous_recipe
            end
            if debug then
              out("Already exists, comparing " .. tostring(inentity) .. " with stored " .. tostring(intable))
            end
            if intable == inentity then -- compare names instead of tables?
                return
            end
            local previous = machineRecipes[pos].recipe
            local current = inentity
            machineRecipes[pos] = { entity = entity, recipe = inentity }
            if previous then
                if debug then
                  out("Remove machine " .. previous.name)
                end
                removeMachine(entity, previous.products)
                previous = previous.name
            end
            if current then
                if debug then
                  out("Add machine " .. current.name)
                end
                addMachine(entity)
                current = current.name
            end
            if entity.type == "assembling-machine" then
              out("[What is missing] Detected recipe change at " .. pos ..
                " from " .. tostring(previous) .. " to " .. tostring(current))
            end
        end
    end
end

-- Add all assembling machines and furnaces in the game to our machines table
local function onInit()
    for _, f in pairs(game.forces) do
        for _, surface in pairs(game.surfaces) do
            for _, ent in pairs(surface.find_entities_filtered({ force = f, type = "assembling-machine"})) do
                if ent.type == "assembling-machine" then
                    addMachine(ent)
                end
            end
            for _, ent in pairs(surface.find_entities_filtered({ force = f, type = "furnace"})) do
                if ent.type == "furnace" then
                    addMachine(ent)
                end
            end
--            for key, ent in pairs(surface.find_entities_filtered({ force = f, type = "mining-drill"})) do
                -- ent.mining_target.name
--                if ent.type == "mining-drill" then
--                  addMachine(ent)
--                end
--            end
--                ent.type
--                ent.get_inventory
--                ent.get_output_inventory
--                ent.get_fuel_inventory
--                ent.get_burnt_result_inventory()
        end
    end
    global.machines = machines
    global.machineRecipes = machineRecipes
    global.playerDatas = playerDatas
end

local function onLoad()
    machines = global.machines
    machineRecipes = global.machineRecipes
    playerDatas = global.playerDatas or {}
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

local function markMissing(data, guiResult)
    local spriteName = data.type .. "/" .. data.name
    local prototype
    if data.type == "fluid" then
        prototype = game.fluid_prototypes[data.name]
    elseif data.type == "item" then
        prototype = game.item_prototypes[data.name]
    end
    local guiElementName = "missing_" .. data.type .. "_" .. data.name
    if guiResult[guiElementName] then
        return false
    end
    guiResult.add({type = "sprite-button", name = guiElementName, style = "slot_button", sprite = spriteName, tooltip = prototype.localised_name})
    return true
end

local function scanMissing(target, player, guiResult, depth)
    if depth > 50 then
        out("[What is missing] POSSIBLE STACK OVERFLOW " .. target)
        -- This happens if there is an infinite loop, such as with bottled stuff.
        -- Empty bottle, gas bottle, empty bottle...
        return
    end
    -- out("Scan missing " .. target .. " and report to " .. player.name .. " at depth " .. depth)
    local machineList = machines[target] or {}
    local missing = {}

    for _, entity in pairs(machineList) do
        if entity.valid and entity.type == "assembling-machine" then
            local awaitingOutput = entity.get_inventory(defines.inventory.assembling_machine_output)
            local recipe = entity.get_recipe()
            local available = true
            if not awaitingOutput.is_empty() then
                -- entity not empty, probably waiting for something to be output.
                -- inserters do not insert anything if output of machine is full
                -- TODO: Check for multiple outputs. Consider oil refinery with full light oil for example. Or Uranium 238.
                available = false
            end

            local ingredients
            if recipe then
                ingredients = recipe.ingredients
                -- out("checking machine at " .. txtpos(entity.position) .. " with recipe " .. recipe.name)
            else
                ingredients = {}
            end

            local current = entity.get_inventory(defines.inventory.assembling_machine_input)
            local fluidBoxCount = 1
            for _, ingredient in ipairs(ingredients) do
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
                    -- out("found missing " .. ingredient.name .. " in machine " .. txtpos(entity.position) .. " with recipe " .. recipe.name)
                    missing[ingredient.name] = { name = ingredient.name, type = ingredient.type }
                end
            end
        end
        if entity.valid and entity.type == "furnace" then
            local awaitingOutput = entity.get_inventory(defines.inventory.furnace_result)
            local recipe = entity.get_recipe() or entity.previous_recipe
            local available = true
            if not awaitingOutput.is_empty() then
                -- entity not empty, probably waiting for something to be output.
                -- inserters do not insert anything if output of machine is full
                -- TODO: Check for multiple outputs. Consider oil refinery with full light oil for example. Or Uranium 238.
                -- Is there any FURNACE recipe that has multiple outputs?
                available = false
            end

            local fuel = entity.get_inventory(defines.inventory.fuel)
            if fuel and fuel.is_empty() then
                missing["coal"] = { name = "coal", type = "item" } -- TODO: Initialize a variable for some fuel before scanning, if coal does not exist
            end

            local ingredients
            if recipe then
                ingredients = recipe.ingredients
                -- out("checking furnace at " .. txtpos(entity.position) .. " with recipe " .. recipe.name)
            else
                ingredients = {}
            end
            local current = entity.get_inventory(defines.inventory.furnace_source)
            local fluidBoxCount = 1
            for _, ingredient in ipairs(ingredients) do
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
                    -- out("found missing " .. ingredient.name .. " in furnace " .. txtpos(entity.position) .. " with recipe " .. recipe.name)
                    missing[ingredient.name] = { name = ingredient.name, type = ingredient.type }
                end
            end
        end
    end

    for missingName, data in pairs(missing) do
        -- local pos = txtpos(entity.position)
        -- local playerPos = txtpos(player.position)
        -- local prototype = game.item_prototypes[missingName]
        -- prototype = game.fluid_prototypes[missingName]
        if markMissing(data, guiResult) then
            -- if we can't mark missing, then it has already been marked as missing and marking it again would cause Stack Overflow
            scanMissing(missingName, player, guiResult, depth + 1)
        end
    end
end

-- Perform a scan to find bottlenecks
local function perform(player)
    if STEP_BY_STEP then
        local entity = entityTickIterateNext()
        if entity then
            -- out("Found entity " .. txtpos(entity.position))
            checkMachine(entity)
        end
    end

    -- out("Perform for " .. player.name)
    local left = player.gui.left
    if not left.what_is_missing then
        return
    end
    local panel = left.what_is_missing.panel
    panel.missing_research.flow.clear()
    panel.missing_rocket.flow.clear()

    if panel.research.state and player.force.current_research then
        -- Scan research (Find labs and check current force research and required stuff)
        local ingredients = player.force.current_research.research_unit_ingredients
        local missing = {}
        if not machines[RESEARCH] then
            machines[RESEARCH] = player.surface.find_entities_filtered({ force = player.force, type = "lab"})
        end
        for _, ent in pairs(machines[RESEARCH]) do
            if ent.type == "lab" then
                local current = ent.get_inventory(defines.inventory.lab_input)

                for _, ingredient in ipairs(ingredients) do
                    local wanted = ingredient.amount
                    local have = current.get_item_count(ingredient.name)
                    -- to support Bob's Mods with Module Labs, check can_insert
                    if have < wanted and current.can_insert({ name = ingredient.name }) then
                        missing[ingredient.name] = ent
                    end
                end
            end
        end
        for missingName, entity in pairs(missing) do
          -- Possibly use 'entity' to make it possible to click and show which entity is missing something
            -- out("Missing research at " .. entity.position.x .. ", " .. entity.position.y .. " player at " .. player.position.x .. ", " .. player.position.y)
            local data = { type = "item", name = missingName }
            markMissing(data, panel.missing_research.flow)
            scanMissing(missingName, player, panel.missing_research.flow, 1)
        end
    end
    if panel.rocket.state then
        -- Scan rocket (Find rocket-silo and check inventory - and recipe?)
        local missing = {}
        if not machines[ROCKET_PART] then
            machines[ROCKET_PART] = player.surface.find_entities_filtered({ force = player.force, type = "rocket-silo" })
        end
        for _, ent in pairs(machines[ROCKET_PART]) do
            if ent.type == "rocket-silo" then
                -- local inv = game.player.selected.get_inventory(defines.inventory.rocket_silo_rocket); -- sattelite
                local ingredients = ent.recipe.ingredients
                local current = ent.get_inventory(defines.inventory.assembling_machine_input)

                for _, ingredient in ipairs(ingredients) do
                    local wanted = ingredient.amount
                    local have = current.get_item_count(ingredient.name)
                    if have < wanted then
                        missing[ingredient.name] = ent
                    end
                end
            end
        end
        for missingName, entity in pairs(missing) do
          -- Possibly use 'entity' to make it possible to click and show which entity is missing something
            local data = { type = "item", name = missingName }
            markMissing(data, panel.missing_rocket.flow)
            scanMissing(missingName, player, panel.missing_rocket.flow, 1)
        end
    end

    for _, element in ipairs(panel.children) do
        if element.wanted and element.wanted.elem_value then
            local guiResult = element.result.flow
            guiResult.clear()
            local target = element.wanted.elem_value
            scanMissing(target, player, guiResult, 1)
        end
    end
end

local function onTick()
    if not STEP_BY_STEP then -- and (0 == game.tick % update_interval) then
        local entity = entityTickIterateNext()
        if entity then
            checkMachine(entity)
        end
    end
    if 0 == game.tick % update_interval then
        for _, player in pairs(game.players) do
            perform(player)
        end
    end
end

local function addEmptyMissing(player)
    if not player.gui.left.what_is_missing then
        return
    end
    local panel = player.gui.left.what_is_missing.panel
    for _, element in ipairs(panel.children) do
        if element.wanted and not element.wanted.elem_value then
            -- There is already some row with an empty element, don't add another one.
            return
        end
    end

    local i = 0
    while panel["missing" .. i] do
        i = i + 1
    end
    createMissingFlow(player.gui.left.what_is_missing.panel, i)
end

local function removeTableValue(theTable, value)
  for index, currValue in ipairs(theTable) do
    if currValue == value then
      out("Delete " .. currValue .. " at index " .. index)
      table.remove(theTable, index)
      return
    end
  end
end

local function onClick(event)
    local player = game.players[event.player_index]
    if event.element.name == "what_is_missing" then
      if player.gui.left["what_is_missing"] then
        player.gui.left["what_is_missing"].destroy()
      else
        createGUI(player, playerDatas[event.player_index])
      end
      return
    end
    if string.find(event.element.name, "what_is_missing_delete") then
        local missingPanel = event.element.parent
        local playerConfig = playerDatas[event.player_index]
        removeTableValue(playerConfig.wanted, missingPanel.wanted.elem_value)
        missingPanel.destroy()
        addEmptyMissing(player)
        return
    end
    if event.element.name ~= "missing_perform" then
        return
    end
    perform(player)
end

local function onChosenElementChanged(event)
    local player = game.players[event.player_index]
    local parent = event.element.parent -- flow
    if not parent then
        return
    end
    if string.sub(parent.name, 1, 7) ~= "missing" then
        return
    end
    -- Find out which table index belongs to element. This would be easier if there was a `event.previous_value`
    local id = tonumber(string.sub(parent.name, string.len("missing") + 1))
    local tableIndex = 0
    local left = player.gui.left["what_is_missing"]
    for i = 1, id do
      if left.panel["missing" .. i] then
        tableIndex = tableIndex + 1
      end
    end
    local old_value = tostring(playerDatas[event.player_index].wanted[tableIndex])
    -- Update player configuration for the found tableIndex
    playerDatas[event.player_index].wanted[tableIndex] = event.element.elem_value

    addEmptyMissing(player)
end

local function onCheckboxClick(event)
  local player = game.players[event.player_index]
  local wim = player.gui.left["what_is_missing"]
  if not wim then
    return
  end
  local element = event.element
  if element == wim.panel.research then
    playerDatas[event.player_index].research = element.state
  end
  if element == wim.panel.rocket then
    playerDatas[event.player_index].rocket = element.state
  end
end

script.on_init(onInit)
script.on_configuration_changed(onInit)
script.on_load(onLoad)

script.on_event(defines.events.on_built_entity, onPlaceEntity)
script.on_event(defines.events.on_robot_built_entity, onPlaceEntity)

script.on_event(defines.events.on_pre_player_mined_item, onRemoveEntity)
script.on_event(defines.events.on_robot_pre_mined, onRemoveEntity)
script.on_event(defines.events.on_entity_died, onRemoveEntity)

script.on_event(defines.events.on_tick, onTick)
script.on_event(defines.events.on_gui_click, onClick)

script.on_event(defines.events.on_gui_elem_changed, onChosenElementChanged)
script.on_event(defines.events.on_gui_checked_state_changed, onCheckboxClick)

local function onSelectedEntityChanged(event)
  -- event.last_entity, event.player_index
  if event.last_entity then
    checkMachine(event.last_entity)
  end
end

local function onPasteSettings(event)
  checkMachine(event.destination)
  -- event.player_index, source, destination
end

local function onGuiClosed(event)
  if event.gui_type == defines.gui_type.entity then
    checkMachine(event.entity)
  end
  -- player_index, gui_type, entity, item, equipment, other_player, element
end

local function onConfigurationChanged(data)
  -- Migration code to also save world name for saved machines (fix #30) in 0.16
  local old_version = data.mod_changes["what-is-missing"].old_version
  if not old_version then
    return
  end
  if string.sub(old_version, 1, string.len("0.15")) == "0.15" then
    if not global.playerDatas then
      savePlayerSettingsFromGUI()
    end
    local newMachineRecipes = {}
    for key, savedMachine in pairs(machineRecipes) do
      local entity = savedMachine.entity
      newMachineRecipes[worldAndPos(entity, key)] = savedMachine
    end
    machineRecipes = newMachineRecipes
    global.machineRecipes = newMachineRecipes
  end
end

script.on_event(defines.events.on_selected_entity_changed, onSelectedEntityChanged)
script.on_event(defines.events.on_entity_settings_pasted, onPasteSettings)
script.on_event(defines.events.on_gui_closed, onGuiClosed)
script.on_configuration_changed(onConfigurationChanged)
