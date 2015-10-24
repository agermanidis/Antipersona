//
//  Notification.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/11/15.
//  Copyright (c) 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit

class Notification: Comparable {    
    var type : Int?
    var users : [User]?
    var tweet : Tweet?
    var seen: Bool = false
    var ctime: NSDate?
    
    init() {
        ctime = NSDate()
    }

    static func deserialize(serialized: Dict) -> Notification {
        let ret = Notification()
        ret.type = serialized["type"] as? Int
        if serialized["users"] != nil {
            ret.users = (serialized["users"] as! [Dict]).map({ User.deserialize($0) })
        }
        if serialized["tweet"] != nil {
            ret.tweet = Tweet.deserialize(serialized["tweet"]! as! Dict)
        }
        ret.seen = serialized["seen"] as! Bool        
        ret.ctime = NSDate.fromString(serialized["created_at"] as! String)
        return ret
    }
    
    func serialize() -> Dict {
        var ret = Dict()
        ret["type"] = self.type!
        if self.users != nil {
            ret["users"] = self.users!.map({ $0.serialize() })
        }
        if self.tweet != nil {
            ret["tweet"] = self.tweet!.serialize()
        }
        ret["seen"] = seen
        ret["created_at"] = ctime!.toString()
        return ret
    }
}

func < (lhs: Notification, rhs: Notification) -> Bool {
    return lhs.ctime < rhs.ctime
}

func == (lhs: Notification, rhs: Notification) -> Bool {
    return lhs.ctime == rhs.ctime
}
