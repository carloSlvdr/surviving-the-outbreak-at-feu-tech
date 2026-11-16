# Surviving the Outbreak at FEU Tech

**An Agent-Based Simulation of a Zombie Outbreak**

This repository implements a MATLAB agent-based model of infection spread and evacuation across FEU Tech. It models 15 occupied levels spatially and treats the garage-level ground floor only as an abstract evacuation endpoint.

## Fixed project scope

- 4,000 agents
- 16 physical levels
- 24 simulated hours
- 10-minute time step, producing 144 updates
- Three mutually exclusive states: `Infected`, `Non-Infected`, and `Escaped`
- Three scenarios: Baseline, Early Evacuation, and Delayed Evacuation

The current code includes a **spatial grid simulation** with plan-guided floor schematics, cell movement, contact infection, stair descent, evacuation, scenario execution, and conservation checks.

## Run the project

From MATLAB:

```matlab
cd('C:\Users\John Carlo\Documents\ChatGPT\ModSimFinalProject\Surviving the Outbreak at FEU Tech')
runProject
```

From the VS Code terminal:

```powershell
matlab -batch "runProject"
```

Run validation tests:

```powershell
matlab -batch "run('tests/run_all_tests.m')"
```

Build the 16-floor spatial framework:

```powershell
matlab -batch "buildModelFramework"
```

Run the spatial grid scenarios:

```powershell
matlab -batch "runGridProject"
```

Generated CSV summaries and PNG charts are written to `results/`.

The spatial run also generates, for every scenario:

- Cumulative occupancy heat-map atlas for all 15 occupied levels
- Cumulative infected-presence heat-map atlas
- Floor population-over-time heat map
- Cumulative stair-traffic chart
- Floor-level spatial and time-series CSV tables
- Raw occupancy and infected-visit matrices for every level
- A split-scale comparison of final outcomes across all scenarios

## Project map

| Path | Purpose |
|---|---|
| `docs/project-deliverables-outline.md` | Complete deliverables checklist and acceptance conditions |
| `docs/initial-planning-and-workflow.md` | Requirements-driven development plan and completion gates |
| `docs/model-framework.md` | Spatial framework architecture, grid contract, and next steps |
| `docs/model-specification.md` | Current mathematical and behavioral specification |
| `data/` | Floor, population, connection, exit, and scenario datasets |
| `references/` | Instructions for private local proposal and floor-plan references |
| `config/defaultConfig.m` | Centralized provisional modeling parameters |
| `src/+outbreak/` | MATLAB simulation package |
| `tests/` | Automated model checks |
| `.vscode/` | MATLAB-aware VS Code settings and tasks |

## Important modeling rule

At every time step:

```text
Infected + Non-Infected + Escaped = 4,000
```

All numerical behavior parameters are centralized and marked provisional until the group approves or sources them. Architectural assumptions must remain distinguishable from verified floor-plan information.

The supplied plans now support plan-derived schematics for all 15 occupied levels (2nd–12th and 14th–17th; FEU Tech has no 13th-floor label). The ground-floor garage is excluded from occupancy and represented only by a minimal evacuation sink. Source floor-plan images and architectural PDFs remain private and are intentionally excluded from the public GitHub repository.

