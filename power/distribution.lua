--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	GPL v3
	See LICENSE.txt for more information
	
	Power Distribution

]]--

local net_def = techage.networks.net_def

local STOPPED = techage.power.STOPPED
local NOPOWER = techage.power.NOPOWER
local RUNNING = techage.power.RUNNING

local function start_consumer(tbl, tlib_type)
	for _,v in pairs(tbl or {}) do
		local nvm = techage.get_nvm(v.pos)
		if nvm[tlib_type.."_cstate"] == NOPOWER and (nvm[tlib_type.."_calive"] or 0) > 0 then
			local ndef = net_def(v.pos, tlib_type)
			nvm[tlib_type.."_cstate"] = RUNNING
			nvm[tlib_type.."_taken"] = v.nominal or 0
			if ndef.on_power then
				ndef.on_power(v.pos)
			end
		end
	end
end

local function stop_consumer(tbl, tlib_type)
	for _,v in pairs(tbl or {}) do
		local nvm = techage.get_nvm(v.pos)
		if nvm[tlib_type.."_cstate"] == RUNNING then
			local ndef = net_def(v.pos, tlib_type)
			nvm[tlib_type.."_cstate"] = NOPOWER
			nvm[tlib_type.."_taken"] = 0
			if ndef.on_nopower then
				ndef.on_nopower(v.pos)
			end
		end
	end
end

local function get_generator_sum(tbl, tlib_type)
	local sum = 0
	for _,v in ipairs(tbl or {}) do
		local nvm = techage.get_nvm(v.pos)
		if nvm[tlib_type.."_gstate"] ~= STOPPED then
			nvm[tlib_type.."_galive"] = (nvm[tlib_type.."_galive"] or 1) - 1
			if nvm[tlib_type.."_galive"] > 0 then
				sum = sum + v.nominal
			end
		end
	end
	return sum
end

local function get_consumer_sum(tbl, tlib_type)
	local sum = 0
	for _,v in ipairs(tbl or {}) do
		local nvm = techage.get_nvm(v.pos)
		if nvm[tlib_type.."_cstate"] ~= STOPPED then
			nvm[tlib_type.."_calive"] = (nvm[tlib_type.."_calive"] or 1) - 1
			if nvm[tlib_type.."_calive"] > 0 then
				sum = sum + v.nominal
			end
		end
	end
	return sum
end

local function set_given(pos, given, tlib_type)
	local nvm = techage.get_nvm(pos)
	if (nvm[tlib_type.."_galive"] or 0) > 0 then
		nvm[tlib_type.."_given"] = given
		return given
	end
	return 0
end

local function set_taken(pos, taken, tlib_type)
	local nvm = techage.get_nvm(pos)
	if (nvm[tlib_type.."_calive"] or 0) > 0 then
		nvm[tlib_type.."_taken"] = taken
		return taken
	end
	return 0
end

local function set_given_values(tbl, needed, tlib_type)
	for _,v in ipairs(tbl or {}) do
		local real = math.max(math.min(needed, v.nominal), 0)
		real = set_given(v.pos, real, tlib_type)
		needed = needed - real
	end
	return needed
end

local function set_taken_values(tbl, taken, tlib_type)
	for _,v in pairs(tbl or {}) do
		local real = math.max(math.min(taken, v.nominal), 0)
		real = set_taken(v.pos, real, tlib_type)
		taken = taken - real
	end
	return taken
end

function techage.power.power_distribution(network, tlib_type, t)
	-- calc maximum power values
	network.available1 = get_generator_sum(network.gen1, tlib_type)
	network.available2 = get_generator_sum(network.gen2, tlib_type)
	network.needed1 = get_consumer_sum(network.con1, tlib_type)
	network.needed2 = get_consumer_sum(network.con2, tlib_type)
	print(t, minetest.get_gametime(), network.available1, network.available2, network.needed1, network.needed2)
	
	-- store results
	network.on = network.available1 + network.available2 >= network.needed1
	if network.on then
		network.ticker = (network.ticker or 0) + 1
		set_given_values(network.gen1, network.needed1 + network.needed2, tlib_type)
		set_given_values(network.gen2, network.needed1 - network.available1, tlib_type)
		start_consumer(network.con1, tlib_type)
		set_taken_values(network.con2, network.available1 - network.needed1, tlib_type)
	else
		set_given_values(network.gen1, 0, tlib_type)
		set_given_values(network.gen2, 0, tlib_type)
		stop_consumer(network.con1, tlib_type)
		set_taken_values(network.con2, 0, tlib_type)
	end
end