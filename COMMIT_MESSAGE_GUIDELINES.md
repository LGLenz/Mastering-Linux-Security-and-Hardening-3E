# Commit message guidelines

Keep commits small and focused. Use the following structure for messages:

- Header: `chapterX: short description` (max ~50 chars)
- Blank line
- Body (optional): one or two sentences explaining *why* the change was made.
- Footer (optional): testing notes or related issue numbers.

Examples:

```
chapter4: fix nftables accept-ssh rule typo

Corrected port number and added brief rationale for rule order.

How I tested: applied on Ubuntu 24.04 test VM with `sudo nft -f Chapter_4/nftables.conf`.
```

```
chapter12: clarify SCAP metadata in ubuntu22-04 profile

Remove redundant tag and add note about expected oscap version.

How I tested: validated using `oscap xccdf eval --profile <PROFILE_ID> ...`.
```

Include a `How I tested` line when the change affects configs or examples.
