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

local flib_table = {}

--- Call the given function on a set number of items in a table, returning the next starting key.
---
--- Calls `callback(value, key)` over `n` items from `tbl` or until the end is reached, starting after `from_k`.
---
--- The first return value of each invocation of `callback` will be collected and returned in a table keyed by the
--- current item's key.
---
--- The second return value of `callback` is a flag requesting deletion of the current item.
---
--- The third return value of `callback` is a flag requesting that the iteration be immediately aborted. Use this flag to
--- early return on some condition in `callback`. When aborted, `for_n_of` will return the previous key as `from_k`, so
--- the next call to `for_n_of` will restart on the key that was aborted (unless it was also deleted).
---
--- **DO NOT** delete entires from `tbl` from within `callback`, this will break the iteration. Use the deletion flag
--- instead.
---
--- ### Examples
---
--- ```lua
--- local extremely_large_table = {
---   [1000] = 1,
---   [999] = 2,
---   [998] = 3,
---   ...,
---   [2] = 999,
---   [1] = 1000,
--- }
--- event.on_tick(function()
---   storage.from_k = table.for_n_of(extremely_large_table, storage.from_k, 10, function(v) game.print(v) end)
--- end)
--- ```
--- @generic K, V, C
--- @param tbl table<K, V> The table to iterate over.
--- @param from_k K The key to start iteration at, or `nil` to start at the beginning of `tbl`. If the key does not exist in `tbl`, it will be treated as `nil`, _unless_ a custom `_next` function is used.
--- @param n number The number of items to iterate.
--- @param callback fun(value: V, key: K):C,boolean,boolean Receives `value` and `key` as parameters.
--- @param _next? fun(tbl: table<K, V>, from_k: K):K,V A custom `next()` function. If not provided, the default `next()` will be used.
--- @return K? next_key Where the iteration ended. Can be any valid table key, or `nil`. Pass this as `from_k` in the next call to `for_n_of` for `tbl`.
--- @return table<K, C> results The results compiled from the first return of `callback`.
--- @return boolean reached_end Whether or not the end of the table was reached on this iteration.
function flib_table.for_n_of(tbl, from_k, n, callback, _next)
  -- Bypass if a custom `next` function was provided
  if not _next then
    -- Verify start key exists, else start from scratch
    if from_k and not tbl[from_k] then
      from_k = nil
    end
    -- Use default `next`
    _next = next
  end

  local delete
  local prev
  local abort
  local result = {}

  -- Run `n` times
  for _ = 1, n, 1 do
    local v
    if not delete then
      prev = from_k
    end
    from_k, v = _next(tbl, from_k)
    if delete then
      tbl[delete] = nil
    end

    if from_k then
      result[from_k], delete, abort = callback(v, from_k)
      if delete then
        delete = from_k
      end
      if abort then
        break
      end
    else
      return from_k, result, true
    end
  end

  if delete then
    tbl[delete] = nil
    from_k = prev
  elseif abort then
    from_k = prev
  end
  return from_k, result, false
end

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

--- Create a transformed table using the output of a mapper function.
---
--- Calls `mapper(value, key)` on each element in the table, using the return as the new value for the key.
---
--- ### Examples
---
--- ```lua
--- local tbl = {1, 2, 3, 4, 5}
--- local tbl_times_ten = table.map(tbl, function(v) return v * 10 end) -- {10, 20, 30, 40, 50}
--- ```
--- @generic K, V, N
--- @param tbl table<K, V>
--- @param mapper fun(value: V, key: V):N?
--- @return table<K, N>
function flib_table.map(tbl, mapper)
  local output = {}
  for k, v in pairs(tbl) do
    output[k] = mapper(v, k)
  end
  return output
end

return flib_table 