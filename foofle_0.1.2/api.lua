--- summary.
-- Description; this can extend over
-- several lines
local impl = require "impl"

local api = {}

--- A table of what is supported
--- @class FoofleSupports
--- @field items boolean|table Either true/false or a table with which ones are supported
--- @field fluid boolean|table Either true/false or a table with which ones are supported
--- @field signal boolean|table Either true/false or a table with which ones are supported
--- @field entity boolean|table Either true/false or a table with which ones are supported

--- A Foofle quick button.
--- @class FoofleQuickButton

--- A Foofle Plugin.
--- A Plugin that can do many things in Foofle.
--- @class FooflePlugin
--- @field id string Unique identifier of the plugin
--- @field name LocalisedString Plugin name to be shown in options and as titles for plugin section
--- @field quick_button FoofleQuickButton? A button to show when having a prototype shown
--- @field supported fun(prototype: SignalID): boolean
--- @field remote FoofleRemote Information about remote interface to use for plugin
--- @field show fun(prototype: SignalID): GuiBuildStructure? A function that creates GUI elements to show

--- Add a plugin.
-- @param plugin FooflePlugin
function api.add_plugin(plugin)
    impl.add_plugin(plugin)
end

return api