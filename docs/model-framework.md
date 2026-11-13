# Model Framework

## Purpose

The framework separates the building, agents, behavior, simulation control, experiments, validation, and outputs. This allows verified floor grids to replace placeholders without rewriting the population or scenario logic.

## Framework layers

| Layer | Responsibility | Current implementation |
|---|---|---|
| Configuration | Fixed scope and provisional parameters | `config/defaultConfig.m` |
| Input data | Floors, occupancy, connections, exits, scenarios | `data/*.csv` |
| Building | Sixteen floor grids and vertical connections | `outbreak.buildBuildingModel` |
| Agents | State and valid spatial placement | `outbreak.initializeGridAgents` |
| Behavior | Movement, infection, evacuation | Floor-level prototype exists; grid behavior is next |
| Simulation | Time stepping and conservation | `outbreak.runScenario` |
| Experiments | Three scenario execution | `runProject.m` |
| Validation | Input, building, placement, and reproducibility checks | `tests/run_all_tests.m` |
| Outputs | CSV tables and figures | `outbreak.writeScenarioOutputs` |

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

The framework can generate all 16 required floor records and validate their spatial structure. The generated grids are explicitly marked `Placeholder generated framework`. They provide a working software contract, not architectural representations of FEU Tech.

When an actual plan is digitized, its grid can replace the matching placeholder while preserving the floor index, floor label, cell-code convention, connectors, exits, source, and verification metadata.

## Agent data contract

Each agent has a unique ID, floor index, grid row and column, state code, and initial floor index. Active agents must occupy traversable cells. Escaped agents are removed from the active grid but remain in population totals and time-series results.

## Framework build command

```matlab
buildModelFramework
```

This command loads and validates the datasets, builds all 16 placeholder grids, validates their structure and reachability, places all 4,000 agents, and saves the model assets and a visual preview.

## Next implementation step

1. Neighbor-cell movement and collision policy
2. Shortest-path movement toward stairs and exits
3. Stair queues and floor transitions
4. Contact-based infection on neighboring cells
5. Exit capacity and Escaped transition
6. Congestion measurements and animation

