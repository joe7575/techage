--[[

	TechAge
	=======

	Copyright (C) 2019 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information
	
	Collect data of registered nodes

]]--


techage.aEtherealDirts = {
	"ethereal:fiery_dirt",
	"ethereal:cold_dirt",
	"ethereal:crystal_dirt",
	"ethereal:gray_dirt",
	"ethereal:mushroom_dirt",
	"ethereal:prairie_dirt",
	"ethereal:grove_dirt",
	"ethereal:jungle_dirt",
	"ethereal:bamboo_dirt",
}

techage.aAnyKindOfDirtBlocks = {}

minetest.register_on_mods_loaded(function()
	for name, ndef in pairs(minetest.registered_nodes) do
		if string.find(name, "dirt") and 
				ndef.drawtype == "normal" and
				ndef.groups.crumbly and ndef.groups.crumbly > 0 then
			techage.aAnyKindOfDirtBlocks[#techage.aAnyKindOfDirtBlocks + 1] = name
		end
	end
end)

