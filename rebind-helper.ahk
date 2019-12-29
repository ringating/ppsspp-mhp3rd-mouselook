#persistent
sendmode input

OnMessage(4444, "MessageFromParentScript")

global inMenuMode := false
global scriptActive := false
liftAllKeys := false

; emulator keybind constants
; (emulator should match these binds)
; (none of the user's script keybinds should overlap with any of these keys)
emu := {}
emu.DpadUp :=       {key: "up",     pressed: false}
emu.DpadLeft :=     {key: "left",   pressed: false}
emu.DpadRight :=    {key: "right",  pressed: false}
emu.DpadDown :=     {key: "down",   pressed: false}
emu.AnalogUp :=     {key: "h", pressed: false}
emu.AnalogLeft :=   {key: "j", pressed: false}
emu.AnalogRight :=  {key: "k", pressed: false}
emu.AnalogDown :=   {key: "l", pressed: false}
emu.Triangle :=     {key: "u", pressed: false}
emu.Square :=       {key: "i", pressed: false}
emu.Circle :=       {key: "o", pressed: false}
emu.Cross :=        {key: "p", pressed: false}
emu.L :=            {key: ";", pressed: false}
emu.R :=            {key: "'", pressed: false}
emu.Null :=         {key: "m", pressed: false} ; used to effectively disable a key (as far as ppsspp is concerned)

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;
; ;;; user keybinds (customize controls here!) ;;; ;
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;

userKeys := {}
userKeys.Push({ key: "w",       combat: "AnalogUp",    menu: "DpadUp"     })   
userKeys.Push({ key: "a",       combat: "AnalogLeft",  menu: "DpadLeft"   })
userKeys.Push({ key: "d",       combat: "AnalogRight", menu: "DpadRight"  })    
userKeys.Push({ key: "s",       combat: "AnalogDown",  menu: "DpadDown"   })    
userKeys.Push({ key: "LButton", combat: "Triangle",    menu: "Circle"     })  
userKeys.Push({ key: "RButton", combat: "Circle",      menu: "Cross"      }) 
userKeys.Push({ key: "Space",   combat: "Cross",       menu: "Null"       })
userKeys.Push({ key: "LCtrl",   combat: "L",           menu: "Null"       })
userKeys.Push({ key: "LShift",  combat: "R",           menu: "Null"       })
userKeys.Push({ key: "q",       combat: "Square",      menu: "L"          })
userKeys.Push({ key: "e",       combat: "Circle",      menu: "R"          })
userKeys.Push({ key: "XButton1",combat: "Null",        menu: "Square"     })
userKeys.Push({ key: "XButton1",combat: "Null",        menu: "Triangle"   })

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;
; ;;;;;;;;;;;;; end of user keybinds ;;;;;;;;;;;;; ;
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;

SetTimer, FastUpdate, 10

return



MessageFromParentScript(wParam, lParam, msg, hwnd)
{
    scriptActive := wParam
    inMenuMode := lParam
    
    ; enable/disable inputs that interfere w/ gameplay
    if(scriptActive)
    {
        Hotkey, *LButton, DisableKeyHotkey, on
        Hotkey, *RButton, DisableKeyHotkey, on
        Hotkey, *LCtrl, DisableKeyHotkey, on
        Hotkey, *LAlt, DisableKeyHotkey, on
    }
    else
    {
        Hotkey, *LButton, DisableKeyHotkey, off
        Hotkey, *RButton, DisableKeyHotkey, off
        Hotkey, *LCtrl, DisableKeyHotkey, off
        Hotkey, *LAlt, DisableKeyHotkey, off
    }
    
    GoSub, SetAllPressedFalse
}



UpdateAllAccordingToPressed:
    For key, value in emu
    {
        if(value.pressed)
        {
            tmp := value.key
            send {blind}{%tmp% down}
        }
        else
        {
            tmp := value.key
            send {blind}{%tmp% up}
        }
    }
    return



SetAllPressedFalse:
    For key, value in emu
    {
        value.pressed := false
    }
    return



LiftAllEmuKeys:
    For key, value in emu
    {
        send {blind}{value.key up}
        value.pressed := false
    }
    return



DisableKeyHotkey:
    return



FastUpdate:

    if(scriptActive)
    {
        GoSub, SetAllPressedFalse
        if(inMenuMode)
        {
            For index, value in userKeys
            {
                if (GetKeyState(value.key, "P"))
                {
                    emu[value.menu].pressed := true
                }
            }
        }
        else
        {
            For index, value in userKeys
            {
                if (GetKeyState(value.key, "P"))
                {
                    emu[value.combat].pressed := true
                }
            }
        }
        GoSub, UpdateAllAccordingToPressed
        liftAllKeys := true
    }
    else
    {
        if(liftAllKeys)
        {
            GoSub, LiftAllEmuKeys
            liftAllKeys := false
        }
    }

    return