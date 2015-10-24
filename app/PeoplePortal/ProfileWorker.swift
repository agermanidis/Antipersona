//
//  ProfileWorker.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/14/15.
//  Copyright © 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit

class ProfileWorker: Worker {
    override func frequency() -> NSTimeInterval? {
        return 120.0
    }
    
    override func backgroundFrequency() -> NSTimeInterval? {
        return 240.0
    }
    
    override func runOnce() {
        print("getting statuses ")
        let shadowedUser = Session.shared.shadowedUser!
        let swifter = Session.shared.swifter!
        let lastTweet = shadowedUser.userTimeline.first
        let uid = shadowedUser.user.userIdString!
        
        var sinceID: String? = nil
        if lastTweet != nil {
            sinceID = String(lastTweet!.tweetId!)
        }
        
        swifter.getStatusesUserTimelineWithUserID(uid, count: 200, sinceID: sinceID, maxID: nil, trimUser: false, contributorDetails: false, includeEntities: false, success: {
            statuses in
            
            print("adding statuses")
            
            for status in statuses! {
                let tweet = Tweet.deserializeJSON(status.object!)
                if !shadowedUser.userTimeline.items.contains(tweet) {
                    shadowedUser.userTimeline.add(tweet)
                }
            }
            
            shadowedUser.userTimeline.items.sortInPlace()
            shadowedUser.userTimeline.reverse()
            
            self.runCount += 1

            }, failure: {
                error in
                
                print("ERROR: \(error)")
        })
    }

}
