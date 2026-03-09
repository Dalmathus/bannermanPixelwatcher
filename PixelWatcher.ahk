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

; =============================================================================
; SETUP - Build two separate overlay GUIs
; =============================================================================

Alert1Visible := false
Alert2Visible := false
Suppressed := false

SysGet, MonW, 78
SysGet, MonH, 79

; Alert 1 - shows "Q" when pixel 1 doesn't match
Gui, Alert1:+AlwaysOnTop -Caption +ToolWindow +E0x20
Gui, Alert1:Color, 1A1A1A
Gui, Alert1:Margin, 0, 0
Gui, Alert1:Font, s48 Bold, Arial
Gui, Alert1:Add, Text, w%AlertWidth% h%AlertHeight% Center cWhite BackgroundTrans +0x200, Q
Gui, Alert1:Color, FF0000

; Alert 2 - shows "E" when pixel 2 doesn't match
Gui, Alert2:+AlwaysOnTop -Caption +ToolWindow +E0x20
Gui, Alert2:Color, 1A1A1A
Gui, Alert2:Margin, 0, 0
Gui, Alert2:Font, s48 Bold, Arial
Gui, Alert2:Add, Text, w%AlertWidth% h%AlertHeight% Center cWhite BackgroundTrans +0x200, E
Gui, Alert2:Color, FF0000

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
        if (Alert1Visible) {
            Gui, Alert1:Hide
            Alert1Visible := false
        }
        if (Alert2Visible) {
            Gui, Alert2:Hide
            Alert2Visible := false
        }
        return
    }

    if (Suppressed) {
        if (Alert1Visible) {
            Gui, Alert1:Hide
            Alert1Visible := false
        }
        if (Alert2Visible) {
            Gui, Alert2:Hide
            Alert2Visible := false
        }
        return
    }

    PixelGetColor, Color1, %Pixel1_X%, %Pixel1_Y%, RGB
    PixelGetColor, Color2, %Pixel2_X%, %Pixel2_Y%, RGB

    Match1 := ColorsMatch(Color1, ExpectedColor, ColorTolerance)
    Match2 := ColorsMatch(Color2, ExpectedColor, ColorTolerance)

    if (!Match1) {
        if (!Alert1Visible) {
            Gui, Alert1:Show, x%Alert1X% y%AlertY% NoActivate, PixelWatcherAlert1
            Alert1Visible := true
        }
    } else {
        if (Alert1Visible) {
            Gui, Alert1:Hide
            Alert1Visible := false
        }
    }

    if (!Match2) {
        if (!Alert2Visible) {
            Gui, Alert2:Show, x%Alert2X% y%AlertY% NoActivate, PixelWatcherAlert2
            Alert2Visible := true
        }
    } else {
        if (Alert2Visible) {
            Gui, Alert2:Hide
            Alert2Visible := false
        }
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
