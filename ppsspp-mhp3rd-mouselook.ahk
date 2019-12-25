; original/inspiration script: https://autohotkey.com/board/topic/92242-map-mouse-movements-to-arrow-keys/?p=581577

#Persistent
sendmode input
SetDefaultMouseSpeed, 0
CoordMode, mouse, window

threshold := 10     ; must move over this many pixels per update in order to register the input
toggleKey := "F1"   ; the key to enable/disable the script
pixelsForMaxSpeed := 100 ; moving this many pixels (or more) per update will result in max turn speed

; see https://en.wikipedia.org/wiki/Moving_average#Exponential_moving_average
alpha := 0.5
ema := 0

prevDir := 0

scriptIsActive   := 0
scriptWasActive  := 0

isTogglePressed  := 0
wasTogglePressed := 0

SetTimer, Update, 33 ; this value should be ( 1000 / (game's framerate) )
; if the game's framerate is variable, then use the lowest expected framerate as the "game's framerate"
; this will hopefully ensure that none of the inputs are missed by the game

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
        DllCall("ShowCursor", Int, 0)
    }
    else
    {
        DllCall("ShowCursor", Int, 1)
        ; MsgBox, (%mdX%,%mdY%) -> (%dX%,%dY%)
    }
}

if (scriptIsActive)
{
    WinGetPos, , , winW, winH, A ; A means the Active window
    winCenterX := (winW / 2)
    winCenterY := (winH / 2)
    MouseGetPos, X, Y
    
    ; mouse delta vector in pixels
    mdX := X - OldX
    mdY := Y - OldY
    
    ; mouse delta vector scaled to range of -1 to 1
    dX := max(-1, min(1, mdX / pixelsForMaxSpeed))
    dY := max(-1, min(1, mdY / pixelsForMaxSpeed))
    
    ; MovedX := ((OldX - X) > 0) ? (OldX - X) : -(OldX - X)
    ; MovedY := ((OldY - Y) > 0) ? (OldY - Y) : -(OldY - Y)
    
    if (abs(dX) > abs(dY)) && (abs(mdX) > threshold)
    {
        if (OldX > X)
        {
            inputDir(-1, prevDir)
        }
        else
        {
            inputDir(1, prevDir)
        }
    }
    else
    {
        inputDir(0, prevDir)
    }
    
    OldX := winCenterX
    OldY := winCenterY
    MouseMove, OldX, OldY
}
else ; if(!scriptIsActive)
{
    if(scriptWasActive)
    {
        inputDir(0, prevDir)
    }
}

wasTogglePressed := isTogglePressed
scriptWasActive := scriptIsActive

return



map(value, start1, stop1, start2, stop2)
{
    return start2+((stop2-start2)*((value-start1)/(stop1-start1)))
}

inputDir(val, ByRef prevDirection)
{
    switch val
    {
        case 0:
            if (prevDirection == 1)
            {
                send, {right up}
            }
            if (prevDirection == -1)
            {
                send, {left up}
            }
            prevDirection := 0
            return
            
        case -1:
            if (prevDirection == 1)
            {
                send, {right up}
            }
            send, {left down}
            prevDirection := -1
            return
            
        case 1:
            if (prevDirection == -1)
            {
                send, {left up}
            }
            send, {right down}
            prevDirection := 1
            return
    }
}