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
    
    func isShadowedUser() -> Bool {
        return userId == Session.shared.shadowedUser?.userId
    }
    
    static func deserialize(serialized:Dict) -> User {
        let ret = User()
        ret.userId = serialized["id"] as? Int
        ret.name = serialized["name"] as? String
        ret.screenName = serialized["screen_name"] as? String
        ret.profileImageUrl = serialized["profile_image_url"] as? String
        ret.verified = serialized["verified"] as? Bool
        return ret
    }
    
    func serialize() -> Dict {
        var ret = Dict()
        ret["id"] = userId!
        ret["name"] = name!
        ret["screen_name"] = screenName!
        ret["profile_image_url"] = profileImageUrl!
        ret["verified"] = verified!
        return ret
    }
}
