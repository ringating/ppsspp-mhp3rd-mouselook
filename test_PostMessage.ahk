#Persistent
SetTitleMatchMode, 2
DetectHiddenWindows, On

otherScriptName := "test_OnMessage.ahk"

Run, %otherScriptName%, %A_WorkingDir%

SetTimer, MyPostMessage, 1000

return


MyPostMessage:
PostMessage, 4444, 1337, 420, , %otherScriptName%
return