//
//  Tweet.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/10/15.
//  Copyright (c) 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit

class Tweet {
    var tweetId : Int?
    var ctime : NSDate?
    var favoriteCount : Int?
    var retweetCount : Int?
    var text : String?
    var user : User?
    
    static func deserialize(serialized:Dict) -> Tweet {
        var ret = Tweet()
        ret.tweetId = serialized["id"] as? Int
        ret.ctime = NSDate.fromString(serialized["ctime"] as! String)
        ret.favoriteCount = serialized["favoriteCount"] as? Int
        ret.retweetCount = serialized["retweetCount"] as? Int
        ret.text = serialized["text"] as? String
        ret.user = User.deserialize(serialized["user"] as! Dict)
        return ret
    }
    
    func serialize() -> Dict {
        var ret = Dict()
        ret["id"] = tweetId!
        ret["ctime"] = ctime!.toString()
        ret["favoriteCount"] = favoriteCount!
        ret["retweetCount"] = retweetCount!
        ret["text"] = text!
        ret["user"] = user!.serialize()
        return ret
    }
}
