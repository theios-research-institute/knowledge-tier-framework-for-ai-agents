# Security Protocol - Tier 1: Restricted

> **This project contains information requiring maximum protection.**

## Classification: RESTRICTED

This project is classified as **Tier 1: Restricted** under the Knowledge Tier Framework. All work must comply with the following protocols.

---

## Mandatory Requirements

### Memory Status
- [ ] Memory MUST be **DISABLED** before any work session
- [ ] Verify with: `memory-status`
- [ ] If enabled, run: `memory-off`
- [ ] Also disable in Claude web settings: https://claude.ai/settings/capabilities

### Session Management
- [ ] Start sessions with: `claude-secure`
- [ ] Never use standard `claude` command for this project
- [ ] Create `SESSION_HANDOFF.md` at end of every session
- [ ] Store handoffs locally only (no cloud sync)

### Agent Access
- [ ] No external agents permitted
- [ ] Do not invoke specialist agents
- [ ] Do not use multi-agent workflows
- [ ] Manual initialization only

### Documentation
- [ ] Use vague feature descriptions
- [ ] Generic commit messages only
- [ ] No detailed technical specifications in tracked files
- [ ] Sensitive details in local `/spec` directory only

---

## Before Each Session

```bash
# 1. Verify memory is off
memory-status

# 2. If memory is ON, disable it
memory-off

# 3. Start secure session
claude-secure
```

---

## If Memory is Accidentally Enabled

1. **STOP** all work immediately
2. Note what information may have been exposed
3. Disable memory in Claude settings
4. Run `memory-off` to update local status
5. Document the incident in project notes
6. Review what was discussed and assess impact

---

## Legal Basis

Under U.S. trade secret law (Defend Trade Secrets Act), information loses protection if the owner fails to take "reasonable measures to maintain secrecy."

AI memory retention may constitute:
- Disclosure to third parties (Anthropic servers)
- Inadequate protection measures
- Potential waiver of trade secret status

This protocol ensures reasonable measures are taken.

---

## Emergency Contacts

If a security incident occurs:
- Document immediately
- Assess potential exposure
- Contact legal counsel if needed

---

*Knowledge Tier Framework - Theios Research Institute*
*https://github.com/theios-research-institute/knowledge-tier-framework-for-ai-agents*
