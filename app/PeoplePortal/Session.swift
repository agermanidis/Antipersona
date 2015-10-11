//
//  Session.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/11/15.
//  Copyright (c) 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit

class Session {
    static let shared = Session.retrieve()
    
    var shadowedUser : ShadowedUser?
    var notificationsEnabled = true
    
    func serialize() -> Dict {
        var ret = Dict()
        if let serializedUser = shadowedUser?.serialize() {
            ret["user"] = serializedUser
        }
        ret["notificationsEnabled"] = notificationsEnabled
        return ret
    }
    
    func save() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(serialize(), forKey: "session")
    }
    
    static func deserialize(dict:Dict) -> Session {
        let session = Session()
        session.notificationsEnabled = dict["notificationsEnabled"] as! Bool
        session.shadowedUser = ShadowedUser.deserialize(dict["user"] as! Dict)
        return session
    }
    
    static func retrieve() -> Session {
        let defaults = NSUserDefaults.standardUserDefaults()
        let retrieved = defaults.dictionaryForKey("session") as? Dict
        if retrieved != nil {
            return deserialize(retrieved!)
        } else {
            return Session()
        }
    }
}
