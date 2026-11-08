# ADR 0003: Asset import metadata

Status: Proposed · 2026-11-06

## Context

The repository currently ignores *.import; generated metadata can affect identifiers and settings.

## Proposed decision

Re-evaluate whether to version import metadata after a clean-clone comparison; retain current policy until a decision is approved.

## Alternatives and tradeoffs

Continue ignoring with reproducibility checks; commit metadata with documented review.

## Acceptance evidence

Compare clean imports, settings and exported output on multiple environments before acceptance.

The [E01-03 baseline](../import-test-baseline.md) compares two clean imports on one machine and documents differences from local ignored metadata. It does not satisfy the multi-environment or exported-output evidence above; the decision remains proposed.
