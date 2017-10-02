local entitiesToScan = {}
local entitiesToScanIndex = nil
local surfacesToScan = {}
local surfacesToScanIndex = nil
local typeToScan = "assembling-machine"

local function out(txt)
  local debug = true
  if debug then
    game.print(txt)
  end
end

local function scan()
    local useNext = false
    for surfaceIndex, surface in pairs(game.surfaces) do
--      out(surfaceIndex .. " name " .. surface.name .. " useNext? " .. tostring(useNext))
        if surfacesToScanIndex == nil then
            return surfaceIndex
        end
        if useNext then
            return surfaceIndex
        end
        if surfaceIndex == surfacesToScanIndex then
            useNext = true
        end
    end
    return nil

--    out("Scan surface current index is " .. tostring(surfacesToScanIndex))
--   local index, surface = next(surfacesToScan, surfacesToScanIndex)
--    if not index then
--        surfacesToScan = game.surfaces
--        out("Resetting surfaces to scan2")
--        index, surface = next(surfacesToScan, nil)
--    end
--    if surface then
--        surfacesToScanIndex = index
--        out("Scanning surface " .. index .. tostring(surface))
----        return surface.find_entities_filtered({type = "assembling-machine"})
--    else
--        out("Surface is nil. Not scanning")
--    end
--    return {}
end

local scan_delay = 3600
local last_scan = 0
local wait = false

function entityTickIterateNext()
  -- Use time constraint to not scan too often (to avoid lag)
  -- If next is not nil, then scan it
  local index, entity
  if not wait then
    index, entity = next(entitiesToScan, entitiesToScanIndex)
  end
  if index then
    entitiesToScanIndex = index
    return entity
  end
  wait = true
  if last_scan + scan_delay > game.tick then
    -- Skip checking to avoid lag.
    return nil
  end
  wait = false
  last_scan = game.tick
--  out("TIME " .. last_scan)
    if not index then
--      out("No index at tick " .. game.tick)
        local surfaceIndex = scan()
        surfacesToScanIndex = surfaceIndex
        if surfaceIndex then
--          out("Scan " .. typeToScan .. " on " .. surfaceIndex .. " at tick " .. game.tick)
            entitiesToScan = game.surfaces[surfaceIndex].find_entities_filtered({type = typeToScan})
            -- out("Using surfaceIndex " .. tostring(surfaceIndex) .. " contains " .. #entitiesToScan)
            index, entity = next(entitiesToScan, index)
        else
            entitiesToScanIndex = nil
            if typeToScan == "assembling-machine" then
                typeToScan = "furnace"
            else
                typeToScan = "assembling-machine"
            end
            -- out("Switching type to " .. typeToScan)
            return nil
        end
    end
    entitiesToScanIndex = index
    return entity
end
