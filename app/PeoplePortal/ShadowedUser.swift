//
//  ShadowedUser.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/10/15.
//  Copyright (c) 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit

class ShadowedUser : NSObject {
    var workers = [Worker]()
    
    var homeTimeline = Buffer(capacity: Constants.TIMELINE_BUFFER_CAPACITY)
    var notifications = Buffer(capacity: Constants.TIMELINE_BUFFER_CAPACITY)
    var userTimeline = Buffer(capacity: Constants.TIMELINE_BUFFER_CAPACITY)
    
    var following = Buffer(capacity: Constants.USER_LIST_BUFFER_CAPACITY)
    var followers = Buffer(capacity: Constants.USER_LIST_BUFFER_CAPACITY)
    
    var username : String?
    var profileDescription : String?
    var profilePictureUrl : String?

    var currentListId : Int?
    
    var userId : Int
    var ctime : NSDate
    
    init(userId : Int) {
        self.ctime = NSDate()
        self.userId = userId
    }
    
    init(userId : Int, ctime : NSDate) {
        self.ctime = ctime
        self.userId = userId
    }
    
    var started = false
    
    func start() {
        // start workers
    }

    func startBackgroundMode() {
        // start background workers
    }
    
    func stop() {
        // stop
    }

    func ready() -> Bool {
        return workers.filter({$0.loopCount == 0}).count == 0
    }
    
    func serialize() -> Dict {
        return Dict()
    }
    
    static func deserialize(dict : Dict) -> ShadowedUser {
        var user = ShadowedUser(userId: dict["userId"] as! Int)

        for (key, value) in dict {
            switch key {
            case "userId":
                user.userId = value as! Int
                
            case "username":
                user.username = value as? String
                
            case "profileDescription":
                user.profileDescription = value as? String
                
            case "userTimeline":
                let tweetObjects = value as! [Dict]
                let tweets = tweetObjects.map({ Tweet.deserialize($0) })
                user.userTimeline = Buffer(capacity: Constants.TIMELINE_BUFFER_CAPACITY, items: tweets)
                
            case "homeTimeline":
                let tweetObjects = value as! [Dict]
                let tweets = tweetObjects.map({ Tweet.deserialize($0) })
                user.homeTimeline = Buffer(capacity: Constants.TIMELINE_BUFFER_CAPACITY, items: tweets)
                
            case "notifications":
                let notificationsObjects = value as! [Dict]
                let notifications = notificationsObjects.map({ Notification.deserialize($0) })
                user.notifications = Buffer(capacity: Constants.TIMELINE_BUFFER_CAPACITY, items: notifications)
                
            case "profilePictureUrl":
                user.profilePictureUrl = value as? String
                
            default:
                continue
            }
            
        }
        
        return user
    }
}
