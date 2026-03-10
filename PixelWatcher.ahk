#Persistent
#SingleInstance Force
#NoEnv

;this line makes the script only work when Path of Exile is the active window
#IfWinActive, ahk_class POEWindowClass

SetBatchLines, -1
CoordMode, Pixel, Screen

; =============================================================================
; CONFIGURATION - Edit these values to suit your needs
; =============================================================================

; Pixel location 1
Pixel1_X := 1939
Pixel1_Y := 1365

; Pixel location 2
Pixel2_X := 2087
Pixel2_Y := 1364

; Expected color in 0xRRGGBB format (e.g. 0xFF0000 = red)
ExpectedColor := 0xDED277

; Color tolerance (0 = exact match, higher = more lenient)
ColorTolerance := 10

; How often to check pixels (in milliseconds)
CheckInterval := 250

; Alert box dimensions (pixels)
AlertWidth  := 64
AlertHeight := 64

; Delay before alert escalates from green to red (in milliseconds)
AlertEscalationMs := 3000

; =============================================================================
; SETUP - Build two separate overlay GUIs
; =============================================================================

Alert1Visible := false
Alert2Visible := false
Alert1ShownAt := 0
Alert2ShownAt := 0
Alert1Escalated := false
Alert2Escalated := false
Suppressed := false

SysGet, MonW, 78
SysGet, MonH, 79

; Alert 1 - shows "Q" when pixel 1 doesn't match
Gui, Alert1:+AlwaysOnTop -Caption +ToolWindow +E0x20
Gui, Alert1:Color, 1A1A1A
Gui, Alert1:Margin, 0, 0
Gui, Alert1:Font, s28 Bold, Arial
Gui, Alert1:Add, Text, vAlert1Text w%AlertWidth% h%AlertHeight% Center cWhite BackgroundTrans +0x200, Q
Gui, Alert1:Color, 00CC00

; Alert 2 - shows "E" when pixel 2 doesn't match
Gui, Alert2:+AlwaysOnTop -Caption +ToolWindow +E0x20
Gui, Alert2:Color, 1A1A1A
Gui, Alert2:Margin, 0, 0
Gui, Alert2:Font, s28 Bold, Arial
Gui, Alert2:Add, Text, vAlert2Text w%AlertWidth% h%AlertHeight% Center cWhite BackgroundTrans +0x200, E
Gui, Alert2:Color, 00CC00

; Position alerts side by side, centered on screen with a small gap
AlertGap := 20
;Alert1X := (MonW // 2) - AlertWidth - (AlertGap // 2)
;Alert2X := (MonW // 2) + (AlertGap // 2)
;AlertY  := (MonH - AlertHeight) // 2

Alert1X := 1200
Alert2X := 1280
AlertY  := 550


SetTimer, CheckPixels, %CheckInterval%

TrayTip, PixelWatcher, Monitoring started. Press Ctrl+Shift+Q to quit., 3
return

; =============================================================================
; PIXEL CHECK ROUTINE
; =============================================================================

CheckPixels:
    IfWinNotActive, ahk_class POEWindowClass
    {
        GoSub, HideAlert1
        GoSub, HideAlert2
        return
    }

    if (Suppressed) {
        GoSub, HideAlert1
        GoSub, HideAlert2
        return
    }

    PixelGetColor, Color1, %Pixel1_X%, %Pixel1_Y%, RGB
    PixelGetColor, Color2, %Pixel2_X%, %Pixel2_Y%, RGB

    Match1 := ColorsMatch(Color1, ExpectedColor, ColorTolerance)
    Match2 := ColorsMatch(Color2, ExpectedColor, ColorTolerance)

    if (!Match1) {
        if (!Alert1Visible) {
            Gui, Alert1:Color, 00CC00
            remaining := AlertEscalationMs / 1000
            GuiControl, Alert1:, Alert1Text, % Format("{:.1f}", remaining)
            Gui, Alert1:Show, x%Alert1X% y%AlertY% NoActivate, PixelWatcherAlert1
            Alert1Visible := true
            Alert1ShownAt := A_TickCount
            Alert1Escalated := false
        } else if (!Alert1Escalated) {
            elapsed := A_TickCount - Alert1ShownAt
            if (elapsed >= AlertEscalationMs) {
                Gui, Alert1:Color, FF0000
                GuiControl, Alert1:, Alert1Text, Q
                Alert1Escalated := true
            } else {
                remaining := (AlertEscalationMs - elapsed) / 1000
                GuiControl, Alert1:, Alert1Text, % Format("{:.1f}", remaining)
            }
        }
    } else {
        GoSub, HideAlert1
    }

    if (!Match2) {
        if (!Alert2Visible) {
            Gui, Alert2:Color, 00CC00
            remaining := AlertEscalationMs / 1000
            GuiControl, Alert2:, Alert2Text, % Format("{:.1f}", remaining)
            Gui, Alert2:Show, x%Alert2X% y%AlertY% NoActivate, PixelWatcherAlert2
            Alert2Visible := true
            Alert2ShownAt := A_TickCount
            Alert2Escalated := false
        } else if (!Alert2Escalated) {
            elapsed := A_TickCount - Alert2ShownAt
            if (elapsed >= AlertEscalationMs) {
                Gui, Alert2:Color, FF0000
                GuiControl, Alert2:, Alert2Text, E
                Alert2Escalated := true
            } else {
                remaining := (AlertEscalationMs - elapsed) / 1000
                GuiControl, Alert2:, Alert2Text, % Format("{:.1f}", remaining)
            }
        }
    } else {
        GoSub, HideAlert2
    }
return

; =============================================================================
; HIDE / RESET ALERT SUBROUTINES
; =============================================================================

HideAlert1:
    if (Alert1Visible) {
        Gui, Alert1:Hide
        Gui, Alert1:Color, 00CC00
        GuiControl, Alert1:, Alert1Text, Q
        Alert1Visible := false
        Alert1ShownAt := 0
        Alert1Escalated := false
    }
return

HideAlert2:
    if (Alert2Visible) {
        Gui, Alert2:Hide
        Gui, Alert2:Color, 00CC00
        GuiControl, Alert2:, Alert2Text, E
        Alert2Visible := false
        Alert2ShownAt := 0
        Alert2Escalated := false
    }
return

; =============================================================================
; COLOR COMPARISON WITH TOLERANCE
; =============================================================================

ColorsMatch(actual, expected, tolerance) {
    actualR := (actual >> 16) & 0xFF
    actualG := (actual >> 8)  & 0xFF
    actualB :=  actual        & 0xFF

    expectR := (expected >> 16) & 0xFF
    expectG := (expected >> 8)  & 0xFF
    expectB :=  expected        & 0xFF

    return (Abs(actualR - expectR) <= tolerance)
        && (Abs(actualG - expectG) <= tolerance)
        && (Abs(actualB - expectB) <= tolerance)
}

; =============================================================================
; HOTKEYS
; =============================================================================

; Ctrl+Shift+Q  -> Quit
^+q::
    SetTimer, CheckPixels, Off
    Gui, Alert1:Destroy
    Gui, Alert2:Destroy
    TrayTip, PixelWatcher, Monitoring stopped., 2
    Sleep, 1500
    ExitApp
return

; Ctrl+Shift+D  -> Toggle alert suppression
^+d::
    Suppressed := !Suppressed
    if (Suppressed) {
        TrayTip, PixelWatcher, Alerts suppressed., 2
    } else {
        TrayTip, PixelWatcher, Alerts enabled., 2
    }
return
