# Changes — MaterialShell (fork of DankMaterialShell)

Tracks all modifications from upstream [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) for easy conflict resolution when rebasing.

---

## Upstream URL
`https://github.com/AvengeMedia/DankMaterialShell.git`

## Branch Tracking
Rebase this fork on upstream `main`:
```bash
git remote add upstream https://github.com/AvengeMedia/DankMaterialShell.git
git fetch upstream
git rebase upstream/main
# Resolve conflicts using this file as reference
```

---

## Changes

### Install & Branding
| File | Change | Reason |
|------|--------|--------|
| `README.md` | Replaced `curl` auto-install with manual step-by-step build guide | Fork shouldn't point to parent repo's servers |
| `README.md` | Removed all upstream branding (danklinux.com, AvengeMedia links) | Fork identity |
| `GEMINI.md` | Updated install instructions, removed upstream URLs | Fork identity; AI context for agents |
| `core/README.md` | Removed upstream badging | Fork identity |
| `quickshell/PLUGINS/README.md` | Removed upstream badging | Fork identity |

### KDE / Hyprland Integration
| File | Change | Reason |
|------|--------|--------|
| `core/internal/config/embedded/hyprland.lua` | Added `plasma-kwalletd.service`, `kdeconnect-indicator.service`, `dms.service` to startup `exec_cmd` block (both systemd and non-systemd paths) | KDE user needs KWallet+KDE Connect auto-started |
| `core/internal/config/hyprland_lua.go` | Non-systemd transform: same KDE service starts added | Non-systemd path parity |
| `core/internal/config/embedded/hyprland.lua` | **Removed** `plasma-kwalletd.service` from startup block | PAM `pam_kwallet5.so` already handles wallet startup on SDDM login; starting it again spawns a 2nd `kwalletd6` without PAM credentials, causing password prompt |
| `core/internal/config/hyprland_lua.go` | **Removed** `plasma-kwalletd.service` from non-systemd transform | Same reason — wallet daemon must be the PAM-started one to receive login credentials |
| `/etc/pam.d/sddm` | Removed `kwalletd=/usr/bin/ksecretd` override from `pam_kwallet5.so` line | Was starting `ksecretd` instead of `kwalletd6`; `kwalletd6` then took over the D-Bus secret service name without PAM creds, causing password prompt |
| `core/cmd/dms/commands_setup.go` | Removed `promptSystemd()` call and function; hardcoded `useSystemd = false` | Systemd-based DMS startup caused double DMS instances; `dms run` directly from Hyprland `exec_cmd` is the only method now |

### Dynamic Workspaces + GNOME-like Behavior
| File | Change | Reason |
|------|--------|--------|
| `core/internal/config/embedded/hypr-layout.lua` | Added `misc.create_new_workspace = true` | Hyprland auto-creates next workspace |
| `core/internal/config/embedded/hypr-layout.lua` | `hl.config({ workspace = { id = 1, persistent = true } })` + same for id=2 | Keep workspaces 1 & 2 always available |
| `core/internal/config/deployer.go` | Set `overwrite: true` for `layout.lua` and `colors.lua` | Embedded changes take effect on `dms setup` |
| `quickshell/Modules/DankBar/Widgets/WorkspaceSwitcher.qml` | Modified `getHyprlandWorkspaces()` — added `addAvailableWorkspace()` helper | Shows clickable empty next-workspace slot only if highest occupied workspace has windows; matches GNOME dynamic workspace UX |

### Alt+Tab Cross-Workspace Window Cycling
| File | Change | Reason |
|------|--------|--------|
| `core/internal/config/embedded/hypr-binds.lua` | Added `ALT + Tab` → `cycle-window.sh next` and `ALT + SHIFT + Tab` → `cycle-window.sh prev` | Alt+Tab cycles through all windows across all workspaces (like GNOME/KDE) |
| `core/internal/config/embedded/hypr-binds.lua` | Used `$HOME` instead of `~` in `exec_cmd` paths | Tilde not expanded by `sh -c` in Hyprland Lua API |
| `core/internal/config/embedded/hypr-cycle-window.sh` | **New file** — `jq`-based script to list all windows across workspaces, sort by workspace then position, focus next/prev with wraparound | Core cycling logic |
| `core/internal/config/embedded/hypr-cycle-window.sh` | Uses `hl.dsp.focus({window='address:0x...'})` Lua dispatch syntax | Hyprland 0.55+ requires Lua API |
| `core/internal/config/hyprland.go` | Added `//go:embed embedded/hypr-cycle-window.sh` | Embed script into Go binary |
| `core/internal/config/deployer.go` | Added `cycle-window.sh` to deployment configs with `isScript()` permission (0755) | Auto-deploy to `~/.config/hypr/dms/` |

---

## Merge Conflict Tips
- **`README.md`** and **`GEMINI.md`** — always accept upstream install docs, then re-apply manual install section and branding removals
- **`hyprland.lua`** / **`hyprland_lua.go`** — keep our KDE service starts; accept upstream structural changes
- **`hypr-binds.lua`** — keep our Alt+Tab binds and `$HOME` fix; accept new upstream binds
- **`hypr-cycle-window.sh`** — upstream won't have this, always keep ours
- **`hypr-layout.lua`** — keep our `create_new_workspace` and persistent workspaces; accept upstream layout changes
- **`deployer.go`** — keep our `overwrite: true` flags and `cycle-window.sh` deployment; accept upstream new config entries
- **`hyprland.go`** — keep our `go:embed` for `cycle-window.sh`; accept new upstream embeds
- **`WorkspaceSwitcher.qml`** — keep our `addAvailableWorkspace()` helper and modified `getHyprlandWorkspaces()`; accept upstream QML structural changes
- **`CHANGES.md`** — always keep ours (this file)
