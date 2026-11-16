# Model Framework

## Purpose

The framework separates the building, agents, behavior, simulation control, experiments, validation, and outputs. This allows later architectural refinements without rewriting the population or scenario logic.

## Framework layers

| Layer | Responsibility | Current implementation |
|---|---|---|
| Configuration | Fixed scope and provisional parameters | `config/defaultConfig.m` |
| Input data | Floors, occupancy, connections, exits, scenarios | `data/*.csv` |
| Building | Sixteen floor grids and vertical connections | `outbreak.buildBuildingModel` |
| Agents | State and valid spatial placement | `outbreak.initializeGridAgents` |
| Behavior | Grid movement, stair descent, contact infection, and exits | `outbreak.runGridScenario` |
| Simulation | Time stepping and conservation | `outbreak.runScenario` and `outbreak.runGridScenario` |
| Experiments | Three scenario execution | `runProject.m` and `runGridProject.m` |
| Validation | Input, building, placement, and reproducibility checks | `tests/run_all_tests.m` |
| Outputs | CSV tables, population charts, spatial heat maps, and congestion figures | `outbreak.writeScenarioOutputs` and `outbreak.writeGridScenarioOutputs` |

## Occupancy-grid codes

| Code | Meaning | Traversable |
|---:|---|:---:|
| 0 | Wall or inaccessible space | No |
| 1 | Walkable corridor | Yes |
| 2 | Room or occupied area | Yes |
| 3 | Staircase | Yes |
| 4 | Elevator | Yes, subject to the final scenario rules |
| 5 | Evacuation exit | Yes |
| 6 | Special area | Yes |

## Current building status

The framework generates all 16 required level records and validates their spatial structure. All 15 occupied levels use plan-derived schematics based on the supplied evacuation maps. The ground-floor garage has no starting agents and is represented only by an `Abstract evacuation sink` that connects the final stair transition to an exit.

Plan-derived schematics preserve major circulation zones, room bands, open areas, cores, obstacles, and opposing fire-exit stairs visible in the supplied drawings, but they are not scale architectural reproductions. Connector coordinates are normalized across floors for the simulation contract and documented in `data/floor_plan_traceability.csv`.

If a drawing is later traced at architectural scale, its grid can replace the matching schematic while preserving the floor index, cell-code convention, connectors, exits, source, and verification metadata.

## Agent data contract

Each agent has a unique ID, floor index, grid row and column, state code, and initial floor index. Active agents must occupy traversable cells. Escaped agents are removed from the active grid but remain in population totals and time-series results.

## Framework build command

```matlab
buildModelFramework
```

This command loads and validates the datasets, builds 15 plan-derived occupied-floor grids and one abstract exit sink, validates their structure and reachability, places all 4,000 agents above ground, and saves the model assets and a visual preview.

## Current modeling boundary

Neighbor-cell movement, pathfinding, stair descent, contact infection, the `Escaped` transition, spatial heat maps, floor-time metrics, and stair-traffic outputs are implemented. Remaining refinement work is calibration: architectural-scale tracing, measured connector and exit capacities, empirically supported infection/movement parameters, queue-based congestion metrics, and presentation-quality animation.

