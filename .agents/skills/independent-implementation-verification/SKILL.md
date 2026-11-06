---
name: independent-implementation-verification
description: Independently verify an issue implementation against its acceptance criteria and exact candidate.
---
# Independent implementation verification

When independent verification is requested or required, use a fresh verifier without the implementation narrative. Provide the issue, acceptance criteria, base and candidate identity (commit plus a reproducible diff or tree including untracked files), applicable rules and claimed checks. The verifier must not edit the candidate or publish, merge or message others.

The verifier examines source, call sites and tests, runs appropriate safe checks, and maps every criterion to pass, fail or blocked with evidence. Check relevant gameplay, scene, input, save, co-op, asset and platform boundaries. Record commands, environment, outcome and limitations; no unrun or simulated test is a real playtest. Return findings and a pass/fail/blocked verdict identifying the exact candidate. If no independent verifier is available or a required check cannot be performed, report blocked rather than calling self-review independent. Any change invalidates the prior verdict; reverify the new candidate. This project has no automated verdict helper; do not claim machine enforcement.
