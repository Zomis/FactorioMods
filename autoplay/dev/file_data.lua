current_dir=io.popen"cd":read'*l'
print(current_dir)

local json = require "json"
local calc = require "autoplay/dev/calc2"

local function read_all(file)
    local f = assert(io.open(file, "rb"))
    local content = f:read("*all")
    f:close()
    return content
end

local data = json.decode(read_all("../script-output/export.json"))
calc.calc(data)
