# open_grid — Development Plan

> **The decentralized mesh network toolkit. Built on Rust.**

---

## Vision

A modular mesh networking toolkit that makes it easy to build local-first, peer-to-peer applications. Discover devices. Send encrypted messages. Transfer files. All over local networks, without internet.

---

## Tech Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| **Rust Backend** | `tokio`, `noise-rust`, `x25519-dalek`, `mdns` | Async, encrypted, zero-config discovery |
| **Flutter Frontend** | Riverpod, `fl_chart`, `go_router` | Clean state, smooth UI |
| **Discovery** | mDNS/DNS-SD, BLE | Zero-config local discovery |
| **Transport** | TCP, WebSocket, BLE | Flexible, reliable |
| **Crypto** | `noise-rust`, `x25519-dalek` | Post-quantum-ready, audited |
| **IPC** | Unix domain socket (Linux/macOS), named pipe (Windows) | Zero-copy, no network exposure |

---

## Architecture

```
┌───────────────────────────────────────────────────┐
│         open_grid architecture                      │
│                                                      │
│  ┌──────────────┐      ┌──────────────────┐         │
│  │  Flutter UI   │◄────►│  Rust Backend    │         │
│  │  (Device      │  IPC │  Mesh protocol   │         │
│  │   discovery,  │      │  E2E encryption  │         │
│  │   messaging)  │      │  Relay server    │         │
│  └──────────────┘      └──────────────────┘         │
│                                                      │
│  ┌──────────────────────────────────────────┐        │
│  │  Discovery Layer                          │        │
│  │  mDNS/DNS-SD • WiFi Direct • BLE          │        │
│  └──────────────────────────────────────────┘        │
│  ┌──────────────────────────────────────────┐        │
│  │  Transport Layer                          │        │
│  │  TCP • WebSocket • BLE • WiFi Direct      │        │
│  └──────────────────────────────────────────┘        │
│  ┌──────────────────────────────────────────┐        │
│  │  Security Layer                           │        │
│  │  Noise protocol • Curve25519 • AES-256    │        │
│  └──────────────────────────────────────────┘        │
└───────────────────────────────────────────────────┘
```

---

## Development Phases

### Phase 1 — Core Networking Stack

**Goal:** Rust backend with basic TCP transport, device identity, and local discovery.

#### 1.1 Device Identity

- [ ] Implement key pair generation (X25519) in `rust/src/crypto/keys.rs`
- [ ] Derive display name from key + random suffix ("NeonFox42")
- [ ] Store keys persistently (file-based keychain)
- [ ] Key export/import (base64-encoded for backup)
- [ ] Write crypto unit tests

#### 1.2 TCP Transport Layer

- [ ] Implement TCP server (`tokio::net::TcpListener`) in `rust/src/transport/tcp.rs`
- [ ] Implement TCP client with reconnection
- [ ] Framed protocol: `[length: u32][payload: bytes]`
- [ ] Handle connection lifecycle (connect, disconnect, reconnect)
- [ ] Write transport integration tests

#### 1.3 mDNS Discovery

- [ ] Implement mDNS advertiser in `rust/src/discovery/mdns.rs`
- [ ] Implement mDNS scanner in `rust/src/discovery/scanner.rs`
- [ ] Announce service: `_open-grid._tcp.local`
- [ ] Scan results: device ID, name, capabilities
- [ ] Write discovery tests (local network simulation)

#### 1.4 Unified Discovery Abstraction

- [ ] Define `Discovery` trait in `rust/src/discovery/mod.rs`
- [ ] Implement `MdnsDiscovery`, `BleDiscovery` (stub), `WifiDirectDiscovery` (stub)
- [ ] Multi-protocol scanner: aggregate results from all discovered backends
- [ ] Deduplicate devices across protocols
- [ ] Write scanner integration tests

#### 1.5 Local IPC Server

- [ ] Implement Unix domain socket server in `rust/src/server/`
- [ ] Define message types (`Request` / `Response`)
- [ ] Implement endpoints: `discover`, `connect`, `send_message`, `disconnect`
- [ ] Write server integration tests

**Deliverable:** `cargo test` passes 100%. `rust/src/lib.rs` exposes a stable public API for discovery + TCP transport.

---

### Phase 2 — End-to-End Encryption

**Goal:** Secure channel establishment, encrypted messaging.

#### 2.1 Key Exchange

- [ ] Implement Noise_XX handshake via `noise-rust`
- [ ] Support Noise_XX + Curve25519 + ChaCha20-Poly1305 + SHA256
- [ ] Server-side identity keys (persistent)
- [ ] Client ephemeral keys (per session)
- [ ] Write handshake unit tests

#### 2.2 Secure Channel

- [ ] Implement TLS-like wrapper over TCP in `rust/src/crypto/noise.rs`
- [ ] Automatic encryption/decryption of frames
- [ ] Forward secrecy (ephemeral keys per session)
- [ ] Key rotation every N messages or N minutes
- [ ] Write encryption roundtrip tests

#### 2.3 Message Protocol

- [ ] Define message types in `rust/src/protocol/messages.rs`:
  - `Hello` (handshake initiation)
  - `HelloResponse` (handshake response)
  - `Message` (encrypted text)
  - `Heartbeat` (keepalive)
  - `FileHeader` / `FileChunk` / `FileComplete` (file transfer)
  - `Ping` / `Pong` (latency)
- [ ] Message framing: `[encrypted_length: u32][nonce: u128][ciphertext: bytes]`
- [ ] Message ordering guarantee (monotonic nonce)
- [ ] Write protocol tests

#### 2.4 Secure Messaging

- [ ] Send/receive encrypted messages over TCP
- [ ] Message history (store last 100 messages per peer)
- [ ] Typing indicators (optional)
- [ ] Read receipts (optional)
- [ ] Write messaging integration tests

**Deliverable:** Two nodes can discover each other, establish encrypted channel, and exchange messages.

---

### Phase 3 — Relay Server (NAT Traversal)

**Goal:** Central relay server for NAT traversal when direct P2P isn't possible.

#### 3.1 Relay Server

- [ ] Implement relay server binary `rust/src/bin/relay.rs`
- [ ] WebSocket server for client connections
- [ ] Peer registry: map device ID → connection
- [ ] Message forwarding: pub/sub by device ID
- [ ] Heartbeat monitoring: disconnect stale peers

#### 3.2 NAT Traversal Logic

- [ ] Implement STUN-like discovery (local IP + port)
- [ ] If direct TCP fails → fallback to relay
- [ ] Auto-negotiation: peers try P2P first, relay as fallback
- [ ] Relay connection established via authenticated token
- [ ] Write relay integration tests

#### 3.3 Relay Security

- [ ] Relay cannot read messages (E2E encrypted)
- [ ] Relay only forwards encrypted payloads
- [ ] Rate limiting per peer (prevent abuse)
- [ ] Audit log (optional, configurable)
- [ ] Write security tests

**Deliverable:** `cargo run --bin relay --port 9000` runs a relay server. Two peers behind different NATs can communicate via relay.

---

### Phase 4 — Flutter Frontend

**Goal:** Synthwave-themed UI for device discovery, messaging, and file transfer.

#### 4.1 App Shell & Routing

- [ ] Flutter project scaffold
- [ ] Riverpod state management
- [ ] `go_router` setup (discovery, messages, settings tabs)
- [ ] Synthwave neon theme (dark mode, gradient accents)

#### 4.2 IPC Bridge

- [ ] Unix socket client in Flutter (`dart:io` `Socket`)
- [ ] Serialize/deserialize messages to/from Rust
- [ ] Error handling (connection lost, timeout)
- [ ] Background service (keep Rust process alive)

#### 4.3 Discovery Screen

- [ ] Real-time device discovery list
- [ ] Device cards: name, IP, connection status, capabilities
- [ ] Tap to connect → establishes encrypted channel
- [ ] Nearby devices animation (pulsing dots)
- [ ] Filter by protocol (mDNS / BLE / WiFi Direct)
- [ ] Manual address input (for relay)

#### 4.4 Messaging Screen

- [ ] Message list per peer (encrypted, timestamped)
- [ ] Input field + send button
- [ ] Message bubbles (sent = neon green, received = neon purple)
- [ ] Typing indicators (if supported)
- [ ] Message search

#### 4.5 File Transfer

- [ ] File picker in Flutter
- [ ] Progress bar during transfer
- [ ] Resume support (partial transfers)
- [ ] File preview (images, PDFs)
- [ ] Transfer history

#### 4.6 Settings Screen

- [ ] Device name / identity management
- [ ] Key backup / restore
- [ ] Relay server configuration
- [ ] Transport preferences (TCP / WebSocket / BLE)
- [ ] About / feedback

#### 4.7 Polish

- [ ] Lottie animations for loading states
- [ ] Haptic feedback on interactions
- [ ] Offline-first (queue messages when disconnected)
- [ ] Accessibility (semantic labels, contrast)

**Deliverable:** `flutter build apk --release` produces a working Android APK.

---

### Phase 5 — BLE Mesh Networking

**Goal:** Bluetooth Low Energy mesh for devices without WiFi direct (phones in different networks).

#### 5.1 BLE Discovery

- [ ] Implement BLE scanner in `rust/src/discovery/ble.rs`
- [ ] Advertise `open-grid` service UUID
- [ ] Parse BLE manufacturer data for device identity
- [ ] Write BLE discovery tests

#### 5.2 BLE Transport

- [ ] Implement BLE GATT client/server
- [ ] Custom service UUID + characteristic for messaging
- [ ] MTU negotiation (handle BLE packet size limits)
- [ ] Write BLE transport tests

#### 5.3 BLE Mesh Routing

- [ ] Store-and-forward: nodes forward messages for each other
- [ ] TTL counter (max hops)
- [ ] Route discovery (BFS over mesh)
- [ ] Mesh topology visualization
- [ ] Write mesh integration tests

**Deliverable:** Three phones can form a BLE mesh and relay messages between devices that can't see each other directly.

---

### Phase 6 — File Transfer & Extras

#### 6.1 File Transfer (Backend)

- [ ] Implement file transfer protocol in `rust/src/protocol/` (FileHeader/FileChunk/FileComplete)
- [ ] Chunked transfer with checksums (CRC32)
- [ ] Resume support (skip verified chunks)
- [ ] Concurrent transfers (max 3 simultaneous)
- [ ] Write file transfer integration tests

#### 6.2 Browser Extension (Future)

- [ ] WebAssembly module for browser-based discovery
- [ ] WebSocket bridge to local Rust process
- [ ] Local web app P2P communication
- [ ] Service worker for background discovery

#### 6.3 MQTT Broker Overlay (Future)

- [ ] MQTT broker on local network (UDP broadcast)
- [ ] Devices subscribe to topic by device ID
- [ ] Publish messages as MQTT topics
- [ ] MQTT over TCP (standard port 1883)

**Deliverable:** File transfer works at production quality. v1.0 release.

---

### Phase 7 — Hardening & Release

#### 7.1 Security Audit

- [ ] Pen-test noise-rust handshake implementation
- [ ] Verify forward secrecy (compromised key → past messages safe)
- [ ] Relay server: verify it cannot decrypt messages
- [ ] Key rotation: verify old keys are purged

#### 7.2 CI/CD

- [ ] GitHub Actions: Rust fmt, clippy, test (PR)
- [ ] GitHub Actions: Flutter analyze, test (PR)
- [ ] GitHub Actions: Cross-platform release (Android APK, iOS IPA, Linux AppImage, macOS DMG)
- [ ] Release artifacts attached to GitHub releases

#### 7.3 Performance

- [ ] Benchmark: message latency (discover → encrypt → send)
- [ ] Benchmark: discovery scan time (50+ devices on subnet)
- [ ] Optimize: reduce TCP handshake time
- [ ] Memory profiling: ensure no leaks in long-running relay

#### 7.4 Documentation

- [ ] Update README with screenshots
- [ ] Architecture deep-dive doc
- [ ] "Building with open_grid" guide (how to embed the toolkit)
- [ ] Security model doc

#### 7.5 Publishing

- [ ] Publish Android APK to GitHub Releases
- [ ] Submit to F-Diff (if applicable)
- [ ] Submit to Amazon Appstore
- [ ] Write blog post / HN / r/networking

**Deliverable:** v1.0 release on GitHub with binaries for Android, iOS, Linux, macOS.

---

## Dependencies Between Projects

| Feature | Depends on |
|---------|-----------|
| Group challenges (friends' health) | open_habit (gamification + notifications) |
| Wearable notifications (health alerts) | open_habit (habit tracking + reminders) |
| Cross-app stat sharing | open_health (health data engine) |

These are future integrations. Phase 1–4 are fully self-contained.

---

## Success Metrics

| Metric | Target |
|--------|--------|
| Discovery time (20 devices) | < 2 seconds |
| Message latency (direct TCP) | < 50ms |
| Message latency (relay) | < 200ms |
| E2E encryption: forward secrecy | ✅ (compromised key → past safe) |
| BLE mesh hops (tested) | ≥ 3 |
| Crash-free sessions | > 99% |

---

## Open Questions

1. **BLE mesh routing** — Flooding vs. route discovery? Trade-off: flooding = simpler, route discovery = fewer messages but more complex.
2. **Relay server auth** — Token-based (pre-shared) vs. certificate-based (PKI)?
3. **Cross-platform IPC** — Windows named pipes vs. Unix sockets. Abstract behind trait?
4. **Browser P2P** — WebRTC data channels require STUN/TURN, but local-only WebRTC over DataChannel (no ICE) works on same subnet?
5. **Mesh auto-routing** — How do devices learn routes? AODV? DSR? Or just BFS on demand?
6. **Firewall issues** — Many routers block inbound TCP. Should relay be the default and P2P the bonus?

---

*The grid connects. No cloud required.*
