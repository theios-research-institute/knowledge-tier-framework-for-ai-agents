#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════
# Knowledge Tier Framework for AI Agents - Test Suite
# ═══════════════════════════════════════════════════════════════════════════

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
BOLD='\033[1m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

PASSED=0
FAILED=0

# Test helper
assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"

    if [ "$expected" = "$actual" ]; then
        echo -e "${GREEN}✓${NC} $test_name"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}✗${NC} $test_name"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
        FAILED=$((FAILED + 1))
    fi
}

assert_file_exists() {
    local file="$1"
    local test_name="$2"

    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $test_name"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}✗${NC} $test_name (file not found: $file)"
        FAILED=$((FAILED + 1))
    fi
}

assert_dir_exists() {
    local dir="$1"
    local test_name="$2"

    if [ -d "$dir" ]; then
        echo -e "${GREEN}✓${NC} $test_name"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}✗${NC} $test_name (directory not found: $dir)"
        FAILED=$((FAILED + 1))
    fi
}

assert_executable() {
    local file="$1"
    local test_name="$2"

    if [ -x "$file" ]; then
        echo -e "${GREEN}✓${NC} $test_name"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}✗${NC} $test_name (not executable: $file)"
        FAILED=$((FAILED + 1))
    fi
}

echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}  Knowledge Tier Framework for AI Agents - Test Suite${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# ═══════════════════════════════════════════════════════════════════════════
# File Structure Tests
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BOLD}File Structure Tests${NC}"

assert_file_exists "$PROJECT_DIR/install.sh" "install.sh exists"
assert_executable "$PROJECT_DIR/install.sh" "install.sh is executable"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# Template Tests
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BOLD}Template Tests${NC}"

# All four tiers should exist
assert_dir_exists "$PROJECT_DIR/templates/tier-1-restricted" "Tier 1 template exists"
assert_dir_exists "$PROJECT_DIR/templates/tier-2-confidential" "Tier 2 template exists"
assert_dir_exists "$PROJECT_DIR/templates/tier-3-internal" "Tier 3 template exists"
assert_dir_exists "$PROJECT_DIR/templates/tier-4-public" "Tier 4 template exists"

# All tiers should have .epistemic-tier file
for tier in 1 2 3 4; do
    case $tier in
        1) tier_name="tier-1-restricted" ;;
        2) tier_name="tier-2-confidential" ;;
        3) tier_name="tier-3-internal" ;;
        4) tier_name="tier-4-public" ;;
    esac
    assert_file_exists "$PROJECT_DIR/templates/$tier_name/.epistemic-tier" "Tier $tier has .epistemic-tier"
done

# Tier 1 should have additional security files
assert_file_exists "$PROJECT_DIR/templates/tier-1-restricted/SECURITY_PROTOCOL.md" "Tier 1 has SECURITY_PROTOCOL.md"
assert_file_exists "$PROJECT_DIR/templates/tier-1-restricted/init.sh" "Tier 1 has init.sh"
assert_file_exists "$PROJECT_DIR/templates/tier-1-restricted/.claude_project_config.json" "Tier 1 has .claude_project_config.json"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# Tier Configuration Tests
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BOLD}Tier Configuration Tests${NC}"

# Verify tier values are correct
TIER1=$(grep -E "^TIER=" "$PROJECT_DIR/templates/tier-1-restricted/.epistemic-tier" | cut -d= -f2)
assert_equals "restricted" "$TIER1" "Tier 1 TIER=restricted"

TIER2=$(grep -E "^TIER=" "$PROJECT_DIR/templates/tier-2-confidential/.epistemic-tier" | cut -d= -f2)
assert_equals "confidential" "$TIER2" "Tier 2 TIER=confidential"

TIER3=$(grep -E "^TIER=" "$PROJECT_DIR/templates/tier-3-internal/.epistemic-tier" | cut -d= -f2)
assert_equals "internal" "$TIER3" "Tier 3 TIER=internal"

TIER4=$(grep -E "^TIER=" "$PROJECT_DIR/templates/tier-4-public/.epistemic-tier" | cut -d= -f2)
assert_equals "public" "$TIER4" "Tier 4 TIER=public"

# Tier 1 should require memory off
MEM_REQ=$(grep -E "^MEMORY_REQUIRED=" "$PROJECT_DIR/templates/tier-1-restricted/.epistemic-tier" | cut -d= -f2)
assert_equals "off" "$MEM_REQ" "Tier 1 MEMORY_REQUIRED=off"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# Script Syntax Tests
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BOLD}Script Syntax Tests${NC}"

if bash -n "$PROJECT_DIR/install.sh" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} install.sh has valid syntax"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗${NC} install.sh has syntax errors"
    FAILED=$((FAILED + 1))
fi

if bash -n "$PROJECT_DIR/templates/tier-1-restricted/init.sh" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} tier-1 init.sh has valid syntax"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗${NC} tier-1 init.sh has syntax errors"
    FAILED=$((FAILED + 1))
fi

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# JSON Validation Tests
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BOLD}JSON Validation Tests${NC}"

if command -v jq &> /dev/null; then
    if jq empty "$PROJECT_DIR/templates/tier-1-restricted/.claude_project_config.json" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} .claude_project_config.json is valid JSON"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}✗${NC} .claude_project_config.json is invalid JSON"
        FAILED=$((FAILED + 1))
    fi
else
    echo -e "${RED}✗${NC} jq not installed - skipping JSON validation"
    FAILED=$((FAILED + 1))
fi

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# Results
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
TOTAL=$((PASSED + FAILED))
echo -e "Tests: $TOTAL | ${GREEN}Passed: $PASSED${NC} | ${RED}Failed: $FAILED${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
echo ""

if [ $FAILED -gt 0 ]; then
    exit 1
fi
exit 0
