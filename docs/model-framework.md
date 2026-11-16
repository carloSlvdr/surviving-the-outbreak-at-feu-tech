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
| Validation | `tests/run_all_tests.m` |
| Primary outputs | `results/authoritative_scenarios` |

The framework exports population time series, final agents, floor metrics, occupancy and infection matrices, heat-map atlases, elevator and stair queue summaries, scenario comparisons, and replicated-run summaries.
