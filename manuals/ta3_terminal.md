# TA3 Terminal BASIC Mode

![Basic Terminal](https://github.com/joe7575/techage/blob/master/textures/techage_basic_mode.png)

The TA3 Terminal can be used in BASIC mode to interact with Techage devices for
automation and control.

BASIC (Beginner's All-purpose Symbolic Instruction Code) is a high-level programming
language that was designed to be easy to use. It is a good choice for beginners and
for simple automation tasks.

The BASIC interpreter in the TA3 Terminal is based on the
[NanoBASIC](https://github.com/joe7575/techage/tree/master/manuals/nanobasic.md) language.
NanoBASIC is similar to the Microsoft (TM) BASIC interpreter, which was available on
the Commodore 64 and other computers of the 1980s.

Information to the Microsoft (TM) BASIC interpreter can be found
[here](https://vtda.org/docs/computing/Microsoft/MS-BASIC/8101-530-11-00F14RM_MSBasic8086XenixReference_1982.pdf).

NanoBasic is available on the Techage TA3 Terminal and allows you to monitor and
control the Techage machines and devices. It works similar to the Lua Controller
of the Techage mod, but fits more into the era of TA3 machines.

NanoBasic is normally not visible on the Techage Terminal. But it can be activated
by means of the Techage Info Tool (open-ended wrench).

The NanoBasic manual is available [here](https://github.com/joe7575/techage/tree/master/manuals/nanobasic.md).

## NanoBASIC Examples

NanoBASIC does not distinguish between upper and lower case letters. The following
examples are written in lower case letters.

### Hello World

The following example prints "Hello World!" to the terminal.

```basic
10 for i=1 to 10
20 print "Hello World!"
30 next i
```

### Input Demo

```basic
10 name$ = input$("What is your name")
20 print "Hello" name$ "nice to meet you!"
30 age = input("What is your age")
40 print "Next year you will be" age+1
50 end
```

### Blinking Light

The following example blinks a light on and off every second.
You need a Techage Color Lamp (techage:color_lamp_off) for this example.
You have to adapt the node number of the lamp to your setup.

```basic
10 for i=1 to 10
20 res = cmd(1234, 1, 1)
30 sleep(1)
40 res = cmd(1234, 1, 0)
50 sleep(1)
60 next i
```

### Read Minecart States

The following example reads the states of the minecarts 1 to 4 from the Cart Terminal
and outputs them to a techage display.
This example requires a Minecart Cart Terminal (minecart:terminal) and a Techage
TA4 Display (techage:ta4_display) for the output.

```basic
10 const display = 1234  ' node number
20 const cartterm = 1235 ' node number
30 const cmd_state = 129 
40 const cmd_dist = 130
50 :
60 dputs(display, 1, "    Carts")
70 :
80 for idx = 1 to 4
90 : gosub 140
100 next
110 sleep(5)
120 goto 60
130 :
140 state = cmd(cartterm, cmd_state, idx)
150 if state == 1 then
160 : dputs(display, idx+1, "#" + str$(idx) + " stopped") 
170 else
180 : dist = cmd(cartterm, cmd_dist, idx)
190 : s$ = "#" + str$(idx) + " " + str$(dist) + "m"
200 : dputs(display, idx+1, s$)
210 endif
220 return
230 :
65000 print "error =" param$() "in" param()
65010 return
```
