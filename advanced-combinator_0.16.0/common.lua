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

local function table_indexof(table, value)
  for key, v in pairs(table) do
    if v == value then
      return key
    end
  end
  return nil
end

return {
  txtpos = txtpos,
  worldAndPos = worldAndPos,
  table_indexof = table_indexof,

  out = out
}
