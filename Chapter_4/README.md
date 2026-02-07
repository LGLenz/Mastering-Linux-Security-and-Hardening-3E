# Chapter 4 - Firewall Configuration Files

This directory contains firewall configuration examples for the book "Mastering Linux Security and Hardening - 3rd Edition".

## Files Overview

### ip6tables Configuration

#### `ip6tables_lab-step_2.txt`
Original step-by-step commands for configuring ip6tables firewall rules.
- **Bug fixed**: Lines 13-16 now include `-j ACCEPT` action (was missing in original)
- Shows individual commands for educational purposes
- Total: 27 commands to build a complete IPv6 firewall ruleset

#### `ip6tables_lab-step_2.sh` (NEW - Refactored)
Shell script version that eliminates code duplication using loops and arrays.
- **Eliminates duplication**: Uses a loop to handle 20 ICMPv6 type rules instead of 20 separate commands
- **More maintainable**: Easy to add/remove ICMPv6 types by modifying the array
- **Same functionality**: Produces identical firewall rules as the original file
- **Usage**: `chmod +x ip6tables_lab-step_2.sh && sudo ./ip6tables_lab-step_2.sh`

### nftables Configuration

#### `nftables_base.conf` (NEW - Refactored)
Base template containing all common nftables firewall rules with extensive documentation.
- **Eliminates duplication**: Single source of truth for common firewall rules
- **Well-documented**: Each rule includes comments explaining its purpose
- **Complete example**: Includes prerouting and input chains with comprehensive rules

#### `nftables.conf` (Original Example 1)
Original configuration with:
- Combined shebang and flush on line 1: `#!/usr/sbin/nft -f flush ruleset`
- Includes extra log prefix on prerouting chain (line 7)
- Includes IPv6 ICMPv6 filtering rule (line 23)

#### `nftables_example_1.conf` (Original Example 2)  
Original configuration with minor variations from `nftables.conf`:
- Separated shebang and flush commands
- Different formatting/indentation
- Missing one ICMPv6 rule
- Author comment: "# prerouting chain added by Donnie"

## Refactoring Summary

### What Was Changed

1. **ip6tables duplication removed**:
   - Created `ip6tables_lab-step_2.sh` that uses loops instead of 20+ repetitive commands
   - Fixed bug in original file (missing `-j ACCEPT` on lines 13-16)
   - Reduced code duplication by ~75%

2. **nftables duplication addressed**:
   - Created `nftables_base.conf` as a single, well-documented base template
   - Original files preserved for backward compatibility and comparison
   - New file includes all rules from both originals with proper documentation

### Benefits

- **Maintainability**: Easier to update rules in one place
- **Clarity**: Better documentation explains each rule's purpose  
- **Correctness**: Bug fixes ensure all rules work properly
- **Educational**: Shows both verbose and optimized approaches

### Migration Guide

To use the refactored versions:

1. For ip6tables: Replace command-by-command execution with the shell script
   ```bash
   chmod +x ip6tables_lab-step_2.sh
   sudo ./ip6tables_lab-step_2.sh
   ```

2. For nftables: Use the base configuration as your starting point
   ```bash
   sudo nft -f nftables_base.conf
   ```

### Original Files

The original files (`nftables.conf`, `nftables_example_1.conf`, and `ip6tables_lab-step_2.txt`) are preserved for:
- Educational comparison between approaches
- Backward compatibility with book references
- Historical documentation of the refactoring
