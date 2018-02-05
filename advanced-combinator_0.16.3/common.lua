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

local function split(text, delimiter)
  if string.len(delimiter) > 1 then
    error("split only supports a single character as delimiter, not a string")
  end
  local result = {}
  for line in string.gmatch(text, "[^" .. delimiter .. "]+") do
    table.insert(result, line)
  end
  return result
end

local function join(dict, joiner)
  local joined = ""
  local first = true
  for _, v in pairs(dict) do
    if not first then
      joined = joined .. joiner
    end
    joined = joined .. v
    first = false
  end
  return joined
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
  split = split,
  join = join,

  out = out
}
