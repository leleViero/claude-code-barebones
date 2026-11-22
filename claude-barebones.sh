#!/usr/bin/env bash
# claude-barebones.sh — Strip Claude Code to bare minimum context for local model
# Targets: ~10-15k init tokens on a 64k context window
# Requires Claude Code v2.1.275+ for syncClaudeAiSkills to work
# Run: bash claude-barebones.sh

set -euo pipefail

CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
SETTINGS="$CLAUDE_DIR/settings.json"
BACKUP="$CLAUDE_DIR/settings.full-plugins.json"

if [ ! -f "$SETTINGS" ]; then
  echo "ERROR: $SETTINGS not found."
  exit 1
fi

# Back up current config (only if backup doesn't already exist)
if [ ! -f "$BACKUP" ]; then
  cp "$SETTINGS" "$BACKUP"
  echo "Backed up current config to: $BACKUP"
else
  echo "Backup already exists at: $BACKUP (not overwriting)"
fi

cat > "$SETTINGS" << 'EOF'
{
  "model": "opus",
  "enabledPlugins": {},
  "effortLevel": "medium",
  "tui": "fullscreen",
  "agentPushNotifEnabled": false,
  "syncClaudeAiSkills": false,
  "syncClaudeAiPlugins": false,
  "env": {
    "ANTHROPIC_BASE_URL": "http://172.16.169.134:11434",
    "ANTHROPIC_API_KEY": "ollama",
    "ANTHROPIC_AUTH_TOKEN": "ollama",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "qwen3.8:27b-64k",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "qwen3.8:27b-64k",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "qwen3.8:27b-64k",
    "CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS": "1",
    "CLAUDE_CODE_MAX_CONTEXT_TOKENS": "65536"
  },
  "permissions": {
    "deny": [
      "NotebookEdit",
      "EnterPlanMode",
      "ExitPlanMode",
      "EnterWorktree",
      "ExitWorktree",
      "DesignSync",
      "SendMessage",
      "PushNotification",
      "RemoteTrigger",
      "ReportFindings",
      "ScheduleWakeup",
      "AskUserQuestion",
      "CronCreate",
      "CronDelete",
      "CronList",
      "Agent",
      "WebSearch",
      "WebFetch",
      "ListMcpResourcesTool",
      "ReadMcpResourceTool",
      "ReadMcpResourceDirTool",
      "ListConnectors",
      "SearchMcpRegistry",
      "SuggestConnectors",
      "SearchPlugins",
      "SuggestPluginInstall",
      "ListPlugins",
      "ListSkills",
      "SearchSkills",
      "Monitor",
      "ReadNotifications",
      "ListAgents",
      "ShowOnboardingRolePicker"
    ]
  },
  "disableBundledSkills": true,
  "disableWorkflows": true,
  "disableRemoteControl": true,
  "disableClaudeAiConnectors": true,
  "disableArtifact": true
}
EOF

echo ""
echo "=== BARE-BONES MODE ACTIVE ==="
echo "Removed: all plugins, statusLine, extraKnownMarketplaces"
echo "Added:   syncClaudeAiSkills: false, syncClaudeAiPlugins: false"
echo "Added:   local model env (qwen3.8:27b-64k via Ollama)"
echo "Added:   CLAUDE_CODE_MAX_CONTEXT_TOKENS=65536 (correct window)"
echo "Denied:  33 tools via permissions.deny (strips schemas from context)"
echo ""
echo "Kept tools: Bash, Read, Write, Edit, Grep, Glob, Skill, ToolSearch"
echo ""
echo "On next start Claude Code will:"
echo "  - Stop loading synced skills (~3,270 tokens saved)"
echo "  - Strip denied tool schemas (~10-15k tokens saved)"
echo "  - Use 64k context window instead of 200k default"
echo ""
echo "Restart Claude Code for changes to take effect."
echo "To revert: bash claude-fullplugins.sh"
