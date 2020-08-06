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
        Some(NotificationOptions {
            app_icon: None,
            content_image: None,
            main_button: None,
            close_button: None,
            group_id: None,
            delivery_date: None,
            sound: Some("Submarine"),
        }),
    )
    .unwrap();
}
