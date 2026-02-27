# Orange Pi 5 Pro Setup

## Hardware
- Orange Pi 5 Pro 16GB RAM
- 128GB NVMe SSD
- Debian Bookworm (ARM64)

## Software Stack
Install in this order:
1. **Kalico** (Klipper fork): `git clone https://github.com/KalicoCrew/kalico.git ~/klipper`
2. **Moonraker**: API server for web interfaces
3. **Fluidd**: Web interface (install via update_manager)
4. **KlipperScreen**: Touch display interface
5. **Crowsnest**: Camera streaming (ustreamer)
6. **jellyfin-ffmpeg**: For hardware-encoded camera overlay (h264_rkmpp)

## Security Checklist
- Change default passwords for all users
- Set up SSH key authentication, disable password auth
- Configure firewall (ufw): allow ports 22, 80, 7125
- Keep system updated: `sudo apt update && sudo apt upgrade`

## Camera Overlay
The camera overlay system uses hardware H.264 encoding via the RK3588S VPU.
See [camera-overlay/README.md](../camera-overlay/README.md) for full details.

## File Transfer
Note: SCP may not work if sftp-server is not installed. Alternative:
```bash
cat localfile | ssh user@printer 'cat > /tmp/file'
```

## Kalico vs Stock Klipper
This printer runs Kalico (KalicoCrew/kalico), not stock Klipper. Key differences:
- STM32H723 clocked at 520 MHz (vs 400 MHz stock)
- Neopixel timing fixes
- CAN bus improvements
- The update manager in moonraker.conf points to KalicoCrew/kalico.git
