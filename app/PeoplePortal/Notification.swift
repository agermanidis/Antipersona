//
//  Notification.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/11/15.
//  Copyright (c) 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit

class Notification: NSObject {
    static func deserialize(serialized : Dict) -> Notification {
        return Notification()
    }
    
    static func serialize() -> Dict {
        return Dict()
    }
}
