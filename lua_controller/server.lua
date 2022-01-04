--[[

	Techage
	=======

	Copyright (C) 2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	server.lua:

]]--

-- for lazy programmers
local S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local M = minetest.get_meta

local SERVER_CAPA = 5000

local function formspec(nvm)
	local names = table.concat(nvm.names or {}, " ")
	return "size[9,4]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"field[0.2,1;9,1;names;Allowed user names (space separated):;"..names.."]" ..
	"button_exit[3.5,2.5;2,1;exit;Save]"
end

minetest.register_node("techage:ta4_server", {
	description = "TA4 Lua Server",
	tiles = {
		-- up, down, right, left, back, front
		"techage_server_top.png",
		"techage_server_top.png",
		"techage_server_side.png",
		"techage_server_side.png^[transformFX",
		"techage_server_back.png",
		{
			image = "techage_server_front.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 1,
			},
		},
	},

	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -3/16, -8/16, -7/16, 3/16, 6/16, 7/16},
		},
	},

	after_place_node = function(pos, placer)
		local meta = M(pos)
		local nvm = techage.get_nvm(pos)
		local number = techage.add_node(pos, "techage:ta4_server")
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("number", number)
		meta:set_string("formspec", formspec(nvm))
		nvm.size = 0
		meta:set_string("infotext", "Server "..number..": ("..nvm.size.."/"..SERVER_CAPA..")")
		minetest.get_node_timer(pos):start(20)
	end,

	on_receive_fields = function(pos, formname, fields, player)
		local meta = M(pos)
		local nvm = techage.get_nvm(pos)
		local owner = meta:get_string("owner")
		if player:get_player_name() == owner then
			if fields.names and fields.names ~= "" then
				nvm.names = string.split(fields.names, " ")
				meta:set_string("formspec", formspec(nvm))
			end
		end
	end,

	on_dig = function(pos, node, puncher, pointed_thing)
		if minetest.is_protected(pos, puncher:get_player_name()) then
			return
		end
		techage.del_mem(pos)
		minetest.node_dig(pos, node, puncher, pointed_thing)
	end,

	after_dig_node = function(pos, oldnode, oldmetadata)
		techage.remove_node(pos, oldnode, oldmetadata)
	end,

	on_timer = function(pos, elasped)
		local meta = M(pos)
		local nvm = techage.get_nvm(pos)
		nvm.size = nvm.size or 0
		local number = meta:get_string("number")
		meta:set_string("infotext", "Server "..number..": ("..nvm.size.."/"..SERVER_CAPA..")")
		return true
	end,

	paramtype = "light",
	sunlight_propagates = true,
	use_texture_alpha = techage.CLIP,
	paramtype2 = "facedir",
	groups = {choppy=1, cracky=1, crumbly=1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	output = "techage:ta4_server",
	recipe = {
		{"default:steel_ingot", "dye:black", "default:steel_ingot"},
		{"techage:ta4_ramchip", "default:copper_ingot", "techage:ta4_ramchip"},
		{"techage:ta4_ramchip", "techage:ta4_wlanchip", "techage:ta4_ramchip"},
	},
})

minetest.register_node("techage:ta4_server2", {
	description = "TA4 Lua Rack Server",
	tiles = {
		-- up, down, right, left, back, front
		"techage_server2_top.png",
		"techage_server2_top.png",
		"techage_server2_side.png",
		"techage_server2_side.png^[transformFX",
		"techage_server2_back.png",
		{
			image = "techage_server2_front.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 1,
			},
		},
	},

	drawtype = "nodebox",
	node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, -0.4375, -0.4375, 0.5},
            {-0.5, 0.4375, -0.5, -0.4375, 0.5, 0.5},
            {0.4375, -0.5, -0.5, 0.5, -0.4375, 0.5},
            {0.4375, 0.4375, -0.5, 0.5, 0.5, 0.5},
            {-0.5, -0.5, -0.375, -0.4375, 0.5, -0.3125},
            {-0.5, -0.5, 0.3125, -0.4375, 0.5, 0.375},
            {0.4375, -0.5, 0.3125, 0.5, 0.5, 0.375},
            {0.4375, -0.5, -0.375, 0.5, 0.5, -0.3125},
            {-0.4375, -0.3125, -0.4375, 0.4375, 0.3125, 0.4375},
            {0.4375, -0.0625, -0.4375, 0.5, 0, 0.4375},
            {-0.5, -0.0625, -0.4375, -0.4375, 0, 0.4375},
        }
    },

	after_place_node = function(pos, placer)
		local meta = M(pos)
		local nvm = techage.get_nvm(pos)
		local number = techage.add_node(pos, "techage:ta4_server2")
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("number", number)
		meta:set_string("formspec", formspec(nvm))
		nvm.size = 0
		meta:set_string("infotext", "Server "..number..": ("..nvm.size.."/"..SERVER_CAPA..")")
		minetest.get_node_timer(pos):start(20)
	end,

	on_receive_fields = function(pos, formname, fields, player)
		local meta = M(pos)
		local nvm = techage.get_nvm(pos)
		local owner = meta:get_string("owner")
		if player:get_player_name() == owner then
			if fields.names and fields.names ~= "" then
				nvm.names = string.split(fields.names, " ")
				meta:set_string("formspec", formspec(nvm))
			end
		end
	end,

	on_dig = function(pos, node, puncher, pointed_thing)
		if minetest.is_protected(pos, puncher:get_player_name()) then
			return
		end
		techage.del_mem(pos)
		minetest.node_dig(pos, node, puncher, pointed_thing)
	end,

	after_dig_node = function(pos, oldnode, oldmetadata)
		techage.remove_node(pos, oldnode, oldmetadata)
	end,

	on_timer = function(pos, elasped)
		local meta = M(pos)
		local nvm = techage.get_nvm(pos)
		nvm.size = nvm.size or 0
		local number = meta:get_string("number")
		meta:set_string("infotext", "Server "..number..": ("..nvm.size.."/"..SERVER_CAPA..")")
		return true
	end,

	paramtype = "light",
	sunlight_propagates = true,
	use_texture_alpha = techage.CLIP,
	paramtype2 = "facedir",
	groups = {choppy=1, cracky=1, crumbly=1},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	type = "shapeless",
	output = "techage:ta4_server2",
	recipe = {"techage:ta4_server"},
})

minetest.register_craft({
	type = "shapeless",
	output = "techage:ta4_server",
	recipe = {"techage:ta4_server2"},
})

local function calc_size(v)
	if type(v) == "number" then
		return 1
	elseif type(v) == "boolean" then
		return 1
	elseif v == nil then
		return 0
	elseif type(v) == "string" then
		return #v
	elseif v.MemSize then
		return v.MemSize
	else
		return nil
	end
end

local function get_memory(num, name)
	local info = techage.get_node_info(num)
	if info and info.pos then
		local nvm = techage.get_nvm(info.pos)
		nvm.names = nvm.names or {}
		for _,n in ipairs(nvm.names) do
			if name == n then
				nvm.data = nvm.data or {}
				return nvm
			end
		end
	end
end

local function write_value(nvm, key, item)
	if nvm and nvm.size < SERVER_CAPA then
		if nvm.data[key] then
			nvm.size = nvm.size - calc_size(nvm.data[key])
		end
		if type(item) == "table" then
			item = safer_lua.datastruct_to_table(item)
		end
		nvm.size = nvm.size + calc_size(item)
		nvm.data[key] = item
		return true
	end
	return false
end

local function read_value(nvm, key)
	local item = nvm.data[key]
	if type(item) == "table" then
		item = safer_lua.table_to_datastruct(item)
	end
	return item
end

techage.register_node({"techage:ta4_server", "techage:ta4_server2"}, {
	on_recv_message = function(pos, src, topic, payload)
		return "unsupported"
	end,
	on_node_load = function(pos)
		minetest.get_node_timer(pos):start(20)
	end,
})


techage.lua_ctlr.register_function("server_read", {
	cmnd = function(self, num, key)
		if type(key) == "string" then
			local nvm = get_memory(num, self.meta.owner)
			if nvm then
				return read_value(nvm, key)
			end
		else
			self.error("Invalid server_read parameter")
		end
	end,
	help = " $server_read(num, key)\n"..
		" Read a value from the server.\n"..
		" 'key' must be a string.\n"..
		' example: state = $server_read("123", "state")'
})

techage.lua_ctlr.register_action("server_write", {
	cmnd = function(self, num, key, value)
		if type(key) == "string" then
			local nvm = get_memory(num, self.meta.owner)
			if nvm then
				return write_value(nvm, key, value)
			end
		else
			self.error("Invalid server_write parameter")
		end
	end,
	help = " $server_write(num, key, value)\n"..
		" Store a value on the server under the key 'key'.\n"..
		" 'key' must be a string. 'value' can be either a\n"..
		" number, string, boolean, nil or data structure.\n"..
		" return value: true if successful or false\n"..
		' example: res = $server_write("123", "state", state)'
})
