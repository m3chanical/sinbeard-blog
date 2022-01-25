---
title: "FlareOn 2020 - Fidler"
author: "sinbeard"
date: 2020-12-16 20:44:49
tags: flareon
---

# Challenge 1 - Fidler

We're presented with a simple python game in the style of cookie clickers or other idle games, and instructed to win by any means necessary. It's straightforward to solve either statically or by playing the game. However, if one seeks the flag by playing, there's one additional step required to get to the game itself - bypassing the `Flare On TURBO Nuke v55.7`.

![Need to find the correct password in the code.](/assets/images/password.png)

If the wrong password is entered...

![](/assets/images/donegoofed.png)

Bad pirate. At this point it's necessary to look at the underlying python script, which is provided in the challenge files. Some quick investigation reveals the code that checks the password and is shown below:

```py
def password_check(input):
    altered_key = 'hiptu' 
    key = ''.join([chr(ord(x) - 1) for x in altered_key]) # ghost
    return input == key
```

Each character of the altered key has one subtracted. Either looking at an ascii table or simply printing out the `key` reveals that the password is `ghost`. Onward. 

Once the correct password is entered, we're instructed to send Kitty out to catch mice for cash.

![](/assets/images/fidler_main.png)

Clicking on the cat indeed yields coins. Can we click 100 billion times? Who knows. Luckily we can buy autoclickers - but why when we have the source code? 

The listing below shows the relevant part of the main loop. This was found by tracing backward from where the flag is generated in an effort to determine the proper input to transform the `encoded_flag` variable. The loop checks the amount of coins against a target amount - if the coins are roughly greater or equal to the `target_amount`, `victory_screen` is called with the current coins divided by 10^8 cast to an int. 

```py
...

while not done:
    target_amount = (2**36) + (2**35)
    if current_coins > (target_amount - 2**20):
        while current_coins >= (target_amount + 2**20):
            current_coins -= 2**20
        victory_screen(int(current_coins / 10**8)) # Passed into decode_flag as 'frob'
        return

...
```

Below we can see the `decode_flag` function. It takes the number passed in from above and uses it to transform the flag. 

```py
def decode_flag(frob):
    last_value = frob
    encoded_flag = [1135, 1038, 1126, 1028, 1117, 1071, 1094, 1077, 1121, 1087, 1110, 1092, 1072, 1095, 1090, 1027,
                    1127, 1040, 1137, 1030, 1127, 1099, 1062, 1101, 1123, 1027, 1136, 1054]
    decoded_flag = []

    for i in range(len(encoded_flag)):
        c = encoded_flag[i]
        val = (c - ((i%2)*1 + (i%3)*2)) ^ last_value
        decoded_flag.append(val)
        last_value = c

    return ''.join([chr(x) for x in decoded_flag])
```

## Solution

```py
    last_value = int(((2 ** 36) + (2 ** 35) - 2 ** 20) / 10 ** 8) #frob
encoded_flag = [1135, 1038, 1126, 1028, 1117, 1071, 1094, 1077, 1121, 1087, 1110, 1092, 1072, 1095, 1090, 1027,
                1127, 1040, 1137, 1030, 1127, 1099, 1062, 1101, 1123, 1027, 1136, 1054]
decoded_flag = []

for i in range(len(encoded_flag)):
    c = encoded_flag[i]
    val = (c - ((i%2)*1 + (i%3)*2)) ^ last_value
    decoded_flag.append(val)
    last_value = c

print(''.join([chr(x) for x in decoded_flag]))
```

### Flag

`idle_with_kitty@flare-on.com`

If one decides to click a whole bunch and let this thing run its course, the following will be displayed. 

![](/assets/images/victory.png)

## Commentary

I first solved this the lazy way by clicking Kitty many times, then buying autoclickers. I became distracted by a video game and checked back several minutes later to see the flag. I felt that was a little lazy and decided to solve it statically by copying over the relevant python script in order to generate the flag.
