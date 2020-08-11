local forces_bounds = nil

local function is_player_force(force)
    return force.name ~= "enemy" and force.name ~= "neutral" and force.name ~= "player"
end

local function refresh_bounds()
    local force_count = 0
    local forces = {}
    for _, force in pairs(game.forces) do
        if is_player_force(force) then
            forces[force.name] = { index = force_count }
            force_count = force_count + 1
        end
    end
    local radians_per_force = math.pi * 2.0 / force_count
    for _, force_data in pairs(forces) do
        force_data.angle_start = radians_per_force * force_data.index - math.pi
        force_data.angle_end = radians_per_force * force_data.index - math.pi + radians_per_force
    end
    forces_bounds = forces
    global.forces_bounds = forces_bounds
    game.print("Forces: " .. serpent.block(forces))
end

local function on_tick(event)
    if not forces_bounds then return end
    for _, player in pairs(game.players) do
        -- Loop through all players and check if they are within their designated area.
        if forces_bounds[player.force.name] then
            local angle = math.atan(player.position.x, player.position.y)
            local force_data = forces_bounds[player.force.name]
    --        player.print("Your angle is " .. angle)
            if angle < force_data.angle_start or angle >= force_data.angle_end then
                player.print("You are outside your area: " .. force_data.angle_start .. ".." .. force_data.angle_end)
                if player.character then
                    player.character.damage(1, "neutral")
                end
            end
        end
    end
end

local function on_force_created(event)
--    event.force.print("Hello new force!")
    refresh_bounds()
--    if true then return end

    local new_force = event.force
    for _, tech in pairs(new_force.technologies) do
        tech.visible_when_disabled = true
    end

    -- Redistribute technologies and recipes

    -- Recipes: Only the ones that have been unlocked.
    -- Technologies: Only the ones that have not been researched.

    local all_recipes = {}
    local all_technologies = {}
    local old_force_count = 0
    for _, f in pairs(game.forces) do
        if is_player_force(f) and f ~= new_force then
            old_force_count = old_force_count + 1

            f.set_friend(new_force, true)
            new_force.set_friend(f, true)
            
            for _, recipe in pairs(f.recipes) do
                if recipe.enabled then
                    table.insert(all_recipes, recipe)
                end
            end
            for _, tech in pairs(f.technologies) do
                if tech.enabled then
                    table.insert(all_technologies, tech)
                end
            end
        end
    end
    if old_force_count == 0 then
        return
    end
--    if true then return end

    local new_force_count = old_force_count + 1
    local rng = game.create_random_generator()

    -- Redistribution: 1 --> 2, 2 --> 3.
    -- For each thing, randomise a number from 1 to X (inclusive). If number == X, then give it to new force.

    for _, recipe in pairs(all_recipes) do
        if rng(1, new_force_count) == new_force_count then
            recipe.enabled = false
        else
            new_force.recipes[recipe.name].enabled = false
        end
    end

    for _, tech in pairs(all_technologies) do
        if rng(1, new_force_count) == new_force_count then
            tech.enabled = false
        else
            new_force.technologies[tech.name].enabled = false
        end
    end
end

local function on_player_created(event)
    local player = game.players[event.player_index]
    
    -- Create new force with player
    local new_force = game.create_force("player-" .. player.name)
    player.force = new_force
end

local function on_research_finished(event)
    refresh_bounds()
    local researched_tech = event.research
    local researched_force = researched_tech.force

    for _, effect in pairs(researched_tech.effects) do
        if effect.type == "unlock-recipe" then
            local recipe_name = effect.recipe
            for _, force in pairs(game.forces) do
                if force ~= researched_force then
                    local other_recipe = force.recipes[recipe_name]
                    if other_recipe and other_recipe.enabled then
                        researched_force.recipes[recipe_name].enabled = false
                        researched_force.print("Recipe " .. recipe_name .. " is already enabled for " .. force.name)
                    end
                end
            end
        end
    end

    for _, force in pairs(game.forces) do
        local force_tech = force.technologies[researched_tech.name]
        if force_tech and not force_tech.enabled then
            -- force.print(force_tech.localised_name)
            -- "Player __1__ researched __2__ which gives them access to __3__"
            force_tech.enabled = true
            force_tech.researched = true
        end
    end
end

local function on_init()
    global.forces_bounds = {}
    forces_bounds = global.forces_bounds
end

local function on_load()
    forces_bounds = global.forces_bounds
end

script.on_init(on_init)
script.on_load(on_load)
script.on_event(defines.events.on_tick, on_tick)
script.on_event(defines.events.on_player_created, on_player_created)
script.on_event(defines.events.on_force_created, on_force_created)
script.on_event(defines.events.on_research_finished, on_research_finished)

-- TODO: on_player_removed (How to trigger this? Script?)
-- TODO: Only restrict moving on nauvis surface?
-- TODO: Potential performance increase? on_player_changed_position to check out of bounds, then just read that.
-- TODO: Mark player's allowed zone on map? Show alert when in wrong zone? https://lua-api.factorio.com/latest/LuaPlayer.html#LuaPlayer.create_local_flying_text ?
-- TODO: Set spawn position to be safe. https://lua-api.factorio.com/latest/LuaForce.html#LuaForce.set_spawn_position

-- Competition mode when first to research something gets it? (but then one player could do everything, which would be boring)

-- on_forces_merged -- event.source_name, event.source_index , event.destination (force)
