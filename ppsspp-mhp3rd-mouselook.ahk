; original/inspiration script: https://autohotkey.com/board/topic/92242-map-mouse-movements-to-arrow-keys/?p=581577

#Persistent
sendmode input
SetDefaultMouseSpeed, 0
CoordMode, mouse, window

toggleKey := "F1"   ; the key to enable/disable the script
pixelsForMaxSpeed := 200 ; moving this many pixels (or more) per update will result in max turn speed
pixelThreshold := 50 ; number of pixels mouse must move for input to count at all

; see https://en.wikipedia.org/wiki/Moving_average#Exponential_moving_average
alpha := 0.25
ema := 0

prevDir := 0

scriptIsActive   := 0
scriptWasActive  := 0

isTogglePressed  := 0
wasTogglePressed := 0

SetTimer, Update, 33 ; this value should be ( 1000 / (game's framerate) )
; if the game's framerate is variable, then use the lowest expected framerate as the "game's framerate"
; this will hopefully ensure that none of the inputs are missed by the game

 doScrollUp := false
didScrollUp := false
 doScrollDown := false
didScrollDown := false 

emuDpadUpKey = up
emuDpadLeftKey = left
emuDpadRightKey = right
emuDpadDownKey = down

emuAnalogUpKey = h
emuAnalogLeftKey = j
emuAnalogRightKey = k
emuAnalogDownKey = l

emuTriangleKey = u
emuSquareKey = i
emuCircleKey = o
emuCrossKey = p

emuLKey = ;
emuRKey = '

menuModeToggleKey = r
menuMode := false

menuModeSoundPath = main6bL.dsp.wav
combatModeSoundPath = main3f.dsp.wav

currWinID := 0
prevWinID := 0
winChange := false

return



Update:

if (GetKeyState(toggleKey, "P"))
{
    isTogglePressed := true
}
else
{
    isTogglePressed := false
}

if(didScrollUp)
{
    send {Blind}{%emuDpadUpKey% up}
    didScrollUp := false
}
if(didScrollDown)
{
    send {Blind}{%emuDpadDownKey% up}
    didScrollDown := false
}
if(doScrollUp)
{
    send {Blind}{%emuDpadUpKey% down}
    didScrollUp := true
    doScrollUp := false
}
if(doScrollDown)
{
    send {Blind}{%emuDpadDownKey% down}
    didScrollDown := true
    doScrollDown := false
}

if((isTogglePressed && !wasTogglePressed) || winChange)
{
    scriptIsActive := !scriptIsActive
    
    winChange := false
    
    if(scriptIsActive) ; for hide/unhide cursor, see https://www.autohotkey.com/boards/viewtopic.php?p=128346#p128346
    {
        ; hide cursor
        MouseGetPos, , , hwnd
        Gui Cursor:+Owner%hwnd%
        DllCall("ShowCursor", Int, 0)
        
        ; start in combat mode
        gosub, SetCombatMode
        
        ; enable menu mode toggle hotkey
        Hotkey, *%menuModeToggleKey%, MenuModeToggleHotkey, on
        
        ; enable scroll up overwrite
        Hotkey, *WheelUp, WheelUpHotkey, on
        
        ; enable scroll down overwrite
        Hotkey, *WheelDown, WheelDownHotkey, on
        
        ; store active window's ID
        WinGet, prevWinID, ID, A
        currWinID := prevWinID
    }
    else
    {
        ; show cursor
        DllCall("ShowCursor", Int, 1)
        
        ; blindly disable combat/menu hotkeys
        gosub, DisableCombatHotkeys
        gosub, DisableMenuHotkeys
        
        ; disable menu mode toggle hotkey
        Hotkey, *%menuModeToggleKey%, MenuModeToggleHotkey, off
        
        ; disable scroll up overwrite
        Hotkey, *WheelUp, WheelUpHotkey, off
        
        ; disable scroll down overwrite
        Hotkey, *WheelDown, WheelDownHotkey, off
    }
}

if (scriptIsActive)
{
    ; disable script if active window has changed since toggling script
    WinGet, currWinID, ID, A
    if(currWinID != prevWinID)
    {
        ; MsgBox, currWinID: %currWinID%, prevWinID: %prevWinID%
        winChange := true
        return
    }
    
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
    
    if(mdX < -pixelThreshold || pixelThreshold < mdX)
    {
        if (mdX >= pixelThreshold)
        {
            ; target value is between 0 and 1
            ema := max(0, min(1, ema))
            
            if(dX < ema)
            {
                inputDir(0, prevDir)
                updateEMA(0, ema, alpha)
            }
            else
            {
                inputDir(1, prevDir)
                updateEMA(1, ema, alpha)
            }
        }
        else ; (mdX <= -pixelThreshold)
        {
            ; target value is between -1 and 0
            ema := max(-1, min(0, ema))
            
            if(dX < ema)
            {
                inputDir(-1, prevDir)
                updateEMA(-1, ema, alpha)
            }
            else
            {
                inputDir(0, prevDir)
                updateEMA(0, ema, alpha)
            }
        }
    }
    else ; (mdX == 0)
    {
        inputDir(0, prevDir)
        updateEMA(0, ema, alpha)
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
        ema := 0
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
                send {Blind}{right up}
            }
            if (prevDirection == -1)
            {
                send {Blind}{left up}
            }
            prevDirection := 0
            return
            
        case -1:
            if (prevDirection == 1)
            {
                send {Blind}{right up}
            }
            send {Blind}{left down}
            prevDirection := -1
            return
            
        case 1:
            if (prevDirection == -1)
            {
                send {Blind}{left up}
            }
            send {Blind}{right down}
            prevDirection := 1
            return
    }
}

updateEMA(val, ByRef avg, alpha)
{
    avg := alpha*val + (1-alpha)*avg
}



WheelUpHotkey:
doScrollUp := 1
return

WheelDownHotkey:
doScrollDown := 1
return



LeftClickCombatHotkey:
send {Blind}{%emuTriangleKey% down}
KeyWait, LButton
send {Blind}{%emuTriangleKey% up}
return

LeftClickMenuHotkey:
send {Blind}{%emuCircleKey% down}
KeyWait, LButton
send {Blind}{%emuCircleKey% up}
return

RightClickCombatHotkey:
send {Blind}{%emuCircleKey% down}
KeyWait, RButton
send {Blind}{%emuCircleKey% up}
return

RightClickMenuHotkey:
send {Blind}{%emuCrossKey% down}
KeyWait, RButton
send {Blind}{%emuCrossKey% up}
return



WMenuHotkey:
send {Blind}{%emuDpadUpKey% down}
KeyWait, W
send {Blind}{%emuDpadUpKey% up}
return

AMenuHotkey:
send {Blind}{%emuDpadLeftKey% down}
KeyWait, A
send {Blind}{%emuDpadLeftKey% up}
return

SMenuHotkey:
send {Blind}{%emuDpadDownKey% down}
KeyWait, S
send {Blind}{%emuDpadDownKey% up}
return

DMenuHotkey:
send {Blind}{%emuDpadRightKey% down}
KeyWait, D
send {Blind}{%emuDpadRightKey% up}
return



WCombatHotkey:
send {Blind}{%emuAnalogUpKey% down}
KeyWait, W
send {Blind}{%emuAnalogUpKey% up}
return

ACombatHotkey:
send {Blind}{%emuAnalogLeftKey% down}
KeyWait, A
send {Blind}{%emuAnalogLeftKey% up}
return

SCombatHotkey:
send {Blind}{%emuAnalogDownKey% down}
KeyWait, S
send {Blind}{%emuAnalogDownKey% up}
return

DCombatHotkey:
send {Blind}{%emuAnalogRightKey% down}
KeyWait, D
send {Blind}{%emuAnalogRightKey% up}
return



DisableKeyHotkey:
return



SetCombatMode:
menuMode := false
gosub, DisableMenuHotkeys
gosub, EnableCombatHotkeys
return



MenuModeToggleHotkey:
menuMode := !menuMode
if(menuMode)
{
    SoundPlay, %A_WorkingDir%/%menuModeSoundPath%
    gosub, DisableCombatHotkeys
    gosub, EnableMenuHotkeys
}
else
{
    SoundPlay, %A_WorkingDir%/%combatModeSoundPath%
    gosub, DisableMenuHotkeys
    gosub, EnableCombatHotkeys
}
KeyWait, %menuModeToggleKey%
return



DisableMenuHotkeys:

Hotkey, *W, WMenuHotkey, off
Hotkey, *A, AMenuHotkey, off
Hotkey, *S, SMenuHotkey, off
Hotkey, *D, DMenuHotkey, off

Hotkey, *LButton, LeftClickMenuHotkey, off
Hotkey, *RButton, RightClickMenuHotkey, off

return


EnableMenuHotkeys:

Hotkey, *W, WMenuHotkey, on
Hotkey, *A, AMenuHotkey, on
Hotkey, *S, SMenuHotkey, on
Hotkey, *D, DMenuHotkey, on

Hotkey, *LButton, LeftClickMenuHotkey, on
Hotkey, *RButton, RightClickMenuHotkey, on

return


DisableCombatHotkeys:

Hotkey, *W, WCombatHotkey, off
Hotkey, *A, ACombatHotkey, off
Hotkey, *S, SCombatHotkey, off
Hotkey, *D, DCombatHotkey, off

Hotkey, *LButton, LeftClickCombatHotkey, off
Hotkey, *RButton, RightClickCombatHotkey, off

return


EnableCombatHotkeys:

Hotkey, *W, WCombatHotkey, on
Hotkey, *A, ACombatHotkey, on
Hotkey, *S, SCombatHotkey, on
Hotkey, *D, DCombatHotkey, on

Hotkey, *LButton, LeftClickCombatHotkey, on
Hotkey, *RButton, RightClickCombatHotkey, on

return