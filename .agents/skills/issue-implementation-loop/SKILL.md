---
name: issue-implementation-loop
description: Coordinate issue implementation, independent verification, corrections and an authorized pull request.
---
# Issue implementation loop

Read the issue, parent epic, GDD, relevant ADRs and actual code. Identify acceptance criteria, dependencies and material ambiguities; resolve those that change behavior before dependent implementation. Implement with agent-task-workflow and applicable Godot skills, then gather focused evidence. Request independent verification of the exact candidate under independent-implementation-verification; correct blockers and reverify after each change. Stop and report if required evidence or independent verification is unavailable, or repeated attempts do not progress. Only create a PR within the user's authorized scope and describe evidence with create-pull-request. Never merge by default. This is a human/agent procedure, not an automated enforcement system.
