# DankMaterialShell

<div align="center">
  <img src="assets/danklogo.svg" alt="DankMaterialShell" width="200">

### A modern desktop shell for Wayland

Built with [Quickshell](https://quickshell.org/) and [Go](https://go.dev/)

[![GitHub License](https://img.shields.io/github/license/AvengeMedia/DankMaterialShell?style=for-the-badge&labelColor=101418&color=b9c8da)](https://github.com/AvengeMedia/DankMaterialShell/blob/master/LICENSE)

</div>

DankMaterialShell is a complete desktop shell for [niri](https://github.com/YaLTeR/niri), [Hyprland](https://hyprland.org/), [MangoWC](https://github.com/DreamMaoMao/mangowc), [Sway](https://swaywm.org), [labwc](https://labwc.github.io/), [Scroll](https://github.com/dawsers/scroll), [Miracle WM](https://github.com/miracle-wm-org/miracle-wm), and other Wayland compositors. It replaces waybar, swaylock, swayidle, mako, fuzzel, polkit, and everything else you'd normally stitch together to make a desktop.

## Repository Structure

This is a monorepo containing both the shell interface and the core backend services:

```
DankMaterialShell/
├── quickshell/         # QML-based shell interface
│   ├── Modules/        # UI components (panels, widgets, overlays)
│   ├── Services/       # System integration (audio, network, bluetooth)
│   ├── Widgets/        # Reusable UI controls
│   └── Common/         # Shared resources and themes
├── core/               # Go backend and CLI
│   ├── cmd/            # dms CLI and dankinstall binaries
│   ├── internal/       # System integration, IPC, distro support
│   └── pkg/            # Shared packages
├── distro/             # Distribution packaging
│   ├── fedora/         # Fedora RPM specs
│   ├── debian/         # Debian packaging
│   └── nix/            # NixOS/home-manager modules
└── flake.nix           # Nix flake for declarative installation
```

## See it in Action

<div align="center">

https://github.com/user-attachments/assets/1200a739-7770-4601-8b85-695ca527819a

</div>

<details><summary><strong>More Screenshots</strong></summary>

<div align="center">

<img src="https://github.com/user-attachments/assets/203a9678-c3b7-4720-bb97-853a511ac5c8" width="600" alt="Desktop" />

<img src="https://github.com/user-attachments/assets/a937cf35-a43b-4558-8c39-5694ff5fcac4" width="600" alt="Dashboard" />

<img src="https://github.com/user-attachments/assets/2da00ea1-8921-4473-a2a9-44a44535a822" width="450" alt="Launcher" />

<img src="https://github.com/user-attachments/assets/732c30de-5f4a-4a2b-a995-c8ab656cecd5" width="600" alt="Control Center" />

</div>

</details>

## Features

**Dynamic Theming**
Wallpaper-based color schemes that automatically theme GTK, Qt, terminals, editors (vscode, vscodium), and more using [matugen](https://github.com/InioX/matugen) and dank16.

**System Monitoring**
Real-time CPU, RAM, GPU metrics and temperatures with [dgop](https://github.com/AvengeMedia/dgop). Process list with search and management.

**Powerful Launcher**
Spotlight-style search for applications, files ([dsearch](https://github.com/AvengeMedia/danksearch)), emojis, running windows, calculator, and commands. Extensible with plugins.

**Control Center**
Unified interface for network, Bluetooth, audio devices, display settings, and night mode.

**Smart Notifications**
Notification center with grouping, rich text support, and keyboard navigation.

**Media Integration**
MPRIS player controls, calendar sync, weather widgets, and clipboard history with image previews.

**Session Management**
Lock screen, idle detection, auto-lock/suspend with separate AC/battery settings, and greeter support.

**Plugin System**
Extend functionality with dynamically-loaded QML plugins.

## Supported Compositors

Works best with [niri](https://github.com/YaLTeR/niri), [Hyprland](https://hyprland.org/), [Sway](https://swaywm.org/), [MangoWC](https://github.com/DreamMaoMao/mangowc), [labwc](https://labwc.github.io/), [Scroll](https://github.com/dawsers/scroll), and [Miracle WM](https://github.com/miracle-wm-org/miracle-wm) with full workspace switching, overview integration, and monitor management. Other Wayland compositors work with reduced features.

## Command Line Interface

Control the shell from the command line or keybinds:

```bash
dms run              # Start the shell
dms ipc call spotlight toggle
dms ipc call audio setvolume 50
dms ipc call wallpaper set /path/to/image.jpg
dms brightness list  # List available displays
dms plugins search   # Browse plugin registry
```

## Manual Installation (Arch Linux)

This guide builds everything from source.

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
# Clone this repository (or use your fork)
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

The `dms.service` is of type `dbus` with bus name `org.freedesktop.Notifications`. It starts automatically when the notification bus name is requested.

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
    XF86MonBrightnessDown { spawn "dms" "ipc" "call" "brightness" "decrement"; }
    XF86MonBrightnessUp { spawn "dms" "ipc" "call" "brightness" "increment"; }

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

## Development

See component-specific documentation:

- **[quickshell/](quickshell/)** - QML shell development, widgets, and modules
- **[core/](core/)** - Go backend, CLI tools, and system integration
- **[distro/](distro/)** - Distribution packaging (Fedora, Debian, NixOS)

### Building from Source

**Core + Dankinstall:**

```bash
cd core
make              # Build dms CLI
make dankinstall  # Build installer
```

**Shell:**

```bash
quickshell -p quickshell/
```

**NixOS:**

```nix
{
  inputs.dms.url = "github:AvengeMedia/DankMaterialShell";

  # Use in home-manager or NixOS configuration
  imports = [ inputs.dms.homeModules.dank-material-shell ];
}
```

## Credits

- [Quickshell](https://quickshell.org/) - Shell framework
- [niri](https://github.com/YaLTeR/niri) - Scrolling window manager
- [Ly-sec](http://github.com/ly-sec) - Wallpaper effects from [Noctalia](https://github.com/noctalia-dev/noctalia-shell)
- [soramanew](https://github.com/soramanew) - [Caelestia](https://github.com/caelestia-dots/shell) inspiration
- [end-4](https://github.com/end-4) - [dots-hyprland](https://github.com/end-4/dots-hyprland) inspiration

## License

MIT License - See [LICENSE](LICENSE) for details.
