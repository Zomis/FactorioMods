local main_gui = require("gui/main_gui")

remote.add_interface("train-log", {
    open_train_log = function(player, info)
        main_gui.open(player, info)
    end,
    foogle_support = function(info)
        return info.type == "fluid" or info.type == "item"
    end
})

local function on_load()
    if remote.interfaces["foogle"] then
        remote.call("foogle", "add_integration", "train-log", {
            supported_check = "foogle_support",
            callback = "open_train_log"
        })
    end
end

return { on_load = on_load }
