techage = {
	NodeDef = {},		-- node registration info
}

if minetest.global_exists("tubelib") then
	minetest.log("error", "[techage] Techage can't be used together with the mod tubelib!")
elseif minetest.global_exists("ironage") then
	minetest.log("error", "[techage] Techage can't be used together with the mod ironage!")
elseif minetest.global_exists("techpack") then
	minetest.log("error", "[techage] Techage can't be used together with the modpack techpack!")
elseif minetest.global_exists("tubelib2") and tubelib2.version < 1.4 then
	minetest.log("error", "[techage] Techage requires tubelib2 version 1.4 or newer!")
else
	techage.max_num_forceload_blocks = tonumber(minetest.setting_get("techage_max_num_forceload_blocks")) or 12
	techage.basalt_stone_enabled = minetest.setting_get("techage_basalt_stone_enabled") == "true"
	techage.machine_aging_value = tonumber(minetest.setting_get("techage_machine_aging_value")) or 100
	techage.ore_rarity = tonumber(minetest.setting_get("techage_ore_rarity")) or 1
	techage.modified_recipes_enabled = minetest.setting_get("techage_modified_recipes_enabled") == "true"

	local MP = minetest.get_modpath("techage")

	-- Load support for intllib.
	dofile(MP.."/basis/intllib.lua")

	-- Basis features
	dofile(MP.."/basis/lib.lua")  -- helper functions
	dofile(MP.."/basis/gravel_lib.lua")  -- ore probability
	dofile(MP.."/basis/guide.lua")  -- construction guide
	dofile(MP.."/basis/node_states.lua") -- state model
	dofile(MP.."/basis/tubes.lua")  -- tubelib replacement
	dofile(MP.."/basis/command.lua")  -- tubelib replacement
	dofile(MP.."/basis/consumer.lua")  -- consumer base model
	dofile(MP.."/basis/firebox_lib.lua")  -- common firebox functions
	
	-- Overrides
	dofile(MP.."/overrides/signs_bot.lua")
	
	-- Tools
	dofile(MP.."/tools/trowel.lua")
	dofile(MP.."/tools/repairkit.lua")
	
	-- Nodes
	dofile(MP.."/nodes/baborium.lua")
	dofile(MP.."/nodes/usmium.lua")
	
	-- Power networks
	dofile(MP.."/power/power.lua")
	dofile(MP.."/power/junction.lua") 
	dofile(MP.."/power/drive_axle.lua")
	dofile(MP.."/power/steam_pipe.lua")
	dofile(MP.."/power/biogas_pipe.lua")
	dofile(MP.."/power/electric_cable.lua")
	dofile(MP.."/power/junctionbox.lua")

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
	dofile(MP.."/basic_machines/source.lua")
	dofile(MP.."/basic_machines/pusher.lua")
	dofile(MP.."/basic_machines/blackhole.lua")
	dofile(MP.."/basic_machines/legacy_nodes.lua")
	dofile(MP.."/basic_machines/grinder.lua")
	dofile(MP.."/basic_machines/distributor.lua")
	dofile(MP.."/basic_machines/gravelsieve.lua")
	dofile(MP.."/basic_machines/gravelrinser.lua")
	dofile(MP.."/basic_machines/chest.lua")
	dofile(MP.."/basic_machines/autocrafter.lua")
	dofile(MP.."/basic_machines/mark.lua")
	dofile(MP.."/basic_machines/forceload.lua")
	dofile(MP.."/basic_machines/electronic_fab.lua")
	if techage.basalt_stone_enabled then
		dofile(MP.."/basic_machines/basalt.lua")
	end

	-- Coal power station
	dofile(MP.."/coal_power_station/help.lua")
	dofile(MP.."/coal_power_station/firebox.lua")
	dofile(MP.."/coal_power_station/boiler_base.lua")
	dofile(MP.."/coal_power_station/boiler_top.lua")
	dofile(MP.."/coal_power_station/generator.lua")
	dofile(MP.."/coal_power_station/turbine.lua")
	dofile(MP.."/coal_power_station/cooler.lua")
	dofile(MP.."/coal_power_station/akkubox.lua")

	--dofile(MP.."/test/generator.lua")
	--dofile(MP.."/test/lamp.lua")
--	dofile(MP.."/test/consumer.lua")
	--dofile(MP.."/test/consumer2.lua")
	--dofile(MP.."/test/test.lua")


	--dofile(MP.."/fermenter/gasflare.lua")


	--dofile(MP.."/nodes/test.lua")
	--dofile(MP.."/mechanic/perf_test.lua")
end