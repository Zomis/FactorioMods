local function out(txt)
  local debug = false
  if debug then
    game.print(txt)
  end
end

local function txtpos(pos)
  return "{" .. pos["x"] .. ", " .. pos["y"] .."}"
end

local function worldAndPos(entity)
  return entity.surface.name .. txtpos(entity.position)
end

return { out = out, txtpos = txtpos, worldAndPos = worldAndPos }
