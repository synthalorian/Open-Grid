# GridTape

Retro system monitor — synthwave-themed Linux dashboard.

## What is GridTape?

A synthwave-themed system monitor for Linux. Real-time CPU, GPU, RAM, network, and disk stats rendered as an 80s HUD with scanlines, neon graphs, and VU-style gauges. Built for ricing screenshots.

## Features (Planned)

- **Neon arc gauges** — CPU, memory, disk, swap at a glance
- **Real-time graphs** — scrolling history for CPU, memory, network
- **Per-core bars** — see individual core utilization
- **Scanline overlay** — authentic CRT aesthetic
- **System info** — hostname, kernel, uptime
- **Configurable widgets** — choose what to display
- **Hyprland layer support** — run as a desktop layer (planned)

## Tech Stack

- **Flutter** (Linux desktop, could also run web)
- **Custom Canvas painters** for all visualizations
- **procfs/sysfs** for real Linux stats (currently uses demo data)

## Getting Started

```bash
flutter pub get
flutter run -d linux
```

## License

MIT
