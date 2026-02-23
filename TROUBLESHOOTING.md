# Troubleshooting

Issues encountered during the NIGHTMARE build and their solutions.

## EBB42 Katapult Bootloader Corruption

**Symptom:** EBB42 fails to boot, doesn't enumerate on USB after power cycle.

**Cause:** The factory Katapult (CanBoot) 8KiB bootloader was corrupted.

**Solution:** Flash firmware directly at offset 0x8000000 (no bootloader). Enter DFU via 1200-baud trick or physical BOOT0 jumper. The board is more reliable without the bootloader.

## MCU Shutdown Recovery (1200-baud trick)

**Symptom:** MCU enters shutdown state, won't respond to commands.

**Solution:** Send 1200-baud signal to enter DFU mode:
```bash
stty -F /dev/serial/by-id/usb-Klipper_stm32xxxxx_YOUR_SERIAL-if00 1200
```
Wait 2 seconds, then flash or power cycle. Works for Octopus Pro and EBB42, NOT for Therm^2.

## Therm^2 USB Pin Remap

**Symptom:** Therm^2 board doesn't enumerate on USB after flashing.

**Cause:** The STM32F042 on the Therm^2 board uses PA9/PA10 for USB, NOT the standard PA11/PA12.

**Solution:** Set `CONFIG_STM32_USB_PA11_PA12_REMAP=y` in the firmware .config. This was discovered after multiple failed flash attempts.

## Therm^2 Flash Procedure

**Symptom:** 1200-baud DFU trick doesn't work, board won't enter DFU.

**Cause:** STM32F042 doesn't support the 1200-baud DFU entry method.

**Solution:** Use physical buttons:
1. Press and hold BOOT0
2. Press and release RESET
3. Release BOOT0
4. Flash with `dfu-util` (without `-R` flag)
5. Press RESET to boot new firmware

## rkmpp MJPEG Encoder Broken

**Symptom:** Camera overlay produces corrupt JPEG frames that browsers refuse to display.

**Cause:** The Rockchip MPP library's MJPEG encoder doesn't byte-stuff entropy data and omits EOI markers. This is a fundamental library bug, not fixable by rebuilding ffmpeg.

**Solution:** Use `h264_rkmpp` hardware encoder with HLS streaming instead of MJPEG. CPU usage: ~159% (vs ~500% for software MJPEG at 4K).

## Filament Sensor Pin Mapping

**Symptom:** Filament sensor always reads as "filament present" regardless of actual state.

**Cause:** BTT sample config shows PB4=FS, PB3=FTU, but RatRig wiring swaps these pins.

**Solution:** Configure PB3 as filament switch (with `^` pull-up) and PB4 as tangle/unload button. The original config had PB8 (BLTouch probe pin) which was constant high and not connected to the sensor.

## LED SPI Color Corruption

**Symptom:** WS2812B LEDs show wrong colors (red appears purple, green appears yellow) when driven via Orange Pi SPI.

**Cause:** Orange Pi SPI timing at all tested speeds (3.8MHz, 6.4MHz, 8MHz) doesn't produce clean enough waveforms for the strict WS2812B protocol. Both 4-bit and 8-bit SPI encoding methods failed. The 8-LED modules were particularly susceptible.

**Solution:** Drive LEDs from Octopus Pro PB10 through an SN74AHCT125N unidirectional level shifter (3.3V to 5V). Do NOT use bi-directional level shifters (BSS138, TXB0104, TXS0108E) — they're too slow for the 800kHz neopixel protocol.

## ffmpeg Dual-Output Segfault

**Symptom:** ffmpeg crashes (exit 139) when using two output streams with separate `-vf` flags.

**Cause:** jellyfin-ffmpeg 7.1.3 bug with multiple filter chains and multiple outputs.

**Solution:** Use single output only. For snapshots, proxy from ustreamer directly (no overlay on snapshots).

## Serial IDs Changed After Firmware Flash

**Symptom:** Klipper can't find MCUs after reflashing firmware.

**Cause:** USB serial IDs changed from BTT custom strings to chip-ID based strings after flashing via DFU (BTT custom strings were set by the factory bootloader).

**Solution:** Run `ls /dev/serial/by-id/` to find new serial paths. Update:
- `hardware/mcu.cfg`
- `hardware/toolboard.cfg`
- `hardware/therm2.cfg`
- Any udev rules

## Klipper Custom Kinematics Missing After Update

**Symptom:** Klipper fails to start with "Unknown kinematics" error after updating.

**Cause:** Klipper updates overwrite the symlinks to custom kinematics modules.

**Solution:** Re-run the installer:
```bash
bash /home/pi/klipper_extras/install_kinematics.sh
sudo systemctl restart klipper
```

## Motor Current Too Low (RatOS Default)

**Symptom:** XY motors skip steps, poor print quality, especially at high speeds.

**Cause:** RatOS default was 1.1A run_current for XY motors, which is far too low for LDO Kraken V2 motors rated at 3.0A.

**Solution:** Increase run_current in tmc.cfg. Current setting: 2.0A (67% of rated). With TMC5160T Pro on 56V, the motors have substantial torque headroom.
