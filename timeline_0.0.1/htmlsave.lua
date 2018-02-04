local tick_to_timestring = require "tick_to_timestring"

local function row(mark)
	local TICKS_PER_SECOND = 60
	local tick = mark.tick
  local seconds = math.floor(tick / TICKS_PER_SECOND)
	local minutes = math.floor(seconds / 60)
	local hours = math.floor(minutes / 60)
	local timestamp = string.format("%02d:%02d:%02d", hours, minutes % 60, seconds % 60)

	local name = mark.name
	local param = mark.param
	local value = mark.value

	local tickStr = "<td>" .. tostring(tick) .. "</td>\n"
	local timestampStr = "<td>" .. timestamp .. "</td>\n"
	local nameStr = "<td>" .. tostring(name) .. "</td>\n"
	local paramStr = "<td>" .. tostring(param) .. "</td>\n"
	local valueStr = "<td>" .. tostring(value) .. "</td>\n"
	return "<tr>\n" .. tickStr .. timestampStr .. nameStr .. paramStr .. valueStr .. "</tr>\n"
end

local function timelineRows(marks)
	html = ""
	for i, mark in ipairs(marks) do
		html = html .. row(mark) .. "\n"
	end
	return html
end

local function htmlString(marks)
	local html = [[<!DOCTYPE html>
<html>
	<head>
	</head>
	<body>
		<table>
			<thead>
				<tr>
					<th>Tick</th>
					<th>Timestamp</th>
					<th>Event</th>
					<th>Parameter</th>
					<th>Value</th>
				</tr>
			</thead>
			<tbody>
]]
	html = html .. timelineRows(marks)
	html = html .. [[
		</tbody>
	</table>
	</body>
	</html>
	]]
	return html
end

return htmlString
