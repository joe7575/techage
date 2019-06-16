# Power Distribution API

The module power supports 3 kinds of devices:
- Generators: Provide power, can be turned on/off
- Consumers: Need power, like machines or lamps, can be turned on/off
- Akkus: Can provide stored power, combination of generator and consumer

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
		conn_sides = <list>,                   -- allowed connection sides for power cables
			                                   -- one or several of {"L", "R", "U", "D", "F", "B"}
		power_network = <tubelib2-instance>,
    }

tbd..........


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

