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

/** Required for building a location provider */
#import "UALocationCommonValues.h"

NS_ASSUME_NONNULL_BEGIN

@protocol UALocationProviderProtocol <NSObject>
@required
/**
 * Required location manager for any location services.
 */
@property (nonatomic, retain) CLLocationManager *locationManager;

/**
 * The distance filter.
 */
@property (nonatomic, assign) CLLocationDistance distanceFilter;

/**
 * The desired accuracy.
 */
@property (nonatomic, assign) CLLocationAccuracy desiredAccuracy;

/**
 * Current status of the location provider.
 */
@property (nonatomic, assign) UALocationProviderStatus serviceStatus;

/** 
 * This is a required parameter on the CLLocationManager and is presented to the user for authentication.
 */
@property (nonatomic, copy) NSString *provider;

/**
 * The UALocationProviderDelegate that will receive updates.
 */
@property (nonatomic, assign, nullable) id delegate;

/**
 * Purpose for location services shown to user
 * when prompted to allow location services to begin. The default value
 * is the NSLocationUsageDescription listed in the info.plist. This value cannot be set
 * programatically.
 * @return An NSString with the current purpose
 */
- (nullable NSString *)purpose;

/**
 * Starts updating location.
 */
- (void)startReportingLocation;

/**
 * Stops providing location updates.
 */
- (void)stopReportingLocation;

@end

NS_ASSUME_NONNULL_END

