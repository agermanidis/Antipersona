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
    var currentListId: String?

    var name: String?
    var screenName: String?
    var profileDescription: String?
    var profilePictureUrl: String?
    var profileColor: String?
    var userId: Int
    var ctime: NSDate
    
    var homeTimeline = Buffer(capacity: Constants.TIMELINE_BUFFER_CAPACITY)
    var notifications = Buffer(capacity: Constants.TIMELINE_BUFFER_CAPACITY)
    var userTimeline = Buffer(capacity: Constants.TIMELINE_BUFFER_CAPACITY)
    
    var following = Buffer(capacity: Constants.USER_LIST_BUFFER_CAPACITY)
    var followers = Buffer(capacity: Constants.USER_LIST_BUFFER_CAPACITY)
    
    init(userId: Int) {
        self.ctime = NSDate()
        self.userId = userId
    }
    
    init(userId: Int, ctime: NSDate) {
        self.ctime = ctime
        self.userId = userId
    }
    
    func canSwitch() -> Bool {
        return NSDate().daysDiff(ctime) > 0
    }
    
    var started = false
    
    func start() {
        workers.forEach({ $0.start() })
    }

    func startBackgroundMode() {
        workers.forEach({ $0.startBackgroundMode() })
    }
    
    func stop() {
        workers.forEach({ $0.stop() })
    }

    func ready() -> Bool {
        return workers.filter({ $0.runCount == 0 }).count == 0
    }
    
    func profileReady() -> Bool {
        for worker in workers {
            if worker.dynamicType == ProfileWorker.self {
                return worker.runCount > 0
            }
        }
        return false
    }
    
    func serialize() -> Dict {
        var ret = Dict()
        ret["userId"] = userId
        ret["screenName"] = screenName
        ret["name"] = name
        ret["profileDescription"] = profileDescription
        ret["homeTimeline"] = (homeTimeline.freeze() as! [Tweet]).map({ $0.serialize() })
        ret["notifications"] = (notifications.freeze() as! [Notification]).map({ $0.serialize() })
        ret["userTimeline"] = (userTimeline.freeze() as! [Tweet]).map({ $0.serialize() })
        ret["following"] = (following.freeze() as! [User]).map({ $0.serialize() })
        ret["followers"] = (followers.freeze() as! [User]).map({ $0.serialize() })
        return ret
    }
    
    static func deserialize(dict: Dict) -> ShadowedUser {
        let user = ShadowedUser(userId: dict["userId"] as! Int)

        for (key, value) in dict {
            switch key {
            case "userId":
                user.userId = value as! Int
                
            case "screenName":
                user.screenName = value as? String
                
            case "name":
                user.name = value as? String
                
            case "profileDescription":
                user.profileDescription = value as? String
        
            case "profilePictureUrl":
                user.profilePictureUrl = value as? String
                
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
                
            default:
                continue
            }
        }
        
        return user
    }
}
