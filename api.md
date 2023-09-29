# Techage API Functions

Techage API function to adapt/prepare techage for other mods/games.



## Move/Fly Controller

Register node names for nodes allowed to be moved by fly/move controllers.

This is only necessary for undiggable/intelligent nodes with one of the following attributes:

- ```drop = ""```
- ```diggable = false```
- ```after_dig_node ~= nil```

```lua
techage.register_simple_nodes(node_names, is_valid)
```

- `is_valid = true`  - Add node to the list of simple nodes
- `is_valid = false`  - Remove node from the list of simple nodes

Example:

```lua
techage.register_simple_nodes({"techage:power_lineS"}, true)
```

For door nodes used as sliding doors by means of the move controller, call in addition:

```lua
techage.flylib.protect_door_from_being_opened(node_name)
```



## TA1 Hammer

Register stone/gravel name pair for the hammer blow:

```lua
techage.register_stone_gravel_pair(stone_name, gravel_name)
```

Example:

```lua
techage.register_stone_gravel_pair("default:stone", "default:gravel")
```



## TA1 Melting Pot

Register a pot recipe:

```lua
techage.ironage_register_recipe(recipe)
```

Examples:

```lua
techage.ironage_register_recipe({
	output = "default:obsidian",
	recipe = {"default:cobble"},
	heat = 10,	-- Corresponds to the tower height
	time = 8,	-- Cooking time in seconds
})
techage.ironage_register_recipe({
	output = "default:bronze_ingot 4",
	recipe = {"default:copper_ingot", "default:copper_ingot", "default:copper_ingot", "default:tin_ingot"},
	heat = 4,	-- Corresponds to the tower height
	time = 8,	-- Cooking time in seconds
})
```



## TA2/TA3/TA4 Autocrafter

Register any nodes/items that should not be crafted via the autocrafter.

```lua
techage.register_uncraftable_items(item_name)
```



## TA2/TA3/TA4 Gravel Sieve

Change the probability of ores or register new ores for sieving. 

```lua
techage.register_ore_for_gravelsieve(ore_name, probability)
```

Example:

```lua
techage.register_ore_for_gravelsieve("default:iron_lump", 30)
```

Default values for MTG are:

```lua
-- higher value means less frequent occurrence
techage:baborium_lump    100000  -- hardly ever
default:mese_crystal     548     -- every 548th time
default:gold_lump        439
default:tin_lump         60
default:diamond          843
default:copper_lump      145
default:coal_lump        11
default:iron_lump        15
```



## TA2/TA3/TA4 Gravel Rinser

Add a rinser recipe.

```lua
techage.add_rinser_recipe(recipe)
```

Example:

```lua
techage.add_rinser_recipe({input = "techage:sieved_gravel", output = "techage:usmium_nuggets", probability = 30})
```



## TA2/TA3/TA4 Grinder

Add a grinder recipe.

```lua
techage.add_grinder_recipe(recipe, ta1_permitted)
```

Examples:

```lua
echage.add_grinder_recipe({input = "default:cobble", output = "default:gravel"})
techage.add_grinder_recipe({input = "default:sandstone", output = "default:sand 4"})
```



## TA3/TA4 Electronic Fab, TA4 Doser

Add recipes to an electronic fab or doser (chemical reactor):


```lua
techage.recipes.add(rtype, recipe)
```

`rtype` is one of: `ta2_electronic_fab` , `ta4_doser`

A recipe look like:

```
{
    output = "<item-name> <units>",  -- units = 1..n
    waste = "<item-name> <units>",   -- units = 1..n
    input = {                        -- up to 4 items
        "<item-name> <units>",
        "<item-name> <units>",
    },
}
```

Examples:

```lua
techage.recipes.add("ta2_electronic_fab", {
	output = "techage:vacuum_tube 2",
	waste = "basic_materials:empty_spool 1",
	input = {"default:glass 1", "basic_materials:copper_wire 1", "basic_materials:plastic_sheet 1", "techage:usmium_nuggets 1"}
})

techage.recipes.add("ta4_doser", {
	output = "techage:naphtha 1",
	input = {
		"techage:fueloil 1",
	},
	catalyst = "techage:gibbsite_powder",
})
```



## TA3 Furnace

Register recipe:

```lua
techage.furnace.register_recipe(recipe)
```

Example:

```lua
techage.furnace.register_recipe({
	output = "default:bronze_ingot 4",
	recipe = {"default:copper_ingot", "default:copper_ingot", "default:copper_ingot", "default:tin_ingot"},
	time = 2,  -- in seconds
}) 
```



## Assembly Tool

Disable a block from being removed by the assembly tool:

```lua
techage.disable_block_for_assembly_tool(block_name)
```

