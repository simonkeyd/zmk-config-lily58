MAKEFLAGS += -j2

ZMK_DIR ?= $(HOME)/zmk
WEST_DIR ?= $(ZMK_DIR)/.west
CONFIG_DIR ?= $(CURDIR)
BUILD_DIR ?= $(CONFIG_DIR)/build
MOUNT_POINT = /mnt/usb

LEFT_SHIELD = lily58_left
RIGHT_SHIELD = lily58_right
BOARD = nice_nano_v2
EXTRAS = nice_view_adapter nice_view

.PHONY: all left right clean pristine check-west show-firmware deploy-left deploy-right update-zmk

all: left right

check-west: $(ZMK_DIR) $(WEST_DIR)
ifeq (, $(shell command -v west))
$(error 'west' command not found.)
endif

$(ZMK_DIR):
	git clone https://github.com/zmkfirmware/zmk.git $(ZMK_DIR)

$(WEST_DIR):
	cd $(ZMK_DIR) && west init -l app/
	cd $(ZMK_DIR) && west update
	cd $(ZMK_DIR) && west zephyr-export
	cd $(ZMK_DIR) && pip install -r zephyr/scripts/requirements-base.txt

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

left: check-west $(BUILD_DIR)
	@echo "*** Building left side firmware..."
	cd $(ZMK_DIR); west build -s $(ZMK_DIR)/app -d $(BUILD_DIR)/left -b $(BOARD) -- \
		-DSHIELD="$(LEFT_SHIELD) $(EXTRAS)" \
		-DZMK_CONFIG=$(CONFIG_DIR)/config \

right: check-west $(BUILD_DIR)
	@echo "*** Building right side firmware..."
	cd $(ZMK_DIR); west build -s $(ZMK_DIR)/app -d $(BUILD_DIR)/right -b $(BOARD) -- \
		-DSHIELD="$(RIGHT_SHIELD) $(EXTRAS)" \
		-DZMK_CONFIG=$(CONFIG_DIR)/config \

clean:
	rm -rf $(BUILD_DIR)

pristine: clean
	rm -rf $(ZMK_DIR)

# Helper target to show firmware locations
show-firmware:
	@echo "*** Left firmware: $(BUILD_DIR)/left/zephyr/zmk.uf2"
	@echo "*** Right firmware: $(BUILD_DIR)/right/zephyr/zmk.uf2"


define mount_and_copy
@echo "*** Please put the $(1) side nice!nano into bootloader mode (double-tap reset button)"
@echo -n "*** Waiting for USB device..."
@while ! sudo fdisk -l | grep -q "nRF UF2"; do sleep 1; echo -n .; done
@echo -e "\n*** Found nice!nano device"
@export DEV_PATH=$$(sudo fdisk -l | grep -B1 "nRF UF2" | grep -o '/dev/s[a-z]\+') && \
	sudo mount $$DEV_PATH $(MOUNT_POINT) && \
	sudo cp "$(BUILD_DIR)/$(1)/zephyr/zmk.uf2" "$(MOUNT_POINT)/" && \
	echo "*** Firmware copied successfully" && \
	sudo umount $(MOUNT_POINT)
endef

$(MOUNT_POINT):
	@sudo mkdir -p /mnt/usb

deploy-left: $(MOUNT_POINT)
	$(call mount_and_copy,left)

deploy-right: $(MOUNT_POINT)
	$(call mount_and_copy,right)
