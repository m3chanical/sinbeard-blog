---
title: "windows system programming week 5 and 6"
author: "canderson"
date: 2021-02-13 07:11:24
---

Week 5! 

# Threads

It is an instance of a function executing code.
It owns
    * 



## Creating Threads

* The CreateThread API

## Thread Stack in User Space

* By default, 1 MB is reserved, 4 KB is committed initially

![](/assets/images/thread_stack.png)

![](/assets/images/vmmap.png)

## Changing Stack Size

* Use Linker settings as new defaults

![](/assets/images/stack_size.png)

* On a thread by thread basis in the call to `CreateThread{Ex}`
    * Can specify a new committed or reserved, but not both
    * Committed is assumed, unless the flag `STACK_SIZE_PARAM_IS_A_RESERVATION` is specified
    * The native function, `NtCreateThreadEx` allows one to specify both...
        * maybe there's a reason? it's odd.

## Thread Priorities

* Thread priorities are between 1 and 31 (31 is highest)
    * Priority 0 is reserved for the zero page thread(s)
* The Windows API mandates thread priority be based on a process priority class (base priority)
* A thread's priority can be changed around the base priority

![](/assets/images/thread_priority.png)

* Realtime priorities
    * really just means the thread priority is higher than all the others. 
    * no guarantees on actual "real time" processing

## Some Other Thread-Related APIs

* `GetThreadTimes`
    * Similar to `GetProcessTimes`, gives a bunch of information regarding the life of the thread
* `OpenThread`
    * Gets a handle to an existing thread
    * unique ID over lifetime of thread
* `SuspendThread`, `ResumeThread`
    * Pretty self-explanatory. If suspended, must call resume
* `Sleep`
    * Waits a specified amount of time. Typically in ms
* `GetExitCodeThread`
    * Gets the exit code of a thread with the specified ID
* `SetThreadDescription`, `GetThreadDescription` (Win10)
    * Assigns/gets a description text for a thread. 
* `SetThreadAffinityMask`, `GetThreadAffinityMask`
    * Affinity determines which processor a thread will run on.

To determine performance: Always measure. Ya gotta.

## Thread Enumeration

* There is no documented API to enumerate threads in a specific process
* The best option is to use the ToolHelp APIs
    * Enumerates all threads in the system
* If a specific process is desired, the process can be filtered based on its ID or some other criteria.

# Memory

## Virtual Memory

* Each process sees a flat bit of linear memory
* Internally, memory may be mapped to both physical (RAM) and disk memory

![](/assets/images/virtual_mem.png)

## Managing Memory

Memory is managed in chunks called Pages, whose size is determined by CPU type, which is a compromise between fine and coarse

* Two page sizes are supported - small/normal, and large
    * A third page size (huge) is supported by Win10 and Server 2016
* Allocations, de-alloc, and other memory blocks are always done by page. 

## Virtual Page States

* Each page in virtual memory can be one of three states
    * Free
        * Unallocated page
        * Any access causes an Access Violation exception
    * Committed
        * Allocated page that can be accessed
        * May currently reside on disk
    * Reserved
        * Unallocated page causing Access Violation on access
        * Address range will not be used for future allocations unless specifically requested

This information can be viewed with the Sysinternals VMMap tool. See screenshot above of the thread stack sizes.

## Some Memory APIs

* System Information
    * `Get{Native}SystemInfo` retrieves the max and min addresses of a process.
    * Global memory information functions
        * `GlobalMemoryStatusEx`
        * `GetPerformanceInfo`
    * Process memory 
        * `GetProcessMemoryInfo`
        * `QueryWorkingSet{Ex}`

## Process Virtual Memory Map

* The memory map of a process can be obtained by scanning its regions: 
    * `VirtualQuery`
        * current process
    * `VirtualQueryEx` 
        * any process for which `PROCESS_QUERY_INFORMATION` mask can be obtained

## `VirtualAlloc` Function

* Powerful function for memory manipulation 
    * reserving, committing, using large pages, etc.
* Calls `NtAllocateVirtualMemory`
* Operates on whole pages
* New allocations are always on allocation granularity (64kb)
* Committed memory is always zeroed!

## Other Virtual Functions

* `VirtualAllocEx`
    * commit/reserver in another process
* `VirtualProtect{Ex}`
    * Change page protections
* `Virtual{Un}Lock`
    * Attempt to keep committed memory in RAM
* `VirtualAllocExNuma`
    * Select a preferred NUMA node
* `VirtualAlloc2` (Win10 1803 and later)
    * Combines other virtual functions (?)

## Heap 

* The `VirtualAlloc{Ex}` function is great, but works on page level things. Thus, it's kinda wasteful for small allocations
* The Heap Manager manages small allocations
    * `NtDll.dll`
    * Calls virtual function when needed
* The `Heap*` functions are wrappers around the native heap APIs
    