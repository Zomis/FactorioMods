-- 1:result_value = func(func(a), func(20))

-- Basic Mathematics
virtual/signal-A = green(this,item/iron-plate)
virtual/signal-B = add(green(this,iron-plate),green(this,copper-plate))
virtual/signal-B = add(green(this,iron-plate),red(this,copper-plate))

iron_plate = sum(network(this,green))
copper_plate = avg(array(green(this,item/iron_plate),green(this,item/copper_plate)))
signal_a = avg(network(this,red))
signal_b = div(green(top,item/copper_plate),red(bottom,fluid/oil))
signal_a = avg(network(top,green))
signal_a = count(network(top,green))

-- More complicated Mathematics
stone = mod(add(stone, 1), 10)

-- Get data from nearby entities or the game
signal_b = entityData(top, rocket_parts)
signal_a = sum(network(this, red))
signal_a = sum(network(top, green))
signal_h = gameData(tick)

-- Current game time in ticks, hours, minutes, seconds
1:virtual/signal-c = add(previous(1),const(1))

1:virtual/signal-t = gameData(tick)
2:virtual/signal-s = div(current(1), 60)
3:virtual/signal-h = div(current(2), 3600)
4:virtual/signal-m = mod(div(current(2), 60), 60)
2:virtual/signal-s = mod(current(2), 60)

-- Also use types
typeof(max(top.green)) = const(1)
typeof(min(top.green)) = const(2)

-- If-else statements
coal = if(stone, "==", const(0), const(1), const(0)) -- if (stone == 0) then coal = 1 else coal = 0
if(red.coal > 100) copper_plate = 1
if(red.coal < 20) copper_plate = 0

-- Filtering
signal_b = filter(red, array(iron_plate, copper_plate, signal_a))
signal_c = filter(red, predicate("==", 20)) -- filter all values that fulfill a criteria

if tick time % 5322 == 0 then signal_l = 0

-- Minesweeper ?

-- http://lua-api.factorio.com/latest/Concepts.html#ConstantCombinatorParameters

copper_plate = on_off(red.coal > 100, red.coal < 100) -- turn on when condition A, turn off when condition B


transform(array(iron_plate, copper_plate, signal_a, signal_b, signal_c), array(signal_f, signal_g, signal_h, signal_i, signal_j))
transform(top.red, bottom.green) -- take the signals that exist on top.red and map them to signals on bottom.green (?)
