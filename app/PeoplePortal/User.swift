//
//  User.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/11/15.
//  Copyright (c) 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit

class User: Equatable {
    var userId: Int?
    var name: String?
    var screenName: String?
    var profileDescription : String?
    var profileImageUrl: String?
    var profileImageUrlBigger: String? {
        get {
            return profileImageUrl?.stringByReplacingOccurrencesOfString("normal", withString: "bigger")
        }
    }
    var verified: Bool?
    var friendCount: Int?
    var followerCount : Int?
    var profileBackgroundColor: String?
    var profileBannerUrl: String?
    var profileColorHex: String?
    var profileColor: UIColor? {
        if profileColorHex != nil {
            return Utils.hexToColor(profileColorHex!)
        }
        return nil
    }
    var protected: Bool?
    
    var cachedProfileBanner: UIImage?

    var userColor: UIColor?

    func calculateColor() {
        if profileBannerUrl == nil {
            userColor = profileColor

        } else {
            let downloadedImg = Utils.downloadImage(profileBannerUrl!)
            if downloadedImg != nil{
                userColor = downloadedImg!.areaAverage()
            } else {
                userColor = profileColor
            }
        }
    }

    var userIdString: String? {
        get {
            if userId != nil {
                return String(userId!)
                
            } else {
                return nil
            }
        }
    }
    
    func isShadowedUser() -> Bool {
        return userId == Session.shared.shadowedUser?.user.userId
    }

    func isOriginalUser() -> Bool {
        return userId == Session.shared.me?.userId
    }
    
    func serialize() -> Dict {
        var ret = Dict()
        ret["id"] = userId!
        ret["name"] = name!
        ret["screen_name"] = screenName!
        ret["description"] = profileDescription!
        ret["profile_image_url_https"] = profileImageUrl!
        ret["profile_banner_url"] = profileBannerUrl
        ret["profile_link_color"] = profileColorHex
        ret["verified"] = verified!
        ret["friends_count"] = friendCount!
        ret["followers_count"] = followerCount!
        ret["protected"] = protected!
        return ret
    }
    
    static func deserialize(serialized: Dict) -> User {
        let ret = User()
        ret.userId = serialized["id"] as? Int
        ret.name = serialized["name"] as? String
        ret.screenName = serialized["screen_name"] as? String
        ret.profileDescription = serialized["description"] as? String
        ret.profileImageUrl = serialized["profile_image_url_https"] as? String
        ret.profileBannerUrl = serialized["profile_banner_url"] as? String
        ret.profileColorHex = serialized["profile_link_color"] as? String
        ret.verified = serialized["verified"] as? Bool
        ret.friendCount = serialized["friends_count"] as? Int
        ret.followerCount = serialized["followers_count"] as? Int
        ret.protected = serialized["protected"] as? Bool
        return ret
    }
    
    static func deserializeJSON(serialized: Dictionary<String, JSON>) -> User {
        let ret = User()
        ret.userId = serialized["id"]!.integer
        ret.name = serialized["name"]!.string
        ret.screenName = serialized["screen_name"]!.string
        ret.profileDescription = serialized["description"]!.string
        ret.profileImageUrl = serialized["profile_image_url_https"]!.string
        ret.profileBannerUrl = serialized["profile_banner_url"]?.string
        ret.profileColorHex = serialized["profile_link_color"]!.string
        ret.verified = serialized["verified"]!.boolValue
        ret.friendCount = serialized["friends_count"]!.integer
        ret.followerCount = serialized["followers_count"]!.integer
        ret.protected = serialized["protected"]!.boolValue
        return ret
    }
}

func == (lhs: User, rhs: User) -> Bool {
    return lhs.userId == rhs.userId
}

