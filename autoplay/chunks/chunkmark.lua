local ChunkMark = {}
ChunkMark.__index = ChunkMark

function ChunkMark:create(surface, chunk_position)
    local mark = {}
    setmetatable(mark, ChunkMark)
    mark.save_state = { chunk_surface = surface.name, chunk_x = chunk_position.x, chunk_y = chunk_position.y }
    return mark
end

function ChunkMark:load(data)
    local mark = {}
    setmetatable(mark, ChunkMark)
    mark.save_state = data
    return mark
end

return ChunkMark
