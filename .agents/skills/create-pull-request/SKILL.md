---
name: create-pull-request
description: Prepare or create an evidence-backed GitHub pull request for this game.
---
# Create pull request

Inspect the actual candidate diff, linked issue and acceptance criteria, relevant GDD/ADRs and executed checks. If an issue exists, use `[Issue-N] <concise outcome>`; never invent an issue number. Use these headings: What, Why, Changes, How to test / verify, Risk & rollout, Notes for reviewers. Include actual commands and outcomes, unrun manual playtests, scene/save compatibility, asset rights and release risks where relevant. Mention independent review only when it was performed on this candidate. Use `Closes #N` only if the PR fully resolves the issue; otherwise use `Refs #N`. Create or update the PR only within the user's authorized scope; never merge by default.
