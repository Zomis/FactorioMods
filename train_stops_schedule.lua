/c
function shuffle(list)
	for i = #list, 2, -1 do
		local j = math.random(i);
		list[i], list[j] = list[j], list[i];
	end
end

local train = game.player.vehicle.train;
local schedule = { current = 1, records = {} };
function addstop(name)
    table.insert(schedule.records, { station = name, wait_conditions = { { type = "time", ticks = 0, compare_type = "and" } } });
    game.print("Added stop " .. name);
end
local directions = { "West", "East", "North", "South" };
local extra = { "Inner", "Outer" };

local combinations = {};
for _, start_dir in pairs(directions) do
    for _, start_ext in pairs(extra) do
        for _, stop_dir in pairs(directions) do
            if start_dir ~= stop_dir then
                for _, stop_ext in pairs(extra) do
                    table.insert(combinations, { entrance = start_dir .. " Entrance " .. start_ext, exit = stop_dir .. " Exit " .. stop_ext });
                end
            end
        end
    end
end
game.print("combinations: " .. tostring(#combinations))

shuffle(combinations);
for _, path in pairs(combinations) do
    addstop(path.entrance);
    addstop(path.exit);
end

train.schedule = schedule;






local i = 0;
for _, start_dir in pairs(directions) do
    for _, start_ext in pairs(extra) do
        local start = start_dir .. " Entrance " .. start_ext;
        for _, stop_dir in pairs(directions) do
            for _, stop_ext in pairs(extra) do
                local stop = stop_dir .. " Exit " .. stop_ext;
                addstop(start);
                addstop(stop);
            end
        end
    end
end
