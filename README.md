# Open Grid

Synthwave-themed system monitor for Linux — real-time stats rendered as an 80s HUD.

## Features

- **Neon arc gauges** — CPU, GPU, memory, disk, swap at a glance
- **Real-time graphs** — scrolling 60-second history for CPU, GPU, memory, network
- **GPU monitoring** — NVIDIA (nvidia-smi) and AMD (sysfs) with temp and VRAM
- **Per-core bars** — individual core utilization with color-coded load levels
- **Scanline overlay** — authentic CRT aesthetic
- **System info** — hostname, kernel, uptime, CPU model
- **Disk overview** — all mounted filesystems with usage bars

## Screenshots

*Coming soon*

## Tech Stack

- **Flutter** (Linux desktop)
- **Custom Canvas painters** for all visualizations
- **procfs/sysfs** for real Linux stats — no polling daemons, no dependencies
- **nvidia-smi** fallback for NVIDIA GPU stats

## Getting Started

```bash
flutter pub get
flutter run -d linux
```

## Build

```bash
flutter build linux --release
```

Binary lands in `build/linux/x64/release/bundle/open-grid`.

## License

MIT

---

## ☕ Support the Developer

If this project saved you time, solved a problem, or just made your day a little more neon, you can fuel the next one:

[![Buy Me A Coffee](https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png)](https://buymeacoffee.com/synthalorian)
