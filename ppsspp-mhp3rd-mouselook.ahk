; original/inspiration script: https://autohotkey.com/board/topic/92242-map-mouse-movements-to-arrow-keys/?p=581577

#Persistent
sendmode input
SetDefaultMouseSpeed, 0
CoordMode, mouse, window

threshold := 10     ; must move over this many pixels per update in order to register the input
toggleKey := "F1"   ; the key to enable/disable the script

prevDir := 0

scriptIsActive   := 0
scriptWasActive  := 0

isTogglePressed  := 0
wasTogglePressed := 0

SetTimer, Update, 10

return



Update:

if (GetKeyState(toggleKey, "P"))
{
    isTogglePressed := 1
}
else
{
    isTogglePressed := 0
}

if(isTogglePressed && !wasTogglePressed)
{
    scriptIsActive := !scriptIsActive
    
    if(scriptIsActive) ; hide/unhide cursor, see https://www.autohotkey.com/boards/viewtopic.php?p=128346#p128346
    {
        MouseGetPos, , , hwnd
        Gui Cursor:+Owner%hwnd%
        DllCall("ShowCursor", Int,0)
    }
    else
    {
        DllCall("ShowCursor", Int, 1)
    }
}

if (scriptIsActive)
{
    WinGetPos, , , winW, winH, A ; A means the Active window
    winCenterX := (winW / 2)
    winCenterY := (winH / 2)
    MouseGetPos, X, Y
    
    MovedX := ((OldX - X) > 0) ? (OldX - X) : -(OldX - X)
    MovedY := ((OldY - Y) > 0) ? (OldY - Y) : -(OldY - Y)
    
    if (MovedX > MovedY) && (MovedX > threshold)
    {
        if (OldX > X)
        {
            if (prevDir == 1)
            {
                send, {right up}
            }
            send, {left down}
            prevDir := -1
        }
        else
        {
            if (prevDir == -1)
            {
                send, {left up}
            }
            send, {right down}
            prevDir := 1
        }
    }
    else
    {
        if (prevDir == 1)
        {
            send, {right up}
        }
        if (prevDir == -1)
        {
            send, {left up}
        }
        
        prevDir := 0
    }
    
    OldX := winCenterX
    OldY := winCenterY
    MouseMove, OldX, OldY
}
else ; if(!scriptIsActive)
{
    if(scriptWasActive)
    {
        if (prevDir == 1)
        {
            send, {right up}
        }
        if (prevDir == -1)
        {
            send, {left up}
        }
        
        prevDir := 0
    }
}

wasTogglePressed := isTogglePressed
scriptWasActive := scriptIsActive

return
