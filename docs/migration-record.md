# Migration record - authoritative 15-floor model

Initial migration: 2026-11-16

Final documentation review: 2026-11-20

- Replaced the 16-level sequence with physical floors 1-12 and 14-16.
- Removed Floor 17 and prohibited Floor 13.
- Replaced the fixed 4,000-agent allocation with independent room-level inclusive random draws.
- Replaced the photographed evacuation maps with `FLOORPLANS DRAWING.zip` and the revised 11th-floor plan.
- Removed the incorrect Floor-11 Computer Engineering room.
- Added separate regular-elevator and green-elevator cells, queues, capacities, and transfer counts.
- Restricted Floor-1 access to the green-box elevator and made the absent ground geometry explicitly provisional.
- Added the Floor-2 Student Plaza entrance as the second authorized escape boundary.
- Added evidence and uncertainty records for mislabeled, incomplete, or conflicting drawings.
- Replaced the former evacuation-timing scenarios with the three outbreak-origin scenarios and wrote the current detailed outputs under `results/outbreak_origin_scenarios`.
- Reserved `output/` for the tracked submission artifacts and removed the obsolete `baseline`, `early_evacuation`, `delayed_evacuation`, `grid_scenarios`, `authoritative_scenarios`, framework, and smoke-test result directories during final cleanup.
- Removed obsolete generated grid `.mat` files and the superseded venue-plan deck and earlier extracted map images; the active hand-drawn plan set and proposal remain locally preserved.
- Replaced proximity-only infection with aggressive pursuit, a 12% bite opportunity per adjacent infected agent, a 35% per-update cap, and guaranteed infection after a successful bite.

The current normalized grids are drawing-derived topological reconstructions, not scale architectural plans. The final repository retains the current MATLAB implementation, final report, selected visual outputs, and scenario animations while excluding reproducible detailed results and private source plans from Git.
