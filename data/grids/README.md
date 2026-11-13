# Floor grid files

Run `buildModelFramework` to generate the current sixteen placeholder `.mat` grids.

Every grid file contains a `uint8` occupancy matrix named `grid` and a `metadata` structure containing its floor label, function, reference status, layout source, and grid source.

Generated placeholders are software-development assets only. Replace them with digitized layouts as verified floor plans become available, while preserving the cell-code definitions in `config/defaultConfig.m`.

