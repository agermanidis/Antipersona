//
//  Async.swift
//
//  Created by Tobias DM on 15/07/14.
//
//	OS X 10.10+ and iOS 8.0+
//	Only use with ARC
//
//	The MIT License (MIT)
//	Copyright (c) 2014 Tobias Due Munk
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy of
//	this software and associated documentation files (the "Software"), to deal in
//	the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//	the Software, and to permit persons to whom the Software is furnished to do so,
//	subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//	FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//	COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//	IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


import Foundation


// MARK: - DSL for GCD queues

private class GCD {
	
	/* dispatch_get_queue() */
	class func mainQueue() -> dispatch_queue_t {
		return dispatch_get_main_queue()
		// Don't ever use dispatch_get_global_queue(qos_class_main(), 0) re https://gist.github.com/duemunk/34babc7ca8150ff81844
	}
	class func userInteractiveQueue() -> dispatch_queue_t {
		return dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
	}
	class func userInitiatedQueue() -> dispatch_queue_t {
		 return dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
	}
	class func utilityQueue() -> dispatch_queue_t {
		return dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)
	}
	class func backgroundQueue() -> dispatch_queue_t {
		return dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
	}
}


// MARK: - Async – Struct

public struct Async {
    
    private let block: QDispatchBlock
    
    private init(_ block: QDispatchBlock) {
        self.block = block
    }
}


// MARK: - Async – Static methods

extension Async {
    
    
    /* async */
    
    public static func main(after after: Double? = nil, block: dispatch_block_t) -> Async {
        return Async.async(after, block: block, queue: GCD.mainQueue())
    }
    public static func userInteractive(after after: Double? = nil, block: dispatch_block_t) -> Async {
        return Async.async(after, block: block, queue: GCD.userInteractiveQueue())
    }
    public static func userInitiated(after after: Double? = nil, block: dispatch_block_t) -> Async {
        return Async.async(after, block: block, queue: GCD.userInitiatedQueue())
    }
    public static func utility(after after: Double? = nil, block: dispatch_block_t) -> Async {
        return Async.async(after, block: block, queue: GCD.utilityQueue())
    }
    public static func background(after after: Double? = nil, block: dispatch_block_t) -> Async {
        return Async.async(after, block: block, queue: GCD.backgroundQueue())
    }
    public static func customQueue(queue: dispatch_queue_t, after: Double? = nil, block: dispatch_block_t) -> Async {
        return Async.async(after, block: block, queue: queue)
    }
    
    
    /* Convenience */
    
    private static func async(seconds: Double? = nil, block chainingBlock: dispatch_block_t, queue: dispatch_queue_t) -> Async {
        if let seconds = seconds {
            return asyncAfter(seconds, block: chainingBlock, queue: queue)
        }
        return asyncNow(chainingBlock, queue: queue)
    }
    
    
    /* dispatch_async() */
    
    private static func asyncNow(block: dispatch_block_t, queue: dispatch_queue_t) -> Async {
        // Create a new block (Qos Class) from block to allow adding a notification to it later (see matching regular Async methods)
        // Create block with the "inherit" type
        let _block = QDispatchBlock(block: block)
        // Add block to queue
        _block.dispatchAsyncToQueue(queue)
        // Wrap block in a struct since dispatch_block_t can't be extended
        return Async(_block)
    }
    
    
    /* dispatch_after() */
    
    private static func asyncAfter(seconds: Double, block: dispatch_block_t, queue: dispatch_queue_t) -> Async {
        let nanoSeconds = Int64(seconds * Double(NSEC_PER_SEC))
        let time = dispatch_time(DISPATCH_TIME_NOW, nanoSeconds)
        return at(time, block: block, queue: queue)
    }
    private static func at(time: dispatch_time_t, block: dispatch_block_t, queue: dispatch_queue_t) -> Async {
        // See Async.async() for comments
        let _block = QDispatchBlock(block: block)
        _block.dispatchAfter(time, inQueue: queue)
        return Async(_block)
    }
}


// MARK: - Async – Regualar methods matching static ones

extension Async {
    
    
    /* chain */
    
    public func main(after after: Double? = nil, chainingBlock: dispatch_block_t) -> Async {
        return chain(after, block: chainingBlock, queue: GCD.mainQueue())
    }
    public func userInteractive(after after: Double? = nil, chainingBlock: dispatch_block_t) -> Async {
        return chain(after, block: chainingBlock, queue: GCD.userInteractiveQueue())
    }
    public func userInitiated(after after: Double? = nil, chainingBlock: dispatch_block_t) -> Async {
        return chain(after, block: chainingBlock, queue: GCD.userInitiatedQueue())
    }
    public func utility(after after: Double? = nil, chainingBlock: dispatch_block_t) -> Async {
        return chain(after, block: chainingBlock, queue: GCD.utilityQueue())
    }
    public func background(after after: Double? = nil, chainingBlock: dispatch_block_t) -> Async {
        return chain(after, block: chainingBlock, queue: GCD.backgroundQueue())
    }
    public func customQueue(queue: dispatch_queue_t, after: Double? = nil, chainingBlock: dispatch_block_t) -> Async {
        return chain(after, block: chainingBlock, queue: queue)
    }
    
    
    /* cancel */
    
    public func cancel() {
        block.cancel()
    }
    
    
    /* wait */
    
    /// If optional parameter forSeconds is not provided, it uses DISPATCH_TIME_FOREVER
    public func wait(seconds seconds: Double = 0.0) {
        if seconds != 0.0 {
            let nanoSeconds = Int64(seconds * Double(NSEC_PER_SEC))
            let time = dispatch_time(DISPATCH_TIME_NOW, nanoSeconds)
            block.wait(time)
        } else {
            block.wait(DISPATCH_TIME_FOREVER)
        }
    }
    
    
    /* Convenience */
    
    private func chain(seconds: Double? = nil, block chainingBlock: dispatch_block_t, queue: dispatch_queue_t) -> Async {
        if let seconds = seconds {
            return chainAfter(seconds, block: chainingBlock, queue: queue)
        }
        return chainNow(block: chainingBlock, queue: queue)
    }
    
    
    /* dispatch_async() */
    
    private func chainNow(block chainingBlock: dispatch_block_t, queue: dispatch_queue_t) -> Async {
        // See Async.async() for comments
        let _chainingBlock = QDispatchBlock(block: chainingBlock)
        self.block.notifyNextBlockOnCompletion(_chainingBlock, inQueue: queue)
        return Async(_chainingBlock)
    }
    
    
    /* dispatch_after() */
    
    private func chainAfter(seconds: Double, block chainingBlock: dispatch_block_t, queue: dispatch_queue_t) -> Async {
        // Create a new block (Qos Class) from block to allow adding a notification to it later (see Async)
        // Create block with the "inherit" type
        let _chainingBlock = QDispatchBlock(block: chainingBlock)
        
        // Wrap block to be called when previous block is finished
        let chainingWrapperBlock: dispatch_block_t = {
            // Calculate time from now
            let nanoSeconds = Int64(seconds * Double(NSEC_PER_SEC))
            let time = dispatch_time(DISPATCH_TIME_NOW, nanoSeconds)
            _chainingBlock.dispatchAfter(time, inQueue: queue)
        }
        // Create a new block (Qos Class) from block to allow adding a notification to it later (see Async)
        // Create block with the "inherit" type
        let _chainingWrapperBlock = QDispatchBlock(block: chainingWrapperBlock)
        // Add block to queue *after* previous block is finished
        self.block.notifyNextBlockOnCompletion(_chainingWrapperBlock, inQueue: queue)
        // Wrap block in a struct since dispatch_block_t can't be extended
        return Async(_chainingBlock)
    }
}


// MARK: - Apply

public struct Apply {
    
    // DSL for GCD dispatch_apply()
    //
    // Apply runs a block multiple times, before returning. 
    // If you want run the block asynchronously from the current thread,
    // wrap it in an Async block, 
    // e.g. Async.main { Apply.background(3) { ... } }
    
    public static func userInteractive(iterations: Int, block: Int -> ()) {
        dispatch_apply(iterations, GCD.userInteractiveQueue(), block)
    }
    public static func userInitiated(iterations: Int, block: Int -> ()) {
        dispatch_apply(iterations, GCD.userInitiatedQueue(), block)
    }
    public static func utility(iterations: Int, block: Int -> ()) {
        dispatch_apply(iterations, GCD.utilityQueue(), block)
    }
    public static func background(iterations: Int, block: Int -> ()) {
        dispatch_apply(iterations, GCD.backgroundQueue(), block)
    }
    public static func customQueue(iterations: Int, queue: dispatch_queue_t, block: Int -> ()) {
        dispatch_apply(iterations, queue, block)
    }
}


// MARK: - qos_class_t

public extension qos_class_t {

    // Convenience description of qos_class_t
	// Calculated property
	var description: String {
		get {
			switch self {
				case qos_class_main(): return "Main"
				case QOS_CLASS_USER_INTERACTIVE: return "User Interactive"
				case QOS_CLASS_USER_INITIATED: return "User Initiated"
				case QOS_CLASS_DEFAULT: return "Default"
				case QOS_CLASS_UTILITY: return "Utility"
				case QOS_CLASS_BACKGROUND: return "Background"
				case QOS_CLASS_UNSPECIFIED: return "Unspecified"
				default: return "Unknown"
			}
		}
	}
}

// Make qos_class_t equatable
extension qos_class_t: Equatable {}
