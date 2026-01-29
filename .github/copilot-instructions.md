<!--
Quick guide for AI coding agents to make safe, targeted edits in this repo.
-->
# Copilot / AI-Agent Instructions

Purpose: Provide concise, actionable guidance for AI agents working in this
repository. This project consists of chapter folders with example configurations
and command output snapshots. Typical changes: fix example configs, improve
explanations, or add small complementary files. There is no running service or
monorepo build system to modify.

- Project layout: top-level folders are `Chapter_<n>/`. Examples:
  - `Chapter_4/nftables.conf` — nftables example ruleset
  - `Chapter_12/*_scap_profiles/` — SCAP/XCCDF/OVAL artifacts (machine-readable)
  - `Chapter_16/*.txt` — recorded outputs (nmap, netstat)

- Scope & expectations:
  - Limit edits to content and examples. Avoid broad refactors or renames.
  - Keep files and paths stable; prefer editing contents over moving files.

- File-specific patterns and cautions:
  - nftables: follow nftables syntax (tables/chains/rules). Example: edit
    `Chapter_4/nftables.conf` only to fix typos or clarify examples; verify
    rules on a test VM before marking as final.
  - SCAP/XCCDF/OVAL (Chapter_12): these are schema-sensitive XML artifacts.
    Only modify if you understand the SCAP schema; prefer metadata notes
    rather than structural changes.
  - Output snapshots (Chapter_16): keep original command lines and timestamps
    unless correcting an obvious transcription error.

- CI / automation:
  - There is one workflow: `.github/workflows/go-ossf-slsa3-publish.yml`.
  - No repo-wide test suite — functional validation is manual on a Linux VM.

- Commit & PR guidance (examples):
  - Commit messages: `chapter4: fix nftables rule typo in accept-ssh`.
  - PR description: 1–2 lines summary, list of edited files, validation steps.

- What not to change:
  - Do not rewrite `LICENSE` or `SECURITY.md` except for clear factual fixes.
  - Avoid mass reformatting of many example files in one PR.

- Documentation additions:
  - Add short contextual notes next to examples (same folder). For larger
    explanatory content, add a `README.md` in the chapter folder.

- Validation tips:
  - For firewall configs: provide a short `How I tested` bullet in the PR
    with commands you ran on a test VM (e.g., `nft list ruleset`, `nft -f ...`).
  - For SCAP profiles: note the SCAP tool/version you used and the check
    command if available.

If anything is ambiguous, ask a focused question and include the affected
path(s). Provide minimal, reversible changes and keep commits small.
