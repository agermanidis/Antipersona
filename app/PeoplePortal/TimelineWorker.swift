//
//  TimelineWorker.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/14/15.
//  Copyright © 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit

class TimelineWorker: Worker {
    override func frequency() -> NSTimeInterval? {
        return 15.0
    }
    
    override func backgroundFrequency() -> NSTimeInterval? {
        return 240.0
    }
    
    override func runOnce() {
        getLatestStatuses()
    }
    
    func getLatestStatuses() {
        print("getting latest statuses")
        
        let shadowedUser = Session.shared.shadowedUser!
        let swifter = Session.shared.swifter!
        let listId = shadowedUser.listId!
        let userId = String(shadowedUser.user.userId)
        let lastTweet = shadowedUser.userTimeline.first
       
        var sinceID:String? = nil
        if lastTweet != nil {
            sinceID = String(lastTweet!.tweetId!)
        }

        swifter.getListsStatusesWithListID(listId, ownerID: userId, sinceID: sinceID, maxID: nil, count: 200, includeEntities: false, includeRTs: true, success: {
            statuses in
            
            for status in statuses! {
                let tweet = Tweet.deserializeJSON(status.object!)
                if !shadowedUser.homeTimeline.items.contains(tweet) {
                    shadowedUser.homeTimeline.add(tweet)
                }
            }
            
            shadowedUser.homeTimeline.items.sortInPlace()
            shadowedUser.homeTimeline.reverse()
            
            self.runCount += 1
            }, failure: {
                error in
                
                print("error: \(error)")
                
        })
    }
}
