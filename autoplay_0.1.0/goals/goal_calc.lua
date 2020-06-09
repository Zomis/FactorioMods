function calc_research_times()
    -- Calculates the average/median research times for all techs
    -- TODO: Consider amount (100 / 200 / 500 / 1000 / etc) also and do weighted calculation?

    local research_times = mapToArray(map(function (tech) return tech.research_unit_energy end, player.force.technologies))
    table.sort(research_times)
    local count = table_size(research_times)
    game.print(serpent.line(research_times))
    local sum = reduce(operator.add, research_times)
    local avg = sum / count
    
    game.print("Avg " .. avg)
    local middle = math.floor(count / 2)
    game.print("middle " .. middle)
    game.print("Median " .. research_times[middle])
end

function calculate_max_machines()
    -- Find belt speeds
    local belt_speeds = filter(function (proto) return proto.belt_speed ~= nil end, game.entity_prototypes)
    
    game.print("Belt speeds " .. serpent.line(pairsMap(belt_speeds, function(proto) return proto.name end, function(proto)
        -- Why 480? Good question. Who knows? It's what seemed to fit.
        return 480 * proto.belt_speed
    end)))

    -- Calculate labs/machines needed

    -- recipe: Iron Gear, 0.5 seconds, 1 input. Machine speed 0.5 makes recipe take 1 second.
    -- consume_per_second = 1 --> 15 machines.
    
    -- 30 second recipe (research). 1 ingredient per recipe. Speed 1. Belt speed = 15/s. Half a belt = 7.5/s
    -- consume_per_second = 1/30
    -- In 30 seconds we spit out 7.5*30 = 225 resources. To consume all of them we would need 225 machines.
    
    -- belt_speed / consume_per_second ?
end

-- /c for k, v in pairs(game.player.force.technologies) do game.print(k) end
-- /c for k, v in pairs(game.player.force.technologies["railway"].prerequisites) do game.print(k) end

-- Calculate median research speed, to figure out how many labs we should have

-- Recipe tree consider all steps to figure out normal/side-products/farming and so on.
