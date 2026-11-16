# Migration record - authoritative 15-floor model

Date: 2026-11-16

- Replaced the 16-level sequence with physical floors 1-12 and 14-16.
- Removed Floor 17 and prohibited Floor 13.
- Replaced the fixed 4,000-agent allocation with independent room-level inclusive random draws.
- Replaced the photographed evacuation maps with `FLOORPLANS DRAWING.zip` and the revised 11th-floor plan.
- Removed the incorrect Floor-11 Computer Engineering room.
- Added separate regular-elevator and green-elevator cells, queues, capacities, and transfer counts.
- Restricted Floor-1 access to the green-box elevator and made the absent ground geometry explicitly provisional.
- Added the Floor-2 Student Plaza entrance as the second authorized escape boundary.
- Added evidence and uncertainty records for mislabeled, incomplete, or conflicting drawings.
- Wrote new outputs under `results/authoritative_scenarios`; older `results/grid_scenarios` outputs are obsolete.

The current normalized grids are drawing-derived topological reconstructions, not scale architectural plans.
