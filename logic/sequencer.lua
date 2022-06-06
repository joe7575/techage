--[[

	TechAge
	=======

	Copyright (C) 2017-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	TA3 Sequencer

]]--

-- for lazy programmers
local M = minetest.get_meta
local S = techage.S

local logic = techage.logic
local NUM_SLOTS = 8

local sAction = ",on,off"
local kvAction = {[""]=1, ["on"]=2, ["off"]=3}
local tAction = {nil, "on", "off"}

local function new_rules()
	local tbl = {}
	for idx = 1,NUM_SLOTS do
		tbl[idx] = {offs = "", num = "", act = 1}
	end
	return tbl
end

local function formspec(state, rules, endless)
	local tbl = {"size[8,9.2]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"label[0,0;Number(s)]label[2.1,0;Command]label[6.4,0;Offset/s]"}

	for idx, rule in ipairs(rules or {}) do
		tbl[#tbl+1] = "field[0.2,"..(-0.2+idx)..";2,1;num"..idx..";;"..(rule.num or "").."]"
		tbl[#tbl+1] = "dropdown[2,"..(-0.4+idx)..";3.9,1;act"..idx..";"..sAction..";"..(rule.act or "").."]"
		tbl[#tbl+1] = "field[6.2,"..(-0.2+idx)..";2,1;offs"..idx..";;"..(rule.offs or "").."]"
	end
	tbl[#tbl+1] = "checkbox[0,8.5;endless;Run endless;"..dump(endless).."]"
	tbl[#tbl+1] = "button[2.2,8.5;1.5,1;help;help]"
	tbl[#tbl+1] = "button[4.2,8.5;1.5,1;save;Save]"
	tbl[#tbl+1] = "image_button[6.2,8.5;1,1;".. techage.state_button(state) ..";button;]"

	return table.concat(tbl)
end

local function formspec_help()
	return "size[8,9.2]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"label[2,0;TA3 Sequencer Help]"..
		"label[0,1;Define a sequence of commands\nto control other machines.]"..
		"label[0,2.2;Numbers(s) are the node numbers,\nthe command shall sent to.]"..
		"label[0,3.4;The commands 'on'/'off' are used\n for machines and other nodes.]"..
		"label[0,4.6;Offset is the time to the\nnext line in seconds (0.2 to 999).]"..
		"label[0,5.8;If endless is set, the Sequencer\nrestarts again and again.]"..
		"label[0,7;The command '  ' does nothing,\nonly consuming the offset time.]"..
		"button[3,8;2,1;exit;close]"
end

local function stop_the_sequencer(pos)
	local nvm = techage.get_nvm(pos)
	local meta = M(pos)
	nvm.running = false
	nvm.endless = nvm.endless or false
	nvm.rules = nvm.rules or new_rules()
	logic.infotext(meta, S("TA3 Sequencer"), "stopped")
	meta:set_string("formspec", formspec(techage.STOPPED, nvm.rules, nvm.endless))
	minetest.get_node_timer(pos):stop()
	return false
end

local function get_next_slot(idx, rules, endless)
	idx = idx + 1
	if idx <= #rules and rules[idx].offs ~= "" and rules[idx].num ~= "" then
		return idx
	elseif endless then
		return 1
	end
	return nil
end

local function restart_timer(pos, time)
	local timer = minetest.get_node_timer(pos)
	if timer:is_started() then
		timer:stop()
	end
	if type(time) == "number" then
		time = math.max(time, 0.2)
		timer:start(time)
	end
end

local function check_rules(pos, elapsed)
	local nvm = techage.get_nvm(pos)
	local own_num = M(pos):get_string("node_number")
	nvm.rules = nvm.rules or new_rules()
	nvm.running = nvm.running or false
	nvm.index = nvm.index or 1
	nvm.endless = nvm.endless or false
	techage.counting_start(M(pos):get_string("owner"))
	while true do -- process all rules as long as offs == 0
		local rule = nvm.rules[nvm.index]
		local offs = tonumber(nvm.rules[nvm.index].offs or 1)
		techage.send_multi(own_num, rule.num, tAction[rule.act])
		nvm.index = get_next_slot(nvm.index, nvm.rules, nvm.endless)
		if nvm.index ~= nil and offs ~= nil and nvm.running then
			-- after the last rule a pause with 1 or more sec is required
			if nvm.index == 1 and offs < 1 then
				offs = 1
			end
			if offs > 0 then
				-- we can't restart the timer within the function om_timer
				minetest.after(0, restart_timer, pos, offs)
				techage.counting_stop()
				return false
			end
		else
			techage.counting_stop()
			return stop_the_sequencer(pos)
		end
	end
	techage.counting_stop()
	return false
end

local function start_the_sequencer(pos)
	local nvm = techage.get_nvm(pos)
	if not nvm.running then
		local meta = M(pos)
		nvm.running = true
		nvm.endless = nvm.endless or false
		nvm.rules = nvm.rules or new_rules()
		logic.infotext(meta, S("TA3 Sequencer"), "running")
		meta:set_string("formspec", formspec(techage.RUNNING, nvm.rules, nvm.endless))
		minetest.get_node_timer(pos):start(0.1)
	end
	return false
end

local function on_receive_fields(pos, formname, fields, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return
	end

	local meta = M(pos)
	local nvm = techage.get_nvm(pos)
	nvm.running = nvm.running or false
	nvm.endless = nvm.endless or false
	nvm.rules = nvm.rules or new_rules()

	if fields.help ~= nil then
		meta:set_string("formspec", formspec_help())
		return
	end

	if fields.endless ~= nil then
		nvm.endless = fields.endless == "true"
		nvm.index = 1
	end

	if fields.exit ~= nil then
		if nvm.running then
			meta:set_string("formspec", formspec(techage.RUNNING, nvm.rules, nvm.endless))
		else
			meta:set_string("formspec", formspec(techage.STOPPED, nvm.rules, nvm.endless))
		end
		return
	end

	for idx = 1,NUM_SLOTS do
		if fields["offs"..idx] ~= nil then
			nvm.rules[idx].offs = tonumber(fields["offs"..idx]) or ""
		end
		if fields["num"..idx] ~= nil and
				techage.check_numbers(fields["num"..idx], player:get_player_name()) then
			nvm.rules[idx].num = fields["num"..idx]
		end
		if fields["act"..idx] ~= nil then
			nvm.rules[idx].act = kvAction[fields["act"..idx]]
		end
	end

	if fields.button ~= nil then
		if nvm.running then
			stop_the_sequencer(pos)
		else
			start_the_sequencer(pos)
		end
	elseif fields.num1 ~= nil then  -- any other change?
		stop_the_sequencer(pos)
	else
		if nvm.running then
			meta:set_string("formspec", formspec(techage.RUNNING, nvm.rules, nvm.endless))
		else
			meta:set_string("formspec", formspec(techage.STOPPED, nvm.rules, nvm.endless))
		end
	end
end

minetest.register_node("techage:ta3_sequencer", {
	description = S("TA3 Sequencer"),
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3_top.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_sequencer.png",
	},

	after_place_node = function(pos, placer)
		local meta = M(pos)
		local nvm = techage.get_nvm(pos)
		logic.after_place_node(pos, placer, "techage:ta3_sequencer", S("TA3 Sequencer"))
		logic.infotext(meta, S("TA3 Sequencer"), S("stopped"))
		nvm.rules = new_rules()
		nvm.index = 1
		nvm.running = false
		nvm.endless = false
		meta:set_string("formspec", formspec(techage.STOPPED, nvm.rules, nvm.endless))
	end,

	on_receive_fields = on_receive_fields,

	can_dig = function(pos, puncher)
		if minetest.is_protected(pos, puncher:get_player_name()) then
			return false
		end
		local nvm = techage.get_nvm(pos)
		return not nvm.running
	end,

	after_dig_node = function(pos, oldnode, oldmetadata)
		techage.remove_node(pos, oldnode, oldmetadata)
		techage.del_mem(pos)
	end,

	on_timer = check_rules,

	paramtype2 = "facedir",
	groups = {choppy=2, cracky=2, crumbly=2},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
})


minetest.register_craft({
	output = "techage:ta3_sequencer",
	recipe = {
		{"group:wood", "group:wood", ""},
		{"default:mese_crystal", "techage:vacuum_tube", ""},
		{"group:wood", "group:wood", ""},
	},
})

techage.register_node({"techage:ta3_sequencer"}, {
	on_recv_message = function(pos, src, topic, payload)
		if topic == "on" then
			start_the_sequencer(pos)
		elseif topic == "off" then
			-- do not stop immediately
			local nvm = techage.get_nvm(pos)
			if not nvm.running then
				nvm.endless = not (nvm.endless or false)
			else
				nvm.endless = false
			end
		elseif topic == "pause" then
			stop_the_sequencer(pos)
		else
			return "unsupported"
		end
	end,
	on_beduino_receive_cmnd = function(pos, src, topic, payload)
		local nvm = techage.get_nvm(pos)
		if topic == 7 then  -- TA3 Sequenzer
			if payload[1] == 1 then
				start_the_sequencer(pos)
				return 0
			elseif payload[1] == 0 then
				-- do not stop immediately
				local nvm = techage.get_nvm(pos)
				if not nvm.running then
					nvm.endless = not (nvm.endless or false)
				else
					nvm.endless = false
				end
				return 0
			elseif payload[1] == 2 then
				stop_the_sequencer(pos)
				return 0
			end
		end
		return 2
	end,
	on_node_load = function(pos)
		local nvm = techage.get_nvm(pos)
		if nvm.running then
			minetest.get_node_timer(pos):start(1)
		end
	end,
})
