//
//  UserInfoWorker.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/18/15.
//  Copyright © 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit
import Async

class FriendsWorker: Worker {
    var requestsCount = 0
    var totalRequests = 0
    var currentCursor: String? = nil
    var users = [User]()
    
    override func frequency() -> NSTimeInterval? {
        return 60.0
    }
    
    override func backgroundFrequency() -> NSTimeInterval? {
        return 120.0
    }
    
    override func runOnce() {
        let shadowedUser = Session.shared.shadowedUser!
        requestsCount = 0
        totalRequests = min(5, Int(ceil(Double(shadowedUser.user.followerCount!) / 200.0)))
        print("Total Requests = \(totalRequests)")
        makeNextRequest()
    }
    
    func makeNextRequest() {
        let shadowedUser = Session.shared.shadowedUser!
        let userId = String(shadowedUser.user.userId!)
        
        print("Getting list of friends")
        Session.shared.swifter?.getFriendsListWithID(
            userId,
            cursor: currentCursor,
            count: 200,
            skipStatus: true,
            includeUserEntities: true,
            success: {
                users, previousCursor, nextCursor in
                
                self.currentCursor = nextCursor
                self.requestsCount += 1
                
                for user in users! {
                    self.users.append(User.deserializeJSON(user.object!))
                }
                
                Async.main(after: 1.0) {
                    if self.requestsCount < self.totalRequests {
                        self.makeNextRequest()
                    } else {
                        self.runCount += 1
                        shadowedUser.following.replace(self.users)
                    }
                }
                
            }, failure: {
                error in
                
        })
    }
}