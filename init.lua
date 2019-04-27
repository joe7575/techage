techage = {
	NodeDef = {},		-- node registration info
}


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
dofile(MP.."/basis/guide.lua")  -- construction guide
dofile(MP.."/basis/power.lua")  -- power distribution
dofile(MP.."/basis/node_states.lua")
dofile(MP.."/basis/trowel.lua")  -- hidden networks
dofile(MP.."/basis/junction.lua")  -- network junction box
dofile(MP.."/basis/tubes.lua")  -- tubelib replacement
dofile(MP.."/basis/command.lua")  -- tubelib replacement
dofile(MP.."/basis/consumer.lua")  -- consumer base model
dofile(MP.."/basis/steam_pipe.lua")
dofile(MP.."/basis/firebox.lua")

-- Iron Age
dofile(MP.."/iron_age/main.lua")
dofile(MP.."/iron_age/gravelsieve.lua")
dofile(MP.."/iron_age/hammer.lua")
dofile(MP.."/iron_age/lighter.lua")
dofile(MP.."/iron_age/charcoalpile.lua")
dofile(MP.."/iron_age/coalburner.lua")
dofile(MP.."/iron_age/meltingpot.lua")
if techage.modified_recipes_enabled then
	dofile(MP.."/iron_age/tools.lua")
end
dofile(MP.."/iron_age/recipes.lua")
dofile(MP.."/iron_age/help.lua")
if minetest.global_exists("wielded_light") then
	dofile(MP.."/iron_age/meridium.lua")
end

-- Steam Engine
dofile(MP.."/steam_engine/drive_axle.lua")
dofile(MP.."/steam_engine/firebox.lua")
dofile(MP.."/steam_engine/boiler.lua")
dofile(MP.."/steam_engine/cylinder.lua")
dofile(MP.."/steam_engine/flywheel.lua")
dofile(MP.."/steam_engine/gearbox.lua")
dofile(MP.."/steam_engine/consumer.lua")
dofile(MP.."/steam_engine/battery.lua")

dofile(MP.."/electric/electric_cable.lua")
dofile(MP.."/electric/test.lua")
dofile(MP.."/electric/generator.lua")
dofile(MP.."/electric/consumer.lua")

-- Basic Machines
dofile(MP.."/basic_machines/pusher.lua")
dofile(MP.."/basic_machines/legacy_nodes.lua")
dofile(MP.."/basic_machines/grinder.lua")
dofile(MP.."/basic_machines/distributor.lua")
dofile(MP.."/basic_machines/gravelsieve.lua")
dofile(MP.."/basic_machines/chest.lua")

-- Coal power station
dofile(MP.."/coal_power_station/firebox.lua")


--dofile(MP.."/fermenter/biogas_pipe.lua")
--dofile(MP.."/fermenter/gasflare.lua")


--dofile(MP.."/nodes/test.lua")
--dofile(MP.."/mechanic/perf_test.lua")
