<!-- Pull Request template to help reviewers quickly validate chapter edits -->
# Pull Request

- **Summary**: Short (1-2 lines) summary of the change.
- **Files changed**: List of edited files (or directories).
- **Why**: One-line rationale for the change (typo, clarify example, fix config).
- **How tested / Validation steps**: concise steps that a reviewer can follow.

Validation examples (adjust paths/commands to your test VM):

- nftables (chapter 4):

```bash
# Syntax / quick apply (run on a disposable test VM):
sudo nft -f Chapter_4/nftables.conf
sudo nft list ruleset
```

- SCAP (chapter 12):

```bash
# Example: run an XCCDF evaluation against a dataset file (adjust profile):
oscap xccdf eval --profile <PROFILE_ID> --results results.xml Chapter_12/ubuntu22-04_scap_profiles/ssg-ubuntu2204-ds.xml
```

- **Checklist**:
  - [ ] Small, focused change (no mass reformat)
  - [ ] Files/paths preserved where possible
  - [ ] `How I tested` added with commands used

Add any notes for reviewers (scoping decisions, manual steps, or why a larger
refactor was avoided).
