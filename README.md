# Hammerspoon Dock Auto-Hide

A Hammerspoon script that automatically hides or shows the Dock based on window state in macOS.

## Why?

macOS full-screen mode creates a separate Space, making it impossible to float other apps on top.

This script provides a similar experience using **maximize + auto-hide Dock** instead of full-screen mode. You get more screen space while keeping the ability to use multiple windows.

## Features

| Window State | Dock |
|--------------|------|
| Maximized | Auto-hide |
| Normal window | Visible |
| Desktop | Visible |

**Additional features:**
- Automatically expands window to fill the Dock area after hiding

## macOS Settings

Before using this script, configure your Dock settings:

**System Settings → Desktop & Dock:**
- **Automatically hide and show the Dock:** Off (the script will control this)
- **Position on screen:** Bottom

## Installation

### 1. Install Hammerspoon

```bash
brew install hammerspoon --cask
```

### 2. Copy the script

```bash
mkdir -p ~/.hammerspoon
curl -o ~/.hammerspoon/init.lua https://raw.githubusercontent.com/Joowonoil/hammerspoon-dock-autohide/main/init.lua
```

### 3. Launch Hammerspoon

```bash
open -a Hammerspoon
```

On first launch, grant **Accessibility** permission when prompted.

### 4. Launch at login (optional)

Menu bar hammer icon → Preferences → **Launch Hammerspoon at login**

## Usage

Just use your Mac normally. The Dock will automatically hide when you maximize a window, and reappear when you switch to a smaller window.

**Reload config:** `Cmd + Ctrl + R`

## Tips

Use with [TopNotch](https://topnotch.app) to make the menu bar background black. Combined with this script, it feels like full-screen mode while keeping multi-window flexibility.

## Compatibility

- macOS Sonoma, Sequoia, Tahoe (Apple Silicon)
- Works with Rectangle, Magnet, and other window managers

## License

MIT License
