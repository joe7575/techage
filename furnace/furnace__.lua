
--[[

	=======================================================================
	Tubelib Biogas Machines Mod
	by Micu (c) 2018, 2019

	Copyright (C) 2018, 2019 Michal Cieslakiewicz

	Biogas Jet Furnace is an upgraded version of standard Gas Furnace.
	It works 2 times faster in both item cooking speed and Biogas
	consumption. One unit of Biogas lasts for 20 seconds but items
	are cooked twice as fast. However, this puts more stress on internal
	parts so machine needs to be serviced more frequently.
	Please see gasfurnace.lua for differences between Biogas and Coal
	furnaces as this device is functionally identical to Gas Furnace.
	The only extra upgrade is support for pulling whole stacks from
	output tray (like HighPerf Chest), so its output can be paired with
	HighPerf Pusher.

	Note about implementation: to maintain timer at 1 sec while halving
	cooking time a random factor has been introduced for all cooking
	durations that are odd numbers. Such items will cook either longer or
	quicker with 50/50 probability. Example: from 10 iron lumps that have
	standard cooking time 3 sec each, ~5 items should cook for 2 sec and
	~5 for 1 sec giving average cooking time 1.5 sec and using proper
	amount of Biogas.

	Tubelib v2 implementation info:
	* device updates itself every tick, so cycle_time must be set to 1
	  even though production takes longer (start method sets timer to
	  this value)
	* keep_running function is called every time item is produced
	  (not every processing tick - function does not accept neither 0
	  nor fractional values for num_items parameter)
	* desired_state metadata allows to properly change non-running target
	  state during transition; when new state differs from old one, timer
	  is reset so it is guaranteed that each countdown starts from
	  COUNTDOWN_TICKS
	* num_items in keep_running method is set to 1 (default value);
	  machine aging is controlled by aging_factor solely; tubelib item
	  counter is used to count production iterations not actual items

	License: LGPLv2.1+
	=======================================================================
	
]]--

--[[
        ---------
        Variables
        ---------
]]--

-- Jet Furnace uses Biogas twice as fast so 1 Biogas unit burns for 20 sec
local BIOGAS_TICKS = 20
-- timing
local TIMER_TICK_SEC = 1		-- Node timer tick
local STANDBY_TICKS = 4			-- Standby mode timer frequency factor
local COUNTDOWN_TICKS = 4		-- Ticks to standby

-- machine inventory
local INV_H = 3				-- Inventory height
local INV_IN_W = 3			-- Input inventory width
local INV_OUT_W = (6 - INV_IN_W)	-- Output inventory width

--[[
	--------
	Formspec
	--------
]]--
-- static data for formspec
local fmxy = {
	inv_h = tostring(INV_H),
        inv_in_w = tostring(INV_IN_W),
        mid_x = tostring(INV_IN_W + 1),
        inv_out_w = tostring(INV_OUT_W),
        inv_out_x = tostring(INV_IN_W + 2),
	biogas_time = tostring(BIOGAS_TICKS * TIMER_TICK_SEC)
}

-- formspec
local function formspec(self, pos, meta)
	local state = meta:get_int("tubelib_state")
	local fuel_pct = tostring(100 * meta:get_int("fuel_ticks") / BIOGAS_TICKS)
	local item_pct = tostring(100 * (1 - meta:get_int("item_ticks") / meta:get_int("item_total")))
	return "size[8,8.25]" ..
	default.gui_bg ..
	default.gui_bg_img ..
	default.gui_slots ..
	"list[context;src;0,0;" .. fmxy.inv_in_w .. "," .. fmxy.inv_h .. ";]" ..
	"list[context;cur;" .. fmxy.inv_in_w .. ",0;1,1;]" ..
	"image[" .. fmxy.inv_in_w ..
		",1;1,1;biogasmachines_gasfurnace_inv_bg.png^[lowpart:" ..
		fuel_pct .. ":biogasmachines_gasfurnace_inv_fg.png]" ..
	"image[" .. fmxy.mid_x .. ",1;1,1;gui_furnace_arrow_bg.png^[lowpart:" ..
		item_pct .. ":gui_furnace_arrow_fg.png^[transformR270]" ..
	"list[context;fuel;" .. fmxy.inv_in_w .. ",2;1,1;]" ..
	"item_image[" .. fmxy.inv_in_w .. ",2;1,1;tubelib_addons1:biogas]" ..
	"image_button[" .. fmxy.mid_x .. ",2;1,1;" ..
		self:get_state_button_image(meta) .. ";state_button;]" ..
	"item_image[2,3.25;0.5,0.5;biogasmachines:jetfurnace]" ..
	"label[2.5,3.25;=]" ..
	"item_image[2.75,3.25;0.5,0.5;default:furnace]" ..
	"label[3.25,3.25;x 2]" ..
	"item_image[4.5,3.25;0.5,0.5;tubelib_addons1:biogas]" ..
	"tooltip[4.5,3.25;0.5,0.5;Biogas]" ..
	"label[5,3.25;= " .. fmxy.biogas_time .. " sec]" ..
	"list[context;dst;" .. fmxy.inv_out_x .. ",0;" .. fmxy.inv_out_w ..
		"," .. fmxy.inv_h .. ";]" ..
	"list[current_player;main;0,4;8,1;]" ..
	"list[current_player;main;0,5.25;8,3;8]" ..
	"listring[context;dst]" ..
	"listring[current_player;main]" ..
	"listring[context;src]" ..
	"listring[current_player;main]" ..
	"listring[context;fuel]" ..
	"listring[current_player;main]" ..
	(state == tubelib.RUNNING and
                "box[" .. fmxy.inv_in_w .. ",0;0.82,0.88;#BF5F2F]" or
                "listring[context;cur]listring[current_player;main]") ..
	default.get_hotbar_bg(0, 4)
end

--[[
	-------
	Helpers
	-------
]]--

-- reset processing data
local function state_meta_reset(pos, meta)
	meta:set_int("item_ticks", -1)
	meta:set_int("item_total", -1)
end

-- Wrapper for 'cooking' get_craft_result() function for specified ItemStack
-- Return values are as follows:
-- time - cooking time or 0 if not cookable
-- input - input itemstack (take it from source stack to get decremented input)
-- output - output itemstack array (all extra leftover products are also here)
-- decr_input - decremented input (without leftover products)
local function get_cooking_items(stack)
	if stack:is_empty() then
		return 0, nil, nil, nil
	end
	local cookout, decinp = minetest.get_craft_result({ method = "cooking",
		width = 1, items = { stack } })
	if cookout.time <= 0 or cookout.item:is_empty() then
		return 0, nil, nil, nil
	end
	local inp = stack
	local outp = { cookout.item }
	local decp = decinp and decinp.items and decinp.items[1] or nil
	if decp and not decp:is_empty() then
		if decp:get_name() ~= stack:get_name() then
			outp[#outp + 1] = decp
			decp = ItemStack({})
		else
			inp = ItemStack(stack:get_name() .. " " ..
			tostring(stack:get_count() - decp:get_count()))
		end
	end
	return cookout.time, inp, outp, decp
end

-- calculates fast (jet) cooking time, adding randomly 1 (with 50/50 chance)
-- to odd durations to compensate halves
local function get_fast_cooking_time(time)
	local otime = math.max(math.floor(time + 0.5), 2)	-- rounding
	local ntime = math.floor(otime / 2)
	if otime % 2 == 0 then
		return ntime
	else
		return math.random(ntime, ntime + 1)
	end
end

--[[
	-------------
	State machine
	-------------
]]--

local machine = tubelib.NodeStates:new({
	node_name_passive = "biogasmachines:jetfurnace",
	node_name_active = "biogasmachines:jetfurnace_active",
	node_name_defect = "biogasmachines:jetfurnace_defect",
	infotext_name = "Biogas Jet Furnace",
	cycle_time = TIMER_TICK_SEC,
	standby_ticks = STANDBY_TICKS,
	has_item_meter = true,
	aging_factor = 20,
	on_start = function(pos, meta, oldstate)
		meta:set_int("desired_state", tubelib.RUNNING)
		state_meta_reset(pos, meta)
	end,
	on_stop = function(pos, meta, oldstate)
		meta:set_int("desired_state", tubelib.STOPPED)
		state_meta_reset(pos, meta)
	end,
	formspec_func = formspec,
})

-- fault function for convenience as there is no on_fault method (yet)
local function machine_fault(pos, meta)
	meta:set_int("desired_state", tubelib.FAULT)
	state_meta_reset(pos, meta)
	machine:fault(pos, meta)
end

-- customized version of NodeStates:idle()
local function countdown_to_halt(pos, meta, target_state)
	if target_state ~= tubelib.STANDBY and
	   target_state ~= tubelib.BLOCKED and
	   target_state ~= tubelib.STOPPED and
	   target_state ~= tubelib.FAULT then
		return true
	end
	if machine:get_state(meta) == tubelib.RUNNING and
	   meta:get_int("desired_state") ~= target_state then
		meta:set_int("tubelib_countdown", COUNTDOWN_TICKS)
		meta:set_int("desired_state", target_state)
	end
	local countdown = meta:get_int("tubelib_countdown") - 1
	if countdown >= -1 then
		-- we don't need anything less than -1
		meta:set_int("tubelib_countdown", countdown)
	end
	if countdown < 0 then
		if machine:get_state(meta) == target_state then
			return true
		end
		meta:set_int("desired_state", target_state)
		-- workaround for switching between non-running states
		meta:set_int("tubelib_state", tubelib.RUNNING)
		if target_state == tubelib.FAULT then
			machine_fault(pos, meta)
		elseif target_state == tubelib.STOPPED then
			machine:stop(pos, meta)
		elseif target_state == tubelib.BLOCKED then
			machine:blocked(pos, meta)
		else
			machine:standby(pos, meta)
		end
		return false
	end
	return true
end

-- countdown to one of two states depending on fuel availability
local function fuel_countdown_to_halt(pos, meta, target_state_fuel, target_state_empty)
	local inv = meta:get_inventory()
	if meta:get_int("fuel_ticks") == 0 and inv:is_empty("fuel") then
		return countdown_to_halt(pos, meta, target_state_empty)
	else
		return countdown_to_halt(pos, meta, target_state_fuel)
	end
end

--[[
	---------
	Callbacks
	---------
]]--

-- do not allow to dig protected or non-empty machine
local function can_dig(pos, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return false
	end
	local meta = minetest.get_meta(pos);
	local inv = meta:get_inventory()
	return inv:is_empty("src") and inv:is_empty("dst")
		and inv:is_empty("fuel")
end

-- cleanup after digging
local function after_dig_node(pos, oldnode, oldmetadata, digger)
	tubelib.remove_node(pos)
end

-- init machine after placement
local function after_place_node(pos, placer, itemstack, pointed_thing)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	inv:set_size('src', INV_H * INV_IN_W)
	inv:set_size('cur', 1)
	inv:set_size('fuel', 1)
	inv:set_size('dst', INV_H * INV_OUT_W)
	meta:set_string("owner", placer:get_player_name())
	meta:set_int("fuel_ticks", 0)
	state_meta_reset(pos, meta)
	local number = tubelib.add_node(pos, "biogasmachines:jetfurnace")
	machine:node_init(pos, number)
end

-- validate incoming items
local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	if listname == "src" then
		if stack:get_name() == "tubelib_addons1:biogas" then
			return 0
		else
			return stack:get_count()
		end
	elseif listname == "cur" or listname == "dst" then
		return 0
	elseif listname == "fuel" then
		if stack:get_name() == "tubelib_addons1:biogas" then
			return stack:get_count()
		else
			return 0
		end
	end
	return 0
end

-- validate items move
local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local meta = minetest.get_meta(pos)
	if to_list == "cur" or
	   (from_list == "cur" and machine:get_state(meta) == tubelib.RUNNING) then
		return 0
	end
	local inv = meta:get_inventory()
	local stack = inv:get_stack(from_list, from_index)
	return allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

-- validate items retrieval
local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	if listname == "cur" then
		local meta = minetest.get_meta(pos)
		if machine:get_state(meta) == tubelib.RUNNING then
			return 0
		end
	end
	return stack:get_count()
end

-- formspec callback
local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end
	machine:state_button_event(pos, fields)
end

-- tick-based item production
local function on_timer(pos, elapsed)
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local fuel = meta:get_int("fuel_ticks")
	local recipe = {}
	local inp
	if inv:is_empty("cur")  then
		-- idle and ready, check for something to work with
		if inv:is_empty("src") then
			return fuel_countdown_to_halt(pos, meta,
				tubelib.STANDBY, tubelib.STOPPED)
		end
		-- find item to cook/smelt that fits output tray
		-- (parse list items as first choice is not always the best one)
		local idx = -2
		for i = 1, inv:get_size("src") do
			inp = inv:get_stack("src", i)
			if not inp:is_empty() then
				recipe.time, recipe.input, recipe.output,
					recipe.decremented_input = get_cooking_items(inp)
				if recipe.time > 0 then
					idx = -1
					inv:set_list("dst_copy", inv:get_list("dst"))
					local is_dst_ok = true
					for _, stack in ipairs(recipe.output) do
						local outp = inv:add_item("dst_copy", stack)
						if not outp:is_empty() then
							is_dst_ok = false
							break
						end
					end
					inv:set_size("dst_copy", 0)
					if is_dst_ok then
						idx = i
						break
					end
				end
			end
		end
		-- (idx == -2 - nothing cookable found in src)
		-- (idx == -1 - cookable item in src but no space in dst)
		if idx == -2 then
			return fuel_countdown_to_halt(pos, meta,
				tubelib.STANDBY, tubelib.STOPPED)
		elseif idx == -1 then
			if machine:get_state(meta) == tubelib.STANDBY then
				-- adapt behaviour to other biogas machines
				-- (standby->blocked should go through running)
				machine:start(pos, meta, true)
				return false
			else
				return fuel_countdown_to_halt(pos, meta,
					tubelib.BLOCKED, tubelib.FAULT)
			end
		end
		if machine:get_state(meta) == tubelib.STANDBY or
		   machine:get_state(meta) == tubelib.BLOCKED then
			-- something to do, wake up and re-entry
			machine:start(pos, meta, true)
			return false
		end
		if fuel == 0 and inv:is_empty("fuel") then
			return countdown_to_halt(pos, meta, tubelib.FAULT)
		end
		inv:set_stack("src", idx, recipe.decremented_input)
		inv:set_stack("cur", 1, recipe.input)
		recipe.time = get_fast_cooking_time(recipe.time)
		meta:set_int("item_ticks", recipe.time)
		meta:set_int("item_total", recipe.time)
	else
		-- production
		inp = inv:get_stack("cur", 1)
		if machine:get_state(meta) ~= tubelib.RUNNING or
		   inp:is_empty() then
			-- exception, should not happen - oops
			machine_fault(pos, meta)
			return false
		end
		-- production tick
		if fuel == 0 and inv:is_empty("fuel") then
			return countdown_to_halt(pos, meta, tubelib.FAULT)
		end
		local itemcnt = meta:get_int("item_ticks")
		local zzz	-- dummy
		if itemcnt < 0 then
			-- interrupted - cook again
			recipe.time, zzz, recipe.output = get_cooking_items(inp)
			recipe.time = get_fast_cooking_time(recipe.time)
			meta:set_int("item_total", recipe.time)
			itemcnt = recipe.time
		else
			recipe.output = nil
		end
		itemcnt = itemcnt - 1
		if itemcnt == 0 then
			if not recipe.output then
				zzz, zzz, recipe.output = get_cooking_items(inp)
			end
			for _, i in ipairs(recipe.output) do
				inv:add_item("dst", i)
			end
			inv:set_stack("cur", 1, ItemStack({}))
			state_meta_reset(pos, meta)
			-- item produced, increase aging
			machine:keep_running(pos, meta, COUNTDOWN_TICKS)
		else
			meta:set_int("item_ticks", itemcnt)
		end
		-- consume fuel tick
		if fuel == 0 then
			if not inv:is_empty("fuel") then
				inv:remove_item("fuel",
					ItemStack("tubelib_addons1:biogas 1"))
				fuel = BIOGAS_TICKS
			else
				machine_fault(pos, meta)	-- oops
				return false
			end
		end
		meta:set_int("fuel_ticks", fuel - 1)
	end
	meta:set_int("tubelib_countdown", COUNTDOWN_TICKS)
	meta:set_int("desired_state", tubelib.RUNNING)
	meta:set_string("formspec", formspec(machine, pos, meta))
	return true
end

--[[
	-----------------
	Node registration
	-----------------
]]--

minetest.register_node("biogasmachines:jetfurnace", {
	description = "Tubelib Biogas Jet Furnace",
	tiles = {
		-- up, down, right, left, back, front
		"biogasmachines_jetfurnace_top.png",
		"biogasmachines_bottom.png",
		"biogasmachines_jetfurnace_side.png",
		"biogasmachines_jetfurnace_side.png",
		"biogasmachines_jetfurnace_side.png",
		"biogasmachines_jetfurnace_side.png",
	},
	drawtype = "nodebox",

	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = { choppy = 2, cracky = 2, crumbly = 2 },
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),

	drop = "",
	can_dig = can_dig,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		machine:after_dig_node(pos, oldnode, oldmetadata, digger)
		after_dig_node(pos, oldnode, oldmetadata, digger)
	end,

	on_rotate = screwdriver.disallow,
	on_timer = on_timer,
	on_receive_fields = on_receive_fields,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	after_place_node = after_place_node,
})

minetest.register_node("biogasmachines:jetfurnace_active", {
	description = "Tubelib Biogas Jet Furnace",
	tiles = {
		-- up, down, right, left, back, front
		{
			image = "biogasmachines_jetfurnace_active_top.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 1.5,
			},
		},
		"biogasmachines_bottom.png",
		"biogasmachines_jetfurnace_side.png",
		"biogasmachines_jetfurnace_side.png",
		"biogasmachines_jetfurnace_side.png",
		"biogasmachines_jetfurnace_side.png",
	},
	drawtype = "nodebox",

	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = { crumbly = 0, not_in_creative_inventory = 1 },
	is_ground_content = false,
	light_source = 6,
	sounds = default.node_sound_metal_defaults(),

	drop = "",
	can_dig = can_dig,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		machine:after_dig_node(pos, oldnode, oldmetadata, digger)
		after_dig_node(pos, oldnode, oldmetadata, digger)
	end,

	on_rotate = screwdriver.disallow,
	on_timer = on_timer,
	on_receive_fields = on_receive_fields,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
})

minetest.register_node("biogasmachines:jetfurnace_defect", {
	description = "Tubelib Biogas Jet Furnace",
	tiles = {
		-- up, down, right, left, back, front
		"biogasmachines_jetfurnace_top.png",
		"biogasmachines_bottom.png",
		"biogasmachines_jetfurnace_side.png^tubelib_defect.png",
		"biogasmachines_jetfurnace_side.png^tubelib_defect.png",
		"biogasmachines_jetfurnace_side.png^tubelib_defect.png",
		"biogasmachines_jetfurnace_side.png^tubelib_defect.png",
	},
	drawtype = "nodebox",

	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = { choppy = 2, cracky = 2, crumbly = 2, not_in_creative_inventory = 1 },
	is_ground_content = false,
	sounds = default.node_sound_metal_defaults(),

	can_dig = can_dig,
	after_dig_node = after_dig_node,
	on_rotate = screwdriver.disallow,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_take = allow_metadata_inventory_take,

	after_place_node = function(pos, placer, itemstack, pointed_thing)
		after_place_node(pos, placer, itemstack, pointed_thing)
		machine:defect(pos, minetest.get_meta(pos))
	end,
})

tubelib.register_node("biogasmachines:jetfurnace",
	{ "biogasmachines:jetfurnace_active", "biogasmachines:jetfurnace_defect" }, {

	on_push_item = function(pos, side, item)
		local meta = minetest.get_meta(pos)
		if item:get_name() == "tubelib_addons1:biogas" then
			return tubelib.put_item(meta, "fuel", item)
		end
		return tubelib.put_item(meta, "src", item)
	end,

	on_pull_item = function(pos, side)
		local meta = minetest.get_meta(pos)
		return tubelib.get_item(meta, "dst")
	end,

	on_pull_stack = function(pos, side)
		local meta = minetest.get_meta(pos)
		return tubelib.get_stack(meta, "dst")
	end,

	on_unpull_item = function(pos, side, item)
		local meta = minetest.get_meta(pos)
		return tubelib.put_item(meta, "dst", item)
	end,

	on_recv_message = function(pos, topic, payload)
		local meta = minetest.get_meta(pos)
		if topic == "fuel" then
			return tubelib.fuelstate(meta, "fuel")
		end
		local resp = machine:on_receive_message(pos, topic, payload)
		if resp then
			return resp
		else
			return "unsupported"
		end
	end,

	on_node_load = function(pos)
		machine:on_node_load(pos)
	end,

	on_node_repair = function(pos)
		return machine:on_node_repair(pos)
	end,
})

--[[
	--------
	Crafting
	--------
]]--

minetest.register_craft({
	output = "biogasmachines:jetfurnace",
	recipe = {
		{ "default:obsidian_block", "biogasmachines:gasfurnace", "" },
		{ "biogasmachines:gasfurnace", "default:goldblock", "" },
		{ "", "", "" },
	},
})
