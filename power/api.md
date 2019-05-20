# Power Distribution API

The module power supports 3 kinds of devices:
- Generators: Provide power, can be turned on/off
- Consumers: Need power, like machines or lamps, can be turned on/off
- Batteries: Can provide stored power, combination of generator and consumer

### Possible connection sides
```
                        U(p) B(ack)
                        |    /
                        |   /
                     +--|-----+
                    /   o    /|
                   +--------+ |
        L(eft) ----|        |o---- R(ight)
                   |    o   | +
                   |   /    |/
                   +--/-----+
                     /  |
                F(ront) |
                        |
                      D(own)
```

All 3 kinds of nodes use the same registration function to enrich the nodes functionality for power distribution.

    techage.power.register_nodes(names, definition) 
    -- names is a list of node names
	-- definition is a table according to:

	{
		on_power_pass1 = func(pos, mem),       -- for power balance calculation
		on_power_pass2 = func(pos, mem, sum),  -- for power balance adjustment
		on_power_pass3 = func(pos, mem, sum),  -- for power balance result
		conn_sides = <list>,                   -- allowed connection sides for power cables
			                                   -- one or several of {"L", "R", "U", "D", "F", "B"}
		power_network = <tubelib2-instance>,
    }

**Pass1: Power balance calculation** `on_power_pass1`
Return the currently needed amount of power.
For batteries, switch to uncharging and return the uncharging value (negative value).

**Pass2: Power balance adjustment** `on_power_pass2`
Provides the current power balance. A positive sum means, more power available then needed.
A battery can turn off or even switch to charging if the balance is positive. 
In this case, return the correction value (a positive value) instead of 0.
In case of a consumer: turn off if power balance is negative and return the correction value (a negative value).

**Pass3: Power balance result** `on_power_pass3`
Function provides the final power balance for output purposes.


	techage.power.power_distribution(pos) 
	-- Trigger the recalculation or the power distribution in case of
    -- a turn on/off request


    techage.power.formspec_power_bar(max_power, current_power)
    -- returns the formspec PGN with a bar according the the ratio `current_power/max_power`

    techage.power.formspec_load_bar(charging)
    -- returns the formspec PGN with the charging/uncharging symbol
    -- charging can be:
    --   true  => charging
    --   false => uncharging
    --   nil   => turned off


### Internas
The function `techage.power.register_nodes`:
- adds a wrapper to `after_place_node` (needed to maintain tubelib2 data base)
- adds a wrapper to `after_dig_node` (needed to maintain tubelib2 data base)
- adds the function `after_tube_update` (needed to maintain tubelib2 data base)
- adds the table `power` to the node definition with the provided attributes
- adds `power_dirs` to the node meta table with the `conn_sides` information converted to node specific dirs
- adds `mem.connections` for the available power connections with consideration of valid `power_dirs`

