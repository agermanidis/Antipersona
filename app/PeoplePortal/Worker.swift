//
//  Worker.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/10/15.
//  Copyright (c) 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit

class Worker: NSObject {
    enum Mode {
        case Started
        case StartedInBackground
        case Stopped
    }
    var mode: Mode = .Stopped
    
    var runCount = 0 {
        didSet {
            lastRunTime = NSDate()
            Session.shared.save()
            print("\(self.dynamicType) finished running once")
        }
    }
    var lastRunTime: NSDate? = nil
    var timer: NSTimer?
    
    func frequency() -> NSTimeInterval? {
        return nil
    }
    
    func backgroundFrequency() -> NSTimeInterval? {
        return nil
    }

    func start() {
        if mode == .Started { return }
        stop()
        print("\(self.dynamicType) started running")
        if frequency() == nil {
            runOnce()
        } else {
            timer = NSTimer.scheduledTimerWithTimeInterval(frequency()!, target: self, selector: "runOnce", userInfo: nil, repeats: true)
        }
        mode = .Started
    }
    
    func startBackgroundMode() {
        if mode == .StartedInBackground { return }
        stop()
        print("\(self.dynamicType) started running on the background")
        if backgroundFrequency() == nil {
            runOnce()
        } else {
            timer = NSTimer.scheduledTimerWithTimeInterval(frequency()!, target: self, selector: "runOnce", userInfo: nil, repeats: true)
        }
        mode = .StartedInBackground
    }
    
    func stop() {
        print("\(self.dynamicType) stopped running")
        timer?.invalidate()
        timer = nil
        mode = .Stopped
    }
    
    func runOnce() {
        assert(false == true, "Method not implemented")
    }
}
