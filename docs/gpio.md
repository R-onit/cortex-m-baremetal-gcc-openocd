# GPIO & Peripheral Registers (STM32F103RB, GPIOA)

This document explains how the STM32F103RB configures and drives GPIO pins. It maps register-level details of RCC + GPIOA to the LED blink implemented in this repository.

---

## 1. Peripheral Addressing

All peripherals reside in **Peripheral region**: `0x4000_0000 – 0x5FFF_FFFF`.

- **APB2 bus base:** `0x4001_0000`  
- **RCC base:** `0x4002_1000`  
- **GPIOA base:** `0x4001_0800`  

Thus:
```c
#define RCC_BASE   0x40021000UL
#define GPIOA_BASE 0x40010800UL
```
## 2. RCC — Clock Control
Before using any peripheral, its clock must be enabled.

Register: `RCC_APB2ENR @ RCC_BASE + 0x18`

Bit 2 (IOPAEN): Enable clock for GPIOA.

Example:

```c
RCC_APB2ENR |= (1 << 2);   // IOPAEN = 1
```
Without this, GPIOA registers remain inaccessible (read as 0).

## 3. GPIOA Configuration Registers
Each GPIO port has Control Registers and Data Registers.

#### 3.1 GPIOx_CRL / GPIOx_CRH
`CRL` → config for pins 0–7.

`CRH` → config for pins 8–15.

Each pin uses 4 bits:

`MODE[1:0]` → output speed (00 = input).

`CNF[1:0]` → function (00 = GP push-pull, 01 = GP open-drain, 10 = AF push-pull, 11 = AF open-drain).

For PA5 (LED):

```c
GPIOA_CRL &= ~(0xF << 20);  // Clear 4 bits for pin 5
GPIOA_CRL |=  (0x2 << 20);  // MODE=10 (2 MHz), CNF=00 (GP push-pull)
```
Resulting config: Output, push-pull, 2 MHz drive.

#### 3.2 GPIOx_ODR
Output Data Register (`GPIOA_ODR @ offset 0x0C`).

Writing 1 → sets pin high.

Writing 0 → sets pin low.

Toggling:

```c
GPIOA_ODR ^= (1 << 5);  // Flip PA5 state
```
#### 3.3 GPIOx_BSRR / BRR
Alternative atomic access:

`BSRR`: write 1 to set pin, write 1 in high half to reset pin.

`BRR`: write 1 to clear pin.

This prevents race conditions in multi-bit writes, but `ODR` suffices for single-pin toggles.

## 4. LED Circuit Context
On Nucleo-F103RB, user LED (LD2) is connected to PA5.

LED is active-high (ON when `PA5 = 1`).

No pull-up/down needed for output mode.

## 5. Example Flow in Code
Enable Clock:

```c
RCC_APB2ENR |= RCC_IOPAEN;
```
Configure Pin:

```c
GPIOA_CRL &= ~(0xF << 20);
GPIOA_CRL |=  (0x2 << 20);
```
Blink Loop:
```c
while (1) {
    GPIOA_ODR ^= (1 << 5);  // toggle
    delay(500000);
}
```
## 6. Debugging Registers
Using GDB + OpenOCD:

Inspect RCC:

```cpp
x/1wx 0x40021018   // RCC_APB2ENR
```
Inspect GPIOA config:

```cpp
x/1wx 0x40010800   // GPIOA_CRL
x/1wx 0x4001080C   // GPIOA_ODR
```
## 7. Key Takeaways
Peripheral access = simple memory-mapped I/O.

`RCC` gating is mandatory; registers are inert without clock.

Each GPIO pin has 4-bit config: `[CNF + MODE]`.

`ODR/BSRR/BRR` provide different access semantics.

Minimal toggle sequence = enable clock → configure pin → write ODR.

