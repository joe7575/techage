--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

]]--

techage = {}

-- Version for compatibility checks, see readme.md/history
techage.version = 1.08

if minetest.global_exists("tubelib") then
	minetest.log("error", "[techage] Techage can't be used together with the mod tubelib!")
	return
elseif minetest.global_exists("ironage") then
	minetest.log("error", "[techage] Techage can't be used together with the mod ironage!")
	return
elseif minetest.global_exists("techpack") then
	minetest.log("error", "[techage] Techage can't be used together with the modpack techpack!")
	return
elseif minetest.global_exists("tubelib2") and tubelib2.version < 2.2 then
	minetest.log("error", "[techage] Techage requires tubelib2 version 2.2 or newer!")
	return
elseif minetest.global_exists("minecart") and minecart.version < 1.08 then
	minetest.log("error", "[techage] Techage requires minecart version 1.08 or newer!")
	return
elseif minetest.global_exists("lcdlib") and lcdlib.version < 1.01 then
	minetest.log("error", "[techage] Techage requires lcdlib version 1.01 or newer!")
	return
elseif minetest.global_exists("safer_lua") and safer_lua.version < 1.01 then
	minetest.log("error", "[techage] Techage requires safer_lua version 1.01 or newer!")
	return
elseif minetest.global_exists("networks") and networks.version < 0.10 then
	minetest.log("error", "[techage] Techage requires networks version 0.10 or newer!")
	return
elseif minetest.global_exists("hyperloop") and hyperloop.version < 2.07 then
	minetest.log("error", "[techage] Techage requires hyperloop version 2.07 or newer!")
	return
end

-- Test MT 5.4 new string mode
techage.CLIP  = minetest.features.use_texture_alpha_string_modes and "clip" or false
techage.BLEND = minetest.features.use_texture_alpha_string_modes and "blend" or true

techage.NodeDef = {}		-- node registration info

techage.max_num_forceload_blocks = tonumber(minetest.settings:get("techage_max_num_forceload_blocks")) or 24

techage.basalt_stone_enabled = minetest.settings:get_bool("techage_basalt_stone_enabled") ~= false
techage.ore_rarity = tonumber(minetest.settings:get("techage_ore_rarity")) or 1
techage.modified_recipes_enabled = minetest.settings:get_bool("techage_modified_recipes_enabled") ~= false
techage.collider_min_depth = tonumber(minetest.settings:get("techage_collider_min_depth")) or -28

-- allow to load marshal and sqlite3
techage.IE = minetest.request_insecure_environment()

-- Load support for I18n.
techage.S = minetest.get_translator("techage")

-- Load mod storage
techage.storage = minetest.get_mod_storage()

-- Ensure compatibility with older Minetest versions by providing
-- a dummy implementation of `minetest.get_translated_string`.
if not minetest.get_translated_string then
	minetest.get_translated_string = function(lang_code, string)
		return string
	end
end

-- Basis features
local MP = minetest.get_modpath("techage")
dofile(MP.."/basis/lib.lua")  -- helper functions
dofile(MP.."/basis/counting.lua")  -- command counting
dofile(MP.."/basis/fake_player.lua")  -- dummy player object
dofile(MP.."/basis/node_store.lua")
dofile(MP.."/basis/gravel_lib.lua")  -- ore probability
dofile(MP.."/basis/node_states.lua") -- state model
dofile(MP.."/basis/tubes.lua")  -- tubes for item transport
dofile(MP.."/basis/tubes_ta4.lua")  -- TA4 tubes for item transport
dofile(MP.."/basis/tube_wall_entry.lua")
dofile(MP.."/basis/command.lua")  -- command API
dofile(MP.."/basis/firebox_lib.lua")  -- common firebox functions
dofile(MP.."/basis/boiler_lib.lua")  -- common boiler functions
dofile(MP.."/basis/liquid_lib.lua")  -- common liquids functions
dofile(MP.."/basis/fuel_lib.lua")  -- common fuel functions
dofile(MP.."/basis/mark.lua")
dofile(MP.."/basis/mark2.lua")
dofile(MP.."/basis/assemble.lua")
dofile(MP.."/basis/recipe_lib.lua")
dofile(MP.."/basis/formspec_update.lua")
dofile(MP.."/basis/windturbine_lib.lua")
dofile(MP.."/basis/laser_lib.lua")
dofile(MP.."/basis/legacy.lua")
dofile(MP.."/basis/hyperloop.lua")
dofile(MP.."/basis/oggfiles.lua")
dofile(MP.."/basis/submenu.lua")
dofile(MP.."/basis/shared_inv.lua")
dofile(MP.."/basis/shared_tank.lua")
dofile(MP.."/basis/teleport.lua")

-- Main doc
dofile(MP.."/doc/manual_DE.lua")
dofile(MP.."/doc/manual_EN.lua")
dofile(MP.."/doc/plans.lua")
dofile(MP.."/doc/items.lua")
dofile(MP.."/doc/guide.lua")  -- construction guides
dofile(MP.."/doc/manual_api.lua")  -- external API

dofile(MP.."/items/filling.lua")

-- Power networks
dofile(MP.."/power/formspecs.lua")
dofile(MP.."/power/drive_axle.lua")
dofile(MP.."/power/gearbox.lua")
dofile(MP.."/power/steam_pipe.lua")
dofile(MP.."/power/electric_cable.lua")
dofile(MP.."/power/junctionbox.lua")
dofile(MP.."/power/power_terminal.lua")
dofile(MP.."/power/power_terminal2.lua")
dofile(MP.."/power/powerswitchbox_legacy.lua")
dofile(MP.."/power/powerswitchbox.lua")
dofile(MP.."/power/powerswitch.lua")
dofile(MP.."/power/protection.lua")
dofile(MP.."/power/power_line.lua")
dofile(MP.."/power/ta4_cable.lua")
dofile(MP.."/power/ta4_cable_wall_entry.lua")

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

-- TA1 Watermill
dofile(MP.."/ta1_watermill/ta1_axle.lua")
dofile(MP.."/ta1_watermill/watermill.lua")
dofile(MP.."/ta1_watermill/sluice.lua")
dofile(MP.."/ta1_watermill/millboard.lua")
dofile(MP.."/ta1_watermill/mill.lua")

dofile(MP.."/iron_age/recipes.lua")
if minetest.global_exists("wielded_light") or minetest.global_exists("illumination") then
	dofile(MP.."/iron_age/meridium.lua")
end

-- Steam Engine
dofile(MP.."/steam_engine/firebox.lua")
dofile(MP.."/steam_engine/boiler.lua")
dofile(MP.."/steam_engine/cylinder.lua")
dofile(MP.."/steam_engine/flywheel.lua")

-- TA2 gravity-based energy storage
dofile(MP.."/ta2_energy_storage/ta2_rope.lua")
dofile(MP.."/ta2_energy_storage/ta2_winch.lua")
dofile(MP.."/ta2_energy_storage/ta2_weight_chest.lua")

-- Liquids I
dofile(MP.."/liquids/liquid_pipe.lua")
dofile(MP.."/liquids/valve.lua")
dofile(MP.."/liquids/pipe_wall_entry.lua")
dofile(MP.."/fusion_reactor/gas_pipe.lua")


-- Basic Machines
dofile(MP.."/basic_machines/consumer.lua")  -- consumer base model
dofile(MP.."/basic_machines/source.lua")
dofile(MP.."/basic_machines/pusher.lua")
dofile(MP.."/basic_machines/foreign_nodes.lua")
dofile(MP.."/basic_machines/mods_support.lua")
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
dofile(MP.."/basic_machines/ta4_injector.lua")
dofile(MP.."/basic_machines/itemsource.lua")
dofile(MP.."/basic_machines/recycler.lua")
dofile(MP.."/basic_machines/concentrator.lua")
dofile(MP.."/basic_machines/recipeblock.lua")
dofile(MP.."/basic_machines/ta5_chest.lua")

-- Liquids II
dofile(MP.."/liquids/tank.lua")
dofile(MP.."/liquids/filler.lua")
dofile(MP.."/liquids/silo.lua")
dofile(MP.."/liquids/pump.lua")
dofile(MP.."/liquids/waterpump.lua")
dofile(MP.."/liquids/waterinlet.lua")
dofile(MP.."/liquids/ta5_tank.lua")

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
dofile(MP.."/tools/screwdriver.lua")

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
--  dofile(MP.."/oil/gasflare.lua")

-- TA3 power based
dofile(MP.."/ta3_power/tiny_generator.lua")
dofile(MP.."/ta3_power/akkubox.lua")
dofile(MP.."/ta3_power/axle2power.lua")
dofile(MP.."/ta3_power/power2axle.lua")

-- TA4 power based
dofile(MP.."/ta4_power/laser.lua")
dofile(MP.."/ta4_power/transformer.lua")
dofile(MP.."/ta4_power/electricmeter.lua")

-- Digtron
if minetest.global_exists("digtron") then
	dofile(MP.."/digtron/battery.lua")
end

-- Logic
dofile(MP.."/logic/lib.lua")
dofile(MP.."/logic/terminal.lua")
dofile(MP.."/logic/button.lua")
dofile(MP.."/logic/detector.lua")
dofile(MP.."/logic/repeater.lua")
dofile(MP.."/logic/programmer.lua")
dofile(MP.."/logic/signallamp.lua")
dofile(MP.."/logic/sequencer.lua")
dofile(MP.."/logic/sequencer2.lua")
dofile(MP.."/logic/timer.lua")
dofile(MP.."/logic/lua_logic.lua")  -- old
dofile(MP.."/logic/logic_block.lua")  -- new
dofile(MP.."/logic/node_detector.lua")
dofile(MP.."/logic/light_detector.lua")
dofile(MP.."/logic/player_detector.lua")
dofile(MP.."/logic/mba_detector.lua")
dofile(MP.."/logic/cart_detector.lua")
dofile(MP.."/logic/collector.lua")
dofile(MP.."/logic/button_2x.lua")
dofile(MP.."/logic/button_4x.lua")
dofile(MP.."/logic/signallamp_2x.lua")
dofile(MP.."/logic/signallamp_4x.lua")
if minetest.global_exists("mesecon") then
	dofile(MP.."/logic/mesecons_converter.lua")
end

-- move_controller
dofile(MP.."/move_controller/gateblock.lua")
dofile(MP.."/move_controller/doorblock.lua")
dofile(MP.."/move_controller/doorcontroller.lua")  -- old
dofile(MP.."/move_controller/doorcontroller2.lua")  -- new
dofile(MP.."/move_controller/movecontroller.lua")
dofile(MP.."/move_controller/turncontroller.lua")
dofile(MP.."/move_controller/flycontroller.lua")
dofile(MP.."/move_controller/soundblock.lua")


-- Test
dofile(MP.."/recipe_checker.lua")
dofile(MP.."/.test/sink.lua")

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
dofile(MP.."/chemistry/ta4_liquid_filter.lua")

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
dofile(MP.."/items/registered_nodes.lua")
dofile(MP.."/items/barrel.lua")
dofile(MP.."/items/baborium.lua")
dofile(MP.."/items/usmium.lua")
dofile(MP.."/items/lye.lua")
dofile(MP.."/items/oil.lua")
dofile(MP.."/items/petroleum.lua")
dofile(MP.."/items/bauxit.lua")
dofile(MP.."/items/silicon.lua")
dofile(MP.."/items/steelmat.lua")
dofile(MP.."/items/aluminium.lua")
dofile(MP.."/items/powder.lua")
dofile(MP.."/items/epoxy.lua")
dofile(MP.."/items/plastic.lua")
dofile(MP.."/items/hydrogen.lua")
dofile(MP.."/items/electronic.lua")
dofile(MP.."/items/redstone.lua")
dofile(MP.."/items/cement.lua")
dofile(MP.."/items/cracking.lua")
dofile(MP.."/items/ceramic.lua")
dofile(MP.."/items/basalt.lua")
dofile(MP.."/items/moreblocks.lua")

-- Carts
dofile(MP.."/carts/tank_cart.lua")
dofile(MP.."/carts/chest_cart.lua")

-- TA4 Collider
dofile(MP.."/collider/vacuumtube.lua")
dofile(MP.."/collider/magnet.lua")
dofile(MP.."/collider/inlets.lua")
dofile(MP.."/collider/cooler.lua")
dofile(MP.."/collider/detector.lua")
dofile(MP.."/collider/worker.lua")

-- TA5 Teleport
dofile(MP.."/teleport/teleport_tube.lua")
dofile(MP.."/teleport/teleport_pipe.lua")

-- TA5 Fusion Reactor
dofile(MP.."/fusion_reactor/shell.lua")
dofile(MP.."/fusion_reactor/magnet.lua")
dofile(MP.."/fusion_reactor/controller.lua")
dofile(MP.."/fusion_reactor/heatexchanger3.lua")
dofile(MP.."/fusion_reactor/heatexchanger2.lua")
dofile(MP.."/fusion_reactor/heatexchanger1.lua")
dofile(MP.."/fusion_reactor/generator.lua")
dofile(MP.."/fusion_reactor/turbine.lua")
dofile(MP.."/fusion_reactor/ta5_pump.lua")

-- Beduino extensions
dofile(MP.."/beduino/kv_store.lua")

-- Prevent other mods from using IE
techage.IE = nil
