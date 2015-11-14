//
//  Buffer.swift
//  EmotionsFolder
//
//  Created by Anastasis Germanidis on 9/28/15.
//  Copyright (c) 2015 Anastasis Germanidis. All rights reserved.
//

import UIKit


class Buffer<T> {
    typealias BufferCallback = (Buffer<T>) -> ()

    var items:[T] = []
    var capacity : Int
    var count : Int {
        return items.count
    }
    var first : T? {
        return items.first
    }
    var last : T? {
        return items.last
    }
    
    init(capacity:Int) {
        self.items = []
        self.capacity = capacity
    }
    
    init(capacity:Int, items:[T]) {
        self.items = []
        self.capacity = capacity
        for item in items {
            self.add(item)
        }
    }
    
    func empty() {
        self.items = []
        triggerCallbacks()
    }
    
    func atCapacity() -> Bool {
        return self.items.count == self.capacity
    }
    
    func add(item:T) {
        if items.count == capacity {
            items.removeAtIndex(0)
        }
        items.append(item)
        triggerCallbacks()
    }
    
    func replace(var items: [T]) {
        empty()
        for item in items {
            items.append(item)
        }
        triggerCallbacks()
    }
    
    func reverse() {
        items = items.reverse()
        triggerCallbacks()
    }
    
    var callbacks = [BufferCallback?]()
    func onChange(callback: BufferCallback?) {
        callbacks.append(callback)
    }
    
    func triggerCallbacks() {
        for callback in callbacks {
            callback?(self)
        }
    }
}