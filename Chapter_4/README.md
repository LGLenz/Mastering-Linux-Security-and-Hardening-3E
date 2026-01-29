# Chapter 4 — nftables validation notes

Quick validation steps for changes to `Chapter_4/nftables.conf`.

Run commands on a disposable test VM or container; do not run on production hosts.

Syntax check / apply (example):

```bash
# Apply the ruleset on a test VM
sudo nft -f Chapter_4/nftables.conf

# List loaded rules to verify
sudo nft list ruleset
```

Cleanup: remove or revert tables/chains you added as needed on the test host.

In the PR description include a short `How I tested` bullet with the exact
commands you ran and the test environment (OS, nft version).
