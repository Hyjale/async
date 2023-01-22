//
//  main.m
//  Async
//
//  Created by Jae Lee on 12/27/22.
//

#import <Foundation/Foundation.h>

#define THREAD_COUNT 4

@interface Calculator : NSObject

- (instancetype)initWithArray:(NSArray *)array;
- (void)start;

@end

@implementation Calculator {
    NSArray *_array;
    NSUInteger _res;
}

- (instancetype)initWithArray:(NSArray *)array {
    self = [super init];
    if (self) {
        _array = array;
    }
    return self;
}

- (void)start {
    NSUInteger subSize = _array.count / THREAD_COUNT;

    for (int i = 0; i < THREAD_COUNT; i++) {
        NSRange range = NSMakeRange(i * subSize, subSize);
        NSArray *subArray = [_array subarrayWithRange:range];

        [NSThread detachNewThreadSelector:@selector(sumArray:) toTarget:self withObject:subArray];
    }
}

- (void)sumArray:(NSArray *)array {
    NSUInteger sum = 0;
    for (NSNumber *number in array) {
        sum += [number unsignedIntegerValue];
    }

    @synchronized (self) {
        _res += sum;
    }

    NSLog(@"Sum of array: %lu", (unsigned long)_res);
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSArray *nums = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10, @11, @12, @13, @14, @15, @16];

        Calculator *calculator = [[Calculator alloc] initWithArray:nums];
        [calculator start];

        NSLog(@"Calculated sum...");

        __block NSNumber *sum = @0;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_apply([nums count], queue, ^(size_t i){
            sum = @([sum integerValue] + [nums[i] integerValue]);
        });

        NSLog(@"Sum: %@", sum);
    }

    return 0;
}
