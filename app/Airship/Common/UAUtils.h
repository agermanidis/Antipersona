/*
 Copyright 2009-2016 Urban Airship Inc. All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.

 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.

 THIS SOFTWARE IS PROVIDED BY THE URBAN AIRSHIP INC ``AS IS'' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 EVENT SHALL URBAN AIRSHIP INC OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SystemConfiguration/SCNetworkReachability.h>

NS_ASSUME_NONNULL_BEGIN

@class UAHTTPRequest;

#define kUAConnectionTypeNone @"none"
#define kUAConnectionTypeCell @"cell"
#define kUAConnectionTypeWifi @"wifi"

/**
 * The UAUtils object provides an interface for utility methods.
 */
@interface UAUtils : NSObject

///---------------------------------------------------------------------------------------
/// @name Device ID Utils
///---------------------------------------------------------------------------------------

/**
 * Get the device model name. e.g., iPhone3,1
 * @return The device model name.
 */
+ (NSString *)deviceModelName;

/**
 * Gets the Urban Airship Device ID.
 *
 * @return The device ID, or an empty string if the ID cannot be retrieved or created.
 */
+ (NSString *)deviceID;

///---------------------------------------------------------------------------------------
/// @name UAHTTP Authenticated Request Helpers
///---------------------------------------------------------------------------------------


+ (void)logFailedRequest:(UAHTTPRequest *)request withMessage:(NSString *)message;

/**
 * Returns a basic auth header string.
 *
 * The return value takes the form of: `Basic [Base64 Encoded "username:password"]`
 *
 * @return An HTTP Basic Auth header string value for the user's credentials.
 */
+ (NSString *)userAuthHeaderString;


/**
 * Returns a basic auth header string.
 *
 * The return value takes the form of: `Basic [Base64 Encoded "username:password"]`
 *
 * @return An HTTP Basic Auth header string value for the app's credentials.
 */
+ (NSString *)appAuthHeaderString;

///---------------------------------------------------------------------------------------
/// @name UI Formatting Helpers
///---------------------------------------------------------------------------------------

+ (NSString *)pluralize:(int)count
           singularForm:(NSString*)singular
             pluralForm:(NSString*)plural;

+ (NSString *)getReadableFileSizeFromBytes:(double)bytes;

///---------------------------------------------------------------------------------------
/// @name Date Formatting
///---------------------------------------------------------------------------------------

/**
 * Creates an ISO dateFormatter (UTC) with the following attributes:
 * locale set to 'en_US_POSIX', timestyle set to 'NSDateFormatterFullStyle',
 * date format set to 'yyyy-MM-dd HH:mm:ss'.
 *
 * @return A DateFormatter with the default attributes.
 */
+ (NSDateFormatter *)ISODateFormatterUTC;

/**
 * Creates an ISO dateFormatter (UTC) with the following attributes:
 * locale set to 'en_US_POSIX', timestyle set to 'NSDateFormatterFullStyle',
 * date format set to 'yyyy-MM-dd'T'HH:mm:ss'. The formatter returned by this method
 * is identical to that of `ISODateFormatterUTC`, except that the format matches the optional
 * `T` delimiter between date and time.
 *
 * @return A DateFormatter with the default attributes, matching the optional `T` delimiter.
 */
+ (NSDateFormatter *)ISODateFormatterUTCWithDelimiter;


///---------------------------------------------------------------------------------------
/// @name File management
///---------------------------------------------------------------------------------------

/**
 * Sets a file or directory at a url to not backup in
 * iCloud or iTunes
 * @param url The items url
 * @return YES if successful, NO otherwise
 */
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)url;

/**
 * Returns the main window for the app. This window will
 * be positioned underneath any other windows added and removed at runtime, by
 * classes such a UIAlertView or UIActionSheet.
 *
 * @return The main window, or `nil` if the window cannot be found.
 */
+ (nullable UIWindow *)mainWindow;

/**
 * A utility method that grabs the top-most view controller for the main application window.
 * May return nil if a suitable view controller cannot be found.
 * @return The top-most view controller or `nil` if controller cannot be found.
 */
+ (nullable UIViewController *)topController;

/**
 * Returns the main window's bounds, in orientation-dependent coordinates.
 * As this is the default behavior in iOS 8, the method is intended as a
 * utility for backwards compatibility.
 *
 * @return A CGRect representing the main window's bounds, in orientation-dependent coordinates.
 */
+ (CGRect)orientationDependentWindowBounds;

/**
 * Gets the current connection type.
 * Possible values are "cell", "wifi", or "none".
 * @return The current connection type as a string.
 */
+ (NSString *)connectionType;

///---------------------------------------------------------------------------------------
/// @name Notification payload
///---------------------------------------------------------------------------------------

/**
 * Determine if the notification payload is a background push (no notification elements).
 * @param notification The notification payload
 * @return `YES` if it is a background push, `NO` otherwise
 */
+ (BOOL)isBackgroundPush:(NSDictionary *)notification;

@end

NS_ASSUME_NONNULL_END
