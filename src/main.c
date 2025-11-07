#include <stdint.h>

#define SCS_BASE        0xE000E000UL
#define PERIPH_BASE     0x40000000UL
#define APB2PERIPH_BASE (PERIPH_BASE + 0x10000UL)
#define APB1PERIPH_BASE (PERIPH_BASE + 0x00010000UL)

#define RCC_BASE        0x40021000UL
#define GPIOA_BASE      0x40010800UL
#define UART_BASE       0x40004400UL
#define AFIO_BASE       0x40010000UL
#define SYSTICK_BASE    (SCS_BASE + 0x00000010UL)


#define RCC_APB2ENR     (*(volatile uint32_t *)(RCC_BASE + 0x18))
#define RCC_APB1ENR     (*(volatile uint32_t *)(RCC_BASE + 0x1C))

#define GPIOA_CRL       (*(volatile uint32_t *)(GPIOA_BASE + 0x00))
#define GPIOA_ODR       (*(volatile uint32_t *)(GPIOA_BASE + 0x0C))
#define AFIO_MAPR       (*(volatile uint32_t *)(AFIO_BASE + 0x04))


#define UART_SR         (*(volatile uint32_t *)(UART_BASE)) 
#define UART_DR         (*(volatile uint32_t *)(UART_BASE + 0x04))
#define UART_BRR        (*(volatile uint32_t *)(UART_BASE + 0x08))
#define UART_CR1        (*(volatile uint32_t *)(UART_BASE + 0x0C))

#define SYST_CSR        (*(uint32_t *)(SYSTICK_BASE + 0x00000000))
#define SYST_RVR        (*(uint32_t *)(SYSTICK_BASE + 0x00000004))
#define SYST_CVR        (*(uint32_t *)(SYSTICK_BASE + 0x00000008))


#define RCC_IOPAEN      (1 << 2)
#define RCC_AFIOEN      (1 << 0)
#define RCC_UART2EN     (1 << 17)
#define LED_PIN         (1 << 5)
#define SYSTICK_EN      (1 << 0)
#define COUNTFLAG       (1 << 16)
#define SYS_CLK		    8000000U
#define BAUD_RATE	    115200U

static void delay(volatile uint32_t count) {
    while (count--) __asm__("nop");
}

void gpio_init(void);
void uart_init(void);
char uart_read();
void uart_write(char ch);
void set_BaudRate(uint32_t clk ,uint32_t baud );
void systick_delay(int delay);

int main(void) {
    gpio_init();
    uart_init();

    //Blink loop
    while (1) {
        GPIOA_ODR ^= LED_PIN;  // toggle PA5
        systick_delay(1);

        char recieved = uart_read();
        uart_write(recieved);
    }
}

void systick_delay(int delay){
    SYST_RVR = (SYS_CLK * 1000) -1;
    SYST_CVR = 0;

    // enabled the clock , and set the mcu clock for use
    SYST_CSR |= SYSTICK_EN | (1 << 2);

    for(int i =0 ;i<delay; i++){
        while((SYST_CSR & COUNTFLAG)==0);
    }
    SYST_CSR =0;

}

void gpio_init(void){
    // Enable GPIOA clock
    RCC_APB2ENR |= RCC_IOPAEN;

    //Configure PA5 as push-pull output, 2 MHz
    GPIOA_CRL &= ~(0xF << 20);  // clear CNF5 + MODE5
    GPIOA_CRL |=  (0x2 << 20);  // MODE5 = 10 (output 2 MHz), CNF5 = 00 (push-pull)

}

void uart_init(void){
    // using UART2 -->apb1 bus , PA2-->TX ,PA3-->RX 
    RCC_APB1ENR |= RCC_UART2EN; //clock access to uart2 
    RCC_APB2ENR |= RCC_IOPAEN ; //clock access to GPIOA 
    RCC_APB2ENR |= RCC_AFIOEN;

    AFIO_MAPR &= ~(1 << 3);  // clear USART2_REMAP

    //We would have to configure the rx and tx pins too
    // TX pin -->output 50mhz[11], alternate function pushpull[10]. [1011] 
    GPIOA_CRL &= ~(0xF <<(4*2));
    GPIOA_CRL |=  (0xB <<(4*2));
    //RX pin-->floating input[01], input mode[00].  [0100]
    GPIOA_CRL &= ~(0xF <<(4*3));
    GPIOA_CRL |=  (0x4 <<(4*3));

    //baud rate thing
    set_BaudRate(SYS_CLK,BAUD_RATE);

    //enabling uart pins
    UART_CR1 |=  (1U << 13); //UE enabled
    UART_CR1 |=  (1U << 3); //TX enabled
    UART_CR1 |=  (1U << 2); //RX enabled 

}

void set_BaudRate(uint32_t clk ,uint32_t baud ){
	UART_BRR = (clk + (baud/2U))/baud;
}
void uart_write(char ch){
    while(!(UART_SR & (1U << 7)));
    UART_DR =ch ;
}

char uart_read(){
    while(!(UART_SR & (1U<<5)));
    return UART_DR ;
}