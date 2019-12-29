global myBool := false

OnMessage(4444, "MyMessageMonitor")

MyMessageMonitor(wParam, lParam, msg, hwnd)
{
    ; msgbox, wParam: %wParam%, lParam: %lParam%
    myBool := !myBool
    return 0
}

Space::
    msgbox, myBool: %myBool%
    return