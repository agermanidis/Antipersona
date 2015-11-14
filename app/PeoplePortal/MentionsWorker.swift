//
//  MentionsWorker.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/23/15.
//  Copyright © 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit

class MentionsWorker: Worker {
    override func frequency() -> NSTimeInterval? {
        return 60.0
    }
    
    override func backgroundFrequency() -> NSTimeInterval? {
        return 120.0
    }
    
    func mentionAlreadyExists(mention: Tweet) -> Bool {
        for notification in Session.shared.shadowedUser!.notifications.items {
            if notification.tweet?.tweetId == mention.tweetId {
                return true
            }
        }
        return false
    }
    
    func retweetAlreadyExists(retweet: Tweet) -> Bool {
        for notification in Session.shared.shadowedUser!.notifications.items {
            if notification.isRetweet() {
                for tweet in notification.otherTweets! {
                    if tweet.tweetId == retweet.tweetId {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    override func run() {
        let shadowedUser = Session.shared.shadowedUser!
        let user = shadowedUser.user
//        let latestMention = shadowedUser.mentions.first
        
        let sinceId: String? = nil
//        if latestMention != nil {
//            sinceId = String(latestMention!.tweetId!)
//        }
        
        Session.shared.swifter?.getSearchTweetsWithQuery("@\(user.screenName!)", geocode: nil, lang: nil, locale: nil, resultType: nil, count: 100, until: nil, sinceID: sinceId, maxID: nil, includeEntities: nil, callback: nil, success: {
            
            statuses, metadata in

            var tweets: [Tweet] = []
            for status in statuses! {
                tweets.append(Tweet.deserializeJSON(status.object!))
            }
            
            let mentions: [Tweet] = tweets.filter({!$0.isRetweet()})
            let retweets: [Tweet] = tweets.filter({$0.isRetweet()})
            
            print("Number of mentions: \(mentions.count)")
            print("Number of retweets: \(retweets.count)")
            
            let notifications = shadowedUser.notifications
            let firstNotification = notifications.first
            
            for mention in mentions {
                if mention.user!.userId == shadowedUser.user.userId {
                    continue
                }
                if self.mentionAlreadyExists(mention) {
                    continue
                }
                if firstNotification != nil && mention.ctime!.isEarlierThan(firstNotification!.ctime!) {
                    continue
                }
                let notification = Notification()
                notification.type = Constants.NOTIFICATION_TYPE_MENTION
                notification.tweet = mention
                notification.ctime = mention.ctime!
//                notification.ctime = NSDate()
                notifications.add(notification)
                shadowedUser.notificationAdded(notification)
            }

            var groupedRetweets = Dictionary<Tweet, [Tweet]>()
            for retweet in retweets {
                if self.retweetAlreadyExists(retweet) {
                    continue
                }
                if firstNotification != nil && retweet.ctime!.isEarlierThan(firstNotification!.ctime!) {
                    continue
                }
                let status = retweet.retweetedStatus!
                if groupedRetweets[status] == nil {
                    groupedRetweets[status] = []
                }
                groupedRetweets[status]!.append(retweet)
            }
            
            for (original, otherTweets) in groupedRetweets {
                let notification = Notification()
                notification.type = Constants.NOTIFICATION_TYPE_RETWEET
                notification.tweet = original
                notification.otherTweets = otherTweets
                notification.ctime = otherTweets[0].ctime
//                notification.ctime = NSDate()
                notifications.add(notification)
                shadowedUser.notificationAdded(notification)
            }
            
            print("grouped retweets count: \(groupedRetweets.count)")
            
            notifications.items.sortInPlace()

            self.runCount += 1
            

            }, failure: {
                error in
        })

    }
    
}
