# Migration record - authoritative 15-floor model

Initial migration: 2026-11-16

Final documentation review: 2026-11-18

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
- Reserved `output/` for the tracked submission artifacts; older `results/grid_scenarios` and `results/authoritative_scenarios` runs are historical and are not referenced by the final documentation.
- Replaced proximity-only infection with aggressive pursuit, a 12% bite opportunity per adjacent infected agent, a 35% per-update cap, and guaranteed infection after a successful bite.

The current normalized grids are drawing-derived topological reconstructions, not scale architectural plans. The final repository retains the current MATLAB implementation, final report, selected visual outputs, and scenario animations while excluding reproducible detailed results and private source plans from Git.
