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



## Register Custom Machines (TA2/TA3/TA4/TA5)

Register a custom processing machine that automatically generates all 4 stages (TA2, TA3, TA4, TA5) with power consumption and state management.

```lua
techage.register_consumer(base_name, inv_name, tiles, tNode, validStates, node_name_prefix, inv_name_prefix)
```

### Parameters:

- `base_name` (string): Base name for the node (e.g., `"grinder"` generates `"techage:ta2_grinder_pas"`, `"techage:ta2_grinder_act"`, etc.)
- `inv_name` (string): Display name shown in inventory and formspec (e.g., `"Grinder"` becomes `"TA2 Grinder"`, `"TA3 Grinder"`, etc.)
- `tiles` (table): Texture definitions with `pas` (passive) and `act` (active) states:
  - Use `#` as placeholder for stage number (2-5)
  - Use `{power}` as placeholder for power connection texture
  - Use `@@` if you need a literal `#` character
- `tNode` (table): Node definition table (see below for properties)
- `validStates` (table, optional): Control which stages to generate, e.g., `{false, true, false, false}` for TA2 only. Default: `{true, true, true, true}`
- `node_name_prefix` (string, optional): Prefix for node names. Default: `"techage:ta"`
- `inv_name_prefix` (string, optional): Prefix for inventory name. Default: `""`

### Returns:

Four node names: `name_ta2_pas, name_ta3_pas, name_ta4_pas, name_ta5_pas`

### tNode Properties:

**Required for powered machines:**
- `power_consumption` (table): Power consumption per stage: `{0, 4, 6, 9}` (0=TA2 uses axle power)
- `num_items` (table): Items processed per cycle: `{0, 1, 2, 4}`

**Timing:**
- `cycle_time` (number): Base cycle time in seconds (default: 2)
- `standby_ticks` (number): Ticks before entering standby mode

**Visual:**
- `drawtype` (string): Node drawtype (e.g., `"nodebox"`, `"normal"`)
- `paramtype` (string): Usually `"light"` for nodebox
- `node_box` (table): Node box definition
- `selection_box` (table): Selection box definition

**Callbacks:**
- `formspec` (function): `function(self, pos, nvm)` - Returns formspec string
- `node_timer` (function): `function(pos, elapsed)` - Called every cycle
- `after_place_node` (function): `function(pos, placer, itemstack, pointed_thing)`
- `after_dig_node` (function): `function(pos, oldnode, oldmetadata, digger)`
- `on_receive_fields` (function): `function(pos, formname, fields, player)`
- `on_rightclick` (function): `function(pos, node, clicker, itemstack, pointed_thing)`
- `can_dig` (function): `function(pos, player)` - Return true if node can be dug
- `can_start` (function): `function(pos, nvm, state)` - Return true or error message string
- `on_state_change` (function): `function(pos, old_state, state)` - Called on state changes

**Inventory callbacks:**
- `allow_metadata_inventory_put` (function)
- `allow_metadata_inventory_move` (function)
- `allow_metadata_inventory_take` (function)
- `on_metadata_inventory_put` (function)
- `on_metadata_inventory_move` (function)
- `on_metadata_inventory_take` (function)

**Tube/Power connections:**
- `tubing` (table): Tube callback functions (see example below)
- `tube_sides` (table): Valid tube connection sides, e.g., `{L=1, R=1, U=1}`
- `power_sides` (table): Valid power connection sides, e.g., `{F=1, B=1}` (default: `{F=1, B=1, U=1, D=1}`)

**Other:**
- `groups` (table): Node groups (e.g., `{choppy=2, cracky=2, crumbly=2}`)
- `sounds` (table): Node sounds
- `drop` (string): Item to drop when node is dug
- `preserve_metadata` (function): For preserving metadata on dig
- `on_rotate` (function): Rotation handling (default: `screwdriver.disallow`)
- `ta_rotate_node` (function): Custom rotation handler
- `ta3_formspec` (number): Custom formspec for TA3 (stage == 3)
- `ta4_formspec` (number): Custom formspec for TA4 (stage == 4)

### Example:

```lua
local S = techage.S
local M = minetest.get_meta

local function formspec(self, pos, nvm)
    return "size[8,8]"..
        default.gui_bg..
        default.gui_bg_img..
        default.gui_slots..
        "list[context;src;0,0;3,3;]"..
        "list[context;dst;5,0;3,3;]"..
        "list[current_player;main;0,4;8,4;]"..
        "listring[context;dst]"..
        "listring[current_player;main]"..
        "listring[context;src]"..
        "listring[current_player;main]"
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
    if minetest.is_protected(pos, player:get_player_name()) then
        return 0
    end
    if listname == "src" then
        return stack:get_count()
    elseif listname == "dst" then
        return 0
    end
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
    if minetest.is_protected(pos, player:get_player_name()) then
        return 0
    end
    return stack:get_count()
end

local tiles = {
    pas = {
        "techage_filling_ta#.png^techage_frame_ta#_top.png",
        "techage_filling_ta#.png^techage_frame_ta#.png",
        "techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_outp.png",
        "techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_inp.png",
        "techage_filling_ta#.png^techage_appl_grinder.png^techage_frame_ta#.png",
        "techage_filling_ta#.png^techage_appl_grinder.png^techage_frame_ta#.png^{power}",
    },
    act = {
        -- Animated textures for active state
        "techage_filling_ta#.png^techage_frame_ta#_top.png",
        "techage_filling_ta#.png^techage_frame_ta#.png",
        "techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_outp.png",
        "techage_filling_ta#.png^techage_frame_ta#.png^techage_appl_inp.png",
        {
            name = "techage_filling4_ta#.png^techage_appl_grinder4.png^techage_frame4_ta#.png",
            backface_culling = false,
            animation = {type = "vertical_frames", aspect_w = 32, aspect_h = 32, length = 2.0},
        },
        {
            name = "techage_filling4_ta#.png^techage_appl_grinder4.png^techage_frame4_ta#.png^{power}",
            backface_culling = false,
            animation = {type = "vertical_frames", aspect_w = 32, aspect_h = 32, length = 2.0},
        },
    },
}

local tubing = {
    on_pull_item = function(pos, in_dir, num)
        local meta = M(pos)
        if meta:get_int("pull_dir") == in_dir then
            local inv = meta:get_inventory()
            return techage.get_items(pos, inv, "dst", num)
        end
    end,
    on_push_item = function(pos, in_dir, stack)
        local meta = M(pos)
        if meta:get_int("push_dir") == in_dir or in_dir == 5 then
            local inv = meta:get_inventory()
            return techage.put_items(inv, "src", stack)
        end
    end,
    on_unpull_item = function(pos, in_dir, stack)
        local meta = M(pos)
        if meta:get_int("pull_dir") == in_dir then
            local inv = meta:get_inventory()
            return techage.put_items(inv, "dst", stack)
        end
    end,
    on_recv_message = function(pos, src, topic, payload)
        return CRD(pos).State:on_receive_message(pos, topic, payload)
    end,
}

local function processing(pos, crd, nvm, inv)
    -- Your processing logic here
    -- Check for items in inv:get_list("src")
    -- Process them and put results in inv:get_list("dst")
end

local function keep_running(pos, elapsed)
    local nvm = techage.get_nvm(pos)
    local crd = CRD(pos)
    local inv = M(pos):get_inventory()
    processing(pos, crd, nvm, inv)
end

local node_name_ta2, node_name_ta3, node_name_ta4 = techage.register_consumer(
    "mygrinder",
    S("My Grinder"),
    tiles,
    {
        drawtype = "nodebox",
        paramtype = "light",
        node_box = {
            type = "fixed",
            fixed = {-8/16, -8/16, -8/16, 8/16, 8/16, 8/16},
        },
        selection_box = {
            type = "fixed",
            fixed = {-8/16, -8/16, -8/16, 8/16, 8/16, 8/16},
        },
        cycle_time = 2,
        standby_ticks = 3,
        formspec = formspec,
        tubing = tubing,
        after_place_node = function(pos, placer)
            local inv = M(pos):get_inventory()
            inv:set_size('src', 9)
            inv:set_size('dst', 9)
        end,
        can_dig = function(pos, player)
            local inv = M(pos):get_inventory()
            return inv:is_empty("dst") and inv:is_empty("src")
        end,
        node_timer = keep_running,
        allow_metadata_inventory_put = allow_metadata_inventory_put,
        allow_metadata_inventory_take = allow_metadata_inventory_take,
        groups = {choppy=2, cracky=2, crumbly=2},
        sounds = default.node_sound_wood_defaults(),
        num_items = {0, 1, 2, 4},          -- Items per cycle for TA2/3/4/5
        power_consumption = {0, 4, 6, 9},  -- Power consumption for TA2/3/4/5
        tube_sides = {L=1, R=1, U=1},      -- Left, Right, Up
    }
)
```

### Important Notes:

1. **Tube connections**: By default, tubes connect on left (input) and right (output) sides. Use `tube_sides` to customize.

2. **Power connections**: By default, power connects on front, back, up, and down. TA2 uses axle power, TA3+ uses electric power.

3. **State management**: The function automatically handles passive/active states and provides `CRD(pos).State` object with methods like:
   - `State:start(pos, nvm)` - Start the machine
   - `State:stop(pos, nvm)` - Stop the machine
   - `State:standby(pos, nvm)` - Enter standby mode
   - `State:keep_running(pos, nvm, ticks)` - Keep running for specified ticks
   - `State:is_active(nvm)` - Check if machine is active

4. **Complex machines with multiple liquid I/O**: For machines that need multiple fluid inputs/outputs (like an electrolyzer with 1 input and 3 outputs), `register_consumer` may be too limited. In such cases, manually register nodes using `techage.NodeStates:new()` and handle liquid connections with `networks.liquid.register_nodes()`. See `hydrogen/electrolyzer.lua` for an example.

5. **Custom properties**: Properties starting with underscore (`_`) are copied to both passive and active node definitions.

