# Factorio Mods

Several mods for the Factorio game, each mod is described below.

## [Visual Signals](https://mods.factorio.com/mods/zomis/visual-signals) (GUI Signal Display)

Allows players to keep track of circuit networks in the GUI at any time.

Originally based on [CircuitsUI by Fumelgo](https://mods.factorio.com/mods/Fumelgo/CircuitsUI) but massively modified to become a mod on its own.

![Factorio screenshot of Visual Signals](https://mods-data.factorio.com/pub_data/media_files/vjrlqhNDv4QS.png)

## [Lamp Placer](https://mods.factorio.com/mods/zomis/lamp-placer)

Lets the player select an area with a Lamp Placer tool to give orders to robots to place lamps in the area.

![Factorio screenshot of Lamp Placer](https://mods-data.factorio.com/pub_data/media_files/XolK5mysVxah.png)

## [What is Missing (WiM)](https://mods.factorio.com/mods/zomis/what-is-missing)

The GUI will show when you place something on the map.

No need to run around checking why you are not producing so much as you want to. This mod will tell you about all things that are causing you to not produce as much research, build a rocket, or any items of your choice.

![Factorio screenshot of What is Missing](https://mods-data.factorio.com/pub_data/media_files/ZYuB7woBjvzO.png)

## [Advanced Combinator](https://mods.factorio.com/mod/advanced-combinator)

Instead of using one combinator to get the minimum value of a network, one to get the game time, then some to do some other arithmetic with it, I decided to make one combinator that can do it all!

This mod is using (somewhat) clean code and good coding practices which makes it easy to add more features too.

Although it may be difficult to use at first, it is very powerful and capable of lots of things!

![Factorio screenshot of Advanced Combinator](https://mods-data.factorio.com/assets/102511eb9c85063d051c0492bfc17b2c23994650.png)

## [Timeline](https://mods.factorio.com/mod/timeline)

Track your efficiency and improve yourself in becoming faster. Ideal for those who try to speed-run the game.

This mod saves the timestamp of some key events:
- Research finished
- Rockets launched and their content
- Every power of 10 of items produced (1 items produced, 10, 100, 1000, etc.)
- Player died

Other mods may add their own mark by invoking a method that takes the force, a name, a parameter, and a numeric value:
remote.call("timeline", "add_timeline_mark", force, "some-name", "some-parameter", 42)

Supports export to a HTML file so that you can easily compare your performance between different games.

![Factorio screenshot of Timeline](https://mods-data.factorio.com/assets/ee2cc0396664d16c43bcb9869ef60c45aa070589.png)
