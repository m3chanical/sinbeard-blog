---
title: "windows systems programming week 1"
author: "canderson"
date: 2021-01-16 07:06:21
---

Primarily as a result of Flare-On and learning game hacking techniques, I've been more interested in learning Windows things lately. As a result, I've picked up a couple books - Windows Kernel Programming, and Windows System Programming, both by Pavel Yosifovich. They are really clearly written and provide excellent on modern Windows programming I also grabbed a quick class on System Programming. These pages will serve as my notes and a general reference. 

# Foundations 

![](/assets/images/windows_architecture.png)

## Process

Is a set of resources used to execute a program. It consists of the following:

*   A private virtual address space
*   An executable program (the image), that contains the initial code and data to be executed
*   A table of handles to kernel objects
*   A security context, an access token
*   One or more threads that execute code

## Virtual Memory

Each process thinks it has a chunk of flat linear memory. Virtual memory may map to physical memory or be stored on disk. It is managed in chunks called Pages, which on Windows has a default size of 4 kb. Processes access memory regardless of where the memory resides. The memory manager handles mapping of virtual to physical pages, and they can't (and need not) know the actual physical address of a given address in virtual memory.

32-bit processes have a 2 gb address space for the user, from 0 to 0x7fffffff. System space is from 0x80000000 to 0xffffffff. Kernel code all shares one large memory space. 

64-bit has a 128 tb user address space. Same size for system space. 64-bit has an address space of... a lot, so most of the address space is unmapped.

Windows 8 and earlier (x64) support 8 tb user/kernel space. 

## Threads

An entity that is scheduled by the kernel to execute code. A thread maintains:

*   The state of CPU registers
*   Current access mode (user or kernel)
*   Two stacks - one in user space, and one in kernel space.
*   Thread Local Storage (TLS)
*   Optional security token
*   Optional message queue and Windows the thread creates (??)
*   Priotity, used in thread scheduling
*   States: running, ready, waiting

## User vs Kernel Mode

*   Thread access modes
*   User mode
    *   Allows access to non-OS system code and data only
    *   No access to the hardware
    *   Protects user applications from crashing the system
*   Kernel mode
    *   Privileged mode for use by the kernel and device drivers only
    *   Allows access to all system resources
    *   Can potentially crash the system - BSOD T_T

## Windows Subsystem APIs

*   Windows API ("Win32")
    *   Classic C API from the first days of Windows NT
    *   COM based APIs
        *   found often in newer (Vista+) APIs
        *   e.g. BITS, DirectX, WIC
*   .NET
    *   Managed libraries running on top of the CLR
    *   Languages: C#, VB.NET, C++/CLI
*   Windows Runtime (WinRT)
    *   New unmanaged API available for Windows 8+ (e.g. Calculator in Win10)
    *   Built on top of an enhanced version of COM

# Application Development Basics

Visual Studio is the most efficient tool for building System applications on Windows.
*   Testing and debugging integration
*   Community Edition is perfectly fine
*   Must install "Desktop development with C++"

The Sysinternals (TODO: Add link) tools are incredibly useful for tinkering with applications.

## Coding Conventions

Coding is done primarily using C, and some C++ is used where it makes sense to use it. Windows API functions can be prefixed with a `::` to indicate global scope. It makes it easier to spot Windows API calls. Further, applications should compile successfully in 32 and 64 bit. Can also build and test in *Debug* and *Release*.

### Hello World Example

From the Windows System Programming Fundamentals slides for Module 2

```cpp
#include <Windows.h>
#include <stdio.h>

int main() 
{
    SYSTEM_INFO si;
    ::GetNativeSystemInfo(&si);
    printf("Number of Logical Processors: %u\n", si.dwNumberOfProcessors);
    printf("Page size: %u Bytes\n", si.dwPageSize);
    printf("Processor Mask: 0x%zX\n", si.dwActiveProcessorMask);
    printf("Minimum process address: 0x%p\n", si.lpMinimumApplicationAddress);
    printf("Maximum process address: 0x%p\n", si.lpMaximumApplicationAddress);
    return 0;
}
```

## Handling Errors

Many Windows API functions return a boolean (BOOL type) to indicate success or failure. Typically, FALSE (0) indicates and error, and any other value indicates a success.

*   GetLastError() can abe used to obtain the last set error code
    *   The debugger's `@err` can be used to show the value as well
        * Go to `Watch` tab and search for `@err` and the last error will be displayed
    *   `Error Lookup` tool can be used to get the text description of the error
    *   Can also use `FormatMessage` to get the text
        *   see Appendix for example code
*   Some other common return types
    *   HANDLE
        *   Zero (NULL) and -1(INVALID_HANDLE_VALUE) indicate failure
        *   Again call GetLastError
    * LRESULT or LONG
        *   Error code returned directly from the function
        *   ERROR_SUCCESS (0) indicates success
    *   HRESULT
        *   Typical return type in COM functions/methods
        *   S_OK (0) indicates success and negative values are errors


----------

# Appendix

## Show Error Code

From Windows System Programming book

```cpp
int main(int argc, char* argv[])
{
    if(argc < 2)
    {
        printf("Usage: ShowError <number>\n");
        return 0;
    }

    int message = atoi(argv[1]);

    LPWSTR text;
    DWORD chars = ::FormatMessage(
        FORMAT_MESSAGE_ALLOCATE_BUFFER | // FormatMessage allocates the buffer
        FORMAT_MESSAGE_FROM_SYSTEM |
        FORMAT_MESSAGE_IGNORE_INSERTS,
        nullptr, message, 0,
        (LPWSTR)&text,
        0, nullptr);

	if(chars > 0)
	{
        printf("Message %d: %ws\n", message, text);
        ::LocalFree(text);
	}
    else
    {
        printf("No such error exists!\n");
    }
    return 0;
}
```