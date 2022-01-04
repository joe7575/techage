local S = techage.S

local function remove_pipe(itemstack, user, pointed_thing)
	local pos = pointed_thing.under
	if pos and user then
		if minetest.is_protected(pos, user:get_player_name()) then
			return itemstack
		end
    end

    if(pos ~= nil) then
        local node = minetest.get_node(pos)
        if(node.name == "techage:oil_drillbit2") then
            minetest.set_node(pos, {name = "air"})
            itemstack:add_wear(65636/200)
            return itemstack

        end -- if(node.name

    end -- if(pos ~= nil)

end -- remove_pipe


minetest.register_tool("techage:ta3_drill_pipe_wrench", {
	description = S("TA3 Drill Pipe Wrench"),
	inventory_image = "techage_pipe_wrench.png",
	wield_image = "techage_pipe_wrench.png",
	groups = {cracky=1},
	on_use = remove_pipe,
	stack_max = 1,
})

minetest.register_craft({
	output = "techage:ta3_drill_pipe_wrench",
	recipe = {
		{"default:diamond", "default:diamond", ""},
		{"dye:red", "default:steel_ingot", "dye:red"},
		{"default:steel_ingot", "", "default:steel_ingot"},
	},
})
