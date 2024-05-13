CHIP=esp8266
SERIAL_PORT=/dev/cu.usbserial-120
BAUD_RATE=115200

SRC=$(PWD)/src
USER_CONFIG=$(SRC)/config/user_config.h
USER_MODULES=$(SRC)/config/user_modules.h
U8G2_DISPLAYS=$(SRC)/config/u8g2_displays.h
WIFI_MONITOR=$(SRC)/config/wifi_monitor.c

IMAGE_NAME=asdasd
FILES_LIST=app.lst
BUILD_TYPE=float

debug:
	sudo cu -s $(BAUD_RATE) -l $(SERIAL_PORT)

copy-config:
	rm -f $(PWD)/nodemcu-firmware/app/include/user_config.h
	rm -f $(PWD)/nodemcu-firmware/app/include/user_modules.h
	rm -f $(PWD)/nodemcu-firmware/app/include/u8g2_displays.h
	rm -f $(PWD)/nodemcu-firmware/app/modules/wifi_monitor.c
	cp $(USER_CONFIG) $(PWD)/nodemcu-firmware/app/include/user_config.h
	cp $(USER_MODULES) $(PWD)/nodemcu-firmware/app/include/user_modules.h
	cp $(U8G2_DISPLAYS) $(PWD)/nodemcu-firmware/app/include/u8g2_displays.h
	cp $(WIFI_MONITOR) $(PWD)/nodemcu-firmware/app/modules/wifi_monitor.c

build-firmware: copy-config
	docker run --rm \
		-ti \
		-e "IMAGE_NAME=$(IMAGE_NAME)" \
		-v  $(PWD)/nodemcu-firmware:/opt/nodemcu-firmware \
		marcelstoer/nodemcu-build \
		build

flash-firmware:
	esptool.py --port $(SERIAL_PORT) erase_flash
	esptool.py --port $(SERIAL_PORT) write_flash -fm dio 0x00000 $(PWD)/nodemcu-firmware/bin/nodemcu_$(BUILD_TYPE)_$(IMAGE_NAME).bin

firmware: build-firmware flash-firmware

build-lfs-image:
	docker run --rm \
		-ti \
		-e "IMAGE_NAME=$(IMAGE_NAME)" \
		-v $(PWD)/nodemcu-firmware:/opt/nodemcu-firmware \
		-v $(SRC):/opt/lua \
		marcelstoer/nodemcu-build \
		lfs-image $(FILES_LIST)

upload-image: build-lfs-image
	nodemcu-uploader --port $(SERIAL_PORT) upload \
		$(SRC)/LFS_$(BUILD_TYPE)_$(IMAGE_NAME).img:flash.img \
		$(SRC)/init.lua:init.lua

image: build-lfs-image upload-image

clone-nodemcu-firmware:
	git clone --recurse-submodules git@github.com:nodemcu/nodemcu-firmware.git
