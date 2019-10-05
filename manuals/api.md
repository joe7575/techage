# Techage APIs und Design

*Hinweis: Dieses Dokument folgt dem markdown Standard und ist mit Typora erstellt. Damit hat man links das Inhaltsverzeichnis zur Übersicht und zum Navigieren. Zur Not geht aber jeder Editor.*

## History

- v1.0 - 03.10.2019 - Erster Entwurf

## Hierarchiediagramm

```
        +-------------------------------------------------------------+
        |                          consumer                           |
        |  (tubing/commands/states/formspec/power/connections/node)   |
        +-------------------------------------------------------------+
                |                    |                     |
                V                    V                     V
        +-----------------+  +-----------------+  +-------------------+
        |     command     |  |   node_states   |  |      power        |
        |(tubing/commands)|  |(states/formspec)|  |(power,connections)|
        +-----------------+  +-----------------+  +-------------------+
                |                    |                     |
                V                    V                     V
        +-------------------------------------------------------------+
        |                      Tube/tubelib2                          |
        |                  (tubes, mem, get_node_pos)                 |
        +-------------------------------------------------------------+
```

## Klasse `Tube` (Mod tubelib2)

Da Techage auf tubelib2 aufsetzt, soll auch diese Mod hier soweit behandelt werden, wie notwendig.

`tubelib2` dient zur Verknüpfung von Blöcken über tubes/pipes/cables. Tubes sind dabei "primary nodes", die Blöcke "secundary nodes". Die Features dabei sind:

- platzieren von Tubes, so dass diese mit benachbarten Tubes oder registrierten Blöcken eine Verbindung eingehen
- Event-Handling, so dass registrierte Blöcke über Änderungen an den Tube-Verbindungen informiert werden
- API-Funktionen, um die Position des Blockes gegenüber (peer node) zu bestimmen

```lua
-- From source node to destination node via tubes.
-- pos is the source node position, dir the output dir
-- The returned pos is the destination position, dir
-- is the direction into the destination node.
function Tube:get_connected_node_pos(pos, dir)
	local key = S(pos)
	if self.connCache[key] and self.connCache[key][dir] then
		local item = self.connCache[key][dir]
		return item.pos2, Turn180Deg[item.dir2]
	end	
	local fpos,fdir = self:walk_tube_line(pos, dir)
	local spos = get_pos(fpos,fdir)
	self:add_to_cache(pos, dir, spos, Turn180Deg[fdir])
	self:add_to_cache(spos, Turn180Deg[fdir], pos, dir)
	return spos, fdir
end

-- Check if node at given position is a tubelib2 compatible node,
-- able to receive and/or deliver items.
-- If dir == nil then node_pos = pos 
-- Function returns the result (true/false), new pos, and the node
function Tube:compatible_node(pos, dir)
	local npos = vector.add(pos, Dir6dToVector[dir or 0])
	local node = self:get_node_lvm(npos)
	return self.secondary_node_names[node.name], npos, node
end
```

Um mit `tubelib2` arbeiten zu können, muss zuvor eine Tube Instanz angelegt werden:

```lua
local Tube = tubelib2.Tube:new(...) 
```

wird eine Instanz von tubes/pipes/cables angelegt. Hier die Parameter:

```lua
dirs_to_check = attr.dirs_to_check or {1,2,3,4,5,6},
max_tube_length = attr.max_tube_length or 1000, 
primary_node_names = Tbl(attr.primary_node_names or {}), 
secondary_node_names = Tbl(attr.secondary_node_names or {}),
show_infotext = attr.show_infotext or false,
force_to_use_tubes = attr.force_to_use_tubes or false, -- Block an Block oder Tubes dazw.
clbk_after_place_tube = attr.after_place_tube, -- hiermit wird die Tube ausgetauscht (1)
tube_type = attr.tube_type or "unknown", -- hier einen eindeutigen Namen für die Instanz
```

zu (1): Bei einfachen Tubes reicht hier:

```lua
minetest.swap_node(pos, {name = "tubelib2:tube"..tube_type, param2 = param2})
```

tube_type bei "swap_node" ist "S" oder "A"  (straight or angled)

### Registrierung

Alle Blöcke mit Tube-Support müssen bei `tubelib2` registriert werden über:

```lua
Tube:add_secondary_node_names({names})
```

### Events

#### Änderungen an den Nodes

Damit die Tubes und die gegenüber angeschlossenen Blöcke über Änderungen informiert werden, existieren 2 Funktionen:

```lua
after_place_node = function(pos, placer)
    Tube:after_place_node(pos [, {tube_dir}])		
end,

after_dig_node = function(pos, oldnode, oldmetadata, digger)
    Tube:after_dig_node(pos [, {tube_dir}])
end,
```

Diese müssen in jedem Fall aufgerufen werden, sonst werden die Daten der benachbarten Tubes nicht aktualisiert. Der Parameter `tube_dir` ist optional, macht aber Sinn, so dass nicht alle 6 Seiten geprüft werden müssen.

#### Änderungen an Tubes/anderen Nodes

Damit der Block über Änderungen an Tubes oder Peer-Blöcken informiert wird, gibt es zwei Möglichkeiten:

1. Knoten-spezifische callback Funktionen
2. Zentrale callback Funktionen

##### 1. Knoten-spezifische callback Funktion `tubelib2_on_update`

```
tubelib2_on_update(node, pos, out_dir, peer_pos, peer_in_dir)
```

Die Funktion muss Teil von `minetest.register_node()` sein.

##### 2. Zentrale callback Funktion `register_on_tube_update`

```lua
Tube:register_on_tube_update(function(node, pos, out_dir, peer_pos, peer_in_dir)
    ...
end)
```

Wird 1) aufgerufen, wird 2) **nicht** mehr gerufen!

### API Funktionen

```lua
tubelib2.get_pos(pos, dir)
```



## Techage `command`

### Dir vs. Side

`tubelib2` arbeitet nur mit dirs (siehe oben). Oft ist aber die Arbeitsweise mit `sides` einfacher.

Techage definiert `sides` , die wie folgt definiert sind `{B=1, R=2, F=3, L=4, D=5, U=6}`:

```
sides:                                  dirs: 
            U                    
            |    B               
            |   /                                 6
         +--|-----+                               |  1
        /   o    /|                               | /
       +--------+ |                               |/
L <----|        |o----> R               4 <-------+-------> 2
       |    o   | |                              /|
       |   /    | +                             / |
       |  /     |/                             3  |
       +-/------+                                 5
        /   |
       F    |
            D 
```

`techage/command.lua` definiert hier:

```lua
techage.side_to_outdir(side, param2)  -- "B/R/F/L/D/U", node.param2
```

In Ergänzung zu `tubelib2` sind in `command` Funktionen für den Austausch von Items von Inventar zu Inventar (Tubing) und Kommandos für Datenaustausch definiert. 

Zusätzlich etabliert `command` das Knoten-Nummern-System für die Adressierung bei Kommandos.

Dazu muss jeder Knoten bei `command` an- und abgemeldet werden:

```lua
techage.add_node(pos, name) --> number
techage.remove_node(pos)
```

Soll der Knoten Kommandos empfangen und/oder Items austauschen können, ist folgende Registrierung notwendig (alle Funktionen sind optional):

```lua
techage.register_node(names, {
        on_pull_item = func(pos, in_dir, num),
        on_push_item = func(pos, in_dir, item),
        on_unpull_item = func(pos, in_dir, item),
        on_recv_message = func(pos, src, topic, payload),
        on_node_load = func(pos),  -- LBM function
        on_transfer = func(pos, in_dir, topic, payload),
})
```

### Client API

Bspw. der Pusher als Client nutzt:

```lua
techage.pull_items(pos, out_dir, num)
techage.push_items(pos, out_dir, stack)
techage.unpull_items(pos, out_dir, stack)
```

### Server  API

Für den Server (chest mit Inventar) existieren dazu folgende Funktionen:

```lua
techage.get_items(inv, listname, num)
techage.put_items(inv, listname, stack)
techage.get_inv_state(inv, listname)
```

### Hopper  API

Es gibt bspw. mit dem Hopper aber auch einen Block, der nicht über Tubes sondern nur mit direkten Nachbarn Items austauschen soll. Dazu dient dieser Satz an Funktionen:

```lua
techage.neighbour_pull_items(pos, out_dir, num)
techage.neighbour_push_items(pos, out_dir, stack)
techage.neighbour_unpull_items(pos, out_dir, stack)
```

### Nummern bezogene Kommando API

Kommunikation ohne Tubes, Addressierung nur über Knoten-Nummern

```lua
techage.not_protected(number, placer_name, clicker_name) --> true/false
techage.check_numbers(numbers, placer_name) --> true/false (for send_multi)
techage.send_multi(src, numbers, topic, payload) --> to many nodes
techage.send_single(src, number, topic, payload) --> to one node with response
```

### Positions bezogene Kommando API

Kommunikation mit Tubes oder mit direkten Nachbar-Knoten über pos/dir.  Im Falle von Tubes muss bei `network` die Tube Instanz angegeben werden.

```lua
techage.transfer(pos, outdir, topic, payload, network, nodenames)
-- The destination node location is either:
-- A) a destination position, specified by pos
-- B) a neighbor position, specified by caller pos/outdir, or pos/side
-- C) a tubelib2 network connection, specified by caller pos/outdir, or pos/side
-- outdir is one of: 1..6 or alternative a 'side'
-- side is one of: "B", "R", "F", "L", "D", "U"
-- network is a tuebelib2 network instance
-- opt: nodenames is a table of valid callee node names
```

### Sonstige API

```lua
techage.side_to_indir(side, param2) --> indir
techage.get_node_info(dest_num) --> { pos, name }
techage.get_node_number(pos) --> number
techage.get_new_number(pos, name) --> should ne be needed (repair function)
```

## Wrapper `power`

Im Gegensatz zu `tubelib2` und `command` verwaltet `power` ganze Netzwerke und nicht nur Einzelverbindungen zwischen zwei Knoten. Dazu muss `power` in jedem Knoten eine Connection-Liste anlegen, die alle angeschlossenen Tubes beinhaltet.

Nur so können mit der internen Funktion `connection_walk` alle Knoten im Netzwerk erreicht werden.

`power` besitzt die Funktion:

```lua
techage.power.register_node(names, {
	conn_sides = {"L", "R", "U", "D", "F", "B"},
	on_power = func(pos, mem),  -- für Verbraucher (einschalten)
	on_nopower = func(pos, mem),  -- für Verbraucher (ausschalten)
	on_getpower = func(pos, mem),  -- für Solarzellen (Strom einsammeln)
	power_network = Tube,  -- tubelib2 Instanz
    after_place_node = func(pos, placer, itemstack, pointed_thing),
    after_dig_node = func(pos, oldnode, oldmetadata, digger)
    after_tube_update = func(node, pos, out_dir, peer_pos, peer_in_dir)
})
```

Durch die Registrierung des Nodes werden die Knoten-eigenen `after_...` Funktionen überschrieben. Optional können deshalb eigene Funktionen bei `register_node`  übergeben werden.

```lua
-- after_place_node decorator
after_place_node = function(pos, placer, itemstack, pointed_thing)
    local res = <node>.after_place_node(pos, placer, itemstack, pointed_thing)
    <Tube>:after_place_node(pos)
    return res
end,
-- after_dig_node decorator
after_dig_node = function(pos, oldnode, oldmetadata, digger)
    <Tube>:after_dig_node(pos)
    minetest.after(0.1, tubelib2.del_mem, pos)  -- At latest...
    return <node>.after_dig_node(pos, oldnode, oldmetadata, digger)
end,
-- called after any connection change via 
--   --> tubelib2 
--     --> register_on_tube_update callback (cable)
--       --> after_tube_update (power)
after_tube_update = function(node, pos, out_dir, peer_pos, peer_in_dir)
    mem.connections = ...  -- aktualisieren/löschen
    return <node>.after_tube_update(node, pos, out_dir, peer_pos, peer_in_dir)
end,

```

Und es erfolgt eine Registrierung bei Tube:

```
<Tube>:add_secondary_node_names({name})
```

**Damit ist es nicht mehr notwendig, die `tubelib2` callback Funktionen `after_place_node` und `after_dig_node` sowie `after_tube_update` selbst zu codieren.**

**Soll aber der Knoten außer Power auch Kommandos empfangen oder senden können, oder am Tubing teilnehmen, so müssen die `command` bezogenen Funktionen zusätzlich beachtet werden.**

### Alternative API

Sollen die Knoten-eigenen `after_...` Funktionen nicht überschrieben, so bietet sich folgende, alternative API an:

```lua
techage.power.enrich_node(names, pwr_def)
techage.power.after_place_node(pos)
techage.power.after_dig_node(pos, oldnode)
techage.power.after_tube_update2(node, pos, out_dir, peer_pos, peer_in_dir)
```

### `power`/`power2` API

```lua
techage.power.side_to_dir(param2, side)  --> outdir
techage.power.side_to_outdir(pos, side)  --> outdir
techage.power.set_conn_dirs(pos, sides)  --> store as meta "power_dirs"
techage.get_pos(pos, side)               --> new pos
techage.power.after_rotate_node(pos, cable)  -- update cables
techage.power.percent(max_val, curr_val) --> percent value
techage.power.formspec_power_bar(max_power, current_power)  --> formspec string
techage.power.power_cut(pos, dir, cable, cut)  -- for switches

techage.power.network_changed(pos, mem) -- for each network change from any node

techage.power.generator_start(pos, mem, available) -- on start
techage.power.generator_update(pos, mem, available) -- on any change of performance
techage.power.generator_stop(pos, mem) -- on stop
techage.power.generator_alive(pos, mem) -- every 2 s

techage.power.consumer_start(pos, mem, cycle_time, needed)
techage.power.consumer_stop(pos, mem)
techage.power.consumer_alive(pos, mem)
techage.power.power_available(pos, mem, needed) -- lamp turn on function

techage.power.secondary_start(pos, mem, available, needed)
techage.power.secondary_stop(pos, mem)
techage.power.secondary_alive(pos, mem, capa_curr, capa_max)

techage.power.power_accounting(pos, mem) --> {network data...} (used by info tool)
techage.power.get_power(start_pos) --> sum (used by solar cells)
techage.power.power_network_available(start_pos)  --> bool (used by TES generator)
techage.power.mark_nodes(name, start_pos) -- used by debugging tool
techage.power.limited_connection_walk(pos, clbk)  --> num_nodes (used by terminal)
```

## Klasse `NodeStates`

`NodeStates` abstrahiert  die Zustände einer Maschine:

```lua
techage.RUNNING = 1	-- in normal operation/turned on
techage.BLOCKED = 2 -- a pushing node is blocked due to a full destination inventory
techage.STANDBY = 3	-- nothing to do (e.g. no input items), or node (world) not loaded
techage.NOPOWER = 4	-- only for power consuming nodes, no operation
techage.FAULT   = 5	-- any fault state (e.g. wrong source items)
techage.STOPPED = 6	-- not operational/turned off
```

Dazu muss eine Instanz von `NodeStates` angelegt werden:

```lua
State = techage.NodeStates:new({
        node_name_passive = "mymod:name_pas",
        node_name_active = "mymod:name_act",
        infotext_name = "MyBlock",
        cycle_time = 2,
        standby_ticks = 6,
        formspec_func = func(self, pos, mem),  --> string
        on_state_change = func(pos, old_state, new_state),
        can_start = func(pos, mem, state)  --> true or false/<error string>
        has_power = func(pos, mem, state), --> true/false (for consumer)
        start_node = func(pos, mem, state),
        stop_node = func(pos, mem, state),
    })
```

**Wird `NodeStates` verwendet, muss der Knoten die definierten Zustände unterstützen und sollte die formspec mit dem Button und die callbacks `can_start`, `start_node` und `stop_node` implementieren.**

### Methods

```lua
node_init(pos, mem, number) -- to be called once
stop(pos, mem)
start(pos, mem)
start_from_timer(pos, mem) -- to be used from node timer functions
standby(pos, mem)
blocked(pos, mem)
nopower(pos, mem)
fault(pos, mem, err_string)  -- err_string is optional
get_state(mem) --> state
is_active(mem)
start_if_standby(pos) -- used from allow_metadata_inventory functions
idle(pos, mem) -- To be called if node is idle
keep_running(pos, mem, val, num_items) -- to keep the node in state RUNNING
state_button_event(pos, mem, fields) -- called from on_receive_fields
get_state_button_image -- see techage.state_button()
on_receive_message(pos, topic, payload) -- for command interface
on_node_load(pos, not_start_timer) -- LBM actions

```

### Helper API

```lua
techage.state_button(state) --> button layout for formspec
techage.get_power_image(pos, mem) --> power symbol for formspec

techage.is_operational(mem) -- true if node_timer should be executed
techage.needs_power(mem) --> true/false state dependent
techage.needs_power2(state) --> true/false state dependent
techage.get_state_string(mem) --> "running"

NodeStates:node_init(pos, mem, number)
```

## Wrapper `consumer`

Wie auch `power` bietet `consumer` einen Registrierungs-Wrapper, der dem Knoten einige Eigenschaften und Funktionen hinzufügt.

```lua
techage.register_consumer("autocrafter", S("Autocrafter"), tiles, {
		drawtype = "normal",
		cycle_time = CYCLE_TIME,
		standby_ticks = STANDBY_TICKS,
		formspec = formspec,
		tubing -- anstatt 'techage.register_node' 
		after_place_node = func(pos, placer), -- knotenspezifischer Teil
		can_dig = fubnc(pos, player), -- knotenspezifischer Teil
		node_timer = func(pos, elapsed), -- knotenspezifischer Teil
		on_receive_fields = func(pos, formname, fields, player), -- knotenspez. Teil
		allow_metadata_inventory_put = allow_metadata_inventory_put,
		allow_metadata_inventory_move = allow_metadata_inventory_move,
		allow_metadata_inventory_take = allow_metadata_inventory_take,
		groups = {choppy=2, cracky=2, crumbly=2},
		sounds = default.node_sound_wood_defaults(),
		num_items = {0,1,2,4}, -- Verarbeitungsleistung in items/cycle
		power_consumption = {0,4,6,9}, -- Stromverbrauch (optional)
	}) --> node_name_ta2, node_name_ta3, node_name_ta4
```

Diese `register_consumer` Funktion deckt alles generische ab, was ein Knoten bzgl. Power, Tubing, Kommandos (Status, on/off), formspec, swap_node(act/pas) benötigt, damit auch node_states, tubelib2.

Dabei werden auch bereits definiert:

- `push` und `pull` Richtung für das Tubing (links/rechts)
- Umschalten des Knotens zwischen aktiv und passiv
- `has_power` / `start_node` / `stop_node` / `on_power` / `on_nopower` 
- Unterstützung Achsenantrieb (TA2) oder Strom (TA3+)
- Strom/Achsen von vorne oder hinten (alles andere muss selbst definiert werden)

Ein einfaches Beispiele dafür wäre: `pusher.lua`

**Es darf in `after_place_node`  kein `tubelib2.init_mem(pos)` aufgerufen werden, sonst werden die Definitionen wieder zerstört!!!**

## Anhang

### Unschönheiten

#### Problem: Verbindungen zu zwei Netzwerken

Es ist nicht möglich, einen Knoten in zwei unterschiedlichen Netzwerken (bspw. Strom, Dampf) über `techage.power.register_node()` anzumelden. `power` würde zweimal übereinander die gleichen Knoten-internen Variablen wie `mem.connections` im Knoten anlegen und nutzen. Das geht und muss schief gehen. Aktuell gibt es dafür keine Lösung.

### ToDo

- tubelib2.mem beschreiben
- Aufteilung in node/meta/mem/cache beschreiben

