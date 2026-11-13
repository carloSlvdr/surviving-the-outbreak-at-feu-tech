function building = buildBuildingModel(cfg, data)
%BUILDBUILDINGMODEL Construct the 16-floor spatial model contract.
% The initial grids are labeled placeholders and are not architectural plans.

numFloors = height(data.floors);
floorTemplate = struct( ...
    'floorIndex', uint8(0), ...
    'floorLabel', "", ...
    'mainFunction', "", ...
    'referenceStatus', "", ...
    'layoutSource', "", ...
    'gridSource', "Placeholder generated framework", ...
    'grid', zeros(cfg.GridRows, cfg.GridColumns, 'uint8'));
floors = repmat(floorTemplate, numFloors, 1);

for floorNumber = 1:numFloors
    floors(floorNumber).floorIndex = uint8(data.floors.floor_index(floorNumber));
    floors(floorNumber).floorLabel = string(data.floors.floor_label(floorNumber));
    floors(floorNumber).mainFunction = string(data.floors.main_function(floorNumber));
    floors(floorNumber).referenceStatus = string(data.floors.reference_status(floorNumber));
    floors(floorNumber).layoutSource = string(data.floors.layout_source(floorNumber));
    floors(floorNumber).grid = createPlaceholderGrid(cfg, floorNumber);
end

building.projectTitle = cfg.ProjectTitle;
building.cellCodes = cfg.Cell;
building.traversableCellCodes = cfg.TraversableCellCodes;
building.floors = floors;
building.connections = data.connections;
building.exits = data.exits;
building.isArchitecturallyVerified = false;
building.frameworkVersion = "0.1.0";
end

function grid = createPlaceholderGrid(cfg, floorNumber)
rows = cfg.GridRows;
cols = cfg.GridColumns;
grid = repmat(cfg.Cell.Room, rows, cols);

grid([1 rows], :) = cfg.Cell.Wall;
grid(:, [1 cols]) = cfg.Cell.Wall;

middleRows = floor(rows / 2) + (-1:1);
middleCols = floor(cols / 2) + (-1:1);
grid(middleRows, 2:cols-1) = cfg.Cell.Walkable;
grid(2:rows-1, middleCols) = cfg.Cell.Walkable;

partitionColumns = [15 45];
for column = partitionColumns
    grid(2:rows-1, column) = cfg.Cell.Wall;
    grid(middleRows, column) = cfg.Cell.Walkable;
    grid(8:10, column) = cfg.Cell.Walkable;
    grid(rows-9:rows-7, column) = cfg.Cell.Walkable;
end

grid(3, 3) = cfg.Cell.Stair;
grid(rows-2, cols-2) = cfg.Cell.Stair;
grid(floor(rows/2), floor(cols/2)) = cfg.Cell.Elevator;
grid(middleRows, middleCols + 5) = cfg.Cell.Special;

if floorNumber == 1
    grid(rows, floor(cols/2)) = cfg.Cell.Exit;
    grid(rows-1, floor(cols/2)) = cfg.Cell.Walkable;
end
end

