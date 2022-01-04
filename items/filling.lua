-- Needed for the trowel

local fillings = {}

minetest.register_on_mods_loaded(function()
	for name, ndef in pairs(minetest.registered_nodes) do
		-- test if it is a simple node without logic
		if ndef	and not ndef.groups.soil and name ~= "default:cobble" and
		not ndef.after_place_node and not ndef.on_construct then
			table.insert(fillings, name)
		end
	end
	networks.register_filling_items(fillings)
end)
