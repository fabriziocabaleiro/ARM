PREFIX ?= arm-none-eabi-

CC      = $(PREFIX)gcc
LD      = $(PREFIX)ld
OBJCOPY = $(PREFIX)objcopy
SIZE    = $(PREFIX)size

SRCS    = blink.S
OBJS    = ${SRCS:.S=.o}
TARGET ?= blink

CFLAGS = -mthumb -g -Wall -mcpu=cortex-m0

all: ${TARGET}.bin

%.bin: %.elf
	$(OBJCOPY) $< $@ -O binary

${TARGET}.elf: ${OBJS} stm32f030f4p6.ld
	$(LD) ${OBJS} --print-memory-usage -T stm32f030f4p6.ld -o $@
	$(SIZE) $@

%.o: %.S
	$(CC) $(CFLAGS) $< -c -o $@

install: ${TARGET}.bin
	st-flash write $< 0x08000000

gdb:
	st-util

gdb-attach: ${TARGET}.elf
	arm-none-eabi-gdb -ex "target remote localhost:4242" $<

clean:
	rm -f ${TARGET}.elf ${TARGET}.bin *.o
