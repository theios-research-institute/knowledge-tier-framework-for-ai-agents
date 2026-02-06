#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════
# Knowledge Tier Framework - Tier 1 Environment Verification
# ═══════════════════════════════════════════════════════════════════════════
# This script verifies the environment is correctly configured for
# Tier 1 (Restricted) work before starting a session.
# ═══════════════════════════════════════════════════════════════════════════

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
BOLD='\033[1m'

echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}  Tier 1 (Restricted) Environment Verification${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
echo ""

ERRORS=0

# Check 1: Memory status
echo -e "${BOLD}Checking memory status...${NC}"
MEMORY_STATUS_FILE="$HOME/.claude/.memory-status-cache"
if [ -f "$MEMORY_STATUS_FILE" ]; then
    MEMORY_STATUS=$(cat "$MEMORY_STATUS_FILE")
    if [ "$MEMORY_STATUS" = "ON" ]; then
        echo -e "  ${RED}✗ Memory is ENABLED - CRITICAL VIOLATION${NC}"
        echo -e "    Run: ${GREEN}memory-off${NC} and disable in Claude settings"
        ERRORS=$((ERRORS + 1))
    else
        echo -e "  ${GREEN}✓ Memory is disabled${NC}"
    fi
else
    echo -e "  ${YELLOW}⚠ Memory status unknown, assuming OFF${NC}"
fi

# Check 2: .epistemic-tier file exists
echo -e "${BOLD}Checking tier configuration...${NC}"
if [ -f ".epistemic-tier" ]; then
    # Use grep instead of source for security (avoid arbitrary code execution)
    TIER=$(grep -E "^TIER=" ".epistemic-tier" 2>/dev/null | cut -d= -f2)
    if [ "$TIER" = "restricted" ]; then
        echo -e "  ${GREEN}✓ Tier correctly set to: restricted${NC}"
    else
        echo -e "  ${RED}✗ Tier mismatch: expected 'restricted', got '$TIER'${NC}"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo -e "  ${RED}✗ Missing .epistemic-tier file${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Check 3: Security protocol exists
echo -e "${BOLD}Checking security protocol...${NC}"
if [ -f "SECURITY_PROTOCOL.md" ]; then
    echo -e "  ${GREEN}✓ Security protocol document present${NC}"
else
    echo -e "  ${YELLOW}⚠ SECURITY_PROTOCOL.md not found${NC}"
fi

# Check 4: Not in cloud-synced directory
echo -e "${BOLD}Checking directory location...${NC}"
CURRENT_DIR=$(pwd)
if [[ "$CURRENT_DIR" == *"Dropbox"* ]] || [[ "$CURRENT_DIR" == *"Google Drive"* ]] || [[ "$CURRENT_DIR" == *"iCloud"* ]] || [[ "$CURRENT_DIR" == *"OneDrive"* ]]; then
    echo -e "  ${YELLOW}⚠ Project appears to be in cloud-synced directory${NC}"
    echo -e "    Consider moving to a local-only location"
else
    echo -e "  ${GREEN}✓ Project not in detected cloud sync directory${NC}"
fi

# Results
echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}  ✓ All checks passed - environment ready${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    exit 0
else
    echo -e "${RED}  ✗ $ERRORS error(s) found - fix before proceeding${NC}"
    echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    exit 1
fi
