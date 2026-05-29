# open_grid

<p align="center">
  <img src="https://img.shields.io/badge/Rust-2024-orange?style=for-the-badge&logo=rust" alt="Rust">
  <img src="https://img.shields.io/badge/Flutter-3.0-blue?style=for-the-badge&logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/License-Apache_2.0-green?style=for-the-badge" alt="License">
  <img src="https://img.shields.io/badge/Status-Alpha-red?style=for-the-badge" alt="Status">
</p>

> **The decentralized mesh network toolkit. Built on Rust.**

---

## The Problem

Mesh networking tools are either too academic (FRR, complex BGP configs) or too simple (basic p2p chat apps). There's no serious developer toolkit for building local-first, peer-to-peer applications on modern devices.

## The Solution

**open_grid** is a modular mesh networking toolkit that makes it easy to build local-first, peer-to-peer applications. Think of it as the "Swiss Army knife" for edge networking. Discover devices. Send encrypted messages. Transfer files. All over local networks, without internet.

```
┌───────────────────────────────────────────────────┐
│             open_grid architecture                 │
│                                                    │
│  ┌──────────────┐      ┌──────────────────┐       │
│  │  Flutter UI   │◄────►│  Rust Backend    │       │
│  │  (Device      │  IPC │  Mesh protocol   │       │
│  │   discovery,  │      │  E2E encryption  │       │
│  │   messaging)  │      │  Relay server    │       │
│  └──────────────┘      └──────────────────┘       │
│                                                    │
│  ┌──────────────────────────────────────────┐      │
│  │  Discovery Layer                          │      │
│  │  mDNS/DNS-SD • WiFi Direct • BLE          │      │
│  └──────────────────────────────────────────┘      │
│  ┌──────────────────────────────────────────┐      │
│  │  Transport Layer                          │      │
│  │  TCP • WebSocket • BLE • WiFi Direct      │      │
│  └──────────────────────────────────────────┘      │
│  ┌──────────────────────────────────────────┐      │
│  │  Security Layer                           │      │
│  │  Noise protocol • Curve25519 • AES-256    │      │
│  └──────────────────────────────────────────┘      │
└───────────────────────────────────────────────────┘
```

## Features

### MVP (Current)
- ✅ Local network discovery (mDNS/DNS-SD)
- ✅ P2P messaging over TCP (Tokio async)
- ✅ End-to-end encryption (Noise protocol via `noise-rust`)
- ✅ Simple relay server for NAT traversal
- ✅ Real-time device discovery dashboard

### Roadmap
- 🔜 BLE mesh networking for phones without WiFi direct
- 🔜 File transfer over mesh
- 🔜 Browser extension for local web apps
- 🔜 MQTT broker overlay
- 🔜 Edge compute (WebAssembly modules)

## Tech Stack

| Layer | Technology | Why |
|-------|-----------|-----|
| **Rust Backend** | Tokio, `noise-rust`, `mdns` | Async, encrypted, standard protocols |
| **Flutter Frontend** | Riverpod, `fl_chart`, `go_router` | Clean state, smooth UI |
| **Discovery** | mDNS/DNS-SD, BLE | Zero-config local discovery |
| **Transport** | TCP, WebSocket, BLE | Flexible, reliable |
| **Crypto** | `noise-rust`, `x25519-dalek` | Post-quantum-ready, audited |

## Getting Started

### Prerequisites
- Rust 1.75+
- Flutter 3.0+
- macOS 13+ / Android API 26+ / Linux

### Build

```bash
# Clone the repo
git clone https://github.com/synth/open_grid.git
cd open_grid

# Build the Rust backend
cd rust
cargo build --release

# Build the Flutter app
cd ../flutter
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

### Running the Mesh

```bash
# Start the relay server (optional, for NAT traversal)
cargo run --bin relay --port 9000

# Start a mesh node
cargo run --bin node --join localhost:9000

# Or discover locally without a relay
cargo run --bin discover
```

## Architecture

### Rust Backend (`rust/`)

```
rust/
├── Cargo.toml
├── src/
│   ├── lib.rs              # Library root
│   ├── discovery/          # Network discovery
│   │   ├── mod.rs
│   │   ├── mdns.rs         # mDNS discovery
│   │   ├── ble.rs          # BLE discovery
│   │   └── scanner.rs      # Multi-protocol scanner
│   ├── transport/          # Transport layer
│   │   ├── mod.rs
│   │   ├── tcp.rs          # TCP transport
│   │   ├── websocket.rs    # WebSocket transport
│   │   └── ble.rs          # BLE transport
│   ├── crypto/             # E2E encryption
│   │   ├── mod.rs
│   │   ├── keys.rs         # Key generation/rotation
│   │   └── noise.rs        # Noise protocol
│   ├── server/             # Relay server
│   │   ├── mod.rs
│   │   ├── peer.rs         # Peer management
│   │   └── forward.rs      # Message forwarding
│   └── protocol/           # Application protocol
│       ├── mod.rs
│       └── messages.rs     # Message types
```

### Flutter Frontend (`flutter/`)

```
flutter/
├── pubspec.yaml
├── lib/
│   ├── main.dart
│   ├── app.dart              # App shell & routing
│   ├── themes/               # Synthwave neon themes
│   ├── screens/              # Discovery, messages, transfer
│   ├── widgets/              # Device cards, message bubbles
│   ├── providers/            # Riverpod state
│   ├── services/             # IPC bridge to Rust
│   └── utils/                # Helpers
└── test/
    ├── unit/
    ├── integration/
    └── widgets/
```

## Development

### Running Tests

```bash
# Rust tests
cd rust && cargo test

# Flutter tests
cd flutter && flutter test
```

### Code Style

- **Rust:** `cargo fmt` + `cargo clippy -- -D warnings`
- **Flutter:** `dart format .` + `flutter analyze`

## Contributing

Contributions welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

1. Fork the repo
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.

## Acknowledgments

Built with love by **synth** 🎹🦈 — [synthshark](https://github.com/synth)

Part of **The Neon Stack** — three open-source apps, one ecosystem.

---

*The grid connects. No cloud required.*
