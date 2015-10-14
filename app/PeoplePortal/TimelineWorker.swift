//
//  TimelineWorker.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/14/15.
//  Copyright © 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit

class TimelineWorker: Worker {
    let timeInterval = 60.0
    
    var runCount = 0
    var timer : NSTimer?
    
    func run() {
        timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: "getLatestStatuses", userInfo: nil, repeats: true)
    }
    
    func stop() {
        timer?.invalidate()
    }
    
    func getLatestStatuses() {
        let user = Session.shared.shadowedUser!
        let swifter = Session.shared.swifter!
        let listId = user.currentListId!
        let userId = String(user.userId)
        let lastTweet = user.userTimeline.last as? Tweet
       
        var sinceID:String? = nil
        if lastTweet != nil {
            sinceID = String(lastTweet?.tweetId)
        }

        swifter.getListsStatusesWithListID(listId, ownerID: userId, sinceID: sinceID, maxID: nil, count: 200, includeEntities: false, includeRTs: true, success: {
            statuses in

            for status in statuses! {
                let tweet = Tweet.deserializeJSON(status.object!)
                user.homeTimeline.add(tweet)
            }
            self.runCount += 1
        }, failure: nil)
    }
}
