#persistent
sendmode input

userKeys := {}

userKeys.Push({key: "w",       combat: "h", menu: "up"})   
userKeys.Push({key: "a",       combat: "j", menu: "left"})
userKeys.Push({key: "d",       combat: "k", menu: "right"})    
userKeys.Push({key: "s",       combat: "l", menu: "down"})    
userKeys.Push({key: "LButton", combat: "u", menu: "o"})  
userKeys.Push({key: "RButton", combat: "o", menu: "p"}) 
userKeys.Push({key: "Space",   combat: "p", menu: "m"})

SetTimer, FastUpdate, 10

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


FastUpdate:

For index, value in userKeys
{
    UpdateXAccordingToY(value.combat, value.key)
}

return