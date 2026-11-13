# Initial Planning and Modeling Workflow

## 1. Objective

Develop a reproducible MATLAB agent-based simulation that compares how evacuation timing affects infection and successful escape during a fictional outbreak inside FEU Tech. The final model will represent 4,000 agents moving across 16 physical levels over 24 simulated hours.

## 2. Requirements baseline

| Requirement | Current decision | Verification |
|---|---|---|
| Population | 4,000 agents | Initialization test and conservation test |
| Initial categories | 1 Infected, 3,999 Non-Infected, 0 Escaped | Initialization test |
| Duration | 24 hours | Configuration check |
| Time step | 10 minutes | 144 model updates |
| Building | 16 physical levels | Floor metadata validation |
| Agent categories | Infected, Non-Infected, Escaped | State-domain validation |
| Scenarios | Baseline, Early Evacuation, Delayed Evacuation | Scenario output files |
| Platform | MATLAB R2026a, base MATLAB only | Batch execution in VS Code |

## 3. Deliverable-driven workflow

### Phase 1 — Freeze the model specification

1. Reconcile the original proposal with the revised 16-level, 24-hour scope.
2. Approve the research question and experiment comparison.
3. Approve state definitions and permitted transitions.
4. Approve or source movement, infection, evacuation, and capacity parameters.
5. Record every unsupported value as a provisional modeling assumption.

**Deliverables**

- Approved model specification
- Parameter dictionary with units, rationale, and status
- Scenario configuration table
- Assumptions and limitations register

**Gate 1:** No core parameter remains undocumented.

### Phase 2 — Build the environment datasets

1. Inventory the 16 levels and their functions.
2. Preserve the original floor-plan sources separately from simulation grids.
3. Digitize one available level as a pilot occupancy grid.
4. Define grid codes for walls, walkable cells, rooms, stairs, elevators, exits, and special areas.
5. Verify vertical links and ground-level evacuation destinations.
6. Create simplified layouts for missing plans only when necessary, labeling them as assumptions.

**Deliverables**

- `floor_metadata.csv`
- `floor_occupancy.csv`
- `floor_connections.csv`
- `floor_exits.csv`
- Sixteen grid matrices in a future `data/grids/` directory
- Source-to-grid traceability notes

**Gate 2:** Every walkable region can reach a valid connector or exit, and every modeled feature has a source or stated assumption.

### Phase 3 — Implement a single-floor prototype

1. Place a reduced population on one pilot grid.
2. Implement valid-cell movement and collision handling.
3. Implement Non-Infected to Infected transitions.
4. Implement Non-Infected to Escaped transitions at valid exits.
5. Record category counts each time step.

**Deliverables**

- Working movement engine
- Infection engine
- Evacuation engine
- Time-series logger
- Automated population conservation test

**Gate 3:** The prototype completes reproducibly without invalid positions or population loss.

### Phase 4 — Integrate all levels

1. Load all 16 grids.
2. Connect stairs and approved vertical routes.
3. Add queues and capacities for connectors and exits.
4. Allocate all 4,000 agents using `floor_occupancy.csv`.
5. Validate path availability from every occupied floor.

**Deliverables**

- Unified building model
- Inter-floor movement logic
- Capacity and bottleneck handling
- Full-population initialization

**Gate 4:** All 4,000 agents initialize on valid cells and all floors participate in a complete run.

### Phase 5 — Execute the three experiments

1. Keep building, population, infection rules, initial infected location, and seed policy consistent.
2. Run Baseline with no organized evacuation.
3. Run Early Evacuation using the approved early start time.
4. Run Delayed Evacuation using the approved delayed start time.
5. Repeat each scenario over an approved set of random seeds.

**Deliverables**

- Per-run time-series files
- Final category counts and percentages
- Floor-level infection and escape results
- Seed and configuration manifest

**Gate 5:** Runs are reproducible, complete, and directly comparable.

### Phase 6 — Analyze and present results

1. Plot Infected, Non-Infected, and Escaped counts over time.
2. Compare final survivability across scenarios.
3. Compare infections and successful escape by initial floor.
4. Summarize variability across repeated runs.
5. Produce the animation and final statistical tables.
6. Document conclusions, assumptions, and limitations.

**Deliverables**

- Animated building simulation
- Population progression graph
- Floor infection comparison
- Floor survivability comparison
- Scenario comparison chart
- Repeated-run variability plot
- Final report, presentation, source package, and demonstration script

**Gate 6:** Every stated conclusion is supported by a generated output and limited to the modeled assumptions.

## 4. Immediate work queue

1. Review and approve the provisional values in `config/defaultConfig.m`.
2. Confirm Early Evacuation and Delayed Evacuation start times.
3. Verify staircase, elevator, and ground-exit information.
4. Select the first available floor plan to digitize as the pilot grid.
5. Replace the current floor-level movement approximation with grid-based pathfinding.
6. Decide the number of repeated runs and seed policy for final experiments.

## 5. Definition of technical completion

- All 16 levels have validated model representations.
- Exactly 4,000 agents are present throughout each run.
- Only valid state transitions occur.
- All three scenarios run for 24 simulated hours.
- Batch runs are reproducible from MATLAB and VS Code.
- Required CSV results, figures, and animations are generated.
- Assumptions are clearly separated from verified building information.

