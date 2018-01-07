iron_plate = sum(green)
copper_plate = avg(green.iron_plate, green.copper_plate)
stone = mod(add(stone, 1), 10)
coal = if(stone, "==", const(0), const(1), const(0)) -- if (stone == 0) then coal = 1 else coal = 0
signal_a = avg(red)
signal_b = filter(red, array(iron_plate, copper_plate, signal_a))

cooper_plate = red.copper_plate + red.iron_plate
signal_b = top.copper_plate / bottom.oil
if(red.coal > 100) copper_plate = 1
if(red.coal < 20) copper_plate = 0

transform(array(iron_plate, copper_plate, signal_a, signal_b, signal_c), array(signal_f, signal_g, signal_h, signal_i, signal_j))
transform(top.red, bottom.green) -- take the signals that exist on top.red and map them to signals on bottom.green (?)

copper_plate = on_off(red.coal > 100, red.coal < 100) -- turn on when condition A, turn off when condition B
signal_a = avg(top.green)
signal_a = count(top)
-- place it next to a lamp?

result_value = func(func(a), func(20))
signal_a = circuit_network_green(this)

signal_b = top.rocket_parts

if tick time % 5322 == 0 then signal_l =

-- Minesweeper ?

-- http://lua-api.factorio.com/latest/Concepts.html#ConstantCombinatorParameters
