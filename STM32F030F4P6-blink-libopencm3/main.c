#define STM32F0
#include <libopencm3/stm32/gpio.h>
#include <libopencm3/stm32/rcc.h>

void main()
{
    /* I/O port A clock enable */
    rcc_periph_clock_enable(RCC_GPIOA);
    /* Set port */
    gpio_mode_setup(GPIOA, GPIO_MODE_OUTPUT, GPIO_PUPD_NONE, GPIO4);

    int i;
    for(i = 0;; i++)
    {
        if(i & (1 << 18))
            gpio_set(GPIOA, GPIO4);
        else
            gpio_clear(GPIOA, GPIO4);
    }
}

void reset()
{
    main();
}
