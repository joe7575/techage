# TA2: Steam Age

TA2 is about building and operating the first machines for processing ores. Some machines have to be driven via drive axles. To do this, you need to build a steam engine and heat it with coal or charcoal.

In TA2 there is also a gravel rinser that can be used to wash out rare ores such as Usmium nuggets. You will need these nuggets later for further recipes.

[techage_ta2|image]

## Steam Engine

The steam engine consists of several blocks and must be assembled as shown in the plan on the right. The blocks TA2 fire box, TA2 boiler top, TA2 boiler bottom, TA2 cylinder, TA2 flywheel and steam pipes are required.

In addition, drive axles and gear blocks are required for changing direction. The flywheel must be connected to all machines that have to be driven via the drive axles.

Always pay attention to the alignment of all blocks when placing:

- Cylinder on the left, flywheel on the right
- Connect steam pipes where there is a corresponding hole
- Drive axle on flywheel only on the right
- In all machines, the drive axles can be connected on all sides, which is not occupied by other functions, such as the IN and OUT holes in the grinder and sieve.

The boiler must be filled with water. Fill up to 10 buckets of water in the boiler.
The fire box must be filled with coal or charcoal.
When the water is hot (temperature display at the top), the steam engine can be started on the flywheel.

The steam engine has a capacity of 25 ku, so it can drive several machines at the same time.

[steamengine|plan]


### TA2 Firebox

Part of the steam engine.

The fire box must be filled with coal or charcoal. The burning time depends on the power demanded by the steam engine. Coal burns for 32 s and charcoal for 96 s under full load.

[ta2_firebox|image]


### TA2 Boiler

Part of the steam engine. Must be filled with water. This is done by clicking on the boiler with a water bucket. When there is no more water or the temperature drops too low, the steam engine switches off.

[ta2_boiler|image]


### TA2 Cylinder

Part of the steam engine.

[ta2_cylinder|image]


### TA2 Flywheel

Drive part of the steam engine. The flywheel must be connected to the machines via drive axles.

[ta2_flywheel|image]


### TA2 Steam Pipes

Part of the steam engine. The boiler must be connected to the cylinder via the steam pipes. The steam pipe has no branches, the maximum length is 12 m (blocks).

[ta2_steampipe|image]


### TA2 Drive Axle / TA2 Gearbox

The drive axles are used to transmit power from the steam engine to other machines. The maximum length of a drive axis is 10 blocks. With TA2 Gearboxes, larger distances can be bridged, and branches and changes of direction can be realized.

[ta2_driveaxle|image]


### TA2 Power Generator

The TA2 Power Generator is required to operate lamps or other power consumers on a steam engine. The TA2 Power Generator has to be connected to drive axles on one side and then supplies electricity on the other side.

If the Power Generator is not supplied with sufficient power, it goes into an error state and must be reactivated with a right-click.

The Power Generator takes max. 25 ku of axle power and provides on the other side max. 24 ku as electricity. So he consumes one ku for the conversion.

[ta2_generator|image]

## TA2 energy storage

For larger systems with several steam engines or many driven machines, an energy storage system is recommended. The energy storage at TA2 works with position energy. For this purpose, ballast (stones, gravel, sand) is pulled up in a chest with the help of a cable winch. If there is excess energy in the axis network, the chest is pulled upwards. If more energy is required in the short term than the steam engine can supply, the energy store releases the stored energy again and the weight chest moves down again. 
The energy storage consists of several blocks and must be assembled as shown in the plan on the right. 
In order to achieve the maximum storage capacity, the chest must be completely filled with weights and the mast including the two gear boxes must be 12 blocks high. Smaller structures are also possible.

[ta2_storage|plan]



###  TA2 Winch

The cable winch must be connected to a gear box and can absorb excess energy and thus pull a weight chest upwards. The maximum rope length is 10 blocks. 

[ta2_winch|image]



### TA2 Weight Chest

This chest must be placed under the winch with a distance of up to 10 blocks and filled with cobblestone, gravel or sand. If the minimum weight of a stack (99+ items) is reached and there is excess energy, the box is automatically connected to the winch via a rope and pulled up. 

[ta2_weight_chest|image]



## Push and sort items

In order to transport objects from one processing station to the next, pushers and tubes are used. See plan.

[itemtransport|plan]


### TechAge Tube

Two machines can be connected with the help of a pusher and a tube. Tubes have no branches. The maximum length is 200 m (blocks).

Alternatively, tubes can be placed using the Shift key. This allows, for example, tubes to be laid in parallel without them accidentally connecting.

The transport capacity of a tube is unlimited and only limited by the pusher.

[tube|image]

### Tube Concentrator

Several tubes can be combined into one tube via the concentrator. The direction in which all items are passed on is marked with an arrow. 

[concentrator|image]

### TA2 Pusher

A pusher is able to pull items out of boxes or machines and push them into other boxes or machines. In other words, there must be one and exactly one pusher between two blocks with inventory. Multiple pushers in a row are not possible.
In the opposite direction, however, a pusher is permeable for items, so that a box can be filled via a tube and also taught.

A pusher goes into the "standby" state if it has no items to push. If the output is blocked or the recipient's inventory is full, the pusher goes into the "blocked" state. The pusher automatically comes out of both states after a few seconds if the situation has changed.

The processing power of a TA2 pusher is 2 items every 2 s.

[ta2_pusher|image]


### TA2 Distributor

The distributor is able to transport the items from his inventory sorted in up to four directions. To do this, the distributor must be configured accordingly.

The distributor has a menu with 4 filters with different colors, corresponding to the 4 outputs. If an output is to be used, the corresponding filter must be activated via the "on" checkbox. All items that are configured for this filter are output via the assigned output. If a filter is activated without items being configured, we are talking about an "unconfigured", open output.

**Attention: The distributor is also a pusher at its output sides. Therefore, never pull items out of the distributor with a pusher!**

There are two operating modes for a non-configured output:

1) Output all items that cannot be output to any other exit, even if they are blocked.

2) Only output the items that have not been configured for any other filter.

In the first case, all items are always forwarded and the distributor does not run full. In the second case, items are held back and the distributor can run full and then block.

The operating mode can be set using the "blocking mode" checkbox.

The processing power of a TA2 distributor is 4 items every 2 s, whereby the distributor tries to distribute the 4 items to the open outputs.

If the same item is configured multiple times in one filter, the long term distribution ratio will be influenced accordingly.

Please note that the distribution is a probabilistic process. This means that the distribution rations won't be matched exactly, but only in the long term.

The maximum stack size in the filters is 12; in total, not more than 36 items can be configured.

[ta2_distributor|image]


## Gravel washer

The gravel washer is a more complex machine with the goal of washing Usmium nuggets out of sieved gravel. A TA2 rinser with axis drive, a hopper, a chest and running water are required for the installation.

Structure from left to right (see also plan):

* A dirt block, on top of it the water source, surrounded on 3 sides by e.g. glass blocks
* next to it the gravel rinser, if necessary with tube connections for the gravel delivery and removal
* then the hopper with chest

The whole thing is surrounded by further glass blocks, so that the water flows over the gravel rinser and the hopper and rinsed-out nuggets can be collected again by the hopper.

[gravelrinser|plan]


### TA2 Gravel Rinser

The gravel washer is able to rinse out the Usmium and copper ores from gravel that has already been sieved, provided that this is flushed with water.

Whether the Gravel Rinser works correctly can be tested with sticks if these are placed in the inventory of the Gravel Rinser. These must be rinsed out individually and caught by the hopper.

The processing power is one gravel item every 2 s. The gravel washer needs 3 ku of energy.

[ta2_rinser|image]


## Dig stone, grind and sieve

Crushing, grinding and sieving of cobblestone is used to extract ores. Sieved gravel can also be used for other purposes. Quarry, grinder and sieve must be driven and thus installed near a steam engine.

[ta2_grinder|image]


### TA2 Quarry

The quarry is used to remove stones and other materials from the underground. The quarry digs a 5x5 block hole. The depth is adjustable.
The processing power is one block every 4 s. The quarry needs 10 ku of energy. The maximum depth is 20 meters. For greater depths see TA3 / TA4.

[ta2_quarry|image]


### TA2 Grinder

The grinder is able to grind various rocks, but also wood and other items.
The processing power is one item every 4 s. The grinder needs 4 ku of energy.

[ta2_grinder|image]


### TA2 Gravel Sieve

The gravel sieve is able to sieve gravel to extract ores. The result is partially "sieved gravel", which cannot be sieved again.
The processing power is one item every 4 s. The gravel sieve requires 3 ku of energy.

[ta2_gravelsieve|image]


## Produce Items

TA2 machines can not only extract ores, but also produce objects.


### TA2 Autocrafter

The autocrafter is used for the automatic production of goods. Everything that the player can produce via the "Crafting Grid" can also be done by the autocrafter. To do this, the recipe must be entered in the menu of the autocrafter and the necessary ingredients added.

Ingredients and manufactured goods can be transported in and out of the block via tubes and pushers.

The processing power is one item every 4 s. The autocrafter requires 4 ku of energy.

[ta2_autocrafter|image]


### TA2 Electronic Fab

The electronic fab is a special machine and can only be used for the production of vacuum tubes. Vacuum tubes are required for TA3 machines and blocks.

The processing power is one vacuum tube every 6 s. The electronic fab requires 8 ku of energy.

[ta2_electronicfab|image]


## Other blocks

### TA2 Liquid Sampler

Some recipes require water. So that these recipes can also be processed automatically with the autocrafter, water must be provided in buckets. The liquid sampler is used for this. He needs empty buckets and has to be put in the water.

The processing capacity is one water bucket every 8 s. The liquid sampler requires 3 ku of energy.

[ta2_liquidsampler|image]


### TA2 Protected Chest

The protected chest can only be used by players who can build at this location, i.e. who have protection rights. It does not matter who sets the chest.

[ta2_chest|image]


### Techage Forceload Block

Minetest divides the map into so-called map blocks. These are cubes with an edge length of 16x16x16 blocks. Such a map block is always loaded completely by the server, but only the blocks around a player are loaded (approx. 2-3 blocks in all directions). In the player's direction of view, there are also more map blocks. Only this part of the world is active and only here do plants and trees grow or the machines run.

With a forceload block you can force the map block in which the forceload block is located to remain loaded as long as you are on the server. When all your farms and machines are covered with Forceload blocks, everything is always running.

The map blocks with their coordinates are predefined, e.g. (0,0,0) to (15,15,15), or (16,16,16) to (31,31,31).
You can move a forceload block within a map block as you like, the position of the map block remains unchanged.

[ta2_forceload|image]

