function report = validateBuildingModel(cfg, building, data)
%VALIDATEBUILDINGMODEL Validate geometry, connectors, rooms, and exits.

assert(numel(building.floors) == 15, "Building must contain 15 floors.");
assert(isequal(building.physicalFloorIds, [1:12 14:16]), "Unexpected physical floor sequence.");
checks = strings(cfg.NumFloors, 1);
reachableRooms = zeros(cfg.NumFloors, 1);
roomCounts = zeros(cfg.NumFloors, 1);

for floorIndex = 1:cfg.NumFloors
    floorGrid = building.floors(floorIndex).grid;
    assert(isa(floorGrid, 'uint8') && isequal(size(floorGrid), [cfg.GridRows cfg.GridColumns]));
    assert(all(ismember(unique(floorGrid), [cfg.Cell.Wall cfg.TraversableCellCodes])));
    if floorIndex == 1
        assert(~any(floorGrid(:) == cfg.Cell.Stair), "Stairs cannot reach Floor 1.");
        assert(~any(floorGrid(:) == cfg.Cell.RegularElevator), "Regular elevators cannot reach Floor 1.");
        assert(any(floorGrid(:) == cfg.Cell.GreenElevator) && any(floorGrid(:) == cfg.Cell.Exit));
    else
        assert(nnz(floorGrid == cfg.Cell.Stair) >= 2, "Each upper floor requires two stair approaches.");
        assert(any(floorGrid(:) == cfg.Cell.RegularElevator), "Each upper floor requires regular elevator service.");
    end
    traversable = ismember(floorGrid, cfg.TraversableCellCodes);
    visited = floodFill(traversable);
    roomRows = find(data.rooms.floor_index == floorIndex);
    roomCounts(floorIndex) = numel(roomRows);
    for roomRow = roomRows'
        cells = building.floors(floorIndex).roomMap == roomRow;
        if any(cells(:)) && all(visited(cells))
            reachableRooms(floorIndex) = reachableRooms(floorIndex) + 1;
        end
    end
    assert(reachableRooms(floorIndex) == roomCounts(floorIndex), ...
        "Floor %d has unreachable occupied rooms.", floorIndex);
    checks(floorIndex) = "passed";
end

report = table((1:cfg.NumFloors)', cfg.PhysicalFloorIds', ...
    string({building.floors.floorLabel})', roomCounts, reachableRooms, checks, ...
    'VariableNames', {'floor_index', 'physical_floor_id', 'floor_label', ...
    'occupied_rooms', 'reachable_rooms', 'framework_validation'});
end

function visited = floodFill(traversable)
[startRow, startCol] = find(traversable, 1, 'first');
visited = false(size(traversable));
queue = zeros(nnz(traversable), 2, 'uint16');
head = 1; tail = 1;
queue(1, :) = uint16([startRow startCol]);
visited(startRow, startCol) = true;
directions = int16([-1 0; 1 0; 0 -1; 0 1]);
while head <= tail
    current = int16(queue(head, :)); head = head + 1;
    for directionIndex = 1:4
        neighbor = current + directions(directionIndex, :);
        row = neighbor(1); column = neighbor(2);
        if row >= 1 && row <= size(traversable, 1) && column >= 1 && column <= size(traversable, 2) ...
                && traversable(row, column) && ~visited(row, column)
            tail = tail + 1; queue(tail, :) = uint16([row column]);
            visited(row, column) = true;
        end
    end
end
end
