//
//  Tweet.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/10/15.
//  Copyright (c) 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit

class Tweet: Comparable, Hashable {
    var tweetId: Int64?
    var ctime: NSDate?
    var text: String?
    var user: User?
    var favoriteCount: Int?
    var retweetCount: Int?
    var retweetedStatus: Tweet?
    var inReplyToId: Int64?
    var inReplyTo: Tweet?
    var replies: [Tweet] = []

    func isItMyRetweet() -> Bool {
        return Session.shared.shadowedUser?.user.userId == retweetedStatus?.user?.userId
    }
    
    func isRetweet() -> Bool {
        return retweetedStatus != nil
    }
    
    func isReply() -> Bool {
        return inReplyTo != nil
    }
    
    static func deserialize(serialized: Dict) -> Tweet {
        let ret = Tweet()
        ret.tweetId = (serialized["id"] as? NSNumber)?.longLongValue
        ret.ctime = NSDate.fromString(serialized["created_at"] as! String)
        ret.favoriteCount = serialized["favorite_count"] as? Int
        ret.retweetCount = serialized["retweet_count"] as? Int
        ret.text = serialized["text"] as? String
        ret.user = User.deserialize(serialized["user"] as! Dict)
        if serialized["retweeted_status"] != nil {
            ret.retweetedStatus = Tweet.deserialize(serialized["retweeted_status"] as! Dict)
        }
        ret.inReplyToId = (serialized["in_reply_to_status_id"] as? NSNumber)?.longLongValue
        return ret
    }
    
    static func deserializeJSON(serialized: Dictionary<String, JSON>) -> Tweet {
        let ret = Tweet()
        ret.tweetId = serialized["id"]!.bigInteger
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
        ret.inReplyToId = serialized["in_reply_to_status_id"]!.bigInteger
        return ret
    }
    
    func serialize() -> Dict {
        var ret = Dict()
        ret["id"] = NSNumber(longLong: tweetId!)
        ret["created_at"] = ctime!.toString()
        ret["favorite_count"] = favoriteCount!
        ret["retweet_count"] = retweetCount!
        ret["text"] = text!
        ret["user"] = user!.serialize()
        if isRetweet() {
            ret["retweeted_status"] = retweetedStatus!.serialize()
        }
        if inReplyToId != nil {
            ret["in_reply_to_status_id"] = NSNumber(longLong: inReplyToId!)
        }
        return ret
    }
    
    func calculateCellHeight(font: UIFont, width: CGFloat) -> CGFloat {
        return NSString(string: text!).boundingRectWithSize(CGSize(width: width, height: CGFloat(NSIntegerMax)), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil).size.height
    }
    
    var hashValue: Int {
        return self.tweetId?.hashValue ?? 0
    }
    
    func loadOriginal(cb: ()->()) {
        
    }
    
    func loadReplies(cb: ()->()) {
        var originalTweet:Tweet = self
        if isRetweet() {
            originalTweet = retweetedStatus!
        }
        
        let user = originalTweet.user
        
        print("@\(user!.screenName!)")
        
        Session.shared.swifter?.getSearchTweetsWithQuery("@\(user!.screenName!)", geocode: nil, lang: nil, locale: nil, resultType: "recent", count: 100, until: nil, sinceID: nil, maxID: nil, includeEntities: nil, callback: nil, success: {
            statuses, metadata in
            print("total statuses: \(statuses!.count)")
            
            var tweets: [Tweet] = []
            for status in statuses! {
                print(status.object!["text"])
                let deserialized = Tweet.deserializeJSON(status.object!)

                tweets.append(deserialized)
            }
            tweets = tweets.filter({
                print("one: \($0.inReplyToId), two: \(self.tweetId)")
                return $0.inReplyToId == self.tweetId
            })
            
            self.replies = tweets
            
            print("got \(tweets.count) replies")
            
            if self.inReplyToId != nil {
                Session.shared.swifter?.getStatusesShowWithID(String(self.inReplyToId!), count: 1, trimUser: false, includeMyRetweet: false, includeEntities: false, success: {
                    status in
                    
                    let original = Tweet.deserializeJSON(status!)
                    self.inReplyTo = original
                    
                    print("got original")
                    cb()
                    
                    }, failure: {
                        error in
                        print(error)
                })
            } else {
                cb()
            }
            
            }, failure: {
                error2 in
                print("error2")
        })
    }
    
    func getConversation() -> [Tweet] {
        var conversation:[Tweet] = []
        if self.inReplyTo != nil {
            conversation.append(self.inReplyTo!)
        }
        conversation.append(self)
        for reply in self.replies {
            conversation.append(reply)
        }
        return conversation
    }
}

func < (lhs: Tweet, rhs: Tweet) -> Bool {
    return lhs.ctime < rhs.ctime
}

func == (lhs: Tweet, rhs: Tweet) -> Bool {
    return lhs.ctime == rhs.ctime
}

