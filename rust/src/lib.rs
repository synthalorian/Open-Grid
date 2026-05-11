//! open_grid — Decentralized mesh network toolkit.
//!
//! Discover devices, send encrypted messages, transfer files.
//! All local. No cloud. No tracking.

#![forbid(unsafe_code)]
#![warn(clippy::all, clippy::pedantic)]
#![allow(clippy::doc_missing_intra_doc_links)]

pub mod discovery;
pub mod protocol;
pub mod crypto;
pub mod server;
pub mod transport;

pub use discovery::*;
pub use protocol::*;
pub use crypto::*;
pub use server::*;
pub use transport::*;

/// Application version.
pub const VERSION: &str = env!("CARGO_PKG_VERSION");

/// Application name.
pub const APP_NAME: &str = "open_grid";

/// Default relay server port.
pub const DEFAULT_RELAY_PORT: u16 = 9000;

/// Default mDNS service name.
pub const MDNS_SERVICE_NAME: &str = "_open-grid._tcp";

#[cfg(test)]
mod tests {
    #[test]
    fn test_version() {
        assert!(!VERSION.is_empty());
    }

    #[test]
    fn test_defaults() {
        assert_eq!(DEFAULT_RELAY_PORT, 9000);
        assert_eq!(MDNS_SERVICE_NAME, "_open-grid._tcp");
    }
}
