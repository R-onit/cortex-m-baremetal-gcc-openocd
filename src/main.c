#include <stdint.h>


#define PERIPH_BASE     0x40000000UL
#define APB2PERIPH_BASE (PERIPH_BASE + 0x10000UL)


#define RCC_BASE        (APB2PERIPH_BASE + 0x1000UL)
#define GPIOA_BASE      (APB2PERIPH_BASE + 0x0800UL)


#define RCC_APB2ENR     (*(volatile uint32_t *)(RCC_BASE + 0x18))
#define GPIOA_CRL       (*(volatile uint32_t *)(GPIOA_BASE + 0x00))
#define GPIOA_ODR       (*(volatile uint32_t *)(GPIOA_BASE + 0x0C))


#define RCC_IOPAEN      (1 << 2)
#define LED_PIN         (1 << 5)

static void delay(volatile uint32_t count) {
    while (count--) __asm__("nop");
}

int main(void) {


    // 1. Enable GPIOA clock
    RCC_APB2ENR |= RCC_IOPAEN;


    // 2. Configure PA5 as push-pull output, 2 MHz
    GPIOA_CRL &= ~(0xF << 20);  // clear CNF5 + MODE5
    GPIOA_CRL |=  (0x2 << 20);  // MODE5 = 10 (output 2 MHz), CNF5 = 00 (push-pull)




    // 3. Blink loop
    while (1) {
        GPIOA_ODR ^= LED_PIN;  // toggle PA5
        delay(500000);
    }
}
