# Camera Overlay System

Custom overlay stream that combines the 3DO USB Camera V2 feed with live printer status information (temps, motion, progress). Runs as a systemd service on the printer's Orange Pi 5 Pro.

## Architecture

```
ustreamer (port 8083, localhost only, 4K 30fps MJPEG, HW encode via camera)
    -> ffmpeg (SW decode + drawbox/drawtext overlay filters + h264_rkmpp HW encode)
    -> HLS segments (.ts + .m3u8) to /tmp/camera-overlay-hls/ (tmpfs)
    -> hls_server.py (Python HTTP server on port 8084)
    -> browsers load HTML player page with hls.js
```

## Endpoints

| URL | Description |
|-----|-------------|
| `http://YOUR_PRINTER_IP:8084/` | HTML player page (hls.js auto-plays) |
| `http://YOUR_PRINTER_IP:8084/stream.m3u8` | HLS playlist (direct embedding) |
| `http://YOUR_PRINTER_IP:8084/snapshot` | JPEG snapshot (proxied from ustreamer, no overlay) |
| `http://YOUR_PRINTER_IP:8084/stats` | HLS stats |

## Files on Printer

Located at `/home/pi/camera-overlay/`:

| File | Description |
|------|-------------|
| `start.sh` | Entrypoint, runs ffmpeg in restart loop |
| `hls_server.py` | HTTP server: HLS files, HTML player, snapshot proxy |
| `overlay_status.py` | Polls Moonraker API, writes status text files (~1s interval) |
| `status/` | Text files read by ffmpeg drawtext filters (reload=1) |

Service: `/etc/systemd/system/camera-overlay.service` (runs as `pi`, `Restart=always`)

## Current Settings

| Parameter | Value |
|-----------|-------|
| Encoder | h264_rkmpp (Rockchip VPU) |
| Bitrate | 4 Mbps |
| GOP | 30 frames (keyframe every 1s at 30fps) |
| B-frames | 0 |
| HLS segment time | 1s |
| HLS playlist size | 3 segments |
| HLS flags | delete_segments, temp_file, split_by_time |

## CPU Usage

| Configuration | CPU | System Idle |
|--------------|-----|-------------|
| h264_rkmpp + HLS (current) | ~159% | ~64% |
| Software MJPEG 4K (old) | ~500% | ~13% |

## Overlay Layout

- **Top bar** (200px, semi-transparent black, blue accent):
  - Row 1: Printer status (white 48pt) + heater temps (yellow 40pt)
  - Row 2: Motion info (cyan 38pt) + motor temps (green 36pt)
  - Row 3: System temps (purple 36pt)
- **Bottom bar** (90px): Filename (white 38pt) + progress (cyan 38pt)
- Font: DejaVu Sans Mono (Bold + Regular)

## Latency Tuning

Tuned from ~7-10s down to ~2-3s:
- HLS segments: 2s -> 1s
- GOP: 60 -> 30 (aligned with segment duration)
- Playlist: 5 -> 3 segments
- hls.js: lowLatencyMode=true, liveSyncDurationCount=1, maxBufferLength=2

HLS has a floor of ~2-3s latency. For sub-second, would need WebRTC (e.g., go2rtc).

## Known Issues

### rkmpp MJPEG Encoder is Broken
The `mjpeg_rkmpp` encoder doesn't byte-stuff entropy data and omits EOI markers. Browsers refuse to render the output. This is a fundamental MPP library bug. Use `h264_rkmpp` instead.

### ffmpeg Dual-Output Segfault
Using two `-vf` flags (one per output) in jellyfin-ffmpeg 7.1.3 causes segfault (exit 139). Use single output only; snapshots are proxied from ustreamer separately.

### ffmpeg -y Flag Required
Without `-y`, ffmpeg prompts to overwrite existing files and exits in non-interactive service context.

## Software Requirements

- **ffmpeg:** jellyfin-ffmpeg 7.1.3 at `/usr/lib/jellyfin-ffmpeg/ffmpeg` (has rkmpp support)
- **ustreamer:** For camera capture
- **Kernel:** Must have `/dev/mpp_service` (Rockchip MPP device)
- **Fonts:** `fonts-dejavu-core` package
