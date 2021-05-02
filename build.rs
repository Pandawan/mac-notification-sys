use std::process::Command;

extern crate cc;

#[link(name = "UserNotifications", kind = "framework")]
fn main() {
    if cfg!(target_os = "macos") {
        cc::Build::new()
            .file("objc/notify.m")
            .flag("-fmodules")
            .flag("-mmacosx-version-min=10.14")
            .warnings(true)
            .debug(true)
            .compile("notify");

        Command::new("sh")
            .arg("-c")
            .arg("codesign -s Pandawan_Test")
            .output()
            .expect("failed to execute process");
    }
}
