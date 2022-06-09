--[[

	TechAge
	=======

	Copyright (C) 2019-2022 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	K/V Store for the Beduino controller

]]--

local COSTS = 400

local function ta_kv_init(cpu_pos, address, regA, regB, regC)
	local nvm = techage.get_nvm(cpu_pos)
	nvm.kv_store = {}
	return 1, COSTS
end

local function ta_kv_add(cpu_pos, address, regA, regB, regC)
	local nvm = techage.get_nvm(cpu_pos)
	local text = vm16.read_ascii(cpu_pos, regA, 32)
	nvm.kv_store[text] = regB
	return 1, COSTS
end

local function ta_kv_get(cpu_pos, address, regA, regB, regC)
	local nvm = techage.get_nvm(cpu_pos)
	local text = vm16.read_ascii(cpu_pos, regA, 32)
	return nvm.kv_store[text] or 0, COSTS
end

local kvstore_c = [[
// Initialize the key/value store
func ta_kv_init() {
  return system(0x140, 0);
}

// Add a key/value pair to the store
func ta_kv_add(key_str, value) {
  return system(0x141, key_str, value);
}

// Returns the value for the given key string
func ta_kv_get(key_str) {
  return system(0x142, key_str);
}
]]

minetest.register_on_mods_loaded(function()
	if minetest.global_exists("beduino") and minetest.global_exists("vm16") then
		beduino.lib.register_SystemHandler(0x140, ta_kv_init)
		beduino.lib.register_SystemHandler(0x141, ta_kv_add)
		beduino.lib.register_SystemHandler(0x142, ta_kv_get)
		vm16.register_ro_file("beduino", "ta_kvstore.c", kvstore_c)
	end
end)
