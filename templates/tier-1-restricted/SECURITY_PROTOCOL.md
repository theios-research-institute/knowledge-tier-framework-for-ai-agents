# Security Protocol - Tier 1: Restricted

> **This project contains information requiring maximum protection.**

## Classification: RESTRICTED

This project is classified as **Tier 1: Restricted** under the Knowledge Tier Framework. All work must comply with the following protocols.

---

## Mandatory Requirements

### Memory Status
- [ ] Memory MUST be **DISABLED** before any work session
- [ ] Verify with: `epistemic-memory-status`
- [ ] If enabled, run: `epistemic-memory-off`
- [ ] Also disable in your AI assistant's memory/retention settings

### Session Management
- [ ] Verify memory is OFF before starting any session
- [ ] Run `./init.sh` to check environment before working
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

### Outbound Actions
- [ ] Verify `git remote -v` before any push operation
- [ ] Declare allowed remotes in `.epistemic-tier` using `ALLOWED_REMOTES`
- [ ] All git remotes must match the `ALLOWED_REMOTES` list
- [ ] Never push to an unlisted remote — the guardrails will block it
- [ ] Verify the correct auth account is active before interacting with remote repos

---

## Before Each Session

```bash
# 1. Verify memory is off
epistemic-memory-status

# 2. If memory is ON, disable it
epistemic-memory-off

# 3. Verify environment
./init.sh
```

---

## Outbound Action Verification

Before any `git push`, `gh repo create`, or similar outbound operation:

```bash
# 1. Verify remotes match allowed list
git remote -v

# 2. Verify auth account
gh auth status

# 3. Compare against ALLOWED_REMOTES in .epistemic-tier
grep ALLOWED_REMOTES .epistemic-tier
```

If an outbound action is blocked by Epistemic Guardrails, the deny message will show:
- The destination that was attempted
- The list of allowed destinations from `ALLOWED_REMOTES`

**Do not bypass the block.** Fix the remote or auth configuration instead.

---

## If Memory is Accidentally Enabled

1. **STOP** all work immediately
2. Note what information may have been exposed
3. Disable memory in Claude settings
4. Run `epistemic-memory-off` to update local status
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
