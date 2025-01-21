return {
  titles = {
    "1,Tech Age Mod",
    "2,Hints",
    "2,Changes from version 1.0",
    "3,Tips on switching",
    "2,Ores and Minerals",
    "3,Meridium",
    "3,Usmium",
    "3,Baborium",
    "3,Petroleum",
    "3,Bauxite",
    "3,Basalt",
    "2,History",
  },
  texts = {
    "Tech Age is a technology mod with 5 development stages:\n"..
    "\n"..
    "TA1: Iron Age\n"..
    "Use tools and aids such as coal burners\\, gravel sieves\\, hammers and hoppers to mine and process the necessary ores and metals.\n"..
    "\n"..
    "TA2: Steam Age\n"..
    "Build a steam engine with drive axles and use it to operate your first ore processing machines.\n"..
    "\n"..
    "TA3: Oil Age\n"..
    "Find and extract oil\\, built railways for oil transportation. A power plant provides the necessary electricity for your machines. Electric light illuminates your industrial plants.\n"..
    "\n"..
    "TA4: Present\n"..
    "Renewable energy sources such as wind\\, sun and bio-fuels help you to leave the oil age. With modern technologies and intelligent machines you set out into the future.\n"..
    "\n"..
    "TA5: Future\n"..
    "Machines to overcome space and time\\, new sources of energy and other achievements shape your life.\n"..
    "\n"..
    "Note: With a click on the plus sign you get into the sub-chapters of this manual.\n"..
    "\n"..
    "\n"..
    "\n",
    "This documentation is available both \"ingame\" (block construction plan) and on GitHub as MD files.\n"..
    "\n"..
    "  - Link: https://github.com/joe7575/techage/wiki\n"..
    "\n"..
    "The construction plans (diagrams) for the construction of the machines and the pictures are only available in-game.\n"..
    "\n"..
    "With Tech Age you have to start over. You can only create TA2 blocks with the items from TA1\\, for TA3 you need the results from TA2\\, etc.\n"..
    "\n"..
    "In TA2\\, the machines only run with drive axes.\n"..
    "\n"..
    "From TA3\\, the machines run on electricity and have a communication interface for remote control.\n"..
    "\n"..
    "TA4 adds more power sources\\, but also higher logistical challenges (power lines\\, item transport).\n"..
    "\n",
    "From V1.0 (07/17/2021) the following has changed:\n"..
    "\n"..
    "  - The algorithm for calculating the power distribution has changed. This makes energy storage systems more important. These compensate for fluctuations\\, which is important in larger networks with several generators.\n"..
    "  - For this reason TA2 got its own energy storage.\n"..
    "  - The battery blocks from TA3 also serve as energy storage. Their functionality has been adapted accordingly.\n"..
    "  - The TA4 storage system has been revised. The heat heat exchanger have been given a new number because the functionality has been moved from the lower to the middle block. If these were remotely controlled\\, the node number must be adapted. The generators no longer have their own menu\\, but are only switched on / off via the heat exchanger. The heat exchanger and generator must now be connected to the same network!\n"..
    "  - Several power grids can now be coupled via a TA4 transformer blocks.\n"..
    "  - A TA4 electricity meter block for sub-networks is also new.\n"..
    "  - At least one battery block or a storage system in each network\n"..
    "\n",
    "Many more blocks have received minor changes. It is therefore possible that machines or systems do not start up again immediately after the changeover. In the event of malfunctions\\, the following tips will help:\n"..
    "\n"..
    "  - Switch machines off and on again\n"..
    "  - remove a power cable block and put it back in place\n"..
    "  - remove the block completely and put it back in place\n"..
    "\n",
    "Techage adds some new items to the game:\n"..
    "\n"..
    "  - Meridium - an alloy for the production of luminous tools in TA1\n"..
    "  - Usmium - an ore that is mined in TA2 and needed for TA3\n"..
    "  - Baborium - a metal that is needed for recipes in TA3\n"..
    "  - Petroleum - is needed in TA3\n"..
    "  - Bauxite - an aluminum ore that is needed in TA4 to produce aluminum\n"..
    "  - Basalt - arises when water and lave touch\n"..
    "\n",
    "Meridium is an alloy of steel and mesecons crystals. Meridium ingots can be made with the coal burner from steel and mesecons crystals. Meridium glows in the dark. Tools made of Meridium also light up and are therefore very helpful in underground mining.\n"..
    "\n"..
    "\n"..
    "\n",
    "Usmium only occurs as nuggets and can only be obtained by washing gravel with the TA2/TA3 gravel washing system.\n"..
    "\n"..
    "\n"..
    "\n",
    "Barborium can only be obtained from underground mining. This substance can only be found at a depth of -250 to -340 meters.\n"..
    "\n"..
    "Baborium can only be melted in the TA3 Industrial Furnace.\n"..
    "\n"..
    "\n"..
    "\n",
    "Petroleum can only be found with the help of the Explorer and extracted with the help of appropriate TA3 machines. See TA3.\n"..
    "\n"..
    "\n"..
    "\n",
    "Bauxite is only extracted in underground mining. Bauxite is only found in stone at a height between -50 and -500 meters.\n"..
    "It is required for the production of aluminum\\, which is mainly used in TA4.\n"..
    "\n"..
    "\n"..
    "\n",
    "Basalt is only created when lava and water come together.\n"..
    "The best thing to do is to set up a system where a lava and a water source flow together.\n"..
    "Basalt is formed where both liquids meet.\n"..
    "You can build an automated basalt generator with the Sign Bot.\n"..
    "\n"..
    "\n"..
    "\n",
    "  - 28.09.2019: Solar system added\n"..
    "  - 05.10.2019: Data on the solar system and description of the inverter and the power terminal changed\n"..
    "  - 18.11.2019: Chapter for ores\\, reactor\\, aluminum\\, silo\\, bauxite\\, furnace heating\\, gravel washing system added\n"..
    "  - 22.02.2020: corrections and chapters on the update\n"..
    "  - 29.02.2020: ICTA controller added and further corrections\n"..
    "  - 14.03.2020 Lua controller added and further corrections\n"..
    "  - 22.03.2020 More TA4 blocks added\n"..
    "\n",
  },
  images = {
    "techage_ta4",
    "",
    "",
    "",
    "",
    "meridium",
    "usmium",
    "baborium",
    "oil",
    "bauxite",
    "basalt",
    "",
  },
  plans = {
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
  }
}