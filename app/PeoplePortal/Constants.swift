//
//  Constants.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/11/15.
//  Copyright (c) 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit

class Constants {
    static let TIMELINE_BUFFER_CAPACITY = 200
    static let USER_LIST_BUFFER_CAPACITY = 5000
    static let NOTIFICATIONS_BUFFER_CAPACITY = 1000

    static let TWITTER_CONSUMER_KEY = "LAFxdex9rnVzBC9FiA9fArBqT"
    static let TWITTER_CONSUMER_SECRET = "HjYiWvGDOvr5oEiqH01bG4mPN3fsjw9UKr3zO9qGuJefBDChMV"
    
    static let NOTIFICATION_TYPE_MENTION = 0
    static let NOTIFICATION_TYPE_RETWEET = 1
    static let NOTIFICATION_TYPE_FOLLOW = 2
    
    static let FOLLOWING_BUTTON_TAG = 0
    static let FOLLOWERS_BUTTON_TAG = 1
    
    static let SWITCH_HOURS_MINIMUM = 24
    
    static let UNSEEN_NOTIFICATION_BACKGROUND = UIColor(red: 227.0/255.0, green: 232.0/255.0, blue: 243.0/255.0, alpha: 1.0)
    
    static let PEOPLE_PORTAL_API_HOST = "https://peopleportal-backend.herokuapp.com"
    
    static let CELL_CONTENT_PADDING = CGFloat(75)
}
