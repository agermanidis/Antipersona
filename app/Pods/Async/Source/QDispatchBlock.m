//
//  QDispatchBlock.m
//  Async
//
//  Created by John Coates on 9/16/15.
//
//  Adapted from code example by eskimo at https://forums.developer.apple.com/message/50963

#import "QDispatchBlock.h"

@interface QDispatchBlock ()

@property (strong) dispatch_block_t block;

@end

@implementation QDispatchBlock

- (instancetype)initWithBlock:(dispatch_block_t)block {
    self = [super init];
    if (self != nil) {
        self->_block = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, block);
    }
    return self;
}

- (void)dispatchAsyncToQueue:(dispatch_queue_t)queue {
    dispatch_async(queue, self.block);
}

- (void)notifyNextBlockOnCompletion:(QDispatchBlock *)nextBlock inQueue:(dispatch_queue_t)queue {
    dispatch_block_notify(self.block, queue, nextBlock.block);
}

- (void)dispatchAfter:(dispatch_time_t)time inQueue:(dispatch_queue_t)queue {
    dispatch_after(time, queue, self.block);
}

- (void)wait:(dispatch_time_t)time {
    dispatch_block_wait(self.block, time);
}

- (void)cancel {
    dispatch_block_cancel(self.block);
}

@end