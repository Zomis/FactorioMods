globals = { "global", "game", "data", "settings", "remote" }
read_globals = { "defines", "script" }
color = false

files["what-is-missing_*/control.lua"] = { read_globals = { "entityTickIterateNext" } }
files["what-is-missing_*/entity_tick_iterate.lua"] = { globals = { "entityTickIterateNext" } }
