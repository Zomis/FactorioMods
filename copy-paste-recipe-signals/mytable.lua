-- MIT License

-- Copyright (c) 2020 raiguard

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.


--- Create a filtered version of a table based on the results of a filter function.
---
--- Calls `filter(value, key)` on each element in the table, returning a new table with only pairs for which
--- `filter` returned a truthy value.
---
--- ### Examples
---
--- ```lua
--- local tbl = {1, 2, 3, 4, 5, 6}
--- local just_evens = table.filter(tbl, function(v) return v % 2 == 0 end) -- {[2] = 2, [4] = 4, [6] = 6}
--- local just_evens_arr = table.filter(tbl, function(v) return v % 2 == 0 end, true) -- {2, 4, 6}
--- ```
--- @generic K, V
--- @param tbl table<K, V>
--- @param filter fun(value: V, key: K): boolean
--- @param array_insert boolean? If true, the result will be constructed as an array of values that matched the filter. Key references will be lost.
--- @return table<K, V>
function flib_table.filter(tbl, filter, array_insert)
  local output = {}
  local i = 0
  for k, v in pairs(tbl) do
    if filter(v, k) then
      if array_insert then
        i = i + 1
        output[i] = v
      else
        output[k] = v
      end
    end
  end
  return output
end 