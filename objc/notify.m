#import "notify.h"

// getBundleIdentifier(app_name: &str) -> "com.apple.Terminal"
NSString* getBundleIdentifier(NSString* appName)
{
    NSString* findString = [NSString stringWithFormat:@"get id of application \"%@\"", appName];
    NSAppleScript* findScript = [[NSAppleScript alloc] initWithSource:findString];
    NSAppleEventDescriptor* resultDescriptor = [findScript executeAndReturnError:nil];
    return [resultDescriptor stringValue];
}

// setApplication(new_bundle_identifier: &str) -> Result<()>
BOOL setApplication(NSString* newbundleIdentifier)
{
    if (LSCopyApplicationURLsForBundleIdentifier((CFStringRef)newbundleIdentifier, NULL) != NULL)
    {
        fakeBundleIdentifier = newbundleIdentifier;
        return YES;
    }
    return NO;
}

// sendNotification(title: &str, subtitle: &str, message: &str, options: NotificationOptions) -> NotificationResult<()>
NSDictionary* sendNotification(NSString* title, NSString* subtitle, NSString* message, NSDictionary* options)
{
    @autoreleasepool
    {
        if (!installNSBundleHook())
        {
            // TODO: Could potentially have different error messages
            return @{@"error" : @""};
        }

        // TODO: Handle scheduled notifications removing others before they actually show up
        // Remove previous notification with the same group ID
        if (options[@"groupID"] && ![options[@"groupId"] isEqualToString:@""])
        {
            removeNotificationWithGroupID(options[@"groupID"]);
        }

        NSUserNotificationCenter* notificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
        NotificationCenterDelegate* ncDelegate = [[NotificationCenterDelegate alloc] init];
        // By default, don't wait for actions. This is set to YES when a button/action-related option is set.
        ncDelegate.keepRunning = NO;
        notificationCenter.delegate = ncDelegate;

        NSUserNotification* userNotification = [[NSUserNotification alloc] init];
        BOOL isScheduled = NO;

        // Basic text
        userNotification.title = title;
        if (![subtitle isEqualToString:@""])
        {
            userNotification.subtitle = subtitle;
        }
        userNotification.informativeText = message;

        // Notification sound
        if (options[@"sound"] && ![options[@"sound"] isEqualToString:@""] && ![options[@"sound"] isEqualToString:@"_mute"])
        {
            userNotification.soundName = options[@"sound"];
        }

        // Delivery Date/Schedule
        if (options[@"deliveryDate"] && ![options[@"deliveryDate"] isEqualToString:@""])
        {
            double deliveryDate = [options[@"deliveryDate"] doubleValue];
            NSDate* scheduleTime = [NSDate dateWithTimeIntervalSince1970:deliveryDate];
            userNotification.deliveryDate = scheduleTime;
            NSLog(@"Delivery date option passed as %@ converted to %f resulting in %@", options[@"deliveryDate"], deliveryDate, scheduleTime);
            isScheduled = YES;

            if (options[@"synchronous"] && [options[@"synchronous"] isEqualToString:@"yes"])
            {
                ncDelegate.keepRunning = YES;
            }
        }

        // Main Actions Button (defaults to "Show")
        if (options[@"mainButtonLabel"] && ![options[@"mainButtonLabel"] isEqualToString:@""])
        {
            userNotification.actionButtonTitle = options[@"mainButtonLabel"];
            userNotification.hasActionButton = 1;
            ncDelegate.keepRunning = YES;
        }

        // Dropdown actions
        if (options[@"actions"] && ![options[@"actions"] isEqualToString:@""])
        {
            [userNotification setValue:@YES forKey:@"_showsButtons"];
            ncDelegate.keepRunning = YES;

            NSArray* myActions = [options[@"actions"] componentsSeparatedByString:@","];

            if (myActions.count > 1)
            {
                [userNotification setValue:@YES forKey:@"_alwaysShowAlternateActionMenu"];
                [userNotification setValue:myActions forKey:@"_alternateActionButtonTitles"];
            }
        }

        // Close/Other button (defaults to "Cancel")
        if (options[@"closeButtonLabel"] && ![options[@"closeButtonLabel"] isEqualToString:@""])
        {
            ncDelegate.keepRunning = YES;
            [userNotification setValue:@YES forKey:@"_showsButtons"];
            userNotification.otherButtonTitle = options[@"closeButtonLabel"];
        }

        // Reply to the notification with a text field
        if (options[@"response"] && ![options[@"response"] isEqualToString:@""])
        {
            ncDelegate.keepRunning = YES;
            userNotification.hasReplyButton = 1;
            userNotification.responsePlaceholder = options[@"mainButtonLabel"];
        }

        // Change the icon of the app in the notification
        if (options[@"appIcon"] && ![options[@"appIcon"] isEqualToString:@""])
        {
            NSImage* icon = getImageFromURL(options[@"appIcon"]);
            // replacement app icon
            [userNotification setValue:icon forKey:@"_identityImage"];
            [userNotification setValue:@(false) forKey:@"_identityImageHasBorder"];
        }
        // Change the additional content image
        if (options[@"contentImage"] && ![options[@"contentImage"] isEqualToString:@""])
        {
            userNotification.contentImage = getImageFromURL(options[@"contentImage"]);
        }

        // Send or schedule notification
        if (isScheduled)
        {
            [notificationCenter scheduleNotification:userNotification];
        }
        else
        {
            [notificationCenter deliverNotification:userNotification];
        }

        [NSThread sleepForTimeInterval:0.1f];

        // Loop/wait for a user action if needed
        while (ncDelegate.keepRunning)
        {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }

        return ncDelegate.actionData;
    }
}
