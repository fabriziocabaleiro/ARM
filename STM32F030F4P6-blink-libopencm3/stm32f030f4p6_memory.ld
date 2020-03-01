MEMORY
{
	/* Main Flash Memory from RM0360 section 2.2.2 */
	rom (rx)  : ORIGIN = 0x08000000, LENGTH = 16K
	/* SRAM from RM0360 section 2.2.2 */
	ram (rwx) : ORIGIN = 0x20000000, LENGTH = 4K
}
