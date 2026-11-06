# ADR 0002: Local co-op ownership

Status: Proposed · 2026-11-06

## Context

Current level scripts reference one character. The GDD proposes independent health and input with shared progress.

## Proposed decision

Propose per-player input and health ownership with a shared session for keys, exit and camera coordination.

## Alternatives and tradeoffs

Duplicate single-player level state; centralize all player state in the level. Compare complexity and testability.

## Acceptance evidence

Demonstrate safe joins, separation, simultaneous depletion, revival and exit without deadlocks.
