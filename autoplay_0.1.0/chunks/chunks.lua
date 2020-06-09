local Chunks = {}
Chunks.__index = Chunks

local ChunkMark = require "chunks/chunkmark"

local global_chunkmarks = nil
local local_chunkmarks = nil

-- surface.get_entities_with_force(chunk_position, force)

function Chunks:on_load()
    global_chunkmarks = globals.chunkmarks
    local_chunkmarks = {}
    if global_chunkmarks then
        for k, v in pairs(global_chunkmarks) do
            local_chunkmarks[k] = ChunkMark:load(v)
        end
    end
end

function Chunks:for_chunk(surface, chunk_position)
    if not global_chunkmarks then
        globals.chunkmarks = globals.chunkmarks or {}
        global_chunkmarks = globals.chunkmarks
    end

    local chunk_key = surface.name .. ":" .. chunk_position.x .. "," .. chunk_position.y
    local existing_chunkmark = global_chunkmarks[chunk_key]
    
    if existing_chunkmark then
        return existing_chunkmark
    end

    local chunk = ChunkMark:create(surface, chunk_position)
    global_chunkmarks[chunk_key] = chunk.save_state
    local_chunkmarks[chunk_key] = chunk
    return chunk
end

return Chunks