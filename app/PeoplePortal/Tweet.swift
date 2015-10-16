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
    var text : String?
    var user : User?
    var favoriteCount : Int?
    var retweetCount : Int?
    
    static func deserialize(serialized:Dict) -> Tweet {
        let ret = Tweet()
        ret.tweetId = serialized["id"] as? Int
        ret.ctime = NSDate.fromString(serialized["created_at"] as! String)
        ret.favoriteCount = serialized["favorite_count"] as? Int
        ret.retweetCount = serialized["retweet_count"] as? Int
        ret.text = serialized["text"] as? String
        ret.user = User.deserialize(serialized["user"] as! Dict)
        return ret
    }
    
    static func deserializeJSON(serialized:Dictionary<String, JSON>) -> Tweet {
        let ret = Tweet()
        ret.tweetId = serialized["id"]!.integer
        ret.ctime = NSDate.fromString(serialized["created_at"]!.string!)
        ret.favoriteCount = serialized["favorite_count"]!.integer
        ret.retweetCount = serialized["retweet_count"]!.integer
            ret.text = serialized["text"]!.string
        ret.user = User.deserializeJSON(serialized["user"]!.object!)
        return ret
    }
    
    func serialize() -> Dict {
        var ret = Dict()
        ret["id"] = tweetId!
        ret["created_at"] = ctime!.toString()
        ret["favourites_count"] = favoriteCount!
        ret["retweet_count"] = retweetCount!
        ret["text"] = text!
        ret["user"] = user!.serialize()
        return ret
    }
}
