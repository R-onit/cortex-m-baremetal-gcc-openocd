# Make is like, we are preparing the pipeline to workflow 
#directories
BUILD = build
STARTUP = startup
#lets begin with creating variables 
#these are compiler and flags 
CC = arm-none-eabi-gcc
CFLAGS = -mcpu=cortex-m3 -mthumb
CFLAGS += -MMD -MP # this syntax updates our CFLAGS which means it adds to the previous CFLAGS
#MEANS APPEND TO EXISTING VARIABLE 

CFLAGS += -Iinclude
#this tells compiler to look in include/

LDFLAGS = -T linker.ld -nostartfiles

#variables for files
OBJ = $(BUILD)/main.o $(BUILD)/startup.o
TARGET = $(BUILD)/firmware.elf
BIN = $(BUILD)/firmware.bin
# Now all generated files go to build/, and your src/ folder stays clean.


#here the firmware.bin file is the main depencency which if changed all the main process should reexected , means make should re used so we have to make some sort of global dependency 
all:$(BIN) #THIS IS HOW WE USE THE VARIABLES 

#FIRST LETS COMPILE C FILE , WHICH WOULD TURN IT INTO ASSEMBLY SO THAT BOTH THE ASSEMBLY FILES WOULD BE NEXT TURNED INTO BINARY FILES
$(BUILD)/%.o:src/%.c # automatically prepares an build directory too
	@mkdir -p $(dir $@)  
	$(CC) -c $(CFLAGS) $< -o $@ 
#here main.c is dependency for the main.o file , which means this recipie would run only if their is an change in main.c file 


#now lets turn the assembly file into obj files so that we would have only object files which would be further used in linkinof files then turning into .elf files 
$(BUILD)/startup.o:startup/startup.s
		mkdir -p $(BUILD)
	$(CC) -c $(CFLAGS) $< -o $@

# now lets link all the object files 
$(TARGET):$(OBJ)
	$(CC) $(OBJ) $(LDFLAGS) -o $(TARGET)

#now we are having an elf file lets convert it into .bin file so that we could flash code 
$(BIN):$(TARGET)
	arm-none-eabi-objcopy -O binary $< $@

#now lets show size by running the .elf code 
run: $(TARGET)
	arm-none-eabi-size $<

#now lets implement an clean up so that the binaries and elf files gets deleted 
clean:
	rm -rf $(BUILD)

# .PHONY is used for the non-file targets like all clean run :used to prevent weird behaviour if run/clean/all ever becomes file.
.PHONY: all clean run

-include $(OBJ:.o=.d)  # by this we say that .o and .d are same /for the use of autodependency generation 

# THESE ARE THE COMMANDS WE USED 
# main: main.c main.o
# 	arm-none-eabi-gcc -c -mcpu=cortex-m3 -mthumb main.c -o main.o
# 	arm-none-eabi-gcc -c -mcpu=cortex-m3 -mthumb startup.s -o startup.o
# 	arm-none-eabi-gcc main.o startup.o -T linker.ld -nostartfiles -o firmware.elf
# 	arm-none-eabi-objcopy -O binary firmware.elf firmware.bin

# run:firmware.elf
# 	arm-none-eabi-size firmware.elf


#Special Makefile Symbols ($@, $<, etc.)-- called as automatic variables, placeholders used in recipes(commands)
#  Symbol			Meaning (Think Like This)
#	$@				Target (the thing being built)
#	$<				First prerequisite (first file in thedependency	list)
#	$^				All prerequisites (space-separated)
#	$?				Only updated prerequisites


#Mental Model: 5 Core Stages (Total Control for Embedded Devs)
# | Stage                | Tool / Output                        | Description                                            |
# | -------------------- | ------------------------------------ | ------------------------------------------------------ |
# | 1. **Preprocessing** | `.i` file (C with includes expanded) | `#includes` and `#defines` handled                     |
# | 2. **Compilation**   | `.s` file (Assembly)                 | C is compiled into assembly                            |
# | 3. **Assembly**      | `.o` file (Object code)              | Assembly is turned into raw machine instructions       |
# | 4. **Linking**       | `.elf` (Executable + symbols)        | Multiple `.o` files and a linker script form one image |
# | 5. **Objcopy**       | `.bin` or `.hex` (Raw Flash Image)   | Removes symbols/debug info, leaves only raw bytes      |


# Auto Header Dependency Tracking (.d files)

#So this is the line that connects GCC's generated .d files → Make's internal tracking.
# if we are including headers in the c files , if the headers content change ,the the main.o made out of main.c should also change right .if  we run make the make doesnt see any change in the main.c so it wouldnt rebuilt main.o . hence , we use auto generated .d files to do these stuffs .

# this can be done using 2 flags , so now make would understand if config.h changes , it need to build main.o
# -MMD --> create .d files for each .c file
# -MP ---> adds dummy rules so make doesnt break if headers are deleted 


# now how would we add these flags as we have made the CFLAGS before only,


# make -j$(nproc)
# This tells Make:
# “Run as many jobs in parallel as I have CPU cores.”