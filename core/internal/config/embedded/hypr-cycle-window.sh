#!/bin/bash
# hypr-cycle-window.sh — Focus next/prev window across all workspaces
# Usage: hypr-cycle-window.sh next|prev

DIRECTION="${1:-next}"

WINDOWS=$(hyprctl clients -j | jq -r '
	[.[] | select(.workspace.id > 0 and .mapped == true)]
	| sort_by(.workspace.id, .at[1], .at[0])
	| .[].address
')

CURRENT=$(hyprctl activewindow -j | jq -r '.address')

TARGET=$(echo "$WINDOWS" | awk -v current="$CURRENT" -v dir="$DIRECTION" '
	{ addrs[NR] = $0; if ($0 == current) idx = NR }
	END {
		if (!idx) idx = 1
		if (dir == "next") target = idx % NR + 1
		else target = (idx == 1) ? NR : idx - 1
		print addrs[target]
	}
')

if [ -n "$TARGET" ]; then
	hyprctl dispatch "hl.dsp.focus({window='address:$TARGET'})"
fi
