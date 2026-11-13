# Initial Model Specification

## State model

Each agent has one mutually exclusive state:

| Code | State | Meaning |
|---|---|---|
| 1 | Non-Infected | Inside the building and susceptible |
| 2 | Infected | Infected and capable of transmitting infection |
| 3 | Escaped | Evacuated while Non-Infected and removed from exposure |

Allowed transitions are:

```text
Non-Infected -> Infected
Non-Infected -> Escaped
```

Infected agents do not become Escaped in the initial model. Recovery and mortality are outside the current scope.

## Population invariant

For every simulation time `t`:

```text
I(t) + N(t) + E(t) = 4,000
```

## Time model

- Duration: 24 hours
- Step size: 10 minutes
- Updates: 144
- Logged observations: 145, including the initial state at time zero

## Current floor-level approximation

The initial executable model represents each agent's physical location by a floor index. Normal movement may shift an active agent to an adjacent level. During organized evacuation, Non-Infected agents preferentially move one level toward the Ground Floor. Non-Infected agents on the Ground Floor may transition to Escaped.

This approximation validates workflow and state logic. It must be replaced by cell-level movement after occupancy grids and verified connections are available.

## Provisional infection rule

For a susceptible agent on floor `f` during one time step:

```text
p_infection(f) = min(p_max, beta * infected_on_floor / active_on_floor)
```

`beta` and `p_max` are provisional experiment parameters, not empirical predictions.

## Scenario controls

| Scenario | Organized evacuation | Provisional start |
|---|---:|---:|
| Baseline | No | Not applicable |
| Early Evacuation | Yes | Hour 1 |
| Delayed Evacuation | Yes | Hour 6 |

The two start times are working values and must be approved before final experiments.

## Validation rules

- Population count remains exactly 4,000.
- Initial counts are 1 Infected, 3,999 Non-Infected, and 0 Escaped.
- Status values remain in the set `{1, 2, 3}`.
- Floor indices remain between 1 and 16 for active agents.
- Escaped agents never return to the active environment.
- Category time series never contain negative counts.
- Re-running with the same seed reproduces the same result.

