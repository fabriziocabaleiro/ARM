# Simple USART example.
## Description
Simple USART receiver/transmitter written in Assembly. Using cheapest development board from ebay, about 1.19 GBP and USB to TTL UART converter (CH340G) for about 2.19 GBP.

Documentation for STM32F030F4P6:
* https://www.st.com/content/ccc/resource/technical/document/reference_manual/cf/10/a8/c4/29/fb/4c/42/DM00091010.pdf/files/DM00091010.pdf/jcr:content/translations/en.DM00091010.pdf
* https://documentation-service.arm.com/static/5ea971669931941038df3ce2?token=
* https://www.st.com/resource/en/datasheet/stm32f030f4.pdf

## Compile and flash
After connecting the ST-LINK to the development board, execute the following commands:
```
$ make
$ make install
```
