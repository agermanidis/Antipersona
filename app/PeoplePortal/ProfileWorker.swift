//
//  ProfileWorker.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/14/15.
//  Copyright © 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit

class ProfileWorker: Worker {
    let timeInterval = 60.0
    
    var runCount = 0
    var timer : NSTimer?
    
    func start() {
        timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: "getLatestStatuses", userInfo: nil, repeats: true)
    }
    
    func startBackgroundMode() {
        
    }
    
    func stop() {
        timer?.invalidate()
    }
    
    func getLatestStatuses() {
        let user = Session.shared.shadowedUser!
        let swifter = Session.shared.swifter!
        let userId = String(user.userId)
        let lastTweet = user.userTimeline.last as? Tweet
        
        var sinceID:String? = nil
        if lastTweet != nil {
            sinceID = String(lastTweet?.tweetId)
        }
        
        swifter.getStatusesUserTimelineWithUserID(userId, count: 200, sinceID: sinceID, maxID: nil, trimUser: false, contributorDetails: false, includeEntities: false, success: {
            statuses in
            
            for status in statuses! {
                let tweet = Tweet.deserializeJSON(status.object!)
                user.userTimeline.add(tweet)
            }
            self.runCount += 1

            }, failure: nil)
    }

}
