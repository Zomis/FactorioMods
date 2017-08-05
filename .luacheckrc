globals = { "global", "game", "data" }
read_globals = { "defines", "script" }
color = false

files["what-is-missing_0.15.0/control.lua"] = { read_globals = { "entityTickIterateNext" } }
files["what-is-missing_0.15.0/entity_tick_iterate.lua"] = { globals = { "entityTickIterateNext" } }
files["visual-signals_0.15.2/control.lua"] = {
  read_globals = {
    "CreateSignalGuiPanel", "UpdateSignalGuiPanel"
  }
}
files["visual-signals_0.15.2/entity_tick_iterate.lua"] = {
  globals = {
    "CreateSignalGuiPanel", "UpdateSignalGuiPanel"
  }
}
