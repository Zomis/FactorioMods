globals = { "global", "game", "data" }
read_globals = { "defines", "script" }
color = false

files["what-is-missing_*/control.lua"] = { read_globals = { "entityTickIterateNext" } }
files["what-is-missing_*/entity_tick_iterate.lua"] = { globals = { "entityTickIterateNext" } }
files["visual-signals_*/control.lua"] = {
  read_globals = {
    "CreateSignalGuiPanel", "UpdateSignalGuiPanel"
  }
}
files["visual-signals_*/signal_gui.lua"] = {
  globals = {
    "CreateSignalGuiPanel", "UpdateSignalGuiPanel"
  }
}
