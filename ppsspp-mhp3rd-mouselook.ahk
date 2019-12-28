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

; script toggling stuff
scriptIsActive   := 0
scriptWasActive  := 0
isTogglePressed  := 0
wasTogglePressed := 0

SetTimer, Update, 33 ; this value should be ( 1000 / (game's framerate) )
; if the game's framerate is variable, then use the lowest expected framerate as the "game's framerate"
; this will hopefully ensure that none of the inputs are missed by the game

SetTimer, FastUpdate, 10 ; poll more frequently in order to reduce latency on button inputs

; scroll stuff
doScrollUp := false
didScrollUp := false
doScrollDown := false
didScrollDown := false 

; emulator keybind constants
; (emulator should match these binds)
; (none of the user's script keybinds should overlap with any of these keys)
emuDpadUp := "up"
emuDpadLeft := "left"
emuDpadRight := "right"
emuDpadDown := "down"
emuAnalogUp := "h"
emuAnalogLeft := "j"
emuAnalogRight := "k"
emuAnalogDown := "l"
emuTriangle := "u"
emuSquare := "i"
emuCircle := "o"
emuCross := "p"
emuL := ";"
emuR := "'"
emuNull := "m" ; used to effectively disable a key as far as ppsspp is concerned

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;
; ;;; user keybinds (customize controls here!) ;;; ;
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;
userKeys := {}
userKeys.Push({ key: "w",       combat: emuAnalogUp,     menu: emuDpadUp    })   
userKeys.Push({ key: "a",       combat: emuAnalogLeft,   menu: emuDpadLeft  })
userKeys.Push({ key: "d",       combat: emuAnalogRight,  menu: emuDpadRight })    
userKeys.Push({ key: "s",       combat: emuAnalogDown,   menu: emuDpadDown  })    
userKeys.Push({ key: "LButton", combat: emuTriangle,     menu: emuCircle    })  
userKeys.Push({ key: "RButton", combat: emuCircle,       menu: emuCross     }) 
userKeys.Push({ key: "Space",   combat: emuCross,        menu: emuNull      })
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;
; ;;;;;;;;;;;;; end of user keybinds ;;;;;;;;;;;;; ;
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;

; menu/combat state toggling stuff
menuModeToggleKey = r
menuMode := false

; toggle sfx
menuModeSoundPath = main6bL.dsp.wav
combatModeSoundPath = main3f.dsp.wav

; window change detecting stuff
currWinID := 0
prevWinID := 0
winChange := false

liftAllKeys := true

return



; ; ; ; ; ; ; ; ; ;
; determine whether the window has changed or the toggle button has been pressed to disable the script
; ; ; ; ; ; ; ; ; ;

RunAtUpdateStart:

    if (GetKeyState(toggleKey, "P"))
    {
        isTogglePressed := true
    }
    else
    {
        isTogglePressed := false
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
            menuMode := false
            
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
        }
    }

    return



UpdateXAccordingToY(x,y)
{
    if (GetKeyState(y, "P"))
    {
        send {blind}{%x% down}
    }
    else
    {
        send {blind}{%x% up}
    }
}

LiftAllCombatKeys()
{
    For index, value in userKeys
    {
        send {blind}{value.combat up}
    }
}

LiftAllMenuKeys()
{
    For index, value in userKeys
    {
        send {blind}{value.menu up}
    }
}

FastUpdate:

    if(winChange)
        return

    if(scriptIsActive)
    {
        For index, value in userKeys
        {
            if(menuMode)
            {
                UpdateXAccordingToY(value.menu, value.key)
                LiftAllCombatKeys()
            }
            else
            {
                UpdateXAccordingToY(value.combat, value.key)
                LiftAllMenuKeys()
            }
            
        }
        liftAllKeys := true
    }
    else
    {
        if(liftAllKeys)
        {
            LiftAllCombatKeys()
            LiftAllMenuKeys()
            liftAllKeys := false
        }
    }

    return



Update:

    GoSub, RunAtUpdateStart

    if(winChange) ; potentially set in RunAtUpdateStart
        return

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



DisableKeyHotkey:
    return



MenuModeToggleHotkey:
    menuMode := !menuMode
    if(menuMode)
    {
        SoundPlay, %A_WorkingDir%/%menuModeSoundPath%
        LiftAllCombatKeys()
    }
    else
    {
        SoundPlay, %A_WorkingDir%/%combatModeSoundPath%
        LiftAllMenuKeys()
    }
    KeyWait, %menuModeToggleKey%
    return