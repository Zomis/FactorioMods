local function signal_for_entity(entity)
    local empty_signal = { type = "virtual", name = "signal-0" }
    if not entity then return empty_signal end
    if not entity.valid then return empty_signal end

    k, v = next(entity.prototype.items_to_place_this)
    if k then
        return { type = "item", name = v.name }
    end
    return empty_signal
end

return {
    signal_for_entity = signal_for_entity
}
