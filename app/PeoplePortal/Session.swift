//
//  Session.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/11/15.
//  Copyright (c) 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit
import Async

struct TwitterCredentials {
    var accessToken : String
    var accessSecret : String
}

class Session {
    static let shared = Session.retrieve()
    
    var swifter: Swifter?
    
    var me: User?
    var following: [User]?

    var credentials: TwitterCredentials? {
        didSet {
            if credentials != nil {
                self.swifter = Swifter(
                    consumerKey: Constants.TWITTER_CONSUMER_KEY,
                    consumerSecret: Constants.TWITTER_CONSUMER_SECRET,
                    oauthToken: credentials!.accessToken,
                    oauthTokenSecret: credentials!.accessSecret
                )
                retrieveUserInfo()
                retrieveFollowing()
                
            } else {
                self.swifter = nil
                self.me = nil
            }

            save()
        }
    }

    var shadowedUser: ShadowedUser? {
        didSet {
            save()
        }
    }

    var notificationsEnabled = true {
        didSet {
            save()
        }
    }
    
    func retrieveUserInfo() {
        Async.background {
            self.swifter?.getAccountVerifyCredentials(true, skipStatus: false, success: {
                (userInfo) in
            
                self.me = User.deserializeJSON(userInfo!)
            
            }, failure: nil)
        }
    }

    func retrieveFollowing() {
        Async.background {
            self.swifter?.getFriendsIDsWithID(String(self.me?.userId), cursor: nil, stringifyIDs: false, count: 1000, success: {
                ids, previousCursor, nextCursor in
                

                // .....
                
                }, failure: nil)
        }
    }
    
    func serialize() -> Dict {
        var ret = Dict()
        if let serializedUser = shadowedUser?.serialize() {
            ret["user"] = serializedUser
        }
        ret["notificationsEnabled"] = notificationsEnabled
        ret["accessToken"] = credentials?.accessToken
        ret["accessSecret"] = credentials?.accessSecret
        return ret
    }
    
    func save() {
        Async.background {
            print("Saving session...")
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(self.serialize(), forKey: "session")
        }
    }
    
    static func deserialize(dict: Dict) -> Session {
        let session = Session()
        session.notificationsEnabled = dict["notificationsEnabled"] as! Bool
        session.shadowedUser = ShadowedUser.deserialize(dict["user"] as! Dict)
        let accessToken = dict["accessToken"] as? String
        let accessSecret = dict["accessSecret"] as? String
        if accessToken != nil && accessSecret != nil {
            session.credentials = TwitterCredentials(accessToken: accessToken!, accessSecret: accessSecret!)
        }
        return session
    }
    
    static func retrieve() -> Session {
        print("Receiving session")
        let defaults = NSUserDefaults.standardUserDefaults()
        let retrieved = defaults.dictionaryForKey("session")
        if retrieved != nil {
            return deserialize(retrieved!)
        } else {
            return Session()
        }
    }
}
