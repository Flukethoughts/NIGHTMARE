# Changelog

Chronological log of modifications to the NIGHTMARE printer.

## February 2026

### RatOS Removal and Standalone Config
- Built complete standalone Klipper configuration from scratch
- Created modular folder structure (hardware/, motion/, macros/, config/, scripts/)
- Extracted all correct pin mappings from RatOS defaults and overrides
- Created custom `hybrid_corexy_4wd.py` kinematics module (renamed from `ratos_hybrid_corexy.py`)
- Deployed to printer, verified all hardware functional
- Cleaned config directory from ~2.8GB to ~19MB

### Kinematics API Fix
- Klipper update broke `hybrid_corexy_4wd.py` with multiple API changes
- Fixed: Coord() takes list not *args with e= keyword
- Fixed: set_position() uses axis names not indices
- Fixed: clear_homing_state() replaces note_z_not_homed() + _motor_off()
- Fixed: register_step_generator() removed
- Fixed: DualCarriages constructor changed
- Fixed: raise config.error() instead of raise self.error()
- Created `install_kinematics.sh` for post-update restoration

### gcode_shell_command Recovery
- Symlink pointed to deleted RatOS directory
- Recovered module from backup, installed to `/home/pi/klipper_extras/`
- Added to `install_kinematics.sh` installer

### Motor Current Optimization
- XY run_current: 1.1A (RatOS wrong) -> 1.6A -> 2.0A
- Kraken V2 rated 3.0A, running at 67% with TMC5160T Pro on 56V

### Calibration Infrastructure
- CoreXY belt tension macro with diagonal axes (AXIS=1,1 and AXIS=1,-1)
- Hybrid Y belt tension macro with position-biased testing (X=30 vs X=470)
- Shell scripts for inline graph display in Mainsail console
- Full calibration macro suite: PID, probe, speed test, pressure advance, cold pull, corner tests

### MCU Firmware Reflash to Kalico
- Migrated all 3 MCUs from stock Klipper v0.12.0-316 to Kalico v0.12.0-786 via DFU
- Octopus Pro H723: Now runs at 520 MHz (was 400 MHz)
- EBB42 v1.2: Removed corrupted Katapult bootloader, flashing at 0x8000000
- Therm^2: Discovered USB pin remap quirk (PA9/PA10), minimal ADC-only build for 32KB flash
- USB serial IDs changed from BTT custom to chip-ID based strings

### Orbiter 2 Smart Sensor
- Configured on EBB42 I2C header (4-pin Dupont)
- Discovered RatRig wiring swaps BTT default pin order: PB3=FS, PB4=FTU
- Added filament runout pause and tangle detection macros

### Status LED System
- 20x WS2812B (4x 5-LED modules), GRB color order, Octopus PB10
- SN74AHCT125N level shifter (3.3V to 5V, unidirectional)
- Orange Pi SPI approach tried and abandoned (color corruption at all speeds)
- Built animated LED effects: rainbow idle, pulse breathing, blue sweep homing, panic flash error, solid green complete
- Integrated into START_PRINT, END_PRINT, PAUSE, RESUME workflow
- Rainbow auto-starts on boot via delayed_gcode

### Camera Overlay System
- ustreamer for 4K MJPEG capture
- ffmpeg with h264_rkmpp hardware encoding to HLS
- Python HTTP server with hls.js player
- Overlay shows: printer status, heater temps, motor temps, system temps, motion info, filename, progress
- Tuned HLS latency from ~7-10s down to ~2-3s

### Hybrid Y Belt Tension Testing
- Added `MEASURE_HYBRID_Y_BELT_TENSION` macro
- Position-biased approach: toolhead at X extremes to bias accelerometer toward each Y rail
- Added `generate_y_belt_graph.sh` for comparison graph

### Input Shaper Recalibration
- Calibrated with belts at 87/84 Hz target tension
- MZV X=68.2 Hz, Y=48.8 Hz
- Max recommended accel: X=13,700 mm/s^2, Y=7,000 mm/s^2

### Branding
- NIGHTMARE logo SVG (purple/magenta gradient)
- Purple favicons
- Vibrant 80s theme in Mainsail

### go2rtc WebRTC Migration (Feb 24)
- Replaced HLS streaming with go2rtc v1.9.14 + WebRTC
- Downgraded capture from 4K to 1080p (CPU savings, WebRTC doesn't need 4K)
- ffmpeg outputs raw H.264 to stdout, go2rtc reads via exec source
- On-demand streaming: ffmpeg only runs when viewer connects (0% CPU idle)
- CPU dropped from ~159% (HLS always-on) to ~47% (on-demand), system idle ~86%
- Latency dropped from ~2-3s (HLS floor) to ~200-500ms (WebRTC)
- Fluidd webcam configured as `webrtc-go2rtc` service type

### Fan Configuration
- FAN2 (PD12): Enclosure intake fan, always-on
- FAN3 (PD13): Controller fan, auto with steppers, 60s idle timeout
- Original PD12 "no voltage" issue was a connection problem, not dead MOSFET

## Planned

### 25T Pulley Upgrade
- Replacing all 20T motor pulleys with Gates genuine 25T
- All toothed and smooth idlers being replaced with Gates genuine
- New Gates LL-2GT-E EPDM belts
- Config changes needed: rotation_distance 40 -> 50, input shaper recalibration
- 25% more speed headroom at same motor RPM

### BRS-AWD V2.2 CNC Conversion
- [BRS-AWD DRIVE](https://store.brs-engineering.com/products/brs-awd-drive-v21) CoreXY AWD conversion to replace hybrid kinematics
- Waiting on CNC machined version (printed v2.2b is available, CNC not yet released)
- Eliminates custom `hybrid_corexy_4wd` kinematics module — uses stock `corexy` kinematics
- Integrated coaxial belt tensioner, compatible with V-Core 4.x, no frame modifications
- Combined with 25T pulley upgrade: rotation_distance 40 → 50, full input shaper recalibration required
