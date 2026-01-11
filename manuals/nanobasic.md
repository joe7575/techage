# NanoBasic<!-- omit from toc -->

## Reference Manual v1.0.4<!-- omit from toc -->

## Table of Contents<!-- omit from toc -->

- [Introduction](#introduction)
	- [Line Numbers](#line-numbers)
	- [Character Set](#character-set)
	- [Constants](#constants)
		- [NIL](#nil)
	- [Variables](#variables)
	- [Array Variables](#array-variables)
	- [Expressions and Operators](#expressions-and-operators)
		- [Functional Operators](#functional-operators)
		- [String Operations](#string-operations)
- [Commands and Statements](#commands-and-statements)
	- [CONST](#const)
	- [DATA](#data)
	- [DIM](#dim)
	- [END](#end)
	- [ERASE](#erase)
	- [FOR...NEXT](#fornext)
	- [FREE](#free)
	- [GOSUB...RETURN](#gosubreturn)
	- [GOTO](#goto)
	- [IF...THEN](#ifthen)
	- [LET](#let)
	- [ON...GOSUB and ON...GOTO](#ongosub-and-ongoto)
	- [PRINT](#print)
	- [READ](#read)
	- [REM](#rem)
	- [RESTORE](#restore)
	- [TRON and TROFF](#tron-and-troff)
	- [WHILE...LOOP](#whileloop)
- [Internal Functions](#internal-functions)
	- [CLRLINE](#clrline)
	- [CLRSCR](#clrscr)
	- [GETCURX](#getcurx)
	- [GETCURY](#getcury)
	- [HEX$](#hex)
	- [INPUT](#input)
	- [INPUT$](#input-1)
	- [INSTR](#instr)
	- [LEFT$](#left)
	- [LEN](#len)
	- [MID$](#mid)
	- [PARAM](#param)
	- [PARAM$](#param-1)
	- [RESET](#reset)
	- [RIGHT$](#right)
	- [RND](#rnd)
	- [SERCUR](#sercur)
	- [SLEEP](#sleep)
	- [SPC](#spc)
	- [STR$](#str)
	- [STRING$](#string)
	- [TIME](#time)
	- [DAYTIME](#daytime)
	- [DAYTIME$](#daytime-1)
	- [VAL](#val)
- [Techage Functions](#techage-functions)
	- [Error Handling](#error-handling)
	- [Mapblock Loading](#mapblock-loading)
	- [Hold / Release of techage commands](#hold--release-of-techage-commands)
	- [HOLD](#hold)
	- [RELEASE](#release)
	- [CMD](#cmd)
	- [CMD$](#cmd-1)
	- [CHAT](#chat)
	- [DCLR](#dclr)
	- [DPUTS](#dputs)
	- [DOOR](#door)
	- [INAME$](#iname)
- [TA3 Terminal Operating Instructions](#ta3-terminal-operating-instructions)
- [Debugging of NanoBasic Programs](#debugging-of-nanobasic-programs)
- [Appendix A: Techage Commands](#appendix-a-techage-commands)
	- [CMD Commands without Response](#cmd-commands-without-response)
	- [CMD Commands with Response as Numeric Value](#cmd-commands-with-response-as-numeric-value)
	- [CMD$ Commands with Response as String Value](#cmd-commands-with-response-as-string-value)

## Introduction

NanoBasic is a simple BASIC interpreter that runs on the NanoVM. It is based on the
Microsoft (TM) BASIC interpreter, which is available on the Commodore 64 and other
computers of the 1980s.

Information to the Microsoft (TM) BASIC interpreter can be found
[here](https://vtda.org/docs/computing/Microsoft/MS-BASIC/8101-530-11-00F14RM_MSBasic8086XenixReference_1982.pdf).

NanoBasic is available on the Techage TA3 Terminal as part of the techage mod for
Minetest/Luanti. It allows you to monitor and control the Techage machines and devices.
It works similar to the Lua Controller of the Techage mod, but fits more into
the era of TA3 machines.

NanoBasic is normally not visible on the Techage Terminal. But it can be activated
by means of the Techage Info Tool (open-ended wrench).

### Line Numbers

Every BASIC program line begins with a line number. Line numbers must be ordered
in ascending sequence. Line numbers are mainly used as references for branches
(jump targets) and as line references for compiler error messages.

The terminal has a convenient text editor that allows you to edit and copy entire
BASIC programs. Lines do not have to be entered or edited individually via a command
line.

Line numbers must be in the range 1 to 65535.

### Character Set

NanoBasic supports the ASCII character set, which includes the upper and lower case
letters of the alphabet, the digits 0 through 9, and special characters such as
punctuation marks and mathematical symbols. NanoBasic distinguishes not between
upper and lower case letters. Variable names and BASIC keywords are not case-sensitive.

### Constants

NanoBasic supports integer and string constants. Integer constants are numbers
without a decimal point. String constants are enclosed in double quotes.

Examples:

```text
"Hello"
1234
```

Numeric constants are positive numbers in the range -2,147,483,648 to 2,147,483,647
(32 bit signed integer).

NanoBasic does not support floating point numbers!

#### NIL

NIL is a special constant that represents the absence of a value. It is used to
pass a null value to a function where an array argument is expected.

### Variables

Variables are names used to represent values used in the program. The value of a
variable may be assigned by the programmer, or it may be assigned by the
calculations in the program. Before a variable is assigned a value, its value is
assumed to be zero.

Variable names must begin with a letter and may contain letters and digits. Variable
names can have any length, but only the first 9 characters are significant.
If 2 variables differ only after the 9th digit, they are considered equal.

A variable name may not be the same as a reserved word. Reserved words include
all commands, statements, function names, and operator names.

Variables may represent either a numeric value or a string. String variable names
are written with a dollar sign ($) as the last character.
For example:

```text
A$ = "SALES REPORT"
```

The dollar sign is a variable type declaration character; that
is, it "declares" that the variable will represent a string.

### Array Variables

An array is a group or table of values referenced by the same variable name.
Each element in an array is referenced by an array variable that is subscripted
with an integer or an integer expression. An array variable name has as many
subscripts as there are dimensions in the array.
For example:

```text
DIM A(10)
```

This statement creates an array named A with 11 elements, A(0) through A(10).
The maximum number of elements in limited by the available heap memory.
Heaps are shared between arrays and strings. The heap size is 8KB.

NanoBasic supports only one-dimensional arrays.

### Expressions and Operators

An expression is a combination of variables, constants, and operators that
the interpreter evaluates to produce a value. Expressions can be used in
statements that require a value, such as assignment statements, PRINT statements,
and IF statements.

Operators perform mathematical or logical values. The Microsoft BASIC operators may
be divided into four categories:

1. Arithmetic
2. Relational
3. Logical
4. Functional

The following table lists the operators in each category:

| Category    | Operator | Description |
|-------------|----------|-------------|
| Arithmetic  | +        | Addition    |
|             | -        | Subtraction |
|             | *        | Multiplication |
|             | /        | Division    |
|             | MOD      | Modulus     |
|             | &        | Binary AND  |
|             | \|       | Binary OR   |
|             | ^        | Binary XOR  |
| Relational  | =        | Equal       |
|             | <>       | Not equal   |
|             | <        | Less than   |
|             | <=       | Less than or equal |
|             | >        | Greater than |
|             | >=       | Greater than or equal |
| Logical     | AND      | Logical AND |
|             | OR       | Logical OR  |
|             | NOT      | Logical NOT |
| Functional  | RND      | Random number |
|             | LEN      | Length of string |
|             | MID      | Substring   |
|             | LEFT$    | Left part of string |
|             | RIGHT$   | Right part of string |
|             | STR$     | Convert to string |
|             | VAL      | Convert to number |
|             | INSTR    | Find substring |
|             | CHR$     | Convert to character |
|             | ASC      | Convert to ASCII code |
|             | SPC      | Print spaces |

The precedence of operators is as follows:

1. Multiplication (*), Division (/), Modulus (MOD)
2. Addition (+), Subtraction (-)
3. Bitwise AND (&)
4. Bitwise OR (|)
5. Bitwise XOR (^)
6. Relational operators (=, <>, <, <=, >, >=)
7. Logical NOT operator
8. Logical AND operator
9. Logical OR operator

If, during the evaluation of an expression, division by zero is encountered,
the "Division by zero" error message is displayed and the program is terminated.

Relational operators are used to compare two values. The result of the comparison
is either "true" (1) or "false" (0). This result may then be used to make a decision
regarding program flow. (See "IF" statements)

Examples:

```text
IF RND(100)<1O GOTO 1000
IF I MOD J<>O THEN K=K+1
```

#### Functional Operators

The functional operators are used to manipulate strings and numbers. They are
used in expressions to convert between numbers and strings, to extract substrings,
to find substrings, and to convert between ASCII codes and characters.

NanoBasic has "intrinsic" functions that reside in the interpreter.
In addition, NanoBasic allows to define "external" functions that are written in Lua
to extend the functionality of the interpreter.

All these functions are called by name and are followed by a list of arguments
enclosed in parentheses. The arguments are separated by commas.

NanoBasic has a strong type system. The type of the arguments and the return value
of a function is determined by the function name. If, for example, the function
name is "STR$", the argument is converted to a string and the return value is a string.

#### String Operations

Strings may be concatenated by using +.

Example:

```text
10 A$="FILE" : B$="NAME"
20 PRINT A$+B$
30 PRINT "NEW "+A$+B$

>> FILENAME
>> NEW FILENAME
```

Strings may be compared using the same relational operators that are used with numbers:

```text
    =   <>   <   >   <=   >=
```

String comparisons are made by taking one character at a time from each string and
comparing the ASCII codes. If all the ASCII codes are the same, the strings are equal.
If the ASCII codes differ, the lower code number precedes the higher. If during string
comparison the end of one string is reached, the shorter string is said to be smaller.
Leading and trailing blanks are significant.

## Commands and Statements

This section describes the commands and statements that are available in NanoBasic in
alphabetical order.

### CONST

The CONST statement is used to define constants that are used in the program.
The CONST statement is nonexecutable and can be placed anywhere in the program.

Example:

```text
10 CONST MAX=100
20 DIM A(MAX)
```

### DATA

The DATA statement is used to define data that is used by the READ statement.

DATA statements are nonexecutable and must be placed at the end of the program.
A DATA statement may contain as many constants as will fit on a line (separated by commas).
Up to 200 DATA statements may be used in a program.

This list of constants may contain numeric or string constants. String constants
must be enclosed in double quotes.

READ statements access DATA statements in the order in which they are encountered.
The variable type (numeric or string) in the READ statement must correspond to the
corresponding constant in the DATA statement.

### DIM

The DIM statement is used to dimension arrays. The DIM statement must be used before
the array is referenced in the program.

For instance, DIM A(5) defines a single-dimension array A. In standard BASIC, the
lower bound of any array was normally 1, so in this case, the variable A has five "slots",
numbered 1 though 5. In NanoBasic, the lower bound is always 0, so the variable A has
six "slots", numbered 0 through 5.

If a subscript is used that is greater than the maximum specified, a "Array index out of bounds"
error occurs. The minimum value for a subscript is always 0.

Example:

```text
10 DIM A(20)
20 FOR I=O TO 20
30 READ A(I)
40 NEXT I

DATA 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20
```

### END

The END statement is used to terminate the program. END statements may be placed
anywhere in the program to terminate execution. Unlike the BREAK statement, END
does not cause a "Break in line nnnnn" message to be printed. An END statement
at the end of a program is optional.

### ERASE

The ERASE statement is used to delete an array.

Arrays may be redimensioned after they are ERASEd, or the previously allocated
array space in memory may be used for other purposes.

Example:

```text
10 DIM A(20)
20 ERASE A
30 DIM A(10)
40 END
```

### FOR...NEXT

Format:

```text
FOR variable = start TO end [STEP increment]
    statements
NEXT variable
```

`start`, `end`, and `increment` are numeric expressions. The `STEP` clause is optional.

The FOR statement is used to set up a loop that will execute a specified number of times.
The variable is assigned the value of `start` and is incremented by `increment` each time
through the loop. The loop continues until the variable is greater than `end`.

If the `STEP` clause is omitted, the increment is assumed to be 1.

Example:

```text
10 FOR I=1 TO 10
20 PRINT I
30 NEXT I
```

The program lines following the FOR statement are executed until the NEXT statement
is encountered. Then the counter is adjusted by the amount specified by STEP.
A check is performed to see if the value of the counter is now greater than the
final value (y). If it is not greater, NanoBasic branches back to the statement
after the FOR statement and the process is repeated. If it is greater, execution
continues with the statement following the NEXT statement.

### FREE

The FREE statement outputs the number of free bytes in the code, variable, and heap
areas of the NanoBasic interpreter to the terminal.

Example:

```
FREE

>> 16345/1020/8192 bytes free (code/data/heap)
```

### GOSUB...RETURN

Format:

```text
GOSUB line
.
.
.
RETURN
```

The GOSUB statement is used to branch to a subroutine. The RETURN statement is used
to return to the statement following the GOSUB statement.

A subroutine may be called any number of times in a program. A subroutine also may
be called from within another subroutine. Up to 8 levels of subroutine nesting are
allowed. If the limit is exceeded, an "Call stack overflow" error occurs.

Example:

```text
10 GOSUB 100
20 PRINT "END"
30 END
100 PRINT "SUBROUTINE"
110 RETURN
```

### GOTO

The GOTO statement is used to branch to a specified line number.
If the line number is not found, a "Line number not found" error occurs.

Example:

```text
10 GOTO 100
20 PRINT "END"
30 END
100 PRINT "GOTO"
110 END
```

### IF...THEN

Format:

```text
IF expression THEN statement [ELSE statement]
```

Or:

```text
IF expression GOT0 line [ELSE statement]
```

Or:

```text
IF expression THEN
    statement
    .
    .
[ELSE
    statement
    .
    .]
ENDIF
```

Or:

```text
IF expression THEN
    statement
    .
    .
[ELSEIF expression THEN
    statement
    .
    .]
[ELSE
    statement
    .
    .]
ENDIF
```

The IF and the ELSEIF statements are used to make a decision based on the value of an expression.
If the expression is true (nonzero), the THEN or GOTO clause is executed.
If the expression is false (zero), the statement following the ELSE keyword is executed.

The ELSEIF and ELSE clauses are optional.

Example:

```text
10 IF A=0 THEN
20   PRINT "A=0"
30 ELSE
40   PRINT "A<>0"
50 ENDIF
60 END
```

### LET

The LET statement is used to assign a value to a variable.
Notice the word LET is optional. The equal sign is sufficient for assigning
an expression to a variable name.

Example:

```text
10 LET A=10
20 LET B$="STRING"
20 PRINT A,B$
30 END
```

Or:

```text
10 A=10
20 B$="STRING"
20 PRINT A,B$
30 END
```

### ON...GOSUB and ON...GOTO

Format:

```text
ON expression GOSUB line1, line2, line3, ...

ON expression GOTO line1, line2, line3, ...
```

The ON statement is used to branch to a specified line number based on the value
of the expression. The expression must be an integer value.

For example, if the value is three, the program branches to the line number given
as the third item in the list (line3).

In the ON...GOSUB statement, each line number in the list must be' the first line
number of a subroutine.

If the value of expression is zero or greater than the number of items in the list
NanoBasic continues with the next executable statement.

Example:

```text
10 ON A GOSUB 100,200,300
20 PRINT "END"
30 END
100 PRINT "GOSUB 100"
110 RETURN
200 PRINT "GOSUB 200"
210 RETURN
300 PRINT "GOSUB 300"
310 RETURN
```

### PRINT

The PRINT statement is used to display output on the screen.

Format:

```text
PRINT [<list of expressions>]
```

If \<list of expressions> is omitted, a blank line is printed. If \<list of expressions>
is included, the values of the expressions are printed at the terminal. The expressions
in the list may be numeric and/or string expressions.
(Strings must be enclosed in quotation marks.)

The position of each printed item is determined by the punctuation used to separate
the items in the list. NanoBasic divides the line into print zones of 10 spaces each
(tabs). In the list of expressions, a comma causes the next value to be
printed at the beginning of the next tab.

A semicolon causes the next value to be printed immediately after the last value.
Typing one or more spaces between expressions causes the next value to be printed
with one space between it and the last value.

If a comma or a semicolon terminates the list of expressions, the next PRINT
statement begins printing on the same line, spacing accordingly.

If the list of expressions terminates without a comma or a semicolon, a carriage
return is printed at the end of the line.

Printed numbers are always followed by a space. Strings are printed without a space.

If the printed line is longer than the terminal width, the line is wrapped to the
next line.

Example:

```text
10 PRINT "HELLO",
20 PRINT "WORLD"
30 END

>> HELLO     WORLD
```

### READ

The READ statement is used to read data from a DATA statement and assign them to
variables.

Format:

```text
READ variable1, variable2, ...
```

A READ statement must always be used in conjunction with a DATA statement. READ
statements assign variables to DATA statement values on a one-to-one basis. READ
statement variables may be numeric or string, and the values read must agree with
the variable types specified. If they do not agree, a "Data type mismatch" will
result.

A single READ statement may access one or more DATA statements (they will be
accessed in order), or several READ statements may access the same DATA statement.
If the number of variables the list of variables exceeds the number of elements
in the DATA statement(s), an "Out of data" error message is printed. If the
number of variables specified is fewer than the number of elements in the DATA
statement(s), subsequent READ statements will begin reading data at the first
unread element. If there are no subsequent READ statements, the extra data is
ignored.

To reread DATA statements from the start, use the RESTORE statement.

Example:

```text
10 READ A,B$
20 PRINT A,B$
30 END
40 DATA 10,"STRING"
```

### REM

The REM statement is used to insert comments in a program. REM statements are
nonexecutable and may be placed anywhere in the program.

Example:

```text
10 REM THIS IS A COMMENT
20 PRINT "END"
30 END
```

### RESTORE

Format:

```text
RESTORE [offset]
```

To allow DATA statements to be reread from a specified offset.
After a RESTORE statement is executed, the next READ statement accesses the first
item in the first DATA statement in the program. If offset is specified, the next
READ statement accesses the item at the given offset.
Offset is a value from 0 (first DATA statement) to the offset of the last DATA
statement.

Example:

```text
110 READ A,B$
20 RESTORE
30 READ C,D$
40 PRINT A B$ C D$
50 END
60 DATA 10,"STRING"

>> 10 STRING 10 STRING
```

### TRON and TROFF

The TRON and TROFF statements are used to turn on and off the trace mode.
When trace mode is on, the line number of each executed statement is printed.
This is useful for debugging programs.

Example:

```text
10 TRON
20 FOR I=1 TO 4
30 PRINT "HELLO"
40 NEXT I
50 PRINT "WORLD"
60 END

>> [20] [30] HELLO
>> [30] HELLO
>> [30] HELLO
>> [30] HELLO
>> [50] WORLD
>> [60] Ready.
```

### WHILE...LOOP

Format:

```text
WHILE expression
    statements
LOOP
```

The WHILE statement is used to set up a loop that will execute as long as the
expression is true (nonzero). The loop continues until the expression is false (zero).

WHILE/LOOP loops may be nested to any level. Each LOOP will match the most recent WHILE.

Example:

```text
10 LET I = 0
20 WHILE I < 10
30   PRINT "I =" I
40   I = I + 1
50 LOOP
60 END
```

## Internal Functions

This section describes the functions that are available in NanoBasic in alphabetical order.

### CLRLINE

Format:

```text
CLRLINE(y-position)
```

The CLRLINE function is used to clear a line on the terminal. The cursor is positioned
at the beginning of the line.
`y-position` is the vertical position (1-20).
If `y-position` is 0, the current line is cleared.

Example:

```text
10 CLRLINE(10)
20 PRINT "HELLO"
30 END
```

### CLRSCR

Format:

```text
CLRSCR()
```

The CLRSCR function is used to clear the screen.

### GETCURX

Format:

```text
GETCURX()
```

The `GETCURX` function is used to return the current horizontal cursor position (1-60).

Example:

```text
10 PRINT GETCURX()
20 END

>> 10
```

### GETCURY

Format:

```text
GETCURY()
```

The `GETCURY` function is used to return the current vertical cursor position (1-20).

Example:

```text
10 PRINT GETCURY()
20 END

>> 10
```

### HEX$

Format:

```text
HEX$(number)
```

The HEX$ function is used to convert a number to a hexadecimal string.

Example:

```text
10 PRINT HEX$(255)

>> FF
```

### INPUT

Format:

```text
variable = INPUT("prompt")
```

The INPUT function is used to accept input from the user. This input accepts
numeric values only. The input is terminated by pressing the Enter key.

When an INPUT function is encountered, program execution pauses and a question
mark is printed to indicate the program is waiting for data.

The data that is entered is returned as the value of the INPUT function.

Example:

```text
10 A = INPUT("ENTER A NUMBER")
20 PRINT A
30 END
```

### INPUT$

Format:

```text
variable$ = INPUT$("prompt")
```

The INPUT$ function is used to accept input from the user. This input is
returned as string value. The input is terminated by pressing the Enter key.

When an INPUT$ function is encountered, program execution pauses and a question
mark is printed to indicate the program is waiting for data.

The data that is entered is returned as the value of the INPUT$ function.

Example:

```text
10 A$ = INPUT$("ENTER A STRING")
20 PRINT A$
30 END
```

### INSTR

Format:

```text
INSTR(string1, string2)
```

The INSTR function is used to find the position of a substring within a string.
The function returns the position of the first occurrence of string2 in string1.
If string2 is not found in string1, the function returns 0.

Example:

```text
10 PRINT INSTR("HELLO","L")

>> 3
```

### LEFT$

Format:

```text
LEFT$(string, length)
```

The LEFT$ function is used to extract the left part of a string.

Example:

```text
10 A$="HELLO"
20 PRINT LEFT$(A$,2)
30 END

>> HE
```

### LEN

Format:

```text
LEN(string)
```

The LEN function is used to determine the length of a string.

Example:

```text
10 A$="HELLO"
20 PRINT LEN(A$)
30 END

>> 5
```

### MID$

Format:

```text
MID$(string, start, length)
```

The MID$ function is used to extract a substring from a string.

`string` is the string from which the substring is to be extracted.
`start` is the starting position of the substring (1-n).
`length` is the length of the substring (1-n).

Example:

```text
10 A$="HELLO"
20 PRINT MID$(A$,3,2)
30 END

>> LL
```

### PARAM

Format:

```text
PARAM()
```

The PARAM function is used to obtain a numeric value from an external subroutine call.
This is used, for example, when an error occurs in an external function.

Example:

```text
10 val = PARAM()
```

### PARAM$

Format:

```text
PARAM$()
```

The PARAM$ function is used to obtain a string value from an external subroutine call.
This is used, for example, when an error occurs in an external function.

Example:

```text
10 val$ = PARAM$()
```

### RESET

Format:

```text
RESET()
```

The RESET function is used to reset the program to the first line.
The function can be called at any time in the program. But the main use is to
restart the program after the mapblock is loaded. See [Mapblock Loading](#mapblock-loading).

### RIGHT$

Format:

```text
RIGHT$(string, length)
```

The RIGHT$ function is used to extract the right part of a string.

Example:

```text
10 A$="HELLO"
20 PRINT RIGHT$(A$,2)
30 END

>> LO
```

### RND

Format:

```text
RND(number)
```

The RND function is used to generate a random number between 0 and number-1.

Example:

```text
10 PRINT RND(100)
20 END
```

### SERCUR

Format:

```text
SERCUR(x-position, y-position)
```

The SERCUR function is used to set the cursor position on the terminal.
`x-position` is the horizontal position (1-60).
`y-position` is the vertical position (1-20).

Example:

```text
10 SERCUR(10,10)
20 PRINT "HELLO"
30 END
```

### SLEEP

Format:

```text
SLEEP(seconds)
```

The SLEEP function is used to pause program execution for a specified number of seconds.
If the number of seconds is 0, the program pauses one time slice (0.2 seconds).

### SPC

Format:

```text
SPC(number)
```

The SPC function is used to print a number of spaces.

Example:

```text
10 PRINT "HELLO";SPC(5);"WORLD"
20 END

>> HELLO     WORLD
```

### STR$

Format:

```text
STR$(number)
```

The STR$ function is used to convert a number to a string.

Example:

```text
10 PRINT STR$(100)
20 END

>> 100
```

### STRING$

Format:

```text
STRING$(number, character)
```

The STRING$ function is used to create a string of a specified length filled
with a specified character.

Example:

```text
10 PRINT STRING$(5,"*")
20 END

>> *****
```

### TIME

Format:

```text
TIME()
```

The TIME function is used to return the current time in seconds since start of the Minetest server.

### DAYTIME

Format:

```text
t = DAYTIME()
```

The DAYTIME function is used to return the daytime in minutes (0-1440).

### DAYTIME$

Format:

```text
t$ = DAYTIME$(format)
```

The DAYTIME$ function is used to return the daytime as string.
`format` is used to specify the time format:

- 0 = 24 hours format (0-23)
- 1 = 12 hour format with AM/PM

### VAL

Format:

```text
VAL(string)
```

The VAL function is used to convert a string to a number.

Example:

```text
10 PRINT VAL("100")
20 END

>> 100
```

## Techage Functions

This section describes the functions that are available in NanoBasic to interact with
the Techage machines and devices.

NanoBasic provides two command functions:

- `CMD` to send commands and receive responses as numeric values.
- `CMD$` to send commands and receive responses as strings.

Both functions can send numeric commands to Techage devices and both functions
support a flexible number of arguments:

- For commands without payload data: `CMD(node_number, cmnd)`
- For commands with one payload value: `CMD(node_number, cmnd, payload1)`
- For commands with two payload values: `CMD(node_number, cmnd, payload1, payload2)`
- For commands with three payload values: `CMD(node_number, cmnd, payload1, payload2, payload3)`

`payload1` can be a numeric value or a string value.

All Techage commands are described in [Appendix A: Techage Commands](#appendix-a-techage-commands)

### Error Handling

`CMD` and `CMD$` throw an error if the command cannot be executed properly.
In NanoBasic, the subroutine starting at line 65000 is called.

This subroutine can be used to handle errors. The error message and the node number
are passed as external parameters to the subroutine.

In the easiest case, the error subroutine can be defined as follows:

```text
65000 err$ = PARAM$()
65010 num = PARAM()
65020 PRINT "Error:" err$ "in" num
65030 RETURN
```

`PARAM` and `PARAM$` are used to get the error message and the error number.
`PARAM$` has always be used in combination with the `PARAM` function, in that order
and only in the error subroutine.

After this subroutine is called, the program returns to the `CMD` or `CMD$` function.

### Mapblock Loading

When the world around the Techage Terminal is loaded and NanoBasic is active,
the program is continued from the line where the program was interrupted.
By means of the NanoBasic subroutine starting at line 64000, it is possible to
define what should happen when the mapblock is loaded.

This subroutine can be used to initialize the program and/or initialize connected
Techage devices.

In the easiest case, the on-load subroutine can be defined as follows:

```text
64000 PRINT "Mapblock loaded"
64010 RETURN
```

To restart the program from the beginning, call the `RESET` function.
The `RESET` function is used to reset the program to the first line.

```text
64000 PRINT "Mapblock loaded"
64010 RESET()
```

### Hold / Release of techage commands

Techage commands can be held and released. This is useful when a sequence of commands should
be executed at once. Normally, the commands are executed once per cycle, which is 0.1 seconds.
By means of the `HOLD` and `RELEASE` functions, the commands are executed at once.
The `HOLD` function is used to hold the commands and the `RELEASE` function is used to release
and execute the commands.

Example:

```text
10 HOLD()
20 CMD(1234, 1, 1)
30 CMD(1234, 2, 1)
40 CMD(1234, 3, 1)
50 RELEASE()   ' <= Execute the commands
```

### HOLD

Format:

```text
HOLD()
```

The `HOLD` function is used to hold Techage commands.

### RELEASE

Format:

```text
RELEASE()
```

The `RELEASE` function is used to release and execute Techage commands.

### CMD

Format:

```text
CMD(node_number, cmnd[, payload1[, payload2[, payload3]]])
```

The `CMD` function is used to send numeric commands to a Techage device
and return the response as a numeric value.

- `node_number` is the number of the device.
- `cmnd` is the numeric command to be sent.
- `payload1` is an optional numeric value or string used as payload data.
- `payload2` is an optional numeric value used as payload data.
- `payload3` is an optional numeric value used as payload data.

All Techage commands are described in [Appendix A: Techage Commands](#appendix-a-techage-commands)

If the `cmnd` value is larger then 127 The return value of the `CMD` function
is the response value from the device. If the `cmnd` value is smaller then 128
the return value is the status of the command execution:

- 0 = success
- 1 = error: Invalid node number or machine has no command interface
- 2 = error: Invalid command or command not supported
- 3 = error: command execution failed
- 4 = error: Machine is protected (access denied)
- 5 = error: Invalid command response type (e.g. string)
- 6 = error: Wrong number of function parameters

In case of an error, the subroutine at line 65000 is called in addition to the
return value.

Example:

```text
10 PRINT CMD(1234, 2, 1)  ' Set Signal Tower color to green
20 END

>> 0
```

### CMD$

Format:

```text
CMD$(node_number, cmnd[, payload1[, payload2[, payload3]]])
```

The `CMD$` function is used to send numeric commands to a Techage device and
return the response as a string.

- `node_number` is the number of the device.
- `cmnd` is the numeric command to be sent.
- `payload1` is an optional numeric value or string used as payload data.
- `payload2` is an optional numeric value used as payload data.
- `payload3` is an optional numeric value used as payload data.

All Techage commands are described in [Appendix A: Techage Commands](#appendix-a-techage-commands)

The return value of the `CMD$` function is the response string from the device.

In case of an error, the subroutine at line 65000 is called. The error message:

- "Node not found" = 1
- "Command not supported" = 2
- "Command failed" = 3
- "Access denied" = 4
- "Wrong response type" = 5
- "Wrong number of parameters" = 6

Example:

```text
10 DIM arr(2)
20 arr(0)=1
30 PRINT CMD$(1234, 128)
40 END

>> running
```

### CHAT

Format:

```text
CHAT("message")
```

The CHAT function is used to send a chat message to the owner of the Techage Terminal.
The message is displayed in the chat area of the Minetest client.
`message` is the text to be displayed.

Example:

```text
10 CHAT("Hello, World!")
20 END
```

### DCLR

Format:

```text
DCLR(node_number)
```

The DCLR function is used to clear the display of a display device.

- `node_number` is the number of the display device.

Example:

```text
10 DCLR(1234)
20 END
```

### DPUTS

Format:

```text
DPUTS(node_number, row_number, "text message")
```

The DPUTS function is used to display a text message on a display device.

- `node_number` is the number of the display device.
- `row_number` is the row number (1-5) of the display. The display has 5 rows.
   If `row_number` is 0, the message is added at the end of the display.
- `text message` is the text to be displayed.

Example:

```text
10 DPUTS(1234, 1, "Hello, World!")
20 END
```

### DOOR

Format:

```text
DOOR("door_position", "state")
```

The DOOR function is used to open/close a door.

- `door_position` is the position of the door, e.g. "-127,2,2004"
- `state` is the state of the door, either "open" or "close".

Hint: Use the Techage Info Tool to determine the door position.

Example:

```text
10 DOOR("-127,2,2004", "open")
20 END
```

### INAME$

Format:

```text
INAME$("node_name")
```

Read the description (item name) for a specified itemstring.
`node_name` is the technical name of the item.

Example:

```text
10 A$ = CMD$(1234, 128)
20 PRINT INAME$(A$)
30 END
```

## TA3 Terminal Operating Instructions

The TA3 Terminal is a Techage device that allows you to run NanoBasic programs
to control Techage machines and devices.

To activate the TA3 Terminal Basic mode, right-click on the TA3 Terminal with
the Techage Info Tool (open-end wrench) and select "Basic" from the menu.

The TA3 Terminal Basic mode has the following buttons:

- "Edit" to edit the program. The editor allows you to write Basic programs
  and also copy/paste complete programs.
- "Save" to save changes to the program. The program is saved inside the TA3 Terminal.
  The "Save" button also sorts the program lines according to the line numbers.
- "Renum" to renumber the program lines from the complete program, starting from 10
  with a step of 10. The "Renum" button also sorts the program lines according to
  the line numbers.
- "Cancel" to cancel the editing of the program (changes are lost).
- "Run" to run the program.
- "Stop" to stop a running program.
- "Continue" to continue a breaked program.
- "List" to list the program lines while the program is in the break mode.
- "*" / "-" to change the font size of the screen.

Depending on the terminal state, only the appropriate buttons are displayed
and can be used.

Terminal states:

- "init" - The terminal is initialized. The screen shows the free memory.
- "edit" - The terminal is in the edit mode. The screen shows the program lines.
- "stopped" - After pressing the "Stop" button, the terminal is in the stop mode.
- "running" - The terminal is running a program. The screen shows the output of the program.
- "error" - An error occurred when when compiling the program or during the execution.
- "input_str" - The terminal is waiting for a string input.
- "input_num" - The terminal is waiting for a numeric input.
- "break" - The program reached a break point.

## Debugging of NanoBasic Programs

The NanoBasic interpreter provides simple debugging features to help you find
errors in your programs.

The "TRON" statement turns on the trace mode. When trace mode is on, the line number
of each executed statement is printed. Enter the "TRON" statement in your program
to activate the trace mode.

The "BREAK" statement is used to set a breakpoint in the program. When the program
reaches the breakpoint, the program execution is stopped and the terminal is in the
"break" mode. The "BREAK" statement is used to set a breakpoint at a specific line number.

When the program is in the "break" mode, the "List" button can be used to list the program
lines. The input field at the bottom of the screen can be used to read variable values.
Enter the variable name and press the "Enter" key to read the value.
In case of arrays, enter the array name and the index, separated by a comma. (e.g. "A,1")

The "Continue" button is used to continue the program execution after a breakpoint.

## Appendix A: Techage Commands

NanoBasic supports the numeric Techage commands known from the Beduino mod.
These commands are also described in [BEP 005: Techage Commands](https://github.com/joe7575/beduino/blob/main/manual/techage.md)

### CMD Commands without Response

The following table lists the numeric Techage commands that can be used with the `CMD` function.
These commands do not return a response value from the device. The return value of the `CMD` function
is the status of the command execution:

- 0 = success
- 1 = error: Invalid node number or machine has no command interface
- 2 = error: Invalid command or command not supported
- 3 = error: command execution failed
- 4 = error: Machine is protected (access denied)
- 5 = error: Invalid command response type (e.g. string)
- 6 = error: Wrong number of function parameters

As payload data, these commands may require numeric values or a string value.

| Command                  | cmnd (num)  | Payload                | Remarks                                                      |
| ------------------------ | ----------- | ---------------------- | ------------------------------------------------------------ |
| Turn on/off              | 1  | state      | Turn device (lamp, machine, button...) on/off.<br>`state`: 0 = "off", 1 = "on" |
| Turn on/off Signs Bot    | 1  | state      | Turn device (lamp, machine, button...) on/off.<br>`state`: 0 = "off", 1 = "on" |
| Signal Tower             | 2  | color      | Set Signal Tower color<br>`color`: 0 = "off", 1 = "green", 2 = "amber", 3 = "red" |
| Traffic Light | 2 | color | Set Traffic Light color<br>`color`: 0 = "off", 1 = "green", 2 = "amber", 3 = "red" |
| Signal Lamp              | 3  | idx, color | Set the lamp color for "TA4 2x" and "TA4 4x" Signal Lamps<br>`idx` is the lamp number (1..4)<br>`color`: 0 = "off", 1 = "green", 2 = "amber", 3 = "red" |
| Distri. Filter Slot      | 4  | idx, state | Enable/disable a Distributor filter slot.<br>`idx` is the slot number: 1 = "red", 2 = "green", 3 = "blue", 4 = "yellow"<br>`state`: 0 = "off", 1 = "on" |
| Detector Block Countdown | 5  | counter    | Set countdown counter of the TA4 Item Detector block to the given value and start countdown mode. |
| Detector Block Reset     | 6  | -          | Reset the item counter of the TA4 Item Detector block        |
| TA3 Sequenzer            | 7  | state      | Turn the TA3 Sequencer on/off<br>`state`: 0 = "off", 1 = "on", 2 = "pause" |
| DC2 Exchange Block       | 9  | 0, idx     | TA3 Door Controller II (techage:ta3_doorcontroller2). Exchange a block in the world<br /> with the block in the inventory.<br>`idx` is the inventory slot number (1..n) |
| DC2 Set to1   | 9  | 4, idx     | TA3 Door Controller II (techage:ta3_doorcontroller2). Swaps a block in the inventory <br />with the block in the world, provided the position was in state 2 (Exchange state).<br>`idx` is the inventory slot number (1..n) |
| DC2 Set to2     | 9  | 5, idx     | TA3 Door Controller II (techage:ta3_doorcontroller2). Swaps a block in the inventory <br />with the block in the world, provided the position was in state 1 (Initial state).<b<br />`idx` is the inventory slot number (1..n) |
| DC2 Reset                | 9  | 3          | TA3 Door Controller II (techage:ta3_doorcontroller2). Using the reset command,<br />all blocks are reset to their initial state after learning. |
| Autocrafter              | 10 | num, idx   | Set the TA4 Autocrafter recipe with a recipe from a TA4 Recipe Block.<br>`num` is the TA4 Recipe Block number<br>`idx` is the number of the recipe in the TA4 Recipe Block |
| Autocrafter              | 11 | -          | Move all items from input inventory to output inventory. Returns 1 if the input inventory was emptied in the process. Otherwise return 0 |
| Move Contr. 1            | 11 | 1          | TA4 Move Controller command to move the block(s) from position A to B |
| Move Contr. 2            | 11 | 2          | TA4 Move Controller command to move the block(s) from position B to A |
| Move Contr. 3            | 11 | 3          | TA4 Move Controller command to move the block(s) to the opposite position |
| Move Contr. `move xyz`   | 18 | x, y, z    | TA4 Move Controller command to move the block(s) by the given<br>x/y/z-distance. Valid ranges for x, y, and z are -100 to 100 |
| Move Contr. `moveto`     | 24 | x, y, z    | TA4 Move Controller command to move the block(s) to the given absolute x/y/z-position. |
| Move Contr. `reset`      | 19 | -          | Reset TA4 Move Controller (move block(s) to start position)  |
| Move Contr. II `moveto`  | 24 | x, y, z    | TA4 Move Controller command to move the block(s) to the given absolute x/y/z-position. |
| Move Contr. II `reset`   | 19 | -          | Reset TA4 Move Controller (move block(s) to start position)  |
| Turn Contr. 1            | 12 | 1          | TA4 Turn Controller command to turn the block(s) to the left |
| Turn Contr. 2            | 12 | 2          | TA4 Turn Controller command to turn the block(s) to the right |
| Turn Contr. 3            | 12 | 3          | TA4 Turn Controller command to turn the block(s) 180 degrees |
| TA4 Sequenzer 1          | 13 | slot       | Start/goto command for the TA4 Sequencer.<br>`slot` is the time slot (1..n) where the execution starts. |
| TA4 Sequenzer 2          | 13 | 0          | Stop command for the TA4 Sequencer.                          |
| Sound 1                  | 14 | 1, volume  | Set volume of the sound block<br>`volume` is a value from 1 to 5 |
| Sound 2                  | 14 | 2, index   | Select sound sample of the sound block<br>`index` is the sound sample number |
| TA4 Pusher Limit         | 20 | limit      | Configure a TA4 Pusher with the number of items that are allowed to be pushed ("flow limiter" mode)<br>`limit` = 0 turns off the "flow limiter" mode |
| TA4 Pump Limit           | 21 | limit      | Configure a TA4 Pump with the number of liquid units that are allowed to be pumped ("flow limiter" mode)<br>`limit` = 0 turns off the "flow limiter" mode |
| Color                    | 22 | color      | Set the color of the TechAge Color Lamp and TechAge Color Lamp 2 (`color` = 0..255) |
| Multi Button             | 23 | num, state | Turn button (TA4 2x Button, TA4 4x Button) on/off<br>`num` is the button number (1..4)<br>`state` is the state: 0 = "off", 1 = "on" |
|                          | 25 is next |    |                                                              |
| Config TA4 Pusher        | 65 | "\<item name>"         | Configure the TA4 pusher.<br/>Example: `wool:blue`           |
| Sensor Chest Text        | 66 | "text string"          | Text to be used for the Sensor Chest menu                    |
| Distri. Filter Config    | 67 | "\<slot> \<item list>" | Configure a Distributor filter slot, like: "red default:dirt dye:blue" |

### CMD Commands with Response as Numeric Value

The following table lists the numeric Techage commands that can be used with the
`CMD` function.
These commands return a numeric response value from the device.
In case of an error, the error subroutine is called and the response value
corresponds to the error from previous chapter.

| Command                    | Topic (num) | Payload (number(s)) | Response (number) | Remarks to the response                                      |
| -------------------------- | ----------- | ------------------- | ----------------------- | ------------------------------------------------------------ |
| Signs Bot State            | 129 | -    | state | Returns: 1 = RUNNING, 2 = BLOCKED, 3 = STOPPED, 4 = NO_POPWER, 5 = ERROR, 6 = FULL, 7 = CHARGING |
| State for Techage Machines | 129 | -    | state | RUNNING = 1, BLOCKED = 2, STANDBY = 3, NOPOWER = 4, FAULT = 5, STOPPED = 6, UNLOADED = 7, INACTIVE = 8 |
| Minecart State (Cart Terminal)   | 129 | cart-id | state    | Returns 0 = UNKNOWN, 1 = STOPPED, 2 = RUNNING           |
| Minecart Distance (Cart Terminal)| 130 | cart-id | distance | Returns the distance from the cart to the Cart Terminal in meters |
| Signal Tower Color         | 130 | -    | color | OFF = 0, GREEN = 1, AMBER = 2, RED = 3                       |
| Traffic Light Color | 130 | - | color | OFF = 0, GREEN = 1, AMBER = 2, RED = 3 |
| Chest State                | 131 | -    | state | State of a TA3/TA4 chest or Sensor Chest: EMPTY = 0, LOADED = 1, FULL = 2 |
| TA3/TA4 Button State       | 131 | -    | state | OFF = 0, ON = 1                                              |
| Fuel Level                 | 132 | -    | level | Fuel level of a fuel consuming block (0..65535)              |
| Quarry Depth               | 133 | -    | depth | Current depth value of a quarry block (1..80)                |
| Load Percent               | 134 | 1    | load    | Load value in percent  (0..100) of a tank, silo, accu, fuelcell, or battery block. |
| Load Absolute              | 134 | 2    | load    | Absolute value in units for silos and tanks                  |
| Storage Percent            | 134 | -    | value   | Read the grid storage amount (state of charge) in percent  (0..100) from a TA3 Power Terminal. |
| Consumer Current           | 135 | -    | current | TA3 Power Terminal: Total power consumption (current) of all consumers |
| Delivered Power            | 135 | -    | power   | Current providing power value of a generator block           |
| Total Flow Rate            | 137 | -    | rate    | Total flow rate in liquid units for TA4 Pumps (0..65535)     |
| Sensor Chests State 1      | 138 | 1    | state   | Last action: NONE = 0 PUT = 1, TAKE = 2                      |
| Sensor Chests State 4      | 138 | 4, idx | state | Number of inventory stack items (0..n)<br>`idx` is the inventory stack number (1..n) |
| Item Counter               | 139 | -    | count   | Item counter of the TA4 Item Detector block (0..n)           |
| Inventory Item Count       | 140 | 1, idx| count  | Amount of TA4 8x2000 Chest items<br>`idx` is the inventory slot number (1..8 from left to right, or 0 for the total number) |
| Inventory Store Size       | 140 | 3    | size    | Size of one of the eight stores of the TA4 8x2000 Chest. Returns e.g. 6000 |
| Binary State               | 142 | -    | state   | Current block state: OFF = 0, ON = 1                         |
| Light Level                | 143 | -    | level   | Light level value between 0  and 15 (15 is high)             |
| Solar Cell State           | 145 | -    | state   | 0 = UNUSED, 1 = CHARGING, 2 = UNCHARGING                     |
| Consumption                | 146 | 0    | value   | TA4 Electric Meter: Amount of electrical energy passed through |
| Countdown                  | 146 | 1    | value   | TA4 Electric Meter: Countdown value for the amount of electrical energy passed through |
| Current                    | 146 | 2    | value   | TA4 Electric Meter: Current flow of electricity (current)    |
| Door Controller II State   | 147 | idx  | state   | State of the specified inventory slot (1..n). Returns: 1 = Initial state (reset), 2 = Exchange state |
| Time Stamp                 | 149 | -    | time    | Time in system ticks (norm. 100 ms) when the TA4 Button is clicked |
| TA4 Pusher Counter         | 150 | -    | number  | Read the number of pushed items for a TA4 Pusher in "flow limiter" mode |
| TA4 Pump Counter           | 151 | -    | number  | Read the number of pumped liquid units for a TA4 Pump in "flow limiter" mode |
| Multi Button State         | 152 | num  | state   | Read the button state (TA4 2x Button, TA4 4x Button)<br>`num` is the button number (1..4), `state`: 0 = "off", 1 = "on" |
| Water Remover Depth        | 153 | -    | depth   | Current depth value of a remover (1..80)                |
| **--------------------------** | **---** | **----** | **-------** | **Payload as string** |
| Chest Item Count           | 192 | "item" | count   | Amount of items in a TA3/TA4/TA5 chest or shop. `item` is the item name or<br>a substring of the item name, e.g. "dirt". |

### CMD$ Commands with Response as String Value

The following table lists the numeric Techage commands that can be used with the
`CMD$` function.
These commands return a string response value from the device.
In case of an error, the error subroutine is called and the response string is "".

| Command               | Topic (num) | Payload (numbers) | Response (string) | Remarks to the response                                      |
| ----------------------| ----------- | ---------------------- | ----------------------- | ------------------------------------------------------------ |
| Identify              | 128  | -      | "\<node name>"   | Node name as string like "techage:ta3_akku"                  |
| Sensor Chests State 2 | 138  | 2      | "\<player name>" | Player name of last action                                   |
| Sensor Chests State 3 | 138  | 3, idx | "\<node name>"   | Inventory Stack node name, or "none". <br>`idx` is the inventory stack number (1..n) |
| Inventory Item Name   | 140  | 2, idx | "\<node name>"   | Name of TA4 8x2000 Chest items<br>`idx` is the inventory slot number (1..8 from left to right) |
| Furnace Output        | 141  | -      | "\<node name>"   | Node name of the Industrial Furnace output. <br>Returns "none", if no recipe is active |
| Player Name           | 144  | -      | "\<player name>" | Player name of the TA3/TA4 Player Detector or TA4 Button     |
| Distri. Filter Get    | 148  | idx    | "\<item list>"   | `idx` is the slot number: 1 = "red", 2 = "green", 3 = "blue", 4 = "yellow"<br>Returns a string like: "default:dirt dye:blue" |
