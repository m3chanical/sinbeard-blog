---
title: "flareon-garbage"
author: "sinbeard"
date: 2020-12-16 22:31:43
tags: flareon
---

# Challenge 2 - Garbage

Based on the challenge write-up, the FireEye team is outsourcing some of their internal work to the CTF players. A binary under development was deleted by accident and recovered using `extreme digital forensic techniques`. Our goal is to reconstruct it to obtain the flag. 

It seems that we'll to perform multiple steps to reconstruct the binary in order to get the flag, likely involving some special knowledge of PE file formats and how Windows parses executable files. I solved this one largely through dynamic analysis, repairing the file as I went along. 

## UPX

Using Detect-it-Easy we can see that the file is packed by UPX, which `should` be fairly straightforward to unpack using one of several tools available for the task. 

![](/assets/images/DiE.png)

However, we quickly see that it isn't that easy: 

![](/assets/images/upx.png)

The UPX utility to decompress the file doesn't work because of an Invalid overlay size. Opening this file in PE Explorer shows that indeed the size of the file is misaligned. Our first step is to fix this. 

![](/assets/images/peexpl.png)

Using 010 Editor I copied null bytes to pad the file to the size required by UPX to unpack (41472 - 40740 = 732 bytes) and was able to unpack without incident. 

## Mangled PE

At this point we're left with a Windows executable that Windows can parse, but immediately runs into problems. 

### Side-by-Side

We may have noticed previously that the xml config at the end of the file was truncated. Well, after unpacking when the file is run, we get the following errors. Looking at the application event log as indicated by the error reveals the source of our problem. The XML manifest embedded in the file is invalid and needs to be fixed.

![](/assets/images/sxs.png)

![](/assets/images/event.png)

I found another executable on my machine with a manifest and copy/pasted it over to the mangled binary. However, this doesn't immediately work for two reasons. First, the size of the XML as indicated in the resource section has now changed. Second, the new XML can't pass offset 0x12800 because that is where the header indicates the `.reloc` section begins. With this in mind, we tailor the XML to ensure we don't pass 12800 and find the offset of the XML size at 0x1264C. Some easy subtraction allows us to determine the size to allow this program to run. See the Appendix for the specifics.

All that does, however, is allow us to run in to our next problem.

### DLL Imports

Now when we run the binary we get a terminal window that pops up and immediately receive a pair of errors. 

![](/assets/images/dll.png)

It's pretty clear that the import table is borked in some way. PE-Bear shows that this binary looks for two dll's with empty names. In order to figure out what dll's are needed we can either look in the binary itself for the functions it seeks, or in my case, I ran the binary in a debugger to see what function it crashed on (there are definitely better ways to do that...). In any case, we find that we're missing `kernel32.dll` and `shell32.dll`. We can fix these in PE-Bear. 

![](/assets/images/impbroke.png)

![](/assets/images/impfix.png)

### ASLR

After unpacking, fixing the resources, and the imports, we arrive at our final hurdle. When we attempt to run the binary it immediately crashes at the following instruction:

![](/assets/images/aslr.png)

We can see that the instruction under execution is at an address that's not somewhere around 0x400000 which suggests that it's been loaded to use ASLR. Next, the instruction points to an offset of 0x413004, which it would use if it used a constant base address. Clearly there's a discrepency that must be corrected.

In the dll optional header at offset 0x156 we find the `DLL Characteristics` section. In this we can find where the binary indicates whether to use ASLR for itself. We can use CFF Explorer, setdllcharacteristics, or simply a hex editor to adjust the setting. Without modification, the dll characteristics are set as 0x8140. Removing ASLR, we change this to 0x8100. This allows us to run our binary without issue as seen below at the same instruction shown previously.

![](/assets/images/notaslr.png)

## Victory

After all that work, we get the flag and a vba script dropped in our directory. 

![](/assets/images/victory_2.png)

## Commentary

For my first go at this I think I solved it in the most hamhanded way possible. I wanted to solve this and get to the quicker challenges as quickly as possible, so I ended up using some really hacky ways to solve this. After much research I managed to fix the UPX unpack and XML problem in much the same way described here. The major differences lay in how I fixed the imports and ASLR. I'm more familiar with debugging and assembly than I am with Windows PE file structures, so I used the debugger as a major troubleshooting tool.

First, with the DLL's I ran the binary in a debugger to check the function it failed at. The first one I found was `kernel32.dll`. It's important to note that the error received from the bad imports looks for `.DLL`. Instead of fixing the imports I simply copied kernel32.dll to my directory and re-named it `.DLL`. That ... worked, somehow, and left me with the problem of fixing the next one. It also was named `.DLL` and I found that it was `shell32.dll` the same way as previous. This time, I opened it in Binary Ninja and found the import for `shell32.dll` and was able to simply edit it to look for `A.DLL`. I copied that as well. 

After all that I encountered the ASLR problem. I realized pretty quickly what the issue was, but didn't know how to fix it. A quick google search (no doubt using suboptimal keywords) didn't reveal much, so I figured I could fix it manually. I ran it in x32dbg until it crashed, and referenced the location in Binary Ninja. On each occasion it was looking for static data, so all I had to do was set breakpoints and change the assembly to a static mov instruction. 

It was certainly hacky and really hamhanded, but it worked at least. Since then (a month later :P ) I've learned better.

## Appendix

### Mangled XML

#### Original

`Size: 0x17D`

```xml
<?xml version='1.0' encoding='UTF-8' standalone='yes'?>
<assembly xmlns='urn:schemas-microsoft-com:asm.v1' manifestVersion='1.0'>  
    <trustInfo xmlns="urn:schemas-microsoft-com:asm.v3">
    <securit
```

#### Fixed

`Size: 0x193`

```xml
<?xml version='1.0' encoding='UTF-8' standalone='yes'?>
<assembly xmlns='urn:schemas-microsoft-com:asm.v1' manifestVersion='1.0'>
 <trustInfo xmlns="urn:schemas-microsoft-com:asm.v3">
  <security>
   <requestedPrivileges xmlns="urn:schemas-microsoft-com:asm.v3">
    <requestedExecutionLevel level="asInvoker" uiAccess="false"/>
   </requestedPrivileges>
  </security>
 </trustInfo>
</assembly>
```
