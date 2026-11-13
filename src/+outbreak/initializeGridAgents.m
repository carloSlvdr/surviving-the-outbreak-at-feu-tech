function agents = initializeGridAgents(cfg, building, occupancy)
%INITIALIZEGRIDAGENTS Place all agents on valid non-connector cells.

rng(cfg.RandomSeed, "twister");
agentId = uint32((1:cfg.NumAgents)');
floorIndex = zeros(cfg.NumAgents, 1, 'uint8');
gridRow = zeros(cfg.NumAgents, 1, 'uint16');
gridColumn = zeros(cfg.NumAgents, 1, 'uint16');
status = repmat(cfg.Status.NonInfected, cfg.NumAgents, 1);

nextAgent = 1;
spawnCodes = uint8([cfg.Cell.Walkable cfg.Cell.Room cfg.Cell.Special]);
for floorNumber = 1:numel(building.floors)
    count = occupancy.population(floorNumber);
    floorGrid = building.floors(floorNumber).grid;
    candidates = find(ismember(floorGrid, spawnCodes));
    assert(numel(candidates) >= count, ...
        "Floor %d has fewer spawn cells than assigned agents.", floorNumber);
    selected = candidates(randperm(numel(candidates), count));
    [rows, columns] = ind2sub(size(floorGrid), selected);
    rowsForFloor = nextAgent:(nextAgent + count - 1);
    floorIndex(rowsForFloor) = uint8(floorNumber);
    gridRow(rowsForFloor) = uint16(rows);
    gridColumn(rowsForFloor) = uint16(columns);
    nextAgent = nextAgent + count;
end

infectedCandidates = find(floorIndex == cfg.InitialInfectedFloorIndex);
infectedRows = infectedCandidates(randperm(numel(infectedCandidates), cfg.InitialInfectedCount));
status(infectedRows) = cfg.Status.Infected;

agents = table(agentId, floorIndex, gridRow, gridColumn, status, floorIndex, ...
    'VariableNames', {'agent_id', 'floor_index', 'grid_row', 'grid_column', ...
    'status', 'initial_floor_index'});
end

