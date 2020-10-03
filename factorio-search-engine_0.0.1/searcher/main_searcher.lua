local searcher = require "searcher/searcher"
local main_searcher = searcher:new()
main_searcher:add_type_plugin(require "plugins/types/items")
return main_searcher
