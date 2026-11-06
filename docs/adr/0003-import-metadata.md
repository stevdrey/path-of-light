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
