# TA4 ICTA Controller

The ICTA controller (ICTA stands for "If Condition Then Action") is used to monitor and control machines. The controller can be used to read in data from machines and other blocks and, depending on this, switch other machines and blocks on / off.

### 8 Controller Rules

The controller works on the basis of rules, whereby up to 8 rules can be created per controller.

Examples of rules are:

- If a distributor is blocked, the pusher in front of it should be switched off
- If a machine displays the fault state, a lamp should be switched on to indicate the fault
- If a player is close to a player detector, his name should be shown on a display
- If a Minecart is recognized by the cart sensor, the cart should be loaded (pusher switched on)

All rules should only be executed as often as necessary. This has two advantages:

- the battery of the controller lasts longer (each controller needs a battery)
- the load for the server is lower (therefore fewer lags)

### Cyclic execution of rules

These rules are checked cyclically by the controller. If a condition is met, the action is carried out. As long as the condition is not met, nothing happens. Even if the condition was already met when the rule was last edited and the action was carried out, nothing happens. The condition must first become invalid and then apply again so that the action is executed again.

How often a rule is checked by the controller can be configured individually for each rule. A cycle time in seconds (`Cycle/s`) must be specified for each rule (1..1000).

### Event-driven execution of rules

As an alternative to the cyclically checked rules, there is also the event-controlled execution of rules.

Events are commands that are sent from other blocks to the controller. Examples are sensors and switches. These send `on` / `off` commands. For example, if the switch is switched on, it sends an `on` command, if it is switched off, it sends an `off` command to the block with the number that was configured for the switch.

For rules that are to be executed in an event-controlled manner, cycle time 0 must be specified.

### Delay Time

You have to set a delay time (`after/s`) for each action. If the action is to be carried out immediately, 0 must be entered.

#### Terms / Conditions

One of the following conditions can be configured for each rule. However, only one condition can be configured per rule.

- `initial` - This condition is always met after the controller is switched on and is used, for example, to switch off a lamp so that it can then be switched on again if an error occurs.

- `true` - This condition is always fulfilled and is used, for example, to make a lamp flash. Two rules are required for this. For example, if both rules have a cycle time of 2 s, but the first rule has a delay time of 0 s and the second rule has a delay time of 1 s, then a lamp can be cyclically switched on and off again.

- `condition` - Depending on another rule, an action can be started here. To do this, the number of the other rule (1..8) must be specified. This means that 2 actions can be carried out with one `condition`. With the additional configurable condition, `was not true` was used to switch off a lamp, for example, when the condition is no longer met.

- `inputs` - This enables the received value `on` / `off` of a command (event) to be evaluated. Please note here: For rules that are to be executed event-controlled, cycle time 0 must be specified.

- `read block state` - This allows the status of a machine to be queried. The machine number must be entered. Possible machine states are:
  
    - `running` -> machine is working
    - `stopped` -> machine is switched off
    - `standby` -> machine has nothing to do, for example because the inventory is empty
    - `blocked` -> machine cannot do anything, e.g. the initial inventory is full
    - `fault` -> machine has a fault. The machine menu may provide further information
    - `unloaded` -> Machines at a greater distance may have been unloaded from the server without a forceload block. Then these are not active.
    
    If a configured condition is fulfilled, e.g. `block number 456 is stopped`, the action is carried out.
    
    The easiest way to determine which machines provide which status information is with the wrench / Techage Info tool directly on the machine.

- `read amount of fuel` - This can be used to read out how much fuel a machine still has (typically 0-99 units) and to compare it with a value of 'larger' or 'smaller'. If the configured condition is met, the action is carried out.
    `read power / liquid load` - This means that the charge of a battery or the heat storage device can be queried in percent (values ​​from 0..100) and checked for 'larger' / 'smaller' with the configured condition. If the condition is met, the action is carried out.

- `read delivered power` - This can be used to query the amount of electricity that a generator (in ku) is delivering. The value can be checked with the configured condition for 'larger' / 'smaller'. If the condition is met, the action is carried out. Since batteries not only emit electricity but also absorb, this value is negative when the battery is charged.

- `read chest state` - This enables the status of a TA3/TA4 chest to be queried and evaluated. Chests provide the states:

    - `empty` - the chest is empty
    - `loaded` - the chest partially filled
    - `full` - All stacks in the chest are at least partially occupied

    If the condition is met, the action is carried out.

- `read Signal Tower state` - This allows the color of a Signal Tower to be queried and checked. Signal towers deliver the values ​​`off`, `green`, `amber`, `red`. If the condition is met, the action is carried out.

- `read Player Detector` - This can be used to query a player detector. The detector provides the player's name near the detector. If not only a specific but every player's name is to be shown on a display, enter '*' in 'player name (s).
    You can also enter multiple names separated by spaces. If the action is to be carried out when there is no player nearby, enter `-`.

### Actions

For all actions that control a block (such as a lamp), the number of the block must be specified in the action. Only one action can be configured per rule.

- `print to output window` - e.g. a text can be output in the controller menu (under 'outp') for test purposes. This is especially helpful when troubleshooting.
- `send Signal Tower command` - This allows the color of the Signal Tower to be set. Possible values ​​are: `off`,` green`, `amber`,` red`.
- `turn block off / on` - This enables a block or machine to be switched on or off again.
- `Display: overwrite one line` - This allows text to be output on the display. The line number on the display (1..5) must be specified.
  If the player name of the player detector is to be output from the condition, then 'text' is on
   Enter the `*` character.
- `Display: Clear screen` - clear the screen
- `send chat message` - This allows you to send yourself a chat message.
- `open / close door` - This allows the standard doors to be opened and closed. Since the doors have no numbers, the coordinates of the door must be entered. The coordination of a door can be easily determined with the wrench / Techage Info tool.
- `Turn distributor filter on / off` - This enables the filter / outputs of a distributor to be switched on and off. The corresponding output must be specified via the color.

### Miscellaneous

The controller has its own help and information on all commands via the controller menu.

Machine data is read in and blocks and machines are controlled using commands. To understand how commands work, the chapter TA3 -> Logic / switching blocks in the in-game help (construction plan) is helpful.





