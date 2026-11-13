# Surviving the Outbreak at FEU Tech

**An Agent-Based Simulation of a Zombie Outbreak**

This repository is the initial implementation foundation for a MATLAB agent-based model of infection spread and evacuation across 16 physical levels of FEU Tech.

## Fixed project scope

- 4,000 agents
- 16 physical levels
- 24 simulated hours
- 10-minute time step, producing 144 updates
- Three mutually exclusive states: `Infected`, `Non-Infected`, and `Escaped`
- Three scenarios: Baseline, Early Evacuation, and Delayed Evacuation

The current code is a **floor-level vertical slice**, not the final grid simulation. It validates the population model, state transitions, scenario runner, result export, and conservation rule while detailed floor grids are still being prepared.

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

The supplied plans currently support six plan-derived schematic levels. The remaining ten levels use labeled placeholders. Private architectural PDFs are intentionally excluded from the public GitHub repository.

