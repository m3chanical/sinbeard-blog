---
title: "FlareOn 2020 - Wednesday"
author: "canderson"
date: 2020-12-17 17:50:27
---

# Challenge 3 - Wednesday

We need to be the Wednesday. Ok. We're also told that we likely can't win the game as easily as challenge 1. Damn. The README file tells us to only check out `mydude.exe` and shows us that Dude is in the middle of the week. We shall quickly see why...

## Wednesday

Considering it's an early challenge and what seemed like just a `simple` game I figured I'd just run the game first to get an idea of what I was working with.

![](/assets/images/game.png)

The boxes clearly show the days of the week, but why? After dying a few times the reason quickly became obvious - we are Wednesday and we have to maneuver the Dude the appropriate alignment for the day of the week, exactly as shown in the README. 

I played this game several times and found that getting past 80 points was difficult. With the message in the write up in mind, I figured I'd have to actually cheat. 

## Pause

I fired the game up in Binary Ninja and had a look around. I had no idea what this Nim stuff was and decided not to look too much into it for the moment. 

After poking around in the binary for a while following the startup code, I found the main loop. In `@run__E9cSjWeb4G6NszYRcpo6sLA_2@4` I observed a block that is triggered when `_gamePaused__s6up9a9at4lzveO5PPmNNLBA == 0`. I didn't see any hotkey assigned to Pause so I figured I could use Cheat Engine to set up a hotkey so I could toggle it to pause the game. Maybe I could edit the game while it was running? Who knows.

![](/assets/images/pause.png)

Ultimately this was only mildly useful. For now anyway. 

## Obstacle Array

Pausing the game was only useful to some extent. I could use it to get much further in the game to give me time to check on the next obstacle, but that only got me so far.

This time in Binary Ninja I followed the obstacle creation and collision detection. This lead me to the array assigning days to the obstacles.

![](/assets/images/obstacles.png)

![](/assets/images/obarray.png)

This suggested two things to me: the amount of points I needed in order to win was 296. Next, playing through a few times with my pause hotkey revealed that the binary values represented which day set I'd encounter. 

(I didn't realize until seeing FireEye's writeups that the bytes were the flag in binary...)

## Flag

At this point I figured I'd have to automate the game or find some way to cheat. I was going to automate it but I figured that I could spend the fifteen minutes or so beating the game "legit" with my pause hotkey and the array as guides. This small expenditure of time and focus would have told me several things about where to direct my efforts, so it seemed like a good idea. 

Turns out... beating the game gives the flag.

## Victory

![](/assets/images/victory.png)

## Commentary

I liked the music. 

I could have also patched the game in order to invert the jumps for the collisions. However, when I tried that it immediately failed so I figured I'd revisit it if I couldn't beat it. There is some debug information in there that draws the collider boxes but it's wasn't very useful. 