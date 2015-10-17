//
//  Promise.swift
//  PeoplePortal
//
//  Created by Anastasis Germanidis on 10/16/15.
//  Copyright © 2015 Anastasis Germanidis. All rights reserved.
//

import Async

class Promise<T: Any> {
    typealias OnChangeCallback = (T? -> ())

    var callback: ((T) -> ()) -> ()
    var observers = [OnChangeCallback]()
    var value: T? {
        didSet {
            for observer in observers {
                observer(value)
            }
        }
    }
    
    init(callback: ((T) -> ()) -> ()) {
        self.callback = callback
        
        Async.background {
            self.callback { value in
                self.value = value
            }
        }
    }

    func onChange(callback: OnChangeCallback) {
        observers.append(callback)
    }
}
