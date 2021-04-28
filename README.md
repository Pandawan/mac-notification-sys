# mac-notification-sys

![Crates.io](https://img.shields.io/badge/platform-macOS-lightgrey?style=flat-square)
[![license](https://img.shields.io/crates/l/mac-notification-sys?style=flat-square)](https://crates.io/crates/mac-notification-sys/)
[![version](https://img.shields.io/crates/v/mac-notification-sys?style=flat-square)](https://crates.io/crates/mac-notification-sys/)
![Crates.io](https://img.shields.io/crates/d/mac-notification-sys?style=flat-square)

A simple wrapper to deliver or schedule macOS Notifications in Rust.

## Usage

```toml
#Cargo.toml
[dependencies]
mac-notification-sys = "0.3"
```

## Documentation

The documentation can be found [here](https://h4llow3en.github.io/mac-notification-sys/mac_notification_sys/)

## Example

```rust
use mac_notification_sys::*;

fn main() {
    let bundle = get_bundle_identifier_or_default("firefox");
    set_application(&bundle).unwrap();

    send_notification(
        "Danger",
        Some("Will Robinson"),
        "Run away as fast as you can",
        None,
    )
    .unwrap();

    send_notification(
        "NOW",
        None,
        "Without subtitle",
        Some(Notification::new().sound("Blow")),
    )
    .unwrap();
}

```

## TODO

- [ ] Add timeout option so notifications can be auto-closed
- [ ] Allow NSDictionary to hold various types (perhaps with a union?)
- [ ] Switch to UserNotification if possible

## Contributors

Thanks goes to these wonderful people:

- [@hoodie](https://github.com/hoodie)
- [@Pandawan](https://github.com/Pandawan)

## UserNotifications plan

- [Use a system version check to enable UserNotifications if available](https://stackoverflow.com/questions/39850603/how-to-implement-push-notification-for-ios-10objective-c)
- Compile with `-framework UserNotifications` to auto-import the framework into the build
  - Might need to use [.flag()](https://docs.rs/cc/1.0.67/cc/struct.Build.html#method.flag) in `build.rs`
- See Apple docs for more info on [including frameworks (without Xcode)](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPFrameworks/Tasks/IncludingFrameworks.html)
- Will probably need to [codesign the binary](https://docs.rs/tugger-apple-codesign/0.2.0/tugger_apple_codesign/) after building in `build.rs`
