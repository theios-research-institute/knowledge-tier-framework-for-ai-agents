#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════
# Knowledge Tier Framework for AI Agents - Installer
# ═══════════════════════════════════════════════════════════════════════════
# Part of the Knowledge Tier Framework by Theios Research Institute
# https://github.com/theios-research-institute/knowledge-tier-framework-for-ai-agents
# ═══════════════════════════════════════════════════════════════════════════

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'
BOLD='\033[1m'

echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}  Knowledge Tier Framework for AI Agents - Installer${NC}"
echo -e "${BOLD}  Theios Research Institute${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Detect script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Target directories
CLAUDE_DIR="$HOME/.claude"
TEMPLATES_DIR="$CLAUDE_DIR/templates"
SCRIPTS_DIR="$CLAUDE_DIR/scripts"

# Create directories
echo -e "${BLUE}Creating directories...${NC}"
mkdir -p "$TEMPLATES_DIR"
mkdir -p "$SCRIPTS_DIR"

# Copy templates
echo -e "${BLUE}Installing tier templates...${NC}"
cp -r "$SCRIPT_DIR/templates/"* "$TEMPLATES_DIR/"

# Make init scripts executable
find "$TEMPLATES_DIR" -name "init.sh" -exec chmod +x {} \;

# Copy hooks if they exist
if [ -d "$SCRIPT_DIR/hooks" ]; then
    echo -e "${BLUE}Installing hooks...${NC}"
    mkdir -p "$CLAUDE_DIR/hooks"
    cp "$SCRIPT_DIR/hooks/"*.sh "$CLAUDE_DIR/hooks/" 2>/dev/null || true
    chmod +x "$CLAUDE_DIR/hooks/"*.sh 2>/dev/null || true
fi

# Create the tier initialization script
echo -e "${BLUE}Installing tier initialization script...${NC}"
cat > "$SCRIPTS_DIR/init-project-tier.sh" << 'SCRIPT'
#!/bin/bash

# Knowledge Tier Framework - Project Tier Initialization
# Theios Research Institute

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'
BOLD='\033[1m'

TEMPLATES_DIR="$HOME/.claude/templates"

show_help() {
    echo ""
    echo -e "${BOLD}Knowledge Tier Framework - Initialize Project${NC}"
    echo ""
    echo "Usage: init-project-tier [OPTIONS] [DIRECTORY]"
    echo ""
    echo "Options:"
    echo "  --tier N    Specify tier (1-4)"
    echo "  --help      Show this help"
    echo ""
    echo "Tiers:"
    echo "  1 - Restricted    (Trade secrets, proprietary research)"
    echo "  2 - Confidential  (Competitive advantage, internal R&D)"
    echo "  3 - Internal      (Client work, business operations)"
    echo "  4 - Public        (Open source, documentation)"
    echo ""
}

# Parse arguments
TIER=""
TARGET_DIR="."

while [[ $# -gt 0 ]]; do
    case $1 in
        --tier)
            TIER="$2"
            shift 2
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            TARGET_DIR="$1"
            shift
            ;;
    esac
done

# Interactive tier selection if not specified
if [ -z "$TIER" ]; then
    echo ""
    echo -e "${BOLD}Select Knowledge Tier:${NC}"
    echo ""
    echo "  1) Restricted    - Trade secrets, pre-patent, proprietary"
    echo "  2) Confidential  - Competitive advantage, internal R&D"
    echo "  3) Internal      - Client work, business operations"
    echo "  4) Public        - Open source, documentation"
    echo ""
    read -p "Enter tier (1-4): " TIER
fi

# Validate tier
case $TIER in
    1) TIER_DIR="tier-1-restricted" ;;
    2) TIER_DIR="tier-2-confidential" ;;
    3) TIER_DIR="tier-3-internal" ;;
    4) TIER_DIR="tier-4-public" ;;
    *)
        echo -e "${RED}Invalid tier: $TIER${NC}"
        exit 1
        ;;
esac

# Check template exists
if [ ! -d "$TEMPLATES_DIR/$TIER_DIR" ]; then
    echo -e "${RED}Template not found: $TEMPLATES_DIR/$TIER_DIR${NC}"
    exit 1
fi

# Navigate to target
cd "$TARGET_DIR" || exit 1

# Copy template files (only if they don't already exist)
echo ""
echo -e "${BLUE}Initializing Tier $TIER project in: $(pwd)${NC}"
for file in "$TEMPLATES_DIR/$TIER_DIR/"*; do
    [ -e "$file" ] || continue
    filename=$(basename "$file")
    [ -e "$filename" ] || cp "$file" . 2>/dev/null
done
for file in "$TEMPLATES_DIR/$TIER_DIR/".*; do
    [ -e "$file" ] || continue
    filename=$(basename "$file")
    [ "$filename" = "." ] || [ "$filename" = ".." ] && continue
    [ -e "$filename" ] || cp "$file" . 2>/dev/null
done

# Make init.sh executable
chmod +x init.sh 2>/dev/null || true

echo ""
echo -e "${GREEN}✓ Project initialized as Tier $TIER${NC}"
echo ""
echo -e "${BOLD}Next steps:${NC}"
if [ "$TIER" = "1" ]; then
    echo "  1. Edit .claude_project_config.json with project name"
    echo "  2. Run ./init.sh to verify environment"
    echo "  3. Review SECURITY_PROTOCOL.md"
    echo "  4. Ensure memory is OFF: epistemic-memory-status"
else
    echo "  1. Review .epistemic-tier configuration"
    echo "  2. Customize tier settings if needed"
fi
echo ""
SCRIPT

chmod +x "$SCRIPTS_DIR/init-project-tier.sh"

# Detect shell and add alias
SHELL_RC=""
if [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_RC="$HOME/.bashrc"
fi

echo ""
echo -e "${BLUE}Setting up shell alias...${NC}"

ALIAS='alias init-project-tier="~/.claude/scripts/init-project-tier.sh"'

if [ -n "$SHELL_RC" ]; then
    if ! grep -q "init-project-tier" "$SHELL_RC" 2>/dev/null; then
        echo "" >> "$SHELL_RC"
        echo "# Knowledge Tier Framework (Theios Research Institute)" >> "$SHELL_RC"
        echo "$ALIAS" >> "$SHELL_RC"
        echo -e "${GREEN}✓ Alias added to $SHELL_RC${NC}"
    else
        echo -e "${YELLOW}Alias already exists in $SHELL_RC${NC}"
    fi
fi

# Success
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BOLD}Quick Start:${NC}"
echo ""
echo -e "  ${GREEN}init-project-tier${NC}         - Initialize a new project with tier"
echo -e "  ${GREEN}init-project-tier --tier 1${NC} - Initialize as Tier 1 (Restricted)"
echo ""
echo -e "${BOLD}Templates installed to:${NC} $TEMPLATES_DIR"
echo ""
echo -e "${BOLD}Companion package:${NC}"
echo -e "  Install ${BLUE}epistemic-guardrails-for-ai-agents${NC} for memory enforcement"
echo -e "  https://github.com/theios-research-institute/epistemic-guardrails-for-ai-agents"
echo ""
echo -e "${BOLD}Documentation:${NC} https://github.com/theios-research-institute/knowledge-tier-framework-for-ai-agents"
echo ""
