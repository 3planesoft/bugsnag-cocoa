//
//  AsyncSafeMallocScenario.m
//  iOSTestApp
//
//  Created by Nick Dowell on 22/02/2021.
//  Copyright © 2021 Bugsnag. All rights reserved.
//

#import "Scenario.h"

#include <libkern/OSSpinLockDeprecated.h>
#include <mach/mach_init.h>
#include <mach/vm_map.h>
#include <malloc/malloc.h>

static OSSpinLock spinLock = OS_SPINLOCK_INIT;

static void * malloc_(struct _malloc_zone_t *zone, size_t size) {
    OSSpinLockLock(&spinLock);
    OSSpinLockLock(&spinLock);
    return NULL;
}

/// Causes all subsequent calls to malloc() to lock indefinitely
static void simulateMallocDeadlock() {
    malloc_zone_t *zone = malloc_default_zone();
    vm_protect(mach_task_self(), (uintptr_t)zone, sizeof(malloc_zone_t), 0, VM_PROT_READ | VM_PROT_WRITE);
    zone->malloc = malloc_;
    vm_protect(mach_task_self(), (uintptr_t)zone, sizeof(malloc_zone_t), 0, VM_PROT_READ);
}

@interface AsyncSafeMallocScenario : Scenario

@end

@implementation AsyncSafeMallocScenario

- (void)run {
    simulateMallocDeadlock();
    
    abort();
}

@end
