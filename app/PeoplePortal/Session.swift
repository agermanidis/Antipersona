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
    enum UserProgress {
        case Initial
        case Selection
        case Shadowing
    }
    
    var userProgress: UserProgress {
        get {
            return .Initial
            if self.credentials != nil {
                if self.shadowedUser != nil {
                    return .Shadowing
                }
                return .Selection
            }
            return .Initial
        }
    }
    
    static let shared = Session.retrieve()
    
    var me: User?
    var following: [User]?
    
    var swifter: Swifter?

    var credentials: TwitterCredentials? {
        didSet {
            refreshSwifter()
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
    
    func canSwitch() -> Bool {
        if self.shadowedUser != nil {
            return NSDate().daysDiff(self.shadowedUser!.ctime) > 0
        } else {
            return true
        }
    }
    
    func refreshSwifter() {
        if self.credentials != nil {
            self.swifter = Swifter(
                consumerKey: Constants.TWITTER_CONSUMER_KEY,
                consumerSecret: Constants.TWITTER_CONSUMER_SECRET,
                oauthToken: credentials!.accessToken,
                oauthTokenSecret: credentials!.accessSecret
            )
            retrieveUserInfo()
            
        } else {
            self.swifter = Swifter(
                consumerKey: Constants.TWITTER_CONSUMER_KEY,
                consumerSecret: Constants.TWITTER_CONSUMER_SECRET
            )
            self.me = nil
            self.following = nil
        }
    }

    func serialize() -> Dict {
        var ret = Dict()
        if let serializedUser = shadowedUser?.serialize() {
            ret["user"] = serializedUser
        }
        ret["following"] = following?.map({$0.serialize()})
        ret["notificationsEnabled"] = notificationsEnabled
        ret["accessToken"] = credentials?.accessToken
        ret["accessSecret"] = credentials?.accessSecret
        return ret
    }
    
    func save() {        
        Async.background {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(self.serialize(), forKey: "session")
            print("Saved session.")
        }
    }
    
    func become(user: User, callback: () -> ()) {
        print("BECOMING")
        let cb = {
            self.shadowedUser = ShadowedUser(user: user)
            self.shadowedUser!.onLoad(callback)
            print("Becoming \(user.name!)")
            self.shadowedUser!.load()
        }

        if self.shadowedUser != nil {
            self.shadowedUser?.unload(cb)
        } else {
            cb()
        }
    }
    
    static func deserialize(dict: Dict) -> Session {
        let session = Session()
        session.notificationsEnabled = dict["notificationsEnabled"] as! Bool
        if dict["user"] != nil {
            session.shadowedUser = ShadowedUser.deserialize(dict["user"] as! Dict)
        }
        if dict["following"] != nil {
            session.following = (dict["following"] as! [Dict]).map({User.deserialize($0)})
        }
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
