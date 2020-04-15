
if minetest.global_exists("tubelib") then
	minetest.log("error", "[techage] Techage can't be used together with the mod tubelib!")
elseif minetest.global_exists("ironage") then
	minetest.log("error", "[techage] Techage can't be used together with the mod ironage!")
elseif minetest.global_exists("techpack") then
	minetest.log("error", "[techage] Techage can't be used together with the modpack techpack!")
elseif minetest.global_exists("tubelib2") and tubelib2.version < 1.8 then
	minetest.log("error", "[techage] Techage requires tubelib2 version 1.8 or newer!")
else
	techage = {
		NodeDef = {},		-- node registration info
	}
	techage.max_num_forceload_blocks = tonumber(minetest.settings:get("techage_max_num_forceload_blocks")) or 24
	 
	techage.basalt_stone_enabled = minetest.settings:get_bool("techage_basalt_stone_enabled") ~= false
	techage.ore_rarity = tonumber(minetest.settings:get("techage_ore_rarity")) or 1
	techage.modified_recipes_enabled = minetest.settings:get_bool("techage_modified_recipes_enabled") ~= false

	-- Load support for I18n.
	techage.S = minetest.get_translator("techage")
	
	-- Basis features
	local MP = minetest.get_modpath("techage")
	dofile(MP.."/basis/lib.lua")  -- helper functions
	dofile(MP.."/basis/storage.lua")
	dofile(MP.."/basis/gravel_lib.lua")  -- ore probability
	dofile(MP.."/basis/node_states.lua") -- state model
	dofile(MP.."/basis/tubes.lua")  -- tubes for item transport
	dofile(MP.."/basis/tubes_ta4.lua")  -- TA4 tubes for item transport
	dofile(MP.."/basis/command.lua")  -- command API
	dofile(MP.."/basis/firebox_lib.lua")  -- common firebox functions
	dofile(MP.."/basis/boiler_lib.lua")  -- common boiler functions
	dofile(MP.."/basis/liquid_lib.lua")  -- common liquids functions
	dofile(MP.."/basis/fuel_lib.lua")  -- common fuel functions
	dofile(MP.."/basis/mark.lua")
	dofile(MP.."/basis/mark2.lua")
	dofile(MP.."/basis/assemble.lua")
	dofile(MP.."/basis/networks.lua")
	dofile(MP.."/basis/recipe_lib.lua")
	dofile(MP.."/basis/formspec_update.lua")

	-- Main doc
	dofile(MP.."/doc/manual_DE.lua")
	--dofile(MP.."/doc/manual_EN.lua")
	dofile(MP.."/doc/plans.lua")
	dofile(MP.."/doc/items.lua")
	dofile(MP.."/doc/guide.lua")  -- construction guides
	
	-- Power networks
	dofile(MP.."/power/node_api.lua")
	dofile(MP.."/power/junction.lua") 
	dofile(MP.."/power/distribution.lua")
	dofile(MP.."/power/schedule.lua")
	dofile(MP.."/power/formspecs.lua")
	dofile(MP.."/power/drive_axle.lua")
	dofile(MP.."/power/gearbox.lua")
	dofile(MP.."/power/steam_pipe.lua")
	dofile(MP.."/power/electric_cable.lua")
	dofile(MP.."/power/junctionbox.lua")
	dofile(MP.."/power/power_terminal.lua")
	dofile(MP.."/power/power_terminal2.lua")
	dofile(MP.."/power/powerswitchbox.lua")
	dofile(MP.."/power/powerswitch.lua")
	dofile(MP.."/power/protection.lua")
	dofile(MP.."/power/power_line.lua")
	dofile(MP.."/power/ta4_cable.lua")

	-- Iron Age
	dofile(MP.."/iron_age/main.lua")
	dofile(MP.."/iron_age/gravelsieve.lua")
	dofile(MP.."/iron_age/hopper.lua")
	dofile(MP.."/iron_age/hammer.lua")
	dofile(MP.."/iron_age/lighter.lua")
	dofile(MP.."/iron_age/charcoalpile.lua")
	dofile(MP.."/iron_age/coalburner.lua")
	dofile(MP.."/iron_age/meltingpot.lua")
	if techage.modified_recipes_enabled then
		dofile(MP.."/iron_age/tools.lua")
	end
	dofile(MP.."/iron_age/recipes.lua")
	if minetest.global_exists("wielded_light") then
		dofile(MP.."/iron_age/meridium.lua")
	end

	-- Steam Engine
	dofile(MP.."/steam_engine/firebox.lua")
	dofile(MP.."/steam_engine/boiler.lua")
	dofile(MP.."/steam_engine/cylinder.lua")
	dofile(MP.."/steam_engine/flywheel.lua")
	
	-- Liquids I
	dofile(MP.."/liquids/liquid_pipe.lua")
	dofile(MP.."/liquids/node_api.lua")
	
	-- Basic Machines
	dofile(MP.."/basic_machines/consumer.lua")  -- consumer base model
	dofile(MP.."/basic_machines/source.lua")
	dofile(MP.."/basic_machines/pusher.lua")
	dofile(MP.."/basic_machines/legacy_nodes.lua")
	dofile(MP.."/basic_machines/grinder.lua")
	dofile(MP.."/basic_machines/distributor.lua")
	dofile(MP.."/basic_machines/gravelsieve.lua")
	dofile(MP.."/basic_machines/gravelrinser.lua")
	dofile(MP.."/basic_machines/chest.lua")
	dofile(MP.."/basic_machines/autocrafter.lua")
	dofile(MP.."/basic_machines/electronic_fab.lua")
	dofile(MP.."/basic_machines/liquidsampler.lua")
	dofile(MP.."/basic_machines/quarry.lua")
	dofile(MP.."/basic_machines/ta4_chest.lua")

	-- Liquids II
	dofile(MP.."/liquids/tank.lua")
	dofile(MP.."/liquids/filler.lua")
	dofile(MP.."/liquids/silo.lua")
	dofile(MP.."/liquids/pump.lua")
	dofile(MP.."/liquids/waterpump.lua")
	
	-- Coal power station
	dofile(MP.."/coal_power_station/firebox.lua")
	dofile(MP.."/coal_power_station/boiler_base.lua")
	dofile(MP.."/coal_power_station/boiler_top.lua")
	dofile(MP.."/coal_power_station/generator.lua")
	dofile(MP.."/coal_power_station/turbine.lua")
	dofile(MP.."/coal_power_station/cooler.lua")
	dofile(MP.."/coal_power_station/oilfirebox.lua")
	
	-- Industrial Furnace
	dofile(MP.."/furnace/firebox.lua")
	dofile(MP.."/furnace/cooking.lua")
	dofile(MP.."/furnace/furnace_top.lua")
	dofile(MP.."/furnace/booster.lua")
	dofile(MP.."/furnace/heater.lua")
	dofile(MP.."/furnace/recipes.lua")
	
	-- Tools
	dofile(MP.."/tools/trowel.lua")
	dofile(MP.."/tools/repairkit.lua")
	dofile(MP.."/tools/pipe_wrench.lua")
	dofile(MP.."/basic_machines/blackhole.lua")
	dofile(MP.."/basic_machines/forceload.lua")
	
	-- Lamps
	dofile(MP.."/lamps/lib.lua")
	dofile(MP.."/lamps/lightblock.lua")	
	dofile(MP.."/lamps/simplelamp.lua")
	dofile(MP.."/lamps/streetlamp.lua")
	dofile(MP.."/lamps/streetlamp2.lua")
	dofile(MP.."/lamps/ceilinglamp.lua")
	dofile(MP.."/lamps/industriallamp1.lua")
	dofile(MP.."/lamps/industriallamp2.lua")
	dofile(MP.."/lamps/industriallamp3.lua")
	dofile(MP.."/lamps/industriallamp4.lua")
	dofile(MP.."/lamps/growlight.lua")
	dofile(MP.."/lamps/lampholder.lua")
	
	-- Oil
	dofile(MP.."/oil/explore.lua")
	dofile(MP.."/oil/tower.lua")
	dofile(MP.."/oil/drillbox.lua")
	dofile(MP.."/oil/pumpjack.lua")
	dofile(MP.."/oil/distiller.lua")
	dofile(MP.."/oil/reboiler.lua")
--	dofile(MP.."/oil/gasflare.lua")
	
	-- TA3 power based
	dofile(MP.."/ta3_power/tiny_generator.lua")
	dofile(MP.."/ta3_power/akkubox.lua")
	
	-- Logic
	dofile(MP.."/logic/lib.lua")
	dofile(MP.."/logic/terminal.lua")
	dofile(MP.."/logic/button.lua")
	dofile(MP.."/logic/detector.lua")
	dofile(MP.."/logic/repeater.lua")
	dofile(MP.."/logic/programmer.lua")
	dofile(MP.."/logic/signallamp.lua")
	dofile(MP.."/logic/sequencer.lua")
	dofile(MP.."/logic/timer.lua")
	dofile(MP.."/logic/lua_logic.lua")
	dofile(MP.."/logic/node_detector.lua")
	dofile(MP.."/logic/player_detector.lua")
	dofile(MP.."/logic/cart_detector.lua")
	dofile(MP.."/logic/gateblock.lua")
	dofile(MP.."/logic/doorblock.lua")
	dofile(MP.."/logic/doorcontroller.lua")
	dofile(MP.."/logic/collector.lua")

	-- Test
	dofile(MP.."/recipe_checker.lua")
	dofile(MP.."/.test/sink.lua")
	--dofile(MP.."/.test/meta_node.lua")
	
	-- Solar
	dofile(MP.."/solar/minicell.lua")
	dofile(MP.."/solar/solarcell.lua")
	dofile(MP.."/solar/inverter.lua")
	
	-- Wind
	dofile(MP.."/wind_turbine/rotor.lua")
	dofile(MP.."/wind_turbine/pillar.lua")
	dofile(MP.."/wind_turbine/signallamp.lua")
	
	-- TA4 Energy Storage
	dofile(MP.."/energy_storage/heatexchanger3.lua")
	dofile(MP.."/energy_storage/heatexchanger2.lua")
	dofile(MP.."/energy_storage/heatexchanger1.lua")
	dofile(MP.."/energy_storage/generator.lua")
	dofile(MP.."/energy_storage/turbine.lua")
	dofile(MP.."/energy_storage/inlet.lua")
	dofile(MP.."/energy_storage/nodes.lua")
	
	-- Chemistry
	dofile(MP.."/chemistry/ta4_reactor.lua")
	dofile(MP.."/chemistry/ta4_stand.lua")
	dofile(MP.."/chemistry/ta4_doser.lua")
	
	-- Hydrogen
	dofile(MP.."/hydrogen/fuelcellstack.lua")
	dofile(MP.."/hydrogen/electrolyzer.lua")
	dofile(MP.."/hydrogen/fuelcell.lua")

	-- ICTA Controller
	dofile(MP.."/icta_controller/submenu.lua")
	dofile(MP.."/icta_controller/condition.lua")
	dofile(MP.."/icta_controller/action.lua")
	dofile(MP.."/icta_controller/formspec.lua")
	dofile(MP.."/icta_controller/controller.lua")
	dofile(MP.."/icta_controller/commands.lua")
	dofile(MP.."/icta_controller/edit.lua")
	dofile(MP.."/icta_controller/battery.lua")
	dofile(MP.."/icta_controller/display.lua")
	dofile(MP.."/icta_controller/signaltower.lua")
	
	-- Lua Controller
	dofile(MP.."/lua_controller/controller.lua")
	dofile(MP.."/lua_controller/commands.lua")
	dofile(MP.."/lua_controller/server.lua")
	dofile(MP.."/lua_controller/sensorchest.lua")
	dofile(MP.."/lua_controller/terminal.lua")
	
	-- Items
	dofile(MP.."/items/barrel.lua")
	dofile(MP.."/items/baborium.lua")
	dofile(MP.."/items/usmium.lua")
	dofile(MP.."/items/lye.lua")
	dofile(MP.."/items/oil.lua")
	dofile(MP.."/items/petroleum.lua")
	dofile(MP.."/items/bauxit.lua")
	dofile(MP.."/items/silicon.lua")
	dofile(MP.."/items/steelmat.lua")
	dofile(MP.."/items/powder.lua")
	dofile(MP.."/items/epoxy.lua")
	dofile(MP.."/items/aluminium.lua")
	dofile(MP.."/items/plastic.lua")
	dofile(MP.."/items/hydrogen.lua")
	dofile(MP.."/items/electronic.lua")
	dofile(MP.."/items/redstone.lua")
	
	if techage.basalt_stone_enabled then
		dofile(MP.."/items/basalt.lua")
	end
end
