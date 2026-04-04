#!/usr/bin/env bash
# PostToolUse hook for ExitPlanMode — reminds Overseer to hand off

echo ""
echo "=========================================="
echo "  PLAN HANDOFF PROTOCOL ACTIVATED"
echo "=========================================="
echo ""
echo "AFTER the user approves:"
echo ""
echo "1. Check for existing Ready issues: rd ready --json"
echo "2. If Ready issues exist → launch Daemon agent to execute"
echo "3. If no Ready issues → launch Architect agent to gather requirements and create issues"
echo "4. Do NOT implement any part of the plan yourself"
echo "=========================================="
exit 0
