# Generated floor-grid files

The active model contains 15 normalized 40-by-60 floor grids for physical floors `[1:12, 14:16]`.

Run either `buildModelFramework` or `runGridProject` to construct and validate the current grids. Grid generation is implemented by `src/+outbreak/createPlanDerivedGrid.m`; generated `.mat` files are ignored because they are reproducible from the tracked source and data tables.

Each grid uses the cell codes defined in `config/defaultConfig.m` and preserves drawing-derived topology and relative placement. The grids are not placeholder architectural plans and do not claim measured scale. Floor 1 is provisional, and Floor 12 is explicitly derived from the revised Floor 11 plan pending an independently verified drawing.
