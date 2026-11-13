# Project Deliverables Outline

## Project title

**Surviving the Outbreak at FEU Tech: An Agent-Based Simulation of a Zombie Outbreak**

## Deliverable 1 — Project definition and approved scope

### Required contents

1. Final project title
2. Background and project rationale
3. Problem statement
4. Research question
5. General and specific objectives
6. Scope and limitations
7. Final simulation boundaries:
   - 16 physical levels
   - 4,000 agents
   - 24 simulated hours
   - 10-minute time step
   - Infected, Non-Infected, and Escaped categories
   - Baseline, Early Evacuation, and Delayed Evacuation scenarios

### Completion condition

The report and proposal use one consistent scope, and any difference from the original proposal is documented and approved.

---

## Deliverable 2 — Model specification and assumptions

### Required contents

1. Agent definition and attributes
2. Population state definitions
3. Permitted state transitions
4. Time-step and simulation-duration rules
5. Human movement behavior
6. Infected-agent movement behavior
7. Infection-contact rule and probability
8. Evacuation behavior
9. Staircase, elevator, and exit rules
10. Queue and bottleneck behavior
11. Random-seed and repeated-run policy
12. Assumptions and limitations register
13. Parameter dictionary with value, unit, source, and approval status

### Completion condition

Every numerical value and behavioral rule used by MATLAB is defined, traceable, and classified as verified, sourced, or assumed.

---

## Deliverable 3 — Building environment package

### Required contents

1. Inventory of all 16 physical levels
2. Original floor-plan references
3. Source and assumption record for every level
4. Simplified occupancy grid for every level
5. Grid-value legend:
   - Wall or inaccessible area
   - Walkable area
   - Room or occupied area
   - Staircase
   - Elevator
   - Evacuation exit
   - Special-purpose area
6. Floor-to-floor connection map
7. Exit locations and capacities
8. Grid validation record

### Required files

- `floor_metadata.csv`
- `floor_occupancy.csv`
- `floor_connections.csv`
- `floor_exits.csv`
- Sixteen MATLAB grid files
- Source-to-grid traceability document

### Completion condition

All occupied locations have valid walking paths to a connector or approved exit, and assumed layouts are clearly separated from verified plans.

---

## Deliverable 4 — Population and scenario datasets

### Required contents

1. Allocation of exactly 4,000 agents across 16 levels
2. Initial population counts:
   - 1 Infected
   - 3,999 Non-Infected
   - 0 Escaped
3. Initial infected location rule
4. Agent placement method
5. Baseline scenario settings
6. Early Evacuation settings
7. Delayed Evacuation settings
8. Experiment seed list
9. Repeated-run count

### Required files

- `floor_occupancy.csv`
- `scenario_config.csv`
- Final parameter configuration
- Experiment manifest

### Completion condition

The datasets load without manual corrections, total exactly 4,000 agents, and reproduce the documented scenario settings.

---

## Deliverable 5 — MATLAB simulation software

### Required modules

1. Configuration loader
2. Dataset loader and validator
3. Building and grid initialization
4. Population initialization
5. Valid-cell agent placement
6. Normal movement engine
7. Evacuation pathfinding
8. Inter-floor movement
9. Infection-processing engine
10. Evacuation and exit processing
11. Queue and capacity handling
12. Time-series data logger
13. Scenario runner
14. Repeated-run controller
15. Visualization and animation engine
16. CSV, image, and video export

### Completion condition

The project runs from one documented command, completes all three scenarios, preserves all 4,000 agents, and exports the required results without manual intervention.

---

## Deliverable 6 — Verification and validation package

### Required tests

1. Population initialization test
2. Population conservation test
3. State-domain test
4. State-transition test
5. Valid-position test
6. Wall and obstacle collision test
7. Floor-connection test
8. Exit-processing test
9. Capacity and queue test
10. Scenario-configuration test
11. Random-seed reproducibility test
12. Full 24-hour execution test

### Required evidence

- Automated test results
- MATLAB Code Analyzer results
- Input-validation results
- Known limitations and unresolved validation items

### Completion condition

All critical tests pass, known exceptions are documented, and repeated execution with the same configuration produces the same outputs.

---

## Deliverable 7 — Experimental results

### Required experiments

1. Baseline scenario
2. Early Evacuation scenario
3. Delayed Evacuation scenario
4. Multiple runs for every scenario using controlled seeds

### Required measurements

1. Infected count over time
2. Non-Infected count over time
3. Escaped count over time
4. Final counts and percentages
5. Overall escape rate
6. Infection count by floor
7. Escape rate by initial floor
8. Evacuation completion time
9. Connector and exit congestion
10. Variation across repeated runs

### Completion condition

Every scenario has complete raw results, summary statistics, run metadata, and enough repeated runs for a defensible comparison.

---

## Deliverable 8 — Graphs, animation, and result presentation

### Required outputs

1. Animated 16-level building simulation
2. Population progression line graph
3. Final population comparison chart
4. Floor infection comparison
5. Floor survivability comparison
6. Overall survivability result
7. Scenario comparison chart
8. Repeated-run boxplot or variability plot
9. Final statistical summary table

### Visual conventions

- Red: Infected
- Blue: Non-Infected
- Green: Escaped
- Display current simulation time, selected floor, and category counts

### Completion condition

All visuals are generated directly from saved simulation results, contain readable labels and units, and do not use manually invented outcome values.

---

## Deliverable 9 — Final written report

### Proposed report outline

1. Title page
2. Abstract or executive summary
3. Introduction
4. Problem statement
5. Objectives and research question
6. Scope and limitations
7. Related concepts or literature
8. Modeling methodology
9. Building and population datasets
10. Agent behavior and algorithms
11. Scenario design
12. Verification and validation
13. Results
14. Discussion
15. Conclusions
16. Recommendations
17. References
18. Appendices

### Completion condition

The report explains the model well enough for another student to understand its assumptions, reproduce its runs, and connect every conclusion to a generated result.

---

## Deliverable 10 — Final submission and presentation package

### Required package

1. Final report
2. Presentation deck
3. MATLAB source code
4. Configuration files
5. Input datasets
6. Sixteen floor grids
7. Test suite and test evidence
8. Scenario results
9. Graphs and statistical tables
10. Simulation animation or recorded demonstration
11. Live demonstration script
12. README with setup and execution instructions

### Completion condition

The complete project can be transferred to another compatible computer, opened in MATLAB or VS Code, tested, executed, and presented using the included instructions.

---

## Current status summary

| Deliverable | Status |
|---|---|
| Project definition and scope | Draft established |
| Model specification and assumptions | Initial draft; parameters remain provisional |
| Building environment package | Metadata started; detailed grids pending |
| Population and scenario datasets | Initial synthetic datasets completed |
| MATLAB simulation software | Floor-level prototype operational |
| Verification and validation package | Initial automated tests operational |
| Experimental results | Prototype outputs generated; not final findings |
| Graphs and animation | Initial line graphs generated; full animation pending |
| Final written report | Initial development report available |
| Final submission package | Pending |

## Immediate next deliverable

Complete the **Model Specification and Assumptions** package, then digitize one verified floor plan as the pilot grid for the Building Environment Package.

