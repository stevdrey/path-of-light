# ADR 0001: Campaign state and saves

Status: Proposed · 2026-11-06

## Context

Settings already use user://settings.cfg; GameProgress is in-memory and level entry resets state. Attempt items and durable campaign progress have different lifetimes.

## Proposed decision

Propose a versioned, separately persisted campaign model with explicit attempt state, defensive loading and migration policy.

## Alternatives and tradeoffs

Keep static state only; serialize whole scene trees. Both complicate restart/replay or compatibility.

## Acceptance evidence

Prove restart, corrupted data, migration, secret retention and attempt resets on desktop and web.
