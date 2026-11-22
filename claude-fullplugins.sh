#!/usr/bin/env bash
# claude-fullplugins.sh — Restore original full-plugins Claude Code config
# Run: bash claude-fullplugins.sh

set -euo pipefail

CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
SETTINGS="$CLAUDE_DIR/settings.json"
BACKUP="$CLAUDE_DIR/settings.full-plugins.json"

# Try restoring from backup first
if [ -f "$BACKUP" ]; then
  cp "$BACKUP" "$SETTINGS"
  echo ""
  echo "=== FULL-PLUGINS MODE RESTORED (from backup) ==="
  echo "Restart Claude Code for changes to take effect."
  echo ""
  exit 0
fi

# No backup found — write the known original config
echo "No backup found at $BACKUP. Writing original config from template."

cat > "$SETTINGS" << 'JSONEOF'
{
  "model": "opus",
  "enabledPlugins": {
    "productivity@knowledge-work-plugins": true,
    "seo-technical-optimization@claude-code-workflows": true,
    "seo-analysis-monitoring@claude-code-workflows": true,
    "seo-content-creation@claude-code-workflows": true,
    "superpowers@claude-plugins-official": true,
    "skill-creator@claude-plugins-official": true,
    "claude-hud@claude-hud": true
  },
  "extraKnownMarketplaces": {
    "knowledge-work-plugins": {
      "source": {
        "source": "github",
        "repo": "anthropics/knowledge-work-plugins"
      }
    },
    "claude-code-workflows": {
      "source": {
        "source": "github",
        "repo": "wshobson/agents"
      }
    },
    "claude-hud": {
      "source": {
        "source": "github",
        "repo": "jarrodwatts/claude-hud"
      }
    }
  },
  "effortLevel": "medium",
  "tui": "fullscreen",
  "agentPushNotifEnabled": false,
  "statusLine": {
    "type": "command",
    "command": "cols=${COLUMNS:-}; case \"$cols\" in \"\"|*[!0-9]*) cols=$(stty size 2>/dev/null </dev/tty | awk '{print $2}');; esac; case \"$cols\" in \"\"|*[!0-9]*) cols=120;; esac; export COLUMNS=$(( cols > 4 ? cols - 4 : 1 )); plugin_dir=$(ls -1d \"${CLAUDE_CONFIG_DIR:-$HOME/.claude}\"/plugins/cache/*/claude-hud/*/ 2>/dev/null | sort -V | tail -1); exec \"/c/Program Files/nodejs/node\" \"${plugin_dir}dist/index.js\"",
    "refreshInterval": 5
  }
}
JSONEOF

echo ""
echo "=== FULL-PLUGINS MODE ACTIVE ==="
echo "Restart Claude Code for changes to take effect."
echo ""
