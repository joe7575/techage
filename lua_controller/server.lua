--[[

	sl_controller
	=============

	Copyright (C) 2018 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	server.lua:

]]--

local SERVER_CAPA = 5000
local DEFAULT_MEM = {
	size=0, 
	data={
		version = 1,
		info = "SaferLua key/value Server",
	}
}

local function formspec(meta)
	local names = meta:get_string("names") or ""
	return "size[9,4]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"field[0.2,1;9,1;names;Allowed user names (spaces separated):;"..names.."]" ..
	"button_exit[3.5,2.5;2,1;exit;Save]"
end


local function on_time(pos, elasped)
	local meta = minetest.get_meta(pos)
	local nvm = techage.get_nvm(pos)
	if next(nvm) == nil then
		nvm = table.copy(DEFAULT_MEM)
	end
	local number = meta:get_string("number")
	meta:set_string("infotext", "Server "..number..": ("..(nvm.size or 0).."/"..SERVER_CAPA..")")
	return true
end

minetest.register_node("techage:ta4_server", {
	description = "Central Server",
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
		local meta = minetest.get_meta(pos)
		local number = techage.add_node(pos, "techage:ta4_server")
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("number", number)
		meta:set_string("formspec", formspec(meta))
		on_time(pos, 0)
		minetest.get_node_timer(pos):start(20)
	end,
	
	on_receive_fields = function(pos, formname, fields, player)
		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner")
		if player:get_player_name() == owner then
			if fields.names and fields.names ~= "" then
				local names = string.gsub(fields.names, " +", " ")
				meta:set_string("names", names)
				meta:set_string("formspec", formspec(meta))
			end
		end
	end,
	
	on_dig = function(pos, node, puncher, pointed_thing)
		if minetest.is_protected(pos, puncher:get_player_name()) then
			return
		end
		local meta = minetest.get_meta(pos)
		local number = meta:get_string("number")
		techage.del_mem(pos)
		minetest.node_dig(pos, node, puncher, pointed_thing)
		techage.remove_node(pos)
	end,
		
	on_timer = on_time,
	
	paramtype = "light",
	sunlight_propagates = true,
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

local function calc_size(v)
	if type(v) == "number" then
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

local function get_memory(pos, num, name)
	local info = techage.get_node_info(num)
	if info and info.name == "techage:ta4_server" then
		local meta = minetest.get_meta(info.pos)
		local owner = meta:get_string("owner")
		if name == owner then
			local nvm = techage.get_nvm(pos)
			if next(nvm) == nil then
				nvm = table.copy(DEFAULT_MEM)
			end
			return nvm
		end
		local names = meta:get_string("names")
		for _,n in ipairs(string.split(names, " ")) do
			local nvm = techage.get_nvm(pos)
			if name == n then
				if next(nvm) == nil then
					nvm = table.copy(DEFAULT_MEM)
				end
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
	end
end	

local function read_value(nvm, key)
	local item = nvm.data[key]
	if type(item) == "table" then
		item = safer_lua.table_to_datastruct(item)
	end
	return item
end	

techage.register_node({"techage:ta4_server"}, {
	on_recv_message = function(pos, topic, payload)
		return "unsupported"
	end,
	on_node_load = function(pos)
		minetest.get_node_timer(pos):start(20)
	end,
})		


techage.lua_ctlr.register_function("server_read", {
	cmnd = function(self, num, key) 
		if type(key) == "string" then
			local nvm = get_memory(self.meta.pos, num, self.meta.owner)
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
		' example: state = $server_read("0123", "state")'
})

techage.lua_ctlr.register_action("server_write", {
	cmnd = function(self, num, key, value)
		if type(key) == "string" then
			local nvm = get_memory(self.meta.pos, num, self.meta.owner)
			if nvm then
				write_value(nvm, key, value)
			end
		else
			self.error("Invalid server_write parameter")
		end
	end,
	help = " $server_write(num, key, value)\n"..
		" Store a value on the server under the key 'key'.\n"..
		" 'key' must be a string. 'value' can be either a\n"..
		" number, string, boolean, nil or data structure.\n"..
		' example: $server_write("0123", "state", state)'
})


