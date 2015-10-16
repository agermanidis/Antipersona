//
//  TimelineConstructionWorker.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/10/15.
//  Copyright (c) 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit

class ListWorker: Worker {
    static let TIME_INTERVAL:Double = 2.0
    
    var queue : [[Any]]?
    var timer : NSTimer?
    var runCount = 0
    
    func queueNext() {
        let user = Session.shared.shadowedUser!
        let swifter = Session.shared.swifter!
        
        if let next = queue?.popLast() as? [String] {
            swifter.postListsMembersCreateWithListID(user.currentListId!, userIDs: next, includeEntities: false, skipStatus: false, success: {
                response in
                
                print("Added %d items", next.count)
                
                }, failure: nil)
        } else {
            timer?.invalidate()
            runCount += 1
        }
    }
    
    func startBackgroundMode() {
        
    }
    
    func stop() {
//        timer?.invalidate()
    }
    
    func start() {
        let user = Session.shared.shadowedUser!
        let swifter = Session.shared.swifter!
        let oldListId = user.currentListId!
        
        swifter.getFriendsIDsWithID(String(user.userId), cursor: nil, stringifyIDs: false, count: 1000, success: {
            ids, previousCursor, nextCursor in
            
            let idStrings = ids!.reverse().map({ $0.string }) as! [String]
            self.queue = idStrings.splitByN(100)
            
            swifter.postListsCreateWithName("PeoplePortal", publicMode: false, description: "PeoplePortal List", success: {
                response in
                
                let listId = response?["id_str"]?.string
                user.currentListId = listId
                print("new list id is ", listId)

                swifter.postListsDestroyWithListID(oldListId, success: {
                    response in
                    
                    self.timer = NSTimer.scheduledTimerWithTimeInterval(ListWorker.TIME_INTERVAL, target: self, selector: "queueNext", userInfo: nil, repeats: true)
                    
                    }, failure: nil)
                }, failure: nil)
            }, failure:nil)
    }
    
}
