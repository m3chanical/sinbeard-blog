---
title: "FlareOn 2020 - TKApp"
author: "canderson"
date: 2020-12-17 17:56:15
---

# Challenge 5 - TKApp

 The prompt for this one indicates that it's an app for some wearable, and we can either run it on real hardware or emulate it. It is pretty clear that this is some kind of mobile app. 
 
 This one was pretty straightforward for me to complete as I have experience (thanks in part to previous Flare-On actually) with .NET applications, and especially since the source code is recovered on disassembly. In fact, this one was the last of the `easy` ones for me this year and I solved it entirely statically.

## Setup

 Immediately we see that we have a `.tpk` file. If it's anything like an Android `.apk` file this should be just a zip file that we can unzip. Indeed.

 ![](folder.png)

 The Flare-VM comes with dnSpy, which is an incredible tool for disassembling .NET applications. 

## Analysis

With the project unzipped and the file structure obtained, we can start to take a look at what's here. A lot of these files aren't necessary for our RE efforts, so we'll just take a look at a couple.

### tizen-manifest.xml

The first interesting file is the manifest. With this we can gain a few details about the application. Importantly, the xml snippet below has some useful information.

```xml
    <ui-application appid="com.flare-on.TKApp" exec="TKApp.dll" multiple="false" nodisplay="false" taskmanage="true" api-version="6" type="dotnet" launch_mode="single">
        <label>TKApp</label>
        <icon>TKApp.png</icon>
        <metadata key="http://tizen.org/metadata/prefer_dotnet_aot" value="true" />
        <metadata key="its" value="magic" />
        <splash-screens />
    </ui-application>
```

First, we can see that the main assembly for this app is `TKApp.dll`. We can take a look at that in a bit. Further, we see a few bits of metadata whose use isn't clear right now. However, the key value pair `its magic` will be useful later as we'll see.

### TKApp.dll

Detect-it-Easy shows us that this is indeed a .NET app. Which means we can check it out using dnSpy

![](die.png)

## Flag

Running our C# code in the appendix decryptes `Runtime.dll` to an image which gives us the flag.

![](whatever.jpg)


## Appendix

### Full Code

```cs
using System;
using System.CodeDom;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Resources;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace challenge5
{
    class Program
    {
        public static byte[] password_enc = new byte[]
        {
            62,
            38,
            63,
            63,
            54,
            39,
            59,
            50,
            39
        };
        //[DllImport("advapi32.dll")]
        public static string password = decode_pass(password_enc);
        public static string note = "keep steaks for dinner";
        public static string step = "magic";
        public static string desc = "water";

        static byte[] hash_compare = new byte[]
        {
            50,
            148,
            76,
            233,
            110,
            199,
            228,
            72,
            114,
            227,
            78,
            138,
            93,
            189,
            189,
            147,
            159,
            70,
            66,
            223,
            123,
            137,
            44,
            73,
            101,
            235,
            129,
            16,
            181,
            139,
            104,
            56
        };

		static void Main(string[] args) {
            Console.WriteLine($"app.password --> {password}");
            Console.WriteLine($"app.note --> {note}");
            Console.WriteLine($"app.step --> {step}");
            Console.WriteLine($"app.desc --> {desc}");

            HashAlgorithm hashAlgorithm = SHA256.Create();
            byte[] bytes = Encoding.ASCII.GetBytes(password + note + step + desc);
            byte[] hash = hashAlgorithm.ComputeHash(bytes);

            if (hash.SequenceEqual(hash_compare))
            {
                Console.WriteLine("You got it.");
            }

            get_image();
            
            Console.ReadLine();
        }

        private static void get_image() {
            string text = new string(new char[]
            {
                desc[2],
                password[6],
                password[4],
                note[4],
                note[0],
                note[17],
                note[18],
                note[16],
                note[11],
                note[13],
                note[12],
                note[15],
                step[4],
                password[6],
                desc[1],
                password[2],
                password[2],
                password[4],
                note[18],
                step[2],
                password[4],
                note[5],
                note[4],
                desc[0],
                desc[3],
                note[15],
                note[8],
                desc[4],
                desc[3],
                note[4],
                step[2],
                note[13],
                note[18],
                note[18],
                note[8],
                note[4],
                password[0],
                password[7],
                note[0],
                password[4],
                note[11],
                password[6],
                password[4],
                desc[4],
                desc[3]
            });
            Console.WriteLine($"weird thing --> {text}");
            byte[] key = SHA256.Create().ComputeHash(Encoding.ASCII.GetBytes(text));
            byte[] bytes = Encoding.ASCII.GetBytes("NoSaltOfTheEarth");
            byte[] runtime = File.ReadAllBytes("C:\\shr\\Runtime.dll");
            byte[] imgBytes = Convert.FromBase64String(get_string(runtime, key, bytes));
            File.WriteAllBytes("C:\\shr\\whatever.jpg", imgBytes);
        }

        private static string get_string(byte[] cipherText, byte[] Key, byte[] IV) {
            string result = null;
            using (RijndaelManaged rijndaelManaged = new RijndaelManaged()) {
                rijndaelManaged.Key = Key;
                rijndaelManaged.IV = IV;
                ICryptoTransform cryptoTransform = rijndaelManaged.CreateDecryptor(rijndaelManaged.Key, rijndaelManaged.IV);
                using (MemoryStream memoryStream = new MemoryStream(cipherText)) {
                    using (CryptoStream cryptoStream = new CryptoStream(memoryStream, cryptoTransform, 0)) {
                        using (StreamReader streamReader = new StreamReader(cryptoStream)) {
                            result = streamReader.ReadToEnd();
                        }
                    }
                }
            }
            return result;
        }

        static string decode_pass(byte[] e)
        {
            string text = "";
            foreach (byte b in e)
            {
                text += Convert.ToChar((int) (b ^ 83)).ToString();
            }

            return text;
        }
    }
}
```