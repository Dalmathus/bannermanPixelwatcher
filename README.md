# PixelWatcher for Path of Exile

An AutoHotkey v1 script that monitors two screen pixels for a specific colour. When a pixel no longer matches the expected colour, a green alert box appears with a countdown timer. If the mismatch persists past the countdown, the box turns red and displays the key label (**Q** or **E**). This is designed to watch banner/buff indicators in Path of Exile and warn you when they drop off.

## Requirements

- [AutoHotkey v1.1+](https://www.autohotkey.com/)
- Windows 10/11

## Quick Start

1. Open `PixelWatcher.ahk` in a text editor.
2. Configure the pixel locations, expected colour, and alert positions (see below).
3. Double-click `PixelWatcher.ahk` to run it.
4. Switch to Path of Exile — alerts will appear when the watched pixels stop matching.

## Configuration

All configurable values are at the top of `PixelWatcher.ahk` inside the **CONFIGURATION** section.

### Pixel Locations

Set the screen coordinates of the two pixels you want to monitor:

```ahk
Pixel1_X := 1939
Pixel1_Y := 1365

Pixel2_X := 2087
Pixel2_Y := 1364
```

### Expected Colour and Tolerance

The colour each pixel is compared against, in `0xRRGGBB` format, and a per-channel tolerance (0 = exact match):

```ahk
ExpectedColor := 0xDED277
ColorTolerance := 10
```

A tolerance of `10` means each of the R, G, and B channels may differ by up to 10 from the expected value and still be considered a match. Increase this if lighting or post-processing causes slight colour shifts.

### Alert Escalation Delay

When an alert first appears it is **green** and displays a countdown timer (e.g. "3.0", "2.8", ..., "0.0"). Once the countdown reaches zero, the box turns **red** and shows the key label (**Q** or **E**) to indicate the buff needs attention:

```ahk
AlertEscalationMs := 3000
```

The value is in milliseconds (3000 = 3 seconds). The countdown updates every `CheckInterval` tick (default 250ms) with one decimal place. If the watched pixel returns to the expected colour before the countdown elapses, the alert disappears and the timer resets — the next appearance will start green with a fresh countdown.

### Check Interval

How frequently (in milliseconds) the script samples the pixels:

```ahk
CheckInterval := 250
```

### Alert Box Position

The alert boxes default to hard-coded positions. Edit these values to move them wherever you like on screen:

```ahk
Alert1X := 1200
Alert2X := 1280
AlertY  := 550
```

If you prefer the alerts centred on your primary monitor, uncomment the three lines above and remove the hard-coded values:

```ahk
Alert1X := (MonW // 2) - AlertWidth - (AlertGap // 2)
Alert2X := (MonW // 2) + (AlertGap // 2)
AlertY  := (MonH - AlertHeight) // 2
```

### Alert Box Size

```ahk
AlertWidth  := 64
AlertHeight := 64
```

## Hotkeys

All hotkeys only work while Path of Exile is the active window.

| Hotkey | Action |
|---|---|
| `Ctrl + Shift + Q` | Quit the script |
| `Ctrl + Shift + D` | Toggle alert suppression on/off |

## Finding Pixel Locations and Colours with AHK Window Spy

AutoHotkey ships with a utility called **Window Spy** that lets you identify exact pixel coordinates and colours on screen.

### Opening Window Spy

1. Right-click the AutoHotkey **H** icon in your system tray.
2. Select **Window Spy** from the context menu.
   - If you installed AHK but don't see a tray icon, launch `WindowSpy.ahk` from the AutoHotkey install directory (typically `C:\Program Files\AutoHotkey\WindowSpy.ahk`).

### Finding the Pixel Coordinates

1. Open Path of Exile and make sure the banner/buff you want to track is visible.
2. In Window Spy, look at the **Mouse Position** section. You will see coordinates listed under several headings — use the **Screen** coordinates (these match the script's `CoordMode, Pixel, Screen` setting).
3. Hover your mouse over the centre of the banner icon you want to watch. Note down the `x` and `y` values shown under **Screen**.
4. Enter those values in `PixelWatcher.ahk`:

```ahk
Pixel1_X := <your x value>
Pixel1_Y := <your y value>
```

5. Repeat for the second banner pixel.

### Finding the Expected Colour

1. With Window Spy still open, hover over the same pixel location.
2. Look at the **Color** value displayed in Window Spy (shown in `0xRRGGBB` or `0xBBGGRR` format depending on version).
3. Make sure the colour is in **RGB** order. Window Spy may show it in BGR — if so, reverse the last six characters. For example, if Window Spy shows `0x77D2DE`, the RGB equivalent is `0xDED277`.
4. Set the value in the script:

```ahk
ExpectedColor := 0xDED277
```

### Tips

- Pick a pixel near the **centre** of the icon so minor UI shifts don't throw off the detection.
- Choose a colour that is **unique** to the active state of the banner. Avoid edges or areas that blend with the background.
- If the colour changes slightly between sessions (e.g., due to lighting effects), increase `ColorTolerance` from `10` to `15` or `20`.
- Use Window Spy's **Follow Mouse** checkbox to have the coordinates update in real time as you move the cursor.

## How It Works

The script polls two screen pixel locations every `CheckInterval` milliseconds. Each pixel's current colour is compared to `ExpectedColor` using per-channel tolerance. If a pixel no longer matches, a small green overlay box appears showing a countdown in seconds. While the countdown is ticking, the box stays green. Once the countdown reaches zero, the box turns red and shows the key label — **Q** (pixel 1) or **E** (pixel 2) — to indicate the buff has been down long enough to need attention. The overlays are click-through so they never interfere with gameplay. The script only runs checks while Path of Exile is the active window.
