//
//  Buffer.swift
//  EmotionsFolder
//
//  Created by Anastasis Germanidis on 9/28/15.
//  Copyright (c) 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit

class Buffer {
    var items : NSMutableArray
    var capacity : Int
    
    init(capacity:Int) {
        self.items = NSMutableArray(capacity: capacity)
        self.capacity = capacity
    }
    
    init(capacity:Int, items:NSArray) {
        self.items = NSMutableArray(capacity: capacity)
        self.capacity = capacity
        for item in items {
            self.add(item)
        }
    }
    
    func empty() {
        self.items = NSMutableArray(capacity: capacity)
    }
    
    func atCapacity() -> Bool {
        return self.items.count == self.capacity
    }
    
    func add(item:AnyObject) {
        if items.count == capacity {
            items.removeObjectAtIndex(0)
        }
        items.addObject(item)
    }
    
    func freeze() -> [AnyObject]? {
        return Array(items)
    }
}