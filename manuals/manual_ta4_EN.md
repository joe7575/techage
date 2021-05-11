# TA4: Future

Renewable energy sources such as wind, sun and biofuels help you to leave the oil age. With modern technologies and intelligent machines you set out into the future.

[techage_ta4|image]


## Wind Turbine

A wind turbine always supplies electricity when there is wind. There is no wind in the game, but the mod simulates this by turning the wind turbines only in the morning (5:00 - 9:00) and in the evening (17:00 - 21:00). A wind turbine only supplies electricity if it is set up in a suitable location.

The TA wind power plants are pure offshore plants, which means that they have to be built in the sea. This means that wind turbines can only be build in a sea (occean) biome and that there must be sufficient water and a clear view around the mast.

To find a suitable spot, click on the water with the wrench (TechAge Info Tool). A chat message will show you whether this position is suitable for the mast of the wind turbine.

The current must be led from the rotor block down through the mast. First pull the power line up and then "plaster" the power cable with TA4 pillar blocks. A work platform can be built below. The plan on the right shows the structure in the upper part.

The wind turbine delivers 70 ku, but only 8 hours a day (see above).

[ta4_windturbine|plan]


### TA4 Wind Turbine

The wind turbine block (rotor) is the heart of the wind turbine. This block must be placed on top of the mast. Ideally at Y = 15, then you just stay within a map / forceload block.
After the block has been set, a check is carried out to determine whether all conditions for the operation of the wind turbine have been met. If all conditions are met, the rotor blades (wings) appear automatically when this block is set. Otherwise you will get an error message.

The check can be repeated by hitting the block. 

[ta4_windturbine|image]


### TA4 Wind Turbine Nacelle

This block must be placed on the black end of the wind turbine block.

[ta4_nacelle|image]


### TA4 Wind Turbine Signal Lamp

This flashing light is only for decorative purposes and can be placed on top of the wind turbine block.

[ta4_blinklamp|image]


### TA4 Pillar

This builds the mast for the wind turbine. However, these blocks are not set by hand but must be set with the help of a trowel, so that the power line to the mast tip is replaced with these blocks (see under TA power cable).

[ta4_pillar|image]


## Solar System

The solar system only produces electricity when the sun is shining. In the game this is every game day from 6:00 am to 6:00 pm.
The same power is always available during this time. After 6:00 p.m., the solar modules switch off completely.

The biome temperature is decisive for the performance of the solar modules. The hotter the temperature, the higher the yield.
The biome temperature can be determined with the Techage Info Tool (wrench). It typically fluctuates between 0 and 100:

- full power is available at 100
- at 50, half the power is available
- at 0 there is no service available

It is therefore advisable to look for hot steppes and deserts for the solar system.
The overhead lines are available for the transport of electricity.
However, hydrogen can also be produced, which can be transported and converted back into electricity at the destination.

The smallest unit in a solar system is two solar modules and one carrier module. The carrier module must be placed first, the two solar modules to the left and right next to it (not above!).

The plan on the right shows 3 units, each with two solar modules and one carrier module, connected to the inverter via red cables.

Solar modules supply DC voltage, which cannot be fed directly into the power grid. Therefore, the solar units must first be connected to the inverter via the red cable. This consists of two blocks, one for the red cable to the solar modules (DC) and one for the gray power cable to the power grid (AC).

The map area where the solar system is located must be fully loaded. This also applies to the direct position above the solar module, because the light intensity is regularly measured there. It is therefore advisable to first set a forceload block and then to place the modules within this area.

[ta4_solarplant|plan]


### TA4 Solar Module

The solar module must be placed on the carrier module. Two solar modules are always required.
In a pair, the solar modules perform up to 3 ku, depending on the temperature.
With the solar modules, care must be taken that they have full daylight and are not shaded by blocks or trees. This can be tested with the Info Tool (wrench).

[ta4_solarmodule|image]


### TA4 Solar Carrier Module

The carrier module is available in two heights (1m and 2m). Both are functionally identical.
The carrier modules can be placed directly next to one another and thus connected to form a row of modules. The connection to the inverter or to other module series must be made with the red low-voltage cables or the low-voltage junction boxes.

[ta4_solarcarrier|image]


### TA4 Solar Inverter

The inverter converts the solar power (DC) into alternating current (AC) so that it can be fed into the power grid.
An inverter can feed a maximum of 100 ku of electricity, which corresponds to 33 solar modules or more.

[ta4_solar_inverter|image]


### TA4 Low Power Cable

The low voltage cable is used to connect rows of solar modules to the inverter. The cable must not be used for other purposes.

The maximum cable length is 200 m.

[ta4_powercable|image]


### TA4 Low Voltage Junction Box

The junction box must be placed on the floor. It has only 4 connections (in the 4 directions).

[ta4_powerbox|image]


### TA4 Street Lamp Solar Cell

As the name suggests, the street lamp solar cell is used to power a street lamp. A solar cell can supply two lamps (1 ku). The solar cell stores the sun's energy during the day and delivers the electricity to the lamp at night. That means the lamp only glows in the dark.

This solar cell cannot be combined with the other solar modules.

[ta4_minicell|image]



## Thermal Energy Storage

The thermal energy store consists of a concrete shell (concrete blocks) filled with gravel. Three sizes of the storage are possible:

- Cover with 5x5x5 concrete blocks, filled with 27 gravel, storage capacity: 1/2 day at 60 ku
- Cover with 7x7x7 concrete blocks, filled with 125 gravel, storage capacity: 2.5 days at 60 ku
- Cover with 9x9x9 concrete blocks, filled with 343 gravel, storage capacity: 6.5 days at 60 ku

A window made of an obsidian glass block may be in the concrete shell. This must be placed fairly in the middle of the wall. Through this window you can see whether the storage is loaded more than 80%. In the plan on the right you can see the structure of TA4 heat exchanger consisting of 3 blocks, the TA4 turbine and the TA4 generator. Pay attention to the alignment of the heat exchanger (the arrow at block 1 must point to the turbine).

Contrary to the plan on the right, the connections on the storage block must be on the same level (arranged horizontally, i.e. not below and above). The pipe inlets (TA4 Pipe Inlet) must be exactly in the middle of the wall and face each other. The yellow TA4 pipes are used as steam pipes. The TA3 steam pipes cannot be used here.
Both the generator and the heat exchanger have a power connection and must be connected to the power grid.

In principle, the heat storage system works exactly the same as the batteries, only with much more storage capacity.
The heat accumulator can hold and deliver 60 ku.

In order for the heat storage system to work, all blocks (also the concrete shell and gravel) must be loaded using a forceload block.

[ta4_storagesystem|plan]


### TA4 Heat Exchanger

The heat exchanger consists of 3 parts that must be placed on top of each other, with the arrow of the first block pointing towards the turbine. The pipes must be built with the yellow TA4 pipes.
The heat exchanger must be connected to the power grid. The heat exchanger charges the energy store again when sufficient electricity is available and the energy storage is less than 95% charged. The heat exchanger takes up 60 ku. 

[ta4_heatexchanger|image]


### TA4 Turbine

The turbine is part of the energy storage. It must be placed next to the generator and connected to the heat exchanger via TA4 tubes as shown in the plan.

[ta4_turbine|image]


### TA4 Generator

The generator is used to generate electricity. Therefore, the generator must also be connected to the power grid.

The generator can deliver 60 ku.

[ta4_generator|image]


### TA4 Pipe Inlet

One pipe inlet block each must be installed on both sides of the storage block. The blocks must face each other exactly.

The pipe inlet blocks **cannot** be used as normal wall openings, use the TA3 pipe wall entry blocks instead.

[ta4_pipeinlet|image]


### TA4 Pipe

With TA4, the yellow pipes are used for the transmission of gas and liquids.
The maximum cable length is 100 m.

[ta4_pipe|image]

## Hydrogen

Electrolysis can be used to split electricity into hydrogen and oxygen. On the other hand, hydrogen can be converted back into electricity with oxygen from the air using a fuel cell.
This enables current peaks or an excess supply of electricity to be converted into hydrogen and thus stored.

In the game, electricity can be converted back into electricity via the fuel cell using the electrolyzer in hydrogen and hydrogen.
This means that electricity (in the form of hydrogen) can not only be stored in tanks, but also transported by means of the tank cart.

However, the conversion of electricity into hydrogen and back is lossy. Out of 100 units of electricity, only 95 units of electricity come out after the conversion to hydrogen and back.

[ta4_hydrogen|image]


### Electrolyzer

The electrolyzer converts electricity into hydrogen.
It must be powered from the left. On the right, hydrogen can be extracted via pipes and pumps.

The electrolyzer can draw up to 35 ku of electricity and then generates a hydrogen item every 4 s.
200 units of hydrogen fit into the electrolyzer.

[ta4_electrolyzer|image]


### Fuel Cell

The fuel cell converts hydrogen into electricity.
It must be supplied with hydrogen from the left by a pump. The power connection is on the right.

The fuel cell can deliver up to 34 ku of electricity and needs a hydrogen item every 4 s.

Usually the fuel cell works as a category 2 generator (like other storage systems). 
In this case, no other category 2 blocks such as the battery block can be charged. However, the fuel cell can also be used as a category 1 generator via the check box.

[ta4_fuelcell|image]


## Chemical Reactor

The reactor is used to process the ingredients obtained from the distillation tower or from other recipes into new products.
The plan on the left shows only one possible variant, since the arrangement of the silos and tanks depends on the recipe.

A reactor consists of:
- Various tanks and silos with the ingredients that are connected to the doser via pipes
- optionally a reactor base, which discharges the waste from the reactor (only necessary for recipes with two starting materials)
- the reactor stand, which must be placed on the base (if available). The stand has a power connection and draws 8 ku during operation.
- The reactor vessel that has to be placed on the reactor stand
- The filler pipe that must be placed on the reactor vessel
- The dosing device, which has to be connected to the tanks or silos and the filler pipe via pipes

Note 1: Liquids are only stored in tanks, solids and substances in powder form only in silos. This applies to ingredients and raw materials.

Note 2: Tanks or silos with different contents must not be connected to a pipe system. In contrast, several tanks or silos with the same content may hang in parallel on one line.

Cracking breaks long chains of hydrocarbons into short chains using a catalyst.
Gibbsite powder serves as a catalyst (is not consumed). It can be used to convert bitumen into fueloil, fueloil into naphtha and naphtha into gasoline.

In hydrogenation, pairs of hydrogen atoms are added to a molecule to convert short-chain hydrocarbons into long ones. 
Here iron powder is required as a catalyst (is not consumed). It can be used to convert gasoline into naphtha,
naphtha into fueloil, and fueloil into bitumen.


[ta4_reactor|plan]


### TA4 Doser

Part of the chemical reactor.
Pipes for input materials can be connected on all 4 sides of the doser. The materials for the reactor are discharged upwards.

The recipe can be set and the reactor started via the doser.

As with other machines:
- if the doser is in standby mode, one or more ingredients are missing
- if the doser is in the blocked state, the outlet tank or silo is full, defective or incorrectly connected

The doser does not need any electricity. A recipe is processed every 10 s.

[ta4_doser|image]

### TA4 Reactor

Part of the chemical reactor. The reactor has a inventory for the catalyst items (for cracking and hydrogenation recipes).

[ta4_reactor|image]


### TA4 Filler Pipe

Part of the chemical reactor. Must be placed on the reactor. If this does not work, remove the pipe at the position above and place it again.

[ta4_fillerpipe|image]


### TA4 Reactor Stand

Part of the chemical reactor. Here is also the power connection for the reactor. The reactor requires 8 ku of electricity.

The stand has two pipe connections, to the right for the starting product and down for the waste, such as red mud in aluminum production.

[ta4_reactorstand|image]


### TA4 Reactor Base

Part of the chemical reactor. Is required for the drainage of the waste product.

[ta4_reactorbase|image]


### TA4 Silo

Part of the chemical reactor. Is required to store substances in powder or granule form.

[ta4_silo|image]




## ICTA Controller

The ICTA controller (ICTA stands for "If Condition Then Action") is used to monitor and control machines. The controller can be used to read in data from machines and other blocks and, depending on this, switch other machines and blocks on / off.

Machine data is read in and blocks and machines are controlled using commands. Chapter TA3 -> Logic / switching blocks is important for understanding how commands work.

The controller requires a battery to operate. The display is used to output data, the signal tower to display errors.

[ta4_icta_controller|image]



### TA4 ICTA controller

The controller works on the basis of `IF <condition> THEN <action>` rules. Up to 8 rules can be created per controller.

Examples of rules are:

- If a distributor is `blocked`, the pusher in front of it should be switched off
- If a machine shows an error, this should be shown on the display

The controller checks these rules cyclically. To do this, a cycle time in seconds (`` Cycle / s '') must be specified for each rule (1..1000).

For rules that evaluate an on / off input, e.g. from a switch or detector, cycle time 0 must be specified. The value 0 means that this rule should always be carried out when the input signal has changed, e.g. the button has sent a new value.

All rules should only be executed as often as necessary. This has two advantages:

- the battery of the controller lasts longer (each controller needs a battery)
- the load for the server is lower (therefore fewer lags)

You have to set a delay time (`after/s`) for each action. If the action is to be carried out immediately, 0 must be entered.

The controller has its own help and information on all commands via the controller menu.

[ta4_icta_controller|image]

### Battery

The battery must be placed in close proximity to the controller, i.e. in one of the 26 positions around the controller.

[ta4_battery|image]

### TA4 Display

The display shows its number after placement. The display can be addressed via this number. Texts can be output on the display, whereby the display can display 5 lines and thus 5 different texts.

The display is updated at most once per second.

[ta4_display|image]

### TA4 Display XL

The TA4 Display XL is twice the size of the TA4 display.

The display is updated every two seconds at most.

[ta4_displayXL|image]


### TA4 Signal Tower

The signal tower can display red, green and orange. A combination of the 3 colors is not possible.

[ta4_signaltower|image]



## TA4 Lua Controller

As the name suggests, the Lua controller must be programmed in the Lua programming language. You should also be able to speak some English. The manual in English is here available:

https://github.com/joe7575/techage/blob/master/manuals/ta4_lua_controller_EN.md

The Lua controller also requires a battery. The battery must be placed in close proximity to the controller, i.e. in one of the 26 positions around the controller.

[ta4_lua_controller|image]

### TA4 Lua Server

The server is used for the central storage of data from several Lua controllers. It also saves the data after a server restart.

[ta4_lua_server|image]

### TA4 Sensor Box / Chest

The TA4 sensor box is used to set up automatic warehouses or vending machines in conjunction with the Lua controller.
If something is put into the box or removed, or one of the "F1" / "F2" keys is pressed, an event signal is sent to the Lua controller.
The sensor box supports the following commands:

- The status of the box can be queried via `state = $send_cmnd(<num>, "state")`. Possible answers are: "empty", "loaded", "full"
- The last player action can be queried via `name, action = $send_cmnd(<num>, "action")`. `name` is the player name. One of the following is returned as `action`: "put", "take", "f1", "f2".
- The contents of the box can be read out via `stacks = $send_cmnd(<num>, "stacks")`. See: https://github.com/joe7575/techage/blob/master/manuals/ta4_lua_controller_EN.md#sensor-chest
- Via `$send_cmnd(<num>, "text", "press both buttons and\nput something into the chest")` the text can be set in the menu of the sensor box.

The checkbox "Allow public chest access" can be used to set whether the box can be used by everyone or only by players who have access/protection rights here.

[ta4_sensor_chest|image]

### TA4 Lua Controller Terminal

The terminal is used for input / output for the Lua controller.

[ta4_terminal|image]



## TA4 Logic/Switching Modules

### TA4 Button/Switch

Only the appearance of the TA4 button/switch has changed. The functionality is the same as with the TA3 button/switch.

[ta4_button|image]

### TA4 Player Detector

Only the appearance of the TA4 player detector has changed. The functionality is the same as with the TA3 player detector.

[ta4_playerdetector|image]

### TA4 State Collector

[ta4_collector|image]

The status collector queries all configured machines in turn for the status. If one of the machines has reached or exceeded a preconfigured status, an "on" command is sent. For example, many machines can be easily monitored for faults from a Lua controller.

### TA4 Detector

The functionality is the same as for the TA3 detector. In addition, the detector counts the items passed on.
This counter can be queried with the 'count' command and reset with 'reset'.

[ta4_detector|image]


## TA4 Lamps

TA4 contains a series of powerful lamps that enable better illumination or take on special tasks.

### TA4 LED Grow Light

The TA4 LED grow light enables fast and vigorous growth of all plants from the `farming` mod. The lamp illuminates a 3x3 field, so that plants can also be grown underground.
The lamp must be placed one block above the ground in the middle of the 3x3 field.

The lamp can also be used to grow flowers. If the lamp is placed over a 3x3 flower bed made of "Garden Soil" (Mod `compost`), the flowers grow there automatically (above and below ground).

You can harvest the flowers with the Signs Bot, which also has a corresponding sign that must be placed in front of the flower field.

The lamp requires 1 ku of electricity.

[ta4_growlight|image]

### TA4 Street Lamp

The TA4 LED street lamp is a lamp with particularly strong illumination. The lamp consists of the lamp housing, lamp arm and lamp pole blocks.

The current must be led from below through the mast up to the lamp housing. First pull the power line up and then "plaster" the power cable with lamp pole blocks.

The lamp requires 1 ku of electricity.

[ta4_streetlamp|image]

### TA4 LED Industrial Lamp

The TA4 LED industrial lamp is a lamp with particularly strong illumination. The lamp must be powered from above.

The lamp requires 1 ku of electricity.

[ta4_industriallamp|image]




## TA4 Liquid Filter

The liquid filter filters red mud.
A part of the red mud becomes lye, which can be collected at the bottom in a tank.
The other part becomes desert cobblestone and clutters the filter material.
If the filter is too clogged, it has to be cleaned and re-filled.
The filter consists of a base layer, 7 identical filter layers and a filling layer at the top.

[ta4_liquid_filter|image]

### Base Layer

You can see the structure of this layer in the plan.

The lye is collected in the tank.

[ta4_liquid_filter_base|plan]

### Gravel Layer

This layer has to be filled with gravel as shown in the plan.
In total, there must be seven layers of gravel.
The filter will become cluttered over time, so that it has to be cleaned and re-filled.

[ta4_liquid_filter_gravel|plan]

### Filling Layer

This layer is used to fill the filter with red mud.
The red mud must be pumped into the filler pipe.

[ta4_liquid_filter_top|plan]




## More TA4 Blocks

### TA4 Tank

See TA3 tank.

A TA4 tank can hold 2000 units or 200 barrels of liquid.

[ta4_tank|image]

### TA4 Pump

See TA3 pump.

The TA4 pump pumps 8 units of liquid every two seconds.

[ta4_pump|image]

### TA4 Furnace Heater

With TA4, the industrial furnace also has its electrical heating. The oil burner and the blower can be replaced with the heater.

The heater requires 14 ku of electricity.

[ta4_furnaceheater|image]

### TA4 Water Pump (deprecated)

This block can no longer be crafted and will be replaced by the TA4 water inlet block. 

### TA4 Water Inlet

Some recipes require water. The water must be pumped from the sea with a pump (water at y = 1). A "pool" made up of a few water blocks is not sufficient for this! 

To do this, the water inlet block must be placed in the water and connected to the pump via pipes. If the block is placed in the water, it must be ensured that there is water under the block (water must be at least 2 blocks deep). 

[ta4_waterinlet|image]

### TA4 Tube

TA4 also has its own tubes in the TA4 design. These can be used like standard tubes.
But: TA4 pushers and TA4 distributors only achieve their full performance when used with TA4 tubes.

[ta4_tube|image]

### TA4 Pusher

The function basically corresponds to that of TA2 / TA3. In addition, a menu can be used to configure which objects should be taken from a TA4 chest and transported further.
The processing power is 12 items every 2 s, if TA4 tubes are used on both sides. Otherwise there are only 6 items every 2 s.

The TA4 pusher has two additional commands for the Lua controller:

- `config` is used to configure the pusher, analogous to manual configuration via the menu.
  Example: `$send_cmnd(1234, "config", "default: dirt")`
- `pull` is used to send an order to the pusher:
  Example: `$send_cmnd(1234, "pull", "default: dirt 8")`
  Values ​​from 1 to 12 are permitted as numbers. Then the pusher goes back to `stopped` mode and sends an" off "command back to the transmitter of the" pull "command.

[ta4_pusher|image]

### TA4 Chest

The function corresponds to that of TA3. The chest can hold more content.

In addition, the TA4 chest has a shadow inventory for configuration. Here certain stack locations can be pre-assigned with an item. Pre-assigned inventory stacks are only filled with these items when filling. A TA4 pusher or TA4 injector with the appropriate configuration is required to empty a pre-assigned inventory stacks.

[ta4_chest|image]

### TA4 8x2000 Chest

The TA4 8x2000 chest does not have a normal inventory like other chest, but has 8 stores, whereby each store can hold up to 2000 items of one sort. The orange buttons can be used to move items to or from the store. The box can also be filled or emptied with a pusher (TA2, TA3 or TA4) as usual.

If the chest is filled with a pusher, all stores fill from left to right. If all 8 stores are full and no further items can be added, further items are rejected.

**Row function**

Several TA4 8x2000 chests can be connected to a large chest with more content. To do this, the chests must be placed in a row one after the other.

First the front chest must be placed, then the stacking chests are placed behind with the same direction of view (all boxes have the front towards the player). With 2 chests in a row, the size increases to 8x4000, etc.

The rows of chests can no longer be removed. There are two ways to dismantle the chests:

- Empty and remove the front chest. This unlocks the next chest and can be removed.
- Empty the front chest so far that all stores contain a maximum of 2000 items. This unlocks the next chest and can be removed.

The chests have an "order" checkbox. If this checkbox is activated, the stores are no longer completely emptied by a pusher. The last item remains in the store as a default. This results in a fixed assignment of items to storage locations.

The chest can only be used by players who can build at this location, i.e. who have protection rights. It does not matter who sets the chest.

The chest has an additional command for the Lua controller:

- `count` is used to request how many items are in the chest.
  Example 1: `$send_cmnd(CHEST, "count")` -> Sum of items across all 8 stores
  Example 2: `$send_cmnd(CHEST, "count", 2)` -> number of items in store 2 (second from left)

[ta4_8x2000_chest|image]



### TA4 Distributor

The function corresponds to that of TA2.
The processing power is 24 items every 4 s, provided TA4 tubes are used on all sides. Otherwise there are only 12 items every 4 s.

[ta4_distributor|image]

### TA4 High Performance Distributor

The function corresponds to that of the normal TA4 distributor, with two differences:
The processing power is 36 items every 4 s, provided TA4 tubes are used on all sides. Otherwise there are only 18 items every 4 s.
Furthermore, up to 8 items can be configured per direction.

[ta4_high_performance_distributor|image]

### TA4 Gravel Sieve

The function corresponds to that of TA2.
The processing power is 4 items every 4 s. The block requires 5 ku of electricity.

[ta4_gravelsieve|image]

### TA4 Grinder

The function corresponds to that of TA2.
The processing power is 4 items every 4 s. The block requires 9 ku of electricity.

[ta4_grinder|image]

### TA4 Quarry

The function largely corresponds to that of TA2.

In addition, the hole size can be set between 3x3 and 11x11 blocks.
The maximum depth is 80 meters. The quarry requires 14 ku of electricity.

[ta4_quarry|image]

### TA4 Electronic Fab

The function corresponds to that of TA2, only different chips are produced here.
The processing power is one chip every 6 s. The block requires 12 ku of electricity for this.

[ta4_electronicfab|image]

### TA4 Injector

The function corresponds to that of TA3.

The processing power is up to 8 times four items every 4 seconds.

[ta4_injector|image]

### TA4 Recycler

The recycler is a machine that processes all Techage recipes backwards, i.e. it can dismantle machines and blocks back into their components. 

The machine can disassemble pretty much any Techage and Hyperloop blocks. But not all recipe items/materials can be recycled:

- Wood turns into sticks
- Stone turns into sand or gravel
- Semiconductors / chips cannot be recycled 
- Tools cannot be recycled

The processing power is one item every 8 s.  The block requires 16 ku of electricity for this.

[ta4_recycler|image] 

### TA4 Laser

The TA4 laser is used for wireless power transmission. Two blocks are required for this: TA4 Laser Beam Emitter and TA4 Laser Beam Receiver. There must be an air gap between the two blocks so that the laser beam can be built up from the emitter to the receiver. First the emitter must be placed. This immediately switches on the laser beam and shows possible positions of the receiver. Possible positions for the receiver are also output via a chat message. 

With the laser, distances of up to 96 blocks can be bridged. Once the connection has been established (no current has to flow), this is indicated via the info text of the emitter and also of the receiver. 

The laser blocks themselves do not require any electricity.

[ta4_laser|image]