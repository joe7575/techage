
if minetest.global_exists("tubelib") then
	minetest.log("error", "[techage] Techage can't be used together with the mod tubelib!")
elseif minetest.global_exists("ironage") then
	minetest.log("error", "[techage] Techage can't be used together with the mod ironage!")
elseif minetest.global_exists("techpack") then
	minetest.log("error", "[techage] Techage can't be used together with the modpack techpack!")
elseif minetest.global_exists("tubelib2") and tubelib2.version < 1.5 then
	minetest.log("error", "[techage] Techage requires tubelib2 version 1.5 or newer!")
else
	techage = {
		NodeDef = {},		-- node registration info
	}
	techage.max_num_forceload_blocks = tonumber(minetest.setting_get("techage_max_num_forceload_blocks")) or 16
	techage.basalt_stone_enabled = minetest.setting_get("techage_basalt_stone_enabled") == "true"
	techage.ore_rarity = tonumber(minetest.setting_get("techage_ore_rarity")) or 1
	techage.modified_recipes_enabled = minetest.setting_get("techage_modified_recipes_enabled") == "true"

	-- Load support for I18n.
	techage.S = minetest.get_translator("techage")
	
	-- Debugging via "mydbg(topic, text)"
	techage.DebugTopics = {
		--con = true,  -- consumer modell
		--pwr = true,  -- power distribution
		--sts = true,  -- status plots
		--dbg = true,
		--dbg2 = true,
		--tst = true,
		--bot = true  -- Signs Bot
	}

	-- Basis features
	local MP = minetest.get_modpath("techage")
	dofile(MP.."/basis/lib.lua")  -- helper functions
	dofile(MP.."/basis/gravel_lib.lua")  -- ore probability
	dofile(MP.."/basis/guide.lua")  -- construction guide
	dofile(MP.."/basis/node_states.lua") -- state model
	dofile(MP.."/basis/tubes.lua")  -- tubelib replacement
	dofile(MP.."/basis/command.lua")  -- tubelib replacement
	dofile(MP.."/basis/firebox_lib.lua")  -- common firebox functions
	dofile(MP.."/basis/mark.lua")
	dofile(MP.."/basis/assemble.lua")

	-- Main doc
	dofile(MP.."/doc/doc.lua")
	dofile(MP.."/doc/ta1_doc.lua")
	dofile(MP.."/doc/ta2_doc.lua")
	dofile(MP.."/doc/ta3_doc.lua")
	
	-- Nodes1
	dofile(MP.."/nodes/baborium.lua")
	dofile(MP.."/nodes/usmium.lua")
	
	-- Power networks
	dofile(MP.."/power/power.lua")
	dofile(MP.."/power/power2.lua")
	dofile(MP.."/power/junction.lua") 
	dofile(MP.."/power/drive_axle.lua")
	dofile(MP.."/power/steam_pipe.lua")
	dofile(MP.."/power/biogas_pipe.lua")
	dofile(MP.."/power/electric_cable.lua")
	dofile(MP.."/power/power_line.lua")
	dofile(MP.."/power/junctionbox.lua")
	dofile(MP.."/power/powerswitch.lua")

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
	dofile(MP.."/steam_engine/help.lua")
	dofile(MP.."/steam_engine/firebox.lua")
	dofile(MP.."/steam_engine/boiler.lua")
	dofile(MP.."/steam_engine/cylinder.lua")
	dofile(MP.."/steam_engine/flywheel.lua")
	dofile(MP.."/steam_engine/gearbox.lua")
	
	-- Basic Machines
	dofile(MP.."/basis/consumer.lua")  -- consumer base model
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

	-- Coal power station
	dofile(MP.."/coal_power_station/firebox.lua")
	dofile(MP.."/coal_power_station/boiler_base.lua")
	dofile(MP.."/coal_power_station/boiler_top.lua")
	dofile(MP.."/coal_power_station/generator.lua")
	dofile(MP.."/coal_power_station/turbine.lua")
	dofile(MP.."/coal_power_station/cooler.lua")
	dofile(MP.."/coal_power_station/akkubox.lua")
	dofile(MP.."/coal_power_station/power_terminal.lua")
	
	-- Industrial Furnace
	dofile(MP.."/furnace/help.lua")
	dofile(MP.."/furnace/firebox.lua")
	dofile(MP.."/furnace/cooking.lua")
	dofile(MP.."/furnace/furnace_top.lua")
	dofile(MP.."/furnace/booster.lua")
	dofile(MP.."/furnace/recipes.lua")
	
	-- Tools
	dofile(MP.."/doc/ta_doc.lua")
	dofile(MP.."/tools/trowel.lua")
	dofile(MP.."/tools/repairkit.lua")
	dofile(MP.."/basic_machines/blackhole.lua")
	dofile(MP.."/basic_machines/forceload.lua")
	
	-- Lamps
	dofile(MP.."/lamps/lib.lua")
	dofile(MP.."/lamps/simplelamp.lua")
	dofile(MP.."/lamps/streetlamp.lua")
	dofile(MP.."/lamps/ceilinglamp.lua")
	dofile(MP.."/lamps/industriallamp1.lua")
	dofile(MP.."/lamps/industriallamp2.lua")
	dofile(MP.."/lamps/industriallamp3.lua")
	
	-- Oil
	dofile(MP.."/oil/explore.lua")
	dofile(MP.."/oil/tower.lua")
	dofile(MP.."/oil/drillbox.lua")
	dofile(MP.."/oil/pumpjack.lua")
	dofile(MP.."/oil/generator.lua")
	
	-- Nodes2
	if techage.basalt_stone_enabled then
		dofile(MP.."/nodes/basalt.lua")
	end
	
	-- Logic
	dofile(MP.."/logic/terminal.lua")

	-- Test
	dofile(MP.."/recipe_checker.lua")
	dofile(MP.."/.test/sink.lua")
	dofile(MP.."/.test/source.lua")
	dofile(MP.."/.test/akku.lua")
	--dofile(MP.."/.test/switch.lua")
	
	-- Solar
	dofile(MP.."/nodes/silicon.lua")
	dofile(MP.."/solar/minicell.lua")
	
end