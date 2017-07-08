local entitiesToScan = {}
local entitiesToScanIndex = nil
local surfacesToScan = {}
local surfacesToScanIndex = nil

local function out(txt)
  debug = true
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

function entityTickIterateNext()
    local index, entity = next(entitiesToScan, entitiesToScanIndex)
    if not index then
        local surfaceIndex = scan()
        surfacesToScanIndex = surfaceIndex
        if surfaceIndex then
            entitiesToScan = game.surfaces[surfaceIndex].find_entities_filtered({type = "assembling-machine"})
            out("Using surfaceIndex " .. tostring(surfaceIndex) .. " contains " .. #entitiesToScan)
            index, entity = next(entitiesToScan, index)
        else
            entitiesToScanIndex = nil
            return nil
        end
    end
    entitiesToScanIndex = index
    return entity
end

