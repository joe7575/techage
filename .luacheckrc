-- Specify the global variables
read_globals = {
	-- Defined by Minetest
	"vector", "PseudoRandom", "PcgRandom", "VoxelArea", "dump", "ItemStack",
	"string", "table",
	minetest = {
		fields = {
			is_protected = {read_only = false},
			get_translated_string = {read_only = false},
		},
		other_fields = true
	},

	-- Defined by minetest_game mods
	"creative", "doors", "screwdriver", "stairs",
	bucket = {
		fields = {
			liquids = {read_only = false, other_fields=true}
		},
		other_fields = true
	},
	default = {
		fields = {
			cool_lava = {read_only = false}
		},
		other_fields = true
	},

	-- Defined by other mods
	"craftguide", "hyperloop", "i3", "lcdlib", "mesecon", "minecart",
	"networks", "safer_lua", "stairsplus", "tubelib2", "unifieddyes",
	"unified_inventory",
	minecart = {
		fields = {
			tEntityNames = {read_only = false, other_fields=true}
		},
		other_fields = true
	},
}
globals = {"techage"}

-- Specify which warnings to ignore
ignore = {
	-- Style-related warnings, e.g. unused arguments and trailing whitespace
	"212", "213", "411", "421", "422", "431", "432", "542",
	"611", "612", "613", "614", "631",

	-- Warnings which are mostly caused by unclean code but may reveal
	-- accidental programming mistakes, e.g. unused variables
	"211",
}

-- Skip files with unfinished code
exclude_files = {"collider/terminal.lua"}
