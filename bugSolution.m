To fix this, use dispatch barriers or other synchronization techniques to ensure that the array modification in the background thread is completed before the main thread accesses the array:

```objectivec
NSMutableArray *myArray = [NSMutableArray arrayWithObjects:@"A", @"B", @"C", nil];

dispatch_barrier_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ 
    [myArray addObject:@"D"]; // Modify array within the barrier
    dispatch_async(dispatch_get_main_queue(), ^{ // Update UI on the main thread
        NSLog (@"Array count: %lu", (unsigned long)myArray.count); // Now it will be 4
    });
});

```

Alternatively, using Grand Central Dispatch's `dispatch_sync`  (but with care to avoid deadlocks) on the main queue would also work to ensure the main thread waits for the changes:

```objectivec
NSMutableArray *myArray = [NSMutableArray arrayWithObjects:@"A", @"B", @"C", nil];

dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ 
    [myArray addObject:@"D"];
    dispatch_sync(dispatch_get_main_queue(), ^{ //Update UI on the main thread
        NSLog (@"Array count: %lu", (unsigned long)myArray.count);
    });
});
```

This ensures that the main thread will only read the array after the modification in the background thread is complete.  Note:  `dispatch_sync` on the main queue from within the main queue is not advised as it will cause deadlocks.  Thus `dispatch_barrier_async` is preferred for better performance and prevention of deadlocks.