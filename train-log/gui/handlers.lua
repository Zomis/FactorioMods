local toolbar = require("gui/toolbar")
local events_table = require("gui/events_table")
local gui = {}

function gui.events_table(e)
    events_table.handle_action(e.action, e.event)
end

function gui.toolbar(e)
    toolbar.handle_action(e.action, e.event)
end

return gui
