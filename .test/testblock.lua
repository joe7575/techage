local M = minetest.get_meta

minetest.register_node("techage:testblock", {
	description = "Testblock",
	tiles = {
		"techage_top_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
	},
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	is_ground_content = false,

	after_place_node = function(pos, placer)
		local nvm = techage.get_nvm(pos)
		nvm.test_val = 1
		M(pos):set_int("test_val", 1)
		M(pos):set_string("infotext", "Value = " .. 1)
	end,
})

minetest.register_lbm({
	label = "Update testblock",
	name = "techage:update_testblock",

	nodenames = {
		"techage:testblock",
	},

	run_at_every_load = true,

	action = function(pos, node)
		local nvm = techage.get_nvm(pos)
		if M(pos):get_int("test_val") == nvm.test_val then
			nvm.test_val = nvm.test_val + 1
			M(pos):set_int("test_val", nvm.test_val)
			M(pos):set_string("infotext", "Value = " .. nvm.test_val)
		else
			minetest.log("error", "[techage] Memory error at " .. minetest.pos_to_string(pos))
			M(pos):set_string("infotext", "Error")
		end
	end,
})

