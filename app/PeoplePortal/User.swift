//
//  User.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/11/15.
//  Copyright (c) 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit

class User: NSObject {
    var userId : Int?
    var name : String?
    var screenName : String?
    var profileImageUrl : String?
    var verified : Bool?
    
    static func deserialize(serialized:Dict) -> User {
        var ret = User()
        ret.userId = serialized["id"] as? Int
        ret.name = serialized["name"] as? String
        ret.screenName = serialized["screenName"] as? String
        ret.profileImageUrl = serialized["profileImageUrl"] as? String
        ret.verified = serialized["verified"] as? Bool
        return ret
    }
    
    func serialize() -> Dict {
        var ret = Dict()
        ret["id"] = userId!
        ret["name"] = name!
        ret["screenName"] = screenName!
        ret["profileImageUrl"] = profileImageUrl!
        ret["verified"] = verified!
        return ret
    }
}
