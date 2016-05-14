//
//  API.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 1/19/16.
//  Copyright © 2016 Anastasis Germanidis. All rights reserved.
//

import UIKit
import Alamofire

class API {
    static func get(path: String, args: Dictionary<String, String>) {
        Alamofire.request(.GET, Constants.PEOPLE_PORTAL_API_HOST + path, parameters: args)
    }
    
    static func post(path: String, body: Dictionary<String, AnyObject>) {
        Alamofire.request(.POST, Constants.PEOPLE_PORTAL_API_HOST + path, parameters: body, encoding: .JSON)
    }
    
    static func registerAsUser(deviceToken: String, userId: String) {
        let body = [
            "device_token": deviceToken,
            "user_id": userId
        ]
        post("/listen", body: body)
    }
    
    static func sendUpdate(session: Session) {
        post("/listen", body: session.serializeAPI())
    }
}

