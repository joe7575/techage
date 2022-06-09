# Techage/Beduino  I/O Module

I/O modules support the following functions:

###  event

Every signal that is sent to an I/O module triggers an event on the controller.
Events can be queried using the `event()` function.
If the function returns the value `1`, one or more signals have been received.
Calling `event()` resets the event flag.

```c
event()
```

### read

Read a value from a remote techage block.

- *port* is the I/O module port number
- *cmnd* is the command, like `IO_STATE` (see example code  "ta_cmnd.c")

```c
read(port, cmnd)
```

### send_cmnd

Send a command to a techage block (see [commands](https://github.com/joe7575/beduino/blob/main/BEPs/bep-005_ta_cmnd.md)).

- *port* is the I/O module port number
- *topic* is a number from the list of [Beduino commands](https://github.com/joe7575/beduino/blob/main/BEPs/bep-005_ta_cmnd.md)
- *payload* is an array or a string with additional information, depending on the command. If no additional commands are required, "" can be used.

```c
send_cmnd(port, topic, payload)
```

### request_data

Request information from a techage block (see [commands](https://github.com/joe7575/beduino/blob/main/BEPs/bep-005_ta_cmnd.md)).

- *port* is the I/O module port number
- *topic* is a number from the list of [Beduino commands](https://github.com/joe7575/beduino/blob/main/BEPs/bep-005_ta_cmnd.md)
- *payload* is an array or a string with additional information, depending on the command. If no additional commands are required, "" can be used.
- *resp* is an array for the response data. The array must be defined large enough to hold the response data.

```c
request_data(port, topic, payload, resp)
```

## Functions for TA4 Display and TA4 Display XL

###  clear_screen

Clear the display.

- *port* is the I/O module port number

```c
clear_screen(port)
```

### append_line

Add a new line to the display.
- *port* is the I/O module port number
- *text* is the text for one line

```c
append_line(port, text)
```


### write_line

Overwrite a text line with the given string.

- *port* is the I/O module port number
- *row* ist the display line/row (1-5)
- *text* is the text for one line

```c
write_line(port, row, text)
```
