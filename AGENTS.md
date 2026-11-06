# Agent instructions

- Write all project documentation, issues, pull requests and agent-facing instructions in English. The GDD's Spanish-first player-facing language is a separate requirement.
- Read `GDD.md`, `docs/ROADMAP.md`, the relevant backlog item and existing implementation before changing behavior. Distinguish proposals from verified features; preserve open decisions and record consequential choices in ADRs.
- Work in small, reviewable increments. Protect the single-player route, optional nature of secrets and assists, co-op requirements, and the playable-slice scope gate.
- Use the relevant Godot skills and editor tooling when available; follow project conventions and verify scene, input and persistence changes. Run focused integration checks and record manual visual, audio, controller and playtest gaps honestly.
- Do not claim an independent review unless a separate reviewer evaluated the exact candidate and its acceptance criteria; repeat review after changes. Do not invent evidence, asset rights, facts or user validation.
- Before release, review asset provenance, licenses, accessibility and target-device results. Never collect real telemetry without its documented consent, retention and local controls.
- Adapt the project workflows in `.agents/skills/` when applicable. These are guidance; they do not automatically enforce checks or authorize sending comments, creating PRs or merging.
