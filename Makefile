include defaults.mk

KERNEL_SRC = src/
KERNEL_OBJ = obj/

SRC = $(shell find $(KERNEL_SRC) -name '*.c')
HEADERS = $(shell find $(KERNEL_SRC) -name '*.h')
OBJ = $(patsubst $(KERNEL_SRC)%.c,$(KERNEL_OBJ)%.o,$(SRC))

.PHONY: all
all: $(TARGET) $(TARGET_EFI) $(TARGET_IMG) $(TARGET_ISO)


.PHONY: folders
folders:
	mkdir -p $(KERNEL_OBJ)

.PHONY: clean
clean:
	rm -rf $(KERNEL_OBJ)
	rm -f $(TARGET)
	rm -f $(TARGET_EFI)
	rm -f $(TARGET_IMG)
	rm -f $(TARGET_ISO)

.PHONY: gnuefi
gnuefi:
	$(MAKE) -C vendor/gnu-efi

.PHONY: run
run: $(TARGET_IMG)
	qemu-system-x86_64 -net none -L /usr/share/ovmf/x64/ -pflash OVMF.fd -cdrom $(TARGET_ISO)

$(KERNEL_OBJ)%.o: $(KERNEL_SRC)%.c $(HEADERS) folders
	$(CC) $(CCFLAGS) $(HEADERS) -o $@ $<

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) -o $@ $^

$(TARGET_EFI): $(OBJ)
	objcopy -j .text -j .sdata -j .data -j .rodata -j .dynamic -j .dynsym  -j .rel -j .rela -j .rel.* -j .rela.* -j .reloc --target efi-app-x86_64 --subsystem=10 $^ $@

$(TARGET_IMG): $(TARGET_EFI)
	dd if=/dev/zero of=$@ bs=512 count=1440
	mformat -i $@ -f 1440 ::
	mmd -i $@ ::/EFI
	mmd -i $@ ::/EFI/BOOT
	mcopy -i $@ $^ ::/EFI/BOOT/BOOTX64.EFI

$(TARGET_ISO): $(TARGET_IMG)
	mkdir -p iso
	cp $^ iso/
	xorriso -as mkisofs -R -f -e $(TARGET_IMG) -no-emul-boot -o $@ iso/
	rm -rf iso
