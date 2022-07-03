# TA4 Lua Controller

![Lua Controller](https://github.com/joe7575/techage/blob/master/textures/techage_lua_controller_inventory.png)

The TA4 Lua Controller is a small computer, programmable in Lua to control your machinery.
In contrast to the ICTA Controller this controller allows to implement larger and more complex programs.

But to write Lua scripts, some knowledge with the programming language Lua is required. 

Minetest uses Lua 5.1. The reference document for Lua 5.1 is [here](https://www.lua.org/manual/5.1/). The  book [Programming in Lua (first edition)](https://www.lua.org/pil/contents.html) is also a perfect source for learning Lua.

This TA4 Lua Controller manual is also available as PDF:

https://github.com/joe7575/techage/blob/master/manuals/ta4_lua_controller_EN.pdf



## Table of Contents

- [TA4 Lua Controller Blocks](#TA4-Lua-Controller-Blocks)
    - [TA4 Lua Controller](#TA4-Lua-Controller)
    - [Battery](#Battery)
    - [TA4 Lua Server](#TA4-Lua-Server)
    - [TA4 Lua Controller Terminal](#TA4-Lua-Controller-Terminal)
    - [TA4 Sensor Chest](#TA4-Sensor-Chest)
- [Lua Functions and Environment](#Lua-Functions-and-Environment)
    - [Lua Functions and Limitations](#Lua-Functions-and-Limitations)
    - [Arrays, Stores, and Sets](#Arrays,-Stores,-and-Sets)
    - [Initialization, Cyclic Task, and Events](#Initialization,-Cyclic-Task,-and-Events)
- [Lua Controller Functions](#Lua-Controller-Functions)
    - [Controller local Functions](#Controller-local-Functions)
    - [Techage Command Functions](#Techage-Command-Functions)
    - [Server and Terminal Functions](#Server-and-Terminal-Functions)
    - [Further Functions](#Further-Functions)
- [Example Scripts](#Example-Scripts)
    - [Simple Counter](#Simple-Counter)
    - [Hello World](#Hello-World)
    - [For Loop with range(from, to)](#For-Loop-with-range(from,-to))
    - [Monitoring Chest & Furnace](#Monitoring-Chest-&-Furnace)
    - [Simple Calculator](#Simple-Calculator)
    - [Welcome Display](#Welcome-Display)
    - [Sensor Chest](#Sensor-Chest)
    - [Emails](#Emails)



## TA4 Lua Controller Blocks

### TA4 Lua Controller

The controller block has a menu form with the following tabs:

- the `init` tab for the initialization code block
- the `func` tab for the Lua functions
- the `loop` tab for the main code block
- the `outp` tab for debugging outputs via `$print()`
- the `notes` tab for your code snippets or other notes (like a clipboard)
- the `help` tab with information to the available functions

The controller needs power to work. A battery pack has to be placed nearby.

### Battery

The battery pack has to be placed near the controller (1 block distance).
The needed battery power is directly dependent on the CPU time the controller consumes.
Because of that, it is important to optimize the execution time of the code (which helps the admin to keep server lags down :))

The controller will be restarted (init() is called) every time the Minetest server starts again.
To store data non-volatile (to pass a server restart), the "TA4 Lua Server" block has to be used.

### TA4 Lua Server

The Server block is used to store data from Lua Controllers nonvolatile. It can also be used for communication purposes between several Lua Controllers.
Only configured players have access to the server. Therefore, the server has a menu to enter player names. 

For special Server functions, see "Server and Terminal Functions"

### TA4 Lua Controller Terminal

The Terminal is used to send command strings to the controller.
In turn, the controller can send text strings to the terminal.
The Terminal has a help system for internal commands. Its supports the following commands:

- `clear` = clear the screen
- `help`  = output this message
- `pub`   = switch terminal to public use (everybody can enter commands)
- `priv`  = switch terminal to private use (only the owner can enter commands)
- `send <num> on/off`  = send on/off event to e. g. lamps (for testing purposes)
- `msg <num> <text>`   = send a text message to another Controller (for testing purposes)

For special Terminal functions for the TA4 Lua Controller, see  "Server and Terminal Functions"

### TA4 Sensor Chest

tbd.

## Lua Functions and Environment

### Lua Functions and Limitations

The controller uses a subset of the language Lua, called SaferLua.  It allows the safe and secure execution of Lua scripts, but has the following limitations:

- limited code length
- limited execution time
- limited memory use
- limited possibilities to call functions

SaferLua follows the standard Lua syntax with the following restrictions:

- no `while` or `repeat` loops (to prevent endless loops)
- no table constructor {..}, see "Arrays, Stores, and Sets" for comfortable alternatives
- limited runtime environment

SaferLua directly supports the following standard functions:

- math.floor
- math.abs
- math.max
- math.min
- math.random
- tonumber
- tostring
- unpack
- type
- string.byte
- string.char
- string.find
- string.format
- string.gmatch
- string.gsub
- string.len
- string.lower
- string.match
- string.rep
- string.sub
- string.upper
- string.split (result is an Array)
- string.split2 (result are multiple returns like the Lua function unpack)
- string.trim

For own function definitions, the menu tab 'func' can be used. Here you write your functions like:

```lua
function foo(a, b)
    return a + b
end
```

Each SaferLua program has access to the following system variables:

- ticks - a counter which increments by one each call of `loop()`
- elapsed - the amount of seconds since the last call of `loop()`
- event - a boolean flag (true/false) to signal the execution of `loop()` based on an occurred event

### Arrays, Stores, and Sets

It is not possible to easily control the memory usage of a Lua table at runtime. Therefore, Lua tables can't be used for SaferLua programs. Because of this, there are the following alternatives, which are secure shells over the Lua table type:

#### Arrays

_Arrays_ are lists of elements, which can be addressed by means of an index. An index must be an integer number. The first element in an _array_ has the index value 1. _Arrays_ have the following methods:

- add(value) - add a new element at the end of the array
- set(idx, value) - overwrite an existing array element on index `idx`
- get(idx)  - return the value of the array element on index `idx`
- remove(idx)  - remove the array element on index `idx`
- insert(idx, val)  - insert a new element at index `idx` (the array becomes one element longer)
- size()  - return the number of _array_ elements
- memsize()  - return the needed _array_ memory space
- next()  - `for` loop iterator function, returning `idx,val`
- sort(reverse) - sort the _array_ elements in place. If _reverse_ is `true`, sort in descending order.


Example:

```lua
a = Array(1,2,3,4)     --> {1,2,3,4}
a.add(6)               --> {1,2,3,4,6}
a.set(2, 8)            --> {1,8,3,4,6}
a.get(2)               --> function returns 8
a.insert(5,7)          --> {1,8,3,4,7,6}
a.remove(3)            --> {1,8,4,7,6}
a.insert(1, "hello")   --> {"hello",1,8,4,7,6}
a.size()               --> function returns 6
a.memsize()            --> function returns 10
for idx,val in a.next() do
    ...
end
```

#### Stores

Unlike _arrays_, which are indexed by a range of numbers, _stores_ are indexed by keys, which can be a string or a number. The main operations on a _store_ are storing a value with some key and extracting the value given the key.
The _store_ has the following methods:

- set(key, val) - store/overwrite the value `val` behind the keyword `key`
- get(key) - read the value behind `key`      
- del(key) - delete a value
- size() - return the number of _store_ elements
- memsize() - return the needed _store_ memory space
- next()    - `for` loop iterator function, returning `key,val`
- keys(order) - return an _array_ with the keys. If _order_ is `"up"` or `"down"`, return the keys as sorted _array_, in order of the _store_ values.

Example:

```lua
s = Store("a", 4, "b", 5)  --> {a = 4, b = 5}
s.set("val", 12)           --> {a = 4, b = 5, val = 12}
s.get("val")               --> returns 12
s.set(0, "hello")          --> {a = 4, b = 5, val = 12, [0] = "hello"}
s.del("val")               --> {a = 4, b = 5, [0] = "hello"}
s.size()                   --> function returns 3
s.memsize()                --> function returns 9
for key,val in s.next() do
    ...
end
```

Keys sort example:

```lua
s = Store()            --> {}
s.set("Joe", 800)      --> {Joe=800}
s.set("Susi", 1000)    --> {Joe=800, Susi=1000}
s.set("Tom", 60)       --> {Joe=800, Susi=1000, Tom=60}
s.keys()               --> {Joe, Susi, Tom}
s.keys("down")         --> {Susi, Joe, Tom}
s.keys("up")           --> {Tom, Joe, Susi}
```

#### Sets

A _set_ is an unordered collection with no duplicate elements. The basic use of a _set_ is to test if an element is in the _set_, e.g. if a player name is stored in the _set_.
The _set_ has the following methods:

- add(val)  - add a value to the _set_
- del(val) - delete a value from the _set_
- has(val) - test if value is stored in the _set_
- size()  - return the number of _set_ elements
- memsize() - return the needed _set_ memory space
- next()    - `for` loop iterator function, returning `idx,val`

Example:

```lua
s = Set("Tom", "Lucy")     --> {Tom = true, Lucy = true}
s.add("Susi")              --> {Tom = true, Lucy = true, Susi = true}
s.del("Tom")               --> {Lucy = true, Susi = true}
s.has("Susi")              --> function returns `true`
s.has("Mike")              --> function returns `false`
s.size()                   --> function returns 2
s.memsize()                --> function returns 8
for idx,val in s.next() do
    ...
end
```

All three types of data structures allow nested elements, e.g. you can store a _set_ in a _store_ or an _array_ and so on. But note that the overall size over all data structures can't exceed the predefined limit. This value is configurable for the server admin. The default value is 1000.
The configured limit can be determined via `memsize()`:

```lua
memsize()  --> function returns 1000  (example)
```

### Initialization, Cyclic Task, and Events

The TA4 Lua Controller distinguishes between the initialization phase (just after the controller was started) and the continuous operational phase, in which the normal code is executed. 

#### Initialization

During the initialization phase the function `init()` is executed once. The `init()` function is typically used to initialize variables, clean the display, or reset other blocks:

```lua
-- initialize variables
counter = 1
table = Store()
player_name = "unknown"

# reset blocks
$clear_screen("123")      -- "123" is the number of the display
$send_cmnd("2345", "off")  -- turn off the blocks with the number "2345"
```


#### Cyclic Task

During the continuous operational phase the `loop()` function is cyclically called.
Code witch should be executed cyclically has to be placed here.
The cycle frequency is per default once per second but can be changed via:

```lua
$loopcycle(0)   -- no loop cyle any more
$loopcycle(1)   -- call the loop function every second
$loopcycle(10)  -- call the loop function every 10 seconds
```

The provided number must be an integer value.
The cycle frequency can be changed in the `init()` function, but also in the `loop()` function.

#### Events

To be able to react directly on received commands, the TA4 Lua Controller supports events.
Events are usually turned off, but can be activated with the function `events()`:

```lua
$events(true)    -- enable events
$events(false)   -- disable events
```

If an event occurs (a command was received from another block), the `loop()` is executed (in addition to the normal loop cycle). In this case the system variable 'event' is set:

```lua
if event then
    -- event has occurred
    if $get_input("3456") == "on" then  -- check input from block "3456"
        -- do some action...
    end
end
```

The first occurred event will directly be processed, further events may be delayed. The TA4 Lua Controller allows a maximum of one event every 100 ms.


## Lua Controller Functions

In addition to Lua standard function the Lua Controller provides the following functions:

### Controller local Functions

- `$print(text)` - Output a text string on the 'outp' tab of the controller menu. 
  E.g.: `$print("Hello "..name)`
- `$loopcycle(seconds)` - This function allows to change the call frequency of the controller loop() function, witch is per default one second. For more info, see "Cyclic Task"
- `$events(bool)` - Enable/disable event handling. For more info, see "Events"
- `$get_ms_time()` - Returns the time with millisecond precision
- `get_gametime()` - Returns the time, in seconds, since the world was created
- `$time_as_str()` - Read the time of day (ingame) as text string in 24h format, like "18:45"
- `$time_as_num()` - Read the time of day (ingame) as integer number in 24h format, like 1845
- `$get_input(num)` - Read an input value provided by an external block with the given number _num_. The block has to be configured with the number of the controller to be able to send status messages (on/off commands) to the controller.  _num_ is the number of the remote block, like "1234".

#### Input Example
- A Player Detector with number "456" is configured to send on/off commands to the TA4 Lua Controller  with number "345".
- The TA4 Lua Controller will receive these commands as input value.
- The program on the SaferLua Controller can always read the last input value from the Player Detector with number "456" by means of:

`sts = $get_input("456")`


### Techage Command Functions

With the `$send_cmnd(num, ident, add_data)` function, you can send commands to and retrieve data from another block with the given number _num_.
The possible commands can be classified in two groups: Commands for reading data and commands for triggering an action.
Please note, that this is not a technical distinction, only a logical.

**Reading data**

- _ident_ specifies the data to be read. 
-  _add_data_ is for additional data and normally not needed. 
-  The result is block dependent (see table below)


| ident        | returned data                                                | comment                                                      |
| ------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| "state"      | one of: "running", "stopped", "blocked", "standby", "fault", or "unloaded" | Techage machine state, used by many machines                 |
| "state"      | one of: "red", "amber", "green", "off"                       | Signal Tower state                                           |
| "state"      | one of: "empty", "loaded", "full"                            | State of a chest or Sensor Chest                             |
| "fuel"       | number                                                       | fuel value of a fuel consuming block                         |
| "depth"      | number                                                       | Read the current depth value of a quarry block (1..80)       |
| "load"       | number                                                       | Read the load value in percent  (0..100) of a tank, silo, accu, or battery block, or from the Signs Bot Box. Silo and tank return two values: The percentage value and the absolute value in units.<br /> Example: percent, absolute = $send_cmnd("223", "load") |
| "delivered"  | number                                                       | Read the current delivered power value of a generator block. A power consuming block (accu) provides a negative value |
| "flowrate"   | Total flow rate in liquid units                              | Only for TA4 Pumps                                           |
| "action"     | player-name, action-string                                   | Only for Sensor Chests                                       |
| "stacks"     | Array with up to 4 Stores with the inventory content (see example) | Only for Sensor Chests                                       |
| "count"      | number                                                       | Read the item counter of the TA4 Item Detector block         |
| "count"      | number of items                                              | Read the total amount of TA4 chest items. An optional  number as `add_data` is used to address only one inventory slot (1..8, from left to right). |
| "itemstring" | item string of the given slot                                | Specific command for the TA4 8x2000 Chest to read the item type (technical name) of one chest slot, specified via `add_data` (1..8).<br />Example: s = $send_cmnd("223", "itemstring", 1) |
| "output"     | recipe output string, <br />e.g.: "default:glass"            | Only for the Industrial Furnace. If no recipe is active, the command returns "unknown" |
| "input"      | \<index>                                                     | Read a recipe from the TA4 Recipe Block. `<index>` is the number of the recipe. The block return a list of recipe items. |
| "name"       | \<player name>                                               | Player name of the TA3/TA4 Player Detector or TA4 Button     |
| "time"       | number                                                       | Time in system ticks (norm. 100 ms) when the TA4 Button is clicked |



**Trigger an action**

- _num_ is the number of the remote block, like "1234"
- _cmnd_ is the command
- _data_ is additional data (see table below)

| cmnd                             | data         | comment                                                      |
| -------------------------------- | ------------ | ------------------------------------------------------------ |
| "on", "off"                      | nil          | turn a node on/off (machine, lamp,...)                       |
| "red, "amber", "green", "off"    | nil          | set Signal Tower color                                       |
| "red, "amber", "green", "off" | lamp number (1..4) | Set the signal lamp color. Valid for "TA4 2x Signal Lamp" and "TA4 4x Signal Lamp" |
| "port"                          | string<br />`<color>=on/off` | Enable/disable a Distributor filter slot..<br />Example: `"yellow=on"`<br />colors: red, green, blue, yellow |
| "config" | "\<slot> \<item list>" | Configure a Distributor filter slot, like: "red default:dirt dye:blue" |
| "text"                           | text string  | Text to be used for the Sensor Chest menu                    |
| "reset"                          | nil          | Reset the item counter of the TA4 Item Detector block        |
| "pull"                           | item  string | Start the TA4 pusher to pull/push items.<br /> Example: `default:dirt 8` |
| "config"                         | item  string | Configure the TA4 pusher.<br />Example: `wool:blue`          |
| "exchange" | inventory slot number | TA3 Door Controller II (techage:ta3_doorcontroller2)<br />Exchange a block<br />*idx* is the inventory slot number (1..n) of/for the block to be exchanged |
| "set" | inventory slot number | TA3 Door Controller II (techage:ta3_doorcontroller2)<br />Set/add a block<br />*idx* is the inventory slot number (1..n) with the block to be set |
| "dig" | inventory slot number | TA3 Door Controller II (techage:ta3_doorcontroller2)<br />Dig/remove a block<br />*idx* is the empty inventory slot number (1..n) for the block |
| "a2b" | nil | TA4 Move Controller command to move the block(s) from position A to B |
| "b2a" | nil | TA4 Move Controller command to move the block(s) from position B to A |
| "move" | nil | TA4 Move Controller command to move the block(s) to the opposite position |
| "move2" | x,y,z | TA4 Move Controller command to move the block(s) by the given<br /> x/y/z-distance. Valid ranges for x, y, and z are -100 to 100. |
| "reset" | nil | Reset TA4 Move Controller (move block(s) to start position) |
| "left" | nil | TA4 Turn Controller command to turn the block(s) to the left |
| "right" | nil | TA4 Turn Controller command to turn the block(s) to the right |
| "uturn" | nil | TA4 Turn Controller command to turn the block(s) 180 degrees |
| "recipe" | `<item_name>,<item_name>,...` | Set the TA4 Autocrafter recipe. <br />Example for the torch recipe: `default:coal_lump,,,default:stick` <br />Hint: Empty fields may only be left out at the end of the item list! |
| "recipe" | `<number>.<index>` | Set the TA4 Autocrafter recipe with a recipe from a TA4 Recipe Block.<br />`<number>` is the TA4 Recipe Block number<br />`<index>` is the number of the recipe in the TA4 Recipe Block |
| "goto" | `<slot>` | Start command for the TA4 Sequencer. `<slot>` is the time slot like `[1]` where the execution starts. |
| "stop" | nil | Stop command for the TA4 Sequencer. |
| "gain" | volume | Set volume of the sound block (`volume` is a value between 0 and 1.0) |
| "sound" | index | Select sound sample of the sound block |

### Server and Terminal Functions

The Server is used to store data permanently/non-volatile. It can also be used to share data between several Controllers.
- `$server_write(num, key, value)` - Store a value on the server under the key _key_. _key_ must be a string. _value_ can be either a number, string, boolean, nil or data structure. 
  **This function does not allow nested data structures**. 
  _num_ is the number of the Server. 
  Example: `$server_write("0123", "state", state)`
- `$server_read(num, key)` - Read a value from the server. _key_ must be a string. _num_ is the number of the Server, like "1234".

The Terminal can send text strings as events to the Controller.
In contrast the Controller can send text strings to the terminal.

- `$get_term()` - Read a text command received from the Terminal
- `$put_term(num, text)` - Send a text string to the Terminal.  _num_ is the number of the Terminal.

### Communication between Lua Controllers

Messages are used to transport data between Controllers. Messages can contain arbitrary data. Incoming messages are stored in order (up to 10) and can be read one after the other.

* `$get_msg([raw])` - Read a received message. The function returns the sender number and the message. (see example "Emails"). If the _raw_ parameter is not set or false, the message is guaranteed to be a string.
* `$send_msg(num, msg)` - Send a message to another Controller.  _num_ is the destination number. (see example "Emails")

### Further Functions

* `$chat(text)` - Send yourself a chat message. _text_ is a text string.
* `$door(pos, text)` - Open/Close a door at position "pos".    
  Example: `$door("123,7,-1200", "close")`.    
  Hint: Use the Techage Info Tool to determine the door position.
* `$item_description("default:apple")`
  Get the description (item name) for a specified itemstring, e. g. determined via the TA4 8x2000 Chest command `itemstring`:
  `str = $send_cmnd("223", "itemstring", 1)`
  `descr = $item_description(str)`

* `$display(num, row, text)` Send a text string to the display with number _num_. _row_ is the display row, a value from 1 to 5, or 0 to add the text string at the bottom (scroll screen mode).  _text_ is the string to be displayed.  If the first char of the string is a blank, the text will be horizontally centered.
* `$clear_screen(num)` Clear the screen of the display with number _num_.
* `$position(num)` Returns the position as string "'(x,y,z)" of the device with the given _num_.

## Example Scripts

### Simple Counter

Very simple example with output on the Controller menu.

init() code:

```lua
a = 1
```

loop() code:

```lua
a = a + 1
$print("a = "..a)
```



### Hello World

"Hello world" example with output on the Display.

init() code:

```lua
a = Array("Hello", "world", "of", "Minetest")

$clear_screen("0669")

for i,text in a.next() do
    $display("0669", i, text)
end
```



### For Loop with range(from, to)

Second "Hello world" example with output on the Display,
implemented by means of a for/range loop.

init() code:

```lua
a = Array("Hello", "world", "of", "Minetest")

$clear_screen("0669")

for i in range(1, 4) do
	text = a.get(i)
	$display("0669", i, text)
end
```



### Monitoring Chest & Furnace

More realistic example to read Pusher states and output them on a display:

init() code:

```lua
DISPLAY = "1234"  -- adapt this to your display number
min = 0
```

loop() code:

```lua
-- call code every 60 sec
if ticks % 60 == 0 then
    -- output time in minutes
    min = min + 1
    $display(DISPLAY, 1, min.." min")

    -- Cactus chest overrun
    sts = $send_cmnd("1034", "state") -- read pusher status
    if sts == "blocked" then $display(DISPLAY, 2, "Cactus full") end

    -- Tree chest overrun
    sts = $send_cmnd("1065", "state")  -- read pusher status
    if sts == "blocked" then $display(DISPLAY, 3, "Tree full") end

    -- Furnace fuel empty
    sts = $send_cmnd("1544", "state")  -- read pusher status
    if sts == "standby" then $display(DISPLAY, 4, "Furnace fuel") end
end
```




### Simple Calculator

A simple calculator (adds entered numbers) by means of a Lua Controller and a Terminal.

init() code:

```lua
$events(true)
$loopcycle(0)

TERM = "360" -- terminal number, to be adapted!
sum = 0
$put_term(TERM, "sum = "..sum)
```

loop() code:

```lua
s = $get_term() -- read text from terminal
if s then
    val = tonumber(s) or 0  -- convert to number
    sum = sum + val
    text = string.format("+%d = %d", val, sum) -- format output string
    $put_term(TERM, text)  -- output to terminal
end
```



### Welcome Display

In addition to the controller, you also need a player detector and a display.
When the Player Detector detects a player the player name is shown on the display:

init() code:

```lua
$events(true)
$loopcycle(0)

SENSOR = "365"   -- player detector number, to be adapted!
DISPLAY = "367"  -- display number, to be adapted!

$clear_screen(DISPLAY)
```

loop() code:

```lua
if event then
    name = $send_cmnd(SENSOR, "name")
    if name == "" then -- no player arround
        $clear_screen(DISPLAY)
    else
        $display(DISPLAY, 2, " Welcome")
        $display(DISPLAY, 3, " "..name)
    end
end
```



### Sensor Chest

The following example shows the functions/commands to be used with the Sensor Chest:

init() code:

```lua
$events(true)
$loopcycle(0)

SENSOR = "372"   -- sensor chest number, to be adapted!

$send_cmnd(SENSOR, "text", "press both buttons and\nput something into the chest")
```

loop() code:

```lua
if event and $get_input(SENSOR) == "on" then
    -- read inventory state
    state = $send_cmnd(SENSOR, "state")
    $print("state: "..state)
    -- read player name and action
    name, action = $send_cmnd(SENSOR, "action")
    $print("action"..": "..name.." "..action)
    -- read inventory content
    stacks = $send_cmnd(SENSOR, "stacks")
    for i,stack in stacks.next() do
        $print("stack: "..stack.get("name").."  "..stack.get("count"))
    end
    $print("")
end
```



### Emails

For an email system you need a TA4 Lua Server and a TA4 Lua Controller with Terminal per player.
The TA4 Lua Server serves as database for player name/block number resolution.

* Each Player needs its own Terminal and Controller. The Terminal has to be connected with the Controller
* Each Controller runs the same Lua Script, only the numbers and the owner names are different
* To send a message, enter the receiver name and the text message like `Tom: hello` into the Terminal
* The Lua script will determine the destination number and send the message to the destination Controller
* All players who should be able to take part in the email system have to be entered into the Server form

init() code:

```lua
$loopcycle(0)
$events(true)

-- Start: update to your conditions
TERM = "360"
CONTROLLER = "359"
NAME = "Tom"
SERVER = "363"
-- End: update to your conditions

$print($server_write(SERVER, NAME, CONTROLLER))
$print($server_write(SERVER, CONTROLLER, NAME))
```

loop() code:

```lua
-- read from Terminal and send the message
s = $get_term()
if s then
    name,text = string.split2(s, ":", false, 1)
    num = $server_read(SERVER, name)
    if num then
        $send_msg(num, text)
        $put_term(TERM, "message sent")
    end
end
    
-- read message and output to terminal
num,text = $get_msg()
if num then
    name = $server_read(SERVER, num)
    if name then
        $put_term(TERM, name..": "..text)
    end
end
```
