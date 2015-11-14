//
//  Tweet.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/10/15.
//  Copyright (c) 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit

class Tweet: Comparable, Hashable {
    var tweetId: Int?
    var ctime: NSDate?
    var text: String?
    var user: User?
    var favoriteCount: Int?
    var retweetCount: Int?
    var retweetedStatus: Tweet?
    
    func isRetweet() -> Bool {
        return retweetedStatus != nil
    }
    
    static func deserialize(serialized: Dict) -> Tweet {
        let ret = Tweet()
        ret.tweetId = serialized["id"] as? Int
        ret.ctime = NSDate.fromString(serialized["created_at"] as! String)
        ret.favoriteCount = serialized["favorite_count"] as? Int
        ret.retweetCount = serialized["retweet_count"] as? Int
        ret.text = serialized["text"] as? String
        ret.user = User.deserialize(serialized["user"] as! Dict)
        if serialized["retweeted_status"] != nil {
            ret.retweetedStatus = Tweet.deserialize(serialized["retweeted_status"] as! Dict)
        }
        return ret
    }
    
    static func deserializeJSON(serialized: Dictionary<String, JSON>) -> Tweet {
        let ret = Tweet()
        ret.tweetId = serialized["id"]!.integer
        if serialized["created_at"]!.string != nil {
            ret.ctime = NSDate.fromString(serialized["created_at"]!.string!)
        }
        ret.favoriteCount = serialized["favorite_count"]!.integer
        ret.retweetCount = serialized["retweet_count"]!.integer
        ret.text = serialized["text"]!.string
        if serialized["user"]?.object != nil {
            ret.user = User.deserializeJSON(serialized["user"]!.object!)
        }
        if serialized["retweeted_status"]?.object != nil {
            ret.retweetedStatus = Tweet.deserializeJSON(serialized["retweeted_status"]!.object!)
        }
        return ret
    }
    
    func serialize() -> Dict {
        var ret = Dict()
        ret["id"] = tweetId!
        ret["created_at"] = ctime!.toString()
        ret["favorite_count"] = favoriteCount!
        ret["retweet_count"] = retweetCount!
        ret["text"] = text!
        ret["user"] = user!.serialize()
        if isRetweet() {
            ret["retweeted_status"] = retweetedStatus!.serialize()
        }
        return ret
    }
    
    func calculateCellHeight(font: UIFont, width: CGFloat) -> CGFloat {
        return NSString(string: text!).boundingRectWithSize(CGSize(width: width, height: CGFloat(NSIntegerMax)), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil).size.height
    }
    
    var hashValue: Int {
        return self.tweetId ?? 0
    }
}

func < (lhs: Tweet, rhs: Tweet) -> Bool {
    return lhs.ctime < rhs.ctime
}

func == (lhs: Tweet, rhs: Tweet) -> Bool {
    return lhs.ctime == rhs.ctime
}

