# Changelog

All notable changes to Knowledge Tier Framework for AI Agents will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-02-27

### Added
- `ALLOWED_REMOTES` field in `.epistemic-tier` for outbound action protection
- Outbound Actions section in Tier 1 `SECURITY_PROTOCOL.md`
- Git remote verification in Tier 1 `init.sh` environment check with SSH, HTTPS, `ssh://`, and `git://` URL normalization
- Tests for `ALLOWED_REMOTES` field presence across all tier templates

### Changed
- Tier 1 `.epistemic-tier` now includes `ALLOWED_REMOTES=` (empty, to be populated per-project)
- Tiers 2-4 `.epistemic-tier` now include `#ALLOWED_REMOTES=` (commented, optional)

## [1.0.0] - 2026-02-05

### Added
- Initial release
- Four-tier classification system (Restricted, Confidential, Internal, Public)
- Tier 1 (Restricted) template with security protocol and environment verification
- Tier 2-4 templates with `.epistemic-tier` configuration
- Interactive project initialization (`init-project-tier`)
- Integration with Epistemic Guardrails

---

*Knowledge Tier Framework for AI Agents — Theios Research Institute, Inc.*
