# AGENTS.md — MaterialShell (DankMaterialShell Fork)

> **Note:** This file mirrors [`GEMINI.md`](./GEMINI.md). Both are kept in sync.  
> See `GEMINI.md` for the canonical version.

A complete desktop shell for Wayland compositors — replaces waybar, swaylock, swayidle, mako, fuzzel, polkit, and everything else you'd normally stitch together to make a desktop.

**Version:** v1.5-beta "The Wolverine"
**License:** MIT
**Repository:** https://github.com/AvengeMedia/DankMaterialShell

> **Fork:** This repository is a fork of [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell).  
> All modifications are tracked in [`CHANGES.md`](./CHANGES.md).  
> **Agents:** Read `CHANGES.md` before modifying anything and update it after each change.  
> See also [`GEMINI.md`](./GEMINI.md).

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Repository Map](#repository-map)
4. [Technology Stack](#technology-stack)
5. [Supported Compositors](#supported-compositors)
6. [Manual Installation (Arch Linux — Without AUR)](#manual-installation-arch-linux--without-aur)
7. [Greeter / Login Manager Setup](#greeter--login-manager-setup)
8. [Configuration](#configuration)
9. [Theme Customization](#theme-customization)
10. [Plugin Development Guide](#plugin-development-guide)
11. [CLI Reference](#cli-reference)
12. [Development](#development)
13. [Troubleshooting](#troubleshooting)
14. [IPC Communication Model](#ipc-communication-model)

---

## Project Overview

DankMaterialShell is a **complete desktop shell** built as a monorepo with two major components:

| Component | Language | Lines | Purpose |
|-----------|----------|-------|---------|
| **Go Backend** (`core/`) | Go 1.26+ | ~118,000 | System integration, IPC server, CLI tools |
| **QML Frontend** (`quickshell/`) | QML/JS | ~350+ files | UI layer consuming the backend's IPC API |

The architecture follows a **backend-first** model:
- **All system integration** (D-Bus, Wayland protocols, hardware, networking, Bluetooth) lives in the **Go backend**
- **QML services** are thin IPC wrappers that communicate with the Go backend via Unix socket JSON-RPC
- The **QML frontend** provides a reactive Material Design 3 UI through property bindings

This separation provides:
- **Type safety** — Go provides compile-time safety for system APIs
- **Performance** — Go handles expensive operations without blocking the UI
- **Robustness** — Backend crashes don't crash the UI, and vice versa
- **Testability** — Backend can be tested independently of the UI
- **Live reload** — QML files can be hot-reloaded during development

### What It Replaces

| Traditional Component | DMS Replacement |
|---------------------|-----------------|
| waybar | DankBar (customizable widget bar) |
| swaylock | Lock screen with PAM auth |
| swayidle | Idle service (separate AC/battery settings) |
| mako | Notification center + popups |
| fuzzel/rofi | DankLauncherV2 (spotlight-style launcher) |
| polkit-gnome | Polkit authentication agent |
| wofi/bemenu | App launcher + desktop entries |
| cliphist | Clipboard history with images |
| NetworkManager applet | Control Center (WiFi, Bluetooth, audio) |
| systemd-resolved GUI | Network management UI |
| GNOME Control Center | Settings app (~45 tabs) |
| bgswitcher | Wallpaper cycling service |
| greetd greeter | DMS Greeter (login screen) |

---

## Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                    QML Frontend (quickshell/)                      │
│                                                                   │
│  shell.qml (entry point)                                          │
│    ├── DMSShell.qml (orchestration ~1,457 lines)                  │
│    │   ├── WallpaperBackground                                    │
│    │   ├── Lock Screen (PAM auth)                                 │
│    │   ├── DankBar (per-monitor via Variants)                     │
│    │   ├── Dock (app dock + trash)                                │
│    │   ├── Notifications (popup + center)                         │
│    │   ├── ControlCenter (WiFi, BT, audio, display)               │
│    │   ├── DankLauncherV2 (spotlight launcher)                    │
│    │   ├── Settings (~45 tabs)                                    │
│    │   ├── OSD surfaces (volume, brightness, media, caps lock)    │
│    │   ├── Toast notifications                                    │
│    │   ├── Notepad                                                │
│    │   ├── PowerMenu                                              │
│    │   ├── Clipboard history                                      │
│    │   ├── Process list (CPU/RAM/GPU)                             │
│    │   ├── Dashboard popout (media, weather, quick settings)      │
│    │   └── DMSShellIPC (bridges CLI commands to UI components)    │
│    │                                                               │
│    ├── Services/ (thin IPC wrappers, ~62 files)                   │
│    │   ├── AudioService → PipeWire/PulseAudio via IPC             │
│    │   ├── NetworkService → NetworkManager via IPC                │
│    │   ├── BluetoothService → BlueZ via IPC                       │
│    │   ├── DisplayService → brightness (DDC/CI + backlight)       │
│    │   ├── NotificationService → notification daemon              │
│    │   ├── MprisController → media player control                 │
│    │   ├── IdleService → idle detection + lock                    │
│    │   ├── ClipboardService → clipboard history                   │
│    │   ├── BatteryService → power profiles                        │
│    │   ├── DgopService → system metrics (CPU, RAM, GPU, disks)    │
│    │   ├── NiriService → niri workspace integration               │
│    │   ├── HyprlandService → Hyprland workspace integration       │
│    │   ├── PluginService → plugin discovery + lifecycle           │
│    │   ├── WeatherService → weather data                          │
│    │   ├── CalendarService → calendar (Khal backend)              │
│    │   ├── PolkitService → PolicyKit authentication               │
│    │   ├── VpnService → VPN management                            │
│    │   ├── TailscaleService → Tailscale VPN                       │
│    │   ├── CupsService → printer management                       │
│    │   ├── WallpaperCyclingService → wallpaper rotation           │
│    │   ├── CompositorService → compositor detection               │
│    │   ├── PortalService → desktop portals                        │
│    │   └── ~40 more services                                      │
│    │                                                               │
│    ├── Modules/ (UI components, ~125 files)                       │
│    │   ├── DankBar/ → customizable widget bar                     │
│    │   ├── ControlCenter/ → system controls                       │
│    │   ├── Notifications/ → notification UI                       │
│    │   ├── AppDrawer/ → app launcher                              │
│    │   ├── Dock/ → app dock                                       │
│    │   ├── Settings/ → ~45 settings tabs                          │
│    │   ├── Lock/ → lock screen                                    │
│    │   ├── ProcessList/ → system monitor                          │
│    │   ├── WorkspaceOverlays/ → workspace overview                │
│    │   ├── OSD/ → on-screen displays                              │
│    │   ├── Greetd/ → login greeter                                │
│    │   └── more...                                                │
│    │                                                               │
│    ├── Widgets/ (reusable controls, ~60 files)                    │
│    │   ├── DankIcon, DankButton, DankToggle, DankSlider           │
│    │   ├── DankTabBar, DankTextField, DankDropdown, DankListView  │
│    │   ├── DankGridView, DankPopout, DankSeekbar, DankScrollbar   │
│    │   ├── DankRipple, DankSpinner, DankSlideout, DankOSD         │
│    │   ├── StateLayer, StyledRect, StyledText, CachingImage       │
│    │   ├── DankNFIcon, DankSVGIcon, DankIconPicker                │
│    │   └── more...                                                │
│    │                                                               │
│    ├── Modals/ (full-screen overlays, ~95 files)                  │
│    │   ├── DankLauncherV2/ → spotlight launcher (~20 files)       │
│    │   ├── Settings/ → settings modal                             │
│    │   ├── Clipboard/ → clipboard history                         │
│    │   ├── FileBrowser/ → file browser (~15 files)                │
│    │   ├── Greeter/ → first-launch wizard (~9 files)              │
│    │   ├── Common/ → DankModal, ConfirmModal, InputModal          │
│    │   └── standalone: PowerMenu, BluetoothPairing, WifiPassword  │
│    │                   PolkitAuth, Keybinds, ColorPicker, etc.    │
│    │                                                               │
│    └── Common/ (shared resources, ~41 files)                      │
│        ├── Theme.qml → Material Design 3 theme singleton          │
│        ├── SettingsData.qml → user preferences                    │
│        ├── SessionData.qml → session state                        │
│        ├── Paths.qml → XDG path resolution                        │
│        ├── ModalManager.qml → modal stacking                      │
│        ├── OSDManager.qml → OSD surface management                │
│        ├── PopoutManager.qml → popout management                  │
│        ├── I18n.qml → internationalization (18 languages)         │
│        └── more utilities                                         │
│                                                                   │
└──────────────────────┬────────────────────────────────────────────┘
                       │ Unix Socket IPC (JSON-RPC)
                       ▼
┌──────────────────────────────────────────────────────────────────┐
│                    Go Backend (core/)                              │
│                                                                   │
│  cmd/dms/main.go (CLI entry point)                                │
│    │                                                              │
│    ├── server.go (IPC server)                                     │
│    │   ├── Unix socket: /tmp/dms-ipc-<uid>.sock                  │
│    │   ├── JSON-RPC protocol (API version 26)                     │
│    │   └── router.go → 20+ subsystem routes                       │
│    │       ├── network.* → NetworkManager + iwd + systemd-networkd│
│    │       ├── bluetooth.* → BlueZ + pairing agent                │
│    │       ├── brightness.* → DDC/CI + backlight                  │
│    │       ├── loginctl.* → systemd-logind (power, sessions)      │
│    │       ├── wayland.* → gamma control, night mode              │
│    │       ├── clipboard.* → ext-data-control-v1                  │
│    │       ├── plugins.* → plugin registry                        │
│    │       ├── themes.* → theme management                        │
│    │       ├── thememode.* → auto dark/light mode                 │
│    │       ├── freedesktop.* → desktop portals                    │
│    │       ├── cups.* → printer management (IPP)                  │
│    │       ├── tailscale.* → VPN                                  │
│    │       ├── evdev.* → input device monitoring                  │
│    │       ├── dbus.* → generic D-Bus access                      │
│    │       ├── apppicker.* → app picker portal                    │
│    │       ├── browser.* → browser integration                    │
│    │       ├── mime.* → MIME type resolution                      │
│    │       ├── location.* → geolocation                           │
│    │       ├── sysupdate.* → system updates                       │
│    │       ├── matugen.* → theme generation                       │
│    │       ├── wlroutput.* → output management                    │
│    │       └── trayrecovery.* → system tray recovery              │
│    │                                                               │
│    ├── notify/ → notification daemon (org.freedesktop.Notifications)│
│    ├── keybinds/ → compositor keybind parsing                    │
│    ├── matugen/ → dynamic theming integration                    │
│    ├── config/ → config management + compositor config gen        │
│    ├── deps/ → dependency detection                               │
│    ├── distros/ → 6 distro installers (Arch, Fedora, Debian, etc.)│
│    ├── plugins/ → plugin registry                                 │
│    ├── greeter/ → display manager support                         │
│    └── ... (23 internal packages total)                           │
│                                                                   │
│  CLI commands (20+):                                              │
│    dms run | restart | kill | ipc | doctor | brightness           │
│    color | clipboard | screenshot | dpms | keybinds | windowrules │
│    matugen | dank16 | config | features | plugins | update        │
│    greeter | auth | setup | trash | randr | open | download       │
│    system | blur | completion                                     │
│                                                                   │
└──────────────────────┬────────────────────────────────────────────┘
                       │
                       ▼
    System Integration: D-Bus, Wayland Protocols, udev, evdev
```

---

## Repository Map

```
DankMaterialShell/
│
├── assets/                          # Shared root assets
│   ├── danklogo.svg                 # Application logo
│   ├── dms-open.desktop             # Desktop entry for file opener
│   └── systemd/
│       └── dms.service              # Systemd user service definition
│
├── core/                            # Go backend (~118K lines)
│   ├── cmd/
│   │   ├── dms/main.go              # Main CLI entry point
│   │   ├── dms/main_distro.go       # Distro binary variant (build tag)
│   │   ├── dms/commands_root.go     # Root cobra command
│   │   ├── dms/shell.go             # Shell management (run, daemon)
│   │   ├── dms/server_client.go     # IPC client
│   │   ├── dms/commands_*.go        # ~25 command files
│   │   └── dankinstall/main.go      # TUI installer binary
│   ├── internal/                    # 23 packages (system integration)
│   │   ├── server/                  # IPC server (the core)
│   │   │   ├── server.go            # Socket listener, manager init
│   │   │   ├── router.go            # Request routing to sub-managers
│   │   │   ├── models/              # Request/Response types
│   │   │   ├── params/              # Parameter validation
│   │   │   ├── network/             # NetworkManager + iwd + systemd-networkd
│   │   │   ├── bluez/               # Bluetooth (org.bluez)
│   │   │   ├── brightness/          # DDC/CI + backlight
│   │   │   ├── loginctl/            # systemd-logind
│   │   │   ├── wayland/             # Wayland gamma control
│   │   │   ├── clipboard/           # Clipboard IPC methods
│   │   │   ├── plugins/             # Plugin IPC methods
│   │   │   ├── themes/              # Theme registry
│   │   │   ├── thememode/           # Auto dark/light mode
│   │   │   ├── freedesktop/         # Desktop portals
│   │   │   ├── cups/                # Printer management (IPP)
│   │   │   ├── tailscale/           # Tailscale VPN
│   │   │   ├── evdev/               # Input device monitoring
│   │   │   ├── dbus/                # Generic D-Bus access
│   │   │   ├── apppicker/           # Application picker portal
│   │   │   ├── browser/             # Web browser integration
│   │   │   ├── mime/                # MIME type resolution
│   │   │   ├── location/            # Geolocation
│   │   │   ├── sysupdate/           # System update management
│   │   │   ├── matugen_handler.go   # Theme generation
│   │   │   ├── wlroutput/           # Output management protocol
│   │   │   ├── trayrecovery/        # System tray recovery
│   │   │   └── wlcontext/           # Shared Wayland connection
│   │   ├── blur/                    # Blur detection/probe
│   │   ├── clipboard/               # Clipboard history (ext-data-control-v1)
│   │   ├── colorpicker/             # Native Wayland color picker
│   │   ├── config/                  # Config management
│   │   │   ├── dms.go               # Config path resolution
│   │   │   ├── deployer.go          # Config deployment
│   │   │   ├── hyprland.go/lua.go   # Hyprland config generation
│   │   │   ├── niri.go              # Niri config generation
│   │   │   ├── mango.go             # Mango config generation
│   │   │   ├── terminals.go         # Terminal config detection
│   │   │   ├── testpage.go          # Test page generation
│   │   │   └── embedded/            # Embedded default configs
│   │   ├── dank16/                  # Terminal color scheme algorithm
│   │   ├── deps/                    # Dependency detection
│   │   ├── desktop/                 # Desktop entry handling
│   │   ├── distros/                 # 6 distro-specific installers
│   │   ├── errdefs/                 # Error type definitions
│   │   ├── geolocation/             # IP geolocation
│   │   ├── greeter/                 # Display manager greeter support
│   │   ├── headless/                # Headless runner for tests
│   │   ├── keybinds/                # Keybind management
│   │   │   ├── registry.go          # Keybind registry
│   │   │   ├── discovery.go         # Auto-discovery of keybind files
│   │   │   ├── types.go             # Type definitions
│   │   │   └── providers/           # Parsers for compositors
│   │   │       ├── hyprland_parser.go
│   │   │       ├── niri_parser.go
│   │   │       ├── sway_parser.go
│   │   │       ├── mangowc_parser.go
│   │   │       ├── miracle_parser.go
│   │   │       └── jsonfile.go
│   │   ├── log/                     # Structured logging
│   │   ├── luaconfig/               # Lua config evaluation
│   │   ├── matugen/                 # Matugen integration
│   │   ├── mocks/                   # Mock implementations for testing
│   │   ├── notify/                  # Notification daemon (freedesktop)
│   │   ├── pam/                     # PAM authentication
│   │   ├── plugins/                 # Plugin registry and management
│   │   ├── privesc/                 # Privilege escalation
│   │   ├── proto/                   # Wayland protocol bindings
│   │   ├── qmlchecks/               # QML validation checks
│   │   ├── screenshot/              # Screenshot utilities
│   │   ├── themes/                  # Theme system
│   │   ├── trash/                   # Trash management
│   │   ├── tui/                     # TUI utilities (for dankinstall)
│   │   ├── utils/                   # General utilities
│   │   ├── version/                 # Version info
│   │   ├── wayland/                 # Wayland protocol helpers
│   │   └── windowrules/             # Window rules management
│   ├── pkg/                         # Shared packages
│   │   ├── dbusutil/                # D-Bus utilities
│   │   ├── go-wayland/              # Vendored Wayland client library
│   │   ├── ipp/                     # Internet Printing Protocol client
│   │   └── syncmap/                 # Thread-safe map
│   ├── Makefile
│   ├── go.mod / go.sum
│   ├── install.sh
│   ├── build_dankinstall.sh
│   ├── .golangci.yml                # Linter config
│   └── .mockery.yml                 # Mock generation config
│
├── quickshell/                      # QML frontend (~350+ files)
│   ├── shell.qml                    # Main entry point (~36 lines)
│   ├── DMSShell.qml                 # Shell orchestration (~1,457 lines)
│   ├── DMSShellIPC.qml              # CLI→UI IPC bridge (~1,500 lines)
│   ├── DMSGreeter.qml               # Greeter entry point
│   ├── Services/                    # ~62 IPC wrapper singletons
│   ├── Modules/                     # ~125 UI component files
│   ├── Modals/                      # ~95 overlay/modal files
│   ├── Widgets/                     # ~60 reusable controls
│   ├── Common/                      # ~41 shared resources
│   ├── PLUGINS/                     # Example plugins for development
│   ├── Shaders/                     # GLSL shader files
│   ├── matugen/                     # Theme generation templates
│   │   ├── configs/                 # ~20 app config templates
│   │   ├── templates/               # Template files
│   │   └── vsix-build/              # VS Code extension
│   ├── translations/                # 18 languages
│   ├── assets/                      # Fonts, icons, sounds, PAM configs
│   ├── systemd/                     # Sysusers + tmpfiles configs
│   ├── VERSION                      # v1.5-beta
│   ├── CODENAME                     # The Wolverine
│   └── scripts/                     # Formatting, linting helpers
│
├── distro/                          # Distribution packaging
│   ├── arch/                        # AUR packages
│   ├── fedora/                      # RPM specs + COPR
│   ├── debian/                      # Debian packaging
│   ├── ubuntu/                      # Ubuntu PPAs
│   ├── opensuse/                    # OBS packaging
│   ├── nix/                         # NixOS/home-manager modules
│   └── scripts/                     # PPA/COPR/OBS build scripts
│
├── docs/                            # Documentation
│   ├── CUSTOM_THEMES.md             # Custom theme guide
│   ├── Hyprland_Lua_Migration.md    # Hyprland Lua migration
│   ├── IPC.md                       # IPC protocol docs
│   └── theme_*.json                 # 12 example theme files
│
├── scripts/
│   └── format-staged.py             # Stage formatting script
│
├── Makefile                         # Root orchestrator Makefile
├── flake.nix / flake.lock           # Nix flake
├── README.md
├── CHANGELOG.MD
├── CONTRIBUTING.md
└── LICENSE                          # MIT
```

---

## Technology Stack

### Backend

| Technology | Version | Purpose |
|------------|---------|---------|
| Go | 1.26+ | System integration, IPC server, CLI |
| Cobra | v1.10.2 | CLI framework |
| godbus/dbus | v5.2.2 | D-Bus integration |
| go-evdev | latest | Input device monitoring |
| go-udev | latest | udev device detection |
| bbolt | v1.4.3 | Embedded key-value DB |
| charmbracelet/log | v1.0.0 | Structured logging |
| gonetworkmanager | v2.2.0 | NetworkManager D-Bus |
| tailscale.com | v1.96.5 | Tailscale VPN API |
| go-git | v6 | Git operations |
| go-qrcode | v2.2.5 | QR code generation |
| goldmark | v1.8.2 | Markdown rendering |
| chroma | v2.24.1 | Syntax highlighting |
| afero | v1.15.0 | Abstract filesystem |
| go-wayland | vendored | Wayland protocol client |

### Frontend

| Technology | Purpose |
|------------|---------|
| QML (Qt Modeling Language) | UI component definition |
| Quickshell | QML desktop shell framework |
| Qt 6 / QtQuick | UI rendering and controls |
| Material Design 3 | Design system and theming |
| Matugen | Wallpaper-based dynamic theming |
| JavaScript | Logic in QML bindings |

### Wayland Protocols (client-side, implemented in Go)

- `wlr-layer-shell-unstable-v1` — Overlay surfaces
- `wlr-gamma-control-unstable-v1` — Night mode color temperature
- `wlr-screencopy-unstable-v1` — Screenshots and color picker
- `wlr-output-management-unstable-v1` — Display configuration
- `wlr-output-power-management-unstable-v1` — DPMS control
- `ext-data-control-v1` — Clipboard history
- `ext-workspace-v1` — Workspace integration
- `dwl-ipc-unstable-v2` — dwl/MangoWC IPC
- `keyboard-shortcuts-inhibit-unstable-v1` — Shortcut inhibition
- `wp-viewporter` — Fractional scaling support

### D-Bus Interfaces

**Client interfaces (consumed by DMS):**

| Interface | Purpose |
|-----------|---------|
| `org.bluez` | Bluetooth device management |
| `org.freedesktop.NetworkManager` | WiFi, ethernet, connections |
| `net.connman.iwd` | iwd Wi-Fi backend |
| `org.freedesktop.network1` | systemd-networkd |
| `org.freedesktop.login1` | Session control, inhibitors, power |
| `org.freedesktop.Accounts` | User account info |
| `org.freedesktop.portal.Desktop` | Desktop appearance |
| CUPS via IPP | Printer management |

**Server interfaces (implemented by DMS):**

| Interface | Purpose |
|-----------|---------|
| `org.freedesktop.Notifications` | Notification daemon |
| `org.freedesktop.ScreenSaver` | Screensaver inhibition |

---

## Supported Compositors

| Compositor | Status | Features |
|------------|--------|----------|
| **niri** | Best support | Workspace switching, overview, per-output workspaces |
| **Hyprland** | Full support | Workspaces, keybinds, window rules |
| **MangoWC** | Full support | Tags via dwl-ipc-unstable-v2 |
| **Sway** | Full support | i3 IPC, workspaces |
| **labwc** | Full support | Workspaces |
| **Scroll** | Full support | Workspaces |
| **Miracle WM** | Full support | Workspaces |
| Other Wayland compositors | Reduced features | No workspace integration |

Feature detection is automatic via `CompositorService` — the shell adapts to available protocols.

---

## Manual Installation (Arch Linux — Without AUR)

This guide builds everything from source instead of using the AUR package.

### Prerequisites

Ensure your system is up to date:

```bash
sudo pacman -Syu
```

### Step 1: Install Build Dependencies

```bash
sudo pacman -S --needed \
    base-devel \
    git \
    go \
    qt6-base \
    qt6-declarative \
    qt6-shadertools \
    qt6-multimedia \
    qt6-wayland \
    cmake \
    meson \
    ninja \
    pkg-config \
    wayland-protocols \
    wayland \
    libxkbcommon \
    cairo \
    pango \
    fontconfig \
    dbus \
    libinput \
    libdisplay-info \
    hwdata \
    pipewire \
    pulseaudio \
    bluez \
    bluez-utils \
    networkmanager \
    upower \
    polkit \
    pam
```

### Step 2: Install Quickshell

Quickshell is the QML shell framework that DMS runs on. Install it from source:

```bash
# Clone quickshell
git clone https://github.com/Quickshell/Quickshell.git
cd Quickshell

# Build and install
cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
cmake --build build
sudo cmake --install build

# Verify installation
quickshell --version
```

Alternatively, if you prefer a package-based approach without AUR, check if quickshell is in the Arch Linux community/extra repos or install the binary from the GitHub releases page.

### Step 3: Install Additional Runtime Dependencies

```bash
sudo pacman -S --needed \
    qt6-svg \
    qt6-imageformats \
    qt6-tools \
    qt6-translations \
    ttf-font-awesome \
    ttf-nerd-fonts-symbols \
    ttf-inter \
    noto-fonts \
    noto-fonts-emoji \
    matugen-bin \
    dgop-bin \
    cliphist \
    python \
    python-requests \
    python-pillow \
    imagemagick \
    playerctl \
    acpid \
    brightnessctl \
    bc
```

### Step 4: Build the Go Backend

```bash
git clone https://github.com/AvengeMedia/DankMaterialShell.git
cd DankMaterialShell

# Build the dms CLI
cd core
make

# Verify the binary
./bin/dms --help

# Go back to repo root
cd ..
```

### Step 5: Install the Binary

```bash
# Install dms binary
sudo mkdir -p /usr/local/bin
sudo cp core/bin/dms /usr/local/bin/dms

# Verify
dms --help
```

### Step 6: Install the QML Shell Files

```bash
sudo mkdir -p /usr/share/quickshell/dms
sudo cp -r quickshell/* /usr/share/quickshell/dms/
sudo rm -rf /usr/share/quickshell/dms/.git*
sudo rm -rf /usr/share/quickshell/dms/.github
```

### Step 7: Install Shell Completions

```bash
# Generate and install shell completions
sudo mkdir -p /usr/share/bash-completion/completions
sudo mkdir -p /usr/share/zsh/site-functions
sudo mkdir -p /usr/share/fish/vendor_completions.d

dms completion bash | sudo tee /usr/share/bash-completion/completions/dms > /dev/null
dms completion zsh | sudo tee /usr/share/zsh/site-functions/_dms > /dev/null
dms completion fish | sudo tee /usr/share/fish/vendor_completions.d/dms.fish > /dev/null
```

### Step 8: Install Icon and Desktop Entry

```bash
# Icon
sudo mkdir -p /usr/share/icons/hicolor/scalable/apps
sudo cp assets/danklogo.svg /usr/share/icons/hicolor/scalable/apps/danklogo.svg
sudo gtk-update-icon-cache -q /usr/share/icons/hicolor 2>/dev/null || true

# Desktop entry
sudo mkdir -p /usr/share/applications
sudo cp assets/dms-open.desktop /usr/share/applications/dms-open.desktop
sudo update-desktop-database -q /usr/share/applications 2>/dev/null || true
```

### Step 9: Set Up the Systemd User Service

```bash
# Install the service
mkdir -p ~/.config/systemd/user
sed 's|/usr/bin/dms|/usr/local/bin/dms|g' assets/systemd/dms.service > ~/.config/systemd/user/dms.service
chmod 644 ~/.config/systemd/user/dms.service

# Reload and enable
systemctl --user daemon-reload
systemctl --user enable --now dms.service
```

**Note:** The `dms.service` is of type `dbus` with bus name `org.freedesktop.Notifications`. It starts automatically when the notification bus name is requested.

Alternatively, for manual startup without systemd:

```bash
dms run -d  # Daemon mode (background)
dms run     # Foreground mode (for debugging)
```

### Step 10: Configure Your Compositor

#### niri

DMS includes an auto-configurator. Run:

```bash
dms setup binds     # Set up keybinds
dms setup layout    # Set up window layout
dms setup colors    # Set up terminal colors
dms doctor          # Verify setup
```

Or manually, add to your niri config (`~/.config/niri/config.kdl`):

```kdl
// DMS integration
spawn-at-startup "dms" "run"

// Sane keybinds for DMS
binds {
    // Spotlight launcher
    Mod+Space { spawn "dms" "ipc" "call" "spotlight" "toggle"; }
    
    // Control center
    Mod+Comma { spawn "dms" "ipc" "call" "control-center" "toggle"; }
    
    // Screenshot
    Print { spawn "dms" "screenshot" "area"; }
    Shift+Print { spawn "dms" "screenshot" "output"; }
    
    // Brightness
    F13 { spawn "dms" "ipc" "call" "brightness" "increment"; }
    F14 { spawn "dms" "ipc" "call" "brightness" "decrement"; }
    
    // Volume
    XF86AudioRaiseVolume { spawn "dms" "ipc" "call" "audio" "setvolume" "5+"; }
    XF86AudioLowerVolume { spawn "dms" "ipc" "call" "audio" "setvolume" "5-"; }
    XF86AudioMute { spawn "dms" "ipc" "call" "audio" "setmute" "toggle"; }
    
    // Media
    XF86AudioPlay { spawn "dms" "ipc" "call" "mpris" "playpause"; }
    XF86AudioNext { spawn "dms" "ipc" "call" "mpris" "next"; }
    XF86AudioPrev { spawn "dms" "ipc" "call" "mpris" "previous"; }
    
    // Lock
    Mod+Shift+Escape { spawn "dms" "ipc" "call" "lock" "activate"; }
}
```

#### Hyprland

```bash
dms setup binds
dms doctor
```

Or manually in `~/.config/hypr/hyprland.conf`:

```conf
# DMS Integration
exec-once = dms run

# Keybinds
bind = $mod, SPACE, exec, dms ipc call spotlight toggle
bind = $mod, COMMA, exec, dms ipc call control-center toggle
bind = $mod, ESCAPE, exec, dms ipc call lock activate
bind = , Print, exec, dms screenshot area
bind = SHIFT, Print, exec, dms screenshot output
```

### Step 11: Start the Shell

After all steps:

```bash
# Option 1: Using systemd (starts automatically on login)
systemctl --user enable --now dms.service

# Option 2: Manual start
dms run -d

# Option 3: Foreground for debugging
dms run
```

Check if it's running:

```bash
dms ipc call ping
# Should return: {"result": "pong", ...}
```

To restart after changes:

```bash
dms restart
```

---

## Greeter / Login Manager Setup

DMS includes a greeter component that can replace your display manager's greeter using greetd.

### Prerequisites

```bash
sudo pacman -S greetd
```

### Installation

1. **Create a greeter system user:**

```bash
sudo groupadd -r greeter
sudo useradd -r -M -G greeter -s /usr/bin/nologin dms-greeter
```

2. **Set up tmpfiles for greeter:**

```bash
sudo mkdir -p /etc/tmpfiles.d
sudo tee /etc/tmpfiles.d/dms-greeter.conf << 'EOF'
d /run/dms-greeter 0755 greeter greeter -
EOF
```

3. **Install the greeter binary and QML files:**

```bash
# Greeter binary
sudo cp core/bin/dms /usr/local/bin/dms-greeter

# Greeter QML files (already installed if you followed Step 6)
# The greeter uses /usr/share/quickshell/dms/ with DMS_RUN_GREETER=1
```

4. **Create the greeter script:**

```bash
sudo tee /usr/local/bin/dms-greeter << 'SCRIPT'
#!/bin/sh
DMS_RUN_GREETER=1 /usr/bin/quickshell -p /usr/share/quickshell/dms/shell.qml
SCRIPT
sudo chmod +x /usr/local/bin/dms-greeter
```

5. **Configure greetd:**

Edit `/etc/greetd/config.toml`:

```toml
[terminal]
vt = 1

[default_session]
command = "/usr/local/bin/dms-greeter"
user = "dms-greeter"
```

6. **Enable greetd:**

```bash
sudo systemctl enable --now greetd
```

### Permissions

The greeter user needs access to certain files:

```bash
# Allow greeter to read configs
sudo chgrp -R greeter ~/.config/DankMaterialShell
sudo chmod -R g+rX ~/.config/DankMaterialShell

# Allow greeter to read cached assets
sudo chgrp -R greeter ~/.cache/DankMaterialShell
sudo chmod -R g+rX ~/.cache/DankMaterialShell

# Allow greeter to read quickshell cache
sudo chgrp -R greeter ~/.cache/quickshell
sudo chmod -R g+rX ~/.cache/quickshell
```

---

## Configuration

All configuration files live under `~/.config/DankMaterialShell/`.

### Core Configuration File

`~/.config/DankMaterialShell/settings.json` — Main settings file. Key sections:

```json
{
  "theme": {
    "mode": "auto",
    "customTheme": null,
    "wallpaperProcessing": "matugen"
  },
  "bar": {
    "widgets": ["clock", "workspaces", "system-tray", "media"],
    "position": "top",
    "height": 36
  },
  "dock": {
    "enabled": true,
    "position": "bottom",
    "iconSize": 48
  },
  "launcher": {
    "maxResults": 8,
    "showWindows": true,
    "showEmojis": true
  },
  "idle": {
    "lockAfterSec": 300,
    "dimAfterSec": 270,
    "suspendAfterSec": 600
  },
  "notifications": {
    "doNotDisturb": false,
    "showPopups": true
  }
}
```

### Paths

| Path | Purpose |
|------|---------|
| `~/.config/DankMaterialShell/` | Configuration files |
| `~/.config/DankMaterialShell/settings.json` | User settings |
| `~/.config/DankMaterialShell/plugins/` | External plugins |
| `~/.local/share/DankMaterialShell/` | Data files |
| `~/.local/state/DankMaterialShell/` | Runtime state |
| `~/.cache/DankMaterialShell/` | Cache (themes, images) |
| `~/.cache/DankMaterialShell/imagecache/` | Image cache |

### CLI Configuration

```bash
# Get a setting
dms config get theme.mode

# Set a setting
dms config set bar.position bottom

# List all settings
dms config list

# Reload configuration
dms ipc call config reload
```

### First-Run Doctor

After installation, run the diagnostics tool:

```bash
dms doctor
```

This checks for:
- Required system tools
- Proper permissions
- Compositor compatibility
- Available Wayland protocols
- Dependency versions

---

## Theme Customization

DMS uses **Material Design 3** with dynamic wallpaper-based color schemes via [matugen](https://github.com/InioX/matugen).

### How Theming Works

1. Wallpaper image → matugen (Material You color extraction)
2. matugen generates a Material Design 3 color scheme
3. DMS applies the colors to the Theme singleton
4. All QML components reference `Theme.propertyName`
5. Theme templates generate configs for external apps

### Built-in Theme Colors

The `Theme.qml` singleton provides these color categories:

```qml
// Surfaces
Theme.surface            // Primary surface background
Theme.surfaceDim         // Dimmed surface
Theme.surfaceBright      // Bright surface
Theme.container          // Elevated container background
Theme.surfaceContainer   // Container variant

// Primary palette
Theme.primary            // Primary color
Theme.onPrimary          // Text on primary
Theme.primaryContainer   // Primary container
Theme.onPrimaryContainer // Text on primary container

// Secondary palette
Theme.secondary          // Secondary color
Theme.onSecondary        // Text on secondary
Theme.secondaryContainer
Theme.onSecondaryContainer

// Tertiary palette
Theme.tertiary           // Accent color
Theme.onTertiary
Theme.tertiaryContainer
Theme.onTertiaryContainer

// Error
Theme.error              // Error color
Theme.onError
Theme.errorContainer
Theme.onErrorContainer

// Utility
Theme.outline            // Borders and dividers
Theme.outlineVariant     // Subtle borders
Theme.shadow             // Shadow color
Theme.scrim              // Scrim/overlay

// Spacing
Theme.spacing            // Base spacing unit (4px)
Theme.padding            // Standard padding
Theme.radius             // Border radius
Theme.radiusFull         // Fully rounded

// Typography
Theme.font               // Base font family
Theme.monoFont           // Monospace font family
```

### Applying Themes

**Set a wallpaper (auto-generates theme):**

```bash
dms ipc call wallpaper set /path/to/image.jpg
```

**Reload theme from current wallpaper:**

```bash
dms ipc call matugen queue
```

**Check matugen status:**

```bash
dms ipc call matugen status
```

**Custom theme file:**

Create `~/.config/DankMaterialShell/theme.json`:

```json
{
  "primary": "#6750A4",
  "secondary": "#625B71",
  "tertiary": "#7D5260",
  "error": "#B3261E",
  "surface": "#FFFBFE",
  "outline": "#79747E"
}
```

Set `settings.json`: `"customTheme": "theme.json"` to use it.

### Pre-built Theme Examples

The `docs/` directory includes 12 example themes:

- `theme_nord.json` — Nord color scheme
- `theme_tokyonight.json` — Tokyo Night
- `theme_rose-pine.json` — Rosé Pine
- `theme_everforest.json` — Everforest
- `theme_gruvbox_material_*.json` — Gruvbox Material (hard/medium/soft)
- `theme_cyberpunk_electric.json` — Cyberpunk Electric
- `theme_synthwave_electric.json` — Synthwave Electric
- `theme_miami_vice.json` — Miami Vice
- `theme_hotline_miami.json` — Hotline Miami

### Application Theme Templates

DMS can theme external applications via matugen templates. Configs live in `quickshell/matugen/configs/`:

| Application | Config File |
|-------------|-------------|
| Alacritty | `alacritty.toml` |
| Kitty | `kitty.toml` |
| Ghostty | `ghostty.toml` |
| Foot | `foot.toml` |
| WezTerm | `wezterm.toml` |
| Neovim | `neovim.toml` |
| VS Code / VSCodium | `vscode.toml` |
| Firefox | `firefox.toml` |
| Zen Browser | `zenbrowser.toml` |
| GTK 3/4 | `gtk3.toml` |
| Qt5 / Qt6 | `qt5ct.toml`, `qt6ct.toml` |
| Hyprland | `hyprland.toml` |
| niri | `niri.toml` |
| MangoWC | `mangowc.toml` |
| Emacs | `emacs.toml` |
| Zed | `zed.toml` |
| Vesktop / Vencord | `vesktop.toml`, `vencord.toml` |
| pywalfox | `pywalfox.toml` |
| dgop | `dgop.toml` |
| bash/zsh | `base.toml` |

Regenerate all app themes:

```bash
dms matugen generate
```

### Custom Theme Files

For detailed information, see `docs/CUSTOM_THEMES.md`.

---

## Plugin Development Guide

DMS supports **four plugin types**:

| Type | Description |
|------|-------------|
| `widget` | UI components in DankBar + Control Center |
| `daemon` | Background processes (no UI) |
| `launcher` | Spotlight search providers |
| `desktop` | Draggable desktop widgets |

### Plugin Directory Structure

Plugins live in `~/.config/DankMaterialShell/plugins/<PluginId>/`.

```
~/.config/DankMaterialShell/
├── settings.json                    # Core settings + plugin data
│   └── pluginSettings: {            # Plugin settings (namespaced)
│       └── <PluginId>: {
│           ├── enabled: true,
│           └── customKey: "value"
│       }
│   }
└── plugins/
    └── <PluginId>/                  # Must match manifest ID
        ├── plugin.json              # Plugin manifest (required)
        ├── Widget.qml               # Widget component (for widget type)
        ├── Settings.qml             # Settings UI (optional)
        └── assets/                  # Plugin-specific assets
```

### Plugin Manifest (`plugin.json`)

```json
{
  "id": "myPlugin",
  "name": "My Plugin",
  "description": "A useful widget",
  "version": "1.0.0",
  "author": "Your Name",
  "icon": "extension",
  "type": "widget",
  "component": "./Widget.qml",
  "settings": "./Settings.qml",
  "permissions": ["settings_read", "settings_write"]
}
```

**Fields:**

| Field | Required | Description |
|-------|----------|-------------|
| `id` | Yes | Unique identifier (matches directory name) |
| `name` | Yes | Display name |
| `description` | Yes | Short description |
| `version` | Yes | Semver |
| `author` | No | Author name |
| `icon` | Yes | Material Design icon name |
| `type` | Yes | `widget`, `daemon`, `launcher`, `desktop` |
| `component` | Yes | Path to main QML component |
| `settings` | No | Path to settings QML component |
| `permissions` | Yes | Array of required permissions |

**Available permissions:**

- `settings_read` — Read plugin settings
- `settings_write` — Read and write plugin settings
- `clipboard_read` — Access clipboard data
- `clipboard_write` — Modify clipboard
- `notification` — Send notifications
- `exec` — Execute shell commands

### Widget Plugin Example

**Widget.qml:**
```qml
import QtQuick
import qs.Services

Rectangle {
    id: root

    // Injected by PluginService
    property bool compactMode: false
    property string section: "center"
    property real widgetHeight: 30
    property var pluginService: null

    width: content.implicitWidth + 16
    height: widgetHeight
    radius: 8
    color: "#20FFFFFF"

    Text {
        id: content
        anchors.centerIn: parent
        text: "My Plugin"
        color: "white"
        font.pixelSize: 12
    }

    Component.onCompleted: {
        if (pluginService) {
            var savedValue = pluginService.loadPluginData(
                "myPlugin", "myKey", "default"
            )
        }
    }
}
```

**Settings.qml:**
```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

FocusScope {
    id: root

    property var pluginService: null

    implicitHeight: settingsColumn.implicitHeight

    ColumnLayout {
        id: settingsColumn
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Text {
            text: "My Plugin Settings"
            font.pixelSize: 18
            font.weight: Font.Bold
        }

        Button {
            text: "Save"
            onClicked: saveSettings("key", "value")
        }
    }

    function saveSettings(key, value) {
        if (pluginService)
            pluginService.savePluginData("myPlugin", key, value)
    }

    function loadSettings(key, defaultValue) {
        if (pluginService)
            return pluginService.loadPluginData("myPlugin", key, defaultValue)
        return defaultValue
    }
}
```

### Daemon Plugin Example

**Daemon.qml:**
```qml
import QtQuick
import qs.Common
import qs.Services

Item {
    id: root

    property var pluginService: null

    Connections {
        target: SessionData
        function onWallpaperPathChanged() {
            console.log("Wallpaper changed:", SessionData.wallpaperPath)
            if (pluginService) {
                pluginService.savePluginData(
                    "myDaemon", "lastEvent", Date.now()
                )
            }
        }
    }

    Component.onCompleted: {
        console.log("Daemon started")
    }
}
```

### Enabling a Plugin

```bash
# Method 1: Via settings UI
# Settings → Plugins → Scan for Plugins → Toggle to enable

# Method 2: Via CLI
dms ipc call plugins enable myPlugin

# Method 3: Manual (edit settings.json)
# Set pluginSettings.myPlugin.enabled = true
```

### Plugin API Reference

**PluginService (injected as `pluginService`):**

| Method | Description |
|--------|-------------|
| `loadPluginData(pluginId, key, default)` | Load persistent data |
| `savePluginData(pluginId, key, value)` | Save persistent data |
| `enablePlugin(pluginId)` | Load a plugin |
| `disablePlugin(pluginId)` | Unload a plugin |

**Available global properties in plugin QML:**

| Property | Source | Description |
|----------|--------|-------------|
| `Theme` | `qs.Common` | Theme singleton |
| `SettingsData` | `qs.Common` | Settings singleton |
| `SessionData` | `qs.Common` | Session data |
| `Paths` | `qs.Common` | Path utilities |
| `I18n` | `qs.Common` | Internationalization |
| `Anims` | `qs.Common` | Animation definitions |
| All Services | `qs.Services` | Audio, Network, etc. |

### Example Plugins

See `quickshell/PLUGINS/` for working examples:

| Plugin | Type | What It Shows |
|--------|------|---------------|
| `ExampleDesktopClock` | Widget | Clock in DankBar |
| `ExampleEmojiPlugin` | Widget | Emoji display widget |
| `ExampleWithVariants` | Widget | Per-monitor variants |
| `ExampleCompositePlugin` | Widget | Multi-surface plugin |
| `ControlCenterExample` | Widget | Control center integration |
| `LauncherExample` | Launcher | Search provider |
| `QuickNotesExample` | Widget | Simple note-taking |
| `ColorDemoPlugin` | Widget | Color theme display |
| `WallpaperWatcherDaemon` | Daemon | Background monitoring |
| `PopoutControlExample` | Widget | Popout window example |

---

## CLI Reference

The `dms` CLI provides 20+ commands for managing the shell:

### Shell Lifecycle

| Command | Purpose |
|---------|---------|
| `dms run` | Start the shell (foreground) |
| `dms run -d` | Start the shell (daemon/background mode) |
| `dms run --session` | Run in session mode (used by systemd) |
| `dms restart` | Restart the shell process |
| `dms kill` | Stop the shell process |

### IPC Commands

| Command | Purpose |
|---------|---------|
| `dms ipc call <method> [args]` | Send IPC command to running shell |
| `dms ipc call spotlight toggle` | Toggle spotlight launcher |
| `dms ipc call control-center toggle` | Toggle control center |
| `dms ipc call lock activate` | Lock the screen |
| `dms ipc call powermenu show` | Show power menu |
| `dms ipc call audio setvolume 50` | Set volume |
| `dms ipc call notification send` | Send a notification |
| `dms ipc call wallpaper set /path/img` | Set wallpaper |
| `dms ipc call ping` | Test IPC connection |
| `dms ipc call matugen queue` | Regenerate theme from wallpaper |

### System Commands

| Command | Purpose |
|---------|---------|
| `dms brightness list` | List displays with brightness support |
| `dms brightness set 50` | Set brightness level |
| `dms color pick` | Open native color picker |
| `dms color pick --rgb` | Get color as RGB |
| `dms color pick --hsv` | Get color as HSV |
| `dms screenshot area` | Interactive area screenshot |
| `dms screenshot output` | Screenshot current output |
| `dms dpms on` / `dms dpms off` | Display power management |
| `dms clipboard list` | Show clipboard history |
| `dms clipboard clear` | Clear clipboard history |
| `dms trash list` | List trash contents |
| `dms trash empty` | Empty trash |
| `dms blur probe` | Detect blur capabilities |

### Configuration Commands

| Command | Purpose |
|---------|---------|
| `dms config get <key>` | Get a setting value |
| `dms config set <key> <value>` | Set a setting value |
| `dms config list` | List all settings |
| `dms doctor` | Run system diagnostics |
| `dms features` | Show available features |
| `dms matugen generate` | Generate theme from wallpaper |
| `dms matugen reload` | Reload theme |

### Compositor Setup

| Command | Purpose |
|---------|---------|
| `dms setup binds` | Set up compositor keybinds |
| `dms setup layout` | Set up window layout rules |
| `dms setup colors` | Set up terminal colors |
| `dms windowrules add <rule>` | Add a window rule |
| `dms windowrules remove <id>` | Remove a window rule |
| `dms windowrules list` | List window rules |
| `dms keybinds list` | List available keybinds |
| `dms keybinds reload` | Reload keybinds |

### Plugin Management

| Command | Purpose |
|---------|---------|
| `dms plugins browse` | Browse plugin registry |
| `dms plugins install <id>` | Install a plugin |
| `dms greeter install` | Install greeter files |
| `dms greeter enable` | Enable greeter |

### Utilities

| Command | Purpose |
|---------|---------|
| `dms open <app>` | Open an application |
| `dms download <url>` | Download a file |
| `dms system info` | Show system information |
| `dms system log` | Show DMS logs |
| `dms update check` | Check for updates |
| `dms auth sync` | Sync authentication config |
| `dms completion bash / zsh / fish` | Generate shell completions |
| `dms version` | Show version |

---

## Development

### Running from Source (Hot Reload)

The QML frontend supports hot-reload during development:

```bash
# Start the Go backend first
cd core && make
./bin/dms run &

# Run the QML shell with hot reload
cd quickshell
quickshell -p shell.qml    # File watching enabled by default
# Or shorthand:
qs -p .

# Verbose debugging:
qs -v -p shell.qml
```

Changes to QML files trigger automatic reloads. Disable with:

```bash
DMS_DISABLE_HOT_RELOAD=1 quickshell -p shell.qml
```

### Go Backend Development

```bash
cd core

# Build with debug info (no stripping)
make dev

# Run tests
make test

# Format code
make fmt

# Run linter
golangci-lint run

# Update dependencies
make deps

# Build the installer
make dankinstall
```

**IPC testing during development:**

```bash
# Test backend independently of UI
./bin/dms run &
./bin/dms ipc call ping
./bin/dms ipc call audio getvolume
./bin/dms ipc call spotlight toggle
./bin/dms features
```

### QML Frontend Development

```bash
cd quickshell

# Format all QML files
./qmlformat-all.sh

# Lint QML (after qs -p . generates .qmlls.ini)
make -C .. lint-qml

# Individual file format:
qmlfmt -t 4 -i 4 -b 250 -w path/to/file.qml
```

**Important:** Do NOT use Qt's `qmlformat` — use `qmlfmt` instead (available in the Nix dev shell or from GitHub).

### Nix Development Shell

If you have Nix with flakes:

```bash
nix develop
```

This provides:
- Go 1.26+ toolchain (go, gopls, delve, go-tools)
- GNU Make
- Quickshell and required QML packages
- Properly configured `QML2_IMPORT_PATH`
- Auto-generated `.qmlls.ini` in `quickshell/`

### VSCode Setup

**QML (quickshell directory):**

```json
{
  "[qml]": {
    "editor.defaultFormatter": "qt-project.qmlls",
    "editor.formatOnSave": true
  },
  "qt-qml.doNotAskForQmllsDownload": true,
  "qt-qml.qmlls.customExePath": "/usr/lib/qt6/bin/qmlls",
  "qt-core.additionalQtPaths": [
    {
      "name": "Qt-6.x-linux-g++",
      "path": "/usr/bin/qmake"
    }
  ]
}
```

**Go (core directory):**

Install the Go extension. Format with `make fmt`.

### Code Conventions

**QML:**
- 4-space indentation
- `id` as the first property
- Properties before signal handlers before child components
- Prefer property bindings over imperative code
- No comments unless absolutely essential
- Null-safe: `object?.property`
- Modular: Services → Modules → Widgets separation

**Import order:**
```qml
import QtQuick
import QtQuick.Controls  // If needed
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Widgets
```

**Service pattern (singleton):**
```qml
pragma Singleton
pragma ComponentBehavior: Bound

Singleton {
    id: root
    property bool featureAvailable: false
    function performAction(param) { /* IPC call */ }
}
```

**Go:**
- Standard Go conventions (`gofmt`)
- Wrap errors: `fmt.Errorf("context: %w", err)`
- Use `internal/log` for logging: `log.Debug()`, `log.Info()`, `log.Error()`
- Table-driven tests with `testing` package
- Use mocks from `internal/mocks/`

**IPC handler pattern:**
```go
type Manager struct { /* state */ }

func NewManager() (*Manager, error) { /* init */ }
func (m *Manager) HandleRequest(req models.Request) models.Response {
    switch req.Method {
    case "list": return m.handleList(req)
    default: return models.ErrorResponse(req.ID, "unknown method")
    }
}
```

---

## Troubleshooting

### IPC Connection Issues

**Shell doesn't start or IPC fails:**

```bash
# Check if socket exists
ls -la /tmp/dms-ipc-$(id -u).sock

# Test IPC connection
dms ipc call ping

# Check logs (systemd)
journalctl --user -u dms.service -f

# Check logs (manual run)
dms run  # Run in foreground to see output
```

**Socket not found:**

1. Ensure the backend is running: `ps aux | grep dms`
2. Restart the service: `systemctl --user restart dms.service`
3. Check for permission issues on `/tmp`

### QML Frontend Issues

**Shell appears but components are broken:**

```bash
# Run with verbose output
qs -v -p /usr/share/quickshell/dms/shell.qml

# Check QML import paths
echo $QML2_IMPORT_PATH

# Verify quickshell installation
quickshell --version
which quickshell
```

**Common QML errors:**

| Error | Likely Cause | Fix |
|-------|-------------|-----|
| "module not found" | Missing QML module | Install `qt6-declarative` or check `QML2_IMPORT_PATH` |
| "file not found" | Incorrect path | Check shell file locations |
| "TypeError" | Property binding issue | Check for undefined properties |
| "Connection refused" | Backend not running | Start `dms run` first |

### Go Backend Issues

**Build failures:**

```bash
# Update Go (must be 1.22+)
go version

# Clean build
cd core && make clean && make

# Download dependencies
go mod download

# Check Go version against go.mod
# DMS requires Go 1.26+
```

**Runtime failures:**

```bash
# Feature check
dms features

# Doctor (system diagnostics)
dms doctor

# Check compositor support
echo $XDG_SESSION_TYPE  # Should be "wayland"

# Test D-Bus services
busctl --user list | grep -E "org.bluez|org.freedesktop.NetworkManager"
```

### Wayland / Compositor Issues

**Shell doesn't show up:**

1. Ensure you're running a Wayland session (not X11)
2. Check compositor compatibility
3. The shell uses `wlr-layer-shell` protocol — not all compositors support it
4. Some compositors need `dms run` in their startup config

**Workspace switching doesn't work:**

```bash
dms features  # Shows available compositor protocols
```
Each compositor uses different protocols:
- niri: ext-workspace-v1
- Hyprland: hyprland-ipc
- Sway: i3 IPC
- MangoWC: dwl-ipc-unstable-v2

### Permission Issues

```bash
# User must be in these groups
groups $(whoami)
# Should include: video, input, audio, network

# Add if missing
sudo usermod -aG video,input,audio $USER
```

### Debug Mode

```bash
# Full Wayland protocol debug
WAYLAND_DEBUG=1 dms run

# D-Bus monitoring
busctl --user monitor

# IPC traffic logging
dms run --verbose

# Check specific subsystem
dms ipc call network list-devices
dms ipc call bluetooth list-adapters
dms ipc call audio list-sinks
```

### Performance Issues

```bash
# Check CPU/memory usage
dms system info

# Disable animated wallpapers
dms config set wallpaperProcessing none

# Reduce bar widgets
dms config set bar.widgets '["clock","workspaces"]'
```

### Common Problems

**"matugen not found":**

```bash
# Install matugen (without AUR, build from source)
git clone https://github.com/InioX/matugen.git
cd matugen
cargo build --release
sudo cp target/release/matugen /usr/local/bin/
```

**"dgop not found" (system metrics):**

This is optional — system monitoring will be disabled but the shell still works.

**Bluetooth not working:**

```bash
sudo systemctl enable --now bluetooth.service
sudo usermod -aG lp $USER  # Add to lp group for bluetooth
```

**Audio controls not working:**

```bash
# Ensure PipeWire is running
systemctl --user enable --now pipewire pipewire-pulse
pactl info  # Should show "Server Name: PulseAudio (on PipeWire)"
```

**Notifications not appearing:**

```bash
# The DMS notification daemon registers as
# org.freedesktop.Notifications on D-Bus
busctl --user status org.freedesktop.Notifications
# Should show DMS's PID

# Test notification
dms notify send "Test" "This is a test notification"
```

---

## IPC Communication Model

### Protocol

- **Transport:** Unix socket at `/tmp/dms-ipc-<uid>.sock`
- **Protocol:** JSON-RPC over a custom TCP-like framing
- **API Version:** 26 (from `APIVersion` constant)

### Request Format

```json
{
  "id": "req-001",
  "method": "network.connect",
  "params": {
    "ssid": "MyWiFi",
    "password": "secret"
  }
}
```

### Response Format

```json
{
  "id": "req-001",
  "result": {
    "success": true,
    "data": {}
  },
  "error": null
}
```

### Subscription Model

The IPC server supports event subscriptions. The QML frontend subscribes to state changes and receives streaming updates:

```json
// Subscribe request
{ "id": "sub-001", "method": "subscribe", "params": { "events": ["audio.*", "network.*", "bluetooth.*"] } }

// Streaming event
{ "event": "audio.volumeChanged", "data": { "sink": "alsa_output.pci-0000_00_1f.3.analog-stereo", "volume": 0.75 } }
```

### Subsystem Routing

Requests are routed by method prefix in `internal/server/router.go`:

| Prefix | Handler | Features |
|--------|---------|----------|
| `network.*` | `network.Manager` | WiFi scan, connect, disconnect, list, status |
| `bluetooth.*` | `bluez.Manager` | Scan, pair, connect, trust, list |
| `audio.*` | `audio.Manager` | List sinks/sources, volume, mute, default |
| `brightness.*` | `brightness.Manager` | List, set, increment, decrement |
| `loginctl.*` | `loginctl.Manager` | Lock, suspend, hibernate, shutdown, reboot |
| `wayland.*` | `wayland.Manager` | Gamma control, night mode |
| `clipboard.*` | `clipboard.Manager` | List, clear, copy |
| `themes.*` | `themes.Manager` | List, get, set theme |
| `plugins.*` | `plugins.Manager` | Enable, disable, list, install |
| `tailscale.*` | `tailscale.Manager` | Status, up, down |
| `cups.*` | `cups.Manager` | List printers, print test page |
| `evdev.*` | `evdev.Manager` | List input devices, monitor |
| `dbus.*` | `dbus.Manager` | Generic D-Bus method calls |
| `apppicker.*` | `apppicker.Manager` | Application search and launch |
| `mime.*` | `mime.Handler` | MIME type resolution |
| `location.*` | `location.Manager` | Geolocation |
| `sysupdate.*` | `sysupdate.Manager` | Check, update system |
| `wlroutput.*` | `wlroutput.Manager` | Output configuration |
| `freedesktop.*` | `freedesktop.Manager` | Desktop portals |
| `matugen.queue` | Direct | Queue theme generation |
| `matugen.status` | Direct | Check matugen status |
| `ping` | Direct | Health check |
| `getServerInfo` | Direct | Server capabilities |

### QML IPC Wrapper Pattern

Each QML service in `quickshell/Services/` wraps IPC calls using `Quickshell.Io.Process` or a dedicated IPC socket connection:

```qml
// Services/AudioService.qml (simplified)
import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton
pragma ComponentBehavior: Bound

Singleton {
    id: root

    property real volume: 0
    property bool muted: false

    function setVolume(vol) {
        Process.exec("dms", ["ipc", "call", "audio", "setvolume", String(vol)])
    }

    function getStatus() {
        Process.exec("dms", ["ipc", "call", "audio", "getstatus"])
    }

    // ... property bindings update reactively via IPC subscription events
}
```

### Event Flow Example

```
User clicks WiFi network in UI
  ↓
QML NetworkService.connectNetwork("HomeWiFi", "password")
  ↓
IPC Request: {"method": "network.connect", "params": {"ssid": "HomeWiFi", "password": "password"}}
  ↓ (over Unix socket)
Go Backend: internal/server/network/ handles D-Bus to NetworkManager
  ↓ (D-Bus)
org.freedesktop.NetworkManager connects to the network
  ↓ (D-Bus signal)
NetworkManager emits AccessPoint::PropertiesChanged
  ↓
Go Backend detects state change via D-Bus signal handler
  ↓
IPC Event: {"event": "network.connectionChanged", "data": {"ssid": "HomeWiFi", "state": "activated"}}
  ↓ (over Unix socket)
QML NetworkService receives event, updates properties
  ↓ (property binding)
UI updates reactively — WiFi icon shows connected state
```

---

## Quick Reference

### File Locations

| Item | Path |
|------|------|
| DMS binary | `/usr/local/bin/dms` |
| QML shell | `/usr/share/quickshell/dms/` |
| User config | `~/.config/DankMaterialShell/` |
| User settings | `~/.config/DankMaterialShell/settings.json` |
| Plugins | `~/.config/DankMaterialShell/plugins/` |
| Cache | `~/.cache/DankMaterialShell/` |
| State | `~/.local/state/DankMaterialShell/` |
| Systemd service | `~/.config/systemd/user/dms.service` |
| IPC socket | `/tmp/dms-ipc-$(id -u).sock` |

### Essential Commands

```bash
# Start / stop
dms run [-d]
systemctl --user start dms.service

# Restart
dms restart

# Test
dms ipc call ping

# Diagnose
dms doctor

# Reload theme
dms ipc call matugen queue

# Toggle launcher
dms ipc call spotlight toggle

# Lock screen
dms ipc call lock activate

# Screenshot
dms screenshot area
```

### Quick Install Recap

```bash
# 1. Install system deps
sudo pacman -S go qt6-base qt6-declarative base-devel git

# 2. Build & install Quickshell
git clone https://github.com/Quickshell/Quickshell.git
cd Quickshell
cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
cmake --build build
sudo cmake --install build
cd ..

# 3. Clone & build DMS
git clone https://github.com/AvengeMedia/DankMaterialShell.git
cd DankMaterialShell
make
sudo make install

# 4. Enable & start
systemctl --user enable --now dms.service

# 5. Verify
dms ipc call ping
```
