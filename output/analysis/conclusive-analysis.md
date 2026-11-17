# Conclusive Outbreak-Origin Analysis

## Analysis scope

This analysis compares three 24-hour outbreak-origin scenarios using the current 3,713-agent primary seed, 10-minute updates, a common Hour-1 evacuation start, and identical behavioral and transport settings. The only controlled scenario difference is whether the initial infected agent begins on Floor 2, Floor 8, or Floor 16.

## Primary-seed outcomes

| Outbreak origin | Infected | Infection rate | Non-Infected | Escaped | Escape rate |
|---|---:|---:|---:|---:|---:|
| Floor 2 | 774 | 20.85% | 2,853 | 86 | 2.32% |
| Floor 8 | 2,881 | 77.59% | 591 | 241 | 6.49% |
| Floor 16 | 3,204 | 86.29% | 300 | 209 | 5.63% |

## Three-seed results

| Outbreak origin | Mean infected ± SD | Mean escaped ± SD | Mean escape rate ± SD |
|---|---:|---:|---:|
| Floor 2 | 850.0 ± 74.5 | 115.0 ± 42.7 | 3.06% ± 1.10% |
| Floor 8 | 2,714.7 ± 653.6 | 193.0 ± 42.3 | 5.16% ± 1.18% |
| Floor 16 | 3,231.7 ± 88.8 | 217.7 ± 12.5 | 5.81% ± 0.35% |

The three seeds use independently drawn room populations of 3,713, 3,794, and 3,733 agents. Percentage-based comparisons are therefore more appropriate than counts alone.

## Temporal findings

- The Floor 2 primary run never reaches 25% infection during the 24-hour period. Its largest 10-minute increase is 35 infections at approximately Hour 23.33.
- The Floor 8 primary run reaches 25% infection at approximately Hour 20.33 and 50% at Hour 21.83. Its largest 10-minute increase is 133 infections near Hour 20.67.
- The Floor 16 primary run reaches 25% infection at approximately Hour 15.83 and 50% at Hour 17.17. Its largest 10-minute increase is 136 infections near Hour 16.67.
- The strongest infection acceleration occurs well after the Hour-5 entrapment threshold, when repeated adjacency receives progressively higher bite probability.

## Interpretation

### Floor 2 outbreak

The Floor 2 origin produces the lowest infection burden in every tested seed. In the current geometry, the outbreak begins on the same floor as the Student Plaza exit, while most occupants begin on higher floors. This limits early contact with the building-wide population. This is a model-based explanation, not a measured real-world conclusion.

### Floor 8 outbreak

The Floor 8 origin produces a severe but highly variable outbreak. Its three-seed infected-count standard deviation is 653.6, much larger than the other scenarios. The Canteen is an open occupied area located between heavily populated classroom levels, allowing the initial infection to access both downward evacuation traffic and occupants arriving through the transport core.

### Floor 16 outbreak

The Floor 16 origin is the most consistently severe scenario. It produces the highest mean infections and the smallest relative variation among the high-infection scenarios. Starting at the top forces infected agents and evacuees through the same downward connector sequence, increasing repeated contact opportunities across many floors before agents reach an exit.

## Supported conclusion

Within the present model, outbreak origin is a major determinant of infection severity. A Floor 16 origin is the highest-risk and most consistent of the three tested locations. A Floor 8 origin is also dangerous but more sensitive to random placement and movement. A Floor 2 origin produces substantially fewer infections because it begins near an authorized exit and below most of the building population.

The result supports prioritizing early isolation and connector control for outbreaks beginning on upper floors. It does not establish real FEU Tech evacuation performance because walking scale, elevator operations, bite behavior, and exit capacities remain provisional.

## Important limitations

1. Only three random seeds were evaluated; at least 30 are recommended for confidence intervals.
2. Infected agents can currently be converted to `Escaped` at an exit, so escape totals are not strictly survivor-only counts.
3. Infected agents can use vertical connectors only after the Hour-1 evacuation begins.
4. Regular elevator capacity is aggregated independently per floor rather than tracking eight individual cars.
5. The entrapment increase uses global time since evacuation rather than personal queue duration.
6. Floor 12 is derived from Floor 11 rather than an independently verified drawing.
7. The primary population is 3,713, not the originally discussed exact 4,000.

## Visual outputs

- [Conclusive dashboard](outbreak_origin_conclusive_dashboard.png)
- [Primary outcome comparison](../../results/outbreak_origin_scenarios/scenario_outcome_comparison.png)
- [Three-seed comparison](../../results/outbreak_origin_scenarios/replicated_scenario_comparison.png)
- [Floor 2 population progression](../../results/outbreak_origin_scenarios/second_floor_outbreak/population_progression.png)
- [Floor 8 population progression](../../results/outbreak_origin_scenarios/eighth_floor_outbreak/population_progression.png)
- [Floor 16 population progression](../../results/outbreak_origin_scenarios/sixteenth_floor_outbreak/population_progression.png)

## Scenario animations

- [Floor 2 outbreak animation](../animation/second_floor_outbreak.mp4)
- [Floor 8 outbreak animation](../animation/eighth_floor_outbreak.mp4)
- [Floor 16 outbreak animation](../animation/sixteenth_floor_outbreak.mp4)
