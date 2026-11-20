# Model framework

| Component | Active implementation |
|---|---|
| Configuration | `config/defaultConfig.m` |
| Floors and physical IDs | `data/floor_metadata.csv` |
| Room inventory and occupancy ranges | `data/room_inventory.csv` |
| Geometry evidence | `data/geometry_evidence.csv` |
| Grid construction | `outbreak.createPlanDerivedGrid` |
| Population generation | `outbreak.generateRoomOccupancy` |
| Agent placement | `outbreak.initializeGridAgents` |
| Simulation | `outbreak.runGridScenario` |
| Validation | `tests/runAllTests.m` |
| Primary outputs | `results/outbreak_origin_scenarios` |
| Final tracked deliverables | `output/` |

The framework exports population time series, final agents, floor metrics, occupancy and infection matrices, heat-map atlases, elevator and stair queue summaries, scenario comparisons, replicated-run summaries, layout previews, and MP4 animations. Detailed run data are reproducible and ignored by Git; the final reports and selected presentation artifacts are tracked under `output/`.
