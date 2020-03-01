.global _start
.section .text._start
_start:
	.org  0x00000000
	/* RM0360 Section 2.5 top-of-stack */
	.word 0x20001000
	/* RM0360 Section 11.1.3 Vector table */
	.word reset
