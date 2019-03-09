techage = {
	NodeDef = {},		-- node registration info
}


techage.max_num_forceload_blocks = tonumber(minetest.setting_get("techage_max_num_forceload_blocks")) or 12
techage.basalt_stone_enabled = minetest.setting_get("techage_basalt_stone_enabled") == "true"
techage.machine_aging_value = tonumber(minetest.setting_get("techage_machine_aging_value")) or 100


local MP = minetest.get_modpath("techage")

-- Load support for intllib.
dofile(MP.."/basis/intllib.lua")

dofile(MP.."/basis/power.lua")  -- power distribution
dofile(MP.."/basis/node_states.lua")
dofile(MP.."/basis/trowel.lua")  -- hidden networks
dofile(MP.."/basis/junction.lua")  -- network junction box
dofile(MP.."/basis/tubes.lua")  -- tubelib replacement
dofile(MP.."/basis/command.lua")  -- tubelib replacement

-- Steam Engine
dofile(MP.."/steam_engine/drive_axle.lua")
dofile(MP.."/steam_engine/steam_pipe.lua")
dofile(MP.."/steam_engine/firebox.lua")
dofile(MP.."/steam_engine/boiler.lua")
dofile(MP.."/steam_engine/cylinder.lua")
dofile(MP.."/steam_engine/flywheel.lua")
dofile(MP.."/steam_engine/gearbox.lua")
dofile(MP.."/steam_engine/consumer.lua")

dofile(MP.."/electric/electric_cable.lua")
dofile(MP.."/electric/test.lua")
dofile(MP.."/electric/generator.lua")
dofile(MP.."/electric/consumer.lua")

dofile(MP.."/basic_machines/pusher.lua")
dofile(MP.."/basic_machines/legacy_nodes.lua")


--dofile(MP.."/fermenter/biogas_pipe.lua")
--dofile(MP.."/fermenter/gasflare.lua")


dofile(MP.."/nodes/test.lua")
--dofile(MP.."/mechanic/perf_test.lua")
