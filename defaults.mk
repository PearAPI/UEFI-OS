CC = gcc
LD = ld

OBJCOPY = objcopy
OBJDUMP = objdump

LINKER_SCRIPT = vendor/gnu-efi/gnuefi/elf_x86_64_efi.lds

LIB_DIRECTORIES = -Lvendor/gnu-efi/x86_64/gnuefi -Lvendor/gnu-efi/x86_64/lib
LIBRARIES = -lgnuefi -lefi

INCLUDES = -Ivendor/gnu-efi/inc -Ivendor/gnu-efi/inc/x86_64

CRT0_LIB = vendor/gnu-efi/x86_64/gnuefi/crt0-efi-x86_64.o

CCFLAGS = -c -g -O0 -fpic -ffreestanding -fno-stack-protector -fno-stack-check -fshort-wchar -mno-red-zone -maccumulate-outgoing-args $(INCLUDES)
LDFLAGS = --verbose -shared -Bsymbolic -nostdlib -T $(LINKER_SCRIPT) $(LIB_DIRECTORIES) $(LIBRARIES) $(CRT0_LIB)

TARGET = kernel.so
TARGET_EFI = kernel.efi
TARGET_IMG = image.img
TARGET_ISO = image.iso