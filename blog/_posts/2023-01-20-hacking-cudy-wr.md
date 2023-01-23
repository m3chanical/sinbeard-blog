---
title: "Hacking Cudy WR2100"
author: "sinbeard"
date: 2023-01-20 15:52:40
---

# Introduction

![](/assets/images/router/banner.png)

Recently for an interview I was asked to perform a pentest on a Cudy WR2100 router and report my findings as a presentation. The task was a lot of fun and I had a good time tinkering on it. Now that the interview is over, I am putting my notes and procedure up here to both organize my thoughts and hopefully provide a resource for others. 

Overall this was a pretty quick pentest and there's undoubtedly things that I missed, things that I could improve on - even by simply spending more time on it. This should be a pretty solid baseline and at least show some of the firmware hacking steps clearly in action. 

# Resources

Understanding the tools and documentation that people use in these kinds of operations is really important to me. I feel like it's generally much more helpful to know how someone thinks and approaches a problem, in addition to why and what tools to use, than it is to simply follow a process. It helps me learn better, at least. Therefore, what follows is a list of resources I used while hacking on this router. 

* [OWASP Firmware Security Testing Methodology](https://scriptingxss.gitbook.io/firmware-security-testing-methodology/)
  * This is a really solid document that provides a grounding point for firmware investigation. The stages it outlines are really good for following a coherent flow. It helped me focus in on my efforts in addition to conveying useful techniques that I didn't know or waas unsure of.  

* [OWASP Top 10 IoT 2018](https://wiki.owasp.org/index.php/OWASP_Internet_of_Things_Project#tab=IoT_Top_10)
  * OWASP is a great resource for many reasons. In this case the list of top 10 vulnerabilities provides us another way to focus our efforts. Using this is an great for helping find the initial attack surface. 

* [Practical IoT Hacking (book)](https://nostarch.com/practical-iot-hacking)
  * My favorite part about these books is the framework they provide. I don't often read straight through, but I look for information relevant to what I'm thinking about. In particular, the tools section in the appendix is my favorite part because it usually allows me to efficiently put my thoughts into action.

* [binwalk](https://github.com/ReFirmLabs/binwalk)
  * Super useful for gaining information and unpacking firmware. I won't go into too much detail as this tool is ubiquitous.

# My Setup

Dell Latitude E7250
Ethernet, USB
USB to TTL Cable
UART Monitoring
Saleae 8-channel Logic analyzer
Raspberry Pi for SPI flash extraction
Flashrom
Alfa WIFI adapter
PCBite

Ubuntu 22.04
Downgrading might be easier
nmap
Binwalk
Firmwalker
Burp Suite
Ghidra
Binary Ninja didn’t seem to handle mipsel very well
With some configuring this would probably work better
FACT & Firmadyne
Would have liked to use, but set up isn’t easy


# The Router

Cudy appears to be a relatively new manufacturer of cheap routers and can be easily obtained from Amazon

# References

* [OWASP Firmware Security Testing Methodology](https://scriptingxss.gitbook.io/firmware-security-testing-methodology/)
* [OWASP Top 10 IoT 2018](https://wiki.owasp.org/index.php/OWASP_Internet_of_Things_Project#tab=IoT_Top_10)
* [Practical IoT Hacking (book)](https://nostarch.com/practical-iot-hacking)
* [LEDE 17.01.6 Security Fixes](https://openwrt.org/releases/17.01/changelog-17.01.6#security_fixes)
* [lbwc.sh](https://gist.github.com/m3chanical/70d9b52d8626afb7f60121de5cc363ae)
  * Quick and dirty script to look for vulnerable string
* [Many links](https://gist.github.com/m3chanical/f723c668eaf1be3af96e51f7507f83bd)
  * Pretty much all of the resources I used for this
