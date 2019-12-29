#persistent
sendmode input

msgPort := 4444
OnMessage(4444, "MessageFromParentScript")

global inMenuMode := false
global scriptActive := false
liftAllKeys := false

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
emuNull := "m" ; used to effectively disable a key (as far as ppsspp is concerned)

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

SetTimer, FastUpdate, 10

return


MessageFromParentScript(wParam, lParam, msg, hwnd)
{
    scriptActive := wParam
    inMenuMode := lParam
}


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

    if(scriptActive)
    {
        if(inMenuMode)
        {
            LiftAllCombatKeys()
            For index, value in userKeys
            {
                UpdateXAccordingToY(value.menu, value.key)
            }
        }
        else
        {
            LiftAllMenuKeys()
            For index, value in userKeys
            {
                UpdateXAccordingToY(value.combat, value.key)
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