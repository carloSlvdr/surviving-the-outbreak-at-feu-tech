# Surviving the Outbreak at FEU Tech

MATLAB agent-based infection and evacuation simulation using the authoritative hand-drawn floor plans.

## Current scope

- 15 physical floors: 1-12 and 14-16
- 24 simulated hours at 10-minute state updates
- independently generated room occupancy with a recorded seed
- Non-Infected, Infected, and Escaped categories
- Three controlled outbreak-origin scenarios: Floor 2 Student Plaza, Floor 8 Canteen, and a random Floor 16 office
- Entrapment pressure after four unsuccessful evacuation hours: bite risk increases by 3 percentage points per hour up to 75%, while still requiring an adjacent infected agent
- two authorized escape boundaries: Floor-2 Student Plaza and provisional Floor-1 exit
- regular elevators, emergency stairs, and the green-box elevator modeled separately
- aggressive infected movement and pursuit with a 12% adjacency-based bite probability
- guaranteed infection after a successful bite, capped at 35% bite probability per update

Floors 13 and 17 are not part of the model. Floor 12 has no initial room population because its supplied drawing is mislabeled. Floor 1 is provisional because no drawing was supplied.

## Run

From MATLAB in this repository:

```matlab
runGridProject
```

Or from a terminal:

```powershell
matlab -batch "run('runGridProject.m')"
```

Run validation:

```powershell
matlab -batch "run('tests/run_all_tests.m')"
```

Run the three-seed comparison:

```powershell
matlab -batch "run('runReplications.m')"
```

Outputs are written to `results/authoritative_scenarios`.

## Important limitation

The grids preserve topology and relative room placement from the drawings, but no architectural scale was supplied. Walking times, inferred doors, connector geometry, transmission parameters, and the Floor-1 exit path remain provisional. See `data/geometry_evidence.csv` and `docs/migration-record.md`.
