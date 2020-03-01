# Simple LED blinker.
## Description
Simple blinker written in C using libopencm3.

At least in Archlinux libopencm3 can be installed with the package manager (pacman).

## LD script
The initial goal was to prepend/append to the default LD script, but apparently
this is not possible. When passing the -T to the linker, the default script is
not used.

In order to use the default LD script with some modifications, the makefile will
dump the default script and modify it.

## Compile and flash
After connecting the ST-LINK to the development board, execute the following commands:
```
$ make
$ make install
```
