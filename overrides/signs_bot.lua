if minetest.global_exists("signs_bot") then
	minetest.register_craft({
		output = "signs_bot:box",
		recipe = {
			{"default:steel_ingot", "group:wood", "default:steel_ingot"},
			{"basic_materials:motor", "techage:wlanchip", "basic_materials:gear_steel"},
			{"default:tin_ingot", "", "default:tin_ingot"}
		}
	})
end
