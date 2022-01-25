---
title: "windows system programming week 3 and 4"
author: "sinbeard"
date: 2021-01-30 08:02:07
---

More Notes! 

# Handles

## Sharing Objects

* A handle is private to its containing process
* Sometimes and object needs to be shared with another process
* Can share using:
    * Process handle inheritance
        * create a child process
    * Open an object by name
        * pretty simple
        * anyone can use the name though...

## Object Names and Sessions

You can cause a handle to be available to all sessions by prepending `Global\` to the object name.


...i'll need to take some better notes.

# Processes

## Process Creation

![](/assets/images/process_creation.png)

## Default DLL Search Paths

It's the same logic that's used by the LoadLibrary API
    * Known DLLs
        * Global object
    * Directory of the executable
    * The System directory
        * `GetSystemDirectory`
    * Windows directory
        * `GetWindowsDirectory`
    * Current directory of the process
    * Directories specified by the PATH env variable

## Process Termination


