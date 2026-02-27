# NIGHTMARE

RatRig V-Core 4 Hybrid 500mm with custom standalone Klipper/Kalico configuration. Built from scratch after removing RatOS. Features custom hybrid CoreXY 4WD kinematics, 56V high-voltage XY system, and extensive calibration tooling.

**Project started:** September 29, 2024 | **Current build cost:** ~$3,996 | **Build time:** ~44 hours manual labor ([full breakdown](docs/cost-breakdown.md))

## Hardware

| Component | Model | Details |
|-----------|-------|---------|
| Frame | RatRig V-Core 4 Hybrid 500mm | 500x500x500mm build volume |
| Host | [Orange Pi 5 Pro](http://www.orangepi.org/html/hardWare/computerAndMicrocontrollers/details/Orange-Pi-5-Pro.html) 16GB | Debian Bookworm, ARM64, 128GB NVMe |
| Mainboard | BTT Octopus Pro H723 V1.1 | STM32H723 MCU |
| Toolboard | BTT EBB42 v1.2 | STM32G0B1 MCU, CAN-over-USB |
| XY Motors (x4) | LDO-42STH60-3004AH "Kraken V2" | 3.0A rated, 56V HV, TMC5160T Pro |
| Z Motors (x3) | LDO-42STH48-2504AC | 2.5A rated, 24V, TMC2209 |
| Extruder | Orbiter 2 | LDO-36STH20-1004AHG motor |
| Hotend | Chube Air | 500C capable, 42mm meltzone, PT1000 |
| Probe | Beacon RevH | USB, contact + scan modes |
| Camera | 3DO USB Camera V2 | 1080p 30fps, hardware-encoded WebRTC overlay via go2rtc |
| Filament Sensor | Orbiter 2 Smart Sensor | Runout + tangle detection |
| Accelerometer | ADXL345 on EBB42 | For input shaper calibration |
| Status LEDs | 20x WS2812B | Animated effects via klipper-led_effect |
| Temp Expansion | Therm^2 | 4x motor thermistors (100K NTC) |

## Software Stack

- **Kalico** (Klipper fork by KalicoCrew) — firmware on all MCUs
- **Moonraker** — API server
- **Fluidd** — Web interface
- **KlipperScreen** — Touch display
- **klipper-led_effect** — LED animation engine

## Key Features

- Custom `hybrid_corexy_4wd` kinematics module (inverted belt routing + AWD)
- 56V high-voltage XY system with TMC5160T Pro drivers
- Adaptive bed mesh based on slicer print area
- Inline belt tension and input shaper graphs in console
- Camera overlay with hardware-encoded WebRTC streaming (h264_rkmpp + go2rtc)
- Status LED animations integrated into print workflow
- Comprehensive calibration macro suite

## Aftermarket Upgrades

Most stock printed parts have been replaced with machined aluminum and titanium components:

| Part | Source |
|------|--------|
| CNC Toolhead (plates, uprights, adapter) | [Mandala Rose Works](https://mandalaroseworks.com/collections/ratrig-cnc-toolhead) |
| CNC XY Joiners | [Mandala Rose Works](https://mandalaroseworks.com/products/ratrig-vcore-4-xy-joiners) |
| CNC Bed Support Arms | [Mandala Rose Works](https://mandalaroseworks.com/products/ratrig-bed-support-arms-for-4-0) |
| CNC Motor Mounts | [Mandala Rose Works](https://mandalaroseworks.com/products/ratrig-vcore4-machined-motor-mounts) |
| Mini Oldham Wobblers (x3) | [Mandala Rose Works](https://mandalaroseworks.com/products/mini-oldham-leadscrew-wobblers) |
| Titanium Gantry Tube 725mm (Clinch Nut) | [MIGL Fabrication](https://migl-fabrication.de/en/) |

Power: Mean Well UHP-350-55 (55V HV) + UHP-350-24 (24V) + 5V buck converter for host and LEDs.

See [docs/hardware-modifications.md](docs/hardware-modifications.md) for full details and [docs/cost-breakdown.md](docs/cost-breakdown.md) for the complete price breakdown.

## Repository Structure

```
config/           # Sanitized Klipper configuration files
  hardware/       # MCU, steppers, drivers, sensors, fans, LEDs
  motion/         # Kinematics, bed mesh, z-tilt, homing, input shaper
  macros/         # Print start/end, pause/resume, calibration, LED effects
  config/         # General settings
  scripts/        # Belt tension and shaper graph generators
klipper_extras/   # Custom kinematics module + installer
camera-overlay/   # Camera overlay system documentation
docs/             # Hardware mods, firmware, setup, calibration, wiring
```

## Quick Start

1. Clone this repository:
   ```bash
   git clone https://github.com/Flukethoughts/NIGHTMARE.git
   ```

2. Copy configs to your printer:
   ```bash
   scp -r NIGHTMARE/config/* user@YOUR_PRINTER_IP:~/printer_data/config/
   ```

3. Edit serial numbers in:
   - `config/hardware/mcu.cfg` — Octopus Pro serial
   - `config/hardware/toolboard.cfg` — EBB42 serial
   - `config/hardware/therm2.cfg` — Therm^2 serial
   - `config/hardware/probe.cfg` — Beacon serial

   Find your serials with: `ls /dev/serial/by-id/`

4. Install custom kinematics:
   ```bash
   cp klipper_extras/hybrid_corexy_4wd.py ~/klipper_extras/
   bash klipper_extras/install_kinematics.sh
   ```

5. Run initial calibration:
   ```
   BEACON_AUTO_CALIBRATE   # Probe calibration
   PID_CALIBRATE_HOTEND    # Hotend PID
   PID_CALIBRATE_BED       # Bed PID
   GENERATE_SHAPER_GRAPHS  # Input shaper
   ```

## Slicer Start G-code

PrusaSlicer / OrcaSlicer:
```
START_PRINT BED_TEMP=[first_layer_bed_temperature] EXTRUDER_TEMP=[first_layer_temperature] AREA_START={first_layer_print_min[0]},{first_layer_print_min[1]} AREA_END={first_layer_print_max[0]},{first_layer_print_max[1]}
```

End G-code:
```
END_PRINT
```

## Security Notice

All serial numbers, IP addresses, and credentials have been removed. See [SECURITY.md](SECURITY.md) for details on what was sanitized and how to keep your own config safe.

## Current Status

- All hardware operational
- Kalico v0.12.0-786 on all MCUs
- Input shaper calibrated (MZV X=68.2 Hz, Y=48.8 Hz)
- 25T pulley upgrade parts on order (will change rotation_distance from 40 to 50)
- CPAP part cooling ([Mammoth 3D](https://www.youtube.com/@mammoth-3D) design) — kit acquired, needs printed parts
- [BRS-AWD DRIVE v2.2](https://store.brs-engineering.com/products/brs-awd-drive-v21) CNC version pending release — will convert from hybrid to CoreXY AWD, eliminating the custom kinematics module

## Dependencies

- [Kalico](https://github.com/KalicoCrew/kalico) (Klipper fork)
- [Fluidd](https://github.com/fluidd-core/fluidd) — Web interface (replaced Mainsail — Vue 3, better theming, actively maintained)
- [klipper-led_effect](https://github.com/julianschill/klipper-led_effect) for LED animations
- [Beacon](https://github.com/beacon3d/beacon_klipper) for probe support
- [gcode_shell_command](https://github.com/dw-0/kiauh/blob/master/docs/gcode_shell_command.md) for inline graph generation

## License

This project is licensed under the GPL-3.0 License — see [LICENSE](LICENSE) for details.

Klipper/Kalico configs and the custom kinematics module are distributed under the same GPL-3.0 license as Klipper itself.

## Credits

- [RatRig](https://www.ratrig.com/) — V-Core 4 frame and design
- [KalicoCrew](https://github.com/KalicoCrew/kalico) — Kalico firmware
- [BigTreeTech](https://github.com/bigtreetech) — Octopus Pro, EBB42
- [LDO Motors](https://www.ldomotors.com/) — Kraken V2, Z motors, Orbiter 2
- [PD3D (PeeDee3D)](https://peedee3d.com/) — Kraken V2 motors, Gates pulleys, Therm^2 board
- [West3D](https://west3d.com/) — Gates GT2 EPDM belts
- [Fabreeko](https://www.fabreeko.com/) — TMC5160T Pro drivers
- [KB-3D](https://kb-3d.com/store/) — 3DO USB Camera V2, Gates smooth idlers
- [Mandala Rose Works](https://mandalaroseworks.com/) — CNC toolhead, XY joiners, bed support arms, motor mounts
- [MIGL Fabrication](https://migl-fabrication.de/en/) — Titanium gantry tube (clinch nut variant)
- [BRS Engineering](https://store.brs-engineering.com/) — BRS-AWD DRIVE (planned)
- [Beacon](https://beacon3d.com/) — Beacon RevH probe
- [Julian Schill](https://github.com/julianschill/klipper-led_effect) — LED effect plugin
- [Chube](https://chubehotend.com/) / [Luke's Lab](https://www.lukeslabonline.com/) — Chube Air hotend
- Original `hybrid_corexy` kinematics by Fabrice Gallet, Helge Keck, Mikkel Schmidt

## Inspiration & Community

YouTube channels that helped shape this build:

- [Vez3D](https://www.youtube.com/@Vez3D)
- [Mandic Labs](https://www.youtube.com/@MandicLabs)
- [Canuck Creator](https://www.youtube.com/@CanuckCreator)
- [xscorpion2](https://www.youtube.com/@xscorpion2)
- [Mandala Rose Works](https://www.youtube.com/@mandalaroseworks)
- [Luke's Laboratory](https://www.youtube.com/@LukesLaboratory)
- [PeeDee3D](https://www.youtube.com/@PeeDee3D)
- [Mammoth 3D](https://www.youtube.com/@mammoth-3D)

## Therapy

- [Lake Martin Machine Gun](https://lakemartinmachinegun.com/) — for stress relief between debugging sessions

## Fuel

- [Monster Zero Ultra](https://www.monsterenergy.com/en-us/energy-drinks/zero-sugar/zero-ultra/) — the caffeine driving this project

## Built With

- [Claude](https://claude.ai/) by [Anthropic](https://www.anthropic.com/) — AI partner for configuration development, documentation, and debugging
