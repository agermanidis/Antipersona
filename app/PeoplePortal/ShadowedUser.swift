//
//  ShadowedUser.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/10/15.
//  Copyright (c) 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit
import Async

struct WorkerCheck: Hashable {
    var workers: [Worker]
    var startTime: NSDate
    var callback: () -> ()
    var hashValue: Int {
        get {
            return "\(workers[0].dynamicType) \(startTime)".hashValue
        }
    }
}

func ==(lhs: WorkerCheck, rhs: WorkerCheck) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

class ShadowedUser : NSObject {
    var workers: [Worker] = [
        ListWorker(),
        ProfileWorker(),
        FriendsWorker(),
        FollowersWorker(),
        TimelineWorker()
    ]
    
    var continuousWorkers: [Worker] {
        get {
            var ret:[Worker] = []
            for worker in workers {
                if worker.dynamicType != ListWorker.self {
                    ret.append(worker)
                }
            }
            return ret
        }
    }
    
    var listId: String?
    var user: User
    var ctime: NSDate
    
    var homeTimeline = Buffer<Tweet>(capacity: Constants.TIMELINE_BUFFER_CAPACITY)
    var userTimeline = Buffer<Tweet>(capacity: Constants.TIMELINE_BUFFER_CAPACITY)
    
    var notifications = Buffer<Notification>(capacity: Constants.NOTIFICATIONS_BUFFER_CAPACITY)
    
    var following = Buffer<User>(capacity: Constants.USER_LIST_BUFFER_CAPACITY)
    var followers = Buffer<User>(capacity: Constants.USER_LIST_BUFFER_CAPACITY)
    
    init(user: User) {
        self.ctime = NSDate()
        self.user = user
        self.user.calculateColor()
    }
    
    init(user: User, ctime: NSDate) {
        self.ctime = ctime
        self.user = user
        self.user.calculateColor()
    }
    
    var started = false
    
    var loadCallback: (() -> ())?
    var loadCheckTimer: NSTimer?
    func onLoad(callback: () -> ()) {
        loadCallback = callback
    }
    
    var currentWorkerIndex: Int = 0
    var currentWorker: Worker? {
        get {
            return workers[currentWorkerIndex]
        }
    }
    
    func load() {
        Async.main {
            self.loadCheckTimer = NSTimer.scheduledTimerWithTimeInterval(
                0.5,
                target: self,
                selector: "loadCheck",
                userInfo: nil,
                repeats: true
            )
         }
        
        currentWorker!.start()
    }
    
    func loadCheck() {
        if currentWorker?.runCount > 0 {
            currentWorkerIndex += 1
            if currentWorkerIndex < workers.count {
                currentWorker!.start()
            } else {
                loadCheckTimer?.invalidate()
                loadCallback?()
            }
        }
    }

    
    func unload(callback: (() -> ())?) {
        if listId == nil {
            callback?()
            
        } else {
            Session.shared.swifter?.postListsDestroyWithListID(listId!, success: {
                (response) -> Void in

                print("destroyed list")
                callback?()

                }, failure: nil)
        }
    }

    func reload(callback: (() -> ())) {
        
    }
    
    var checkTimeout = 5.0
    var checks = Set<WorkerCheck>()
    var checkTimer: NSTimer? = nil
    func checkLoop() {
        var toRemove: [WorkerCheck] = []
        
        for check in checks {
            let workers = check.workers
            let date = check.startTime
            let callback = check.callback
            var success = true
            for worker in workers {
                if worker.lastRunTime == nil {
                    success = false
                    continue
                }
                if worker.lastRunTime!.isEarlierThan(date) && date.secondsAgo() < checkTimeout {
                    success = false
                }
            }
            if success {
                Async.background {
                    callback()
                }
                toRemove.append(check)
            }
        }
        
        while !toRemove.isEmpty {
            checks.remove(toRemove.popLast()!)
        }
        
        if checks.isEmpty {
            checkTimer?.invalidate()
            checkTimer = nil
        }
    }
    
    func waitForWorkers(workerTypes: [Worker.Type], callback: () -> ()) {
        let workers = workerTypes.map({getWorker($0)!})
        let check = WorkerCheck(
            workers: workers,
            startTime: NSDate(),
            callback: callback
        )
        checks.insert(check)
        workers.forEach({$0.runOnce()})
        
        if checkTimer == nil {
            checkTimer = NSTimer.scheduledTimerWithTimeInterval(
                0.5,
                target: self,
                selector: "checkLoop",
                userInfo: nil,
                repeats: true
            )
        }
    }
    
    func getWorker(type: Worker.Type) -> Worker? {
        for worker in workers {
            if worker.dynamicType == type {
                return worker
            }
        }
        return nil
    }

    func start() {
        continuousWorkers.forEach({ $0.start() })
    }
    
    func startBackgroundMode() {
        continuousWorkers.forEach({ $0.startBackgroundMode() })
    }
    
    func stop() {
        continuousWorkers.forEach({ $0.stop() })
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
    
    func hoursSinceSwitch() -> Int {
        return NSDate().hoursDiff(ctime)
    }
    
    func serialize() -> Dict {
        var ret = Dict()
        ret["user"] = user.serialize()
        ret["ctime"] = ctime.toString()
        ret["listId"] = listId
        ret["ready"] = ready()
        ret["homeTimeline"] = homeTimeline.items.map({ $0.serialize() })
        ret["notifications"] = notifications.items.map({ $0.serialize() })
        ret["userTimeline"] = userTimeline.items.map({ $0.serialize() })
        ret["following"] = following.items.map({ $0.serialize() })
        ret["followers"] = followers.items.map({ $0.serialize() })
        return ret
    }
    
    static func deserialize(dict: Dict) -> ShadowedUser {
        let userObj = User.deserialize(dict["user"] as! Dict)
        let ctime = NSDate.fromString(dict["ctime"] as! String)
        let user = ShadowedUser(user: userObj, ctime: ctime)

        for (key, value) in dict {
            switch key {

            case "listId":
                user.listId = value as? String
                
            case "userTimeline":
                let tweetObjects = value as! [Dict]
                let tweets = tweetObjects.map({ Tweet.deserialize($0) })
                user.userTimeline = Buffer<Tweet>(capacity: Constants.TIMELINE_BUFFER_CAPACITY, items: tweets)
                
            case "homeTimeline":
                let tweetObjects = value as! [Dict]
                let tweets = tweetObjects.map({ Tweet.deserialize($0) })
                user.homeTimeline = Buffer<Tweet>(capacity: Constants.TIMELINE_BUFFER_CAPACITY, items: tweets)
                
            case "notifications":
                let notificationsObjects = value as! [Dict]
                let notifications = notificationsObjects.map({ Notification.deserialize($0) })
                user.notifications = Buffer<Notification>(capacity: Constants.TIMELINE_BUFFER_CAPACITY, items: notifications)
                
            case "following":
                let followingObjects = value as! [Dict]
                let following = followingObjects.map({ User.deserialize($0) })
                user.following = Buffer<User>(capacity: Constants.USER_LIST_BUFFER_CAPACITY, items: following)
            
            case "followers":
                let followerObjects = value as! [Dict]
                let followers = followerObjects.map({ User.deserialize($0) })
                user.followers = Buffer<User>(capacity: Constants.USER_LIST_BUFFER_CAPACITY, items: followers)

            default:
                continue
            }
        }
        
        return user
    }
}
