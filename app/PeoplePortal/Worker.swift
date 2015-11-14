//
//  Worker.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/10/15.
//  Copyright (c) 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit
import Async

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
            runOnBackground()
        } else {
            timer = NSTimer.scheduledTimerWithTimeInterval(frequency()!, target: self, selector: "runOnBackground", userInfo: nil, repeats: true)
            timer?.fire()
        }
        mode = .Started
    }
    
    func startBackgroundMode() {
        if mode == .StartedInBackground { return }
        stop()
        print("\(self.dynamicType) started running on the background")
        if backgroundFrequency() == nil {
            runOnBackground()
        } else {
            timer = NSTimer.scheduledTimerWithTimeInterval(frequency()!, target: self, selector: "runOnBackground", userInfo: nil, repeats: true)
            timer?.fire()
        }
        mode = .StartedInBackground
    }
    
    func stop() {
        print("\(self.dynamicType) stopped running")
        timer?.invalidate()
        timer = nil
        mode = .Stopped
    }
    
    func run() {
        assert(false == true, "Method not implemented")
    }
    
    func runOnBackground() {
        Async.background {
            self.run()
        }
    }
}
