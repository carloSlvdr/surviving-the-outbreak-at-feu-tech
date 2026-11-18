# Model Factors, Criteria, and Facts

## Project identity

**Title:** *Surviving the Outbreak at FEU Tech: An Agent-Based Simulation of a Zombie Outbreak*

This document records the authoritative configuration of the current MATLAB model. It distinguishes implemented behavior, source-derived geometry, provisional assumptions, and issues that still require a modeling decision. The simulation is comparative and fictional; it is not an operational emergency plan.

## Current model scope

| Factor | Current setting |
|---|---|
| Simulation method | Grid-based agent-based model |
| Software | MATLAB |
| Duration | 24 simulated hours |
| Update interval | 10 simulated minutes |
| Total updates | 144 |
| Random seed | `20261116` |
| Grid per floor | 40 rows × 60 columns |
| Physical floor IDs | Ground Floor, Floors 2–12, and Floors 14–16 |
| Number of modeled levels | 15, including the Ground Floor |
| Initially occupied levels | 14; the Ground Floor has no initial occupants |
| Excluded floors | Floors 13 and 17 |
| Agent categories | Non-Infected, Infected, Escaped |
| Occupancy method | Independent inclusive integer draw for every occupied space |
| Current generated population | 3,713 agents |
| Allowed total from room ranges | 3,150–4,300 agents |

The project originally discussed an exact 4,000-agent scope. The current room-based configuration generates 3,713 agents with the recorded seed and therefore does not currently impose an exact 4,000-person total.

## Modeled floors and occupants

| Physical floor | Primary function | Occupied spaces | Minimum | Maximum | Generated |
|---:|---|---:|---:|---:|---:|
| Ground Floor | Garage and exit path | 0 | 0 | 0 | 0 |
| 2 | Student Plaza | 1 | 30 | 40 | 34 |
| 3 | Gym | 1 | 30 | 40 | 37 |
| 4 | Classrooms, clinic, and study areas | 11 | 330 | 440 | 401 |
| 5 | Classrooms and offices | 12 | 310 | 420 | 364 |
| 6 | Classrooms and study areas | 12 | 360 | 480 | 418 |
| 7 | Classrooms and engineering offices | 14 | 370 | 500 | 425 |
| 8 | Canteen | 1 | 80 | 100 | 92 |
| 9 | Classrooms and engineering faculty | 12 | 335 | 450 | 393 |
| 10 | Classrooms and computer engineering office | 13 | 365 | 490 | 420 |
| 11 | Classrooms, lounges, and study area | 14 | 380 | 520 | 443 |
| 12 | Floor-11-derived classrooms, lounges, and study area | 14 | 380 | 520 | 452 |
| 14 | Library | 1 | 80 | 100 | 99 |
| 15 | Offices | 9 | 45 | 90 | 57 |
| 16 | Offices | 11 | 55 | 110 | 78 |
| **Total** |  | **126** | **3,150** | **4,300** | **3,713** |

### Occupancy facts

- Every occupied space receives a reproducible independent draw between its minimum and maximum, inclusive.
- Agents are placed randomly in valid cells belonging to their assigned initial room or area.
- The same room draws are used when comparing the three outbreak-origin scenarios for a fixed random seed.
- Floor 12 uses the revised Floor 11 geometry by user direction but has distinct `F1201`–`F1212` room IDs, two distinct Floor 12 lounges, and independently generated occupants.
- Floor 15 and Floor 16 have smaller populations because their spaces are offices with 5–10 occupants rather than classrooms with 30–40 occupants.
- Floor 2 and Floor 8 are large open occupied areas, but their current population ranges are only 30–40 and 80–100 respectively.

## Scenario design

The former Baseline, Early Evacuation, and Delayed Evacuation comparison has been replaced by three outbreak-origin scenarios. All three use the same Hour-1 evacuation timing so the outbreak origin is the controlled independent variable.

| Scenario | Initial infected | Origin policy | Evacuation start |
|---|---:|---|---:|
| Second-Floor Outbreak | 1 | Random occupied Student Plaza position | Hour 1 |
| Eighth-Floor Outbreak | 1 | Random occupied Canteen position | Hour 1 |
| Sixteenth-Floor Outbreak | 1 | Random occupied Floor 16 office | Hour 1 |

Floor 2 and Floor 8 currently have no spaces classified as offices. Their scenario policies therefore use any occupied position in their designated large areas. Floor 16 selects from occupied office agents.

## Agent states

### Non-Infected

- Can move normally before evacuation.
- Uses exit-directed movement after evacuation begins.
- Can be bitten only by an orthogonally adjacent infected agent on the same floor.
- Becomes Infected after a successful bite.
- Becomes Escaped after authorized exit processing under the current implementation.

### Infected

- Moves more aggressively than a normal pre-evacuation agent.
- Usually pursues susceptible agents on the same floor when moving.
- Can use stairs and elevators after organized evacuation becomes active.
- Can transmit only through a successful adjacent bite.
- Newly infected agents begin transmitting on the next update, not during the same bite-resolution pass.
- Under the current implementation, an infected agent can also be converted to Escaped at an exit. This behavior is flagged for correction or confirmation.

### Escaped

- Is a terminal state.
- Has no active floor or grid position.
- No longer moves, queues, pursues, bites, or becomes infected.
- Is excluded from spatial occupancy and infection calculations.

## Movement criteria

All probabilities below are evaluated once per 10-minute update unless a connector transfer occurs first.

| Variable | Value | Operation |
|---|---:|---|
| Normal movement probability | 8% | Non-infected movement before evacuation |
| Evacuation movement probability | 70% | Exit-directed movement after evacuation begins |
| Infected movement probability | 65% | Probability that an infected agent attempts local movement |
| Infected pursuit probability | 75% | Conditional probability of shortest-path pursuit after an infected movement attempt |
| Neighborhood | Four-neighbor | Up, down, left, or right; no diagonal movement |
| Cell occupancy | One agent per cell | A move is rejected if the target cell is occupied |

### Movement facts

- Walls are impassable.
- Walkable, Room, Stair, Regular Elevator, Exit, Special, Door, and Green Elevator cells are traversable.
- Evacuating non-infected agents use precomputed distance maps toward connectors and authorized exits.
- Pursuing infected agents use same-floor distance maps toward susceptible agents.
- If an infected agent does not use pursuit, it selects a random valid neighboring cell.
- Connector processing occurs before ordinary local movement.
- Stair and elevator use is currently conditional on evacuation being active. Consequently, infected agents cannot change floors before Hour 1 in the three configured scenarios.

## Infection and bite criteria

| Variable | Value |
|---|---:|
| Bite probability per adjacent infected | 12% |
| Initial combined-bite cap | 35% per update |
| Infection after successful bite | 100% |
| Contact neighborhood | Four orthogonal adjacent cells |
| Cross-floor transmission | Not allowed |
| Diagonal transmission | Not allowed |
| Transmission through walls | Not allowed |
| Newly infected transmission | Begins on the following update |

For `n` adjacent infected agents, the initial bite probability is:

```text
P_base = min(0.35, 1 - (1 - 0.12)^n)
```

| Adjacent infected agents | Initial bite probability per update |
|---:|---:|
| 0 | 0% |
| 1 | 12.00% |
| 2 | 22.56% |
| 3 | 31.85% |
| 4 or more | 35.00% maximum before entrapment escalation |

A successful bite always produces infection because the infection-given-bite probability is 100%.

## Entrapment-pressure criteria

The model increases bite risk for susceptible agents who remain indoors after evacuation has been active for a prolonged period.

| Variable | Value |
|---|---:|
| Entrapment delay | 4 evacuation hours |
| Bite-risk growth | +3 percentage points per additional hour |
| Equivalent growth per update | +0.5 percentage points per 10-minute update |
| Entrapment bite cap | 75% per update |
| Adjacent infected still required | Yes |

The implemented probability is:

```text
growth_hours = max(0, hours_since_evacuation - 4)
P_bite = min(0.75, P_base + 0.03 * growth_hours)
```

Because evacuation begins at Simulation Hour 1, escalation begins after Simulation Hour 5. The increase is continuous across 10-minute updates. Elapsed time alone never creates an infection; at least one infected agent must still be orthogonally adjacent.

The timer is based on global elapsed evacuation time for every susceptible person still indoors. It does not separately record how long each agent has personally waited in a queue.

## Floor geometry criteria

| Cell code | Meaning |
|---:|---|
| 0 | Wall |
| 1 | Walkable hallway or open path |
| 2 | Occupied room or area |
| 3 | Stair |
| 4 | Regular elevator |
| 5 | Authorized exit |
| 6 | Special area |
| 7 | Door |
| 8 | Green elevator |

### Geometry facts

- Each floor uses a normalized 40 × 60 grid rather than a measured architectural scale.
- Room bands are reduced to preserve hallway margins around doors and elevators.
- No room or door cell is allowed inside the validated elevator safety margin.
- Upper and lower rooms open into reserved circulation areas.
- Right-side rooms are separated from the green elevator and right stair by a dedicated circulation bay.
- Floor 2 and Floor 8 distribute occupants across their full usable open-floor regions.
- Floor 14 uses an upper full-width Library region and a lower-right Library region.
- Floor 12 is explicitly derived from Floor 11 and is not independently verified.
- Floor 1 is provisional because no authoritative Ground Floor drawing was supplied.
- The grid represents topology and relative layout, not real-world distances, room areas, or walking speeds.

## Elevator criteria

### Regular elevators

| Variable | Value |
|---|---:|
| Number of cars/shafts | 8 |
| Layout | Six in the left bank and two in the middle bank |
| Capacity per car | 15 agents |
| Combined configured capacity | 120 agents per serviced floor and dispatch |
| Dispatch interval | Every 2 updates, or 20 simulated minutes |
| Movement | One floor downward per successful dispatch |
| Ground Floor service | Not modeled |

The eight regular elevator shafts occupy corresponding aligned grid positions on every upper floor.

### Green elevator

| Variable | Value |
|---|---:|
| Number of cars | 1 |
| Capacity | 15 agents |
| Dispatch interval | Every 3 updates, or 30 simulated minutes |
| Stops | Every modeled upper floor |
| Position | Beside the right-side stair |
| Destination | Direct transfer to the Ground Floor green-elevator area |

### Elevator limitation

Regular elevator capacity is currently applied independently on every source floor. The implementation can therefore treat the eight-car capacity as simultaneously available on multiple floors during one dispatch. It does not yet track individual elevator-car position, direction, boarding, travel time, or door operation. This is a known realism limitation.

## Stair and exit criteria

| Variable | Value |
|---|---:|
| Stair capacity | 24 agents per floor per 10-minute update |
| Stair movement | One sequence floor downward per successful transfer |
| Number of normalized stair approaches | Two per upper floor |
| Floor 2 exit capacity | 40 agents per 10-minute update |
| Ground Floor exit capacity | 30 agents per 10-minute update |

### Authorized escape boundaries

1. Floor 2 Student Plaza entrance/exit boundary.
2. Provisional Ground Floor exit reached through the green elevator path.

Exit processing currently accepts every non-escaped agent, including Infected agents. Restricting Escaped status to Non-Infected agents is a recommended pending correction.

## Update sequence

Every 10-minute simulation update uses the following order:

1. Determine whether organized evacuation is active.
2. Build same-floor infected pursuit fields toward susceptible agents.
3. Process stair and elevator transfers for agents already occupying connector cells.
4. Process local movement for remaining agents.
5. Count adjacent infected agents for every susceptible agent.
6. Apply base and entrapment-adjusted bite probabilities.
7. Convert successful bite victims to Infected simultaneously.
8. Process authorized exits when evacuation is active.
9. Record population counts, spatial occupancy, infection presence, queues, and connector transfers.
10. Assert population conservation.

Movement occurs before bites, and bites occur before exit processing.

## Reproducibility and validation

- Random number generation uses MATLAB's Twister generator with seed `20261116` by default.
- Room occupancy draws are reproducible for a fixed seed.
- Initial placement and infected selection are reproducible for a fixed seed and scenario.
- Fixed-seed scenario replay is tested for identical time-series results.
- Population conservation is checked at every update.
- Room capacity ranges are validated.
- Every occupied room must be reachable.
- Every upper floor must contain eight regular elevator shafts and one green elevator.
- Elevator margins are validated to contain no Room or Door cells.
- Floor 11 and Floor 12 geometry must be exactly equal.
- Floors 13 and 17 are prohibited from the active physical-floor list.
- The current authoritative test suite passes for 3,713 generated agents.

## Generated and supported outputs

The framework can produce:

- Population time series for Non-Infected, Infected, and Escaped agents.
- New and cumulative bite-infection counts.
- Final agent-state tables.
- Per-floor population over time.
- Cumulative occupancy heat maps.
- Cumulative infected-presence heat maps.
- Stair, regular-elevator, and green-elevator transfer counts.
- Connector queue summaries.
- Cross-scenario comparison charts.
- Multi-seed scenario summaries.
- Static floor-layout images.
- Recorded agent-position animations.

The submitted analytical outputs were regenerated after the Floor 12 population and geometry changes. Historical outputs in older result directories are superseded; the supported analysis uses `results/outbreak_origin_scenarios` and the final artifacts in `output/`.

## Confirmed facts versus provisional assumptions

### Confirmed or user-directed

- The project title and zombie-outbreak subject.
- Outbreak origins on Floors 2, 8, and 16.
- One initial infected agent per scenario.
- Hour-1 evacuation is held constant across origin scenarios.
- Floors 13 and 17 are excluded.
- Ground Floor has no initial occupants.
- Floor 12 is derived from the revised Floor 11 plan.
- Eight regular elevators are represented on every upper floor.
- The green elevator is beside the right stair and serves every modeled upper floor.
- Aggressive infected behavior uses 65% movement and 75% pursuit.
- Bite probability begins at 12% per adjacent infected, with 100% infection after a successful bite.

### Provisional assumptions requiring calibration

- Ten-minute simulation update interval.
- All movement probabilities.
- Bite probabilities, caps, and entrapment-growth values.
- Room occupancy minimums and maximums.
- Grid scale and correspondence to physical distance.
- Walking speed and response delay.
- Stair, elevator, and exit capacities.
- Elevator dispatch intervals.
- Ground Floor geometry and exit route.
- Floor 8 Canteen interpretation despite conflicting source labels.
- Floor 12 geometry until an independently verified plan is supplied.

## Pending modeling decisions

1. **Exact population:** retain the room-generated 3,713 agents or scale to exactly 4,000.
2. **Infected at exits:** determine whether infected agents must remain Infected instead of becoming Escaped.
3. **Pre-evacuation vertical movement:** determine whether infected agents may use stairs before Hour 1.
4. **Elevator realism:** retain aggregated per-floor capacity or implement individual elevator-car trajectories.
5. **Entrapment tracking:** retain a global elapsed-time rule or track individual queue/wait duration.
6. **Calibration:** replace provisional probabilities and transport capacities with measured or sensitivity-tested values.
7. **Replication count:** use at least 30 seeds per scenario before making strong comparative infection claims.

## Authoritative source files

- Configuration: `config/defaultConfig.m`
- Scenario definitions: `data/scenario_config.csv`
- Room inventory and occupancy ranges: `data/room_inventory.csv`
- Floor metadata: `data/floor_metadata.csv`
- Geometry evidence: `data/geometry_evidence.csv`
- Floor connections: `data/floor_connections.csv`
- Exit definitions: `data/floor_exits.csv`
- Grid construction: `src/+outbreak/createPlanDerivedGrid.m`
- Agent initialization: `src/+outbreak/initializeGridAgents.m`
- Scenario execution: `src/+outbreak/runGridScenario.m`
- Bite calculation: `src/+outbreak/computeBiteProbability.m`
- Validation tests: `tests/run_all_tests.m`
