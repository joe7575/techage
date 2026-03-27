# TA5: Future

Machines to overcome space and time, new sources of energy and other achievements shape your life.

Experience points are required for the manufacture and use of TA5 machines and blocks. These can only be worked out using the collider from TA4.

[techage_ta5|image]

## Energy Sources

### TA5 Fusion Reactor

Nuclear fusion means the fusing of two atomic nuclei. Depending on the reaction, large amounts of energy can be released. Nuclear fusions, in which energy is released, take place in the form of chain reactions. They are the source of the energy of the stars, including our sun, for example. A fusion reactor converts the energy released during controlled nuclear fusion into electricity.

**How ​​do fusion reactors work?**

A fusion reactor works according to the classic principle of a thermal power plant: water is heated and drives a steam turbine, whose kinetic energy is converted into electricity by a generator.

A fusion power plant initially requires a large amount of energy, since a plasma has to be generated. "Plasma" is the name given to the fourth state of matter, after solid, liquid and gaseous. This requires a lot of electricity. Only through this extreme concentration of energy does the fusion reaction ignite and the heat given off is used to generate electricity via the heat exchanger. The generator then delivers 800 ku of electricity.

The plan on the right shows a section through the fusion reactor.

60 experience points are required to operate the fusion reactor. The fusion reactor must be built entirely in a forceload block area.

[ta5_fusion_reactor|plan]

#### TA5 Fusion Reactor Magnet

A total of 60 TA5 Fusion Reactor Magnets are required to set up the fusion reactor. These form the ring in which the plasma forms. The TA5 Fusion Reactor Magnets requires power and has two ports for cooling.

There are two types of magnets, so all sides of the magnet that face the plasma ring can also be protected with a heat shield.

With the corner magnets on the inside of the ring, one connection side is covered (power or cooling) and can therefore not be connected. This is technically not feasible and therefore has no influence on the function of the fusion reactor. 

[ta5_magnet|image]

#### TA5 Pump

The pump is required to fill the cooling circuit with isobutane. About 350 units of isobutane are required.

The pump has two connection sides:

- Left side: yellow connector (GasPipe) – connect the isobutane tank here
- Right side: blue connector (LiquidPipe) – connect the cooling circuit here

By default, the pump moves liquid from left (yellow) to right (blue), i.e. from the tank into the cooling circuit. The pump direction can be changed to "reverse" via the wrench menu.

Note: The TA5 pump can only be used to fill the cooling circuit, pumping out the coolant is not possible. Therefore, the pump should not be switched on until the magnets are correctly placed and all power and cooling lines are connected.

If the pump shows "blocked", the destination is full or not connected.

[ta5_pump|image]

#### TA5 Heat Exchanger

The TA5 Heat Exchanger is required to convert the heat generated in the fusion reactor first to steam and then to electricity. The Heat Exchanger itself requires 5 ku electricity. The structure is similar to the Heat Exchanger of the energy store from TA4.

The Heat Exchanger consists of 3 parts (bottom to top: 1, 2, 3). Parts 1 and 3 each have two connection sides:

- Right side: yellow connector – connects to turbine (part 1) or cooler (part 3)
- Left side of part 1: blue connector – cooling circuit to the lower magnet ring (56 magnets)
- Left side of part 3: green connector – cooling circuit to the upper magnet ring (52 magnets)

The cooling circuit can be checked for completeness using the start button on the heat exchanger (part 2), even if no coolant has yet been filled in. Possible error messages:

- "Turbine error" / "Cooler error": Turbine or cooler not connected via yellow pipe
- "Blue/Green pipe connection error": Magnets not correctly connected via blue/green pipes
- "Blue/Green pipe coolant missing": Magnets not yet filled with isobutane (6 units per magnet)

[ta5_heatexchanger|plan]

#### TA5 Fusion Reactor Controller

The fusion reactor is switched on via the TA5 Fusion Reactor Controller. The fusion reactor and thus the controller requires 400 ku of electricity to maintain the plasma.

**Startup sequence:**

1. All magnets must be correctly placed and filled with isobutane
2. Cooling circuit (blue and green pipes) and steam pipes (yellow pipes) must be fully connected
3. First, switch on the Heat Exchanger (part 2)
4. Then switch on the Controller
5. It takes about 2 minutes for the reactor to reach 80° and produce steam/electricity

**Important:** Both the Heat Exchanger and the Controller must be running at the same time. The Controller heats the magnets (inc_power), the Heat Exchanger cools them (dec_power). Without both parts working together, the operating temperature will not be reached.

Possible error messages from the Controller:

- "Magnet detection error": Not all 56 magnets reachable via power cable
- "Plasma ring shape error": Interior of the plasma ring not clear (air)
- "Shell shape error": Shell around the magnets incomplete (shows how many magnets have complete shell)
- "Nucleus detection error": Core missing or not correctly placed
- "Cooling failed": Heat Exchanger not running or magnets not being cooled

[ta5_fr_controller|image]

#### TA5 Fusion Reactor Shell

The entire reactor must be surrounded by a shell that absorbs the enormous pressure that the magnets exert on the plasma and protects the environment from radiation. Without this shell, the reactor cannot be started. With the TechAge Trowel, power cables and cooling pipes of the fusion reactor can also be integrated into the shell.

[ta5_fr_shell|image]

#### TA5 Fusion Reactor Core

The core must sit in the center of the reactor. See illustration under "TA5 Fusion Reactor". The TechAge Trowel is also required for this.

[ta5_fr_nucleus|image]

## Energy Storage

### TA5 Hybrid Storage (planned)

## Logic blocks

## Transport and Traffic

### TA5 Flight Controller

The TA5 Flight Controller is similar to the TA4 Move Controller. In contrast to the TA4 Move Controller, several movements can be combined into one flight route. This flight route can be defined in the input field using several x,y,z entries (one movement per line). The flight route is checked and saved via "Save". In the event of an error, an error message is issued.

With the "Test" button, the flight route with the absolute coordinates is output for checking in the chat.

The maximum distance for the entire flight distance is 1500 m. Up to 32 blocks can be trained.

The use of the TA5 Flight Controller requires 40 experience points.

**Teleport mode**

If the 'Teleport Mode' is enabled, a player can also be moved without blocks. To do this, the start position must be configured using the "Record" button. Only one position can be configured here. The player to be moved must be in that position.

[ta5_flycontroller|image]

### TA5 Hyperloop Chest

The TA5 Hyperloop Chest allows objects to be transported over a Hyperloop network.

The TA5 Hyperloop Chest has to be placed on a Hyperloop Junction. The chest has a special menu, with which you can pair two chests. Things that are in the chest are teleported to the remote station. The chest can also be filled/emptied with a pusher.

For pairing you first have to enter a name for the chest on one side, then you can select this name for the other chest and thus connect the two blocks.

The use of the TA5 Hyperloop Chest requires 15 experience points.

[ta5_chest|image]

### TA5 Hyperloop Tank

The TA5 Hyperloop Tank allows liquids to be transported over a Hyperloop network.

The TA5 Hyperloop Tank has to be placed on a Hyperloop Junction.The tank has a special menu, with which you can pair two tanks. Liquids in the tank will be teleported to the remote station. The tank can also be filled/emptied with a pump.

For pairing you first have to enter a name for the tank on one side, then you can select this name for the other tank and thus connect the two blocks.

The use of the TA5 Hyperloop Tank requires 15 experience points.

[ta5_tank|image]



## Teleport Blocks

Teleport blocks allow things to be transferred between two teleport blocks without the need for a pipe or tube in between. To pair the blocks, you first have to enter a name for the block on one side, then you can select this name for the other block and thus connect the two blocks. Pairing can only be carried out by one player (player name is checked) and must be completed before the server is restarted. Otherwise the pairing data will be lost.

The map on the right shows how the blocks can be used. 

[ta5_teleport|plan]

### TA5 Teleport Block Items

These teleport blocks allow the transfer of items and thus replace a tube. Distances of up to 500 blocks can be bridged.

Each Teleport blocks requires 12 ku of electricity.

30 experience points are required to use the teleport blocks. 

[ta5_tele_tube|image]

### TA5 Teleport Block Liquids

These teleport blocks allow the transfer of liquids and thus replace a pipe. Distances of up to 500 blocks can be bridged.

Each Teleport blocks requires 12 ku of electricity.

30 experience points are required to use the teleport blocks. 

[ta5_tele_pipe|image]

### Hyperloop Teleport Blocks (planned)

The Hyperloop Teleport Blocks allow the construction of a Hyperloop network without Hyperloop tubes.

The use of the Hyperloop Teleport Blocks requires 60 experience points.



## TA5 Digitizer

### TA5 Digitizer

The TA5 Digitizer is a high-capacity item storage block that digitally stores items drawn from adjacent inventories. It can operate in two modes (pull/push) and handles up to 8 different item types with up to 100,000 items per slot.

The Digitizer has a tube connection on the right side and can also be controlled via the Techage network. In pull mode, it draws up to 50 items per cycle from a connected chest. In push mode, it pushes stored items back into adjacent inventories.

Only stackable items without metadata and without wear can be stored. Items such as signed books or worn tools are rejected.

The Digitizer can only be removed with a pickaxe if the internal storage is completely empty. Use the cordless screwdriver to remove it when stopped - the stored items are preserved as item metadata and restored automatically when the block is placed back using the cordless screwdriver.

The TA5 Digitizer requires 24 ku of power.

50 experience points are required to use the TA5 Digitizer (configurable via `techage_ta5_digitizer_expoints`).

The Digitizer can also be configured and started using a Lua or Beduino controller.

Here are the additional commands for the Lua controller:

- `on` / `off` - Start or stop the Digitizer
- `state` - Query the current state (e.g. "running", "stopped")
- `pull` - Start in pull mode; draws items from the adjacent chest
- `push` - Start in push mode; pushes stored items into the adjacent chest
- `stop` - Stop the Digitizer
- `config` sets the target item type (stops the Digitizer first).
  Example: `$send_cmnd(NUM, "config", "default:stone")`
- `count` queries the total number of stored items.
  Example: `$send_cmnd(NUM, "count")` returns a number
- `itemstring` queries the configured item type.
  Example: `$send_cmnd(NUM, "itemstring")` returns the item name
- `mode` gets or sets the operating mode (1 = pull, 2 = push).
  Example: `$send_cmnd(NUM, "mode")` returns 1 or 2
  Example: `$send_cmnd(NUM, "mode", 2)` sets push mode

Beduino topics (cmnd): 65 = set item type, 67 = set mode (1=pull, 2=push)
Beduino topics (request): 154 = total item count, 155 = configured item type

[ta5_digitizer|image]

### TA5 Control Unit

The TA5 Control Unit is required to craft the TA5 Digitizer. It can only be manufactured at the TA4 Electronics Fab and requires 50 experience points.

[ta5_controlunit|image]

### TA5 SSD

The TA5 SSD is an intermediate component required to craft the TA5 Digitizer. It can only be manufactured at the TA4 Electronics Fab from 16 TA4 RAM Chips, 1 TA4 Silicon Wafer, 1 Plastic Sheet and 1 Steel Strip.

[ta5_ssd|image]

## More TA5 Blocks/Items

### TA5 Container (planned)

The TA5 container allows Techage systems to be packed and unpacked at another location.

80 experience points are required to use the TA5 container.

### TA5 AI Chip

The TA5 AI Chip is partly required for the production of TA5 blocks. The TA5 AI Chip can only be manufactured at the TA4 Electronics Fab. This requires 10 experience points.

[ta5_aichip|image]

### TA5 AI Chip II

The TA5 AI Chip II is required to build the TA5 Fusion Reactor. The TA5 AI Chip II can only be manufactured at the TA4 Electronics Fab. This requires 25 experience points.

[ta5_aichip2|image]
