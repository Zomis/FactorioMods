game.get_surface(1).create_entity({
            name = "entity-ghost",
            inner_name = "steel-chest",
            position = game.local_player.position,
            force = game.local_player.force
})
