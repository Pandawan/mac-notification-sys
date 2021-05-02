use mac_notification_sys::*;

#[test]
#[should_panic]
fn set_application_again() {
    let _ = set_application("com.apple.Terminal").unwrap();
    let _ = set_application("com.apple.Terminal").unwrap();
}

#[test]
fn get_default_identifier() {
    let bundle = get_bundle_identifier_or_default("thisappdoesnotexist");
    assert_eq!(bundle, "com.apple.Finder");
}

#[test]
fn test_notif() {
    test()
}
