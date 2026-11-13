function report = validateBuildingModel(cfg, building)
%VALIDATEBUILDINGMODEL Check spatial contracts before simulation.

assert(numel(building.floors) == 16, "Building must contain 16 floors.");
allowedCodes = [cfg.Cell.Wall cfg.TraversableCellCodes];
floorChecks = strings(numel(building.floors), 1);

for floorNumber = 1:numel(building.floors)
    floorGrid = building.floors(floorNumber).grid;
    assert(isa(floorGrid, 'uint8'), "Floor %d grid must be uint8.", floorNumber);
    assert(isequal(size(floorGrid), [cfg.GridRows cfg.GridColumns]), ...
        "Floor %d has unexpected dimensions.", floorNumber);
    assert(all(ismember(unique(floorGrid), allowedCodes)), ...
        "Floor %d contains undefined cell codes.", floorNumber);
    assert(sum(floorGrid(:) == cfg.Cell.Stair) >= 2, ...
        "Floor %d requires at least two staircase cells.", floorNumber);
    assert(any(floorGrid(:) == cfg.Cell.Elevator), ...
        "Floor %d requires an elevator cell in the framework.", floorNumber);
    assertTraversableReachability(floorGrid, cfg, floorNumber);
    floorChecks(floorNumber) = "passed";
end

groundGrid = building.floors(1).grid;
assert(any(groundGrid(:) == cfg.Cell.Exit), "Ground Floor requires an evacuation exit.");

for floorNumber = 2:numel(building.floors)
    assert(~any(building.floors(floorNumber).grid(:) == cfg.Cell.Exit), ...
        "Placeholder upper floors must not define external exits.");
end

report = table((1:16)', floorChecks, ...
    'VariableNames', {'floor_index', 'framework_validation'});
end

function assertTraversableReachability(floorGrid, cfg, floorNumber)
traversable = ismember(floorGrid, cfg.TraversableCellCodes);
[startRow, startCol] = find(traversable, 1, 'first');
assert(~isempty(startRow), "Floor %d has no traversable cells.", floorNumber);

visited = false(size(traversable));
queue = zeros(nnz(traversable), 2, 'uint16');
head = 1;
tail = 1;
queue(tail, :) = uint16([startRow startCol]);
visited(startRow, startCol) = true;
directions = int16([-1 0; 1 0; 0 -1; 0 1]);

while head <= tail
    current = int16(queue(head, :));
    head = head + 1;
    for directionIndex = 1:4
        neighbor = current + directions(directionIndex, :);
        row = neighbor(1);
        col = neighbor(2);
        if row >= 1 && row <= size(floorGrid, 1) && col >= 1 && col <= size(floorGrid, 2) ...
                && traversable(row, col) && ~visited(row, col)
            tail = tail + 1;
            queue(tail, :) = uint16([row col]);
            visited(row, col) = true;
        end
    end
end

assert(all(visited(traversable)), ...
    "Floor %d has disconnected traversable regions.", floorNumber);
end

