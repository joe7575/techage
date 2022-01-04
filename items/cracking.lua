--[[

	TechAge
	=======

	Copyright (C) 2019-2020 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	Cracking breaks long chains of hydrocarbons into short chains using a catalyst.
	Gibbsite powder serves as a catalyst (is not consumed).
	It can be used to convert bitumen into fueloil, fueloil into naphtha and naphtha into gasoline.

	In hydrogenation, pairs of hydrogen atoms are added to a molecule to convert short-chain
	hydrocarbons into long ones.
	Here iron powder is required as a catalyst (is not consumed).
	It can be used to convert gas (propan) into isobutane, isobutane into gasoline, gasoline into naphtha,
	naphtha into fueloil, and fueloil into bitumen.

]]--

-- Cracking
techage.recipes.add("ta4_doser", {
	output = "techage:fueloil 1",
	input = {
		"techage:bitumen 1",
	},
	catalyst = "techage:gibbsite_powder",
})

techage.recipes.add("ta4_doser", {
	output = "techage:naphtha 1",
	input = {
		"techage:fueloil 1",
	},
	catalyst = "techage:gibbsite_powder",
})

techage.recipes.add("ta4_doser", {
	output = "techage:gasoline 1",
	input = {
		"techage:naphtha 1",
	},
	catalyst = "techage:gibbsite_powder",
})

-- Hydrogenate
techage.recipes.add("ta4_doser", {
	output = "techage:isobutane 1",
	input = {
		"techage:gas 1",
		"techage:hydrogen 1",
	},
	catalyst = "techage:iron_powder",
})

techage.recipes.add("ta4_doser", {
	output = "techage:gasoline 1",
	input = {
		"techage:isobutane 1",
		"techage:hydrogen 1",
	},
	catalyst = "techage:iron_powder",
})

techage.recipes.add("ta4_doser", {
	output = "techage:naphtha 1",
	input = {
		"techage:gasoline 1",
		"techage:hydrogen 1",
	},
	catalyst = "techage:iron_powder",
})

techage.recipes.add("ta4_doser", {
	output = "techage:fueloil 1",
	input = {
		"techage:naphtha 1",
		"techage:hydrogen 1",
	},
	catalyst = "techage:iron_powder",
})

techage.recipes.add("ta4_doser", {
	output = "techage:bitumen 1",
	input = {
		"techage:fueloil 1",
		"techage:hydrogen 1",
	},
	catalyst = "techage:iron_powder",
})
