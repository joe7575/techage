# Tech Age [techage] (Minetest 5.4+)

Tech Age, a mod to go through 5 tech ages in search of wealth and power.

![screenshot](https://github.com/joe7575/techage/blob/master/screenshot.png)


Important facts:
- techage is not backwards compatible and cannot be installed on a server together with TechPack
- techage is significantly more extensive, since additional mods are integrated
- techage represents 5 technological ages:
  - Iron Age (TA1) - simple tools like coal pile, coal burner, gravel sieve, hammer for getting ores and making goods
  - Steam Age (TA2) - Simple machines that are powered by steam engines and drive axles
  - Oil Age (TA3) - More modern machines that are powered by electricity.  
  - Present (TA4) - Electricity from renewable energy sources such as sun and wind.
  - Future (TA5) - Machines to overcome space and time, new sources of energy and other achievements.
- Since the levels build on each other, all ages have to be run through one after the other

In contrast to TechPack, the resources are more limited and it is much more difficult to pass all levels.
(no endless ore generation by means of cobble generators)

**Techage blocks store information outside of the block. This is for performance reasons.
If you move, place, or remove blocks with any tool, at best, only the information is lost.
In the worst case, the server crashes.**

[Manuals](https://github.com/joe7575/techage/wiki)


### License
Copyright (C) 2019-2025 Joachim Stolberg
Code: Licensed under the GNU AGPL version 3 or later. See LICENSE.txt  
Textures: CC BY-SA 3.0

The TA1 mill sound is from https://freesound.org/people/JustinBW/sounds/70200/
The TA1 watermill sound is from https://freesound.org/people/bmoreno/sounds/164182/

Many thanks to Thomas-S, niklp09, and others for their contributions


### Dependencies  
Required: default, doors, bucket, stairs, screwdriver, basic_materials, tubelib2, networks, minecart, lcdlib, safer_lua, doclib  
Recommended: signs_bot, hyperloop, compost, techpack_stairway, autobahn, nanobasic  
Optional: unified_inventory, wielded_light, unifieddyes, lua-mashal, lsqlite3, moreores, ethereal, mesecon, everness


The mods `default`, `doors`, `bucket`, `stairs`, and `screwdriver` are part of Minetest Game.

`basic_materials` will be found here: https://content.minetest.net/

The following mods in the newest version have to be downloaded directly from GitHub:
* [tubelib2](https://github.com/joe7575/tubelib2)
* [networks](https://github.com/joe7575/networks)
* [minecart](https://github.com/joe7575/minecart)
* [lcdlib](https://github.com/joe7575/lcdlib)
* [safer_lua](https://github.com/joe7575/safer_lua)
* [doclib](https://github.com/joe7575/doclib)

It is highly recommended that you install the following mods, too:

* [signs_bot](https://github.com/joe7575/signs_bot): For many automation tasks in TA3/TA4 like farming, mining, and item transportation
* [hyperloop](https://github.com/joe7575/Minetest-Hyperloop): Used as passenger transportation system in TA4
* [compost](https://github.com/joe7575/compost): The garden soil is needed for the TA4 LED Grow Light based flower bed
* [techpack_stairway](https://github.com/joe7575/techpack_stairway): Ladders, stairways, and bridges for your machines
* [autobahn](https://github.com/joe7575/autobahn): Street blocks and slopes with stripes for faster traveling
* [ta4_jetpack](https://github.com/joe7575/ta4_jetpack): A Jetpack with hydrogen as fuel and TA4 recipe
* [nanobasic](https://github.com/joe7575/nanobasic-mod): To upgrade the TA3 terminal to a BASIC computer

More recommended Techage related mods by other authors:

* [ta4_addons](https://github.com/Thomas--S/ta4_addons) from Thomas--S: A Touchscreen for the Lua controller
* [ts_vehicles](https://github.com/Thomas--S/ts_vehicles) from Thomas--S: A mod to provide cars and other vehicles for Minetest.
* [ta_apiary](https://gitlab.com/lesya_minetest_mods/ta_apiary) from Olesya Sibidanova: TechAge Machines for beekeeping

For large servers with many players, the following packages are recommended:

* lua-mashal for faster serialization/deserialization of data
* lsqlite3 for storing node and network data

The packages have to be installed via [luarocks](https://luarocks.org/):

    luarocks --lua-version 5.1 install lsqlite3
    luarocks --lua-version 5.1 install lua-marshal

To enable these `unsafe` packages, add 'techage' and 'lua-marshal'
to the list of trusted mods in `minetest.conf`:

    secure.trusted_mods = techage,lua-marshal

and add the following line to your `world.mt` or `minetest.conf`:

    techage_use_sqlite = true

Available worlds will be converted to 'lsqlite3', but there is no way back, so:

**Never disable 'lsqlite3' for a world that has already been used!**

### History

**2025-03-14 V1.23**

- Add Move Controller II
- Improve Basic Terminal
- Improve Lua Controller
- Improve Fly Controller
- Fix several issues

**2025-02-14 V1.22**

- Remove Lua controller batteries
- Change the Lua controller from time-based to credit-based runtime control

**2025-02-09 V1.21**

- Add TA3 monitor and new TA4 dislays with fixed font (requires Minetest 5.7.0 or newer)

**2025-01-08 V1.20**

- Add Traffic Lights and accesories
- Add TA4 water remover device
- Improve door and fly controller
- Fix several issues

**2024-12-31 V1.19**

- Add Everness support #187 (ore sieving)
- Add BASIC mode to TA3 terminal (requires proper installation of nanobasic)
- Improve russian translation (z-op)
- Many bug fixes by Niklp09, joe7575, and others
- Add pre-assignment menu to the furnace
- Improve recording for move/fly/turn controllers
- Allow to move the TA4 terminal with the assembly tool
- Add aluminum recipes for techpack_stairway items (jfanjoy)
- Change forceload block menu


**2023-11-05 V1.18**

- Add TA2 clutch
- TA5 Generator: Add generator menu
- TA4 Injector: Allow rotation with a screwdriver
- Escape equal sign in german translation (Niklp09)
- Autocrafter: Add Beduino command interface
- Autocrafter: Add flush command
- Fix converter stores mesecon signals (Niklp09)
- TA1 Gravel Sieve: Use proper player creative check (Niklp09)
- TA4 Chest: Add storesize command
- Improve Assembly Tool
- Furnace: Fix burn time issue
- Allow further types of cobblestone for the coalburner
- Fix water mill river water bug (alwayshopeless)
- Improve manual
- Further improvements

**2023-08-25 V1.17**

- Add support for doclib / remove techage internal doc support  
  **The mod doclib is a new hard depenency !**
- Fix LICENCSE file bug
- Add beduino support for TA3 repeater (realmicu)
- Add inv_name_prefix to `techage.register_consumer` (debiankaios)
- Add generator menu to TA5 generator (fusion reactor)
- Adapt mod to the new lcdlib mod
- Fix some bugs

**2023-06-30 V1.16**

- Add TA4 node detector
- Add wrench menu to TA3 button
- Add arrows to the pump bottom and allow to turn the pump with the Techage Screwdriver
- Fix bug with configurred TA4 chest and TA5 teleport tubes
- Add gaze sensor
- Many bugfixes and improvements

**2023-05-05 V1.15**

- Allow energy storage with up to 13x13x13 concrete blocks
- Allow registration of other buckets
- Add hyperloop chest only if the hyperloop mod is available
- Add missing 'minetest.formspec_escape' #131 
- Fix bug "Trouble with flycontroller #130"    
- Add optional dependency on farming mod (orwell96)
- Fix forceload formspec receiver (Niklp09)

**2023-04-16 V1.14**

- Add file "api.md"
- Add API function `register_ore_for_gravelsieve`
- Add support for the game Asuna
- Merge pull request #124 from Niklp09/drops
- Fix keep node number issue
- Fix manual issue #123

**2023-04-10 V1.13**

- Add "Teleport mode" to the ta5 fly controller

**2023-04-01 V1.12**

- Improve Transformer:
  - add wrench menu for 'max. power passed through'
  - Increase max. power passed through from 100 to 300 ku
- Improve Electricmeter: 
  - add wrench menu for 'max. power passed through' and 'power countdown' 2458
  - add commands to read the countdown value (Lua and Beduino controller)
- Improve TA3 Mesecons Converter:
  - fix overload bug
  - fix missing dominant 'on' issue
- Add version command to TA3/TA4 Terminal
- TA5 Hyperloop Chest: Disable inventory access on client side due to minetest core issues

**2023-03-05  V1.11**

- Reduce the number of necessary exp points for TA5 Hyperloop Chest,
  TA5 Hyperloop Tank, and TA5 AI Chip II
- Fix possible kernel crashes with TA5 Hyperloop Chest and autocrafter
- Rework doorcontroller (menu changed)
- Increase tank cart storage size to 200 units
- Fix several paramtype/use_texture_alpha issues
- Add command 'load' to the TA4 power terminal
- Add beduino tank commands
- Fix power consumption bug for a stopped collider
- Fix electrolyzer formspec bug
- Add Rack and pinion node
- Expand ta4 sequencer wrench menu
- Accept mincart carts for the move controller
- movecontroller: Allow to move objects 'without' a move block
- Add empty_spool as fab output
- Fix doser goes blocked bug

**2023-02-04  V1.10**
- Improve flycontroller
- Remove handover for movecontroller
- Rename "techage:signal_lamp" to "techage:color_lamp"
- Rename "techage:signal_lamp2" to "techage:color_lamp2"
- Add countdown mode to TA4 Detector
- Adapt to new beduino and minecart versions
- Improve manuals
- flycontroller/movecontroller: Allow moving blocks through unloaded areas
- playerdetector: Add wrench menu to configure search radius
- Default furnace: Don't use items filled from the top as fuel
- Many further improvements and bug fixes from joe7575 and Niklp09

**2022-09-03  V1.09**
- Change the way items are pushed
- Add "Flow Limiter" mode to TA4 pump and TA4 pusher

**2022-06-06  V1.08**
- Native support for the mod Beduino added

**2022-01-22  V1.07**
- TA5 fusion reactor added

**2022-01-03  V1.06**
- TA5 teleport blocks added
- Many improvements

**2021-12-25  V1.05**
- Support for the mod i3 added (thanks to ghaydn)
- TA5 enabled
- Many improvements

**2021-12-12  V1.04**
- TA4 Collider added (experimental)
- move, turn, sound, and fly blocks added
- TA5 (future) introduced (TA4 is now the "present")

**2021-10-24  V1.03**
- Add TA4 Sequencer for time controlled command sequences
- Add TA4 Move Controller for moving blocks
- Add techage command counting function to be able to limit the amount of commands/min.
- Pull request #67: Add switch mode for 4x Button (by realmicu)
- Pull request #69: Add option to keep assignment for TA4 Tank (by Thomas-S)

**2021-09-18  V1.02**
-  TA4 Chest: Fix items disappearing (PR #64 by Thomas--S)
-  Add support for colored cables (PR #63 by Thomas--S)

**2021-08-16  V1.01**
- Allow singleplayer to place lava on y>0.
- Logic block: allow to use output numbers for the expression
- Pull request #60: Allow to pause the sequencer with a TechAge command (by Thomas-S)
- Pull request #61: Allow sharing the button based on protection (by Thomas-S)
- Pull request #62: Allow picking TA3 Tiny Generator with fuel (by realmicu)
- Add TA1 watermill
- Fix TA4 LED Grow Light bug
- Fix grinder recipe bu

**2021-07-23  V1.00**
- Change the way, power distribution works
- Add TA2 storage system
- Add TA4 Isolation Transformer 
- Add TA4 Electric Meter
- Add new power terminal
- Many improvements on power producing/consuming nodes
- See Construction Board for some hints on moving to v1

**2021-05-14  V0.26**
- Add concentrator tubes
- Add ta4 cable wall entry
- Pull request #57: Distributor improvements (from Thomas-S)
- Add new power terminal commands
- Add new door controller
- Add laser beam nodes for energy transfer
- Add TA4 recycle machine
- Many improvements and bug fixes

**2020-11-01  V0.25**
- Pull request #37: Trowel: Add protection support (from Thomas-S)
- Pull request #38: Charcoal Pile: Ignore "ignore" nodes (from Thomas-S)
- Autocrafter: Add register function for uncraftable items
- Fix bug: Tubes do not recognize when TA2 nodes are added/removed
- TA4 chest/tank: Add 'public' checkbox to allow public access
- Add nodes TA2 Power Generator and TA3 Electric Motor

**2020-10-20  V0.24**
- Pull request #27: Liquid Tanks: Add protection support (from Thomas-S)
- Pull request #28: Quarry: Improve digging behaviour (from Thomas-S)
- Pull request #29: Distributor: Keep metadata (from Thomas-S)
- Pull request #30: TA4: Add Liquid Filter (from Thomas-S)
- Pull request #31: Fix chest crash (from Thomas-S)
- Pull request #32: Fix Filter Sink Bug (from Thomas-S)
- Pull request #33: Add TA4 High Performance Distributor (from Thomas-S)
- Pull request #34: Add TA4 High Performance Distributor to Hopper (from Thomas-S)
- Pull request #35: Fixed Gravel Sieve bug (from CosmicConveyor)
- Fix doorcontroller and ta4 doser bugs
- Add check for wind turbine areas
- Fix translation errors
- QSG: Add power consumptions and fix manual bug
- Add load command to the controller battery
- TA4 silo: Add load command
- silo/tank: Add second return value for load command
- Liquid Pumps: Fix issue with undetected pipe connection gaps
- Shrink PGN files
- Fix ta4 chest bugs
- Fix ta4 chest and ta3 firebox issues
- Remove repairkit recipe
- Switched to AGPL license
- API added for ingame manual

**2020-09-13  V0.23**
- Pull request #26: Digtron Battery: Fix duplication bug (from Thomas-S)
- Improve ta4 sensor box
- Firebox: Add check for free space when placing the node
- Lua controller: Add 'get_gametime' function
- Pull request #27: Liquid Tanks: Add protection support  (from Thomas-S)
- Fix pump issue (silo source items can disappear)
- Pull request #28: Quarry: Improve digging behaviour (from Thomas-S)
- Pull request #28: Battery: Store battery load as metadata (from Thomas-S)
- Pull request #29: Distributor: Keep item metadata (from Thomas-S)

**2020-08-08  V0.22**
- Pull request #25: Growlight: Improve flower registration (from Thomas-S)
- Add tube support for digtron chests and protector:chest

**2020-08-08  V0.21**
- Pull request #18: Add a simple Digtron battery (from Thomas-S)
- Pull request #23: Lua Controller: Fix $item_description() documentation and translation (from Thomas-S)
- Pull request #24: Distributor: improve fairness by using random spread (from realmicu)
- Bugfix: TA1 meridian hammer did not glow (from realmicu)
- Bugfix: power.power_available() did not check the network state

**2020-07-31  V0.20**
- Pull request #21: Lua Controller: Allow to get itemstring and description of 8x2000 chest contents (from Thomas-S)
- Pull request #22: Trowel: Prevent hidden nodes from being dug (from Thomas-S)
- Improvement: TA3 Power Terminal: Outputs max needed power in addition
- Bugfix: Quarry: Shall not dig Techage Light Blocks

**2020-07-24  V0.19**
- Pull request #19: Refactor ICTA to use functions instead of loadstring (from Thomas-S)
- State command added for cart-, node-, and player detectors

**2020-07-21  V0.18**
- Pull request #13: Use Monospace Font for Code-Related Formspecs (from Thomas-S)
- Pull request #14: Don't allow to put items with meta or wear information into the 8x2000 chest (from Thomas-S)
- Pull request #15: Blackhole: Add support for liquids (from Thomas-S)
- Pull request #16: ICTA Controller: Add support for valves by adding on/off states (from Thomas-S)
- Bugfix: Digging Redstone gives an 'unknown block'
- ICTA Controller: Escape quotation marks for text outputs

**2020-07-16  V0.17**
- TA4 Reactor recipe bugfix
- TA3 furnace power bugfix (response to the pull request #12 from Thomas-S)
- Manual bugfix (Thomas-S)
- Charcoal pile doesn't start smoking after beeing unloaded (issue #9 from Skamiz) 

**2020-07-06  V0.16**
- Oil cracking/hydrogenation recipes added
- Ethereal growlight bugfix
- Charcoal pile bugfix (issue #9) Thanks to Skamiz
- Quarry bugfix (pull request #10) Thanks to programmerjake

**2020-07-02  V0.15**
- pipe valve added
- growlight bugfix
- further textures to gate/door blocks added
- cement recipe bugfix
- manual improvements

**2020-06-29  V0.14**
- quarry sound bugfix
- grinder bugfix
- ore probability calculation changed
- lua-marshal deactivated (due to weird server crashes)
- alternative cement recipe added
- aluminum output increased
- reboiler cycle time increased to 16 s (from 6)
- many manual improvements

**2020-06-19  V0.13**
- Mesecons Converter added

**2020-06-17  V0.12** 
- Ethereal support added
- manual correction
- tin ingot recipe bugfix

**2020-06-14  V0.11**
- cart commands added for both controllers
- support for moreores added

**2020-06-04  V0.10**
- minor changes and bugfixes

**2020-05-31  V0.09**
- TA4 tubes upgraded, manuals updated

**2020-05-22  V0.08**
- Support for 'lua-marshal' and 'lsqlite3' added

**2020-04-26  V0.07**
- English translation added

**2020-04-24  V0.06**
- TA4 injector added

**2020-03-14  V0.05**
- TA4 Lua controller added

**2020-02-29  V0.04**
- TA4 ICTA controller added

**2019-09-28  V0.02**
- TA3 finished

**2019-06-16  V0.01**
- First upload
