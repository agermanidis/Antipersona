//
//  Worker.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/10/15.
//  Copyright (c) 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit

protocol Worker {
    var runCount : Int { get }
    func run()
}
