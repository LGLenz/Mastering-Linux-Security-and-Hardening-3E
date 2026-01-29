# Chapter 12 — SCAP/XCCDF/OVAL validation notes

This folder contains SCAP artifacts (XCCDF/OVAL) for Ubuntu examples. These
files are schema-sensitive XML; modify only when you understand the SCAP schema.

Quick example of how to run a validation using `oscap` (adjust profile id):

```bash
# Example pattern — replace <PROFILE_ID> and dataset path as appropriate
oscap xccdf eval --profile <PROFILE_ID> --results results.xml Chapter_12/ubuntu22-04_scap_profiles/ssg-ubuntu2204-ds.xml

# Inspect the results
less results.xml
```

If you change an XCCDF/OVAL file, include the tool/version used and the exact
command in the PR so reviewers can reproduce the check.
