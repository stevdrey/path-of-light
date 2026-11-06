# Architecture and state

The prototype includes character components and control strategies, reusable collectibles and hazards, level scenes, menu settings and integration scripts. `GameProgress` is currently in-memory; settings persistence is separate and does not mean campaign saving exists. Level scripts and the current single-character assumptions require review before co-op or durable progression is added.

The proposed boundaries and alternatives are in the repository's [ADRs](https://github.com/stevdrey/path-of-light/tree/main/docs/adr). They are proposals, not implemented contracts. Keep per-attempt keys, health and inventory distinct from durable completed levels, recorded secrets and unlocks when deciding the save model.
