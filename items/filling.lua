-- Needed for the trowel

techage.FILLING_ITEMS = {}

for name, ndef in pairs(minetest.registered_nodes) do
	-- test if it is a simple node without logic
	if ndef	and not ndef.groups.soil and name ~= "default:cobble" and
	not ndef.after_place_node and not ndef.on_construct then
		table.insert(techage.FILLING_ITEMS, name)
	end
end
