# MCU Firmware Guide

All MCU boards run Kalico v0.12.0-786 (reflashed Feb 2026 from stock Klipper). Kalico is a Klipper fork by KalicoCrew with improvements for STM32H7, neopixels, and CAN.

## Board Summary

| Board | Chip | Clock | Flash Offset | DFU Entry Method |
|-------|------|-------|-------------|------------------|
| Octopus Pro H723 | STM32H723 | 520 MHz (25 MHz xtal) | 0x8020000 | 1200-baud trick |
| EBB42 v1.2 | STM32G0B1 | 64 MHz (8 MHz xtal) | 0x8000000 | 1200-baud trick |
| Therm^2 | STM32F042 | Internal 48 MHz | 0x8000000 | Physical BOOT0 button |
| Beacon RevH | Custom | N/A | N/A | beacon_update (separate) |

## General Flash Procedure

All boards flash via DFU using the STM32 system ROM bootloader. No SD card needed.

```bash
# 1. Stop Klipper
curl -s -X POST 'http://YOUR_PRINTER_IP:7125/machine/services/stop?service=klipper'

# 2. SSH to printer
ssh user@YOUR_PRINTER_IP

# 3. Build firmware (as the klipper service user)
cd ~/klipper
# Write .config (see board-specific sections below)
make olddefconfig
make clean && make

# 4. Flash (see board-specific sections)
# 5. Start Klipper
curl -s -X POST 'http://YOUR_PRINTER_IP:7125/machine/services/start?service=klipper'
```

## Octopus Pro H723

Kconfig (.config):
```
CONFIG_LOW_LEVEL_OPTIONS=y
CONFIG_MACH_STM32=y
CONFIG_MACH_STM32H723=y
CONFIG_STM32_FLASH_START_20000=y
CONFIG_STM32_CLOCK_REF_25M=y
CONFIG_STM32_USB_PA11_PA12=y
```

Flash:
```bash
# Enter DFU via 1200-baud trick
stty -F /dev/serial/by-id/usb-Klipper_stm32h723xx_YOUR_SERIAL-if00 1200
sleep 2

# Find DFU device
lsusb | grep DFU   # Note bus-port (e.g. 5-1)

# Flash (128KiB bootloader offset)
sudo dfu-util -p BUS-PORT -R -a 0 -s 0x8020000:leave -D out/klipper.bin
# Board auto-resets (~15 seconds)
```

## EBB42 v1.2

**IMPORTANT:** No bootloader. Original Katapult bootloader was corrupted and removed. Firmware is flashed directly at 0x8000000.

Kconfig (.config):
```
CONFIG_LOW_LEVEL_OPTIONS=y
CONFIG_MACH_STM32=y
CONFIG_MACH_STM32G0B1=y
CONFIG_STM32_FLASH_START_0000=y
CONFIG_STM32_CLOCK_REF_8M=y
CONFIG_STM32_USB_PA11_PA12=y
```

Flash:
```bash
# Enter DFU via 1200-baud trick
stty -F /dev/serial/by-id/usb-Klipper_stm32g0b1xx_YOUR_SERIAL-if00 1200
sleep 2
# If 1200-baud doesn't work: set BOOT0 jumper, press reset, then remove jumper after flash

lsusb | grep DFU

# Flash (no bootloader = 0x8000000)
sudo dfu-util -p BUS-PORT -a 0 -s 0x8000000:leave -D out/klipper.bin
```

## Therm^2 (STM32F042)

**Critical quirks:**
- USB pin remap required: uses PA9/PA10, NOT PA11/PA12. Must set `CONFIG_STM32_USB_PA11_PA12_REMAP=y`
- 1200-baud DFU trick does NOT work. Must use physical BOOT0 button.
- dfu-util `-R` flag doesn't reliably reset this chip. Press physical reset after flash.
- Only 32KB flash. Must disable all features except ADC.

Kconfig (.config):
```
CONFIG_LOW_LEVEL_OPTIONS=y
CONFIG_MACH_STM32=y
CONFIG_MACH_STM32F042=y
CONFIG_STM32_FLASH_START_0000=y
CONFIG_STM32_CLOCK_REF_INTERNAL=y
CONFIG_STM32_USB_PA11_PA12_REMAP=y
CONFIG_WANT_GPIO_ADC=y
CONFIG_WANT_ADC=y
CONFIG_WANT_SPI=n
CONFIG_WANT_SOFTWARE_SPI=n
CONFIG_WANT_I2C=n
CONFIG_WANT_SOFTWARE_I2C=n
CONFIG_WANT_GPIO_SPI=n
CONFIG_WANT_GPIO_I2C=n
CONFIG_WANT_HARD_PWM=n
CONFIG_WANT_BUTTONS=n
CONFIG_WANT_TMCUART=n
CONFIG_WANT_NEOPIXEL=n
CONFIG_WANT_PULSE_COUNTER=n
CONFIG_WANT_ST7920=n
CONFIG_WANT_HD44780=n
CONFIG_WANT_ADXL345=n
CONFIG_WANT_LIS2DW=n
CONFIG_WANT_MPU9250=n
CONFIG_WANT_ICM20948=n
CONFIG_WANT_THERMOCOUPLE=n
CONFIG_WANT_HX71X=n
CONFIG_WANT_ADS1220=n
CONFIG_WANT_LDC1612=n
CONFIG_WANT_SENSOR_ANGLE=n
CONFIG_WANT_OPTIMIZE_SIZE=y
```

Flash:
```bash
# 1. Press and hold BOOT0 button on Therm^2 board
# 2. While holding BOOT0, press and release RESET
# 3. Release BOOT0 — board is now in DFU mode

lsusb | grep DFU   # Should show STM32 BOOTLOADER

# Flash (no -R flag)
sudo dfu-util -a 0 -s 0x8000000:leave -D out/klipper.bin

# 4. Press physical RESET button to boot new firmware
ls /dev/serial/by-id/ | grep stm32f042   # Verify enumeration
```

## After Flashing

If USB serial IDs change:
1. Update serial paths in hardware/mcu.cfg, hardware/toolboard.cfg, hardware/therm2.cfg
2. Find new serials: `ls /dev/serial/by-id/`
3. Restart Klipper

## Verification
```bash
# Start Klipper
curl -s -X POST 'http://YOUR_PRINTER_IP:7125/machine/services/start?service=klipper'

# Check MCU versions in log
grep 'Loaded MCU' ~/printer_data/logs/klippy.log | tail -5

# Check printer state
curl -s 'http://YOUR_PRINTER_IP:7125/printer/info'
# state should be "ready"
```
