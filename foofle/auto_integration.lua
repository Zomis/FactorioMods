local single = require("gui/single")

local function sprite_to_signal(sprite)
    local slash_index = string.find(sprite, "/")
    if not slash_index then
        return {}
    end
    local type = string.sub(sprite, 1, slash_index - 1)
    local name = string.sub(sprite, slash_index + 1)
    return {
        type = type,
        name = name
    }
end

local function on_event(event)
    if not event.control or not event.shift then
        return
    end
    if event.element.type == "choose-elem-button" then
        if type(event.element.elem_value) == "string" then
            single.open({
                type = event.element.elem_type,
                name = event.element.elem_value
            }, event)
            return
        end
        -- elem_value is probably a SignalID in which case it already has type and name properties
        single.open(event.element.elem_value, event)
    end
    if event.element.type == "sprite-button" then
        local info = sprite_to_signal(event.element.sprite)
        if info.type == "item" or info.type == "fluid" then
            single.open(info, event)
        end
    end
end

return {
    on_event = on_event
}