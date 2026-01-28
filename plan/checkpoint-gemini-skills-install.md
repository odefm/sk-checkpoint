# Gemini Skills Install

## Feature summary (high-level, 5–10 lines)
- Goal: Add Gemini CLI as a supported target for installing the checkpoint skill.
- User-facing behavior: Installer and docs include a Gemini flag and path; default install targets include Gemini when no flags are provided.
- Scope (in): `install.sh` targets, help text, flag handling, install copy, README install instructions and examples.
- Scope (out): Changes to skill content, additional tooling, or Gemini CLI behavior beyond install path.
- Assumptions: Gemini CLI v0.26.0 supports skills under `~/.gemini/skills`.
- Risks / edge cases: Confusing defaults or missing docs for the new target.

## Checklist (TDD-first, actionable)
- [x] Add Gemini invoke guidance to README
  - Files: `README.md`
  - TEST: Review README "How to invoke" section for Gemini manual `$checkpoint` note and a Gemini CLI behavior excerpt plus paraphrase.
  - IMPLEMENT: Add Gemini-specific invoke guidance under "How to invoke", including manual `$checkpoint` usage and a short Gemini CLI docs excerpt with a paraphrase of the rest.
  - VERIFY: Open README and confirm the new Gemini section reads correctly and includes the excerpt and paraphrase.

- [x] Add Gemini install target to script and docs
  - Files: `install.sh`, `README.md`
  - TEST: Manually inspect updated help/examples and ensure `install.sh --dry-run --gemini` prints target path `~/.gemini/skills/checkpoint`; check default no-args includes Gemini.
  - IMPLEMENT: Add `--gemini` flag + help text; add `INSTALL_GEMINI` handling; add copy to `~/.gemini/skills/checkpoint`; update README install paths and examples to include Gemini.
  - VERIFY: Run `./install.sh --dry-run --gemini` and `./install.sh --dry-run` and confirm output shows Gemini target(s).

## Progress log (append-only)
- 2026-01-28T14:56:23-08:00 - Initialized plan for Gemini skills install support.
- 2026-01-28T14:56:33-08:00 - Updated installer/docs for Gemini target; verified `./install.sh --dry-run --gemini` and `./install.sh --dry-run` show `~/.gemini/skills/checkpoint`.
- 2026-01-28T15:02:35-08:00 - Added Gemini invoke guidance in README.
