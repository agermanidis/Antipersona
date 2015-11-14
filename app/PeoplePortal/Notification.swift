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
    var otherTweets: [Tweet]?
    var seen: Bool = false
    var ctime: NSDate?
    
    init() {
        ctime = NSDate()
    }
    
    func isFollow() -> Bool {
        return type == Constants.NOTIFICATION_TYPE_FOLLOW
    }
    
    func isMention() -> Bool {
        return type == Constants.NOTIFICATION_TYPE_MENTION
    }
    
    func isRetweet() -> Bool {
        return type == Constants.NOTIFICATION_TYPE_RETWEET
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
        if serialized["other_tweets"] != nil {
            ret.otherTweets = (serialized["other_tweets"] as! [Dict]).map({Tweet.deserialize($0)})
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
        if self.otherTweets != nil {
            ret["other_tweets"] = self.otherTweets!.map({ $0.serialize() })
        }
        ret["seen"] = seen
        ret["created_at"] = ctime!.toString()
        return ret
    }
    
    var attributedText: NSAttributedString? {
        if self.isFollow() {
            let message = NSMutableAttributedString()
            message.appendAttributedString(Utils.createUserAttributedString(users![0].name!))
            if users!.count == 2 {
                message.appendAttributedString(Utils.regularAttributedString(" and "))
                message.appendAttributedString(Utils.createUserAttributedString(users![1].name!))
            }
            var restOfMessage = ""
            if users!.count > 2 {
                restOfMessage += " and \(users!.count-1) others"
            }
            restOfMessage += " followed you"
            message.appendAttributedString(Utils.regularAttributedString(restOfMessage))
            return message
        } else if self.isRetweet() {
            let message = NSMutableAttributedString()
            let retweeters = otherTweets!.map({$0.user!})
            message.appendAttributedString(Utils.createUserAttributedString(retweeters[0].name!))
            if retweeters.count == 2 {
                message.appendAttributedString(Utils.regularAttributedString(" and "))
                message.appendAttributedString(Utils.createUserAttributedString(retweeters[1].name!))
            }
            var restOfMessage = ""
            if retweeters.count > 2 {
                restOfMessage += " and \(retweeters.count-1) others"
            }
            restOfMessage += " retweeted "
            if tweet?.user?.userId == Session.shared.shadowedUser?.user.userId {
                restOfMessage += "your tweet"
            } else {
                restOfMessage += "a tweet you were mentioned in"
            }
            message.appendAttributedString(Utils.regularAttributedString(restOfMessage))
            return message
        }
        return nil
    }
    
    var text: String? {
        return attributedText?.string
    }
}

func < (lhs: Notification, rhs: Notification) -> Bool {
    return lhs.ctime < rhs.ctime
}

func == (lhs: Notification, rhs: Notification) -> Bool {
    return lhs.ctime == rhs.ctime
}
