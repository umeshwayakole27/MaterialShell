# Connected Frame Mode

Connected Frame Mode transforms DankMaterialShell from a collection of floating, independent surfaces into a unified edge-connected shell. Instead of separate panels with gaps and shadows, all surfaces — bar, popouts, notifications, OSD, launcher, dock — emerge flush from a continuous picture-frame border around your display.

---

## Table of Contents

1. [Overview](#overview)
2. [Enabling Connected Frame Mode](#enabling-connected-frame-mode)
3. [All Settings Reference](#all-settings-reference)
4. [Visual Behavior: Connected vs Separate](#visual-behavior-connected-vs-separate)
5. [How It Works Internally](#how-it-works-internally)
6. [The Frame Module](#the-frame-module)
7. [Per-Screen Configuration](#per-screen-configuration)
8. [Theme Integration](#theme-integration)
9. [Connected Popouts & Surfaces](#connected-popouts--surfaces)
10. [Niri Overview Integration](#niri-overview-integration)
11. [IPC Command Reference](#ipc-command-reference)
12. [Troubleshooting](#troubleshooting)

---

## Overview

Connected Frame Mode is a core visual system in DMS that replaces the traditional floating-panel desktop shell with an edge-connected layout. When enabled:

- A **continuous picture-frame border** is drawn around the entire display (or selected screens)
- All shell surfaces (bar notifications, OSD, popouts, launcher) emerge **flush from this frame** — no gaps, no shadows between surfaces and the edge
- The **bar becomes part of the frame**, sharing the same thickness and color
- The frame's **cutout** (the area inside the border) contains all shell surfaces
- **Connector geometry** (arcs at the junctions) smoothly transitions between surfaces and the frame perimeter

The result is a unified, cohesive look where everything feels connected to the edge of the screen rather than floating independently.

---

## Enabling Connected Frame Mode

### Via Settings UI

1. Open **Settings** (click the gear icon in the bar or use `Mod+Comma`)
2. Go to the **Frame** tab
3. Toggle **"Enable Frame"** ON
4. Under **Mode** → **Surface Behavior**, select **"Connected"**
5. Settings apply instantly — no restart needed

### Via IPC Commands

```bash
# Enable the frame system
dms ipc call settings set frameEnabled true

# Set mode to "connected" (surfaces emerge flush from bar)
dms ipc call settings set frameMode connected

# Or set to "separate" (surfaces float independently)
dms ipc call settings set frameMode separate
```

### Via Direct Config Edit

Edit `~/.config/DankMaterialShell/settings.json`:

```json
{
  "frameEnabled": true,
  "frameMode": "connected"
}
```

Then reload: `dms restart`

---

## All Settings Reference

### Frame Enable

| Setting | IPC Command | Default | Description |
|---------|-------------|---------|-------------|
| `frameEnabled` | `dms ipc call settings set frameEnabled true` | `false` | Enable/disable the entire frame system |
| `frameMode` | `dms ipc call settings set frameMode connected` | `"connected"` | `"connected"` = surfaces flush with bar; `"separate"` = surfaces float independently |

### Border Appearance

| Setting | IPC Command | Default | Description |
|---------|-------------|---------|-------------|
| `frameThickness` | `dms ipc call settings set frameThickness 16` | `16` | Width of the picture-frame border in px (range: 2–100) |
| `frameRounding` | `dms ipc call settings set frameRounding 23` | `23` | Corner radius of the border in px (range: 0–100) |
| `frameBarSize` | `dms ipc call settings set frameBarSize 40` | `40` | Bar thickness in frame mode in px (range: 24–100) |
| `frameOpacity` | `dms ipc call settings set frameOpacity 1.0` | `1.0` | Opacity of the frame border and connected surfaces (0.0–1.0) |
| `frameColor` | `dms ipc call settings set frameColor "primary"` | `""` | Color of the frame border. Options: `""` (default = theme surfaceContainer), `"primary"` (theme primary), `"surface"` (theme surface), or a hex color like `"#2a2a2a"` |
| `frameBlurEnabled` | `dms ipc call settings set frameBlurEnabled true` | `true` | Apply compositor background blur behind the frame (requires ext-background-effect-v1 support) |

### Connected Mode Options

These only apply when `frameEnabled: true` AND `frameMode: "connected"`.

| Setting | IPC Command | Default | Description |
|---------|-------------|---------|-------------|
| `frameCloseGaps` | `dms ipc call settings set frameCloseGaps true` | `true` | When `true`: surfaces meet the frame seamlessly, hiding the arcs. When `false`: arcs at surface junctions are exposed as visual connectors. IPC flips this — use `!checked` logic |
| `frameLauncherEmergeSide` | `dms ipc call settings set frameLauncherEmergeSide bottom` | `"bottom"` | Which edge the launcher slides from: `"bottom"` or `"top"` |
| `frameLauncherArcExtender` | `dms ipc call settings set frameLauncherArcExtender false` | `false` | Use the extended arc surface for launcher content area |

### Screen Assignment

| Setting | IPC Command | Default | Description |
|---------|-------------|---------|-------------|
| `frameScreenPreferences` | via Settings UI only | `["all"]` | Which monitors show the frame. Options: `"all"` or specific monitor names like `"DP-1"`, `"HDMI-A-1"` |

### Niri Integration

| Setting | IPC Command | Default | Description |
|---------|-------------|---------|-------------|
| `frameShowOnOverview` | `dms ipc call settings set frameShowOnOverview true` | `false` | Show the frame during Niri overview mode |

---

## Visual Behavior: Connected vs Separate

### Separate Mode (`frameMode: "separate"`)

The frame border is drawn, but shell surfaces remain as independent windows:

```
┌─────────────────────────────────┐
│  ┌───────────────────────────┐  │  ← frame border (16px)
│  │                           │  │
│  │    [Floating Bar]         │  │  ← bar has its own window, gaps
│  │                           │  │
│  │        ┌──────┐           │  │
│  │        │popout│           │  │  ← popout floats, has shadow
│  │        └──────┘           │  │
│  │                           │  │
│  └───────────────────────────┘  │
└─────────────────────────────────┘
```

- Bar retains its own margins, rounded corners, and shadow
- Popouts float above the content area with independent positioning
- Surfaces do not visually connect to the frame border

### Connected Mode (`frameMode: "connected"`)

All surfaces emerge flush from the frame:

```
┌─────────────────────────────────┐
│▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│  ← frame border
│▓▓ █████████████████████████ ▓▓▓▓│  ← bar emerges from frame
│▓▓ █   Connected Surface   █ ▓▓▓▓│  ← surfaces share frame color
│▓▓ █   ┌──────────────┐    █ ▓▓▓▓│
│▓▓ █   │  popout      │    █ ▓▓▓▓│  ← popout connected to frame edge
│▓▓ █   └──────────────┘    █ ▓▓▓▓│
│▓▓ █████████████████████████ ▓▓▓▓│
│▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│
└─────────────────────────────────┘
```

Key visual differences:

| Aspect | Separate Mode | Connected Mode |
|--------|---------------|----------------|
| Bar margins | Has own margins, spacing, bottom gaps | Zero margins — flush with frame |
| Bar corners | Rounded independently | Corners merge with frame cutout |
| Surface color | Uses `surfaceContainer` with popup transparency | Uses `effectiveFrameColor` with `frameOpacity` |
| Surface radius | Uses `Theme.cornerRadius` | Uses `Theme.connectedSurfaceRadius` |
| Shadows | Surfaces cast individual shadows | No shadows — surfaces are part of the frame |
| Popout gaps | Popups have `rawPopupGap` from bar | Zero gap between popout and bar |
| Scrollbar style | Standard rounded scrollbar | Flat scrollbar blending with surface |
| Notification cards | Individual rounded cards with shadows | Cards share frame radius, no shadows |
| Dock | Standalone window with margins | Flush with frame, shares surface color |

---

## How It Works Internally

### Architecture

Connected Frame Mode involves several interacting subsystems:

```
┌──────────────────────────────────────────────────────┐
│                    SettingsData                        │
│  frameEnabled, frameMode, frameThickness, frameColor  │
│  frameRounding, frameOpacity, frameBarSize, ...        │
│  connectedFrameModeActive (computed)                   │
│  effectiveFrameColor (computed)                        │
│                                                         │
│  Connected Frame Mode saves/restores per-bar style     │
│  backups when toggling on/off (border, shadow, etc.)   │
└──────────────────────┬───────────────────────────────┘
                       │ reads
                       ▼
┌──────────────────────────────────────────────────────┐
│              CompositorService                         │
│  usesConnectedFrameChromeForScreen(screen)             │
│  connectedFrameBlockedOnScreen(screen)                 │
│  frameWindowVisibleForScreen(screen)                   │
└──────────────────────┬───────────────────────────────┘
                       │ queries
          ┌────────────┼────────────┐
          ▼            ▼            ▼
┌──────────────┐ ┌──────────┐ ┌──────────┐
│  Frame.qml   │ │  Theme   │ │ Connected│
│  (Variants   │ │ .qml     │ │ Surfaces │
│   per-screen)│ │          │ │          │
│              │ │ .isCon-  │ │ Popouts, │
│ FrameInstance│ │ nected-  │ │ Notifica-│
│  ┌─────────┐ │ │ Effect   │ │ tions,   │
│  │FrameWin-│ │ │          │ │ Dock,    │
│  │dow.qml  │ │ │ .connec- │ │ Bar, OSD │
│  │(visual  │ │ │ tedSur-  │ │          │
│  │ border  │ │ │ faceColor│ │ usesCon- │
│  │ + SDF   │ │ │          │ │ nected-  │
│  │ cutouts)│ │ │ .connec- │ │ Surface- │
│  │         │ │ │ tedCor-  │ │ Chrome   │
│  │FrameEx- │ │ │ nerRadius│ │          │
│  │clusions │ │ │          │ │          │
│  └─────────┘ │ └──────────┘ └──────────┘
└──────────────┘
```

### The Frame Module (`quickshell/Modules/Frame/`)

Five files work together:

**`Frame.qml`** — Entry point. Creates a `Variants` over `Quickshell.screens`, loading one `FrameInstance` per screen that has frame enabled.

**`FrameInstance.qml`** — Per-screen container. Manages the `FrameWindow` (visual border), `FrameExclusions` (invisible strut windows for compositor space reservation), and lifecycle.

**`FrameWindow.qml`** — The visual frame. A full-screen `PanelWindow` at `WlrLayer.Top` that renders:
- The picture-frame border using an SDF shader (`frame_arc.frag.qsb`)
- Cutout geometry (the inner area where content lives)
- Connected surface slots for bar, popouts, notifications, modals, and toasts
- Connector arcs (SDF-based smooth transitions between surfaces and the frame)
- Elevation shadows for the frame layer

**`FrameBorder.qml`** — The actual visual ring. A `ShaderEffect` using `frame_arc.frag.qsb` that renders the rounded-rect cutout with configurable thickness, radius, and color.

**`FrameExclusions.qml`** — Creates invisible `PanelWindow` struts on each edge to tell the compositor (via `wlr-layer-shell` exclusive zones) to reserve space for the frame and bar, preventing tiled/overlapping windows from covering shell surfaces.

### Connected Surface Chrome

When `connectedFrameModeActive` is `true`, components change their visual properties:

**Theme.qml:**
```qml
readonly property bool isConnectedEffect: AnimVariants.isConnectedEffect
// true when frameEnabled && frameMode === "connected"

readonly property real connectedCornerRadius: {
    // Returns connectedCornerRadius value (from SettingsData.frameRounding)
}

readonly property color connectedSurfaceColor: {
    // Returns effectiveFrameColor with frameOpacity applied
    // When NOT connected: returns surfaceContainer with popupTransparency
}

readonly property real connectedSurfaceRadius: {
    // When connected: connectedCornerRadius
    // When not: cornerRadius
}

readonly property bool connectedSurfaceBlurEnabled: {
    // When connected: SettingsData.frameBlurEnabled
    // When not: true (global blur setting)
}
```

**DankBarWindow.qml:**
When frame mode is connected:
- `usesFrameBarChrome` enables frame-aware rendering
- `effectiveSpacing` becomes 0 (no gap between bar and frame)
- `effectiveBarThickness` uses `SettingsData.frameBarSize` instead of computed widget height
- Background color uses `effectiveFrameColor` instead of the bar's normal surface container
- `reserveExclusiveWhenAutoHidden` reserves space for the bar even when auto-hidden

**DankPopoutConnected.qml:**
When `usesConnectedSurfaceChrome` is true:
- Popout gap becomes 0 (flush with bar)
- Surface color becomes `Theme.connectedSurfaceColor`
- Surface radius becomes `Theme.connectedSurfaceRadius` (with edge-dependent corner flattening)
- Surface border becomes transparent (no outline between popout and frame)
- Corner radii on the edge adjacent to the bar are flattened to 0 (creating a seamless join)
- Blur radius matches `connectedCornerRadius`

**NotificationPopup.qml:**
When `connectedFrameMode` is true:
- Blur radius uses `Theme.connectedSurfaceRadius`
- Popup anchors directly to frame edge with no gap
- Shadows are disabled
- Frame-aware Y positioning accounts for cutout insets
- Corner radii are zeroed on the frame-adjacent edge

**Dock:**
When `usesConnectedFrameChrome` is true:
- Surface radius uses `Theme.connectedSurfaceRadius`
- Surface color uses `Theme.connectedSurfaceColor`
- Blur follows `Theme.connectedSurfaceBlurEnabled`
- Shadow overlay visibility adapts to connected mode

### Bar Style Backup/Restore

When Connected Frame Mode is toggled on, DMS saves a snapshot of each bar's current style properties (border, shadow, corner radius, etc.) and zeroes them out (setting border to false, removing goth/square corners). When toggled off, the original styles are restored. This ensures a clean visual transition without manually resetting per-bar settings.

```qml
function _connectedFrameBarStyleSnapshot(config) {
    // Captures: borderEnabled, showGothCorners, squareBarEnds, etc.
}

function _zeroOutHostileFieldsForConnectedMode(configs) {
    // Sets: borderEnabled=false, showGothCorners=false, squareBarEnds=false
}

function saveBarStyle(configs) {
    // Backs up current bar styles before entering connected mode
}

function restoreBarStyle(config) {
    // Restores original bar styles when leaving connected mode
}
```

---

## The Frame Module

### Frame Window (`FrameWindow.qml`)

The core visual component. It's a full-screen `PanelWindow` that handles:

**SDF Slots** — The frame uses 8 SDF (Signed Distance Field) slots to render connected surfaces:
- 4 near-edge slots (bar, popouts, notifications, OSD on each edge)
- 4 far-edge slots (counterpart connectors on the opposite edge)

Each slot is defined by a side (`"top"`, `"bottom"`, `"left"`, `"right"`) and a descriptor that specifies position, size, and corner radii.

**Cutout Geometry** — The frame calculates cutout insets for each edge:
```qml
cutoutTopInset    // Space reserved for top bar
cutoutBottomInset // Space reserved for bottom bar/dock
cutoutLeftInset   // Space reserved for left bar
cutoutRightInset  // Space reserved for right bar
```

**Connector Geometry** — Where a surface meets the frame perimeter, connector arcs smooth the transition:
- Near connector: The arc on the side of the frame closest to the surface
- Far connector: The arc on the opposite side (where surface radius transitions to frame radius)
- Uses `SurfaceGeometry.connectorRadii()` to compute the correct radii

**Popout Radii** — Each popout connected to the frame gets computed radii:
- `popoutStartCcr` / `popoutEndCcr`: Inner corner radii
- `popoutFarStartCcr` / `popoutFarEndCcr`: Outer corner radii (where popout meets frame perimeter)

### Frame Border (`FrameBorder.qml`)

A `ShaderEffect` that renders the visual ring. It uses `frame_arc.frag.qsb` — a custom GLSL fragment shader that:
1. Takes the window dimensions and cutout rectangle (as a vector4d)
2. Applies the cutout corner radius
3. Renders the area between the screen edge and the cutout as a solid color
4. Supports per-edge thickness via the cutout geometry

**Shader Properties:**
```qml
ShaderEffect {
    fragmentShader: "frame_arc.frag.qsb"
    property real widthPx       // Window width
    property real heightPx      // Window height
    property real cutoutRadius  // Corner radius of the cutout
    property vector4d cutout    // [left, top, right, bottom] insets
    property vector4d surfaceColor  // RGBA border color
}
```

### Frame Exclusions (`FrameExclusions.qml`)

Creates invisible `PanelWindow` strut windows with `WlrLayershell.exclusionMode: ExclusionMode.Ignore` to reserve compositor space. Separate strut windows exist for each edge (top, bottom, left, right) with the appropriate `exclusiveZone` value:

- Bar edge uses `frameBarSize`
- Non-bar edges use `frameThickness`

This ensures tiling window managers (Hyprland, niri, Sway) don't place windows under the frame area.

---

## Per-Screen Configuration

Connected Frame Mode supports per-screen activation. Use `frameScreenPreferences` to select which monitors show the frame:

```json
{
  "frameScreenPreferences": ["all"]        // Show on all monitors
}
```

```json
{
  "frameScreenPreferences": ["DP-1", "HDMI-A-1"]  // Show on specific monitors
}
```

Per-screen edge detection (`SettingsData.getActiveBarEdgesForScreen()`) determines which edges have bars on each screen, which affects:
- `frameEdgeInsetForSide()` — returns `frameBarSize` for edges with bars, `frameThickness` for edges without
- Cutout geometry in `FrameWindow.qml` — adjusts inset per edge based on bar presence
- Connector rendering — surfaces connect to the frame differently depending on which edge the bar is on

---

## Theme Integration

Connected Frame Mode integrates with the Material Design 3 theming system:

### Color Sources

| Frame Color Setting | Actual Color Used |
|---------------------|-------------------|
| `""` (default) | `Theme.surfaceContainer` |
| `"primary"` | `Theme.primary` |
| `"surface"` | `Theme.surface` |
| Hex color (e.g. `"#2a2a2a"`) | The hex value directly |

The `effectiveFrameColor` computed property resolves the setting to an actual color:

```qml
readonly property color effectiveFrameColor: {
    const fc = frameColor;
    if (!fc || fc === "default") return Theme.surfaceContainer;
    if (fc === "primary") return Theme.primary;
    if (fc === "surface") return Theme.surface;
    return fc;  // hex string
}
```

This color is then modulated by `frameOpacity` (multiplied alpha) when used for surfaces.

### Connected Surface Colors in Theme.qml

```qml
// The unified surface color for all connected panels
readonly property color connectedSurfaceColor:
    isConnectedEffect
        ? Qt.rgba(
            SettingsData.effectiveFrameColor.r,
            SettingsData.effectiveFrameColor.g,
            SettingsData.effectiveFrameColor.b,
            SettingsData.frameOpacity
          )
        : withAlpha(surfaceContainer, popupTransparency)

// The radius used for connected surfaces (matches frame rounding)
readonly property real connectedSurfaceRadius:
    isConnectedEffect ? connectedCornerRadius : cornerRadius

// Whether blur is enabled for connected surfaces
readonly property bool connectedSurfaceBlurEnabled:
    !isConnectedEffect || SettingsData.frameBlurEnabled
```

### Background Blur

When `frameBlurEnabled` is true and the compositor supports `ext-background-effect-v1`:
- The frame border and connected surfaces render with a frosted-glass blur behind them
- The blur radius matches `Theme.connectedSurfaceRadius` for consistency
- If blur is globally disabled (`SettingsData.blurEnabled` is false), the Frame Blur toggle shows a note that it follows the global blur setting

---

## Connected Popouts & Surfaces

### Popout Positioning

When connected mode is active, popout positioning changes significantly:

**Connected Anchor Points:**
```qml
// Instead of standard popup gap:
readonly property real popupGap: connectedFrameChromeActive ? 0 : rawPopupGap

// Anchor positions:
connectedAnchorX = connected surface position (flush with frame)
connectedAnchorY = connected surface position (flush with frame)
```

**Corner Flattening:**
Corners on the edge adjacent to the bar are flattened to 0 for a seamless join:
```qml
readonly property real surfaceTopLeftRadius:
    usesConnectedSurfaceChrome && (barTop || barLeft) ? 0 : surfaceRadius
readonly property real surfaceTopRightRadius:
    usesConnectedSurfaceChrome && (barTop || barRight) ? 0 : surfaceRadius
readonly property real surfaceBottomLeftRadius:
    usesConnectedSurfaceChrome && (barBottom || barLeft) ? 0 : surfaceRadius
readonly property real surfaceBottomRightRadius:
    usesConnectedSurfaceChrome && (barBottom || barRight) ? 0 : surfaceRadius
```

### Which Components Use Connected Chrome

| Component | Property Check | Effect |
|-----------|---------------|--------|
| **DankBar** | `SettingsData.frameEnabled && usesFrameBarChrome` | Zero spacing, frame color, frame bar size |
| **Popouts** (DankPopoutConnected) | `usesConnectedSurfaceChrome` | Flush positioning, frame color, corner flattening |
| **Notifications** (Popup) | `connectedFrameMode` | Frame radius, no shadows, frame-anchored Y |
| **Notifications** (Card) | `connectedFrameMode` | Frame radius, shadows disabled |
| **Dock** | `usesConnectedFrameChrome` | Frame surface color & radius |
| **OSD** | Through `DankPopoutConnected` | Connected surface chrome |

---

## Niri Overview Integration

On the [niri](https://github.com/YaLTeR/niri) compositor, Connected Frame Mode has additional options:

**`frameShowOnOverview`** — Controls whether the frame and connected surfaces are visible during niri's overview (window picker) mode.

- When `false` (default): Frame hides during overview, giving full screen to the picker
- When `true`: Frame remains visible during overview

This is checked via `CompositorService.isNiri` and the setting is only shown when running on niri.

---

## IPC Command Reference

### Enable/Disable

```bash
# Enable frame
dms ipc call settings set frameEnabled true

# Disable frame
dms ipc call settings set frameEnabled false

# Set connected mode
dms ipc call settings set frameMode connected

# Set separate mode
dms ipc call settings set frameMode separate
```

### Appearance

```bash
# Border thickness (2-100)
dms ipc call settings set frameThickness 16

# Border rounding (0-100)
dms ipc call settings set frameRounding 23

# Bar size in frame mode (24-100)
dms ipc call settings set frameBarSize 40

# Surface opacity (0.0-1.0)
dms ipc call settings set frameOpacity 1.0

# Border color
dms ipc call settings set frameColor "primary"    # theme primary
dms ipc call settings set frameColor "surface"    # theme surface
dms ipc call settings set frameColor "#2a2a2a"    # custom hex
dms ipc call settings set frameColor ""           # default (surfaceContainer)

# Blur
dms ipc call settings set frameBlurEnabled true
```

### Connected Options

```bash
# Launcher emerge side
dms ipc call settings set frameLauncherEmergeSide bottom
dms ipc call settings set frameLauncherEmergeSide top

# Arc extender
dms ipc call settings set frameLauncherArcExtender true

# Close gaps (Expose the Arcs)
# Note: IPC value is opposite of UI toggle
# UI "Expose the Arcs" OFF = frameCloseGaps true
# UI "Expose the Arcs" ON  = frameCloseGaps false
dms ipc call settings set frameCloseGaps true
```

### Niri

```bash
dms ipc call settings set frameShowOnOverview true
```

### Status

```bash
# Check current values
dms ipc call settings get frameEnabled
dms ipc call settings get frameMode
dms ipc call settings get frameThickness
dms ipc call settings get frameRounding
dms ipc call settings get frameColor
dms ipc call settings get frameOpacity
dms ipc call settings get frameBarSize
dms ipc call settings get frameBlurEnabled
dms ipc call settings get frameCloseGaps
dms ipc call settings get frameShowOnOverview
dms ipc call settings get frameLauncherEmergeSide
```

---

## Troubleshooting

### Frame doesn't show after enabling

```bash
# Check if frame is actually enabled
dms ipc call settings get frameEnabled

# Check the mode
dms ipc call settings get frameMode

# Restart the shell
dms restart

# Check logs
journalctl --user -u dms.service -f
```

### Frame shows on wrong monitors

Open Settings → Frame → Display Assignment → select the correct monitors.

Or edit `~/.config/DankMaterialShell/settings.json`:

```json
{
  "frameScreenPreferences": ["DP-1", "HDMI-A-1"]
}
```

### Surfaces still look floating (not connected)

```bash
# Ensure connected mode is active
dms ipc call settings set frameMode connected

# Close gaps
dms ipc call settings set frameCloseGaps true
```

### Frame color not changing

```bash
# Check current color setting
dms ipc call settings get frameColor

# Set explicitly to primary
dms ipc call settings set frameColor "primary"

# Set custom hex
dms ipc call settings set frameColor "#6750A4"

# Reset to default
dms ipc call settings set frameColor ""
```

### Blur not working

```bash
# Check if blur is globally enabled
dms ipc call settings get blurEnabled

# Check frame blur setting
dms ipc call settings get frameBlurEnabled

# Check compositor support
dms features
# Look for "blur" in the features list
```

### Bar looks wrong after toggling frame mode

This is normal — DMS saves and restores bar styles when entering/leaving connected mode. If styles aren't restored correctly:

```bash
# Simply toggle frame off and back on
dms ipc call settings set frameEnabled false
dms ipc call settings set frameEnabled true
```

### Tiling windows overlap the frame area

The `FrameExclusions` struts should prevent this. If windows still overlap:

```bash
# Restart the shell to recreate exclusion zones
dms restart

# On Hyprland, ensure the DMS layer is above windows
# Check your Hyprland config for layer rules
```

### Frame rendering looks glitchy (artifacts, weird arcs)

```bash
# Try reducing the border rounding
dms ipc call settings set frameRounding 16

# Try reducing the border thickness
dms ipc call settings set frameThickness 10

# Disable frame blur
dms ipc call settings set frameBlurEnabled false
```

### Frame doesn't show during Niri overview

```bash
# Enable overview visibility
dms ipc call settings set frameShowOnOverview true
```

### Frame eats too much screen space

Reduce the border thickness or bar size:

```bash
dms ipc call settings set frameThickness 8
dms ipc call settings set frameBarSize 32
```

### Connected mode broke after an update

Settings should persist across updates since they're stored in `~/.config/DankMaterialShell/settings.json`. If something looks wrong:

```bash
# Re-apply connected mode
dms ipc call settings set frameEnabled true
dms ipc call settings set frameMode connected
dms restart
```

---

## Quick Reference Card

```bash
# One-liner to enable fully connected mode
dms ipc call settings set frameEnabled true
dms ipc call settings set frameMode connected
dms ipc call settings set frameCloseGaps true
dms ipc call settings set frameBlurEnabled true
dms restart

# Minimal frame (thin, subtle)
dms ipc call settings set frameThickness 4
dms ipc call settings set frameRounding 8
dms ipc call settings set frameBarSize 28
dms ipc call settings set frameOpacity 0.85

# Bold frame (thick, colorful)
dms ipc call settings set frameThickness 24
dms ipc call settings set frameRounding 32
dms ipc call settings set frameBarSize 48
dms ipc call settings set frameColor "primary"
dms ipc call settings set frameOpacity 1.0

# Transparent/blend-in frame
dms ipc call settings set frameColor "surface"
dms ipc call settings set frameOpacity 0.6
dms ipc call settings set frameBlurEnabled true

# Disable frame entirely
dms ipc call settings set frameEnabled false
dms restart
```
