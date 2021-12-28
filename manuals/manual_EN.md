# Tech Age Mod

Tech Age is a technology mod with 5 development stages:

TA1: Iron Age
Use tools and aids such as coal burners, coal burners, gravel sieves, hammers and hoppers to mine and process the necessary ores and metals.

TA2: Steam Age
Build a steam engine with drive axles and use it to operate your first ore processing machines.

TA3: Oil Age
Find and extract oil, built railways for oil transportation. A power plant provides the necessary electricity for your machines. Electric light illuminates your industrial plants.

TA4: Present
Renewable energy sources such as wind, sun and biofuels help you to leave the oil age. With modern technologies and intelligent machines you set out into the future.

TA5: Future
Machines to overcome space and time, new sources of energy and other achievements shape your life.


Note: With a click on the plus sign you get into the subchapters of this manual.

[techage_ta4|image]



## Hints

This documentation is available both "ingame" (block construction plan) and on GitHub as MD files.

- Link: https://github.com/joe7575/techage/wiki

The construction plans (diagrams) for the construction of the machines and the pictures are only available in-game.

With Tech Age you have to start over. You can only create TA2 blocks with the items from TA1, for TA3 you need the results from TA2, etc.

In TA2, the machines only run with drive axes.

From TA3, the machines run on electricity and have a communication interface for remote control.

TA4 adds more power sources, but also higher logistical challenges (power lines, item transport).



## Changes from version 1.0

From V1.0 (07/17/2021) the following has changed:

- The algorithm for calculating the power distribution has changed. This makes energy storage systems more important. These compensate for fluctuations, which is important in larger networks with several generators.
- For this reason TA2 got its own energy storage.
- The battery blocks from TA3 also serve as energy storage. Their functionality has been adapted accordingly.
- The TA4 storage system has been revised. The heat heat exchanger have been given a new number because the functionality has been moved from the lower to the middle block. If these were remotely controlled, the node number must be adapted. The generators no longer have their own menu, but are only switched on / off via the heat exchanger. The heat exchanger and generator must now be connected to the same network!
- Several power grids can now be coupled via a TA4 transformer blocks.
- A TA4 electricity meter block for sub-networks is also new.
- At least one battery block or a storage system in each network


### Tips on switching

Many more blocks have received minor changes. It is therefore possible that machines or systems do not start up again immediately after the changeover. In the event of malfunctions, the following tips will help:

- Switch machines off and on again
- remove a power cable block and put it back in place
- remove the block completely and put it back in place



## Ores and Minerals

Techage adds some new items to the game:

- Meridium - an alloy for the production of luminous tools in TA1
- Usmium - an ore that is mined in TA2 and needed for TA3
- Baborium - a metal that is needed for recipes in TA3
- Petroleum - is needed in TA3
- Bauxite - an aluminum ore that is needed in TA4 to produce aluminum
- Basalt - arises when water and lave touch


### Meridium

Meridium is an alloy of steel and mesecons crystals. Meridium ingots can be made with the coal burner from steel and mesecons crystals. Meridium glows in the dark. Tools made of Meridium also light up and are therefore very helpful in underground mining.

[meridium|image]


### Usmium

Usmium only occurs as nuggets and can only be obtained by washing gravel with the TA2/TA3 gravel washing system.

[usmium|image]


### Baborium

Baborium is only extracted in underground mining. Baborium can only be found in stone at an altitude between -250 and -340 meters.
Baborium can only be melted in the TA3 Industrial Furnace.


[baborium|image]


### Petroleum

Petroleum can only be found with the help of the Explorer and extracted with the help of appropriate TA3 machines. See TA3.

[oil|image]


### Bauxite

Bauxite is only extracted in underground mining. Bauxite is only found in stone at a height between -50 and -500 meters.
It is required for the production of aluminum, which is mainly used in TA4.

[bauxite|image]


### Basalt

Basalt is only created when lava and water come together.
The best thing to do is to set up a system where a lava and a water source flow together.
Basalt is formed where both liquids meet.
You can build an automated basalt generator with the Sign Bot.

[basalt|image]


## History

- 28.09.2019: Solar system added
- 05.10.2019: Data on the solar system and description of the inverter and the power terminal changed
- 18.11.2019: Chapter for ores, reactor, aluminum, silo, bauxite, furnace heating, gravel washing system added
- 22.02.2020: corrections and chapters on the update
- 29.02.2020: ICTA controller added and further corrections
- 14.03.2020 Lua controller added and further corrections
- 22.03.2020 More TA4 blocks added

