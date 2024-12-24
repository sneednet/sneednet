Dim wshShell
Set wshShell = WScript.CreateObject("WScript.Shell")
currentPath = wshShell.CurrentDirectory & "\Freenet-install"
'WScript.Echo "Setting clipboard to " & currentPath

Set WshShell = CreateObject("WScript.Shell")
Set oExec = WshShell.Exec("clip")
Set oIn = oExec.stdIn
oIn.WriteLine currentPath
oIn.Close

Dim htmlObj
Dim testData
Set htmlObj = CreateObject("htmlfile")
testData = htmlObj.ParentWindow.ClipboardData.GetData("Text")
'WScript.Echo "clipboard: " & testData

'WScript.Echo "Sleeping for 5 seconds"
WScript.Sleep 5000
wshShell.AppActivate "Setup"
wshShell.SendKeys "{ENTER}"
'WScript.Echo "Sleeping for 5 seconds"
WScript.Sleep 5000
'WScript.Echo "Sleeping for 2 seconds"
WScript.Sleep 2000
wshShell.AppActivate "Setup"
wshShell.SendKeys "^V"
'WScript.Echo "Sleeping for 2 seconds"
WScript.Sleep 2000
wshShell.AppActivate "Setup"
wshShell.SendKeys "{ENTER}"
'WScript.Echo "Sleeping for 2 seconds"
WScript.Sleep 2000
wshShell.AppActivate "Setup"
wshShell.SendKeys "{ENTER}"
'WScript.Echo "Sleeping for 2 seconds"
WScript.Sleep 2000
wshShell.AppActivate "Setup"
wshShell.SendKeys "{ENTER}"
'WScript.Echo "Sleeping for 2 seconds"
WScript.Sleep 2000
wshShell.AppActivate "Setup"
wshShell.SendKeys "{ENTER}"
'WScript.Echo "Sleeping for 10 seconds"
WScript.Sleep 10000
wshShell.AppActivate "Setup"
wshShell.SendKeys "{ENTER}"
'WScript.Echo "Sleeping for 2 seconds"
WScript.Sleep 2000

