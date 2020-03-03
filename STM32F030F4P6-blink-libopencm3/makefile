PREFIX ?= arm-none-eabi-
LINKER ?= gcc
DEBUG  ?= 1

CC      = $(PREFIX)gcc
LD      = $(PREFIX)ld
OBJCOPY = $(PREFIX)objcopy
SIZE    = $(PREFIX)size
OBJDUMP = $(PREFIX)objdump

TARGET ?= blinker
DEPDIR  = Deps
OBJDIR  = Objs

TARGET := ${TARGET}_${LINKER}

CFLAGS  = -Wall -Werror
ifeq (${DEBUG}, 1)
    CFLAGS += -g
else
    CFLAGS += -Os
endif
# Bare metal flags
CFLAGS += -nostdlib -nostartfiles -ffreestanding -nodefaultlibs
# Microcontroller specific flags
CFLAGS += -mcpu=cortex-m0 -mthumb
# Couldn't get -script ...liblto_plugin.so working with LD, so using lto only when linking with gcc
ifeq (${LINKER}, gcc)
    CFLAGS += -flto
endif

LDFLAGS = --print-memory-usage --gc-sections -T stm32f030f4p6.ld
LDLIBS  = -lopencm3_stm32f0

SRCS    = main.c start.S
OBJS    = $(addprefix ${OBJDIR}/, ${SRCS:=.o})

# GCC flags for auto dependency generation
DEPOPTS = -MP -MD -MF ${DEPDIR}/$(notdir $@).d

all: ${TARGET}.bin

%.bin: %.elf
	$(OBJCOPY) $< $@ -O binary

stm32f030f4p6.ld: stm32f030f4p6_memory.ld
	cp $< $@
	$(LD) --verbose | sed -n '/^=\{50\}/,/^=\{50\}/p' | sed '1d;$$d' >> $@

ifeq (${LINKER}, gcc)
    SPACE := $(null) #
    COMMA := ,
    LINK   = $(CC) ${CFLAGS} -Wl,$(subst ${SPACE},${COMMA},${LDFLAGS}) ${OBJS} -o $@ ${LDLIBS}
else ifeq (${LINKER}, ld)
    LINK   = $(LD) ${LDFLAGS} ${OBJS} -o $@ ${LDLIBS}
endif

${TARGET}.elf: ${OBJS} stm32f030f4p6.ld
	${LINK}
	$(SIZE) $@ ${OBJS}
	$(eval FILES := $(shell sed -n '/:$$/s/:$$//p' ${DEPDIR}/* | sort -u) ${SRCS})
	@cscope -k -b ${FILES}
	@ctags --extras=+f --c-kinds=defghlmpstuvxzL ${FILES}

# Implicit rules with pattern rules
# On the first go, without dependencies in ./${DEPDIR}, this implicit rule will apply
# and dependency file will be generated.
${OBJDIR}/%.c.o: %.c makefile | ${DEPDIR} ${OBJDIR}
	$(CC) ${DEPOPTS} ${CFLAGS} $< -c -o $@

${OBJDIR}/%.S.o: %.S makefile | ${DEPDIR} ${OBJDIR}
	$(CC) ${DEPOPTS} $(CFLAGS) $< -c -o $@

# Generate directory if doesn't exists
${OBJDIR} ${DEPDIR}:
	test -d $@ || mkdir $@

disassemble: ${TARGET}.elf
	$(OBJDUMP) -D $<

install: ${TARGET}.bin
	st-flash write $< 0x08000000

gdb:
	st-util

gdb-attach: ${TARGET}.elf
	arm-none-eabi-gdb -ex "target remote localhost:4242" $<

clean:
	rm -rf ${TARGET}.elf ${TARGET}.bin stm32f030f4p6.ld ${OBJDIR} ${DEPDIR}
	rm -rf cscope.*out tags

# Include automatic dependencies
-include $(wildcard ${DEPDIR}/*)
