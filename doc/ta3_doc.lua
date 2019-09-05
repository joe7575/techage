--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Main module for the in-game TA1 documentation

]]--

local S = techage.S

techage.register_category_page("ta3", 
	S("Oil Age (TA3)"),
	S("The Oil Age is the third level of the available technic stages. "..
		"The goal of TA3 is to build Power Stations, drill for oil, and build "..
		"machines to produce ores and chips for smart TA4 devices and machines."),
	"techage:oil_source", 
	{"power", "times"}
)

techage.register_entry_page("ta3", "power",
	S("Power Consumption"), 
	S("Power consumption and supply:@n"..
	"- TA3 Power Station: 80 ku@n"..
	"- TA3 Tiny Generator: 12 ku@n"..
	"- TA3 Akku Box: 10 ku (in both dirs)@n"..
	"- TA3 Oil Drill Box: 16 ku@n"..
	"- TA3 Oil Pumpjack: 16 ku@n"..
	"- TA3 Electronic Fab: 12 ku@n"..
	"- TA3 Autocrafter: 6 ku@n"..
	"- TA3 Grinder: 6 ku@n"..
	"- TA3 Gravel Sieve: 4 ku@n"..
	"- TA3 Booster: 3 ku@n"..
	"- Lamps: 0.5 ku@n"..
	"- TA4 Streetlamp Solar Cell: 1 ku@n"..
	"@n"..
	"- Signs Bot: 8 ku (while loading)"),
	"techage:t3_source", nil)

techage.register_entry_page("ta3", "times",
	S("Oil Burning Times"), 
	S("Burning times with one oil item for@n"..
	"Stream Engine  /  Power Station  /  Tiny Generator:@n"..
	"@n"..
	"Power max./ku  :     25 /  80  /  12@n"..
	"Oil burn time/s :     32 /  20  /  100 @n"..
	"@n"..
	"burn time at power   2  :    400  /  800  /   600@n"..
	"burn time at power 10  :      80  /  160  /   120@n"..
	"burn time at power 20  :      40  /    80  /      --"), 
"techage:t3_source", nil)

local Images = {
	{false, false, false, false, false, false, false},
	{"techage_steam_knee.png", 'techage_steam_pipe.png', 'techage_steam_pipe.png', 
		'techage_steam_pipe.png', 'techage_steam_pipe.png', 'techage_steam_pipe.png', "techage_steam_knee.png^[transformR270"},
	{'techage_steam_pipe.png^[transformR90', "techage:coalboiler_top", 'techage_steam_pipe.png', 
		'techage_steam_knee.png^[transformR270', 'techage_steam_knee.png', 
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_cooler.png",
		"techage_steam_knee.png^[transformR180"},
	{"techage_steam_knee.png^[transformR90", "techage:coalboiler_base", false, 'techage_steam_pipe.png^[transformR90',
		'techage_steam_pipe.png^[transformR90'},
	{false, "techage:coalfirebox", false, "techage_steam_knee.png^[transformR90", 
		"techage_filling_ta3.png^techage_appl_turbine.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_generator.png"},
}

--techage.register_entry_page("ta3", "power_station",
techage.register_category_page("ta3ps",
	S("TA3: Power Station"), 
	S("Build a Power Station according to the plan with TA3 Firebox, TA3 Boiler, Steam Pipes, Cooler, Turbine and Generator.@n"..
		"- Heat the Firebox with coal/charcoal or oil@n"..
		"- Fill the boiler with water (more than one bucket is needed)@n"..
		"- Wait until the water is heated@n"..
		"- Open the steam ventil@n"..
		"- Connect the Generator with your machines by means of cables and junction boxes@n"..
		"- Start the Generator"), 
	nil, 
	{"coalboiler_base", "coalboiler_top", "turbine", "generator", "cooler", "akku", "tiny_generator", "ta3_power_terminal"},
	Images)

techage.register_category_page("ta3op",
	S("TA3: Oil plants"), 
	S("In the TA3 age, oil (petroleum) serves as an almost infinite fuel. But oil is difficult "..
		"and expensive to recover:@n"..
		"1: Search for oil with the TA3 Oil Explorer@n"..
		"2: Drill for oil with the TA3 Oil Drill Box (oil derrick)@n"..
		"3: Recover the oil with the TA3 Oil Pumpjack@n"..
		"4: A power station nearby provides the necessary @n"..
		"	 electrical power for the derrick and pumpjack.@n"..
		"5: Tubes or rails are used for oil transportation."),
	"techage:oilexplorer",
	{"oilexplorer", "drillbox", "pumpjack"}
)

techage.register_category_page("ta3m", 
	S("TA3: Machines"),
	S("Collection of TA3 machines, some with eletrical power supply."),
	"techage:ta3_autocrafter_pas", 
	{"pusher", "distributor", "chest", "grinder", "gravelsieve", "autocrafter", "electronic_fab", 
		"funnel", "liquidsampler"}
)

techage.register_category_page("ta3l", 
	S("TA3: Logic"),
	S("Collection of TA3 logic blocks to control your machines."),
	"techage:terminal2", 
	{"terminal", "button", "detector", "repeater", "logic", "node_detector", "player_detector", "cart_detector", "programmer"}
)
