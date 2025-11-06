#lets begin with creating variables 

#directories
BUILD = build
STARTUP = startup

#these are compiler and flags 
CC = arm-none-eabi-gcc
CFLAGS = -mcpu=cortex-m3 -mthumb -g
CFLAGS += -MMD -MP # this syntax updates our CFLAGS which means it adds to the previous CFLAGS
#MEANS APPEND TO EXISTING VARIABLE 

CFLAGS += -Iinclude

LDFLAGS = -T linker.ld -nostartfiles

#variables for files ,using BUILD to structurise all generate files to get into single place 
OBJ = $(BUILD)/main.o $(BUILD)/startup.o
TARGET = $(BUILD)/firmware.elf
BIN = $(BUILD)/firmware.bin

all:$(BIN) #THIS IS HOW WE USE THE VARIABLES 

#All C file converted to object file
$(BUILD)/%.o:src/%.c  # automatically prepares an build directory too
	@mkdir -p $(dir $@) 
	$(CC) -c $(CFLAGS) $< -o $@ 
#here main.c is dependency for the main.o file , which means this recipie would run only if their is an change in main.c file 

#Assembly to Object file
$(BUILD)/startup.o:startup/startup.s
	@mkdir -p $(dir $@)
	$(CC) -c $(CFLAGS) $< -o $@

#linking all Object files 
$(TARGET):$(OBJ)
	$(CC) $(OBJ) $(LDFLAGS) -o $(TARGET)

#.elf file to binary file 
$(BIN):$(TARGET)
	arm-none-eabi-objcopy -O binary $< $@

# debug: $(TARGET)
# 	@echo "Starting QEMU..."
# 	@qemu-system-arm -M stm32vldiscovery -kernel $(TARGET) -nographic -S -s &
# 	@sleep 2
# 	@echo "Starting GDB..."
# 	@gdb-multiarch $(TARGET)


# GDB debugging over OpenOCD
gdb: $(TARGET)	
	openocd -f interface/stlink.cfg -f target/stm32f1x.cfg &
	sleep 2
	@echo "Connecting GDB..."
	@gdb-multiarch $(TARGET) -ex "target remote :3333"

flash: $(TARGET)
	@echo "Starting OpenOCD GDB server..."
	openocd -f interface/stlink.cfg -f target/stm32f1x.cfg \
	-c "program $(TARGET) verify reset exit"


#run .elf code 
run: $(TARGET)
	arm-none-eabi-size $<

#clean 
clean:
	rm -rf $(BUILD)

# .PHONY is used for the non-file targets like all clean run :used to prevent weird behaviour if run/clean/all ever becomes file.
.PHONY: all clean run

-include $(OBJ:.o=.d)  # by this we say that .o and .d are same /for the use of autodependency generation 
