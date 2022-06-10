# TA3: Oil Age

At TA3 it is important to replace the steam-powered machines with more powerful and electric-powered machines.

To do this, you have to build coal-fired power plants and generators. You will soon see that your electricity needs can only be met with oil-powered power plants. So you go looking for oil. Drilling derricks and oil pumps help them get the oil. Railways are used to transport oil to the power plants.

The industrial age is at its peak.

[techage_ta3|image]


## Coal-fired Power Station / Oil-fired Power Station

The coal-fired power plant consists of several blocks and must be assembled as shown in the plan on the right. The blocks TA3 power station fire box, TA3 boiler top, TA3 boiler base, TA3 turbine, TA3 generator and TA3 cooler are required.

The boiler must be filled with water. Fill up to 10 buckets of water in the boiler.
The fire box must be filled with coal or charcoal.
When the water is hot, the generator can then be started.

Alternatively, the power plant can be equipped with an oil burner and then operated with oil.
The oil can be refilled using a pump and oil pipe.

The power plant delivers an output of 80 ku.

[coalpowerstation|plan]


### TA3 power station firebox

Part of the power plant.
The fire box must be filled with coal or charcoal. The burning time depends on the power that is requested by the power plant. Coal burns for 20 s and charcoal for 60 s under full load. Correspondingly longer under partial load (50% load = double time).

[ta3_firebox|image]


### TA3 Power Station Oil Burner

Part of the power plant.

The oil burner can be filled with crude oil, fuel oil, naphtha or gasoline. The burning time depends on the power that is requested by the power plant. Under full load, crude oil burns 15 s, fuel oil 20 s, naphtha 22 s and gasoline 25 s.

Correspondingly longer under partial load (50% load = double time).

The oil burner can only hold 50 units of fuel. An additional oil tank and an oil pump are therefore advisable.


[ta3_oilbox|image]


### TA3 boiler base / top

Part of the power plant. Must be filled with water. If there is no more water or the temperature drops too low, the power plant switches off.

[ta3_boiler|image]


### TA3 turbine

The turbine is part of the power plant. It must be placed next to the generator and connected to the boiler and cooler via steam pipes as shown in the plan.

[ta3_turbine|image]


### TA3 generator

The generator is used to generate electricity. It must be connected to the machines via power cables and junction boxes.

[ta3_generator|image]


### TA3 cooler

Used to cool the hot steam from the turbine. Must be connected to the boiler and turbine via steam pipes as shown in the plan.

[ta3_cooler|image]


## Electrical current

In TA3 (and TA4) the machines are powered by electricity. To do this, machines, storage systems, and generators must be connected with power cables.
TA3 has 2 types of power cables:

- Insulated cables (TA power cables) for local wiring in the floor or in buildings. These cables can be hidden in the wall or in the floor (can be "plastered" with the trowel).
- Overland lines (TA power line) for outdoor cabling over long distances. These cables are protected and cannot be removed by other players.

Several consumers, storage systems, and generators can be operated together in a power network. Networks can be set up with the help of the junction boxes.
If too little electricity is provided, consumers run out.
In this context, it is also important that the functionality of Forceload blocks is understood, because generators, for example, only supply electricity when the corresponding map block is loaded. This can be enforced with a forceload block.

In TA4 there is also a cable for the solar system.


[ta3_powerswitch|image]


### Importance of storage systems 

Storage systems in the power grid fulfill two tasks:

- To cope with peaks in demand: All generators always deliver just as much power as is needed. However, if consumers are switched on/off or there are fluctuations in demand for other reasons, consumers can fail for a short time. To prevent this, there should always be at least one battery block in every network. This serves as a buffer and compensates for these fluctuations in the seconds range.
- To store regenerative energy: Solar and wind are not available 24 hours a day. So that the power supply does not fail when no electricity is produced, one or more storage systems must be installed in the network. Alternatively, the gaps can also be bridged with oil/coal electricity. 

A storage system indicates its capacity in kud, i.e. ku per day. For example, a storage system with 100 kud delivers 100 ku for one game day, or 10 ku for 10 game days.

All TA3/TA4 energy sources have adjustable charging characteristics. By default this is set to "80% - 100%". This means that when the storage system is 80% full, the output is reduced further and further until it switches off completely at 100%. If electricity is required in the network, 100% will never be reached, since the power of the generator has at some point dropped to the electricity demand in the network and the storage system is no longer charged, but only the consumers are served.

This has several advantages:

- The charging characteristics are adjustable. This means, for example, that oil/coal energy sources can be reduced at 60% and regenerative energy sources only at 80%. This means that oil/coal is only burned if there are not enough renewable energy sources available.
- Several energy sources can be operated in parallel and are loaded almost evenly, because all energy sources work, for example, up to 80% of the storage system's charging capacity at their full capacity and then reduce their capacity at the same time.
- All storage systems in a network form a large buffer. The charging capacity and the filling level of the entire storage system can always be read in percent on every storage system, but also on the electricity terminal.

[power_reduction|image] 



### TA Electric Cable

For local wiring in the floor or in buildings.
Branches can be realized using junction boxes. The maximum cable length between machines or junction boxes is 1000 m. A maximum of 1000 nodes can be connected in a power network. All blocks with power connection, including junction boxes, count as nodes.

Since the power cables are not automatically protected, the land lines (TA power line) are recommended for longer distances.

Power cables can be plastered with the trowel so they can be hidden in the wall or in the floor. All stone, clay and other blocks without "intelligence" can be used as plastering material. Dirt does not work because dirt can be converted to grass or the like, which would destroy the line.

For plastering, the cable must be clicked on with the trowel. The material with which the cable is to be plastered must be on the far left in the player inventory.
The cables can be made visible again by clicking on the block with the trowel.

In addition to cables, the TA junction box and the TA power switch box can also be plastered.

[ta3_powercable|image]


### TA Electric Junction Box

With the junction box, electricity can be distributed in up to 6 directions. Junction boxes can also be plastered (hidden) with a trowel and made visible again.

[ta3_powerjunction|image]


### TA Power Line

With the TA power line and the electricity poles, reasonably realistic overhead lines can be realized. The power pole heads also serve to protect the power line (protection). A pole must be set every 16 m or less. The protection only applies to the power line and the poles, however, all other blocks in this area are not protected.

[ta3_powerline|image]


### TA Power Pole
Used to build electricity poles. Is protected from destruction by the electricity pole head and can only be removed by the owner.

[ta3_powerpole|image]


### TA Power Pole Top
Has up to four arms and thus allows electricity to be distributed in up to 6 directions.
The electricity pole head protects power lines and poles within a radius of 8 m.

[ta3_powerpole4|image]


### TA Power Pole Top 2

This electricity pole head has two fixed arms and is used for the overhead lines. However, it can also transmit current downwards and upwards.
The electricity pole head protects power lines and poles within a radius of 8 m.

[ta3_powerpole2|image]


### TA Power Switch

The switch can be used to switch the power on and off. To do this, the switch must be placed on a power switch box. The power switch box must be connected to the power cable on both sides.

[ta3_powerswitch|image]


### TA Power Switch Small

The switch can be used to switch the power on and off. To do this, the switch must be placed on a power switch box. The power switch box must be connected to the power cable on both sides.

[ta3_powerswitchsmall|image]


### TA Power Switch Box

see TA power switch.

[ta3_powerswitchbox|image]


### TA3 Small Power Generator

The small power generator runs on gasoline and can be used for small consumers with up to 12 ku. Gasoline burns for 150 s under full load. Correspondingly longer under partial load (50% load = double time).

The power generator can only hold 50 units of gasoline. An additional tank and a pump are therefore advisable.


[ta3_tinygenerator|image]


### TA3 Battery Block

The battery block is used to store excess energy and automatically delivers power in the event of a power failure (if available).
Several battery blocks together form a TA3 energy storage system. Each battery block has a display for the charging state and for the stored load.
The values for the entire network are always displayed here. The stored load is displayed in "kud" or "ku-days" (analogous to kWh) 5 kud thus corresponds, for example, to 5 ku for a game day (20 min) or 1 ku for 5 game days.

A battery block has 3.33 kud

[ta3_akkublock|image]


### TA3 Power Terminal

The power terminal must be connected to the power grid. It shows data from the power grid.

The most important figures are displayed in the upper half:

- current/maximum generator power
- current power consumption of all consumers
- current charging current in/from the storage system
- Current state of charge of the storage system in percent

The number of network blocks is output in the lower half.

Additional data on the generators and storage systems can be queried via the "console" tab.

[ta3_powerterminal|image]


### TA3 Electric Motor

The TA3 Electric Motor is required in order to be able to operate TA2 machines via the power grid. The TA3 Electric Motor converts electricity into axle power.
If the electric motor is not supplied with sufficient power, it goes into an fault state and must be reactivated with a right-click.

The electric motor takes max. 40 ku of electricity and provides on the other side max. 39 ku as axle power. So he consumes one ku for the conversion.

[ta3_motor|image]




## TA3 Industrial Furnace

The TA3 industrial furnace serves as a supplement to normal furnaces. This means that all goods can be produced with "cooking" recipes, even in an industrial furnace. But there are also special recipes that can only be made in an industrial furnace.
The industrial furnace has its own menu for recipe selection. Depending on the goods in the industrial furnace inventory on the left, the output product can be selected on the right.

The industrial furnace requires electricity (for the fan) and fuel oil / gasoline for the burner. The industrial furnace and must be assembled as shown in the plan on the right.

See also TA4 heater.

[ta3_furnace|plan]


### TA3 Furnace Oil Burner

Is part of the TA3 industrial furnace.

The oil burner can be operated with crude oil, fuel oil, naphtha or gasoline. The burning time is 64 s for crude oil, 80 s for fuel oil, 90 s for naphtha and 100 s for gasoline.

The oil burner can only hold 50 units of fuel. An additional tank and a pump are therefore advisable.

[ta3_furnacefirebox|image]


### TA3 Furnace Top

Is part of the TA3 industrial furnace. See TA3 industrial furnace.

[ta3_furnace|image]


### TA3 Booster

Is part of the TA3 industrial furnace. See TA3 industrial furnace.

[ta3_booster|image]


## Liquids

Liquids such as water or oil can only be pumped through the special pipes and stored in tanks. As with water, there are containers (canisters, barrels) in which the liquid can be stored and transported.

It is also possible to connect several tanks using the yellow pipes and connectors. However, the tanks must have the same content and there must always be at least one yellow pipe between the tank, pump and distributor pipe.

E.g. It is not possible to connect two tanks directly to a distributor pipe.

The liquid filler is used to transfer liquids from containers to tanks. The plan shows how canisters or barrels with liquids are pushed into a liquid filler via pushers. The container is emptied in the liquid filler and the liquid is led down into the tank.

The liquid filler can also be placed under a tank to empty the tank.

[ta3_tank|plan]


### TA3 Tank

Liquids can be stored in a tank. A tank can be filled or emptied using a pump. To do this, the pump must be connected to the tank via a pipe (yellow pipes).

A tank can also be filled or emptied manually by clicking on the tank with a full or empty liquid container (barrel, canister). It should be noted that barrels can only be completely filled or emptied. If, for example, there are less than 10 units in the tank, this remainder must be removed with canisters or pumped empty.

A TA3 tank can hold 1000 units or 100 barrels of liquid.

[ta3_tank|image]


### TA3 Pump

The pump can be used to pump liquids from tanks or containers to other tanks or containers. The pump direction (arrow) must be observed for the pump. The yellow lines and connectors also make it possible to arrange several tanks on each side of the pump. However, the tanks must have the same content.

The TA3 pump pumps 4 units of liquid every two seconds.

Note 1: The pump must not be placed directly next to the tank. There must always be at least a piece of yellow pipe between them.

[ta3_pump|image]


### TA Liquid Filler

The liquid filler is used to transfer liquids between containers and tanks.

- If the liquid filler is placed under a tank and empty barrels are put into the liquid filler with a pusher or by hand, the contents of the tank are transferred to the barrels and the barrels can be removed from the outlet
- If the liquid filler is placed on a tank and if full containers are put into the liquid filler with a pusher or by hand, the content is transferred to the tank and the empty containers can be removed on the exit side

It should be noted that barrels can only be completely filled or emptied. If, for example, there are less than 10 units in the tank, this remainder must be removed with canisters or pumped empty.

[ta3_filler|image]

### TA4 Pipe

The yellow pipes are used for the transmission of gas and liquids.
The maximum pipe length is 100 m.

[ta3_pipe|image]

### TA3 Pipe Wall Entry Blocks

The blocks serve as wall openings for tubes, so that no holes remain open.

[ta3_pipe_wall_entry|image]

### TA Valve

There is a valve for the yellow pipes, which can be opened and closed with a click of the mouse.
The valve can also be controlled via on/off commands.

[ta3_valve|image]


## Oil Production

In order to run your generators and stoves with oil, you must first look for oil and build a derrick and then extract the oil.
TA3 oil explorer, TA3 oil drilling box and TA3 pump jack are used for this.

[techage_ta3|image]


### TA3 Oil Explorer

You can search for oil with the oil explorer. To do this, place the block on the floor and right-click to start the search. The oil explorer can be used above ground and underground at all depths.
The chat output shows you the depth to which oil was searched and how much oil (petroleum) was found.
You can click the block multiple times to search for oil in deeper areas. Oil fields range in size from 4,000 to 20,000 items.

If the search was unsuccessful, you have to move the block approx. 16 m further.
The oil explorer always searches for oil in the whole map block and below, in which it was set. A new search in the same map block (16x16 field) therefore makes no sense.

If oil is found, the location for the derrick is displayed. You have to erect the derrick within the area shown, it is best to mark the spot with a sign and protect the entire area against foreign players.

Don't give up looking for oil too quickly. If you're unlucky, it can take a long time to find an oil well.
It also makes no sense to search an area that another player has already searched. The chance of finding oil anywhere is the same for all players.

The oil explorer can always be used to search for oil.

[ta3_oilexplorer|image]


### TA3 Oil Drill Box

The oil drill box must be placed in the position indicated by the oil explorer. Drilling for oil elsewhere is pointless.
If the button on the oil drilling box is clicked, the derrick is erected above the box. This takes a few seconds.
The oil drilling box has 4 sides, at IN the drill pipe has to be delivered via pusher and at OUT the drilling material has to be removed. The oil drilling box must be supplied with power via one of the other two sides.

The oil drilling box drills to the oil field (1 meter in 16 s) and requires 16 ku of electricity.
Once the oil field has been reached, the derrick can be dismantled and the box removed.

[ta3_drillbox|image]


### TA3 Oil Pumpjack

The oil pump (pump-jack) must now be placed in the place of the oil drilling box. The oil pump also requires electricity (16 ku) and supplies one unit of oil every 8 s. The oil must be collected in a tank. To do this, the oil pump must be connected to the tank via yellow pipes.
Once all the oil has been pumped out, the oil pump can also be removed.

[ta3_pumpjack|image]


### TA3 Drill Pipe

The drill pipe is required for drilling. As many drill pipe items are required as the depth specified for the oil field. The drill pipe is useless after drilling, but it also cannot be dismantled and remains in the ground. However, there is a tool to remove the drill pipe blocks (-> Tools -> TA3 drill pipe pliers).

[ta3_drillbit|image]


### Oil tank

The oil tank is the large version of the TA3 tank (see liquids -> TA3 tank).

The large tank can hold 4000 units of oil, but also any other type of liquid.

[oiltank|image]



## Oil Transportation

### Oil transportation by Tank Carts

Tank carts can be used to transport oil from the oil well to the oil processing plant. A tank cart  can be filled or emptied directly using pumps. In both cases, the yellow pipes must be connected to the tank cart from above.

The following steps are necessary:

- Place the tank cart in front of the rail bumper block. The bumper block must not yet be programmed with a time so that the tank cart does not start automatically
- Connect the tank cart to the pump using yellow pipes
- Switch on the pump
- Program the bumper with a time (10 - 20 s)

This sequence must be observed on both sides (fill / empty).

[tank_cart | image]

### Oil transportation with barrels over Minecarts

Canisters and barrels can be loaded into the Minecarts. To do this, the oil must first be transferred to barrels. The oil barrels can be pushed directly into the Minecart with a pusher and tubes (see map). The empty barrels, which come back from the unloading station by Minecart, can be unloaded using a hopper, which is placed under the rail at the stop.

It is not possible with the hopper to both **unload the empty barrels and load the full barrels at a stop**. The hopper immediately unloads the full barrels. It is therefore advisable to set up 2 stations on the loading and unloading side and then program the Minecart accordingly using a recording run.

The plan shows how the oil can be pumped into a tank and filled into barrels via a liquid filler and loaded into Minecarts.

For the Minecarts to start again automatically, the bumper blocks must be configured with the station name and waiting time. 5 s are sufficient for unloading. However, since the pushers always go into standby for several seconds when there is no Minecart, a time of 15 or more seconds must be entered for loading.

[ta3_loading|plan]

###  Tank Cart

The tank truck is used to transport liquids. Like tanks, it can be filled with pumps or emptied. In both cases, the yellow tube must be connected to the tank truck from above.

100 units fit in the tank truck.

[tank_cart | image]

### Chest Cart

The chest cart is used to transport items. Like chests, it can be filled or emptied using a pusher.

4 stacks fit in the chest cart.

[chest_cart | image]


## Oil Processing

Oil is a mixture of substances and consists of many components. The oil can be broken down into its main components such as bitumen, fuel oil, naphtha, gasoline and propane gas via a distillation tower.
Further processing to end products takes place in the chemical reactor.

[techage_ta31|image]


### Distillation Tower

The distillation tower must be set up as in the plan at the top right.
The bitumen is drained off via the base block. The exit is on the back of the base block (note the direction of the arrow).
The "distillation tower" blocks with the numbers: 1, 2, 3, 2, 3, 2, 3, 4 are placed on this basic block
Fuel oil, naphtha and gasoline are drained from the openings from bottom to top. The propane gas is caught at the top.
All openings on the tower must be connected to tanks.
The reboiler must be connected to the "distillation tower 1" block.

The reboiler needs electricity (not shown in the plan)!


[ta3_distiller|plan]

#### Reboiler

The reboiler heats the oil to approx. 400 ° C. It largely evaporates and is fed into the distillation tower for cooling.

The reboiler requires 14 units of electricity and produces one unit of bitumen, fuel oil, naphtha, gasoline and propane every 16 s.
To do this, the reboiler must be supplied with oil via a pump.

[reboiler|image]


## Logic / Switching Blocks

In addition to the tubes for goods transport, as well as the gas and power pipes, there is also a wireless communication level through which blocks can exchange data with each other. No lines have to be drawn for this, the connection between transmitter and receiver is only made via the block number. All blocks that can participate in this communication show the block number as info text if you fix the block with the mouse cursor.
Which commands a block supports can be read out and displayed with the TechAge Info Tool (wrench).
The simplest commands supported by almost all blocks are:

- `on` - to turn on block / machine / lamp
- `off` - to turn off the block / machine / lamp

With the help of the TA3 Terminal, these commands can be tried out very easily. Suppose a signal lamp is number 123.
Then with:

    cmd 123 on

the lamp can be turned on and with:

    cmd 123 off

the lamp can be turned off again. These commands must be entered in the input field of the TA3 terminal.

Commands such as `on` and` off` are sent to the recipient without a response coming back. These commands can therefore be sent to several receivers at the same time, for example with a push button / switch, if several numbers are entered in the input field.

A command like `state` requests the status of a block. The block then sends its status back. This type of confirmed command can only be sent to one recipient at a time.
This command can also be tested with the TA3 terminal on a pusher, for example:

    cmd 123 state

Possible responses from the pusher are:
- `running` -> I'm working
- `stopped` -> switched off
- `standby` -> nothing to do because source inventory is empty
- `blocked` -> can't do anything because target inventory is full

This status and other information is also output when the wrench is clicked on the block.

[ta3_logic|image]


### TA3 Button / Switch
The button/switch sends `on` / `off` commands to the blocks that have been configured via the numbers.
The button/switch can be configured as a button or a switch. If it is configured as a button, the time between the `on` and `off` commands can be set.

The checkbox "public" can be used to set whether the button can be used by everyone (set) or only by the owner himself (not set).

Note: With the programmer, block numbers can be easily collected and configured.

[ta3_button|image]


### TA3 Logic Block

The TA3 logic block can be programmed in such a way that one or more input commands are linked to one output command and sent. This block can therefore replace various logic elements such as AND, OR, NOT, XOR etc. 
Input commands for the logic block are `on` /` off` commands.
Input commands are referenced via the number, e.g. `1234` for the command from the sender with the number 1234. 
The same applies to output commands.

A rule is structured as follows: 

```
<output> = on/off if <input-expression> is true
```

`<output>` is the block number to which the command should be sent.
`<input-expression>` is a boolean expression where input numbers are evaluated.



**Examples for the input expression**

Negate signal (NOT):

    1234 == off

Logical AND:

    1234 == on and 2345 == on

Logical OR:

    1234 == on or 2345 == on

The following operators are allowed:  `and`   `or`   `on`   `off`   `me`   `==`   `~=`   `(`   `)`

If the expression is true, a command is sent to the block with the `<output>` number. 
Up to four rules can be defined, whereby all rules are always checked when a command is received. 
The internal processing time for all commands is 100 ms. 

Your own node number can be referenced using the keyword `me`. This makes it possible for the block to send itself a command (flip-flop function). 

The blocking time defines a pause after a command, during which the logic block does not accept any further external commands. Commands received during the blocking period are thus discarded. The blocking time can be defined in seconds. 

[ta3_logic|image]


### TA3 Repeater

The repeater sends the received signal to all configured numbers.
This can make sense, for example, if you want to control many blocks at the same time. The repeater can be configured with the programmer, which is not possible with all blocks.

[ta3_repeater|image]


### TA3 Sequencer

The sequencer can send a series of `on` / `off` commands, whereby the interval between the commands must be specified in seconds. You can use it to make a lamp blink, for example.
Up to 8 commands can be configured, each with target block number and pending the next command.
The sequencer repeats the commands endlessly when "Run endless" is set.
If nothing is selected, only the specified time in seconds is waited for.

[ta3_sequencer|image]


### TA3 Timer

The timer can send commands time-controlled. The time, the target number(s) and the command itself can be specified for each command line. This means that lamps can be switched on in the evening and switched off again in the morning.

[ta3_timer|image]


### TA3 Terminal

The terminal is primarily used to test the command interface of other blocks (see "Logic / switching blocks").
You can also assign commands to keys and use the terminal productively.

    set <button-num> <button-text> <command>

With `set 1 ON cmd 123 on`, for example, user key 1 can be programmed with the command `cmd 123 on`. If the key is pressed, the command is sent and the response is output on the screen.

The terminal has the following local commands:
- `clear` clear screen
- `help` output a help page
- `pub` switch to public mode
- `priv` switch to private mode

In private mode, the terminal can only be used by players who can build at this location, i.e. who have protection rights.

In public mode, all players can use the preconfigured keys.

[ta3_terminal|image]


### TechAge Signal Lamp

The signal lamp can be switched on or off with the `on` / `off` command. This lamp does not need electricity and
can be colored with the airbrush tool of the mod Unified Dyes.

[ta3_signallamp|image]


### Door/Gate Blocks

With these blocks you can realize doors and gates that can be opened via commands (blocks disappear) and closed again. One door controller is required for each gate or door.

The appearance of the blocks can be adjusted via the block menu.
This makes it possible to realize secret doors that only open for certain players (with the help of the player detector).

[ta3_doorblock|image]

### TA3 Door Controller

The door controller is used to control the TA3 door/gate blocks. With the door controller, the numbers of the door/gate blocks must be entered. If an `on` / `off` command is sent to the door controller, this opens/closes the door or gate.

[ta3_doorcontroller|image]

### TA3 Door Controller II

The Door Controller II can remove and set all types of blocks. To teach in the Door Controller II, the "Record" button must be pressed. Then all blocks that should be part of the door / gate must be clicked. Then the "Done" button must be pressed. Up to 16 blocks can be selected. The removed blocks are saved in the controller's inventory. The function of the controller can be tested manually using the "Remove" or "Set" buttons. If an `on` /`off` command is sent to the Door Controller II, it removes or sets the blocks as well.

With `$send_cmnd(node_number, "exchange", 2)` individual blocks can be set, removed or replaced by other blocks from the inventory. 

With `$send_cmnd(node_number, "set", 2)` a block from the inventory can be set explicitly, as long as the inventory slot is not empty.

A block can be removed again with `$send_cmnd(node_number, "dig", 2)` if the inventory slot is empty. 

The name of the set block is returned with `$send_cmnd(node_number, "get", 2)`.

The slot number of the inventory (1 .. 16) must be passed as payload in all three cases.

This can also be used to simulate extendable stairs and the like. 

[ta3_doorcontroller|image]

### TA3 Sound Block

Different sounds can be played with the sound block. All sounds of the Mods Techage, Signs Bot, Hyperloop, Unified Inventory, TA4 Jetpack and Minetest Game are available.

The sounds can be selected and played via the menu and via command.

- Command `on` to play a sound
- Command `sound <idx>` to select a sound via the index
- Command `gain <volume>` to adjust the volume via the `<volume>` value (1 to 5). 

[ta3_soundblock|image]

### TA3 Mesecons Converter

The Mesecons converter is used to convert Techage on/off commands into Mesecons signals and vice versa.
To do this, one or more node numbers must be entered and the converter with Mesecons blocks
has to be connected via Mesecons cables. The Mesecons converter can also be configured with the programmer.
The Mesecons converter accepts up to 5 commands per second; it switches itself off at higher loads.

**This node only exists if the mod mesecons is active!**

[ta3_mesecons_converter|image]



## Detectors

Detectors scan their surroundings and send an `on` command when the search is recognized.

[ta3_nodedetector|image]


### TA3 Detector

The detector is a special tube block that detects when items are passed on through the tube. To do this, it must be connected to tubes on both sides. If items are pushed into the detector with a pusher, they are automatically passed on.
It sends an `on` when an item is recognized, followed by an `off` a second later.
Then further commands are blocked for 8 seconds.
The waiting time and the items that should trigger a command can be configured using the open-ended wrench menu. 


[ta3_detector|image]


### TA3 Cart Detector

The cart detector sends an `on` command if it has recognized a cart (Minecart) directly in front of it. In addition, the detector can also restart the cart when an `on` command is received.

The detector can also be programmed with its own number. In this case, he pushes all the wagons that stop near him (one block in all directions).

[ta3_cartdetector|image]


### TA3 Block Detector

The block detector sends an `on` command if it detects that blocks appear or disappear in front of it, but must be configured accordingly. After switching the detector back to the standard state (gray block), an `off` command is sent. Valid blocks are all types of blocks and plants, but not animals or players. The sensor range is 3 blocks / meter in the direction of the arrow.

[ta3_nodedetector|image]


### TA3 Player Detector

The player detector sends an `on` command if it detects a player within 4 m of the block. If the player leaves the area again, an `off` command is sent.
If the search should be limited to specific players, these player names can also be entered.

[ta3_playerdetector|image]

### TA3 Light Detector

The light detector sends an `on` command if the light level of the block above exceeds a certain level, which can be set through the right-click menu.
If you have a TA4 Lua Controller, you can get the exact light level with $get_cmd(num, 'light_level')

[ta3_lightdetector|image]

## TA3 Machines

TA3 has the same machines as TA2, only these are more powerful and require electricity instead of axis drive.
Therefore, only the different technical data are given below.

[ta3_grinder|image]


### TA3 Pusher

The function corresponds to that of TA2.
The processing power is 6 items every 2 s.

[ta3_pusher|image]


### TA3 Distributor

The function of the TA3 distributor corresponds to that of TA2.
The processing power is 12 items every 4 s.

[ta3_distributor|image]


### TA3 Autocrafter

The function corresponds to that of TA2.
The processing power is 2 items every 4 s. The autocrafter requires 6 ku of electricity.

[ta3_autocrafter|image]


### TA3 Electronic Fab

The function corresponds to that of TA2, only TA4 WLAN chips are produced here.
The processing power is one chip every 6 s. The block requires 12 ku of electricity for this.

[ta3_electronicfab|image]


### TA3 Quarry

The function corresponds to that of TA2.
The maximum depth is 40 meters. The quarry requires 12 ku of electricity.

[ta3_quarry|image]


### TA3 Gravel Sieve

The function corresponds to that of TA2.
The processing power is 2 items every 4 s. The block requires 4 ku of electricity.

[ta3_gravelsieve|image]


### TA3 Gravel Rinser

The function corresponds to that of TA2.
The probability is also the same as for TA2. The block also requires 3 ku of electricity.
But in contrast to TA2, the status of the TA3 block can be read (controller)

[ta3_gravelrinser|image]


### TA3 Grinder

The function corresponds to that of TA2.
The processing power is 2 items every 4 s. The block requires 6 ku of electricity.

[ta3_grinder|image]

### TA3 Injector

The injector is a TA3 pusher with special properties. It has a menu for configuration. Up to 8 items can be configured here. He only takes these items from a chest to pass them on to machines with recipes (autocrafter, industrial furnace and electronic fab).

When passing on, only one position in the inventory is used in the target machine. If, for example, only the first three entries are configured in the injector, only the first three storage locations in the machine's inventory are used. So that an overflow in the machine inventory is prevented.

The injector can also be switched to "pull mode". Then he only pulls items out of the chest from the positions that are defined in the configuration of the injector. In this case, item type and position must match. This allows to empty specific inventory entries of a chest. 

The processing power is up to 8 times one item every 4 seconds.

[ta3_injector|image]




## Tools

### Techage Info Tool

The Techage Info Tool (open-ended wrench) has several functions. It shows the time, position, temperature and biome when an unknown block is clicked on.
If you click on a TechAge block with command interface, all available data will be shown (see also "Logic / switching blocks").

With Shift + right click an extended menu can be opened for some blocks. Depending on the block, further data can be called up or special settings can be made here. In the case of a generator, for example, the charging curve/switch-off can be programmed. 

[ta3_end_wrench|image]

### TechAge Programmer

With the programmer, block numbers can be collected from several blocks with a right click and written into a block like a button / switch with a left click.
If you click in the air, the internal memory is deleted.

[ta3_programmer|image]

### TechAge Trowel / Trowel

The trowel is used for plastering power cables. See also "TA power cable".

[ta3_trowel|image]

### TA3 drill pipe wrench

This tool can be used to remove the drill pipe blocks if, for example, a tunnel is to pass through there.

[ta3_drill_pipe_wrench|image]

### Techage Screwdriver

The Techage Screwdriver serves as a replacement for the normal screwdriver. It has the following functions:

- Left click: turn the block to the left
- Right click: turn the visible side of the block upwards
- Shift + left click: save the alignment of the clicked block
- Shift + right click: apply the saved alignment to the clicked block

[ta3_screwdriver|image] 
