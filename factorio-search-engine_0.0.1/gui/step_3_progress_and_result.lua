local function search_completed(search)
    game.print("search_completed")
    game.print(serpent.block(search))
end

return {
    search_completed = search_completed
}
