# Factorio Search Engine

## Approach

- One main API that lets other mods plug in to here
- For example, Visual Signals would for sure want to add it's own things here.

Maybe also expose something that lets other mods call this mod, and help them create their own search interfaces? (Visual Signals could for sure use it)

Use Async to perform the search in many cases. Use a somewhat good filter for the first check (entity type and force) and then scan through it.

## TODO Next steps

- Progress bar (especially important for Signals search)
- Fluid search
- Entity search
- Possibility to search for multiple items/signals/fluids at the same time (such as all "Induction Furnace") - selection is possible with flib styles
- Producer/Consumer search (for items and fluids)
- Improve view of results

## Features

- Recent searches
- Favorite searches - especially for "Find my car" and similar?
- Some kind of share feature... Add icon to other players GUI's? "Simon is sharing XYZ with you"
- Aliases? Such as "LTN" -> logistics-train-stop (entity name in this case)
- Search selector: Select area, show options about what is in that area (transport belt, items on belt, inserters, machines, recipes in machines, inputs, outputs...)
- Add more results to existing search
- Filter existing search results, add/remove filters?

## Random thoughts not mentioned in GUI Flow

Print count of force entities: /c game.print(tonumber(table_size(game.player.surface.find_entities_filtered { force = game.player.force })))
Search recipe chains - "Nutrient Pulp and Plastics, how are those connected?" (Nutrient Pulp ingredient, Plastics result)
Search circuit network, search which thing provides signal in network? (combinators, containers, inserters, belts)
Search free text word-by-word multi search.
  Example: Writing both "LTN" and "Iron" might show Visual Signals Display "Missing in LTN": "2000 Iron Plates"
  Example: Writing both "Car" and "Iron" might show a car with iron plates in it, or an iron chest with a car in it.
Search for burnable items, or other categories
Search for prototypes - item consumers for example (such as science packs, especially in Höllenmodpack)
Search for prototypes - electric generators, electric distributors, logistics-related things... ("type")
Search as soon as you click the first search button, search for all possibilities and show the total results for each as time goes by
Search for train stop name - Where the hell are all those "Unused" stations anyway?
GROUP BY functionality? Such as "Find all assembling machines, group by product/recipe" (show grouped-by-thing, count, sum of count property?)
ORDER BY functionality? Such as "closest" or "highest count"
WiM integration - click on something in WiM (left/right-click like FNEI) to launch search for producers/consumers with extra filter not-enough-ingredients-of-that-kind
Handle special items, such as "item with inventory"

- Item filters: Logistics requests
- Recipe filters: Craftable
- Train
- LuaTransportLine???
- Circuit Network
- Map tag

## GUI Flow

TODO: Should step 1 - 3 be in the same GUI window and selectable first? (which is more like how BeastFinder works)

1. Enter text
2. Choose what to search for exactly
      "Iron" ->
        Recipes: ... (everything *named* something with "iron")
        Items: ore / pellets / ingots ...
        Fluid: Molten Iron
        Entities: Iron Chest
      "Car" ->
        Recipe: Car
        Item: Car, Cargo Wagon
        Entity: Car, Cargo Wagon 1, Cargo Wagon 2...
      "Ass" ->
        Recipe: Assembling machines...
        Item: Assembling machines...
        Entity: Assembling machines...
      (Clicking Item / Fluids will also lead to signals in next step)
      Allow multi-select / search all button
  - Plugin Visual Signals: Visual Signals

3. Where/What to search?
      Items:
        Entity Search: Containers / Vehicles / Belts / Items-on-ground, producers (including mining drills), consumers
        Signals Search: Signals
        Recipe Search: Ingredient / Product
      Fluids:
        Entity Search: Containers / Vehicles / Pipes, producers, consumers
        Signals Search: Signals
        Recipe Search: Ingredient / Product
      Recipes:
        Entity Search: Machines with recipes
        Recipe Search: Recipe
      Entities:
        Entity Search: Entity
      Visual Signals:
        Visual Signals Search: Visual Signals display name. Example: Search for "Missing in LTN" to bring that up

4. Search in progress... Show progress bar? Show results found so far?

5. Actions

Apply Filters: based on location, etc.
- Entity: Owner, contains items, Train: Has Station / Wait condition, recipe, modules
- Has owner: self / name of Owner
- Signals: Connected to entity name/type, also contains signal, does not contain signal
  - Plugin Visual Signals: Connected to (visual signals name)

Actions:
- Add/Remove search condition (filters, see above)
- All:
  - Pop-out/Pin (minimap if has location)
- Has location:
  - player.zoom_to_world / player.open_map
    - Scroll through (Previous / Next, currently showing 1 / 135)
  - player.print (self / other player) `(Thing) is 123m (direction) at [gps=...]`
  - player.force.add_chart_tag
  - player.add_custom_alert
  - player.create_local_flying_text ?
- Signals:
  - View
  - Search for connected entity
- Recipes:
  - View
  - Open FNEI
  - Search for machines with recipe
