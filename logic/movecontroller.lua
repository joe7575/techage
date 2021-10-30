--[[

	TechAge
	=======

	Copyright (C) 2020-2021 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA4 Move Controller
	
]]--

-- for lazy programmers
local M = minetest.get_meta
local P2S = function(pos) if pos then return minetest.pos_to_string(pos) end end
local S2P = minetest.string_to_pos
local S = techage.S

-------------------------------------------------------------------------------
-- Entity / Move / Attach / Detach 
-------------------------------------------------------------------------------
local MIN_SPEED = 0.4
local MAX_SPEED = 8

local function to_vector(s)
	local x,y,z = unpack(string.split(s, ","))
	if x and y and z then
		return {
			x=tonumber(x) or 0, 
			y=tonumber(y) or 0, 
			z=tonumber(z) or 0, 
		}
	end
	return {x=0, y=0, z=0}
end

-- Only the ID ist stored, not the object
local function get_object_id(object)
	for id, entity in pairs(minetest.luaentities) do
		if entity.object == object then
			return id
		end
	end
end

-- determine exact position of attached entities
local function obj_pos(obj)
	local _, _, pos = obj:get_attach()
	pos = vector.divide(pos, 29)
	return vector.add(obj:get_pos(), pos)
end

-- Check access conflicts with other mods
local function lock_player(player)
	local meta = player:get_meta()
	if meta:get_int("player_physics_locked") == 0 then 
		meta:set_int("player_physics_locked", 1)
		meta:set_string("player_physics_locked_by", "ta_movecontroller")
		return true
	end
	return false
end

local function unlock_player(player)
	local meta = player:get_meta()
	if meta:get_int("player_physics_locked") == 1 then 
		if meta:get_string("player_physics_locked_by") == "ta_movecontroller" then
			meta:set_int("player_physics_locked", 0)
			meta:set_string("player_physics_locked_by", "")
			return true
		end
	end
	return false
end

local function detach_player(player)
	local pos = obj_pos(player)
	player:set_detach()
	player:set_properties({visual_size = {x=1, y=1}})
	player:set_pos(pos)
	-- TODO: move to save position
end


-- Attach player/mob to given parent object (block)
local function attach_single_object(parent, obj, dir)
	local self = parent:get_luaentity()
	local rot = obj:get_rotation()
	local res = obj:get_attach()
	if not res then
		local offs = table.copy(dir)
		dir = vector.multiply(dir, 29)
		obj:set_attach(parent, "", dir, rot, true)
		obj:set_properties({visual_size = {x=2.9, y=2.9}})
		if obj:is_player() then
			if lock_player(obj) then
				table.insert(self.players, {name = obj:get_player_name(), offs = offs})
			end
		else
			table.insert(self.entities, {objID = get_object_id(obj), offs = offs})
		end
	end
end

-- Attach all objects around to the parent object
-- offs is the search/attach position offset
local function attach_objects(pos, offs, parent)
	local pos1 = vector.add(pos, offs)
	for _, obj in pairs(minetest.get_objects_inside_radius(pos1, 0.9)) do
		local dir = vector.subtract(obj:get_pos(), pos)
		local entity = obj:get_luaentity()
		if entity then
			if entity.name == "__builtin:item" then  -- dropped items
				--obj:set_attach(objref, "", {x=0, y=0, z=0}, {x=0, y=0, z=0}, true) -- hier kracht es
			elseif entity.name ~= "techage:move_item" then
				attach_single_object(parent, obj, dir)
			end
		elseif obj:is_player() then
			attach_single_object(parent, obj, dir)
		end
	end
end

-- Detach all attached objects from the parent object
local function detach_objects(pos, self)
	for _, item in ipairs(self.entities or {}) do
		local entity = minetest.luaentities[item.objID]
		if entity then
			local obj = entity.object
			obj:set_detach()
			obj:set_properties({visual_size = {x=1, y=1}})
			local pos1 = vector.add(pos, item.offs)
			obj:set_pos(pos1)
		end
	end
	for _, item in ipairs(self.players or {}) do
		local obj = minetest.get_player_by_name(item.name)
		if obj then
			obj:set_detach()
			obj:set_properties({visual_size = {x=1, y=1}})
			local pos1 = vector.add(pos, item.offs)
			obj:set_pos(pos1)
			unlock_player(obj)
		end
	end
	self.entities = {}
	self.players = {}
end

local function entity_to_node(pos, obj)
	local self = obj:get_luaentity()
	if self then
		local name = self.item or "air"
		local metadata = self.metadata or {}
		local rot = obj:get_rotation()
		detach_objects(pos, self)
		obj:remove()
		
		pos = vector.round(pos)
		local dir = minetest.yaw_to_dir(rot.y or 0)
		local param2 = minetest.dir_to_facedir(dir) or 0
		local node =  minetest.get_node(pos)
		local ndef1 = minetest.registered_nodes[name]
		local ndef2 = minetest.registered_nodes[node.name]
		if ndef1 and ndef2 then
			if ndef2.buildable_to then
				local meta = M(pos)
				minetest.set_node(pos, {name=name, param2=param2})
				meta:from_table(metadata)
				meta:set_string("ta_move_block", "")
				return
			end
			local meta = M(pos)
			if not meta:contains("ta_move_block") then
				meta:set_string("ta_move_block", minetest.serialize({name=name, param2=param2}))
				return
			end
			minetest.add_item(pos, ItemStack(name))
		elseif ndef1 then
			minetest.add_item(pos, ItemStack(name))
		end
	end
end

local function node_to_entity(pos, handover)
	local meta = M(pos)
	local node, metadata
	
	if meta:contains("ta_move_block") then
		node = minetest.deserialize(meta:get_string("ta_move_block"))
		metadata = {}
		meta:set_string("ta_move_block", "")
	else
		node = minetest.get_node(pos)
		meta:set_string("ta_move_block", "")
		metadata = meta:to_table()
		minetest.remove_node(pos)
	end
	local dir = minetest.facedir_to_dir(node.param2)
	local yaw = minetest.dir_to_yaw(dir)
	local obj = minetest.add_entity(pos, "techage:move_item")
	if obj then
		local self = obj:get_luaentity() 
		obj:set_rotation({x=0, y=yaw, z=0})
		obj:set_properties({wield_item=node.name})
		obj:set_armor_groups({immortal=1})
		self.item = node.name
		self.metadata = metadata or {}
		self.handover = handover
		self.start_pos = table.copy(pos)
		return obj
	end
end

local function capture_entity(pos)
	local l = minetest.get_objects_in_area(pos, pos)
	for _, obj in ipairs(l) do
		local self = obj:get_luaentity()
		if self and self.name == "techage:move_item" then
			return obj
		end
	end
end

-- move block direction
local function determine_dir(pos1, pos2)
	local vdist = vector.subtract(pos2, pos1)
	local ndist = vector.length(vdist)
	return vector.divide(vdist, ndist)
end

local function move_entity(obj, pos2, dir, max_speed)
	local self = obj:get_luaentity()
	self.max_speed = max_speed
	self.dest_pos = table.copy(pos2)
	self.dir = dir
	local acc = vector.multiply(dir, max_speed / 2)
	obj:set_acceleration(acc)
end

-- Handover the entity to the next movecontroller
local function handover_to(pos, self)
	local info = techage.get_node_info(self.handover)
	if info and info.name == "techage:ta4_movecontroller" then
		local mem = techage.get_mem(info.pos)
		if not mem.entities_are_there then
			mem.entities_are_there = true
			-- copy move direction
			--print("techage.get_nvm(pos).pos_2to1", techage.get_nvm(pos).pos_2to1)
			techage.get_nvm(info.pos).pos_2to1 = techage.get_nvm(pos).pos_2to1
			minetest.after(0.2, techage.send_single, "0", self.handover, "handover")
		end
		return true
	end
end

minetest.register_entity("techage:move_item", {
	initial_properties = {
		pointable = true,
		makes_footstep_sound = true,
		static_save = true,
		collide_with_objects = false,
		physical = false,
		visual = "wielditem",
		wield_item = "default:dirt",
		visual_size = {x=0.67, y=0.67, z=0.67},
		selectionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
	},
	
	get_staticdata = function(self)
		return minetest.serialize({
			item = self.item,
			max_speed = self.max_speed,
			dest_pos = self.dest_pos,
			start_pos = self.start_pos,
			dir = self.dir,
			metadata = self.metadata,
			respawn = true,
		})
	end,
	
	on_activate = function(self, staticdata)
		if staticdata then
			local tbl = minetest.deserialize(staticdata) or {}
			self.item = tbl.item or "air"
			self.max_speed = tbl.max_speed or MAX_SPEED
			self.dest_pos = tbl.dest_pos or self.object:get_pos()
			self.start_pos = tbl.start_pos or self.object:get_pos()
			self.dir = tbl.dir or {x=0, y=0, z=0}
			self.metadata = tbl.metadata or {}
			self.object:set_properties({wield_item = self.item})
			if tbl.respawn then
				entity_to_node(self.start_pos, self.object)
			end
		end
	end,
	
	on_step = function(self, dtime, moveresult)
		if self.dest_pos then
			local obj = self.object
			local pos = obj:get_pos()
			local dist = vector.distance(pos, self.dest_pos)
			local speed = vector.length(obj:get_velocity())
			
			-- Landing
			if dist < 0.05 then
				obj:move_to(self.dest_pos, true)
				obj:set_acceleration({x=0, y=0, z=0})
				obj:set_velocity({x=0, y=0, z=0})
				self.dest_pos = nil
				if not self.handover or not handover_to(pos, self) then
					minetest.after(0.5, entity_to_node, pos, obj)
				end
				self.ttl = 2
				return
			end
			
			-- Braking or limit max speed 
			if speed > (dist * 2) or speed > self.max_speed then
				local speed = math.min(speed, math.max(dist * 2, MIN_SPEED)) 
				local vel = vector.multiply(self.dir,speed)
				obj:set_velocity(vel)
				obj:set_acceleration({x=0, y=0, z=0})
			end
		elseif self.ttl then
			self.ttl = self.ttl - dtime
			if self.ttl < 0 then
				local obj = self.object
				local pos = obj:get_pos()
				entity_to_node(pos, obj)
			end
		end
	end,

})

-------------------------------------------------------------------------------
-- Marker / Record
-------------------------------------------------------------------------------
local MarkedNodes = {} -- t[player] = {{entity, pos},...} 
local CurrentPos  -- to mark punched entities
local SimpleNodes = techage.logic.SimpleNodes

local function is_valid_dest(pos)
	local node = minetest.get_node(pos)
	local ndef = minetest.registered_nodes[node.name]
	if ndef and ndef.buildable_to then
		return true
	end
	if not M(pos):contains("ta_move_block") then
		return true
	end
	return false
end

local function is_simple_node(pos)
	-- special handling
	local name = minetest.get_node(pos).name
	if SimpleNodes[name] ~= nil then 
		return SimpleNodes[name] 
	end
	
	local ndef = minetest.registered_nodes[name]
	if not ndef or name == "air" or name == "ignore" then return false end
	-- don't remove nodes with some intelligence or undiggable nodes
	if ndef.drop == "" then return false end
	if ndef.diggable == false then return false end
	if ndef.after_dig_node then return false end
	
	return true
end	

local function table_add(tbl, offs)
	if not tbl or not offs then return end
	
	local tbl2 = {}
	for _, v in ipairs(tbl) do
		tbl2[#tbl2 + 1] = vector.add(v, offs)
	end
	return tbl2
end

local function unmark_position(name, pos)
	pos = vector.round(pos)
	for idx,item in ipairs(MarkedNodes[name] or {}) do
		if vector.equals(pos, item.pos) then
			item.entity:remove()
			table.remove(MarkedNodes[name], idx)
			CurrentPos = pos
			return
		end
	end
end

local function unmark_all(name)
	for _,item in ipairs(MarkedNodes[name] or {}) do
		item.entity:remove()
	end
	MarkedNodes[name] = nil
end

local function mark_position(name, pos)
	MarkedNodes[name] = MarkedNodes[name] or {}
	pos = vector.round(pos)
	if not CurrentPos or not vector.equals(pos, CurrentPos) then -- entity not punched?
		local entity = minetest.add_entity(pos, "techage:moveblock_marker")
		if entity ~= nil then
			entity:get_luaentity().player_name = name
			table.insert(MarkedNodes[name], {pos = pos, entity = entity})
		end
		CurrentPos = nil
		return true
	end
	CurrentPos = nil
end

local function get_poslist(name)
	local idx = 0
	local lst = {}
	for _,item in ipairs(MarkedNodes[name] or {}) do
		table.insert(lst, item.pos)
		idx = idx + 1
		if idx >= 16 then break end
	end
	return lst
end

minetest.register_on_punchnode(function(pos, node, puncher, pointed_thing)
	if puncher and puncher:is_player() then
		local name = puncher:get_player_name()
		
		if not MarkedNodes[name] then
			return
		end
		
		mark_position(name, pointed_thing.under)
	end
end)


minetest.register_entity(":techage:moveblock_marker", {
	initial_properties = {
		visual = "cube",
		textures = {
			"techage_cube_mark.png",
			"techage_cube_mark.png",
			"techage_cube_mark.png",
			"techage_cube_mark.png",
			"techage_cube_mark.png",
			"techage_cube_mark.png",
		},
		--use_texture_alpha = true,
		physical = false,
		visual_size = {x=1.1, y=1.1},
		collisionbox = {-0.55,-0.55,-0.55, 0.55,0.55,0.55},
		glow = 8,
	},
	on_step = function(self, dtime)
		self.ttl = (self.ttl or 2400) - 1
		if self.ttl <= 0 then
			local pos = self.object:get_pos()
			unmark_position(self.player_name, pos)
		end
	end,
	on_punch = function(self, hitter)
		local pos = self.object:get_pos()
		local name = hitter:get_player_name()
		if name == self.player_name then
			unmark_position(name, pos)
		end
	end,
})

-------------------------------------------------------------------------------
-- TA4 Move Controller
-------------------------------------------------------------------------------
local WRENCH_MENU = {
	{
		type = "dropdown",
		choices = "0.5,1,2,4,6,8",
		name = "max_speed",
		label = S("Maximum Speed"),      
		tooltip = S("Maximum speed for the moving block."),
		default = "8",
	},
	{
		type = "number",
		name = "handoverB",
		label = S("Handover to B"),      
		tooltip = S("Number of the next movecontroller."),
		default = "",
	},
	{
		type = "number",
		name = "handoverA",
		label = S("Handover to A"),      
		tooltip = S("Number of the previous movecontroller."),
		default = "",
	},
	{
		type = "float",
		name = "height",
		label = S("Move block height"),      
		tooltip = S("Value in the range of 0.0 to 1.0"),
		default = "1.0",
	},
}

local function formspec(nvm, meta)
	local status = meta:get_string("status")
	local distance = meta:contains("distance") and meta:get_string("distance") or "0,3,0"
	return "size[8,5]" ..
		default.gui_bg ..
		default.gui_bg_img ..
		default.gui_slots ..
		"box[0,-0.1;7.2,0.5;#c6e8ff]" ..
		"label[0.2,-0.1;" .. minetest.colorize( "#000000", S("TA4 Move Controller")) .. "]" ..
		techage.wrench_image(7.4, -0.05) ..
		"button[0.1,0.8;3.8,1;record;" .. S("Record") .. "]" ..
		"button[4.1,0.8;3.8,1;ready;" .. S("Done") .. "]" ..
		"field[0.4,2.5;3.8,1;distance;" .. S("Move distance (A to B)") .. ";" .. distance .. "]" ..
		"button[4.1,2.2;3.8,1;store;" .. S("Store") .. "]" ..
		"button[0.1,3.3;3.8,1;moveAB;" .. S("Move A-B") .. "]" ..
		"button[4.1,3.3;3.8,1;moveBA;" .. S("Move B-A") .. "]" ..
		"label[0.3,4.3;" .. status .. "]"
end

local function move_node(pos, pos1, pos2, max_speed, handover, height)
	local meta = M(pos)
	local dir = determine_dir(pos1, pos2)
	local obj = node_to_entity(pos1, handover)
	local self = obj:get_luaentity()
	self.players = {}
	self.entities = {}
	
	if obj then
		local offs = {x=0, y=height or 1, z=0}
		attach_objects(pos1, offs, obj)
		if dir.y == 0 then
			if (dir.x ~= 0 and dir.z == 0) or (dir.x == 0 and dir.z ~= 0) then
				attach_objects(pos1, dir, obj)
			end
		end
		move_entity(obj, pos2, dir, max_speed)
	end
end

local function move_nodes(pos, lpos1, lpos2, handover)
	local meta = M(pos)
	local owner = meta:get_string("owner")
	local max_speed = meta:contains("max_speed") and meta:get_int("max_speed") or MAX_SPEED
	local height = meta:contains("height") and meta:get_float("height") or 1
	height = techage.in_range(height, 0, 1)
	
	if #lpos1 == #lpos2 then
		for idx = 1, #lpos1 do
			local pos1 = lpos1[idx]
			local pos2 = lpos2[idx]
			if not minetest.is_protected(pos1, owner) and not minetest.is_protected(pos2, owner) then
				if is_simple_node(pos1) and is_valid_dest(pos2) then
					move_node(pos, pos1, pos2, max_speed, handover, height)
				else
					if not is_simple_node(pos1) then
						meta:set_string("status", S("No valid node at the start position"))
					else
						meta:set_string("status", S("No valid destination position"))
					end
				end
			else
				if minetest.is_protected(pos1, owner) then
					meta:set_string("status", S("Start position is protected"))
				else
					meta:set_string("status", S("Destination position is protected"))
				end
				return false
			end
		end
	else
		meta:set_string("status", S("Position list error"))
		return false
	end
	local info = techage.get_node_info(handover)
	if info and info.name == "techage:ta4_movecontroller" then
		local mem = techage.get_mem(info.pos)
		mem.num_entities = #lpos1
	end
	return true
end

local function moveon_nodes(pos, lpos1, lpos2, handover)
	local meta = M(pos)
	local owner = meta:get_string("owner")
	local max_speed = meta:contains("max_speed") and meta:get_int("max_speed") or MAX_SPEED
	
	if #lpos1 == #lpos2 then
		for idx = 1, #lpos1 do
			local pos1 = lpos1[idx]
			local pos2 = lpos2[idx]
			if not minetest.is_protected(pos1, owner) and not minetest.is_protected(pos2, owner) then
				if is_valid_dest(pos2) then
					local dir = determine_dir(pos1, pos2)
					local obj = capture_entity(pos1)
					if obj then
						obj:get_luaentity().handover = handover
						move_entity(obj, pos2, dir, max_speed)
					end
				else
					if not is_simple_node(pos1) then
						meta:set_string("status", S("No valid node at the start position"))
					else
						meta:set_string("status", S("No valid destination position"))
					end
				end
			else
				if minetest.is_protected(pos1, owner) then
					meta:set_string("status", S("Start position is protected"))
				else
					meta:set_string("status", S("Destination position is protected"))
				end
				return false
			end
		end
	else
		meta:set_string("status", S("Position list error"))
		return false
	end
	local info = techage.get_node_info(handover)
	if info and info.name == "techage:ta4_movecontroller" then
		local mem = techage.get_mem(info.pos)
		mem.num_entities = #lpos1
	end
	return true
end

local function move_to_other_pos(pos)	
	local meta = M(pos)
	local nvm = techage.get_nvm(pos)
	
	if nvm.pos_2to1 then
		local lpos1 = nvm.lpos1 or {}
		local lpos2 = nvm.lpos2 or {}
		nvm.pos_2to1 = false
		local handover = meta:contains("handoverA") and meta:get_string("handoverA")
		return move_nodes(pos, lpos2, lpos1, handover)
	else
		local lpos1 = nvm.lpos1 or {}
		local lpos2 = nvm.lpos2 or {}
		nvm.pos_2to1 = true
		local handover = meta:contains("handoverB") and meta:get_string("handoverB")
		return move_nodes(pos, lpos1, lpos2, handover)
	end
end
	
local function takeover(pos)	
	local meta = M(pos)
	local nvm = techage.get_nvm(pos)
	local mem = techage.get_mem(pos)
	mem.entities_are_there = nil
	
	if nvm.pos_2to1 then
		local lpos1 = nvm.lpos1 or {}
		local lpos2 = nvm.lpos2 or {}
		nvm.pos_2to1 = false
		local handover = meta:contains("handoverA") and meta:get_string("handoverA")
		return moveon_nodes(pos, lpos2, lpos1, handover)
	else
		local lpos1 = nvm.lpos1 or {}
		local lpos2 = nvm.lpos2 or {}
		nvm.pos_2to1 = true
		local handover = meta:contains("handoverB") and meta:get_string("handoverB")
		return moveon_nodes(pos, lpos1, lpos2, handover)
	end
end

minetest.register_node("techage:ta4_movecontroller", {
	description = S("TA4 Move Controller"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_filling_ta4.png^techage_frame_ta4_top.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_movecontroller.png",
	},

	after_place_node = function(pos, placer, itemstack)
		local meta = M(pos)
		techage.logic.after_place_node(pos, placer, "techage:ta4_movecontroller", S("TA4 Move Controller"))
		techage.logic.infotext(meta, S("TA4 Move Controller"))
		local nvm = techage.get_nvm(pos)
		meta:set_string("formspec", formspec(nvm, meta))
	end,

	on_receive_fields = function(pos, formname, fields, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return
		end

		local meta = M(pos)
		local nvm = techage.get_nvm(pos)
		
		if fields.record then
			nvm.lpos1 = nil
			nvm.lpos2 = nil
			nvm.pos_2to1 = false
			meta:set_string("status", S("Recording..."))
			local name = player:get_player_name()
			minetest.chat_send_player(name, S("Click on all blocks that shall be moved"))
			MarkedNodes[name] = {}
			meta:set_string("formspec", formspec(nvm, meta))
		elseif fields.ready then
			local name = player:get_player_name()
			local pos_list = get_poslist(name)
			local text = #pos_list.." "..S("block positions are stored.")
			meta:set_string("status", text)
			meta:set_string("distance", fields.distance)
			nvm.lpos1 = pos_list
			nvm.lpos2 = table_add(pos_list, to_vector(fields.distance))
			nvm.pos_2to1 = false
			unmark_all(name)
			meta:set_string("formspec", formspec(nvm, meta))
		elseif fields.store then
			local dist = to_vector(fields.distance)
			local l = math.hypot(dist.x, math.hypot(dist.y, dist.z)) 
			if l <= 100 then 
				meta:set_string("distance", fields.distance)
				nvm.lpos2 = table_add(nvm.lpos1, to_vector(fields.distance))
				nvm.pos_2to1 = false
			else
				meta:set_string("status", S("Error: Distance > 100 m !!"))
			end
			meta:set_string("formspec", formspec(nvm, meta))
		elseif fields.moveAB then
			meta:set_string("status", "")
			nvm.pos_2to1 = false
			if move_to_other_pos(pos) then
				meta:set_string("formspec", formspec(nvm, meta))
				local name = player:get_player_name()
				MarkedNodes[name] = nil
			end
		elseif fields.moveBA then
			meta:set_string("status", "")
			nvm.pos_2to1 = true
			if move_to_other_pos(pos) then
				meta:set_string("formspec", formspec(nvm, meta))
				local name = player:get_player_name()
				MarkedNodes[name] = nil
			end
		end
	end,
	
	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local name = digger:get_player_name()
		unmark_all(name)
		techage.remove_node(pos, oldnode, oldmetadata)
	end,

	ta4_formspec = WRENCH_MENU,
	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
})

local INFO = [[Commands: 'a2b', 'b2a', 'move']]

techage.register_node({"techage:ta4_movecontroller"}, {
	on_recv_message = function(pos, src, topic, payload)
		if topic == "info" then
			return INFO
		elseif topic == "a2b" then
			local nvm = techage.get_nvm(pos)
			nvm.pos_2to1 = false
			return move_to_other_pos(pos)
		elseif topic == "b2a" then
			local nvm = techage.get_nvm(pos)
			nvm.pos_2to1 = true
			return move_to_other_pos(pos)
		elseif topic == "move" then
			return move_to_other_pos(pos)
		elseif topic == "handover" then
			return takeover(pos)
		end
		return false
	end,
})		

minetest.register_craft({
	output = "techage:ta4_movecontroller",
	recipe = {
		{"default:steel_ingot", "dye:blue", "default:steel_ingot"},
		{"default:mese_crystal_fragment", "techage:ta4_wlanchip", "default:mese_crystal_fragment"},
		{"group:wood", "basic_materials:gear_steel", "group:wood"},
	},
})

minetest.register_on_joinplayer(function(player)
	unlock_player(player)
end)

minetest.register_on_leaveplayer(function(player)
	if unlock_player(player) then
		detach_player(player)
	end
end)

minetest.register_on_dieplayer(function(player)
	if unlock_player(player) then
		detach_player(player)
	end
end)
