//
//  CleanupWorker.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/26/15.
//  Copyright © 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit

class CleanupWorker: Worker {
    static let TIME_INTERVAL:Double = 2.0
    var queue: [String] = []
    var requestTimer: NSTimer?
    
    func queueNext() {
        let swifter = Session.shared.swifter!
        
        if let next = queue.popLast() {
            print(next)
            swifter.postListsDestroyWithListID(next, success: {
                list in
                
                print("Destroy list with id \(next)")
                
                }, failure: {
                    error in
                    
                    print("Error: \(error)")
            })
        } else {
            requestTimer?.invalidate()
            runCount += 1
        }

    }
    
    override func run() {
        Session.shared.swifter?.getListsSubscribedByUserWithReverse(false, success: {
            lists in
            
            for list in lists! {
                let listId = list["id_str"].string!
                let listName = list["name"].string!
                let userId = list["user"].object!["id"]!.bigInteger
                if listName == "PeoplePortal" && listId != Session.shared.shadowedUser!  .listId && userId == Session.shared.me?.userId {
                    self.queue.append(listId)
                }
            }
            
            if self.queue.count > 0 {
                self.requestTimer = NSTimer.scheduledTimerWithTimeInterval(
                    ListWorker.TIME_INTERVAL,
                    target: self,
                    selector: "queueNext",
                    userInfo: nil,
                    repeats: true
                )
            } else {
                self.runCount += 1
            }
            
            },failure: {
                error in
                
        })
        
    }
}
