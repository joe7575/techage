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

minetest.override_item("default:gravel", {groups = {crumbly = 2, gravel = 1, falling_node = 1}})

-- Register all known mobs mods for the move/fly controllers
techage.register_mobs_mods("ts_skins_dummies")
techage.register_mobs_mods("mobs")
techage.register_mobs_mods("draconis")
techage.register_mobs_mods("mobkit")
techage.register_mobs_mods("animalia")
techage.register_mobs_mods("mobs_animal")
techage.register_mobs_mods("mobs_monster")
techage.register_mobs_mods("dmobs")
techage.register_mobs_mods("mob_horse")
techage.register_mobs_mods("petz")
techage.register_mobs_mods("mobs_npc")
techage.register_mobs_mods("livingnether")
techage.register_mobs_mods("extra_mobs")
techage.register_mobs_mods("nssm")
techage.register_mobs_mods("goblins")
techage.register_mobs_mods("animalworld")
techage.register_mobs_mods("aliveai")
techage.register_mobs_mods("people")
techage.register_mobs_mods("paleotest")
techage.register_mobs_mods("mobs_balrog")
techage.register_mobs_mods("wildlife")
techage.register_mobs_mods("mobs_skeletons")
techage.register_mobs_mods("mobs_dwarves")
techage.register_mobs_mods("mobf_trader")
techage.register_mobs_mods("ts_vehicles_cars")

-- Used as e.g. crane cable
techage.register_simple_nodes({"techage:power_lineS"}, true)