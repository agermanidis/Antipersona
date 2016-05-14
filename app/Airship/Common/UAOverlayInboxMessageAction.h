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

#import "UAAction.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Requests an inbox message to be displayed in an overlay.
 *
 * This action is registered under the names open_mc_overlay_action and ^mco.
 *
 * Expected argument value is an inbox message ID as an NSString or "MESSAGE_ID"
 * to look for the message in the argument's metadata.
 *
 * Valid situations: UASituationForegroundPush, UASituationLaunchedFromPush, UASituationWebViewInvocation,
 * UASituationManualInvocation, and UASituationForegroundInteractiveButton.
 *
 * Result value: nil
 *
 * Default predicate: Rejects situation UASituationForegroundPush.
 */
@interface UAOverlayInboxMessageAction : UAAction

@end

/**
 * Represents the possible error conditions
 * when running a `UAOverlayInboxMessageAction`.
 */
typedef NS_ENUM(NSInteger, UAOverlayInboxMessageActionErrorCode) {
    /**
     * Indicates that the message was unavailable.
     */
    UAOverlayInboxMessageActionErrorCodeMessageUnavailable
};

/**
 * The domain for errors encountered when running a `UAOverlayInboxMessageAction`.
 */
extern NSString * const UAOverlayInboxMessageActionErrorDomain;

NS_ASSUME_NONNULL_END
