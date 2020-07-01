/* Copyright (C) 2020  Fabrizio Cabaleiro */

/* ARM DUI 0497A Section 4.2 */
/* Interrupt Set-enable Register */
#define ISER				0xE000E100

/* RM0360 Section 2.2.2 */
#define GPIOA				0x48000000
#define RCC				0x40021000
#define USART1				0x40013800

/* RM0360 Section 7.4.13 */
#define RCC_CFGR3			0x30
#define RCC_CFGR3_USART1SW_PCLK		0x00
#define RCC_CFGR3_USART1SW_SYSCLK	0x01
#define RCC_CFGR3_USART1SW_LSE		0x02
#define RCC_CFGR3_USART1SW_HSI		0x03

/* RM0360 Section 7.4.15 */
#define RCC_AHBENR			0x14
#define RCC_AHBENR_IOPAEN		17
#define RCC_APB2ENR			0x18
#define RCC_APB2ENR_USART1EN		14

/* RM0360 Section 8.4.1 */
#define GPIOx_MODER_ALTERNATE		2
#define GPIOx_MODER_WIDTH		2

/* RM0360 Section 8.4.10 */
#define GPIOx_AFSEL_Px9			4
#define GPIOx_AFSEL_Px10		8

/* RM0360 Section 8.4.12 */
#define GPIOx_MODER			0x00
#define GPIOx_OTYPER			0x04
#define GPIOx_OSPEEDR			0x08
#define GPIOx_PUPDR			0x0C
#define GPIOx_IDR			0x10
#define GPIOx_ODR			0x14
#define GPIOx_BSRR			0x18
#define GPIOx_LCKR			0x1C
#define GPIOx_AFRL			0x20
#define GPIOx_AFRH			0x24
#define GPIOx_BRR			0x28

/* RM0360 Section 11.1.3 */
#define NVIC_USART1			27

/* RM0360 Section 23.7.x */
#define USART_CR1			0x00
#define USART_CR1_UE			0
#define USART_CR1_RE			2
#define USART_CR1_TE			3
#define USART_CR1_RXNEIE		5
#define USART_BRR			0x0C
#define USART_ISR			0x1C
#define USART_ISR_TXE			7
#define USART_ISR_RXNE			5
#define USART_RDR			0x24
#define USART_TDR			0x28

/* DS9773 Section 4 Table 12 */
#define GPIOA_AFR_P9_USART1_TX		1
#define GPIOA_AFR_P10_USART1_RX		1

/* Port A */
#define PA9				9
#define PA10				10

/* Shift bits depending on port */
#define GPIOx_SHIFT(DATA, DATA_WIDTH, PORT) \
	(DATA) << ((DATA_WIDTH) * (PORT))

.section .text

.cpu cortex-m0
.thumb

/* RM0360 Section 2.5 top-of-stack */
.org  0x00000000
.word 0x20001000

/* RM0360 Section 11.1.3 Vector table */
.org  0x00000004
.word reset

.org  0x000000AC
.word usart_isr

/******************************* reset handler ********************************/
.thumb_func
reset:
	bl	main

/******************************* usart handler ********************************/
.thumb_func
usart_isr:
	/* ARM DUI 0497A Section 2.3.6 -> Exception entry */
	/* r0-r3, r12, LR, PC, xPSR are pushed into stack (stack frame) by HW */
	/* Check interrupt flags */
	ldr	r0, =USART1
	ldr	r1, [r0, #USART_ISR]
	/* RXNE */
	ldr	r2, =(1 << USART_ISR_RXNE)
	and	r2, r1, r2
	beq	9f
	ldr	r3, [r0, #USART_RDR]
	/* Wait for TXE to be set */
0:	ldr	r2, =(1 << USART_ISR_TXE)
	and	r2, r1, r2
	beq	0b
	str	r3, [r0, #USART_TDR]
9:	bx	lr /* lr -> link register */

/*********************************** main *************************************/
.thumb_func
main:
	/*****************
	 * CONFIGURE RCC *
	 *****************/
	ldr	r0, =(RCC)
	/* Enable port A clock */
	ldr	r1, [r0, #RCC_AHBENR]
	ldr	r2, =(1 << RCC_AHBENR_IOPAEN)
	orr	r1, r1, r2
	str	r1, [r0, #RCC_AHBENR]

	/* Enable USART1 clock */
	ldr	r1, [r0, #RCC_APB2ENR]
	ldr	r2, =(1 << RCC_APB2ENR_USART1EN)
	orr	r1, r1, r2
	str	r1, [r0, #RCC_APB2ENR]

	/* Set clock source for USART1 */
	ldr	r1, [r0, #RCC_CFGR3]
	ldr	r2, =RCC_CFGR3_USART1SW_PCLK
	orr	r1, r1, r2
	str	r1, [r0, #RCC_CFGR3]

	/*******************
	 * CONFIGURE GPIOA *
	 *******************/
	ldr	r0, =GPIOA
	/* Set PA9/PA10 as alternate mode */
	ldr	r1, [r0, #GPIOx_MODER]
	ldr	r2, =(GPIOx_SHIFT(GPIOx_MODER_ALTERNATE,
				  GPIOx_MODER_WIDTH, PA9) | \
		      GPIOx_SHIFT(GPIOx_MODER_ALTERNATE,
				  GPIOx_MODER_WIDTH, PA10))
	orr	r1, r2
	str	r1, [r0, #GPIOx_MODER]

	/* Select alternate function to USART */
	ldr	r1, [r0, #GPIOx_AFRH]
	ldr	r2, =(GPIOA_AFR_P9_USART1_TX << GPIOx_AFSEL_Px9) | \
		     (GPIOA_AFR_P10_USART1_RX << GPIOx_AFSEL_Px10)
	orr	r1, r2
	str	r1, [r0, #GPIOx_AFRH]

	/******************
	 * CONFIGURE NVIC * 
	 ******************/
	ldr	r1, =ISER
	ldr	r2, =(1 << NVIC_USART1)
	str	r2, [r1, #0]

	/********************
	 * CONFIGURE USART1 *
	 ********************/
	ldr	r0, =(USART1)
	/* Baud rate 9600 @8Mhz */
	ldr	r1, =(833)                  /* 8000000 / 96 */
	str	r1, [r0, #USART_BRR]

	/* Set UE (Usart Enable), TE (Transmit Enable and RE (Receive Enable)
	 * Default M0 = 0 for 8bits words, OVER8 = 0 for Oversampling by 16 */
	ldr	r1, [r0, #USART_CR1]
	ldr	r2, =((1 << USART_CR1_TE)     | \
		      (1 << USART_CR1_RE)     | \
		      (1 << USART_CR1_UE)     | \
		      (1 << USART_CR1_RXNEIE))
	orr	r1, r1, r2
	str	r1, [r0, #USART_CR1]

	/* Interrupt are enabled by default. Enable them anyway as example */
	cpsie	i

	/* loop, sleep while waiting for USART interrupt */
0:	wfi /* Wait For Interrupt */
	b	0b

.end
