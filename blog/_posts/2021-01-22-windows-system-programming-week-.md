---
title: "windows system programming week 2"
author: "sinbeard"
date: 2021-01-22 08:47:44
---

More systems programming! 

# Modules and Handles

## 32-bit vs 64-bit

* Most Windows systems today are 64-bit
* 32-bit applications can run on Windows using WOW64
    * 4 gb address space, instead of 2 gb
* Windows API is mostly unchanged, but some things have been extended for 64-bit - e.g. pointers and handles
* More types have been added where their size depends on 'bitness' - e.g. DWORD_PTR, INT_PTR, SIZE_T

Can change project properties to treat 64/32 bit warnings as errors: 
* Property --> C/C++ --> "Warning Level"
* Treat Warnings As Errors (same properties section)

## Working with Strings

* Can use standard C-style strings, but Windows has a bunch of its own.
* Windows has *A and *W functions. The "A" functions accept ascii-style strings, and the "W" functions use the unicode (utf-16) strings.
* Using the unicode functions is more efficient, because often the "A" functions convert to unicode anyway.
* Unicode literal, prepend with L -> `L"notepad"`

The classic C functions for manipulating strings are considered unsafe.
* e.g. strcpy, wcscpy, strcat...

Safer versions exist:
* strcpy_s, wcscat_s, etc.

```c 
strcpy(dest, src) --> strcpy_s(dest, _countof(dest), src)
```

Can also use `strsafe.h` for some other safe string functions. 
* StringCchCopy, StringCchCat, etc.
* Also has A and W versions

## Structures

* Most structures use the following pattern:
    * ```c
        typedef struct _SOME_STRUCT {
        // members...
        } SOME_STRUCT, *PSOME_STRUCT, *LPSOME_STRUCT;
        ```
* The "L" (long) prefix is sometimes used for compatibility reasons.
    *   All ptrs are the same size, so there's really no such thing as a long or short ptr.
    *   4-bytes (32bit) or 8-bytes (64-bit)
* Some structs are versioned by specifying their size in the first member

## Windows Numeric Versions

All over the place. Windows 10 finally matches the internal Windows version --> 10.0. Though it's reported as 6.2. Check documentation for `GetProductInfo`

Side note: 

> A manifest file with compatibility information can (should?) be used in C++ programs. The best way to accomplish that is to swipe a manifest file from a C# application (just create a new one and steal the text to get the guids and associated info) and paste it into a new xml file in the C++ app. Then go to project properties to the Manifest --> Input and Output section, and add the new manifest to the `Additional Manifest Files` section. 

* GetVersionEx is thoroughly deprecated. 
    *   Using the specific windows version to identify features isn't adequate since Microsoft is releasing a lot of stuff out of band. 
    *   This is where the `versionhelpers.h` APIs come in
* Requires a manifest to get correct information.

### KSHARED_USER_DATA

This is a reliable way to get the Windows version regardless of manifest. It uses the KSHARED_USER_DATA (semi-documented) structure that is mapped to the same address (0x7ffe0000) in every process. 

```c
BYTE* sharedUserData = (BYTE *) 0x7ffe0000;
printf("Version: %d.%d.%d\n",
            *(ULONG*)(sharedUserData + 0x26c), // major version offset
            *(ULONG*)(sharedUserData + 0x270), // minor version offset
            *(ULONG*)(sharedUserData + 0x260)); // build number offset (Windows 10)
```

## System Information

* Several APIs exist to get system-wide information
    * GetSystemInfo, GetNativeSystemInfo
    * Static information
* Information on the total number of processes, threads, handles, memory, etc.
    * GetPerformanceInfo -> `psapi.h`
* Lots of others
    * GetComputerName, GetProductInfo, GetSystemDirectory, ... 
    * See project on github