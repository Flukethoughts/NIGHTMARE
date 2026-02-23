# Calibration Guide

## First-Time Calibration Order
1. Beacon probe calibration: `BEACON_AUTO_CALIBRATE`
2. PID tune hotend: `PID_CALIBRATE_HOTEND TEMP=230`
3. PID tune bed: `PID_CALIBRATE_BED TEMP=60`
4. Belt tension (CoreXY): `MEASURE_COREXY_BELT_TENSION`
5. Belt tension (Hybrid Y): `MEASURE_HYBRID_Y_BELT_TENSION`
6. Input shaper: `GENERATE_SHAPER_GRAPHS`
7. Bed mesh: `BED_MESH_CALIBRATE`
8. Pressure advance: `PA_TUNING`

## Belt Tension Targets (RatRig docs)
- CoreXY belts (stepper_x/x1): **87 Hz** (+/-1 Hz)
- Hybrid Y belts (stepper_y/y1): **84 Hz** (+/-1 Hz)
- Use accelerometer-based testing, NOT phone pluck test (phone picks up harmonics)
- 9mm Gates 2GT belt, linear mass density ~0.01245 kg/m
- Hz to Newtons: `T = 0.0498 * L^2 * f^2` (L in meters)

## CoreXY Belt Tension Testing
`MEASURE_COREXY_BELT_TENSION` tests resonance on diagonal axes (AXIS=1,1 and AXIS=1,-1) which isolate the two CoreXY belts. The generated graph shows frequency peaks — both should be close to 87 Hz and match each other.

## Hybrid Y Belt Tension Testing
Standard Klipper cannot isolate individual Y belt resonances because they share an axis. `MEASURE_HYBRID_Y_BELT_TENSION` works around this by positioning the toolhead at extreme X positions (X=30 for left rail, X=470 for right rail) to bias the accelerometer signal. Compare peak frequencies — should be near 84 Hz and close together.

## Input Shaper
Run `GENERATE_SHAPER_GRAPHS` to test and generate inline graphs. Current values: MZV X=68.2 Hz, Y=48.8 Hz. Must recalibrate after any mechanical changes (belt tension, pulley swap, etc.).

## Available Calibration Macros

| Macro | Description |
|-------|-------------|
| `PID_CALIBRATE_HOTEND TEMP=230` | PID tune extruder |
| `PID_CALIBRATE_BED TEMP=60` | PID tune bed |
| `G32` | Home + Z_TILT_ADJUST + re-home Z |
| `MEASURE_COREXY_BELT_TENSION` | CoreXY belt resonance test with graph |
| `MEASURE_HYBRID_Y_BELT_TENSION` | Y belt comparison at X extremes |
| `GENERATE_SHAPER_GRAPHS` | Input shaper calibration with graphs |
| `CALIBRATE_BEACON` | Beacon auto-calibration |
| `PROBE_TEST SAMPLES=10` | Probe accuracy test |
| `TEST_SPEED SPEED=300 ACCEL=6000` | Max speed stress test |
| `COLD_PULL HEAT_TEMP=230 PULL_TEMP=90` | Nozzle cleaning |
| `PA_TUNING START=0 END=0.1 STEP=0.005` | Pressure advance tower |
| `CORNER_TEST_FAST/MEDIUM/SLOW/CRAWL` | Corner ringing tests |

## Inline Graph Display
Belt tension and shaper graphs render inline in Mainsail console using HTML img tags. Mainsail renders HTML in console output via v-html. Scripts save timestamped copies plus a "latest" symlink to the input_shaper/ folder.
