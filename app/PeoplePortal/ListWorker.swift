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
    var queue : [[String]]?
    var requestTimer: NSTimer?
    
    func queueNext() {
        let user = Session.shared.shadowedUser!
        let swifter = Session.shared.swifter!
        
        if let next = queue!.popLast() {
            print(next)
            swifter.postListsMembersCreateWithListID(user.listId!, userIDs: next as [String], includeEntities: false, skipStatus: false, success: {
                (response) -> Void in

                print("Added \(next.count) items")

                }, failure: nil)
        } else {
            requestTimer?.invalidate()
            runCount += 1
        }
    }
    
    override func run() {
        let shadowedUser = Session.shared.shadowedUser!
        let swifter = Session.shared.swifter!
        let uid = String(shadowedUser.user.userId!)
        
        swifter.getFriendsIDsWithID(uid, cursor: nil, stringifyIDs: nil, count: nil, success: {
            (ids, previousCursor, nextCursor) -> Void in
            
            let idStrings = ids!.reverse().map({ String($0.integer!) })
            self.queue = idStrings.splitByN(100)
            
            swifter.postListsCreateWithName("PeoplePortal", publicMode: false, description: "PeoplePortal List", success: {
                response in
                
                let listId = response!["id_str"]!.string!
                shadowedUser.listId = listId
                print("new list id is ", listId)
                
                self.requestTimer = NSTimer.scheduledTimerWithTimeInterval(
                    ListWorker.TIME_INTERVAL,
                    target: self,
                    selector: "queueNext",
                    userInfo: nil,
                    repeats: true
                )

                }, failure: {
                    err in
                    
                    print("Error creating list: \(err)")
                    
            })
            })
    }
    
}
