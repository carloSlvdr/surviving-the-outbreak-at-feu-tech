# Submission checklist

Final review date: 2026-11-18

## Repository checks

- [x] Project title consistently uses *Surviving the Outbreak at FEU Tech: An Agent-Based Simulation of a Zombie Outbreak*.
- [x] Active code models 15 physical levels: Ground Floor, Floors 2-12, and Floors 14-16.
- [x] Floors 13 and 17 are excluded from the active floor list.
- [x] The primary recorded population is documented as 3,713 rather than an exact 4,000.
- [x] The active scenarios are the Floor 2, Floor 8, and Floor 16 outbreak origins.
- [x] The VS Code default task points to `runGridProject`.
- [x] Private proposal and architectural source files remain excluded from Git.
- [x] Reproducible detailed results and generated grid files remain excluded from Git.

## Validation checks

- [x] `matlab -batch "run('tests/run_all_tests.m')"` passes.
- [x] Population conservation is asserted during every simulation update.
- [x] Every occupied space has a valid occupancy range and reachable walkable cells.
- [x] Floor 11 and the user-directed Floor 12 derivation have matching geometry.
- [x] Every upper floor contains eight regular elevator shafts and one green elevator.
- [x] Elevator safety margins contain no room or door cells.
- [x] Fixed-seed replay produces identical scenario time series.

## Submission artifacts

- [x] Complete analysis report (`output/documents/`, DOCX)
- [x] Matching complete analysis report (`output/pdf/`, PDF)
- [x] Conclusive Markdown analysis and normalized summary (`output/analysis/`)
- [x] Conclusive comparison dashboard (`output/analysis/`)
- [x] Floor-layout atlas and individual floor previews (`output/layouts/`)
- [x] Floor 2, Floor 8, and Floor 16 MP4 animations (`output/animation/`)
- [x] Model factors, criteria, facts, limitations, and workflow documentation (`docs/`)
- [x] SHA-256 checksums for the principal submission artifacts (`output/SHA256SUMS.txt`)

## Final interpretation note

The repository is submission-ready as a comparative simulation project. It is not a validated emergency-response model. The report must retain its stated limitations concerning unscaled geometry, provisional transmission and transport parameters, three-seed uncertainty, infected exit handling, aggregated elevator behavior, global entrapment timing, provisional Floor 1 geometry, and derived Floor 12 geometry.
