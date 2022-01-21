---
title: "FlareOn 2020 - report"
author: "canderson"
date: 2020-12-17 17:53:19
---

# Challenge 4 - Report

The writeup and file within the challenge point toward this being a Microsoft Office Macro based challenge. I'd never programmed macros nor have I ever looked at them, so I was in for some pretty solid learning. Ultimately it was indeed a great learning experience. Most importantly, I originally had no knowledge of VBA stomping. 

## Setup

As I hadn't up to this point ever tinkered with any VBA Excel macros I had to install the developer tools and figure out how to debug the code on my machine. I also heavily leveraged MSDN and various macro references found via Google.

I enabled the feature and opened up the excel file. I was immediately greeted by a helpful image instructing me to enable content. Sure thing. Instead I opened up the developer tools to have a look at what the code does. 

## Analysis

We ignore the enable content request and look immediately at the mechanism of this thing. In order to run this to debug it, Excel wants us to update some of the code for use in 64bit (I think?). After resolving some of the errors it can be run and debugged. But first, some static analysis.


```vb
Sub Workbook_Open()
Sheet1.folderol
End Sub

Sub Auto_Open()
Sheet1.folderol
End Sub
```

Okay. When this workbook is opened this malicious macro will autorun the `folderol` function in Sheet1. There's also a Form within that has some obfuscated data. 

![](/assets/images/form.png)


### Strings

We see immediately in the `folderol()` function an assignment to `onzo` from the form `F.L`. Each string that the macro uses is obfuscated within the `onzo` variable, and is decoded through the use of the `rigmarole` function. 

```vb
onzo = Split(F.L, ".")
Set fudgel = GetObject(rigmarole(onzo(7)))
...

Function rigmarole(es As String) As String
    Dim furphy As String
    Dim c As Integer
    Dim s As String
    Dim cc As Integer
    furphy = ""
    For i = 1 To Len(es) Step 4
        c = CDec("&H" & Mid(es, i, 2))
        s = CDec("&H" & Mid(es, i + 2, 2))
        cc = c - s
        furphy = furphy + Chr(cc)
    Next i
    rigmarole = furphy
End Function
```

We can let the macro do most of the work for us by making a for loop and print. 

```vb
    For Each s In onzo
        Debug.Print rigmarole(CStr(s))
    Next

' Output: 
' 0     AppData
' 1     \Microsoft\stomp.mp3
' 2     play 
' 3     FLARE-ON
' 4     Sorry, this machine is not supported.
' 5     FLARE-ON
' 6     Error
' 7     winmgmts:\\.\root\CIMV2
' 8     SELECT Name FROM Win32_Process
' 9     vbox
' 10    WScript.Network
' 11    \Microsoft\v.png
```

We can see these strings being used a bunch in the rest of the macro. However, some of them don't appear to be used at all which is curious. We'll find out why later.


### Environment Checks

Additionally, we see a pair of environment checks.

Internet connection:

```vb
If GetInternetConnectedState = False Then
    MsgBox "Cannot establish Internet connection.", vbCritical, "Error"
    End
End If
```

And thanks to decoding the strings, we see a check for any process name containing `vmw`, `vmt`, or `vbox`.

If the macro makes it this far, it'll grab more data from the Form from `F.T.Text`, decode it, and write it to `%AppData%\Microsoft\stomp.mp3`. 

```vb
xertz = Array(&H11, &H22, &H33, &H44, &H55, &H66, &H77, &H88, &H99, &HAA, &HBB, &HCC, &HDD, &HEE)

wabbit = canoodle(F.T.Text, 0, 168667, xertz)
mf = Environ(rigmarole(onzo(0))) & rigmarole(onzo(1))
Open mf For Binary Lock Read Write As #fn
    Put #fn, , wabbit
Close #fn

mucolerd = mciSendString(rigmarole(onzo(2)) & mf, 0&, 0, 0)
```

```vb
Function canoodle(panjandrum As String, ardylo As Integer, s As Long, bibble As Variant) As Byte()
    Dim quean As Long
    Dim cattywampus As Long
    Dim kerfuffle() As Byte
    ReDim kerfuffle(s)
    quean = 0
    For cattywampus = 1 To Len(panjandrum) Step 4
        kerfuffle(quean) = CByte("&H" & Mid(panjandrum, cattywampus + ardylo, 2)) Xor bibble(quean Mod (UBound(bibble) + 1))
        quean = quean + 1
        If quean = UBound(kerfuffle) Then
            Exit For
        End If
    Next cattywampus
    canoodle = kerfuffle
End Function
```


### stomp.mp3

Again we let the macro do the work for us which essentially let's us ignore the finer points of the `canoodle()` function and check out this `mp3` file that was dropped in AppData. 

![](/assets/images/mp3.png)

It plays what sounds like someone stomping their foot. More importantly, it gives us some valuable clues: `stomp.mp3`, `P.Code`, and the song title is `This is not what you should be looking at...`.

Some quick research and glances at twitter suggest that the macro source and the PCode differ, which is a fairly common obfuscation technique for macros. It looks like we need to extract all the P Code and check the differences. 

## P Code 

Using `pcode2code` to grab all of the P Code and decompile it, we see a few key differences. 

In particular we see the addition of another environment check, along with a subsequent string reversal. 

```vb
Set groke = CreateObject(rigmarole(onzo(10)))
firkin = groke.UserDomain
If firkin <> rigmarole(onzo(3)) Then
    MsgBox rigmarole(onzo(4)), vbCritical, rigmarole(onzo(6))
    End
End If

n = Len(firkin)
For i = 1 To n
    buff(n - i) = Asc(Mid$(firkin, i, 1))
Next
```

Importantly, `onzo(10)` is `WScript.Network`, and `onzo(3)` is `FLARE-ON`. It appears that we need our UserDomain to be `FLARE-ON`. If it is, we reverse the string. Presumably for use later.

For the next differences, we see a change in the call to `canoodle()`. 

```vb
wabbit = canoodle(F.T.Text, 2, 285729, buff)
mf = Environ(rigmarole(onzo(0))) & rigmarole(onzo(11))
```

`canoodle()` is called with a different size, offset, and xor key. This means that the actual data we're looking for is encoded differently and woven into the large data string in `F.T.Text`. The xor key we can trace back up to the reversed `FLARE-ON` string. Again we can let the macro do the work for us. 

We tinker with the macro to evade all these environment checks and get that data decoded from `F.T.Text` and find it as `v.png`, which is loaded into the excel sheet with:

```vb
Set panuding = Sheet1.Shapes.AddPicture(mf, False, True, 12, 22, 600, 310)
```

See the appendix for the final macro code used to generate the image.

## Flag

The previous yields the flag.

![](/assets/images/Picture1.png)

## Appendix

```vb
Private Declare PtrSafe Function InternetGetConnectedState Lib "wininet.dll" _
(ByRef dwflags As Long, ByVal dwReserved As Long) As Long

Private Declare PtrSafe Function mciSendString Lib "winmm.dll" Alias _
   "mciSendStringA" (ByVal lpstrCommand As String, ByVal _
   lpstrReturnString As Any, ByVal uReturnLength As Long, ByVal _
   hwndCallback As Long) As Long

Private Declare PtrSafe Function GetShortPathName Lib "kernel32" Alias "GetShortPathNameA" _
    (ByVal lpszLongPath As String, ByVal lpszShortPath As String, ByVal lBuffer As Long) As Long

Public Function GetInternetConnectedState() As Boolean
  GetInternetConnectedState = InternetGetConnectedState(0&, 0&)
End Function

Function rigmarole(es As String) As String
    Dim furphy As String
    Dim c As Integer
    Dim s As String
    Dim cc As Integer
    furphy = ""
    For i = 1 To Len(es) Step 4
        c = CDec("&H" & Mid(es, i, 2))
        s = CDec("&H" & Mid(es, i + 2, 2))
        cc = c - s
        furphy = furphy + Chr(cc)
    Next i
    rigmarole = furphy
End Function

Function folderol()
    Dim wabbit() As Byte
    Dim fn As Integer: fn = FreeFile
    Dim onzo() As String
    Dim mf As String
    Dim xertz As Variant
    Dim buff(0 To 7) As Byte
    
    onzo = Split(F.L, ".")
    For Each s In onzo
        Debug.Print rigmarole(CStr(s))
    Next
    
    If GetInternetConnectedState = False Then
        MsgBox "Cannot establish Internet connection.", vbCritical, "Error"
        End
    End If

    Set fudgel = GetObject(rigmarole(onzo(7)))
    Set twattling = fudgel.ExecQuery(rigmarole(onzo(8)), , 48)
    For Each p In twattling
        Dim pos As Integer
        pos = InStr(LCase(p.Name), "vmw") + InStr(LCase(p.Name), "vmt") + InStr(LCase(p.Name), rigmarole(onzo(9)))
        If pos > 0 Then
            'MsgBox rigmarole(onzo(4)), vbCritical, rigmarole(onzo(6))
            'End
        End If
    Next
        
    xertz = Array(&H11, &H22, &H33, &H44, &H55, &H66, &H77, &H88, &H99, &HAA, &HBB, &HCC, &HDD, &HEE)
    firkin = rigmarole(CStr(onzo(3)))
    n = Len(firkin)
    For i = 1 To n
      buff(n - i) = Asc(Mid$(firkin, i, 1))
    Next
        
    wabbit = canoodle(F.T.Text, 2, 285729, buff)
    
    mf = Environ(rigmarole(onzo(0))) & rigmarole(onzo(11))
    Open mf For Binary Lock Read Write As #fn
      Put #fn, , wabbit
    Close #fn
    Set panuding = Sheet1.Shapes.AddPicture(mf, False, True, 12, 22, 600, 310)
    mucolerd = mciSendString(rigmarole(onzo(2)) & mf, 0&, 0, 0)
End Function

Function canoodle(panjandrum As String, ardylo As Integer, s As Long, bibble As Variant) As Byte()
    Dim quean As Long
    Dim cattywampus As Long
    Dim kerfuffle() As Byte
    ReDim kerfuffle(s)
    quean = 0
    For cattywampus = 1 To Len(panjandrum) Step 4
        kerfuffle(quean) = CByte("&H" & Mid(panjandrum, cattywampus + ardylo, 2)) Xor bibble(quean Mod (UBound(bibble) + 1))
        quean = quean + 1
        If quean = UBound(kerfuffle) Then
            Exit For
        End If
    Next cattywampus
    canoodle = kerfuffle
End Function




```