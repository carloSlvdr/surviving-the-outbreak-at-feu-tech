# Surviving the Outbreak at FEU Tech

Agent-based MATLAB simulation of a fictional zombie outbreak inside FEU Tech. The model compares how the initial infected location changes infection spread, congestion, vertical movement, and evacuation outcomes.

## Submission status

The repository is ready for submission as of 2026-11-18. The automated model tests pass for the recorded 3,713-agent primary population, and the final report, figures, layouts, and three scenario animations are available under `output/`.

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
matlab -batch "run('tests/run_all_tests.m')"
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

## Main entry points

| File | Purpose |
|---|---|
| `runGridProject.m` | Validate and run all three scenarios and animations |
| `runReplications.m` | Run the recorded three-seed comparison |
| `buildModelFramework.m` | Build and validate the environment without running full scenarios |
| `exportFloorLayoutPreviews.m` | Export the floor-layout atlas and individual layouts |
| `regenerateSpatialOutputs.m` | Recreate spatial figures from recorded scenario data |
| `createConclusiveVisualizations.m` | Create the final comparison dashboard and analysis data |
| `tests/run_all_tests.m` | Execute the authoritative automated checks |
| `scripts/createCompleteAnalysisReport.py` | Rebuild the Word report from current results and tracked figures |

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

## Final deliverables

- `output/documents/Surviving_the_Outbreak_at_FEU_Tech_Complete_Model_Analysis.docx`
- `output/pdf/Surviving_the_Outbreak_at_FEU_Tech_Complete_Model_Analysis.pdf`
- `output/analysis/conclusive-analysis.md`
- `output/analysis/outbreak_origin_conclusive_dashboard.png`
- `output/layouts/all_floor_layout_atlas.png`
- `output/animation/second_floor_outbreak.mp4`
- `output/animation/eighth_floor_outbreak.mp4`
- `output/animation/sixteenth_floor_outbreak.mp4`

The complete delivery inventory and final verification steps are in `docs/submission-checklist.md`.

## Important interpretation limits

- The 40-by-60 floor grids preserve topology and relative placement, not architectural scale.
- Bite, pursuit, movement, stair, elevator, and exit parameters are provisional simulation assumptions.
- Only three replication seeds are included; at least 30 are recommended for formal uncertainty estimates.
- The current implementation can classify infected agents as `Escaped`; escape counts are therefore not confirmed survivor counts.
- Regular elevator capacity is aggregated by source floor instead of tracking individual cars.
- Entrapment pressure uses global elapsed evacuation time rather than each agent's personal waiting time.

See `docs/model-factors-criteria-and-facts.md` for the full authoritative parameter record and `output/analysis/conclusive-analysis.md` for the supported findings.
