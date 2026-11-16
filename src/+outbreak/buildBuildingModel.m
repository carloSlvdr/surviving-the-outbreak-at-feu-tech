function building = buildBuildingModel(cfg, data)
%BUILDBUILDINGMODEL Construct the authoritative fifteen-floor environment.

floorTemplate = struct( ...
    'floorIndex', uint8(0), 'physicalFloorId', uint8(0), 'floorLabel', "", ...
    'mainFunction', "", 'referenceStatus', "", 'layoutSource', "", ...
    'greenStopStatus', "none", ...
    'grid', zeros(cfg.GridRows, cfg.GridColumns, 'uint8'), ...
    'roomMap', zeros(cfg.GridRows, cfg.GridColumns, 'uint16'));
floors = repmat(floorTemplate, cfg.NumFloors, 1);

for floorIndex = 1:cfg.NumFloors
    physicalId = data.floors.physical_floor_id(floorIndex);
    floors(floorIndex).floorIndex = uint8(floorIndex);
    floors(floorIndex).physicalFloorId = uint8(physicalId);
    floors(floorIndex).floorLabel = string(data.floors.floor_label(floorIndex));
    floors(floorIndex).mainFunction = string(data.floors.main_function(floorIndex));
    floors(floorIndex).referenceStatus = string(data.floors.reference_status(floorIndex));
    floors(floorIndex).layoutSource = string(data.floors.layout_source(floorIndex));
    if ismember(physicalId, cfg.GreenElevatorConfirmedStops)
        floors(floorIndex).greenStopStatus = "verified";
    elseif ismember(physicalId, cfg.GreenElevatorInferredStops)
        floors(floorIndex).greenStopStatus = "inferred";
    end
    [floors(floorIndex).grid, floors(floorIndex).roomMap] = ...
        outbreak.createPlanDerivedGrid(cfg, floorIndex, data.rooms);
end

building.projectTitle = cfg.ProjectTitle;
building.physicalFloorIds = cfg.PhysicalFloorIds;
building.cellCodes = cfg.Cell;
building.traversableCellCodes = cfg.TraversableCellCodes;
building.floors = floors;
building.connections = data.connections;
building.exits = data.exits;
building.isArchitecturallyVerified = false;
building.frameworkVersion = "1.0.0-authoritative-drawings";
end
