# Surviving the Outbreak at FEU Tech

Agent-based MATLAB simulation of a fictional zombie outbreak inside FEU Tech. The model compares how the initial infected location changes infection spread, congestion, vertical movement, and evacuation outcomes.

## Submission status

The repository was re-audited and is ready for submission as of 2026-11-20. The automated model tests pass for the recorded 3,713-agent primary population, and the final report, figures, layouts, and three scenario animations are available under `output/`.

This is a comparative academic simulation, not an operational emergency plan. Building dimensions, transport capacities, movement behavior, and transmission probabilities remain modeling assumptions unless explicitly identified as drawing-derived facts.

## Current model

- 15 physical levels: Ground Floor, Floors 2-12, and Floors 14-16
- 14 initially occupied levels; the Ground Floor is an unoccupied garage/exit path
- 3,713 agents in the primary recorded seed (`20261116`)
- 24 simulated hours with 10-minute updates (144 steps)
- final categories: `Non-Infected`, `Infected`, and `Escaped`
- one initial infected agent per scenario
- three controlled origins: Floor 2 Student Plaza, Floor 8 Canteen, and a random Floor 16 office
- common Hour-1 evacuation start in all scenarios
- stairs, eight regular elevators, and the green elevator represented separately
- adjacency-based bite transmission with entrapment pressure after four evacuation hours

Floors 13 and 17 are excluded. Floor 12 is a user-directed derivation of the revised Floor 11 plan and is clearly marked as not independently verified. Floor 1 is provisional because no authoritative Ground Floor drawing was supplied.

## Latest recorded model outcomes

Every scenario starts with the same 3,713-agent primary population. At the end of a run, each agent belongs to exactly one reporting category: `Infected`, `Non-Infected`, or `Escaped`.

| Initial infected location | Infected | Non-Infected | Escaped | Infection rate | Escape rate |
|---|---:|---:|---:|---:|---:|
| Floor 2 - Student Plaza | 774 | 2,853 | 86 | 20.85% | 2.32% |
| Floor 8 - Canteen | 2,881 | 591 | 241 | 77.59% | 6.49% |
| Floor 16 - Office | 3,204 | 300 | 209 | 86.29% | 5.63% |

Under the current assumptions, the Floor 16 origin produces the most severe outbreak. The Floor 8 origin is also severe, while the Floor 2 origin produces the lowest infection burden because it begins near an authorized exit and below most occupants.

`Escaped` currently measures modeled exit throughput. The implementation permits an infected agent to become `Escaped`, so this category must not be interpreted as confirmed uninfected survivors.

## Generated model outputs

The primary workflow writes detailed reproducible results to `results/outbreak_origin_scenarios/`.

### Overall comparison files

| File | Contents |
|---|---|
| `scenario_comparison.csv` | Final population categories and escape rate for all three scenarios |
| `scenario_outcome_comparison.png` | Primary-run comparison graph |
| `room_occupancy_draws.csv` | Seeded generated occupancy for every modeled room or area |
| `building_validation.csv` | Floor, room-reachability, and geometry validation results |

### Files produced for each scenario

Each scenario directory contains:

- `final_summary.csv` - final Infected, Non-Infected, and Escaped totals;
- `final_agents.csv` - final state and grid position of every agent;
- `population_timeseries.csv` - population categories at every 10-minute update;
- `population_progression.png` - infection and evacuation progression graph;
- `spatial/floor_spatial_summary.csv` - summarized floor exposure, queues, and transfers;
- `spatial/floor_time_metrics.csv` - floor-level population and queues over time;
- `spatial/spatial_metrics.mat` - complete saved spatial metrics for MATLAB reuse;
- `spatial/occupancy_heatmap_atlas.png` - cumulative agent cell visits;
- `spatial/infected_presence_heatmap_atlas.png` - cumulative infected cell visits;
- `spatial/floor_population_over_time_heatmap.png` - active population by floor and time;
- `spatial/transport_and_queue_summary.png` - stair and elevator throughput and peak queues;
- `spatial/matrices/` - per-floor occupancy-visit and infected-visit CSV matrices.

### Final animations and analysis artifacts

The tracked submission outputs include:

- `output/animation/second_floor_outbreak.mp4`;
- `output/animation/eighth_floor_outbreak.mp4`;
- `output/animation/sixteenth_floor_outbreak.mp4`;
- `output/analysis/normalized_scenario_summary.csv`;
- `output/analysis/outbreak_origin_conclusive_dashboard.png`;
- `output/layouts/all_floor_layout_atlas.png` and the individual floor previews;
- the complete Word report under `output/documents/`;
- the matching PDF report under `output/pdf/`.

Running `runReplications` additionally produces the recorded three-seed outcomes, scenario means, standard deviations, and replication comparison graph under `results/outbreak_origin_scenarios/`.

## Requirements

- MATLAB (tested with R2026a)
- a writable project directory for generated `results/`
- no external MATLAB libraries are required

Regenerating the optional Word report requires Python 3.10 or newer and the package listed in `scripts/requirements-report.txt`. The completed DOCX and PDF are already included, so Python is not required to run or submit the MATLAB model.

VS Code users can install the recommended MathWorks MATLAB extension and use the tasks in `.vscode/tasks.json`.

## Quick start

Open MATLAB in the repository root and run:

```matlab
runGridProject
```

Or run from PowerShell:

```powershell
matlab -batch "runGridProject"
```

This command validates the model, executes all three 24-hour scenarios, writes detailed outputs to `results/outbreak_origin_scenarios/`, and creates one MP4 animation per scenario in `output/animation/`.

## Validation and reproducibility

Run the automated tests:

```powershell
matlab -batch "run('tests/runAllTests.m')"
```

Expected final message:

```text
All authoritative model tests passed for 3713 generated agents.
```

Run the recorded three-seed comparison:

```powershell
matlab -batch "runReplications"
```

Regenerate the final visual analysis after the scenario outputs exist:

```powershell
matlab -batch "createConclusiveVisualizations"
```

The primary seed is stored in `config/defaultConfig.m`. Replication seeds are stored in `runReplications.m`.

## Project-level MATLAB scripts

| File | Purpose |
|---|---|
| `runGridProject.m` | Primary workflow. Loads inputs, validates the 15-level building, runs the three outbreak-origin scenarios, exports tables and figures, and writes one MP4 animation per scenario. |
| `runReplications.m` | Runs the three recorded random seeds, exports per-run outcomes, calculates scenario means and standard deviations, and creates the replication comparison graph. |
| `buildModelFramework.m` | Builds and validates the floor grids, generates the seeded room occupancy, initializes agents, and saves framework diagnostics without running the 24-hour scenarios. |
| `exportFloorLayoutPreviews.m` | Exports one static image for each modeled floor and the combined 15-floor layout atlas. |
| `regenerateSpatialOutputs.m` | Rebuilds heat maps, floor-time plots, and transport/queue charts from the saved current outbreak-origin metrics. It requires a completed `runGridProject` run. |
| `createConclusiveVisualizations.m` | Reads the primary and replicated outcomes, creates normalized scenario statistics, and exports the final four-panel comparison dashboard. |
| `tests/runAllTests.m` | Runs the authoritative automated checks for configuration, geometry, occupancy, elevator margins, bite probability, conservation, and fixed-seed replay. |

## Configuration function

| File | Function |
|---|---|
| `config/defaultConfig.m` | Returns the authoritative configuration structure, including duration, time step, random seed, physical floors, state and cell codes, movement probabilities, bite rules, entrapment settings, and connector capacities. |

## MATLAB package functions

All functions below are called through the `outbreak` namespace.

| File | Function |
|---|---|
| `src/+outbreak/loadProjectData.m` | Loads floor metadata, room inventory, scenarios, floor connections, and exit definitions from the tracked CSV files. |
| `src/+outbreak/validateInputs.m` | Enforces the 15-level input contract, prohibited floors, room ranges, floor sequence, and scenario definitions. |
| `src/+outbreak/buildBuildingModel.m` | Constructs the building structure and one normalized grid and room map for every modeled level. |
| `src/+outbreak/createPlanDerivedGrid.m` | Creates drawing-derived 40-by-60 grids, rooms, corridors, stairs, eight regular elevators, the green elevator, and exits. |
| `src/+outbreak/validateBuildingModel.m` | Checks grid dimensions, valid cell codes, room reachability, connector presence, exits, and the ordered physical-floor sequence. |
| `src/+outbreak/generateRoomOccupancy.m` | Draws reproducible room populations within each configured minimum and maximum range. |
| `src/+outbreak/initializeGridAgents.m` | Places agents in their assigned room cells and selects the scenario's initial infected agent from an eligible occupied space. |
| `src/+outbreak/computeDistanceMap.m` | Computes four-neighbor shortest-path distance fields used for evacuation and infected pursuit. |
| `src/+outbreak/computeBiteProbability.m` | Combines adjacent-infected bite opportunities with the cap and time-dependent entrapment increase. |
| `src/+outbreak/runGridScenario.m` | Executes movement, connector transfers, infection, exits, state recording, spatial metrics, and population-conservation checks for one scenario. |
| `src/+outbreak/writeScenarioOutputs.m` | Writes one scenario's time series, final summary, and population-progression chart. |
| `src/+outbreak/writeGridScenarioOutputs.m` | Writes per-floor matrices, heat-map atlases, floor-time metrics, and transport/queue diagnostics. |
| `src/+outbreak/writeScenarioComparison.m` | Creates the primary-run cross-scenario outcome comparison. |
| `src/+outbreak/writeScenarioAnimation.m` | Renders recorded agent histories into the final all-floor MP4 animation. |

## Optional report utility

| File | Purpose |
|---|---|
| `scripts/createCompleteAnalysisReport.py` | Rebuilds the Word analysis report from the current MATLAB results and tracked figures. |

## Repository structure

| Path | Contents |
|---|---|
| `config/` | Simulation parameters and cell codes |
| `data/` | Floor metadata, room inventory, scenarios, exits, and connectivity |
| `src/+outbreak/` | Agent-based model implementation |
| `tests/` | Automated conservation, geometry, connector, and replay tests |
| `docs/` | Model specification, criteria, workflow, migration history, and submission checklist |
| `output/` | Final tracked reports, figures, layouts, and animations |
| `results/` | Detailed generated runs; intentionally ignored by Git because they are reproducible |
| `references/private/` | Local source plans and proposal; intentionally excluded from the public repository |

## Important interpretation limits

- The 40-by-60 floor grids preserve topology and relative placement, not architectural scale.
- Bite, pursuit, movement, stair, elevator, and exit parameters are provisional simulation assumptions.
- Only three replication seeds are included; at least 30 are recommended for formal uncertainty estimates.
- The current implementation can classify infected agents as `Escaped`; escape counts are therefore not confirmed survivor counts.
- Regular elevator capacity is aggregated by source floor instead of tracking individual cars.
- Entrapment pressure uses global elapsed evacuation time rather than each agent's personal waiting time.

See `docs/model-factors-criteria-and-facts.md` for the full authoritative parameter record and `output/analysis/conclusive-analysis.md` for the supported findings.
