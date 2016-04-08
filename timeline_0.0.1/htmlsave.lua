function row(mark)
	local TICKS_PER_SECOND = 60
	local tick = mark.tick
    local seconds = tick / TICKS_PER_SECOND
	local minutes = seconds / 60
	local hours = minutes / 60
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

function timelineRows(player)
	local force = player.force
	local forceData = global.forces[force.name]
	local marks = forceData.allMarks
	html = ""
	for i, mark in ipairs(marks) do
		html = html .. row(mark) .. "\n"
	end
	return html
end

function htmlString(player)
	local html = [[<!DOCTYPE html><html>
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
	html = html .. timelineRows(player)
	html = html .. [[
		</tbody>
	</table>
	</body>
	</html>
	]]
	return html
end
