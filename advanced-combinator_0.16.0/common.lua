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

local function print_recursive_table(data, indentation)
  if not indentation then
    indentation = ""
  end
  if type(data) ~= "table" then
    out(indentation .. tostring(data))
    return
  end
  for k,v in pairs(data) do
    if type(v) == "table" then
      print_recursive_table(v, indentation .. "." .. k)
    elseif type(v) ~= "function" then
      out(indentation .. "[" .. k .. "]" .. " = " .. tostring(v))
    end
  end
end

-- http://lua-users.org/wiki/CommonFunctions
local function trim(s)
  -- from PiL2 20.4
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function table_indexof(table, value)
  for key, v in pairs(table) do
    if v == value then
      return key
    end
  end
  return nil
end

local function signal_to_string(signal)
  return signal.type .. "/" .. signal.name
end

return {
  txtpos = txtpos,
  print_recursive_table = print_recursive_table,
  worldAndPos = worldAndPos,
  table_indexof = table_indexof,
  signal_to_string = signal_to_string,
  trim = trim,

  out = out
}
