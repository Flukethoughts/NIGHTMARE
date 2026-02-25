# Hardware Modifications

Documentation of all hardware modifications made to the NIGHTMARE RatRig V-Core 4 Hybrid 500mm 3D printer.

## Custom Hybrid CoreXY 4WD Kinematics

- **What:** Custom `hybrid_corexy_4wd.py` kinematics module replacing stock Klipper's `hybrid_corexy`
- **Why:** Stock Klipper lacks two features V-Core 4 Hybrid needs: `inverted: true` for belt routing and multi-stepper X rail (AWD with stepper_x + stepper_x1)
- **Origin:** Originally `ratos_hybrid_corexy.py` from RatOS. Renamed and fixed for current Klipper/Kalico API
- **Location:** `klipper_extras/hybrid_corexy_4wd.py`, symlinked into Klipper's kinematics directory
- **Maintenance:** Must re-run `install_kinematics.sh` after Klipper updates (symlinks get overwritten)
- **API changes already handled:** Coord() takes list not \*args, set_position uses axis names, clear_homing_state replaces note_z_not_homed + \_motor_off, register_step_generator removed, DualCarriages constructor changed, raise config.error instead of self.error

## 56V High-Voltage XY System

- **What:** TMC5160T Pro drivers on 56V HV supply for all 4 XY motors
- **Why:** LDO Kraken V2 motors are rated 3.0A -- need TMC5160T Pro (not TMC2209) for high current and HV operation
- **Current:** 2.0A run_current (was RatOS default 1.1A which was wrong, then 1.6A, settled on 2.0A). Max rated 3.0A.
- **sense_resistor:** 0.075 ohm (TMC5160T Pro specific, NOT 0.11)
- **Config:** SpreadCycle only (stealthchop disabled), 64 microsteps, no interpolation

## Kalico Migration

- **What:** Switched from stock Klipper to Kalico (KalicoCrew/kalico fork)
- **Why:** Better STM32H723 support (520 MHz vs 400 MHz), neopixel timing fixes, CAN improvements
- **Impact:** All 3 MCUs reflashed, USB serial IDs changed from BTT custom strings to chip-ID based
- **Update manager:** Points to KalicoCrew/kalico.git, branch main

## EBB42 Bootloader Removal

- **What:** Removed corrupted Katapult (CanBoot) bootloader from EBB42
- **Why:** Bootloader was corrupted, caused boot failures. Flashing directly at 0x8000000 is more reliable.
- **Impact:** Firmware flashed at offset 0x8000000 (no 8KiB bootloader). 1200-baud DFU trick still works.
- **Fallback:** Physical BOOT0 jumper + reset if 1200-baud trick fails

## Beacon RevH Probe Setup

- **What:** Beacon RevH USB probe with custom y_offset
- **Why:** Stock Beacon y_offset doesn't account for V-Core 4 toolhead geometry
- **Custom offset:** y_offset: 27.3 (measured for this specific toolhead)
- **Modes:** Contact mode for Z homing, scan mode for bed mesh

## Orbiter 2 Smart Sensor Pin Mapping

- **What:** Corrected pin assignment for filament sensor on EBB42 I2C header
- **Issue:** BTT sample config shows PB4=FS, PB3=FTU but RatRig wiring is SWAPPED: PB3=FS (filament switch), PB4=FTU (tangle/unload button)
- **Connection:** EBB42 I2C header (4-pin Dupont), NOT the BLTouch connector
- **Pull-up:** PB3 requires `^` pull-up for filament detection

## Status LED System

- **What:** 20x WS2812B LEDs (4x 5-LED modules) driven from Octopus Pro PB10
- **Level shifter:** SN74AHCT125N (3.3V to 5V, unidirectional). Pin 1 (1OE) to GND, Pin 2 (1A) to PB10, Pin 3 (1Y) to LED DIN. 10nF ceramic bypass cap on VCC.
- **Power:** Dedicated 5V buck converter (shared with Orange Pi, 10A capacity)
- **Failed approach:** Orange Pi SPI was tried first but had persistent color corruption on 8-LED modules at all speeds and encodings (4-bit and 8-bit). BSS138/TXB0104/TXS0108E bi-directional level shifters also failed (too slow for 800kHz neopixel protocol).
- **Software:** klipper-led_effect plugin for animations. Symlinked with absolute path (relative paths break on branch switches).

## Therm^2 Motor Temperature Monitoring

- **What:** STM32F042-based thermistor expansion board monitoring all 4 Kraken motor temperatures
- **Thermistors:** 100K NTC (NOT PT1000) on th4-th7 inputs
- **Mapping:** th4=MOTOR0 (stepper_x), th5=MOTOR1 (stepper_y), th6=MOTOR3 (stepper_y1), th7=MOTOR4 (stepper_x1)
- **USB quirk:** Uses PA9/PA10 USB pin remap (NOT standard PA11/PA12). Must set CONFIG_STM32_USB_PA11_PA12_REMAP=y in firmware config.
- **Flash quirk:** 1200-baud DFU trick doesn't work. Requires physical BOOT0 button. Only 32KB flash (ADC-only build).

## Camera Overlay with Hardware Encoding

- **What:** Live camera feed with printer status overlay, hardware H.264 encoding, HLS streaming
- **Pipeline:** ustreamer (4K MJPEG) -> ffmpeg (SW decode + drawtext overlays + h264_rkmpp HW encode) -> HLS segments -> Python HTTP server
- **Why HLS not MJPEG:** rkmpp MJPEG encoder is broken (no byte-stuffing, missing EOI markers). SW MJPEG costs ~500% CPU at 4K. h264_rkmpp + HLS uses ~159% CPU.
- **Software:** jellyfin-ffmpeg 7.1.3 for rkmpp support
- **Latency:** ~2-3s (HLS minimum floor with aggressive tuning)

## Controller Fan Configuration

- **FAN2 (PD12):** Enclosure intake fan, always-on via output_pin (24V on HV stepper driver rail)
- **FAN3 (PD13):** Controller/electronics fan, auto-activates with stepper activity, 60s idle timeout, 0.4 idle speed
- **FAN5 (PE5):** Enclosure exhaust fan, always-on via output_pin (24V on HV stepper driver rail)

## Dir Pin Inversions

Critical for V-Core 4 Hybrid belt routing -- wrong inversions cause axis to move backwards:

| Stepper | Inverted? | Notes |
|---------|-----------|-------|
| stepper_x | No | |
| stepper_x1 | No | |
| stepper_y | Yes (`!y_dir_pin`) | |
| stepper_y1 | No | |
| stepper_z | Yes (`!z0_dir_pin`) | All Z motors inverted |
| stepper_z1 | Yes (`!z1_dir_pin`) | |
| stepper_z2 | Yes (`!z2_dir_pin`) | |
