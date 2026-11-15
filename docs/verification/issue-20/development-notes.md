# Development checks and failures

The first standalone invocation of `campaign_rewards_integration.gd -- --checks` failed to parse because GDScript could not infer the type of `fixture` from a dynamically typed chained store result. The declaration was corrected to an explicit `Dictionary`; the subsequent standalone run passed 35 assertions. This note summarizes the observed failure, not a retained raw engine log.

An interim suite wrote logs under `/tmp/issue20-initial` while implementation was still changing. Those results are exploratory and are not exact-candidate verification. Only the final implementation manifest/results in this directory and the independent report identify a reproducible reviewed candidate.

Godot MCP health reported `bridge_connected: false` with a bind error for port 9080. Command-line integration tests therefore supply the runtime evidence; no editor-driven validation is claimed.

The first frozen implementation run passed 28 of 29 processes. The record-log geometry assertion compared logical UI coordinates with physical window dimensions. Independent geometry inspection found the panel was inside the logical viewport; the test was corrected to use `root.get_visible_rect()`, matching existing map tests. The initial failed manifest/results remain under `initial/implementation/`, and the initial independent FAIL report remains under `independent-final/initial-report.md`. The final evidence pointer was also corrected to the context-isolated reviewer.
