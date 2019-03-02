minetest.register_node("techage:block1", {
	description = "block1",
	tiles = {"techage_filling_ta2.png^techage_frame_ta2.png"},
	paramtype = "light",
	light_source = 0,	
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	is_ground_content = false,
	--sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("techage:block2", {
	description = "block2",
	tiles = {"techage_filling_ta3.png^techage_frame_ta3.png"},
	paramtype = "light",
	light_source = 0,	
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	is_ground_content = false,
	--sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("techage:block3", {
	description = "block3",
	tiles = {
		"techage_top_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
	},
	paramtype = "light",
	light_source = 0,	
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	is_ground_content = false,
	--sounds = default.node_sound_stone_defaults(),
})




minetest.register_node("techage:block4", {
	description = "block4",
	tiles = {
		-- up, down, right, left, back, front
		'techage_filling_ta2.png^techage_frame_ta2.png^techage_appl_arrow.png',
		'techage_filling_ta2.png^techage_frame_ta2.png',
		'techage_filling_ta2.png^techage_frame_ta2.png^techage_appl_outp.png',
		'techage_filling_ta2.png^techage_frame_ta2.png^techage_appl_inp.png',
		{
			image = "techage_pusher14.png^[transformR180]^techage_frame14_ta2.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 2.0,
			},
		},
		{
			image = "techage_pusher14.png^techage_frame14_ta2.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 2.0,
			},
		},
	},
	paramtype = "light",
	light_source = 0,	
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	is_ground_content = false,
	--sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("techage:block5", {
	description = "block5",
	tiles = {
		-- up, down, right, left, back, front
		'techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_arrow.png',
		'techage_filling_ta3.png^techage_frame_ta3.png',
		'techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_outp.png',
		'techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_inp.png',
		{
			image = "techage_pusher14.png^[transformR180]^techage_frame14_ta3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 2.0,
			},
		},
		{
			image = "techage_pusher14.png^techage_frame14_ta3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 2.0,
			},
		},
	},
	paramtype = "light",
	light_source = 0,	
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	is_ground_content = false,
	--sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("techage:block6", {
	description = "block6",
	tiles = {
		-- up, down, right, left, back, front
		'techage_filling_ta4.png^techage_top_ta4.png^techage_appl_arrow.png',
		'techage_filling_ta4.png^techage_frame_ta4.png',
		'techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_outp.png',
		'techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_inp.png',
		{
			image = "tubelib_pusher.png^[transformR180]^techage_frame14_ta4.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 2.0,
			},
		},
		{
			image = "tubelib_pusher.png^techage_frame14_ta4.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 2.0,
			},
		},
	},
	paramtype = "light",
	light_source = 0,	
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	is_ground_content = false,
	--sounds = default.node_sound_stone_defaults(),
})






minetest.register_node("techage:block7", {
	description = "block7",
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta2.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_frame_ta2.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_appl_chest_back_ta3.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_appl_chest_back_ta3.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_appl_chest_back_ta3.png",
		"techage_filling_ta2.png^techage_frame_ta2.png^techage_appl_chest_front_ta3.png",
	},
	paramtype = "light",
	light_source = 0,	
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	is_ground_content = false,
	--sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("techage:block8", {
	description = "block8",
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_chest_back_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_chest_back_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_chest_back_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_chest_front_ta3.png",
	},
	paramtype = "light",
	light_source = 0,	
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	is_ground_content = false,
	--sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("techage:block9", {
	description = "block9",
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta4.png^techage_top_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_chest_back_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_chest_back_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_chest_back_ta4.png",
		"techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_chest_front_ta4.png",
	},
	paramtype = "light",
	light_source = 0,	
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	is_ground_content = false,
	--sounds = default.node_sound_stone_defaults(),
})



minetest.register_node("techage:sieve", {
	description = "sieve",
	drawtype = "nodebox",
	tiles = {
		-- up, down, right, left, back, front
		'techage_filling_ta2.png^techage_frame_ta2.png^techage_appl_inp.png',
		'techage_filling_ta2.png^techage_frame_ta2.png',
		'techage_filling_ta2.png^techage_frame_ta2.png^techage_appl_outp.png',
		'techage_filling_ta2.png^techage_frame_ta2.png',
		{
			image = "techage_filling4_ta2.png^techage_appl_sieve4.png^techage_frame4_ta2.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 2,
			},
		},
		{
			image = "techage_filling4_ta2.png^techage_appl_sieve4.png^techage_frame4_ta2.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 2,
			},
		},
	},
	paramtype = "light",
	light_source = 0,	
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	is_ground_content = false,
	--sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("techage:sieve2", {
	description = "sieve",
	drawtype = "nodebox",
	tiles = {
		-- up, down, right, left, back, front
		'techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_inp.png',
		'techage_filling_ta3.png^techage_frame_ta3.png',
		'techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_outp.png',
		'techage_filling_ta3.png^techage_frame_ta3.png',
		{
			image = "techage_filling4_ta3.png^techage_appl_sieve4.png^techage_frame4_ta3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 2,
			},
		},
		{
			image = "techage_filling4_ta3.png^techage_appl_sieve4.png^techage_frame4_ta3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 2,
			},
		},
	},
	paramtype = "light",
	light_source = 0,	
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	is_ground_content = false,
	--sounds = default.node_sound_stone_defaults(),
})


minetest.register_node("techage:sieve3", {
	description = "sieve",
	drawtype = "nodebox",
	tiles = {
		-- up, down, right, left, back, front
		'techage_filling_ta4.png^techage_top_ta4.png^techage_appl_inp.png',
		'techage_filling_ta4.png^techage_frame_ta4.png',
		'techage_filling_ta4.png^techage_frame_ta4.png^techage_appl_outp.png',
		'techage_filling_ta4.png^techage_frame_ta4.png',
		{
			image = "techage_filling4_ta4.png^techage_appl_sieve4.png^techage_frame4_ta4.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 2,
			},
		},
		{
			image = "techage_filling4_ta4.png^techage_appl_sieve4.png^techage_frame4_ta4.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 2,
			},
		},
	},
	paramtype = "light",
	light_source = 0,	
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	is_ground_content = false,
	--sounds = default.node_sound_stone_defaults(),
})


minetest.register_node("techage:filler", {
	description = "filler",
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_arrow.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_hole2.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_inp.png",
		--"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_filler.png",
		--"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_filler.png",
		{
			image = "techage_filling4_ta3.png^techage_appl_filler4.png^techage_frame4_ta3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 2.0,
			},
		},
		{
			image = "techage_filling4_ta3.png^techage_appl_filler4.png^techage_frame4_ta3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 2.0,
			},
		},
	},
	paramtype = "light",
	light_source = 0,	
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	is_ground_content = false,
	--sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("techage:compressor", {
	description = "compressor",
	tiles = {
		-- up, down, right, left, back, front
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_arrow.png",
		"techage_filling_ta3.png^techage_frame_ta3.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_hole2.png",
		"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_hole2.png",
		--"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_compressor.png",
		--"techage_filling_ta3.png^techage_frame_ta3.png^techage_appl_compressor.png^[transformFX]",
		{
			image = "techage_filling4_ta3.png^techage_appl_compressor4.png^techage_frame4_ta3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.2,
			},
		},
		{
			image = "techage_filling4_ta3.png^techage_appl_compressor4.png^[transformFX]^techage_frame4_ta3.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 0.2,
			},
		},
	},
	paramtype = "light",
	light_source = 0,	
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	is_ground_content = false,
	--sounds = default.node_sound_stone_defaults(),
})


minetest.register_node("techage:fermenter", {
	description = "fermenter",
	tiles = {"techage_fermenter.png"},
	paramtype = "light",
	light_source = 0,	
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	is_ground_content = false,
	--sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("techage:fermenter_foil", {
	description = "fermenter_foil",
	tiles = {"techage_fermenter_foil.png"},
	paramtype = "light",
	light_source = 0,	
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {cracky=2, crumbly=2, choppy=2},
	is_ground_content = false,
	--sounds = default.node_sound_stone_defaults(),
})


minetest.register_node("techage:biomass", {
	description = "biomass",
	drawtype = "liquid",
	tiles = {
		{
			name = "techage_biomass.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 4.0,
			},
		},
	},
	special_tiles = {
		-- New-style water source material (mostly unused)
		{
			name = "techage_biomass.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 4.0,
			},
			backface_culling = false,
		},
	},
	
	on_timer = function(pos)
		minetest.remove_node(pos)
		return false
	end,
	
	after_place_node = function(pos, placer)
		minetest.get_node_timer(pos):start(5)
	end,

	--alpha = 160,
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_flowing = "techage:biomass_flowing",
	liquid_alternative_source = "techage:biomass",
	liquid_viscosity = 1,
	post_effect_color = {a = 103, r = 30, g = 60, b = 90},
	groups = {water = 3, liquid = 3, puts_out_fire = 1, cools_lava = 1},
	sounds = default.node_sound_water_defaults(),
})

minetest.register_node("techage:biomass_flowing", {
	description = "biomass",
	drawtype = "flowingliquid",
	tiles = {"default_water.png"},
	special_tiles = {
		{
			name = "techage_biomass.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 4,
			},
		},
		{
			name = "techage_biomass.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 4,
			},
		},
	},
	--alpha = 220,
	paramtype = "light",
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "flowing",
	liquid_alternative_flowing = "techage:biomass_flowing",
	liquid_alternative_source = "techage:biomass",
	liquid_viscosity = 1,
	post_effect_color = {a = 103, r = 30, g = 60, b = 90},
	groups = {water = 3, liquid = 3, puts_out_fire = 1,
		not_in_creative_inventory = 0, cools_lava = 1},
	sounds = default.node_sound_water_defaults(),
})

