# Security Guidelines

This repository contains sanitized configuration files. All machine-specific identifiers have been replaced with placeholders. Follow these guidelines to keep your setup secure.

## What's Been Sanitized

| Data Type | Placeholder | Where to Find Yours |
|-----------|-------------|---------------------|
| MCU serial IDs | `YOUR_OCTOPUS_SERIAL`, etc. | `ls /dev/serial/by-id/` on your printer |
| Beacon serial | `YOUR_BEACON_SERIAL` | `ls /dev/serial/by-id/ \| grep Beacon` |
| Printer IP | `YOUR_PRINTER_IP` | Your router's DHCP lease table |
| Beacon model coefficients | Removed (SAVE_CONFIG block) | Run `BEACON_AUTO_CALIBRATE` |
| Bed mesh data | Removed (SAVE_CONFIG block) | Run `BED_MESH_CALIBRATE` |

## Before You Commit

1. **Never commit serial numbers** — they identify your specific hardware
2. **Never commit IP addresses** — they reveal your network topology
3. **Never commit SSH keys** — check `.gitignore` covers `id_rsa*`, `id_ed25519*`
4. **Never commit `saved_variables.cfg`** — may contain calibration secrets

## Recommended: Pre-commit Scanning

Install [git-secrets](https://github.com/awslabs/git-secrets) to catch accidental leaks:

```bash
git secrets --install
git secrets --add '192\.168\.\d+\.\d+'
git secrets --add 'usb-Klipper_stm32'
git secrets --add 'usb-Beacon_Beacon'
```

## Orange Pi Image Sanitization

If sharing your OS image:

1. Remove SSH keys: `rm -rf /home/*/.ssh/`
2. Remove bash history: `rm /home/*/.bash_history`
3. Reset passwords: `passwd` for all users
4. Clear Moonraker database: `rm -rf ~/printer_data/database/`
5. Remove WiFi credentials: check `/etc/NetworkManager/` or `/etc/wpa_supplicant/`
6. Clear logs: `rm ~/printer_data/logs/*.log`

## Reporting Security Issues

If you find committed secrets or security issues in this repository, please [open an issue](https://github.com/Flukethoughts/NIGHTMARE/issues) immediately.
