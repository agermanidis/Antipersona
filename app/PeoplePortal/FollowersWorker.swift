//
//  UserInfoWorker.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/18/15.
//  Copyright © 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit
import Async

class FollowersWorker: Worker {
    var requestsCount = 0
    var totalRequests = 0
    var currentCursor: String? = nil
    var users = [User]()

    override func frequency() -> NSTimeInterval? {
        return 120.0
    }
    
    override func backgroundFrequency() -> NSTimeInterval? {
        return 440.0
    }
    
    override func run() {
        let shadowedUser = Session.shared.shadowedUser!
        requestsCount = 0
        totalRequests = min(1, Int(ceil(Double(shadowedUser.user.followerCount!) / 200.0)))
        print("Total Requests = \(totalRequests)")
        makeNextRequest()
    }
    
    func finish() {
        let shadowedUser = Session.shared.shadowedUser!
        var newUsers:[User] = []
        
        for user in self.users {
            if !shadowedUser.followers.items.contains(user) {
                newUsers.append(user)
            }
        }
        
        if newUsers.count > 0 && shadowedUser.followers.items.count > 0 {
            print("There are \(newUsers.count) new users")
            let notification: Notification = Notification()
            notification.type = Constants.NOTIFICATION_TYPE_FOLLOW
            notification.users = newUsers
            shadowedUser.notifications.add(notification)
            shadowedUser.notificationAdded(notification)
        }
        
        shadowedUser.followers.items = self.users
        
        self.runCount += 1
    }

    func makeNextRequest() {
        let shadowedUser = Session.shared.shadowedUser!
        let userId = String(shadowedUser.user.userId!)
       
        print("Getting list of followers")

        Session.shared.swifter?.getFollowersListWithID(
            userId,
            cursor: nil,
            count: 200,
            skipStatus: true,
            includeUserEntities: true,
            success: {
                users, previousCursor, nextCursor in
                
//                self.currentCursor = nextCursor
                self.requestsCount += 1

                for user in users! {
                    self.users.append(User.deserializeJSON(user.object!))
                }
                
                Async.background(after: 1.0) {
                    if self.requestsCount < self.totalRequests {
                        self.makeNextRequest()
                    } else {
                        self.finish()
                    }
                }
                
            }, failure: {
                error in
                
                print("FriendsWorker failed: \(error)")

        })
    }
}