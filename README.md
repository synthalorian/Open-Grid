![Open-Grid](.github/preview.png)

<p align="center">
  <img src=".github/assets/synthalorian-idle-128.gif" width="128" height="128" alt="The synthalorian: a pixel-art figure in a black helmet with a pink T-visor, idling">
</p>
<p align="center"><em>A Linux system monitor that draws your CPU, GPU and memory as an 80s neon HUD.</em></p>

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

## License

[Apache-2.0](LICENSE)

---

<p align="center">
  <img src=".github/assets/synthalorian-idle-128.gif" width="32" height="32" alt="The synthalorian sprite"><br>
  <sub>Built by <a href="https://github.com/synthalorian">the synthalorian</a></sub>
  <br><sub>AI-assisted art: the banner image at the top of this README was made with AI image tools. The synthalorian sprite is code-drawn pixel art.</sub>
</p>
