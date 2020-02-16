/* Copyright (C) 2020  Fabrizio Cabaleiro */

/* RM0360 Section 2.2.2 */
#define GPIOA             0x48000000
#define RCC               0x40021000

/* RM0360 Section 7.4.15 */
#define RCC_AHBENR        0x14
#define RCC_AHBENR_IOPAEN 17


/* RM0360 Section 8.4.12 */
#define GPIOx_MODER       0x00
#define GPIOx_OTYPER      0x04
#define GPIOx_OSPEEDR     0x08
#define GPIOx_PUPDR       0x0C
#define GPIOx_IDR         0x10
#define GPIOx_ODR         0x14

#define GPIOx_MODER_Px4   8
#define GPIOx_OTYPER_Px4  4
#define GPIOx_OSPEEDR_Px4 8
#define GPIOx_PUPDR_Px4   8
#define GPIOx_IDR_Px4     4
#define GPIOx_ODR_Px4     4

.section .text

.cpu cortex-m0
.thumb

/* RM0360 Section 2.5 top-of-stack */
.org  0x00000000
.word 0x20001000

/* RM0360 Section 11.1.3 Vector table */
.org  0x00000004
.word reset

/******************************* reset handler ********************************/
.thumb_func
reset:
	bl	main

/************************************ main ************************************/
.thumb_func
main:
	/* Enable port A clock */
	ldr	r0, =(RCC + RCC_AHBENR)
	ldr	r1, [r0]
	ldr	r2, =(1 << RCC_AHBENR_IOPAEN)
	orr	r1, r1, r2
	str	r1, [r0]

	/* MODER, set PA4 as output */
	ldr	r0, =GPIOA
	ldr	r1, [r0, #GPIOx_MODER]
	ldr	r2, =~(0x3 << GPIOx_MODER_Px4)
	and	r1, r2
	ldr	r2, =(0x1 << GPIOx_MODER_Px4)
	orr	r1, r2
	str	r1, [r0, #GPIOx_MODER]

	/* OTYPER, set PA4 as open-drain */
	ldr	r1, [r0, #GPIOx_OTYPER]
	ldr	r2, =(0x1 << GPIOx_OTYPER_Px4)
	orr	r1, r2
	str	r1, [r0, #GPIOx_OTYPER]

	/* OSPEED, set PA4 to medium speed */
	ldr	r1, [r0, #GPIOx_OSPEEDR]
	ldr	r2, =~(0x3 << GPIOx_OSPEEDR_Px4)
	and	r1, r2
	ldr	r2, =(0x1 << GPIOx_OSPEEDR_Px4)
	orr	r1, r2
	str	r1, [r0, #GPIOx_OSPEEDR]

	/* PUPDR, no pull-up/pull-down */
	ldr	r1, [r0, #GPIOx_PUPDR]
	ldr	r2, =(~0x3 << GPIOx_PUPDR_Px4)
	and	r1, r2
	str	r1, [r0, #GPIOx_PUPDR]

	/* loop pre-set */
	mov	r4, #0                    /* Counter */
	ldr	r1, =(1 << 18)            /* PA4 = Counter & r1 ? 1 : 0 */
	mov	r3, #(1 << GPIOx_IDR_Px4) /* PA4 bitmask */
loop:	add	r4, #1
	mov	r2, r4
	and	r2, r1
	ldr	r2, [r0, #GPIOx_IDR]
	beq	0f
	/* Set PA4 */
	orr	r2, r3
	b	1f
	/* Clear PA4 */
0:	bic	r2, r3
1:	str	r2, [r0, #GPIOx_ODR]
	b	loop

.end
