local htmlString = require "htmlsave"

local marks = {}
local function mark(tick, name, param, value)
  return { tick = tick, name = name, param = param, value = value }
end

table.insert(marks, mark(1, "produced", "iron-ore", 1))
table.insert(marks, mark(12, "produced", "iron-ore", 10))
table.insert(marks, mark(123, "produced", "iron-ore", 100))
table.insert(marks, mark(1234, "produced", "iron-ore", 1000))
table.insert(marks, mark(12345, "produced", "iron-ore", 10000))
table.insert(marks, mark(123456, "research-finished", "automation", nil))
table.insert(marks, mark(1234567, "rocket-launched", "rocket-launched", 1))

print(htmlString(marks))
