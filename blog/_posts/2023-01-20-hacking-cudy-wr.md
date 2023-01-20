---
title: "Hacking Cudy WR2100"
author: "canderson"
date: 2023-01-20 15:52:40
---

# introduction

Recently for an interview I was asked to perform a pentest on a Cudy WR2100 router and report my findings as a presentation. The task was a lot of fun and I had a good time tinkering on it. Now that the interview is over, I am putting my notes and procedure up here to both organize my thoughts and hopefully provide a resource for others. 

Overall this was a pretty quick pentest and there's undoubtedly things that I missed, things that I could improve on - even by simply spending more time on it. This should be a pretty solid baseline and at least show some of the firmware hacking steps clearly in action. 

# resources used

Understanding the tools and documentation that people use in these kinds of operations is really important to me. I feel like it's generally much more helpful to know how someone thinks and approaches a problem, in addition to why and what tools to use, than it is to simply follow a process. It helps me learn better, at least. Therefore, what follows is a list of resources I used while hacking on this router. 

## [OWASP Firmware](https://scriptingxss.gitbook.io/firmware-security-testing-methodology/)

This is a really solid document that provides a grounding point for firmware investigation. The stages it outlines are really good for following a coherent flow. It helped me focus in on my efforts in addition to conveying useful techniques that I didn't know or waas unsure of.  

## [OWASP Top 10 IoT](https://wiki.owasp.org/index.php/OWASP_Internet_of_Things_Project#tab=IoT_Top_10)

OWASP is a great resource for many reasons. In this case the list of top 10 vulnerabilities provides us another way to focus our efforts. Using this is an great for helping find the initial attack surface. 

## [binwalk](https://github.com/ReFirmLabs/binwalk)

Best tool.

# the router

Cudy appears to be a relatively new manufacturer of cheap routers and can be easily obtained from Amazon

# references


