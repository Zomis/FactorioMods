--- A table representing the scan results for a fluidbox network.
-- @class FluidConnections
-- @field inputs Entities providing fluids to the fluid network, mapped by entity_id to entity
-- @field outputs Entities consuming fluids from the fluid network, mapped by entity_id to entity
-- @field scanned Entities scanned, mapped by entity_id to entity
-- @field storages An array of entities that are storage-tanks
-- @field segment_id The segment_id of the fluidbox network


--- Get a string id for an entity
-- @param entity LuaEntity: The entity
-- @return string: The string id for the entity
local function entity_id(entity)
    return entity.surface.name .. "/" .. entity.name .. "/" .. entity.position.x .. "," .. entity.position.y
end

--- Perform a scan of an entity
-- @param results FluidConnections: Where to store the results
-- @param entity LuaEntity: The entity
-- @param segment_id number: The segment_id of the relevant fluidbox
-- @return table: An array of neighbors to be scanned next
local function _scan_in_progress(results, entity, segment_id)
    local fluidbox = entity.fluidbox
    local count = #fluidbox
    local neighbors = {}

    local id = entity_id(entity)
    results.scanned[id] = entity

    if entity.type == "storage-tank" then
        table.insert(results.storages, entity)
    end

    for i = 1,count do
        -- Pumps and machines does not seem to have fluid segment id.
        if fluidbox.get_fluid_segment_id(i) == segment_id then
            local conn = entity.fluidbox.get_pipe_connections(i)
            for _, v in pairs(conn) do
                if v.target then
                    table.insert(neighbors, v.target.owner) -- TODO: Consider adding target_fluidbox_index and target_pipe_connection_index
                end
            end
        else
            -- At 'end', is either input or output.
            -- Might be adjecent to something in our fluid segment, figure out which.
            local conn = entity.fluidbox.get_pipe_connections(i)
            for _, v in pairs(conn) do
                -- Just because it has a connection doesn't mean there's a pipe going out from it
                -- e.g. a machine with two fluid outputs of the same type.
                -- therefore check that v.target is set.
                if v.target and results.scanned[entity_id(v.target.owner)] then
                    local type = v.flow_direction
                    if type == "input" then
                        -- Inputs TO this entity FROM our fluid segment, so it's an output for the fluid segment
                        results.outputs[id] = entity
                    elseif type == "output" then
                        results.inputs[id] = entity
                    end
                end
            end
        end
    end
    return neighbors
end

--- Perform a full scan of a Fluid Network segment
-- @param entity LuaEntity: The entity to start the scanning from
-- @param segment_id number: The segment_id of the relevant fluidbox
-- @return FluidConnections|string: The results of the scan or an error
function scan(entity)
    if not entity then
        return
    end
    if not entity.fluidbox then
        return
    end
    if #entity.fluidbox > 1 then
        return "multiple-fluidboxes"
    end
    local segment_id = entity.fluidbox.get_fluid_segment_id(1)
    if not segment_id then
        return "no-segment-id"
    end
    local results = {
        segment_id = segment_id,
        scanned = {},
        inputs = {},
        outputs = {},
        storages = {},
    }
    local queue = { entity }
    while next(queue, nil) do -- As long as queue is not empty
        local last_element = table.remove(queue)
        local add_to_queue = _scan_in_progress(results, last_element, segment_id)
        for _, e in pairs(add_to_queue) do
            local id = entity_id(e)
            if not results.scanned[id] then
                table.insert(queue, e)
            end
        end
    end
    return results
end

return scan
