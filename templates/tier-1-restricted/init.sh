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

# Check 5: Git remote verification (if ALLOWED_REMOTES is set)
if [ -f ".epistemic-tier" ]; then
    ALLOWED_REMOTES=$(grep -E "^ALLOWED_REMOTES=" ".epistemic-tier" 2>/dev/null | cut -d= -f2)
    if [ -n "$ALLOWED_REMOTES" ] && [ -d ".git" ]; then
        echo -e "${BOLD}Checking git remotes against ALLOWED_REMOTES...${NC}"
        REMOTE_ERRORS=0
        while IFS= read -r REMOTE_LINE; do
            [ -z "$REMOTE_LINE" ] && continue
            REMOTE_NAME=$(echo "$REMOTE_LINE" | awk '{print $1}')
            REMOTE_URL=$(echo "$REMOTE_LINE" | awk '{print $2}')
            # Normalize URL: strip protocol/user prefix and .git suffix
            # git@host:path → host/path, https://host/path → host/path
            # Also handles ssh://, git:// protocols
            NORMALIZED_URL="$REMOTE_URL"
            NORMALIZED_URL="${NORMALIZED_URL%.git}"
            NORMALIZED_URL=$(echo "$NORMALIZED_URL" | sed -E 's|^ssh://[^@]*@||; s|^ssh://||; s|^git://||; s|^https?://||; s|^[^@]*@([^:]+):|\1/|')
            MATCHED=0
            IFS=',' read -ra PATTERNS <<< "$ALLOWED_REMOTES"
            for PATTERN in "${PATTERNS[@]}"; do
                PATTERN=$(echo "$PATTERN" | xargs)  # trim whitespace
                [ -z "$PATTERN" ] && continue
                if [[ "$PATTERN" == *'*' ]]; then
                    PREFIX="${PATTERN%\*}"
                    if [[ "$NORMALIZED_URL" == *"$PREFIX"* ]] || [[ "$REMOTE_URL" == *"$PREFIX"* ]]; then
                        MATCHED=1
                        break
                    fi
                else
                    if [[ "$NORMALIZED_URL" == *"$PATTERN"* ]] || [[ "$REMOTE_URL" == *"$PATTERN"* ]]; then
                        MATCHED=1
                        break
                    fi
                fi
            done
            if [ "$MATCHED" -eq 0 ]; then
                echo -e "  ${RED}✗ Remote '$REMOTE_NAME' ($REMOTE_URL) not in ALLOWED_REMOTES${NC}"
                REMOTE_ERRORS=$((REMOTE_ERRORS + 1))
            fi
        done < <(git remote -v 2>/dev/null | grep '(push)')
        if [ "$REMOTE_ERRORS" -eq 0 ]; then
            echo -e "  ${GREEN}✓ All git remotes match ALLOWED_REMOTES${NC}"
        else
            echo -e "    Allowed: ${YELLOW}$ALLOWED_REMOTES${NC}"
            ERRORS=$((ERRORS + REMOTE_ERRORS))
        fi
    fi
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
