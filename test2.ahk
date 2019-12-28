#persistent
sendmode input
Hotkey, *LCtrl, DisableKeyHotkey, on
SetTimer, update, 10
return

update:
if (GetKeyState("LCtrl", "P")) ; this still works despite hotkey
    msgbox, LCtrl is down
return

DisableKeyHotkey:
return