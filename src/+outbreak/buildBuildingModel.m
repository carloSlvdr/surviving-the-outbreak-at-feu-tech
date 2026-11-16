function building = buildBuildingModel(cfg, data)
%BUILDBUILDINGMODEL Construct occupied floors plus an abstract exit sink.

numFloors = height(data.floors);
floorTemplate = struct( ...
    'floorIndex', uint8(0), ...
    'floorLabel', "", ...
    'mainFunction', "", ...
    'referenceStatus', "", ...
    'layoutSource', "", ...
    'gridSource', "Plan-derived schematic", ...
    'sourceReference', "", ...
    'planCoverage', "", ...
    'connectorStatus', "", ...
    'grid', zeros(cfg.GridRows, cfg.GridColumns, 'uint8'));
floors = repmat(floorTemplate, numFloors, 1);

for floorNumber = 1:numFloors
    floors(floorNumber).floorIndex = uint8(data.floors.floor_index(floorNumber));
    floors(floorNumber).floorLabel = string(data.floors.floor_label(floorNumber));
    floors(floorNumber).mainFunction = string(data.floors.main_function(floorNumber));
    floors(floorNumber).referenceStatus = string(data.floors.reference_status(floorNumber));
    floors(floorNumber).layoutSource = string(data.floors.layout_source(floorNumber));

    if floorNumber == 1
        floors(floorNumber).gridSource = "Abstract evacuation sink";
        floors(floorNumber).sourceReference = "Ground floor excluded by project scope";
        floors(floorNumber).planCoverage = "No garage geometry modeled";
        floors(floorNumber).connectorStatus = "Final stair transition discharges to exit corridor";
        floors(floorNumber).grid = createAbstractExitGrid(cfg);
        continue;
    end

    traceabilityRow = find(data.planTraceability.floor_index == floorNumber, 1);
    assert(~isempty(traceabilityRow), ...
        "Occupied floor %d requires a plan traceability record.", floorNumber);
    floors(floorNumber).sourceReference = string(data.planTraceability.source_reference(traceabilityRow));
    floors(floorNumber).planCoverage = string(data.planTraceability.coverage(traceabilityRow));
    floors(floorNumber).connectorStatus = string(data.planTraceability.connector_status(traceabilityRow));
    floors(floorNumber).grid = outbreak.createPlanDerivedGrid(cfg, floorNumber);
end

building.projectTitle = cfg.ProjectTitle;
building.cellCodes = cfg.Cell;
building.traversableCellCodes = cfg.TraversableCellCodes;
building.floors = floors;
building.connections = data.connections;
building.exits = data.exits;
building.isArchitecturallyVerified = false;
building.frameworkVersion = "0.2.0";
end

function grid = createAbstractExitGrid(cfg)
% The garage is intentionally absent; this is only an evacuation endpoint.
rows = cfg.GridRows;
cols = cfg.GridColumns;
grid = repmat(cfg.Cell.Wall, rows, cols);
grid(3, 3:floor(cols/2)) = cfg.Cell.Walkable;
grid(3:rows-1, floor(cols/2)) = cfg.Cell.Walkable;
grid(rows-2, floor(cols/2):cols-2) = cfg.Cell.Walkable;
grid(3, 3) = cfg.Cell.Stair;
grid(rows-2, cols-2) = cfg.Cell.Stair;
grid(floor(rows/2), floor(cols/2)) = cfg.Cell.Elevator;
grid(rows, floor(cols/2)) = cfg.Cell.Exit;
end
