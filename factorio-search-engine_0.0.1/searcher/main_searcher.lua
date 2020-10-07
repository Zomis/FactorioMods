local searcher = require "searcher/searcher"
local main_searcher = searcher:new()
main_searcher:add_type_plugin(require "plugins/items/items")
main_searcher:add_search_plugin(require "plugins/items/item_container")
return main_searcher
